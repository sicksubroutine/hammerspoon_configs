---@diagnostic disable: lowercase-global
HammerspoonPath = ""
LoggerFileName = ""
DebugMode = false
HyperSymbol = ""
RaycastName = ""
HyperKey = {}

--- Sets all keys in the table to global variables
---@class Globals
---@field debug_mode boolean
---@field LoggerFileName string
---@field HammerspoonPath string
---@param t table<string, any>
function __globals__(t)
    for key, value in pairs(t) do
        _G[key] = value
    end
end
