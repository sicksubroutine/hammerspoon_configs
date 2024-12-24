require("_load")
local connect = require('classes.connection')()
if jSettings:get("connect", false) then
    print("-- Connection Mode is on")
    connect:init(SettingsManager, DebugMode)
    connect:start()
end
hs.alert.show("Config loaded")
local now = dt_now("time")
print("-- Reached the end of the config at "..tostring(now))

