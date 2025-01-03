local dataclasses = require("classes.dataclasses.dataclass")
local field = dataclasses.field
local dataclass = dataclasses.dataclass

---@class Command: Dataclass
---@field name string
---@field key string
---@field action function
---@field showInMenu boolean
---@field menuTitle string
local Command = dataclass("Command", {
        name = field "string" {required = true},
        key = field "string" {required = true},
        action = field "function" {required = false, hidden = true},
        showInMenu = field "boolean" {required = false, default = false},
        menuTitle = field "string" {required = false, default = nil}
    },
    {order=true}
)

function Command:__post_init()
    if self.showInMenu then
        self.menuTitle = self.menuTitle or self.name
    end
    --hyper:registerCommand(self)
end

local toggleHyperMode = Command({
    name = "Toggle Hyper Mode",
    key = "a",
    action = function() hyper:toggleHyperMode() end,
    showInMenu = true,
    menuTitle = "❖ + A: Toggle Hyper Mode"
})

--TODO: Get around to adding all commands as a Command object
-- Still need to convert the registerCommand function to use the Command object
-- then Bob's your uncled

hyper:registerCommand(
    "Toggle Hyper Mode",
    "a",
    function() hyper:toggleHyperMode() end,
    true,
    "❖ + A: Toggle Hyper Mode"
)

hyper:registerCommand(
    "Reload Configuration",
    "r",
    function() hs.reload() end,
    true,
    "❖ + R: Reload Configuration"
)

hyper:registerCommand(
    "Rebuild NixOS",
    "n",
    function() 
        hs.alert.show("Rebuilding Nix Darwin Configuration, please standby...")
        local cmd = "darwin-rebuild switch --flake ~/.config/nix/#pluto"
        hs.timer.doAfter(1, function()
            local output, _, _ = hs.execute(cmd, true)
            logger:debug("Debug output for Nix Rebuild"..output)
        end)
    end,
    true,
    "❖ + N: Rebuild NixOS Configuration"
)

hyper:registerCommand(
    "Launch Raycast",
    "space",
    function()
        hs.application.launchOrFocus(RaycastName)
        hyper.setMode(false)
    end,
    true,
    "❖ + Space: Launch Raycast"
)

hyper:registerCommand(
    "Debug Mode Toggle",
    "d",
    function()
        jSettings:set("debug", not jSettings:get("debug"))
        jSettings:write(true)
        local debug = jSettings:get("debug")
        if debug then hs.alert.show("Debug Mode is on") else hs.alert.show("Debug Mode is off") end
        -- wait a second
        hs.timer.doAfter(1, function()
            hs.reload()
        end)
    end,
    true,
    "❖ + D: Toggle Debug Mode"
)

hyper:registerCommand(
    "Hyper Mode Toggle", -- Disable Hyper Mode For Now
    "h",
    function()
        jSettings:set("hyper", not jSettings:get("hyper"))
        jSettings:write(true)
        local hyper = jSettings:get("hyper")
        if hyper then hs.alert.show("hyper Mode is on") else hs.alert.show("hyper Mode is off") end
        -- wait a second
        hs.timer.doAfter(1, function()
            hs.reload()
        end)
    end,
    true,
    "❖ + D: Toggle Debug Mode"
)


hyper:registerCommand(
    "Clear Log",
    "c",
    function()
        logger:clear()
        hs.alert.show("Log Cleared")
        hs.timer.doAfter(1, function()
            hs.reload()
        end)
    end,
    true,
    "❖ + C: Clear Log"
)

hyper:registerCommand(
    "Sketchybar Restart",
    "z",
    function()
        hs.alert.show("Restart Sketchybar")
        hs.execute("brew services restart sketchybar", true) 
    end,
    true,
    "❖ + S: Restart Sketchybar"
)

hyper:updateMenubar()
