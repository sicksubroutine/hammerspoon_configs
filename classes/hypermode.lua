---@diagnostic disable: undefined-field, need-check-nil
---@alias Optional nil

local class = require('classes.30log')
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

--- comment Returns the event tap for the Hyper Mode
---@return hs.eventtap
function Hyper:returnKeyDownTracker()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        return self:handleKeyEvent(event)
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

function Hyper:ignoreKeys(keyPressed, flags)
    -- Ignore 
end

function Hyper:handleMouseEvent(event, buttonNumber)
    hs.alert.show("Mouse Button: " .. tostring(buttonNumber))
    return false
end

--- An interface between local commands on MacOS and remote Linux commands
---@param keys string
function Hyper:xdotoolInterface(keys)
    local sshCmd = "ssh kai@192.168.50.154"
    -- "export DISPLAY=:1; xdotool key ${keys}"' % {keys=keys}
    sshCmd = "${s} 'export DISPLAY=:1; xdotool key ${keys}'" % {s=sshCmd, keys=keys}
    -- local keyMap = {
    --     ["cmd"] = "ctrl",
    --     ["alt"] = "alt",
    --     ["ctrl"] = "super",
    --     ["shift"] = "shift"
    -- }
    -- local keyStr = ""
    -- for key, value in pairs(flags) do
    --     if value then
    --         keyStr = keyStr .. keyMap[key] .. "+"
    --         local p = {key=key, value=value}
    --         hs.alert.show("Original Flag: ${key} Passed Key: ${value}" % p)
    --     end
    --     -- check if last char is a plus and if so, remove it
    --     if keyStr:sub(-1) == "+" then
    --         keyStr = keyStr:sub(1, -2)
    --     end
    -- end
    -- hs.alert.show("")
    -- -- flags might have more than one key, need to concatenate them together like:
    -- -- ctrl+alt+shift+super+key
    hs.alert.show("Executing: " .. sshCmd)
    -- wait a second
    hs.timer.doAfter(2, function()
        local handle = io.popen(sshCmd .. " 2>&1")
        local result = handle:read("*a")
        handle:close()
        logger:info("Result: " .. result)
        hs.alert.show("Result: " .. result)
    end)

end


---comment Handles the key events for fun and profit
---@param event hs.eventtap.event
---@return boolean
function Hyper:handleKeyEvent(event)
    local keyPressed = hs.keycodes.map[event:getKeyCode()]
    local flags = event:getFlags()
    local ctrl, cmd, alt, shift = flags["ctrl"], flags["cmd"], flags["alt"], flags["shift"]
    local hyperKey = compFlags(
        flags, 
        {"cmd", "alt", "ctrl", "shift"}
    )

    if DebugMode then
        print("Ctrl: " .. tostring(ctrl))
        print("Cmd: " .. tostring(cmd))
        print("Alt: " .. tostring(alt))
        print("Shift: " .. tostring(shift))
        print("Key pressed: " .. tostring(keyPressed))
        print("Flags: " .. hs.inspect(flags))
        print("Hyper Mode Active: " .. tostring(self.hyperModeActive))
        print("Hyper key match: " .. tostring(hyperKey))
    end

    --if self.vncMode then
        -- if alt then
        --     local remote = "kai@192.168.50.154"
        --     --local cmd = "/Users/chaz/.pyenv/shims/python3.12 /Users/chaz/.hammerspoon/sendSubprocess.py alt+Tab"
        --     --hs.alert.show("Executing Remote Command")
        --     -- hs.timer.doAfter(1, function()end)
        --     --hs.alert.show("Remote Command Executed")
        --     return true
        -- end

        -- if cmd then
        -- --     hs.alert.show("VNC Mode Cmd Key Pressed")
        -- --     --return self:xdotoolInterface()
        -- --     return false
        -- -- elseif alt then
        -- --     if keyPressed == "tab" then
        -- --         hs.alert.show("VNC Mode Alt-Tab")
        -- --         print("VNC Mode Alt-Tab")
        -- --         self:xdotoolInterface("alt-Tab")
        -- --         return true
        -- --     end
        -- --     return false
        -- end
    --    return false
    --end
    if hyperKey or self.hyperModeActive then
        return self:executeCommand(keyPressed)
    else
        return false
    end
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
