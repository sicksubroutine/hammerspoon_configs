---@class SettingsManager
debugSettings = SettingsManager():init("debugSettings", JDebugMode)

debugSettings:setAll({
    debug_mode = JDebugMode,
    LoggerFileName = "__hammerspoon.log",
    HammerspoonPath = os.getenv('HOME') .. '/.hammerspoon/'
})

return {
    debugSettings = debugSettings,
    HammerspoonPath = debugSettings:get("HammerspoonPath"),
    LoggerFileName = debugSettings:get("LoggerFileName"),
    DebugMode = debugSettings:get("debug_mode", false),
    HyperSymbol = "❖",
    RaycastName = "Raycast",
    HyperKey = {"cmd", "ctrl", "alt", "shift"},
    CmdAlt = {"cmd", "alt"}
}
