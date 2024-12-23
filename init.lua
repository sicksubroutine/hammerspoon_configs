require("_load")
local reload = require("reload")():init()
if reload then reload:start() end
local connect = require('connection')():init(SettingsManager, DebugMode)
connect:checkInterfaces()
connect:start()

hs.alert.show("Config loaded")
print("Reached the end of the config...")
