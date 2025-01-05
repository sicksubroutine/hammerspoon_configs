hs.console.consoleFont({name="JetBrainsMono Nerd Font", size=15})
hs.consoleOnTop(true)
if hs.console.darkMode() then
    hs.console.outputBackgroundColor{ white = 0 }
    hs.console.consoleCommandColor{ white = 1 }
    hs.console.alpha(1)
end

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
