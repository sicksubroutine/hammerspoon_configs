---@diagnostic disable: lowercase-global
local debugClasses = require("classes.debughelper")

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

function unixTimestamp() return os.time() end

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

function DebugModeToggle()
  jSettings:set("debug", not jSettings:get("debug"))
  jSettings:write(true)
  local debug = jSettings:get("debug")
  if debug then hs.alert.show("Debug Mode is on") else hs.alert.show("Debug Mode is off") end
  -- wait a second
  hs.timer.doAfter(1, function()
      hs.reload()
  end)
end


__setGlobals__({
  unixTimestamp = unixTimestamp,
  str = str,
  debugPrint = dPrint,
  DebugModeToggle = DebugModeToggle,
  readFile = readFile,
  booltoStr = boolToStr,
  cleanStringTable = cleanStringTable,
  trimIndent = trimIndent,
  dPrint = dPrint,
  split = split,
  strip = strip,
  DebugTheme = debugClasses.DebugTheme,
  DebugTable = debugClasses.DebugTable,
})
