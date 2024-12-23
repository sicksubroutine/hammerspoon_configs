--- Tries to define an easier way to create strings with variables
---@param s string
---@param tab table
---@return string
---@usage print("Hello, ${name}! You are ${age} years old." % {name="John", age=30})
local function interp(s, tab)
-- Example of usage:
-- local name = "John"
-- local age = 30
-- "Hello, ${name}! You are ${age} years old." % {name=name, age=age})
    return (s:gsub('${([%w.]+)}', function(w)
      local keys = {}
      for key in w:gmatch('[^.]+') do table.insert(keys, key) end
      
      local value = tab
      for _, key in ipairs(keys) do
        value = value[key]
        if value == nil then break end
      end
      
      return value ~= nil and tostring(value) or ''
    end))
  end
-- Makes the above function available as a method on strings
getmetatable("").__mod = interp

local function debugPrint(...)
  if DebugMode then print(...) end
end

local function unixTimestamp()
  return os.time()
end

_G.str = tostring

local function readFile(path)
  
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return content
end

-- ---Join a table of strings into a string and returns it
-- ---@param strings table<string>
-- ---@param separator string
-- ---@return string
-- local function join(strings, separator)
--   return table.concat(strings, separator)
-- end

__setGlobals__({
  unixTimestamp = unixTimestamp,
  str = str,
  debugPrint = debugPrint,
  readFile = readFile
})
