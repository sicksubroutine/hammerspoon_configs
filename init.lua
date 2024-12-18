---@diagnostic disable: lowercase-global
hs.loadSpoon('EmmyLua')
require('hs.ipc')
require("sugar")
require("global_constants")
Settings = require("settings") -- leaving it uninitialized so it can be created with different prefixes
local reload = require("reload")
reload():init():start()
hs.alert.show("Config loaded")
local logging = require("logging")
-- local logger = logging:getLogger("__hammerspoon", "debug")
-- ---@diagnostic disable: lowercase-global
-- _print = print
-- _G.print = function(...)
--     local args = {...}
--     local message = table.concat(args, "\t")
--     logger:info(message)
--     _print(...)
-- end

--[[#################################
#         Hammerspoon Init          #
#         System Bootstrap          #
##################################--]]

--[[#################################
#           Variables               #
#      Global Configuration         #
#################################--]]
package.path = package.path .. ";" .. HAMMERSPOON_PATH .."helpers/?.lua"
local hyper_key = {"cmd", "ctrl", "alt", "shift"}
--[[#################################
#         Module Loading            #
#     Dynamic Module Import         #
#################################--]]
local loaded_helpers = LoadAndCheck("helpers") if not loaded_helpers then return end
local hyperMode = loaded_helpers.hyper():init(DEBUG)
local connection_checker= require('connection')():init(Settings, DEBUG)
--[[#################################
#         Event Handlers            #
#           Hyper Mode              #
#################################--]]
if hyperMode:start_service() then
    print("-- Hyper Mode Initialized")
else
    hs.alert.show("Failed to initialize Hyper Mode")
end
--local hyperModeActive = hyperMode:getMode()
--[[#################################
#         Keybindings               #
#       Global Shortcuts            #
#################################--]]
hs.hotkey.bind({"cmd", "alt"}, "space", function() hs.application.launchOrFocus("Start") end)
hs.hotkey.bind(hyper_key, "space", function() hs.application.launchOrFocus(RAYCAST) end)
hs.hotkey.bind(hyper_key, "a", function() hyperMode:toggleHyperMode() end)
--[[#################################
#         Connection Handler        #
#        wifi or ethernet           #
#################################--]]
connection_checker:checkInterfaces()
connection_checker:start()
--[[#################################
#         Global Functions          #
#        Extra Functionality        #
#################################--]]

-- local my_list = list()

-- my_list.append("1")™