require("_load")
if Reload then Reload():init():start() hs.alert.show("Config loaded") end
local connect = require('connection')():init(Settings, DEBUG)
connect:checkInterfaces()
connect:start()

local logging = require("logging")



-- logger = logging:getLogger("__hammerspoon", "debug")
-- ---@diagnostic disable: lowercase-global
-- backup_print = print
-- _G.print = function(...)
--     local args = {...}
--     local message = table.concat(args, "\t")
--     logger:info(message)
--     backup_print(...)
-- end

