local class = require("classes.class")
local settingsManager = require("classes.settings")

---@class DockHandler
---@field app_to_block string[]
---@field default_delay number
---@field vnc_delay number
---@field settings SettingsManager
---@field waitTime number
local DockHandler = class("DockHandler")

function DockHandler:init(app_to_block, default_delay, vnc_delay, wait_time)
    self.app_to_block = app_to_block
    self.default_delay = default_delay
    self.vnc_delay = vnc_delay
    self.settings = settingsManager("DockHandler", DebugMode)
    self.waitTime = wait_time -- wait X seconds before updating the settings again to prevent multiple updates
    self.lastTimeUpdated = self.settings:get("last_time_settings_updated", 0)
    self.appWatcher = nil
    return self
end

---StaticMethod
function DockHandler.setDockDelay(delay)
    print("Setting Dock Delay to: ${d}" % {d = delay})
    local command = string.format('/usr/bin/defaults write com.apple.dock autohide-delay -float %f && /usr/bin/killall Dock', delay)
    hs.task.new("/bin/bash", nil, {"-c", command}):start()
end

function DockHandler:checkUpdateTime()
    local current_time = os.time()
    if current_time - self.lastTimeUpdated > self.waitTime then
        return true
    end
    return false
end

function DockHandler:updateSettings(delay)
    local currentTime = os.time()
    self.settings:set("last_time_settings_updated", currentTime)
    self.lastTimeUpdated = currentTime
    self.setDockDelay(delay)
end

function DockHandler.appWatcherCallback(self, appName, eventType)
    if not self:checkUpdateTime() then print("Waiting longer to change...") return end
    if eventType == hs.application.watcher.activated then
        print("Current app Focused: ${a}" % {a = appName})
        if hs.fnutils.contains(self.app_to_block, appName) then
            print("VNC Viewer is running, setting delay to: ${d}" % {d = self.vnc_delay})
            self:updateSettings(self.vnc_delay)
        else
            self:updateSettings(self.default_delay)
        end
    end
end

function DockHandler:start()
    self.appWatcher = hs.application.watcher.new(function(appName, eventType)
        self:appWatcherCallback(appName, eventType)
    end)
    self.appWatcher:start()
    self.setDockDelay(self.default_delay)
end

function DockHandler:stop()
    self:updateSettings(self.default_delay)
    self.appWatcher:stop()
end

return DockHandler
