--[[#################################]]--
--[[##### Load Libraries ###########]]--
---@diagnostic disable: lowercase-global, need-check-nil
GetDataStructure = require("classes.data_structures._init")
require("classes.lines")
require("classes.pathlib")
require("classes.lines")
require("classes.json_help")
jSettings = jsonI(Path("~/.hammerspoon/settings.json"), "jSettings")
jData = jSettings:getData() --{"connect": false, "hyper": true, "debug": false, "clear": true}
print(jSettings:pretty(", "))
__setGlobals__({jSettings = jSettings, jData = jData})
__setGlobals__(require("global_constants"))
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
require("classes.dataclass")

local reload = require("reload")()
if reload then reload:start() end
require("classes.datetime")
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
