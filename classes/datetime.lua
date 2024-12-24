local class = require("30log")

---@type string
local full_date_format = "%m-%d-%Y %I:%M:%S %p"
---@type string
local date_only_format = "%m-%d-%Y"
---@type string
local time_only_format = "%I:%M:%S %p"

---@class DateTime
---@field private year number
---@field private month number
---@field private day number
---@field private hour number
---@field private min number
---@field private sec number
---@field public init fun(self: DateTime, year: number|nil, month: number|nil, day: number|nil, hour: number|nil, min: number|nil, sec: number|nil): DateTime
---@field public fromTimestamp fun(self: DateTime, timestamp: number): DateTime
---@field public toTimestamp fun(self: DateTime): integer
---@field public getYear fun(self: DateTime): number
---@field public getMonth fun(self: DateTime): number
---@field public getDay fun(self: DateTime): number
---@field public getHour fun(self: DateTime): number
---@field public getMin fun(self: DateTime): number
---@field public getSec fun(self: DateTime): number
---@field public parse fun(self: DateTime, datestr: string, format: string): DateTime
---@field public now fun(self: DateTime, option: string): string|osdate
---@field public today fun(self: DateTime): DateTime
---@field public strftime fun(self: DateTime, format: string): string|osdate
---@field public add_days fun(self: DateTime, days: number): DateTime
---@field public compare fun(self: DateTime, other: DateTime): number
---@field public datetime fun(self: DateTime, year: number|nil, month: number|nil, day: number|nil, hour: number|nil, min: number|nil, sec: number|nil): DateTime

local DateTime = class({name = "DateTime"})

--- Initializes the DateTime class
--- @param year number|nil
--- @param month number|nil
--- @param day number|nil
--- @param hour number|nil
--- @param min number|nil
--- @param sec number|nil
--- @return DateTime
function DateTime:init(year, month, day, hour, min, sec)
    self.year = year
    self.month = month
    self.day = day 
    self.hour = hour or 0
    self.min = min or 0
    self.sec = sec or 0
    return self
end

--- Create DateTime from timestamp
--- @param timestamp number
--- @return DateTime
function DateTime:fromTimestamp(timestamp)
    local t = os.date("*t", timestamp)
    return DateTime(t.year, t.month, t.day, t.hour, t.min, t.sec)
end

--- Convert DateTime to timestamp
---@return integer
function DateTime:toTimestamp()
    return os.time({
        year = self.year, month = self.month, day = self.day,
        hour = self.hour, min = self.min, sec = self.sec
    } * 1000)
end

--- Parse DateTime from string
--- @param datestr string
--- @param format string
--- @return DateTime
function DateTime:parse(datestr, format)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local y, m, d, h, min, s = datestr:match(pattern)
    return DateTime(tonumber(y), tonumber(m), tonumber(d), 
                   tonumber(h), tonumber(min), tonumber(s))
end

---comments
---@param option string
---@return string|osdate
function DateTime:now(option)
    if option == "date" then
        return os.date("%m-%d-%Y")
    elseif option == "time" then
        return os.date("%I:%M:%S %p")
    else
        return os.date("%m-%d-%Y %I:%M:%S %p")
    end
end

--- Get current date
--- @return DateTime
function DateTime:today()
    local t = os.date("*t")
    return DateTime(t.year, t.month, t.day)
end

--- Format DateTime to string
--- @param format string
--- @return string|osdate
function DateTime:strftime(format)
    local t = os.time({
        year = self.year, month = self.month, day = self.day,
        hour = self.hour, min = self.min, sec = self.sec
    })
    return os.date(format, t)
end

--- Add time delta
--- @param days number
--- @return DateTime
function DateTime:add_days(days)
    local t = os.time({
        year = self.year, month = self.month, day = self.day,
        hour = self.hour, min = self.min, sec = self.sec
    })
    t = t + (days * 86400) -- seconds in a day
    return DateTime:fromTimestamp(t)
end

--- Get year
---@return number
function DateTime:getYear()
    return self.year
end
--- Get month
---@return number
function DateTime:getMonth()
    return self.month
end
--- Get day
---@return number
function DateTime:getDay()
    return self.day
end

--- Get hour
---@return number
function DateTime:getHour()
    return self.hour
end
--- Get minute
---@return number
function DateTime:getMin()
    return self.min
end
--- Get second
--- @return number
function DateTime:getSec()
    return self.sec
end



--- Compare two DateTime objects
--- @param other DateTime
--- @return number
function DateTime:compare(other)
    local t1 = os.time({
        year = self.year, month = self.month, day = self.day,
        hour = self.hour, min = self.min, sec = self.sec
    })
    local t2 = os.time({
        year = other:getYear(), month = other:getMonth(), day = other:getDay(),
        hour = other:getHour(), min = other:getMin(), sec = other:getSec()
    })
    return t1 - t2
end

--- Generate an instance of DateTime, if no arguments are passed, it will return the current date and time
--- @param year number|nil
--- @param month number|nil
--- @param day number|nil
--- @param hour number|nil
--- @param min number|nil
--- @param sec number|nil
--- @return DateTime
function DateTime:datetime(year, month, day, hour, min, sec)
    if not year or not month or not day then
        return DateTime:today()
    end
    return DateTime(year, month, day, hour, min, sec)
end

_G.datetime = function(year, month, day, hour, min, sec) return DateTime:datetime(year, month, day, hour, min, sec) end
_G.dt_now = function(option) return DateTime:now(option) end
