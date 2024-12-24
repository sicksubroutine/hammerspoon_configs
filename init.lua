require("_load")
if jSettings:get("connect", false) then
    local connect = require('classes.connection')(SettingsManager, DebugMode)
    connect:start()
    print("-- Connection Mode is on")
end
hs.alert.show("Config loaded")
local now = dt_now("time")
print("-- Reached the end of the config at "..tostring(now))

