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
        menuTitle = field "string" {required = false, default = nil},
        disabled = field "boolean" {required = false, default = false}
    },
    {order=true}
)

function Command:__post_init()
    if self.showInMenu then
        self.menuTitle = self.menuTitle or self.name
    end
    hyper:registerCommand(self)
end

Command({
    name = "Toggle Hyper Mode",
    key = "a",
    action = function() hyper:toggleHyperMode() end,    
    showInMenu = true,
    menuTitle = "❖ + A: Toggle Hyper Mode",
    disabled = true
})

Command({
    name = "Reload Configuration",
    key = "r",
    action = function() hs.reload() end,
    showInMenu = true,
    menuTitle = "❖ + R: Reload Configuration"
})

Command({
    name = "Rebuild NixOS",
    key = "n",
    action = function()
        hs.alert.show("Rebuilding Nix Darwin Configuration, please standby...")
        local cmd = "darwin-rebuild switch --flake ~/.config/nix/#pluto"
        hs.timer.doAfter(1, function()
            local output, _, _ = hs.execute(cmd, true)
            logger:debug("Debug output for Nix Rebuild"..output)
        end)
    end,
    showInMenu = true,
    menuTitle = "❖ + N: Rebuild NixOS Configuration"
})

Command({
    name = "Launch Raycast",
    key = "space",
    action = function() hs.application.launchOrFocus(RaycastName) end,
    showInMenu = true,
    menuTitle = "❖ + Space: Launch Raycast"
})

Command({
    name = "Launch iTerm",
    key = "t",
    action = function() hs.application.launchOrFocus("iTerm") end,
    showInMenu = true,
    menuTitle = "❖ + T: Launch iTerm"
})

Command({
    name = "Debug Mode Toggle",
    key = "d",
    action = function()
        jSettings:set("debug", not jSettings:get("debug"))
        jSettings:write(true)
        local debug = jSettings:get("debug")
        if debug then hs.alert.show("Debug Mode is on") else hs.alert.show("Debug Mode is off") end
        -- wait a second
        hs.timer.doAfter(1, function()
            hs.reload()
        end)
    end,
    showInMenu = true,
    menuTitle = "❖ + D: Toggle Debug Mode"
})

Command({
    name = "Clear Log",
    key = "c",
    action = function()
        logger:clear()
        hs.alert.show("Log Cleared")
        hs.timer.doAfter(1, function()
            hs.reload()
        end)
    end,
    showInMenu = true,
    menuTitle = "❖ + C: Clear Log"
})

Command({
    name = "Restart Sketchybar",
    key = "z",
    action = function()
        hs.alert.show("Restart Sketchybar")
        hs.execute("sketchybar --reload", true) 
    end,
    showInMenu = true,
    menuTitle = "❖ + S: Restart Sketchybar"
})

hyper:updateMenubar()
