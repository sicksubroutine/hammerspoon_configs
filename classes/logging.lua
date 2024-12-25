local class = require('classes.30log')

---@class Logger
---@field private logfile file*
---@field private log_level string
---@field private logpath string
---@field private logname string
---@field private buffer table
---@field private buffer_size number
---@field private last_flush number
---@field private flush_interval number
---@field private max_buffer number
---@field public init fun(self: Logger, logname: string, log_level: string): Logger
---@field public start fun(self: Logger): boolean
---@field public close fun(self: Logger)
---@field public flush fun(self: Logger)
---@field public clear fun(self: Logger)
---@field private _log fun(self: Logger, level: string, message: string)
---@field public info fun(self: Logger, ...: any)
---@field public error fun(self: Logger, ...: any)
---@field public warning fun(self: Logger, ...: any)
---@field public debug fun(self: Logger, ...: any)
---@field public getLogger fun(name: string, log_level: string): Logger | nil
---@return Logger
local Logger = class("Logger")

function Logger:init(logname, log_level)
    self.logfile = nil
    self.log_level = log_level or "info"
    self.logpath = os.getenv("HOME") .. "/.hammerspoon/"
    self.logname = logname and (logname .. ".log") or LoggerFileName
    self.buffer = {}
    self.buffer_size = 0
    self.max_buffer = 1024 * 10  -- 10KB buffer
    self.last_flush = os.time()
    self.flush_interval = 5  -- Flush every 5 seconds
    
    -- Emergency cleanup on hammerspoon termination
    hs.shutdownCallback = function()
        self:close()
    end
    
    return self
end

function Logger:start()
    local ok, file = pcall(io.open, self.logpath .. self.logname, "a")
    if not ok or not file then
        hs.alert.show("Failed to open log file")
        return false
    end
    self.logfile = file
    return true
end

function Logger:close()
    if self.logfile then
        self:flush()  -- Flush remaining buffer
        self.logfile:close()
        self.logfile = nil
    end
end

function Logger:clear()
    if self.logfile then
        self:close()
    end
    os.remove(self.logpath .. self.logname)
end

function Logger:flush()
    if #self.buffer > 0 and self.logfile then
        self.logfile:write(table.concat(self.buffer))
        self.logfile:flush()
        self.buffer = {}
        self.buffer_size = 0
        self.last_flush = os.time()
    end
end

function Logger:_log(level, message)
    if not self.logfile then return end
    
    -- Create log entry
    local entry = string.format("[%s] [%s] %s\n", 
        level:upper(),
        os.date("%Y-%m-%d %H:%M:%S"),
        message)
    
    -- Add to buffer
    table.insert(self.buffer, entry)
    self.buffer_size = self.buffer_size + #entry
    
    -- Check if we need to flush
    if self.buffer_size >= self.max_buffer or 
       (os.time() - self.last_flush) >= self.flush_interval then
        self:flush()
    end
end

function Logger:info(...)  
    self:_log("info", table.concat({...}, "\t")) 
end

function Logger:error(...) 
    self:_log("error", table.concat({...}, "\t")) 
end

function Logger:warning(...) 
    self:_log("warning", table.concat({...}, "\t")) 
end

function Logger:debug(...) 
    self:_log("debug", table.concat({...}, "\t")) 
end

---Get a logger instance
---@param name string
---@param log_level string
---@return Logger | nil
function Logger:getLogger(name, log_level)
    local logger = Logger(name, log_level)
    if logger:start() then
        return logger
    end
    return nil
end

return Logger
