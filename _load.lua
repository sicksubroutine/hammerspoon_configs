---@diagnostic disable: lowercase-global, need-check-nil
require("meta.globals")
require("classes.pathlib")
require("classes.lines")
require("classes.json_help")
local logging = require("logging")
jSettings = json(Path():init("~/.hammerspoon/settings.json")) --{"connect": "off", "hyper": "on", "debug": "off"}
---@type string
ConnectionMode = jSettings.connect -- "on" or "off"
---@type string
HyperMode = jSettings.hyper -- "on" or "off"
---@type boolean
JDebugMode = jSettings.debug == "on" -- true or false
logger = logging:getLogger("__hammerspoon", "debug")
local bPrint = print
_G.print = function(...)
    local args = {...}
    local message = table.concat(args, "\t")
    logger:info(message)
    bPrint(...)
end
--[[#################################]]--
hs.loadSpoon('EmmyLua')
require('hs.ipc')
require("helpers")
require("classes.dataclass")
require("settings")
dt = require("classes.datetime")
__setGlobals__(require("global_constants"))
--[[#################################]]--
if HyperMode == "on" then
    local hyper = require("classes.hypermode")():init()
    if hyper then
        hs.alert.show("HyperMode Initialized")
        hs.hotkey.bind({}, "F17", function()
            hyper:toggleHyperMode()
        end)
    else
        hs.alert.show("Failed to initialize Hyper Mode")
    end
    _G.hyper = hyper
end
require("commands")
--[[#################################]]--
hs.hotkey.bind(CmdAlt, "space", function() hs.application.launchOrFocus("Start") end)
hs.hotkey.bind(HyperKey, "space", function() hs.application.launchOrFocus(RaycastName) end)
hs.hotkey.bind(HyperKey, "a", function() hyper:toggleHyperMode() end)
