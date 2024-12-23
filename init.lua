require("_load")
local reload = require("reload")()
if reload:init() then reload:start() end
local connect = require('classes.connection')()
connect:init(SettingsManager, DebugMode)
connect:start()

hs.alert.show("Config loaded")
local now = HumanTimestamp("time")
print("-- Reached the end of the config at "..tostring(now))
