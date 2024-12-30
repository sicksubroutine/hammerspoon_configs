--[[####### Connection Related ######]]--
if jSettings:get("connect", false) then
    require('classes.connection')():start()
    print("-- Connection Mode is on")
end
--[[#################################]]--
--[[####### Keyboard Related ########]]--
if jSettings:get("hyper", false) then
    local hyper = require("classes.hypermode")()
    if hyper then
        _G.hyper = hyper
        hs.alert.show("HyperMode Initialized")
        hs.hotkey.bind({}, "F17", function()
            hyper:toggleHyperMode()
        end)
        require("commands")
    else
        hs.alert.show("Failed to initialize Hyper Mode")
    end
else
    hs.hotkey.bind(HyperKey, "h", function()
        jSettings:set("hyper", not jSettings:get("hyper"))
        jSettings:write(true)
        local hyper = jSettings:get("hyper")
        if hyper then hs.alert.show("hyper Mode is on") else hs.alert.show("hyper Mode is off") end
        -- wait a second
        hs.timer.doAfter(1, function()
            hs.reload()
        end)
    end)
end
--[[#################################]]--
