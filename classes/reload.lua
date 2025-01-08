local class = require('classes.class')
local settings = require('classes.settings')
local path = require('classes.pathlib')
---@class Reload
---@field settings SettingsManager
---@field doReload boolean
---@field lastReload number
---@field path Path
local Reload = class("Reload")

local coolDownPeriod = 2

function Reload:init(pathToReload)
    self.settings = settings("reload", false)
    self.doReload = false
    self.lastReload = self.settings:get("last_reload", 0)
    self.path = pathToReload
    self.watcher = nil
    self.print = function(text) print("-- [Reload] " .. text) end
    self.print("Reload initialized")
    self.error = function(text) error("-- [Reload] " .. text) end
    self:watcherSetup()
    return self
end

function Reload:watcherSetup()
    if not self.path:exists() then
        self.error("Error: Path does not exist")
        return
    end
    
    self.watcher = hs.pathwatcher.new(str(self.path), function(files)
        if not files then
            self.error("Warning: No files detected")
            return
        end
        printf("Files detected: %s", table.concat(files, ", "))
        self:reloadConfig(files)
    end)

    if not self.watcher then
        self.error("Error: Failed to create pathwatcher")
        return
    end
end

function Reload:start()
    self.watcher:start()
    self.print("Reload Start initialized")
end

function Reload:reloadConfig(files)
    local currentTime = os.time()
    if (currentTime - self.lastReload) < coolDownPeriod then
        self.print("Skipping reload: cool down period")
        return
    end

    local success, err = pcall(function()
        for _, file in pairs(files) do
            if file:sub(-4) == ".lua" then
                self.doReload = true
                break
            end
        end
    end)

    if not success then
        self.print("Error processing files: " .. tostring(err))
        return
    end

    if self.doReload then
        self.lastReload = currentTime
        self.settings:set("last_reload", currentTime)
        self.print("Reloading configuration")
        hs.reload()
    end

    self.doReload = false
end

return Reload
