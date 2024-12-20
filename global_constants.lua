---@diagnostic disable: lowercase-global
local debug_mode = false

require("meta.metaGlobals")
---@class SettingsManager
debugSettings = SettingsManager():init("debugSettings", debug_mode)

debugSettings:setAll({
    debug_mode = debug_mode,
    LoggerFileName = "__hammerspoon.log",
    HammerspoonPath = os.getenv('HOME') .. '/.hammerspoon/'
})

__globals__({
    debugSettings = debugSettings,
    HammerspoonPath = debugSettings:get("HammerspoonPath"),
    LoggerFileName = debugSettings:get("LoggerFileName"),
    DebugMode = debugSettings:get("debug_mode", false),
    HyperSymbol = "❖",
    RaycastName = "Raycast",
    HyperKey = {"cmd", "ctrl", "alt", "shift"}
})
