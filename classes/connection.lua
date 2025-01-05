local ethernetKey = "State:/Network/Interface/en6/Link"
local wifiKey = "State:/Network/Interface/en0/Link"
local globalIPv4 = "State:/Network/Global/IPv4"
-- Private functions --
--- Uses Osascript to turn off the Wi-Fi
---@return nil
local function turnOffWiFi()
    hs.osascript.applescript([[
        do shell script "networksetup -setairportpower Wi-Fi off"
    ]])
    hs.alert.show("Trying to turn Wi-Fi off...")
end

--- Uses Osascript to turn on the Wi-Fi
---@return nil
local function turnOnWifi()
    hs.osascript.applescript([[
        do shell script "networksetup -setairportpower Wi-Fi on"
    ]])
    hs.alert.show("Trying to turn Wi-Fi on...")
end


local class = require('classes.class')
local settingsManager = require("classes.settings")
--- @class Connection 
--- @field settings SettingsManager
--- @field debug boolean
--- @field wifi boolean
--- @field ethernet boolean
--- @field dateTime DateTime
--- @field config hs.network.configuration | nil
local Connection = class("Connection")

local WAIT_TIME = 60

---comment Initializes the Connection class
---@return Connection
function Connection:init()
    self.dateTime = DateTime.now()
    self.settings = settingsManager("Connection", DebugMode)
    self.debug = DebugMode
    self.wifi = self.settings:get("wifi", false)
    self.ethernet = self.settings:get("ethernet", false)
    self.config = hs.network.configuration.open()
    self.interfaceChangeAttempts = 0
    self.maxChangeAttempts = 3
    logger:debug("-- Connection(WiFi: ${s.wifi}, Ethernet: ${s.ethernet})" % {s=self})
    return self
end


-- --- Returns a boolean depending on if the time difference is greater than the wait timeout
-- ---@return boolean
-- function Connection:checkTime()
--     local last_checked = self.settings:get("last_checked", unixTimestamp())
--     last_checked = tonumber(last_checked)
--     local lastCheckedDT = DateTime.fromTimestamp(last_checked)
--     if not last_checked then
--         logger:debug("Last checked is nil")
--         self.settings:set("last_checked", unixTimestamp())
--         return true
--     end
--     self.dateTime:updateNow()
--     local difference = self.dateTime:compare(lastCheckedDT)
--     return difference > WAIT_TIME
-- end

--- Returns a boolean depending on if the WiFi status has changed
---@return boolean
function Connection:checkWiFiStatus()
    local currentWifiState = self.config:contents(wifiKey)
    if currentWifiState == nil then
        self.wifi = false
        self.settings:set("wifi", self.wifi)
        return false
    end
    currentWifiState = currentWifiState[wifiKey].Active or false

    logger:debug(string.format("WiFi Check - Previous State: %s, New State: %s",
    tostring(self.wifi), tostring(currentWifiState)))

    if currentWifiState ~= self.wifi then
        logger:debug("WiFi state changed!")
        self.wifi = currentWifiState
        self.settings:set("wifi", self.wifi)
    else
        logger:debug("WiFi state did not change")
    end
    return currentWifiState
end

--- Returns a boolean depending on if the Ethernet status has changed
---@return boolean
function Connection:checkEthernetStatus()
    local currentEthernetState = self.config:contents(ethernetKey)
    if currentEthernetState[ethernetKey] == nil then
        self.ethernet = false
        self.settings:set("ethernet", self.ethernet)
        return false
    end
    local currentEthernetState = self.config:contents(ethernetKey)[ethernetKey].Active or false
    logger:debug(string.format("Ethernet Check - Previous State: %s, New State: %s", str(self.ethernet), str(currentEthernetState)))

    if currentEthernetState ~= self.ethernet then
        logger:debug("Ethernet state changed!")
        self.ethernet = currentEthernetState
        self.settings:set("ethernet", self.ethernet)
    else
        logger:debug("Ethernet state did not change")
    end
    return currentEthernetState
end

--- Forces a reset of all states
---@return nil
function Connection:resetState()
    logger:debug("Forcing state reset...")
    self.wifi = false
    self.ethernet = false
    self.settings:set("wifi", false)
    self.settings:set("ethernet", false)
    self.settings:set("last_checked", -1)
end

function Connection:noInterfaces()
    logger:debug("No interfaces connected, turning on WiFi")
    turnOffWiFi()
    turnOnWifi()
end

function Connection:ethernetWifi()
    logger:debug("Ethernet and WiFi are connected, turning off WiFi")
    turnOffWiFi()
end


--- Checks the current state of the interfaces and takes appropriate actions
---@return nil
function Connection:checkInterfaces()
    local wifi_status = self:checkWiFiStatus()
    local ethernet_status = self:checkEthernetStatus()

    logger:debug("Current States - WiFi: ${w}, Ethernet: ${e}" % {w=str(wifi_status), e=str(ethernet_status)})

    if self.interfaceChangeAttempts >= self.maxChangeAttempts then
        logger:debug("Max attempts reached, backing off...")
        return
    end

    local no_interfaces = not wifi_status and not ethernet_status
    local ethernet_and_wifi = wifi_status and ethernet_status
    local noAction1 = ethernet_status and not wifi_status
    local noAction2 = not ethernet_status and wifi_status
    local unknown = not no_interfaces and not ethernet_and_wifi and not noAction1 and not noAction2

    -- We will actually take action here
    if no_interfaces then
        self.interfaceChangeAttempts = self.interfaceChangeAttempts + 1
        self:noInterfaces()
    return end -- if nothing is active, means that ethernet is not connected
    if ethernet_and_wifi then self:ethernetWifi() return end -- if both are active, that means we don't need wifi
    -- The following are just for logging purposes
    if noAction1 then logger:debug("Ethernet is ON, not doing anything...") end
    if noAction2 then logger:debug("WiFi is ON, not doing anything...") end
    if unknown then logger:warning("Unknown state, not doing anything...") end
end

function Connection:callbackJob()
    self.config:setCallback(function(store, keys)
        self.dateTime:updateNow()
        local current_time = self.dateTime:strftime(fullDateFormat)
        logger:debug("-- Checking interfaces at datetime: ${t}" % {t=str(current_time)})
        self:checkInterfaces()
    end)
end

function Connection:connectionAttemptReset()
    self.interfaceChangeAttempts = 0
end

function Connection:start()
    self:checkInterfaces()
    self:callbackJob()
    self.config:monitorKeys()
    self.config:start()
    hs.timer.doAfter(300, function()
        self:connectionAttemptReset()
    end)
end


return Connection
