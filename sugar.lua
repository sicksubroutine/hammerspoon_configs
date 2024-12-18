---@diagnostic disable-next-line: lowercase-global
function interp(s, tab)
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

getmetatable("").__mod = interp

function LoadAndCheck(moduleName)
    local ok, module = pcall(function() return require(moduleName) end)
    if not ok then print("Failed to load module:", moduleName, "Error:", module) hs.alert.show("Failed to load module: " .. moduleName) return nil end
    if type(module) ~= "table" then print("Module "..moduleName.." loaded but returned unexpected type:", type(module)) return nil end
    print("Module loaded successfully:", moduleName)
    return module 
end
