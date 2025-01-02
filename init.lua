require("globals")

local dt = DateTime.now()

print("-- Starting Loading the config at ${d}" % {d = str(dt:strftime(timeOnlyFormat))} )
require("classes.reload")():start()
with(Timer("Another operation"), function(t)
    require("_load")
    print("-- Time taken: "..t:format_elapsed())
end)

dt:updateNow()
print("-- Reached the end of the config at ${d}" % {d = str(dt:strftime(timeOnlyFormat))} )
hs.alert.show("Config loaded")

local config = hs.network.configuration.open()
---@type 
config:setCallback(function(store, keys)
    -- Your code here to handle network changes
    print("Network configuration changed for keys:", hs.inspect(keys))
end)
config:monitorKeys({ "State:/Network/Interface" })
config:start()