local class = require("30log")

local full_date_format = "%m-%d-%Y %I:%M:%S %p"
local date_only_format = "%m-%d-%Y"
local time_only_format = "%I:%M:%S %p"

---@class DateTime
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

--- Compare two DateTime objects
--- @param other DateTime
--- @return number
function DateTime:compare(other)
    local t1 = os.time({
        year = self.year, month = self.month, day = self.day,
        hour = self.hour, min = self.min, sec = self.sec
    })
    local t2 = os.time({
        year = other.year, month = other.month, day = other.day,
        hour = other.hour, min = other.min, sec = other.sec
    })
    return t1 - t2
end

return DateTime
