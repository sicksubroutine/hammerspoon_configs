---@diagnostic disable: undefined-field, need-check-nil
---@alias Optional nil

local class = require('classes.class')
---@class Hyper
---@field hyperModeActive boolean
---@field commands table
---@field menubarStatus string
---@field keyDownTracker hs.eventtap
---@field menubarItem hs.menubar | Optional
local Hyper = class({ name = "Hyper" })

---@class HyperCommand
---@field name string
---@field key string
---@field action function
---@field showInMenu boolean
---@field menuTitle string|nil
---@field disabled boolean

--- comment Initialized the Hyper class
--- @return Hyper | Optional
function Hyper:init()
    self.hyperModeActive = false
    self.commands = {}
    self.menubarStatus = "inactive"
    self.keyDownTracker = self:returnKeyDownTracker()
    self.keyUpTracker = self:returnKeyUpTracker()
    --self.mouseButtonTracker = self:returnMouseButtonDownTracker()
    if jSettings:get("vnc", false) then
        self.vncWatcher = self:vncModeCheck() -- Check if VNC Viewer is in focus
    end
    self.menubarItem = hs.menubar.new()
    if not self.menubarItem then
        hs.alert.show("Failed to create menubar item")
        return nil
    end
    self:onInit()
    self.print = function(text) print("-- [Hyper] " .. text) end
    self.print("HyperMode Initialized")
    return self
end

function Hyper:onInit()
    self:updateMenubar()
    if jSettings:get("vnc", false) then
        self.vncWatcher:start()
    end
    self.keyDownTracker:start()
    self.keyUpTracker:start()
    --self.mouseButtonTracker:start()
end


function Hyper:registerCommandAlt(name, key, action, showInMenu, menuTitle)
    logger:debug("Registering Command: ${n}" % {n=name})
    self.commands[key] = {
        name = name,
        key = key,
        action = action,
        showInMenu = showInMenu or false,
        menuTitle = menuTitle or name
    }
end


---Registers Command Object for Various Hyper Mode Commands
function Hyper:registerCommand(cmd)
    self.commands[cmd.key] = cmd
end



--- comment Returns the event tap for the Hyper Mode
---@return hs.eventtap
function Hyper:returnKeyDownTracker()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        return self:handleKeyEvent(event, "Key Down")
    end)
    return tap
end

function Hyper:returnKeyUpTracker()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(event)
        return self:handleKeyEvent(event, "Key Up")
    end)
    return tap
end

function Hyper:returnMouseButtonDownTracker()
    local tap = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
        local buttonNumber = event:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
        return self:handleMouseEvent(event, buttonNumber)
    end)
    return tap
end


---Check if VNC Viewer is running and set the vncMode to true
---@return hs.application.watcher | nil
function Hyper:vncModeCheck()
    if not jSettings:get("vnc", false) then return nil end
    local vncWatcher = hs.application.watcher.new(function(name, event, app)
        if name == "VNC Viewer" then
            if event == hs.application.watcher.activated then
                self.menubarStatus = "vnc"
                self:updateMenubar()
            elseif event == hs.application.watcher.deactivated then
                self.menubarStatus = "inactive"
                self:updateMenubar()
            end
        end
    end)
    if vncWatcher then
        return vncWatcher
    end
    return nil
end

--- comment Returns the current mode of the Hyper Mode
---@return boolean
function Hyper:getMode()
    return self.hyperModeActive
end

---comment Sets the mode of the Hyper Mode
---@param value boolean
function Hyper:setMode(value)
    if value == false then
        self.hyperModeActive = false
    else
        self.hyperModeActive = true
    end
    self:updateMenubar()
end

function Hyper:toggleHyperMode()
    self.hyperModeActive = not self.hyperModeActive
    if self.hyperModeActive then
        self.menubarStatus = "active"
        hs.alert.show("Hyper Mode Activated")
    else
        self.menubarStatus = "inactive"
        hs.alert.show("Hyper Mode Deactivated")
    end
    self:updateMenubar()
end


---comment Creates the menubar for the Hyper Mode
---@return table
function Hyper:createMenu()

    local hyperModeStatus = "Hyper Status: " .. (self.hyperModeActive and "Hyper Mode Active" or "Hyper Mode Inactive")

    local menu = {
        {
            title = hyperModeStatus,
            fn = function() self:toggleHyperMode() end
        },
        -- debug status
        {
            title = "Debug Mode: " .. (jSettings:get("debug", false) and "On" or "Off"),
            fn = function() DebugModeToggle() end
        },
        { title = "-" },
        {
            title = "Available Commands:",
            disabled = true
        }
    }
    for _, command in pairs(self.commands) do
        if command.showInMenu then
            table.insert(menu, {
                title = command.menuTitle,
                fn = command.action
            })
        end
    end
    
    return menu
end

local function returnStatusMap(status)
    -- ⭕ 🔴 🟠 🟡 🟢 🔵 🟣 🟤 ⚫ ⚪ 🍑
    -- ☠️ 💩 👽 🍆 🐻 👻 💦 👀 👅 🫦 🥑
    -- 🧄 🧅 🫘 🥨 🍔 🍕 🍟 🌮 🥩 🥓 🧨
    -- 🎃 😏 🥴
    STATUS_MAP = {
        ["active"] = "🔵",
        ["inactive"] = "⚪",
        ["vnc"] = "🟢",
        ["booty"] = "🍑"
    }
    return STATUS_MAP[status]
end


---comment Updates the menubar for the Hyper Mode
function Hyper:updateMenubar()
    if self.menubarItem then
        self.menubarItem:setTitle(returnStatusMap(self.menubarStatus))
    end
    self.menubarItem:setMenu(self:createMenu())
end

--- Compares the flags to the pattern
---@param pattern table | nil
---@param flags table
---@return boolean
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

function Hyper:ignoreKeys() return false end

-- TODO: Implement the mouse button handling eventually
function Hyper:handleMouseEvent(event, buttonNumber)
    hs.alert.show("Mouse Button: " .. tostring(buttonNumber))
    return false
end

-- TODO: Implement the key up event handling eventually maybe... if you're good. Are you good?
function Hyper:handleKeyUpEvent(event, key)
    hs.alert.show("Key Up Event: " .. key)
    return false
end

---comment Handles the key events for fun and profit
---@param event hs.eventtap.event
---@param eventType string
---@return boolean
function Hyper:handleKeyEvent(event, eventType)
    ---@type string
    local keyPressed = hs.keycodes.map[event:getKeyCode()]
    local keyDown = eventType == "Key Down"
    local keyUp = eventType == "Key Up"
    local flags = event:getFlags()
    local ctrl, cmd, alt, shift = flags["ctrl"], flags["cmd"], flags["alt"], flags["shift"]
    local hyperKey = compFlags(flags, {"cmd", "alt", "ctrl", "shift"})
    --local disableAll = true
    local disableAll = false


    if DebugMode and not disableAll then
        local dTable = DebugTable({
        theme = DebugTheme({
            title = "Key Events",
            prefix = "-- ",
            mid = ": ",
            sep = "\n"
        }),
        data = {
            Event = eventType,
            Key = keyPressed,
            Ctrl = boolToStr(ctrl),
            Cmd = boolToStr(cmd),
            Alt = boolToStr(alt),
            Shift = boolToStr(shift),
            HyperKey = boolToStr(hyperKey),
            HyperMode = boolToStr(self.hyperModeActive)
        }}
    )
        dTable:debugPrint()
    end

    if keyUp then
        return Hyper:ignoreKeys()
    end
    if disableAll then
        return false
    end
    
    if not hyperKey or self.hyperModeActive then
        return false
    end
    return self:executeCommand(keyPressed)
end

function Hyper:executeCommand(key)
    local command = self.commands[key]
    if command == nil then print("No command found for key: " .. key) return false end
    if command.disabled then return false end
    if command then command.action() return true end
    return false
end

function Hyper:startService()
    self.keyDownTracker:start()
    return true
end

function Hyper:stopService()
    if self.keyDownTracker then
        self.keyDownTracker:stop()
    end
end

return Hyper
