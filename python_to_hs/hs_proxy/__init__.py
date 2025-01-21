import atexit
from enum import Enum
from threading import Lock
from subprocess import PIPE
from dataclasses import dataclass
from abc import ABC, abstractmethod
from subprocess import check_output, CalledProcessError, TimeoutExpired
from typing import Union, List, Optional, ClassVar, Any, Type, TYPE_CHECKING


if TYPE_CHECKING:
    from stubs.hs import HammerSpoon

OBJECT_TABLE_NAME = "__python_bridge_storage"
HAMMERSPOON_CLI_PATH = "/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs"


class LuaObjectLike(ABC):
    @abstractmethod
    def _unwrap(self) -> "LuaObject":
        """Convert this object to a raw LuaObject"""


class LuaType(Enum):
    NUMBER = "number"
    STRING = "string"
    BOOLEAN = "boolean"
    TABLE = "table"
    FUNCTION = "function"
    NIL = "nil"

    @classmethod
    def from_python_type(cls, py_type: Type) -> "LuaType":
        type_map = {
            int: cls.NUMBER,
            float: cls.NUMBER,
            str: cls.STRING,
            bool: cls.BOOLEAN,
            dict: cls.TABLE,
            list: cls.TABLE,
            tuple: cls.TABLE,
            type(None): cls.NIL,
            callable: cls.FUNCTION,
        }
        return type_map.get(py_type, cls.NIL)

    @classmethod
    def to_python_type(cls, lua_type: "LuaType") -> Type:
        type_map = {
            cls.NUMBER: float,
            cls.STRING: str,
            cls.BOOLEAN: bool,
            cls.TABLE: dict,
            cls.FUNCTION: callable,
            cls.NIL: type(None),
        }
        return type_map.get(lua_type, object)


NUMBER, STRING, BOOLEAN, TABLE, FUNCTION, NIL = (
    LuaType.NUMBER,
    LuaType.STRING,
    LuaType.BOOLEAN,
    LuaType.TABLE,
    LuaType.FUNCTION,
    LuaType.NIL,
)


class TypeConverter:
    @staticmethod
    def to_lua(value: Any) -> str:
        """Convert any Python value to Lua code string"""
        if isinstance(value, (int, float)):
            return str(value)
        elif isinstance(value, str):
            return f"'{value}'"
        elif isinstance(value, bool):
            return str(value).lower()
        elif value is None:
            return "nil"
        elif isinstance(value, (list, tuple)):
            items = [TypeConverter.to_lua(item) for item in value]
            return f"{{ {', '.join(items)} }}"
        elif isinstance(value, dict):
            items = [f"[{TypeConverter.to_lua(k)}] = {TypeConverter.to_lua(v)}" for k, v in value.items()]
            return f"{{ {', '.join(items)} }}"
        else:
            raise ValueError(f"Cannot convert {value} of type {type(value)} to Lua")

    @staticmethod
    def _convert_lua_table(value: str) -> Union[dict, list]:
        """Helper method to convert Lua table string to Python dict/list"""
        # Handle empty tables
        if value.strip("{}") == "":
            return {}

        # Remove outer braces and whitespace
        value = value.strip("{ }").strip()

        # Split by commas not inside nested structures
        items = []
        current = ""
        brace_count = 0
        for char in value:
            if char == "{":
                brace_count += 1
            elif char == "}":
                brace_count -= 1
            elif char == "," and brace_count == 0:
                items.append(current.strip())
                current = ""
                continue
            current += char
        if current:
            items.append(current.strip())

        # Convert to appropriate Python type
        is_array = all(not item.startswith("[") for item in items if item)
        if is_array:
            return [TypeConverter.from_lua(LuaType.from_python_type(type(item)), item) for item in items if item]

        # Handle dictionary-style tables
        result = {}
        for item in items:
            if not item or "=" not in item:
                continue
            key_str, value_str = item.split("=", 1)
            key_str = key_str.strip("[]")
            key_type = LuaType.NUMBER if key_str.isdigit() else LuaType.STRING
            key = TypeConverter.from_lua(key_type, key_str)
            value_type = LuaType.from_python_type(type(eval(value_str)))
            value = TypeConverter.from_lua(value_type, value_str)
            result[key] = value
        return result

    @staticmethod
    def from_lua(lua_type: LuaType, value: str) -> Any:
        """Convert Lua string value to Python type T"""
        if lua_type == NUMBER:
            value = str(value).strip("'\"")
            return float(value) if "." in value else int(value)
        elif lua_type == STRING:
            return str(value).strip("'\"")
        elif lua_type == BOOLEAN:
            return value.lower() == "true"
        elif lua_type == NIL:
            return None
        elif lua_type == TABLE:
            return TypeConverter._convert_lua_table(value)

        raise ValueError(f"Cannot convert Lua value {value} of type {lua_type}")


class LuaObject(LuaObjectLike):
    _id_lock: ClassVar[Lock] = Lock()
    _last_id: ClassVar[int] = 0

    @classmethod
    def new_id(cls) -> int:
        """Generate a unique ID for Lua objects in a thread-safe manner"""
        with cls._id_lock:
            cls._last_id += 1
            return cls._last_id

    def __init__(self, bridge):
        self.id: int = self.new_id()
        self.bridge: "LuaBridge" = bridge
        self.accessed_from: Optional["LuaObject"] = None

    @staticmethod
    def from_python_object(bridge: "LuaBridge", obj) -> "LuaObject":
        """Convert Python objects to Lua objects using TypeConverter"""
        if isinstance(obj, LuaObjectLike):
            return obj._unwrap()

        # Use TypeConverter for primitive types
        if isinstance(obj, (float, int, str, bool)) or obj is None:
            lua_str = TypeConverter.to_lua(obj)
            return bridge.execute_lua(lua_str)

        # Handle lists using TypeConverter
        if isinstance(obj, list):
            sub_objs = [LuaObject.from_python_object(bridge, item) for item in obj]
            list_items_str = ", ".join(subobj.lua_accessor() for subobj in sub_objs)
            return bridge.execute_lua(f"{{ {list_items_str} }}")

        # Handle dicts using TypeConverter
        if isinstance(obj, dict):
            items = []
            for k, v in obj.items():
                key = LuaObject.from_python_object(bridge, k)
                value = LuaObject.from_python_object(bridge, v)
                items.append(f"[{key.lua_accessor()}] = {value.lua_accessor()}")
            return bridge.execute_lua(f"{{ {', '.join(items)} }}")

        # Handle callable objects
        if callable(obj):

            def wrapper(*args):
                result = obj(*args)
                return LuaObject.from_python_object(bridge, result)

            proxy = LuaObject(bridge)
            bridge._function_registry[proxy.id] = wrapper
            bridge.execute_lua_raw(
                f"""
                {proxy.lua_accessor()} = function(...)
                    local args = {{...}}
                    return __python_bridge_call({proxy.id}, args)
                end
            """
            )
            return proxy

        raise TypeError(f"Cannot convert {obj} of type {type(obj)} to Lua object")

    def get_property(self, name: str) -> "LuaObject":
        result = self.bridge.execute_lua(f"{self.lua_accessor()}.{name}")
        result.accessed_from = self
        return result

    def __call__(self, *args: List["LuaObject"]) -> "LuaObject":
        # The first argument being ... indicates an instance method call
        args = list(args)
        if len(args) > 0 and args[0] == ...:
            args[0] = self.accessed_from

        for i, arg in enumerate(args):
            if not isinstance(arg, LuaObjectLike):
                args[i] = self.from_python_object(self.bridge, arg)

        args_string = ", ".join([arg.lua_accessor() for arg in args])
        return self.bridge.execute_lua(f"{self.lua_accessor()}({args_string})")

    def __getitem__(self, key: "LuaObject") -> "LuaObject":
        key = self.from_python_object(self.bridge, key)
        return self.bridge.execute_lua(f"{self.lua_accessor()}[{key.lua_accessor()}]")

    def __setitem__(self, key: Union[str, int, float], value: Any) -> None:
        if not isinstance(key, (str, int, float)):
            raise TypeError(f"Invalid key type: {type(key)}. Must be str, int, or float")
        key = self.from_python_object(self.bridge, key)
        value = self.from_python_object(self.bridge, value)
        return self.bridge.execute_lua(f"{self.lua_accessor()}[{key.lua_accessor()}] = {value.lua_accessor()}")

    def __len__(self) -> "LuaObject":
        return int(self.bridge.execute_lua(f"#{self.lua_accessor()}").lua_repr())

    def lua_accessor(self) -> str:
        return f"{OBJECT_TABLE_NAME}[{self.id}]"

    def _unwrap(self) -> "LuaObject":
        return self

    def lua_repr(self) -> str:
        return self.bridge.execute_lua_raw(self.lua_accessor())

    def __str__(self, wrapped=False) -> str:
        wrapped_repr = " [proxy]" if wrapped else ""
        return f"<Lua object {self.id}{wrapped_repr}: {self.lua_repr()}>"

    def __repr__(self, wrapped=False) -> str:
        return self.__str__(wrapped=wrapped)

    def __del__(self):
        try:
            # Only attempt cleanup if bridge is still alive and cleanup hasn't happened
            if hasattr(self, "bridge") and hasattr(self.bridge, "_active_objects"):
                self.bridge.execute_lua_raw(f"{self.lua_accessor()} = nil")
                if self.id in self.bridge._active_objects:
                    self.bridge._active_objects.remove(self.id)
        except Exception:
            # Silently fail on cleanup errors - they're usually due to interpreter shutdown
            pass


@dataclass
class LuaObjectWrapper(LuaObjectLike):
    obj: LuaObject

    def _unwrap(self) -> LuaObject:
        return self.obj

    def __getattr__(self, name) -> "LuaObjectWrapper":
        return LuaObjectWrapper(self.obj.get_property(name))

    def __getitem__(self, key) -> "LuaObjectWrapper":
        return LuaObjectWrapper(self.obj.__getitem__(key))

    def __setitem__(self, key, value) -> "LuaObjectWrapper":
        return LuaObjectWrapper(self.obj.__setitem__(key, value))

    def __len__(self) -> "LuaObjectWrapper":
        return LuaObjectWrapper(self.obj.__len__())

    def __call__(self, *args) -> "LuaObjectWrapper":
        return LuaObjectWrapper(self.obj(*[arg._unwrap() if isinstance(arg, LuaObjectLike) else arg for arg in args]))

    def __str__(self) -> str:
        return self.obj.__str__(wrapped=True)

    def __repr__(self) -> str:
        return self.__str__()


@dataclass
class LuaTopLevelWrapper:
    bridge: "LuaBridge"

    def __getattr__(self, name) -> "LuaObjectWrapper":
        return LuaObjectWrapper(self.bridge.execute_lua(name))


class LuaBridge:
    """Bridge between Python and Lua (Hammerspoon)

    Example:
        with LuaBridge() as bridge:
            # Execute Lua code
            result = bridge.execute_lua("return 42")

            # Convert Python objects to Lua
            lua_dict = bridge.from_python_object({"key": "value"})

            # Access Hammerspoon API
            hs = bridge.proxy()
            hs.alert("Hello from Python!")
    """

    def __init__(self):
        self._function_registry = {}
        self._active_objects = set()  # Add this line
        self.remote_setup()
        atexit.register(self.cleanup)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.cleanup()

    def from_python_object(self, obj: Any) -> LuaObject:
        """Convert Python object to Lua object"""
        return LuaObject.from_python_object(self, obj)

    # Helper methods for Lua type operations
    def lua_type(self, lua_obj) -> str:
        """Get the Lua type of an object"""
        return self.execute_lua_raw(f"type({lua_obj.lua_accessor()})")

    def lua_tostring(self, lua_obj) -> str:
        """Convert Lua object to string"""
        return self.execute_lua_raw(f"tostring({lua_obj.lua_accessor()})")

    def lua_tonumber(self, lua_obj) -> float:
        """Convert Lua object to number"""
        value = self.lua_tostring(lua_obj)
        return float(value) if "." in value else int(value)

    def lua_length(self, lua_obj) -> int:
        """Get length of Lua table"""
        return int(self.execute_lua_raw(f"#{lua_obj.lua_accessor()}"))

    def lua_is_array(self, lua_obj) -> bool:
        """Check if Lua table is array-like"""
        return (
            self.execute_lua_raw(
                f"""
            local t = {lua_obj.lua_accessor()}
            local i = 0
            for _ in pairs(t) do i = i + 1 end
            return #t == i
        """
            )
            == "true"
        )

    def lua_get_keys(self, lua_obj) -> "LuaObject":
        """Get all keys from a Lua table"""
        return self.execute_lua(
            f"""
            local keys = {{}}
            for k, _ in pairs({lua_obj.lua_accessor()}) do
                table.insert(keys, k)
            end
            return keys
        """
        )

    def remote_setup(self):
        try:
            self.execute_lua_raw(
                f"""
                {OBJECT_TABLE_NAME} = {{}}
                function __python_bridge_call(func_id, args)
                    -- Call back into Python
                    return hs.execute(string.format(
                        'python3 -c "from your_module import bridge; print(bridge.call_python_function(%d, %s))"',
                        func_id,
                        table.concat(args, ',')
                    ))
                end
            """
            )
        except (CalledProcessError, TimeoutExpired) as e:
            raise RuntimeError(f"Failed to initialize Lua bridge: {e}")

    def call_python_function(self, func_id: int, args: List[Any]) -> Any:
        """Bridge method to call Python functions from Lua"""
        if func_id not in self._function_registry:
            raise RuntimeError(f"No function registered with id {func_id}")
        func = self._function_registry[func_id]
        return func(*[self.from_lua_object(arg) for arg in args])

    def from_lua_object(self, lua_obj) -> Any:
        """Convert Lua objects to Python objects using TypeConverter"""
        if lua_obj is None:
            return None

        lua_type = self.lua_type(lua_obj)

        try:
            # Handle primitive types using TypeConverter
            if lua_type in (NUMBER, STRING, BOOLEAN, NIL):
                return TypeConverter.from_lua(lua_type, lua_obj.lua_repr())

            # Handle tables
            elif lua_type == TABLE:
                if self.lua_is_array(lua_obj):
                    length = self.lua_length(lua_obj)
                    return [self.from_lua_object(lua_obj[i + 1]) for i in range(length)]
                else:
                    result = {}
                    lua_keys = self.lua_get_keys(lua_obj)
                    for key in lua_keys:  # is this iterable?
                        key_py = self.from_lua_object(key)
                        value_py = self.from_lua_object(lua_obj[key])
                        result[key_py] = value_py
                    return result

            # Handle functions
            elif lua_type == FUNCTION:

                def wrapper(*args):
                    lua_args = [self.from_python_object(self, arg) for arg in args]  # is this correct?
                    result = lua_obj(*lua_args)
                    return self.from_lua_object(result)

                return wrapper

        except ValueError as e:
            raise RuntimeError(f"Error converting Lua value: {e}")

        return LuaObjectWrapper(lua_obj)

    def cleanup(self):
        """Clean up all remaining Lua objects"""
        for obj_id in self._active_objects.copy():
            self.execute_lua_raw(f"{OBJECT_TABLE_NAME}[{obj_id}] = nil")
        self._active_objects.clear()
        self._function_registry.clear()

    def proxy(self) -> LuaTopLevelWrapper:
        return LuaTopLevelWrapper(self)

    def execute_lua(self, cmd: str) -> LuaObject:
        result_object = LuaObject(self)
        self._active_objects.add(result_object.id)  # Track the object
        self.execute_lua_raw(f"{OBJECT_TABLE_NAME}[{result_object.id}] = (function () return {cmd} end)()")
        return result_object

    def execute_lua_raw(self, cmd: str, timeout: float = 5.0) -> str:
        try:
            result = check_output([HAMMERSPOON_CLI_PATH, "-c", cmd], timeout=timeout, stderr=PIPE).decode().rstrip()
            if "error:" in result.lower():
                raise RuntimeError(f"Lua syntax error: {result}")
            return result
        except TimeoutExpired:
            raise RuntimeError(f"Lua command timed out: {cmd}")
        except CalledProcessError as e:
            raise RuntimeError(f"Lua command failed: {cmd}\nError: {e.output.decode()}")


class HammerspoonAPI:
    """Wrapper for Hammerspoon API access

    Example:
        hs = HammerspoonAPI()
        hs.alert("Hello!")
        hs.hotkey.bind("cmd", "space", lambda: print("Pressed!"))
    """

    def __init__(self):
        self._bridge = LuaBridge()
        self._hs: "HammerSpoon" = self._bridge.proxy().hs

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self._bridge.cleanup()

    def __getattr__(self, name: str) -> "LuaObjectWrapper":
        return getattr(self._hs, name)

    @property
    def _type_stub(self) -> "HammerSpoon":
        """Stub property for type hints - never actually called"""
        ...


def init() -> Type["HammerSpoon"]:
    """Initialize Hammerspoon API connection"""
    return HammerspoonAPI()
