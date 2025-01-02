---@diagnostic disable: lowercase-global
local class = require("classes.30log")
---@param head string
---@param text string
---@param sepChar string | nil
function dPrint(head, text, sepChar)
  local sepChar = sepChar or "#"
  local fiveSep = string.rep(sepChar, 5)
  local header = "${s} ${h} ${s}\n" % {h=head, s=fiveSep}
  local footer = string.rep("#", #header)
  print("\n${s}\n${h}\n${t}\n${s}" % {s=footer, h=header, t=text})
end

---@param str string The string to colorize
---@param colorName string The color name (red|green|yellow|blue|magenta|cyan|white)
---@return string colorized
function colorStrToAnsiStr(str, colorName)
  local endColor = "\27[0m"
  local colorMap = {
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
  }
  local color = "\27[${c}m" % {c=colorMap[colorName] or 37}
  return "${c}${s}${e}" % {c=color, s=str, e=endColor}
end

---@class DebugTheme
---@field title string
---@field prefix string | nil
---@field mid string | nil
---@field sep string | nil
---@field data table {title: string, value: string}
---@field theme table {title: string, prefix: string, mid: string, sep: string}
DebugTheme = class("Debug Theme")

---Initializes a new DebugTheme instance
---@return DebugTheme
function DebugTheme:init(data)
  if type(data) == "table" then self:setAll(data) return self end
  self.title = "Debug"
  self.prefix = "-- "
  self.mid = ": "
  self.sep = "\n"
  self.attrColor = "\033[0;36m"
  self.valueColor = "\033[0m"
  return self
end

function DebugTheme:set(key, value)
  self[key] = value
end

function DebugTheme:setAll(data)
  for k, v in pairs(data) do
    self:set(k, v)
  end
end

---@class DebugLine
---@field title string
---@field value string
DebugLine = class("DebugLine")

function DebugLine:init(title, value)
  self.title = title
  self.value = value
  return self
end

---@class DebugTable
---@field title string
---@field prefix string
---@field mid string
---@field sep string
---@field data table {title: string, value: string}
DebugTable = class("DebugTable")

---@alias DataPair {title: string, value: string}
---@alias ThemeConfig {title: string, prefix: string, mid: string, sep: string}
---@alias DebugTableInput {theme: DebugTheme, data: DataPair[]}

---Initializes a new DebugTable instance
---@param input DebugTableInput
---@return DebugTable
function DebugTable:init(input)
  local theme, data = input.theme, input.data
  local localTheme = theme or DebugTheme()
  self.title = localTheme.title
  self.prefix = localTheme.prefix
  self.mid = localTheme.mid
  self.sep = localTheme.sep
  self.attrColor = localTheme.attrColor
  self.valueColor = localTheme.valueColor
  self.data = self:setAll(data) or {}
  return self
end
function DebugTable:setAll(data)
  temp_data = {}
  for k, v in pairs(data) do
    table.insert(temp_data, DebugLine(k, v))
  end
  return temp_data
end

function DebugTable:prettySelf()
  local str = ""
  for _, v in pairs(self.data) do
    str = "${s}${p}${t}${m}${v}${s2}" % {s=str, p=self.prefix, t=v.title, v=v.value, m=self.mid, s2=self.sep}
  end
  return str
end

function DebugTable:debugPrint()
  dPrint(self.title, self:prettySelf())
end

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

function unixTimestamp()
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

function boolToStr(value)
  return value and "True" or "False"
end


function cleanStringTable(strings)
  local cleaned = {}
  for _, str in ipairs(strings) do
    str = str:gsub("\n", ", ")
    str = str:gsub("  ", "")
    table.insert(cleaned, str)
  end
  return table.concat(cleaned, " ")
end

function split(str, sep)
  return hs.fnutils.split(str, sep)
end


---Strips whitespace from the beginning and end of a string
---@param str string
---@return string, number
function strip(str) return str:gsub("^%s*(.-)%s*$", "%1") end


---@param str string
---@return string
function trimIndent(str)
  local rStr = ""
  local lines = split(str, "\n")
  for i, l in ipairs(lines) do
    rStr = "${r}${line}" % {r=rStr, line=strip(l)}
    if i ~= #lines then rStr = rStr .. "\n" end
  end
  return rStr
end

__setGlobals__({
  unixTimestamp = unixTimestamp,
  str = str,
  debugPrint = debugPrint,
  readFile = readFile,
  booltoStr = boolToStr,
  cleanStringTable = cleanStringTable,
  trimIndent = trimIndent,
  dPrint = dPrint,
  split = split,
  strip = strip,
  DebugTheme = DebugTheme,
  DebugTable = DebugTable
})
