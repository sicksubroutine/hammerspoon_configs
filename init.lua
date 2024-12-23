require("_load")
local reload = require("reload")()
if reload:init() then reload:start() end
local connect = require('classes.connection')()
if ConnectionMode == "on" then
    connect:init(SettingsManager, DebugMode)
    connect:start()
end
hs.alert.show("Config loaded")
local now = humanTimestamp("time")
print("-- Reached the end of the config at "..tostring(now))
