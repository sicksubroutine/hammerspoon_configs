--[[#################################]]--
--[[##### Load Libraries ###########]]--
---@diagnostic disable: lowercase-global, need-check-nil
require("meta.globals")
require("classes.data_structures.dictionary")
require("helpers")
require("classes.lines")
require("classes.pathlib")
require("classes.lines")
require("classes.json_help")
jSettings = jsonI(Path("~/.hammerspoon/settings.json"), "jSettings")
jData = jSettings:getData() --{"connect": false, "hyper": true, "debug": false, "clear": true}
-- print(
--     "-- jSettings:"..
--     " Debug:".. jSettings:getStr("debug", "false")..
--     ", Hyper:".. jSettings:getStr("hyper", "false")..
--     ", Connect:".. jSettings:getStr("connect", "false")..
--     ", Clear:".. jSettings:getStr("clear", "false")
-- )
print(jSettings:pretty(", "))
__setGlobals__({jSettings = jSettings, jData = jData})
logger = require("logging"):getLogger("__hammerspoon", "debug")
local bPrint = print
_G.print = function(...)
    local args = {...}
    local message = table.concat(args, "\t")
    logger:info(message)
    bPrint(...)
end
hs.loadSpoon('EmmyLua')
require('hs.ipc')
--require("classes.dataclass")
require("settings")
local reload = require("reload")()
if reload then reload:start() end
require("classes.datetime")
__setGlobals__(require("global_constants"))
--[[#################################]]--
--[[##### Keyboard Related ##########]]--
hs.hotkey.bind(CmdAlt, "space", function() hs.application.launchOrFocus("Start") end)
if jSettings:get("hyper", false) then
    local hyper = require("classes.hypermode")()
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
--[[#################################]]--
