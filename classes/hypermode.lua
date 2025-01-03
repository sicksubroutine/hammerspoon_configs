---@diagnostic disable: undefined-field, need-check-nil
---@alias Optional nil

local class = require('classes.class')
---@class Hyper
---@field hyperModeActive boolean
---@field commands table
---@field vncMode boolean
---@field keyDownTracker hs.eventtap
---@field menubarItem hs.menubar | Optional
local Hyper = class({ name = "Hyper" })

---@class HyperCommand
---@field name string
---@field key string
---@field action function
---@field showInMenu boolean
---@field menuTitle string|nil

--- comment Initialized the Hyper class
--- @return Hyper | Optional
function Hyper:init()
    self.hyperModeActive = false
    self.commands = {}
    self.vncMode = false
    self.keyDownTracker = self:returnKeyDownTracker()
    self.keyUpTracker = self:returnKeyUpTracker()
    --self.mouseButtonTracker = self:returnMouseButtonDownTracker()
    self.vncWatcher = self:vncModeCheck() -- Check if VNC Viewer is in focus
    self.menubarItem = hs.menubar.new()
    if not self.menubarItem then
        hs.alert.show("Failed to create menubar item")
        return nil
    end
    self:onInit()
    print("-- HyperMode Initialized")
    return self
end

function Hyper:onInit()
    self:updateMenubar()
    self.vncWatcher:start()
    self.keyDownTracker:start()
    self.keyUpTracker:start()
    --self.mouseButtonTracker:start()
end


function Hyper:registerCommand(name, key, action, showInMenu, menuTitle)
    self.commands[key] = {
        name = name,
        key = key,
        action = action,
        showInMenu = showInMenu or false,
        menuTitle = menuTitle or name
    }
end


---Registers Command Object for Various Hyper Mode Commands
-- function Hyper:registerCommand(cmd)
--     self.commands[cmd.key] = {
--         cmd.name = cmd.name,
--         key = key,
--         action = action,
--         showInMenu = showInMenu or false,
--         menuTitle = menuTitle or name
--     }
-- end



--- comment Returns the event tap for the Hyper Mode
---@return hs.eventtap
function Hyper:returnKeyDownTracker()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        return self:handleKeyEvent(event, "Key Down")
    end)
    return tap
end

function Hyper:returnKeyUpTracker()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(event)
        return self:handleKeyEvent(event, "Key Up")
    end)
    return tap
end

function Hyper:returnMouseButtonDownTracker()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
        local buttonNumber = event:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
        return self:handleMouseEvent(event, buttonNumber)
    end)
    return tap
end


---Check if VNC Viewer is running and set the vncMode to true
---@return hs.application.watcher | nil
function Hyper:vncModeCheck()
    local vncWatcher = hs.application.watcher.new(function(name, event, app)
        if name == "VNC Viewer" then
            if event == hs.application.watcher.activated then
                self.vncMode = true
                self:updateMenubar()
            elseif event == hs.application.watcher.deactivated then
                self.vncMode = false
                self:updateMenubar()
            end
        end
    end)
    if vncWatcher then
        return vncWatcher
    end
    return nil
end

--- comment Returns the current mode of the Hyper Mode
---@return boolean
function Hyper:getMode()
    return self.hyperModeActive
end

---comment Sets the mode of the Hyper Mode
---@param value boolean
function Hyper:setMode(value)
    if value == false then
        self.hyperModeActive = false
    else
        self.hyperModeActive = true
    end
    self:updateMenubar()
end

function Hyper:toggleHyperMode()
    self.hyperModeActive = not self.hyperModeActive
    if self.hyperModeActive then
        hs.alert.show("Hyper Mode Activated")
    else
        hs.alert.show("Hyper Mode Deactivated")
    end
    self:updateMenubar()
end


---comment Creates the menubar for the Hyper Mode
---@return table
function Hyper:createMenu()
    local menu = {
        {
            title = "Status: " .. (self.hyperModeActive and "Hyper Mode Active 🔴" or "Hyper Mode Inactive ⚪"),
            fn = function() self:toggleHyperMode() end
        },
        { title = "-" },
        {
            title = "Available Commands:",
            disabled = true
        }
    }
    for _, command in pairs(self.commands) do
        if command.showInMenu then
            table.insert(menu, {
                title = command.menuTitle,
                fn = command.action
            })
        end
    end
    
    return menu
end

---comment Updates the menubar for the Hyper Mode
function Hyper:updateMenubar()
    if self.menubarItem then
        if self.vncMode then
            self.menubarItem:setTitle("🟢") -- Green dot for VNC
        elseif self.hyperModeActive then
            self.menubarItem:setTitle("🔴") -- red dot for active
        else
            self.menubarItem:setTitle("⚪") -- White dot for inactive
        end
    end
    self.menubarItem:setMenu(self:createMenu())
end

--- Compares the flags to the pattern
---@param pattern table | nil
---@param flags table
---@return boolean
local function compFlags(pattern, flags)
    if pattern == nil then
        return false
    end
    for i, v in ipairs(flags) do
        if not pattern[v] then
            return false
        end
    end
    return true
end

---comment String comparison for hyper key checks
---@param key string
---@return boolean
function Hyper:hyperKeyChecks(key)
    if key == "a" then
        self:toggleHyperMode()
        return true
    elseif key == "r" then
        hs.reload()
        return true
    elseif key == "n" then
        hs.alert.show("Rebuilding Nix Darwin Configuration, please standby...")
        --hs.execute("open ~/.hammerspoon/__hammerspoon.log")
        local cmd = "darwin-rebuild switch --flake ~/.config/nix/#pluto"
        hs.timer.doAfter(1, function()
            local output, _, _ = hs.execute(cmd, true)
            logger:debug("Debug output for Nix Rebuild"..output)
        end)
        return true
    elseif key == "s" then
        hs.timer.doAfter(0.1, function()
            local output, _, _ = hs.execute("sketchybar --reload", true)
        end)
        return true
    end
    return false
end

--- Handles key events for when the hyper mode is active
---@param keyPressed number | string
---@return boolean
function Hyper:whileHyperModeActive(keyPressed)
    debugPrint("Processing active hyper mode key: " .. tostring(keyPressed))
    if keyPressed == "a" then
        hs.alert.show("Hyper A")
        return true
    elseif keyPressed == "r" then
        hs.reload()
        return true
    elseif keyPressed == "k" then
        print("Killing Hammerspoon")
        hs.alert.show("Killing Hammerspoon")
        hs.execute("killall Hammerspoon")
        return true
    elseif keyPressed == "space" then
        print("Launching Raycast")
        hs.application.launchOrFocus(RaycastName)
        self:toggleHyperMode()
        return true
    end
    return false
end

function Hyper:ignoreKeys()
    return false
end

function Hyper:handleMouseEvent(event, buttonNumber)
    hs.alert.show("Mouse Button: " .. tostring(buttonNumber))
    return false
end

function Hyper:handleKeyUpEvent(event, key)
    hs.alert.show("Key Up Event: " .. key)
    return false
end


---comment Handles the key events for fun and profit
---@param event hs.eventtap.event
---@param eventType string
---@return boolean
function Hyper:handleKeyEvent(event, eventType)
    ---@type string
    local keyPressed = hs.keycodes.map[event:getKeyCode()]
    local keyDown = eventType == "Key Down"
    local keyUp = eventType == "Key Up"
    local flags = event:getFlags()
    local ctrl, cmd, alt, shift = flags["ctrl"], flags["cmd"], flags["alt"], flags["shift"]
    local hyperKey = compFlags(flags, {"cmd", "alt", "ctrl", "shift"})
    --local disableAll = true
    local disableAll = false


    if DebugMode and not disableAll then
        local dTable = DebugTable({
        theme = DebugTheme({
            title = "Key Events",
            prefix = "-- ",
            mid = ": ",
            sep = "\n"
        }),
        data = {
            Event = eventType,
            Key = keyPressed,
            Ctrl = boolToStr(ctrl),
            Cmd = boolToStr(cmd),
            Alt = boolToStr(alt),
            Shift = boolToStr(shift),
            HyperKey = boolToStr(hyperKey),
            HyperMode = boolToStr(self.hyperModeActive)
        }}
    )
        dTable:debugPrint()
    end

    if keyUp then
        return Hyper:ignoreKeys()
    end
    if disableAll then
        return false
    end
    

    if not hyperKey or self.hyperModeActive then
        return false
    end
    return self:executeCommand(keyPressed)

    -- if self.vncMode then
    --     if keyPressed == "tab" then
    --         -- /Users/chaz/.hammerspoon/sendSubprocess
    --         -- run the subprocess in shell
    --         local script = "/Users/chaz/.hammerspoon/sendSubprocess"

    --         local altDown = "alt keydown"
    --         local altDownCmd = "${s} ${k}" % { s = script, k = altDown }
    --         local altUp = "alt keyup"
    --         local altUpCmd = "${s} ${k}" % { s = script, k = altUp }
    --         local tabDown = "tab keydown"
    --         local tabDownCmd = "${s} ${k}" % { s = script, k = tabDown }
    --         local tabUp = "tab keyup"
    --         local tabUpCmd = "${s} ${k}" % { s = script, k = tabUp }

    --         hs.execute(altDownCmd, true)
    --         hs.execute(tabDownCmd, true)

    --         hs.timer.doAfter(0.1, function()
    --             hs.execute(tabUpCmd, true)
    --         end)
    --         return true
    --     end
        
    --     -- if cmd then
    --     -- --     hs.alert.show("VNC Mode Cmd Key Pressed")
    --     -- --     --return self:xdotoolInterface()
    --     -- --     return false
    --     -- -- elseif alt then
    --     -- --     if keyPressed == "tab" then
    --     -- --         hs.alert.show("VNC Mode Alt-Tab")
    --     -- --         print("VNC Mode Alt-Tab")
    --     -- --         self:xdotoolInterface("alt-Tab")
    --     -- --         return true
    --     -- --     end
    --     -- --     return false
    --     -- end
    --     return false
    -- end
end

function Hyper:executeCommand(key)
    local command = self.commands[key]
    if command then
        command.action()
        return true
    end
    return false
end

function Hyper:startService()
    self.keyDownTracker:start()
    return true
end

function Hyper:stopService()
    if self.keyDownTracker then
        self.keyDownTracker:stop()
    end
end

return Hyper
