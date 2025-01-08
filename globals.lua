---@diagnostic disable: lowercase-global, need-check-nil
DebugMode = false
HammerspoonPath = ""
LoggerFileName = ""
HyperSymbol = ""
RaycastName = ""
HyperKey = {}
CmdAlt = {}

--- Sets all keys in the table to global variables
---@class Globals
---@param t table<string, any>
function __setGlobals__(t)
    for key, value in pairs(t) do
        _G[key] = value
    end
end

_G.__setGlobals__ = __setGlobals__

--[[#################################]]--
--[[########### Logging #############]]--
logger = require("classes.logging"):getLogger("__hammerspoon", "debug")
hs.loadSpoon('EmmyLua')
require('hs.ipc')
require("classes.context_manager")
require("classes.pathlib")
require("helpers")
require("classes.json_help")
require("classes.datetime")
bPrint = print
_G.printf = hs.printf
_G.print = function(...)
    local args = {...}

    for _, v in ipairs(args) do
        if type(v) == "table" and v.class and v.class._className then
            bPrint(...)
            return
        end
    end

    local msg = table.concat(args, "\t")
    
    logger[string.match(msg:lower(), "error") and "error" or "info"](logger, msg)
    if not string.match(msg, "%[.*%]") then
        msg = msg:gsub("^%s*-+%s*", ""):gsub("%s*-+%s*$", "")
        msg = "-- [hs] " .. msg
    end
    msg = msg:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    bPrint(msg)
end
--[[#################################]]--

jSettings = jsonI(Path("~/.hammerspoon/settings.json"), "jSettings")
jData = jSettings:getData() --{"connect": false, "hyper": true, "debug": false, "clear": true, "vnc": false}
logger:debug(jSettings:pretty(", "))

local debug = jSettings:get("debug", false)
local settingsManager = require("classes.settings")

---@class SettingsManager
debugSettings = settingsManager("debugSettings", debug)

debugSettings:setAll({
    debug_mode = debug,
    LoggerFileName = "__hammerspoon.log",
    HammerspoonPath = os.getenv('HOME') .. '/.hammerspoon/'
})

fullDateFormat = "%m-%d-%Y %I:%M:%S %p"
dateOnlyFormat = "%m-%d-%Y"
timeOnlyFormat = "%I:%M:%S %p"

---@class Globals
---@field jSettings table
---@field jData table
---@field debugSettings SettingsManager
---@field HammerspoonPath string
---@field LoggerFileName string
---@field DebugMode boolean
---@field HyperSymbol string
---@field RaycastName string
---@field HyperKey string[]
---@field CmdAlt string[]
---@field fullDateFormat string
---@field dateOnlyFormat string
---@field timeOnlyFormat string
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
    CmdAlt = {"cmd", "alt"},
    fullDateFormat = fullDateFormat,
    dateOnlyFormat = dateOnlyFormat,
    timeOnlyFormat = timeOnlyFormat
})
