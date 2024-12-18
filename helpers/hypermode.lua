-- helpers/hypermode.lua
---@diagnostic disable: undefined-field
local class = require("30log")
---@class Hyper
local Hyper = class({ name = "Hyper" })

--- comment Initialized the Hyper class
--- @param debug boolean
function Hyper:init(debug)
    self.debug = debug
    self.hyperModeActive = false
    self.menubarItem = hs.menubar.new()
    if not self.menubarItem then
        hs.alert.show("Failed to create menubar item")
        return nil
    end
    self:updateMenubar()

    self.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        ---@type hs.eventtap.event
        return self:handleKeyEvent(event)
    end)

    if not self.eventtap then
        hs.alert.show("Failed to create event tap")
        return nil
    end

    return self
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

---comment Handles the key events for fun and profit
---@param event hs.eventtap.event
---@return boolean
function Hyper:handleKeyEvent(event)
    if self.hyperModeActive then
        local modifiers = event:getFlags()
        local hyper_key = modifiers["cmd"] and modifiers["ctrl"] and modifiers["alt"] and modifiers["shift"]
        local keyPressed = hs.keycodes.map[event:getKeyCode()]

        if keyPressed == "space" then
            hs.application.launchOrFocus(RAYCAST)
            self:toggleHyperMode()
            return true
        end
        if self:hyperKeyChecks(hyper_key, keyPressed) then return true end

        if keyPressed == "a" then
            hs.alert.show("Hyper A")
            return true -- Suppress original key
        end
    end
    return false
end

function Hyper:start_service()
    if not self.eventtap then
        print("Debug: eventtap is nil")
        return false
    end
    local status, err = pcall(function()
        self.eventtap:start()
        self:hyperBind({}, "F17", function() self:toggleHyperMode() end)
    end)
    if not status then
        hs.alert.show("Failed to start service: " .. str(err))
        return false
    end
    return true
end

function Hyper:stop_service()
    if self.eventtap then
        self.eventtap:stop()
    end
end

return Hyper
