require("globals")
local _print = function(text) print("-- [init] " .. text) end
local dt = DateTime.now()
_print("Starting Loading the config at ${d}" % {d = str(dt:strftime(timeOnlyFormat))} )

with(Timer("Another operation"), function(t)
    local reload = require("classes.reload")
    local hsPath = Path(hs.configdir)
    local reloadInstance = reload(hsPath)
    reloadInstance:start()

    if jSettings:get("vnc", false) then
        local docker_handler = require("classes.dock_handler")
    
        local dockHandler = docker_handler({"VNC Viewer"}, 0.0001, 1000, 5)
        dockHandler:start()
    end
    require("_load")
    _print("Time taken: "..t:format_elapsed())
end)

dt:updateNow()
_print("Reached the end of the config at ${d}" % {d = str(dt:strftime(timeOnlyFormat))} )
hs.alert.show("Config loaded")
