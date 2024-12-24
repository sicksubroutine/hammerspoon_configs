--[[#################################]]--
--[[##### Load Libraries ###########]]--
---@diagnostic disable: lowercase-global, need-check-nil
require("meta.globals")
require("classes.pathlib")
require("classes.lines")
require("classes.json_help")
logger = require("logging"):getLogger("__hammerspoon", "debug")
hs.loadSpoon('EmmyLua')
require('hs.ipc')
require("helpers")
require("classes.dataclass")
require("settings")
jSettings = jsonI(Path("~/.hammerspoon/settings.json"))
jData = jSettings:getData() --{"connect": "off", "hyper": "on", "debug": "off"}
---@type boolean
ConnectionMode = jData.connect and jData.connect == "on" or false -- true or false
---@type boolean
HyperMode = jData.hyper and jData.hyper == "on" or false -- true or false
---@type boolean
JDebugMode = jData.debug and jData.debug == "on" or false -- true or false

--logger = logging:getLogger("__hammerspoon", "debug")
local bPrint = print
_G.print = function(...)
    local args = {...}
    local message = table.concat(args, "\t")
    logger:info(message)
    bPrint(...)
end
dt = require("classes.datetime")
__setGlobals__(require("global_constants"))
--[[#################################]]--
--[[##### Keyboard Related ##########]]--
hs.hotkey.bind(CmdAlt, "space", function() hs.application.launchOrFocus("Start") end)
if HyperMode then
    local hyper = require("classes.hypermode")():init()
    if hyper then
        _G.hyper = hyper
        hs.alert.show("HyperMode Initialized")
        hs.hotkey.bind({}, "F17", function()
            hyper:toggleHyperMode()
        end)
        hs.hotkey.bind(HyperKey, "space", function() hs.application.launchOrFocus(RaycastName) end)
        hs.hotkey.bind(HyperKey, "a", function() hyper:toggleHyperMode() end)
        require("commands")
    else
        hs.alert.show("Failed to initialize Hyper Mode")
    end
end
print("-- Connection Mode is [[".. str(ConnectionMode and "on" or "off") .."]]")
print("-- Debug Mode is [[".. str(JDebugMode and "on" or "off") .."]]")
print("-- Hyper Mode is [[".. str(HyperMode and "on" or "off") .."]]")
--[[#################################]]--

__setGlobals__({
    ConnectionMode = ConnectionMode,
    HyperMode = HyperMode,
    JDebugMode = JDebugMode,
    jSettings = jSettings,
    jData = jData,
})
