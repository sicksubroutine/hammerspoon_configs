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
            title = "❖ + N: Rebuild NixOS Configuration",
            fn = function() end
        },
        {
            title = "❖ + Space: Launch Raycast",
            fn = function() hs.application.launchOrFocus(RaycastName) end
        },
        {
            title = "Launch Start Applications",
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
            self.menubarItem:setTitle("🔴") -- red dot for active
        else
            self.menubarItem:setTitle("⚪") -- White dot for inactive
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
        hs.alert.show("Rebuilding NixOS Configuration, please standby...")
        hs.execute("open ~/.hammerspoon/__hammerspoon.log")
        hs.timer.doAfter(1, function()
            local output, _, _ = hs.execute("darwin-rebuild switch --flake ~/.config/nix/#pluto", true)
            logger:debug(output)
        end)
    end
    return false
end

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

    if hyperKey then
        return self:hyperKeyChecks(keyPressed)
    end

    if self.hyperModeActive then
        return self:whileHyperModeActive(keyPressed)
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
