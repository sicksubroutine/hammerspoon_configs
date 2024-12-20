---@diagnostic disable: lowercase-global
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
require("dataclass")
require("settings")
require("global_constants")
require("logging")
--[[#################################]]--
local hyper = require("hypermode")():init()
if hyper then
    hs.alert.show("HyperMode Initialized")
    hs.hotkey.bind({}, "F17", function()
        hyper:toggleHyperMode()
    end)
else
    hs.alert.show("Failed to initialize Hyper Mode")
end
--[[#################################
#         Keybindings               #
#       Global Shortcuts            #
#################################--]]
hs.hotkey.bind({"cmd", "alt"}, "space", function() hs.application.launchOrFocus("Start") end)
hs.hotkey.bind(HyperKey, "space", function() hs.application.launchOrFocus(RaycastName) end)
hs.hotkey.bind(HyperKey, "a", function() hyper:toggleHyperMode() end)
