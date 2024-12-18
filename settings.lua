local class = require("30log")

---@class Settings
local Settings = class({name = "Settings"})

function Settings:init(name, debug)
    self.prefix = name and name .. "." or ""
    self.debug = debug
    return self
end

function Settings:save(key, value)
    hs.settings.set(self.prefix .. key, value)
    local check = hs.settings.get(self.prefix .. key)
    if self.debug then print("Saved Key to Settings [" .. key .."]: "..tostring(check)) end
end

function Settings:get(key, default)
    local value = hs.settings.get(self.prefix .. key)
    if self.debug then print("Getting Key from Settings [" .. key .."]: "..tostring(value)) end
    return value ~= nil and value or default
end

function Settings:delete(key)
    if self:get(key) == nil then
        if self.debug then print("Key [" .. key .. "] does not exist") end
        return false
    end
    hs.settings.clear(self.prefix .. key)
    local check = hs.settings.get(self.prefix .. key)
    if self.debug then print("Deleted Key from Settings [" .. key .."]: "..tostring(check)) end
end

function Settings:clear()
    if self.debug then print("Clearing all settings") end
    return hs.settings.clear()
end

function Settings:getAllKeys()
    -- Get all keys in the settings
    -- If a prefix is set, only return keys with that prefixes in a table

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

return Settings
