-- helpers/hypermode.lua
---@diagnostic disable: undefined-field
---@alias Optional nil

local class = require("30log")
---@class Hyper
---@field hyperModeActive boolean
---@field eventtap hs.eventtap
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
    self.eventtap = self:returnEventTap()
    self.eventtap:start()
    self.menubarItem = hs.menubar.new()
    if not self.menubarItem then
        hs.alert.show("Failed to create menubar item")
        return nil
    end
    self:updateMenubar()
    print("-- HyperMode Initialized")
    return self
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
function Hyper:returnEventTap()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        return self:handleKeyEvent(event)
    end)
    return tap
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
        if self.hyperModeActive then
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

---comment Handles the key events for fun and profit
---@param event hs.eventtap.event
---@return boolean
function Hyper:handleKeyEvent(event)
    local keyPressed = hs.keycodes.map[event:getKeyCode()]
    local flags = event:getFlags()
    local hyperKey = compFlags(flags, {"cmd", "alt", "ctrl", "shift"})

    if DebugMode then
        print("Key pressed: " .. tostring(keyPressed))
        print("Flags: " .. hs.inspect(flags))
        print("Hyper Mode Active: " .. tostring(self.hyperModeActive))
        print("Hyper key match: " .. tostring(hyperKey))
    end
    
    if hyperKey or self.hyperModeActive then
        return self:executeCommand(keyPressed)
    end
    
    return false
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
    self.eventtap:start()
    return true
end

function Hyper:stopService()
    if self.eventtap then
        self.eventtap:stop()
    end
end

return Hyper
