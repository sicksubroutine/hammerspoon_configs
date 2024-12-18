-- public functions


local class = require("30log")

---@class Logger
---@field private logfile any
---@field private log_level string
---@field private logpath string
---@field private logname string
---@field private logger any
---@field private _logger hs.logger
local Logger = class({name="Logger"})

--- Initializes the Logger class
---@param logname string
---@param log_level string
---@return Logger
function Logger:init(logname, log_level)
    self.logfile = nil
    self.log_level = log_level or "info"
    self.logpath = os.getenv("HOME") .. "/.hammerspoon/"
    self.logname = logname..".log" or LOGGER_FILE_NAME
    --self.logger = nil
    --self._logger = hs.logger.new(logname, self.log_level)
    print("-- Logger initialized")
    return self
end

function Logger:start()
    self.logfile = io.open(self.logpath .. self.logname, "a")
    if self.logfile == nil then
        hs.alert.show("Failed to open log file")
        return false
    end
    --self:loggerMap(self.log_level)
    return true
end

function Logger:__gc()
    self:close()
end

function Logger:close()
    if self.logfile then
        self.logfile:close()
        self.logfile = nil
    end
end

function Logger:write(message)
    self.logfile:write(message .. "\n")
    self.logfile:flush()
end

-- --- Sends to hs.logger, which is console output
-- ---@param level string
-- ---@return function | nil
-- function Logger:loggerMap(level)
--     if level == "info" then
--         self.logger = self._logger.i
--     elseif level == "error" then
--         self.logger = self._logger.e
--     elseif level == "warning" then
--         self.logger = self._logger.w
--     elseif level == "debug" then
--         self.logger = self._logger.d
--     end
--     return nil
-- end


function Logger:_log(level, args)
    local message = table.concat(args, "\t")
    message = HumanTimestamp() .. "\t" .. message
    self.logfile:write("[".. level:upper() .. "] " .. message .. "\n")
    self.logfile:flush()
end

function Logger:info(...) self:_log("info", {...}) end

function Logger:error(...)
    local args = {...}
    local message = table.concat(args, "\t")
    message = HumanTimestamp() .. "\t" .. message
    self:_log("error", message)
end

function Logger:warning(...)
    local args = {...}
    local message = table.concat(args, "\t")
    message = HumanTimestamp() .. "\t" .. message
    self:_log("warning", message)
end

function Logger:debug(...)
    local args = {...}
    local message = table.concat(args, "\t")
    message = HumanTimestamp() .. "\t" .. message
    self:_log("debug", message)
end

---comment Return a logger for easy logging
---@param name string
---@param log_level string
---@return Logger
function Logger:getLogger(name, log_level)
    local logger = Logger():init(name, log_level)
    if logger.logfile == nil then
        if logger:start() then
            return logger
        end
    end
    return logger
end

return Logger
