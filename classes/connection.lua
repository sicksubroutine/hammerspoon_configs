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


local class = require('classes.30log')
local settingsManager = require("classes.settings")
--- @class Connection 
--- @field settings SettingsManager
--- @field debug boolean
--- @field wifi boolean
--- @field ethernet boolean
--- @field dateTime DateTime
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
    logger:debug("-- Connection(WiFi: ${s.wifi}, Ethernet: ${s.ethernet})" % {s=self})
    return self
end


--- Returns a boolean depending on if the time difference is greater than the wait timeout
---@return boolean
function Connection:checkTime()
    local last_checked = self.settings:get("last_checked", unixTimestamp())
    last_checked = tonumber(last_checked)
    local lastCheckedDT = DateTime.fromTimestamp(last_checked)
    if not last_checked then
        logger:debug("Last checked is nil")
        self.settings:set("last_checked", unixTimestamp())
        return true
    end
    self.dateTime:updateNow()
    local difference = self.dateTime:compare(lastCheckedDT)
    return difference > WAIT_TIME
end

--- Returns a boolean depending on if the WiFi status has changed
---@return boolean
function Connection:checkWiFiStatus()
    local interface_info = hs.network.addresses("en0")
    local new_wifi_status = interface_info ~= nil and #interface_info > 0

    logger:debug(string.format("WiFi Check - Previous State: %s, New State: %s",
    tostring(self.wifi), tostring(new_wifi_status)))

    if new_wifi_status ~= self.wifi then
        logger:debug("WiFi state changed!")
        self.wifi = new_wifi_status
        self.settings:set("wifi", self.wifi)
    else
        logger:debug("WiFi state did not change")
    end
    return new_wifi_status
end

--- Returns a boolean depending on if the Ethernet status has changed
---@return boolean
function Connection:checkEthernetStatus()
    local interface_info = hs.network.addresses("en6")
    local new_ethernet_status = interface_info ~= nil and #interface_info > 0

    logger:debug(string.format("Ethernet Check - Previous State: %s, New State: %s", str(self.ethernet), str(new_ethernet_status)))

    if new_ethernet_status ~= self.ethernet then
        logger:debug("Ethernet state changed!")
        self.ethernet = new_ethernet_status
        self.settings:set("ethernet", self.ethernet)
    else
        logger:debug("Ethernet state did not change")
    end
    return new_ethernet_status
end

--- Forces a reset of all states
---@return nil
function Connection:resetState()
    print("Forcing state reset...")
    self.wifi = false
    self.ethernet = false
    self.settings:set("wifi", false)
    self.settings:set("ethernet", false)
    self.settings:set("last_checked", 0)
end

--- Checks the current state of the interfaces and takes appropriate actions
---@return nil
function Connection:checkInterfaces()
    local wifi_status = self:checkWiFiStatus()
    local ethernet_status = self:checkEthernetStatus()

    logger:debug("Current States - WiFi: ${w}, Ethernet: ${e}" % {w=str(wifi_status), e=str(ethernet_status)})
    logger:debug("Last Checked: ${t}" % {t=str(self.settings:get("last_checked", unixTimestamp()))})
    self.settings:set("last_checked", unixTimestamp())

    local no_interfaces = not wifi_status and not ethernet_status
    local ethernet_and_wifi = wifi_status and ethernet_status

    if no_interfaces then
        print("No interfaces connected, turning on WiFi")
        turnOnWifi()
    elseif ethernet_and_wifi then
        print("Ethernet is ON, turning off WiFi")
        turnOffWiFi()
    elseif ethernet_status and not wifi_status then
        logger:debug("Ethernet is ON, not doing anything...")
    elseif wifi_status and not ethernet_status then
        logger:debug("WiFi is ON, not doing anything...")
    else
        print("Unknown state, not doing anything...")
    end
end

--- Starts the timer to check the interfaces
function Connection:start()
    self.dateTime:updateNow()
    local current_time = self.dateTime:strftime(fullDateFormat)
    logger:debug("-- Checking interfaces at datetime: ${t}" % {t=str(current_time)})
    self:checkInterfaces()
    hs.timer.doAfter(WAIT_TIME, function() self:start() end)
end


return Connection
