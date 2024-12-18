hs.loadSpoon('EmmyLua')
require('hs.ipc')
require("sugar")
require("global_constants")
Settings = require("settings") -- leaving it uninitialized so it can be created with different prefixes
Reload = require("reload")
HyperMode = require('hypermode')
Hyper = HyperMode():init(DEBUG):startService()
if Hyper then print("-- Hyper Mode Initialized") else hs.alert.show("Failed to initialize Hyper Mode") end
--[[#################################
#         Keybindings               #
#       Global Shortcuts            #
#################################--]]
hs.hotkey.bind({"cmd", "alt"}, "space", function() hs.application.launchOrFocus("Start") end)
hs.hotkey.bind(HYPERKEY, "space", function() hs.application.launchOrFocus(RAYCAST) end)
hs.hotkey.bind(HYPERKEY, "a", function() Hyper:toggleHyperMode() end)

_G.Settings = Settings
_G.Reload = Reload
_G.HyperMode = HyperMode
