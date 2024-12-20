-- helpers/hypermode.lua
---@diagnostic disable: undefined-field
---@alias Optional nil

local class = require("30log")
---@class Hyper
---@field hyperModeActive boolean
---@field eventtap hs.eventtap
---@field menubarItem hs.menubar | Optional
local Hyper = class({ name = "Hyper" })

--- comment Initialized the Hyper class
--- @return Hyper | Optional
function Hyper:init()
    self.hyperModeActive = false
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

--- comment Returns the event tap for the Hyper Mode
---@return hs.eventtap
function Hyper:returnEventTap()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        return self:handleKeyEvent(event)
    end)
    return tap
end
    

function Hyper:getMode()
    return self.hyperModeActive
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
    local __separator__ = { title = "-" }
    return {
        -- Show current state
        {
            title = "Status: " .. (self.hyperModeActive and "Hyper Mode Active 🔴" or "Hyper Mode Inactive ⚪"),
            fn = function() self:toggleHyperMode() end
        },
        __separator__,
        {
            title = "Available Commands:",
            disabled = true
        },
        {
            title = "• Hyper + Space: Launch Raycast",
            fn = function() hs.application.launchOrFocus(RAYCAST) end
        },
        {
            title = "• Launch Start Applications",
            fn = function() hs.application.launchOrFocus("Start") end
        },
        __separator__,
        {
            title = "Reload Configuration",
            fn = function() hs.reload() end
        }
    }
end

function Hyper:updateMenubar()
    if self.menubarItem then
        if self.hyperModeActive then
            -- red dot for active
            self.menubarItem:setTitle("🔴")
        else
            -- White dot for inactive
            self.menubarItem:setTitle("⚪")
        end
    end
    self.menubarItem:setMenu(self:createMenu())
end

---comment Passthrough for hs.hotkey.bind
---@param modifiers table
---@param key string
---@param pressedfn any
---@param releasedfn any
function Hyper:hyperBind(modifiers, key, pressedfn, releasedfn)
    hs.hotkey.bind(modifiers, key, pressedfn, releasedfn)
end

---comment String comparison for hyper key checks
---@param hyper_key boolean
---@param key string
---@return boolean
function Hyper:hyperKeyChecks(hyper_key, key)
    if hyper_key then
        if key == "a" then
            self:toggleHyperMode()
            return true
        elseif key == "r" then
            hs.reload()
            return true
        end
    end
    return false
end

local function compFlags(pattern, flags)
    for i, v in ipairs(flags) do
        if not pattern[v] then
            return false
        end
    end
    return true
end

---comment Handles the key events for fun and profit
---@param event hs.eventtap.event
---@return boolean
function Hyper:handleKeyEvent(event)
    local keyPressed = hs.keycodes.map[event:getKeyCode()]
    local flags = event:getFlags()
    
    -- Add debug logging
    print("Key pressed: " .. tostring(keyPressed))
    print("Flags: " .. hs.inspect(flags))
    print("Hyper Mode Active: " .. tostring(self.hyperModeActive))
    
    local hyper_key = compFlags(flags, {"cmd", "alt", "ctrl", "shift"})
    print("Hyper key match: " .. tostring(hyper_key))

    if self.hyperModeActive then
        print("Processing active hyper mode key: " .. tostring(keyPressed))
        
        if keyPressed == "k" then
            print("Killing Hammerspoon")
            hs.alert.show("Killing Hammerspoon")
            hs.execute("killall Hammerspoon")
            return true
        end

        if keyPressed == "space" then
            print("Launching Raycast")
            hs.application.launchOrFocus(RAYCAST)
            self:toggleHyperMode()
            return true
        end
        
        if self:hyperKeyChecks(hyper_key, keyPressed) then 
            print("Hyper key check passed")
            return true 
        end

        if keyPressed == "a" then
            print("Hyper A pressed")
            hs.alert.show("Hyper A")
            return true
        end
    end
    
    print("Event not handled")
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
