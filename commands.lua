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

hyper:updateMenubar()
