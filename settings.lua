local class = require('classes.30log')

---@class SettingsManager
---@field private prefix string
---@field private debug boolean
local SettingsManager = class("Settings")

--- Initializes the SettingsManager class
---@param name string
---@param debug boolean
---@return SettingsManager
function SettingsManager:init(name, debug)
    self.prefix = name and name .. "." or ""
    self.debug = debug or false
    return self
end

function SettingsManager:set(key, value)
    hs.settings.set(self.prefix .. key, value)
    local check = hs.settings.get(self.prefix .. key)
    if self.debug then print("Added Key to Settings [" .. key .."]: "..tostring(check)) end
end

function SettingsManager:setAll(data)
    for key, value in pairs(data) do
        self:set(key, value)
    end
end

function SettingsManager:get(key, default)
    local value = hs.settings.get(self.prefix .. key)
    if self.debug then print("Getting Key from Settings [" .. key .."]: "..tostring(value)) end
    return value ~= nil and value or default
end

function SettingsManager:delete(key)
    if self:get(key) == nil then
        if self.debug then print("Key [" .. key .. "] does not exist") end
        return false
    end
    hs.settings.clear(self.prefix .. key)
    local check = hs.settings.get(self.prefix .. key)
    if self.debug then print("Deleted Key from Settings [" .. key .."]: "..tostring(check)) end
end

function SettingsManager:clear()
    if self.debug then print("Clearing all settings") end
    return hs.settings.clear()
end

--- Returns all keys in the settings with the prefix
---@return table
function SettingsManager:getAllKeys()
    local all_keys = hs.settings.getKeys()
    if not all_keys then
        return {}
    end
    
    local prefix_keys = {}
    for _, key in ipairs(all_keys) do
        if string.sub(key, 1, #self.prefix) == self.prefix then
            table.insert(prefix_keys, string.sub(key, #self.prefix + 1))
        end
    end

    if self.debug then print("Number of keys returned: " .. #prefix_keys) end
    return prefix_keys
end

_G.SettingsManager = SettingsManager
