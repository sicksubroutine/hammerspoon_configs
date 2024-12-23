---@diagnostic disable: lowercase-global
function debugPrint(...)
    if DebugMode then print(...) end
end

local function interp(s, tab)
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

getmetatable("").__mod = interp -- probably not using this anyway lol

function UnixTimestamp()
  return os.time()
end

function HumanTimestamp(option)
  -- date, time, both
  -- if nothing is passed, return both
  if option == "date" then
    return os.date("%m-%d-%Y")
  elseif option == "time" then
    return os.date("%I:%M:%S %p")
  else
    return os.date("%m-%d-%Y %I:%M:%S %p")
  end
end

function Str(v)
  return type(v) == "table" and hs.inspect.inspect(v) or tostring(v)
end

__setGlobals__({
  UnixTimestamp = UnixTimestamp,
  HumanTimestamp = HumanTimestamp,
  str = Str,
  debugPrint = debugPrint
})
