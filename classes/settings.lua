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
    logger:debug("-- New SettingsManager Created: (${n})" % {n=name})
    return self
end

function SettingsManager:set(key, value)
    hs.settings.set(self.prefix .. key, value)
    local check = hs.settings.get(self.prefix .. key)
    logger:debug("Added Key to Settings [${k}]: ${c}" % {k=key, c=check})
end

function SettingsManager:setAll(data)
    for key, value in pairs(data) do
        self:set(key, value)
    end
end

function SettingsManager:get(key, default)
    local value = hs.settings.get(self.prefix .. key)
    logger:debug("Getting Key from Settings [${k}] ${v}" % {k=key, v=str(value)})
    return value ~= nil and value or default
end

function SettingsManager:delete(key)
    if self:get(key) == nil then
        logger:warning("Key [${k}] does not exist" % {k=key})
        return false
    end
    hs.settings.clear(self.prefix .. key)
    local check = hs.settings.get(self.prefix .. key)
    logger.debug("Deleted Key from Settings [${k}]: ${c}" % {k=key, c=check})
end

function SettingsManager:clear()
    logger:debug("Clearing all settings")
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

    logger:debug("Number of keys returned: ${n}" % {n=#prefix_keys})
    return prefix_keys
end

_G.SettingsManager = SettingsManager
return SettingsManager
