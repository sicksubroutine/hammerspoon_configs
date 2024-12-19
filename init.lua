require("_load")
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

