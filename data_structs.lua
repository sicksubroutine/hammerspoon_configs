local class = require("30log")

---@class Collection
local Collection = class({name = "Collection"})

--- comment t table maintain_order boolean in the args passed
--- @param ... unknown
--- @return Collection
function Collection:init(...)
    local args = {...}

    self.data = {}

    if #args == 1 and type(args[1]) == 'table' then
        self.data = args[1]
    elseif #args > 0 then
        self.data = args
    end

    self.maintain_order = false
    if type(args[#args]) == 'boolean' then
        self.maintain_order = table.remove(args)
    end

    if self.maintain_order then
        self._key_order = {}
        for k in pairs(self.data) do
            table.insert(self._key_order, k)
        end
    end

    return self
end
-- Data Manipulation Methods
----------------------------
function Collection:append(value)
    table.insert(self.data, value)
    return self
end

function Collection:extend(t)
    for _, v in ipairs(t) do
        table.insert(self.data, v)
    end
    return self
end

function Collection:pop(index)
    return table.remove(self.data, index)
end

function Collection:set(key, value)
    if self.maintain_order and not self.data[key] then
        table.insert(self._key_order, key)
    end
    self.data[key] = value
    return self
end

-- Data Access Methods
----------------------
function Collection:get(key)
    return self.data[key]
end

function Collection:getData()
    return self.data
end

function Collection:len()
    local count = 0
    for _ in pairs(self.data) do count = count + 1 end
    return count
end

-- Iteration Methods
--------------------
function Collection:enumerate()
    local i = 0
    local t = self.data
    return function()
        i = i + 1
        if t[i] then
            return i, t[i]
        end
    end
end

function Collection:items()
    for k, v in pairs(self.data) do
        print(k, v)
    end
end

function Collection:values()
    for _, v in pairs(self.data) do
        print(v)
    end
end

function Collection:keys()
    for k, _ in pairs(self.data) do
        print(k)
    end
end

-- Functional Programming Methods
--------------------------------
function Collection:map(f)
    local mapped = {}
    for k, v in pairs(self.data) do
        mapped[k] = f(v)
    end
    return Collection(mapped)
end

function Collection:filter(fn)
    local filtered = {}
    for _, v in pairs(self.data) do
        if fn(v) then
            table.insert(filtered, v)
        end
    end
    return Collection(filtered)
end

function Collection:reduce(fn, initial)
    local acc = initial
    for _, v in pairs(self.data) do
        acc = fn(acc, v)
    end
    return acc
end

function Collection:any(fn)
    fn = fn or function(x) return x end
    for _, v in pairs(self.data) do
        if fn(v) then return true end
    end
    return false
end

function Collection:all(fn)
    fn = fn or function(x) return x end
    for _, v in pairs(self.data) do
        if not fn(v) then return false end
    end
    return true
end

-- Array Operation Methods
--------------------------
function Collection:range(start, stop, step)
    step = step or 1
    local t = {}
    for i = start, stop, step do
        table.insert(t, i)
    end
    return Collection(t)
end

function Collection:reversed()
    local reversed = {}
    for i = #self.data, 1, -1 do
        table.insert(reversed, self.data[i])
    end
    return Collection(reversed)
end

function Collection:sorted(fn)
    local sorted = {}
    for k, v in pairs(self.data) do
        sorted[k] = v
    end
    table.sort(sorted, fn)
    return Collection(sorted)
end

function Collection:zip(...)
    local args = {self.data, ...}
    local idx = 1
    return function()
        local values = {}
        local all_valid = true
        for _, t in ipairs(args) do
            if t[idx] == nil then
                all_valid = false
                break
            end
            table.insert(values, t[idx])
        end
        if all_valid then
            idx = idx + 1
            return table.unpack(values)
        end
    end
end

-- String and Display Methods
----------------------------
function Collection:str(s)
    return tostring(s)
end

function Collection:pp(indent_spaces)
    indent_spaces = indent_spaces or 2

    local function pp_internal(obj, depth)
        local indent = string.rep(" ", depth * indent_spaces)
        local indent_end = string.rep(" ", (depth - 1) * indent_spaces)
        
        if type(obj) ~= 'table' then
            if type(obj) == 'string' then
                return string.format('"%s"', obj)
            else
                return tostring(obj)
            end
        end

        if next(obj) == nil then
            return "{}"
        end

        local parts = {}
        local is_array = #obj > 0

        -- Use ordered keys if available, otherwise sort them
        local keys
        if self.maintain_order and obj == self.data then
            keys = self._key_order
        else
            keys = {}
            for k in pairs(obj) do
                table.insert(keys, k)
            end
            table.sort(keys, function(a, b)
                if type(a) == type(b) then
                    return a < b
                else
                    return type(a) < type(b)
                end
            end)
        end

        for _, k in ipairs(keys) do
            local v = obj[k]
            local key_str
            if is_array then
                key_str = ""
            else
                if type(k) == 'string' then
                    key_str = string.format('"%s": ', k)
                else
                    key_str = string.format('%s: ', tostring(k))
                end
            end
            table.insert(parts, string.format('%s%s%s',
                indent,
                key_str,
                pp_internal(v, depth + 1)
            ))
        end

        return string.format('{\n%s\n%s}',
            table.concat(parts, ',\n'),
            indent_end
        )
    end

    return pp_internal(self.data, 1)
end

function Collection:join(separator)
    return table.concat(self.data, separator)
end

-- Mathematical Methods
----------------------
function Collection:sum()
    return self:reduce(function(acc, v) return acc + v end, 0)
end

---@class List : Collection
local List = Collection:extend({name = "List"})

function List:init(...)
    print("List init called")
    print("Self before init:", self)
    print("Args:", ...)
    
    if not self then
        print("WARNING: self is nil")
        return nil
    end
    
    self.data = {}  -- Always ensure data is a table
    
    local args = {...}
    
    if #args == 1 and type(args[1]) == 'table' then
        self.data = args[1]
    elseif #args > 0 then
        self.data = args
    end
    
    print("Self after init:", self)
    print("Self.data after init:", self.data)
    
    return self
end


-- Additional List-specific methods
function List:first()
    return self.data[1]
end

function List:last()
    return self.data[#self.data]
end

function List:slice(start, stop)
    start = start or 1
    stop = stop or #self.data
    local sliced = {}
    for i = start, stop do
        table.insert(sliced, self.data[i])
    end
    return List(sliced)
end

function List:insert(index, value)
    table.insert(self.data, index, value)
    return self
end

function List:index(value)
    for i, v in ipairs(self.data) do
        if v == value then
            return i
        end
    end
    return nil
end

function List:count(value)
    local count = 0
    for _, v in ipairs(self.data) do
        if v == value then
            count = count + 1
        end
    end
    return count
end

function List:clear()
    self.data = {}
    if self.maintain_order then
        self._key_order = {}
    end
    return self
end

-- Override some methods to ensure list-like behavior
function List:map(f)
    local mapped = {}
    for i, v in ipairs(self.data) do
        mapped[i] = f(v)
    end
    return List(mapped)
end

function List:filter(fn)
    local filtered = {}
    for _, v in ipairs(self.data) do
        if fn(v) then
            table.insert(filtered, v)
        end
    end
    return List(filtered)
end

--- Deep copy a table
--- @param orig any
--- @return any
local function deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deep_copy(orig_key)] = deep_copy(orig_value)
        end
        setmetatable(copy, deep_copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

---@class Dict : Collection
local Dict = Collection:extend({name = "Dict"})

function Dict:init(...)
    Collection:init(...)
    return self
end

-- Dict-specific methods
function Dict:update(other)
    for k, v in pairs(other) do
        self:set(k, v)
    end
    return self
end

function Dict:pop(key, default)
    local value = self.data[key]
    if value ~= nil then
        self.data[key] = nil
        if self.maintain_order then
            for i, k in ipairs(self._key_order) do
                if k == key then
                    table.remove(self._key_order, i)
                    break
                end
            end
        end
    end
    return value or default
end

function Dict:get(key, default)
    return self.data[key] or default
end

function Dict:setdefault(key, default)
    if self.data[key] == nil then
        self:set(key, default)
    end
    return self.data[key]
end

function Dict:keys()
    local keys = {}
    for k, _ in pairs(self.data) do
        table.insert(keys, k)
    end
    return List(keys)
end

function Dict:values()
    local values = {}
    for _, v in pairs(self.data) do
        table.insert(values, v)
    end
    return List(values)
end

function Dict:items()
    local items = {}
    for k, v in pairs(self.data) do
        table.insert(items, {k, v})
    end
    return List(items)
end

function Dict:copy()
    return Dict(deep_copy(self.data), self.maintain_order)
end

function Dict:clear()
    self.data = {}
    if self.maintain_order then
        self._key_order = {}
    end
    return self
end

---@class Set : Collection
local Set = Collection:extend({name = "Set"})

function Set:init(...)
    Collection:init(...)

    local unique = {}
    for _, v in ipairs(self.data) do
        unique[v] = true
    end
    self.data = unique
    return self
end

-- Set-specific methods
function Set:add(value)
    self.data[value] = true
    return self
end

function Set:remove(value)
    self.data[value] = nil
    return self
end

function Set:contains(value)
    return self.data[value] ~= nil
end

function Set:union(other)
    local result = self:copy()
    for k in pairs(other.data) do
        result:add(k)
    end
    return result
end

function Set:intersection(other)
    local result = Set()
    for k in pairs(self.data) do
        if other:contains(k) then
            result:add(k)
        end
    end
    return result
end

function Set:difference(other)
    local result = Set()
    for k in pairs(self.data) do
        if not other:contains(k) then
            result:add(k)
        end
    end
    return result
end

function Set:symmetric_difference(other)
    local result = Set()
    for k in pairs(self.data) do
        if not other:contains(k) then
            result:add(k)
        end
    end
    for k in pairs(other.data) do
        if not self:contains(k) then
            result:add(k)
        end
    end
    return result
end

function Set:issubset(other)
    for k in pairs(self.data) do
        if not other:contains(k) then
            return false
        end
    end
    return true
end

function Set:issuperset(other)
    return other:issubset(self)
end

function Set:copy()
    local new_set = Set()
    for k in pairs(self.data) do
        new_set:add(k)
    end
    return new_set
end

function Set:clear()
    self.data = {}
    return self
end

function Set:pop()
    for k in pairs(self.data) do
        self.data[k] = nil
        return k
    end
end

function Set:values()
    local values = {}
    for k in pairs(self.data) do
        table.insert(values, k)
    end
    return List(values)
end

---@class Stack : Collection
local Stack = Collection:extend({name = "Stack"})

function Stack:init(...)
    Collection:init(...)
    return self
end

function Stack:push(value)
    table.insert(self.data, value)
    return self
end

function Stack:pop()
    return table.remove(self.data)
end

function Stack:peek()
    return self.data[#self.data]
end

function Stack:isEmpty()
    return #self.data == 0
end

---@class Queue : Collection
local Queue = Collection:extend({name = "Queue"})

function Queue:init(...)
    Collection:init(...)
    return self
end

function Queue:enqueue(value)
    table.insert(self.data, value)
    return self
end

function Queue:dequeue()
    return table.remove(self.data, 1)
end

function Queue:front()
    return self.data[1]
end

function Queue:isEmpty()
    return #self.data == 0
end

---@class Deque : Collection
local Deque = Collection:extend({name = "Deque"})

function Deque:init(...)
    Collection:init(...)
    return self
end

function Deque:pushFront(value)
    table.insert(self.data, 1, value)
    return self
end

function Deque:pushBack(value)
    table.insert(self.data, value)
    return self
end

function Deque:popFront()
    return table.remove(self.data, 1)
end

function Deque:popBack()
    return table.remove(self.data)
end

function Deque:front()
    return self.data[1]
end

function Deque:back()
    return self.data[#self.data]
end

function Deque:isEmpty()
    return #self.data == 0
end

---@class OrderedDict : Dict
local OrderedDict = Dict:extend({name = "OrderedDict"})

function OrderedDict:init(...)
    Dict.init(self, ...)
    self.maintain_order = true
    return self
end

_G.list = function(...) 
    local instance = List()
    instance.data = {}  -- Explicitly set data to an empty table
    if select('#', ...) > 0 then
        return instance:init(...)
    end
    return instance
end

_G.dict = function(...) 
    local instance = Dict()
    return instance:init(...)
end

_G.set = function(...) 
    local instance = Set()
    return instance:init(...)
end

_G.stack = function(...) 
    local instance = Stack()
    return instance:init(...)
end

_G.queue = function(...) 
    local instance = Queue()
    return instance:init(...)
end

_G.deque = function(...) 
    local instance = Deque()
    return instance:init(...)
end

_G.ordereddict = function(...)
    local instance = OrderedDict()
    return instance:init(...)
end
