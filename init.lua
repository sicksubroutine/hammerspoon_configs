require("_load")
local reload = require("reload")
if reload then reload():init():start() end
local connect = require('connection')():init(SettingsManager, DebugMode)
connect:checkInterfaces()
connect:start()

hs.alert.show("Config loaded")
print("Reached the end of the config...")
