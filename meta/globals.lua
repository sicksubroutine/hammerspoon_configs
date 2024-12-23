---@diagnostic disable: lowercase-global
DebugMode = false
HammerspoonPath = ""
LoggerFileName = ""
HyperSymbol = ""
RaycastName = ""
HyperKey = {}
CmdAlt = {}

-- Global Function Stubs for type checking
str = function(string)end
debugPrint = function(string)end
readFile = function()end
UnixTimestamp = function()end
humanTimestamp = function(time)end

--- Sets all keys in the table to global variables
---@class Globals
---@param t table<string, any>
function __setGlobals__(t)
    for key, value in pairs(t) do
        _G[key] = value
    end
end
