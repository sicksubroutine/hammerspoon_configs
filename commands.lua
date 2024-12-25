
---@comment Params for registering a command
-- function Hyper:registerCommand(name, key, action, showInMenu, menuTitle)
--     self.commands[key] = {
--         name = name,
--         key = key,
--         action = action,
--         showInMenu = showInMenu or false,
--         menuTitle = menuTitle or name
--     }
-- end


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
        hs.application.launchOrFocus("Start")
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

hyper:updateMenubar()
