-- connection.lua
local class = require("30log")
--- @class Connection 
--- @field settings Settings
local Connection = class({name="Connection"})

local WAIT_TIME = 30

---comment Initializes the Connection class
---@param settings Settings
---@param debug boolean
---@return self
function Connection:init(settings, debug)
    if settings then
        self.settings = settings():init("Connection", debug)
        print("-- Settings initialized")
    end
    self.debug = debug

    self.wifi = self.settings:get("wifi", false)
    self.ethernet = self.settings:get("ethernet", false)

    print("Debug: ${s.debug}, WiFi: ${s.wifi}, Ethernet: ${s.ethernet}" % {s=self})

    return self
end

-- Private functions remain local
local function turnOffWiFi()
    hs.osascript.applescript([[
        do shell script "networksetup -setairportpower Wi-Fi off"
    ]])
    hs.alert.show("Trying to turn Wi-Fi off...")
end

local function turnOnWifi()
    hs.osascript.applescript([[
        do shell script "networksetup -setairportpower Wi-Fi on"
    ]])
    hs.alert.show("Trying to turn Wi-Fi on...")
end

-- Private Methods


function Connection:p_debug(message)
    if self.debug then print(message) end
end

function Connection:checkTime()
    local last_checked = self.settings:get("last_checked", UnixTimestamp())
    if not last_checked then
        Connection:p_debug("Last checked is nil")
        self.settings:save("last_checked", UnixTimestamp())
        return true
    end
    local current_time = UnixTimestamp()
    local difference = os.difftime(current_time, last_checked)
    return difference > WAIT_TIME
end

function Connection:checkWiFiStatus()
    local interface_info = hs.network.addresses("en0")
    local new_wifi_status = interface_info ~= nil and #interface_info > 0

    Connection:p_debug(string.format("WiFi Check - Previous State: %s, New State: %s",
    tostring(self.wifi), tostring(new_wifi_status)))

    if new_wifi_status ~= self.wifi then
        Connection:p_debug("WiFi state changed!")
        self.wifi = new_wifi_status
        self.settings:save("wifi", self.wifi)
    else
        Connection:p_debug("WiFi state did not change")
    end
    return new_wifi_status
end

function Connection:checkEthernetStatus()
    local interface_info = hs.network.addresses("en6")
    local new_ethernet_status = interface_info ~= nil and #interface_info > 0

    Connection:p_debug(string.format("Ethernet Check - Previous State: %s, New State: %s", tostring(self.ethernet), tostring(new_ethernet_status)))

    if new_ethernet_status ~= self.ethernet then
        Connection:p_debug("Ethernet state changed!")
        self.ethernet = new_ethernet_status
        self.settings:save("ethernet", self.ethernet)
    else
        Connection:p_debug("Ethernet state did not change")
    end
    return new_ethernet_status
end

function Connection:resetState()
    print("Forcing state reset...")
    self.wifi = false
    self.ethernet = false
    self.settings:save("wifi", false)
    self.settings:save("ethernet", false)
    self.settings:save("last_checked", 0)
end

function Connection:checkInterfaces()
    local wifi_status = self:checkWiFiStatus()
    local ethernet_status = self:checkEthernetStatus()

    Connection:p_debug(string.format("Current States - WiFi: %s, Ethernet: %s", tostring(wifi_status), tostring(ethernet_status)))
    self.settings:save("last_checked", UnixTimestamp())

    local no_interfaces = not wifi_status and not ethernet_status
    local ethernet_and_wifi = wifi_status and ethernet_status

    if no_interfaces then
        print("No interfaces connected, turning on WiFi")
        turnOnWifi()
    elseif ethernet_and_wifi then
        print("Ethernet is ON, turning off WiFi")
        turnOffWiFi()
    elseif ethernet_status and not wifi_status then
        Connection:p_debug("Ethernet is ON, not doing anything...")
    elseif wifi_status and not ethernet_status then
        Connection:p_debug("WiFi is ON, not doing anything...")
    else
        print("Unknown state, not doing anything...")
    end
end


function Connection:start()
    local timer = hs.timer.doEvery(WAIT_TIME, function()
        local current_time = UnixTimestamp()
        local last_checked = self.settings:get("last_checked", 0)
        local time_diff = os.difftime(current_time, last_checked)
        
        Connection:p_debug(string.format("Timer Tick - Current Time: %d, Last Checked: %d, Time Diff: %d",
        current_time, last_checked, time_diff))
        
        if time_diff >= WAIT_TIME * 2 then print("Long time since last check, forcing reset") self:resetState() end
        self:checkInterfaces()
    end)
end


return Connection
