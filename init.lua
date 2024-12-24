require("classes.context_manager")
with(Timer("Another operation"), function(t)
    require("meta.globals")
    require("helpers")
    require("settings")
    require("_load")
    if jSettings:get("connect", false) then
        require('classes.connection')(SettingsManager, DebugMode):start()
        print("-- Connection Mode is on")
    end
    print("-- Time taken: "..t:format_elapsed())
    print("-- Reached the end of the config at "..tostring(dt_now("time")))
    hs.alert.show("Config loaded")
end)

