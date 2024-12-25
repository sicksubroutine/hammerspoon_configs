hs.loadSpoon('EmmyLua')
require('hs.ipc')

--[[#################################]]--
--[[########### Logging #############]]--
---@diagnostic disable: lowercase-global, need-check-nil
logger = require("classes.logging"):getLogger("__hammerspoon", "debug")
local bPrint = print
_G.print = function(...)
    local args = {...}
    local message = table.concat(args, "\t")
    logger:info(message)
    bPrint(...)
end
--[[#################################]]--

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
debugPrint = function(...)end
readFile = function()end
--- Returns the current Unix timestamp
UnixTimestamp = function()end

--- Sets all keys in the table to global variables
---@class Globals
---@param t table<string, any>
function __setGlobals__(t)
    for key, value in pairs(t) do
        _G[key] = value
    end
end

_G.__setGlobals__ = __setGlobals__

require("classes.context_manager")
require("classes.pathlib")
require("helpers")
require("classes.json_help")
require("classes.dataclass")
require("classes.datetime")

jSettings = jsonI(Path("~/.hammerspoon/settings.json"), "jSettings")
jData = jSettings:getData() --{"connect": false, "hyper": true, "debug": false, "clear": true}
print(jSettings:pretty(", "))

local debug = jSettings:get("debug", false)
local settingsManager = require("classes.settings")

---@class SettingsManager
debugSettings = settingsManager("debugSettings", debug)

debugSettings:setAll({
    debug_mode = debug,
    LoggerFileName = "__hammerspoon.log",
    HammerspoonPath = os.getenv('HOME') .. '/.hammerspoon/'
})

__setGlobals__({
    jSettings = jSettings,
    jData = jData,
    debugSettings = debugSettings,
    HammerspoonPath = debugSettings:get("HammerspoonPath"),
    LoggerFileName = debugSettings:get("LoggerFileName"),
    DebugMode = debugSettings:get("debug_mode", false),
    HyperSymbol = "❖",
    RaycastName = "Raycast",
    HyperKey = {"cmd", "ctrl", "alt", "shift"},
    CmdAlt = {"cmd", "alt"}
})
