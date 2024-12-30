require("globals")
print("-- Starting Loading the config at "..tostring(dt_now("time")))
require("classes.reload")():start()
with(Timer("Another operation"), function(t)
    require("_load")
    print("-- Time taken: "..t:format_elapsed())
end)

-- hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function(event)
--     local buttonNumber = event:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
--     hs.alert.show("Button number: "..buttonNumber)
--     local remote = "kai@192.168.50.154"
--     if buttonNumber == 1 then
--         -- Back button
        
--         hs.alert.show("Back button pressed")
--         return true
--     elseif buttonNumber == 2 then
--         -- Forward button
--         hs.execute("ssh ${r} 'xdotool key alt+Right'" % {r = remote})
--         hs.alert.show("Forward button pressed")
--         return true
--     end

--     return false
-- end):start()

print("-- Reached the end of the config at "..tostring(dt_now("time")))
hs.alert.show("Config loaded")
