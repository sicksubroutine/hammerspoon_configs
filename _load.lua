---@diagnostic disable: lowercase-global
require("meta.metaGlobals")
local logging = require("logging")
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
require("sugar")
require("classes.dataclass")
require("settings")

__setGlobals__(require("global_constants"))
require("logging")
--[[#################################]]--
local hyper = require("classes.hypermode")():init()
if hyper then
    hs.alert.show("HyperMode Initialized")
    hs.hotkey.bind({}, "F17", function()
        hyper:toggleHyperMode()
    end)
else
    hs.alert.show("Failed to initialize Hyper Mode")
end
--[[#################################]]--
hs.hotkey.bind(CmdAlt, "space", function() hs.application.launchOrFocus("Start") end)
hs.hotkey.bind(HyperKey, "space", function() hs.application.launchOrFocus(RaycastName) end)
hs.hotkey.bind(HyperKey, "a", function() hyper:toggleHyperMode() end)
