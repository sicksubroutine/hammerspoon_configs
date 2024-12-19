--[[#################################]]--
hs.loadSpoon('EmmyLua')
require('hs.ipc')
require("sugar")
require("global_constants")
--[[#################################]]--
Settings = require("settings") -- leaving it uninitialized so it can be created with different prefixes
local reload = require("reload")
local hypermode = require('hypermode')
if reload then reload():init():start() hs.alert.show("Config loaded") end
hyper = hypermode():init(DEBUG)
if hyper then hs.alert.show("HyperMode Initialized") else hs.alert.show("Failed to initialize Hyper Mode") end
hs.hotkey.bind(HYPERKEY, "a", function() hyper:toggleHyperMode() end)

--[[#################################
#         Keybindings               #
#       Global Shortcuts            #
#################################--]]
hs.hotkey.bind({"cmd", "alt"}, "space", function() hs.application.launchOrFocus("Start") end)
hs.hotkey.bind(HYPERKEY, "space", function() hs.application.launchOrFocus(RAYCAST) end)

_G.Settings = Settings
_G.Reload = Reload
_G.HyperMode = HyperMode
