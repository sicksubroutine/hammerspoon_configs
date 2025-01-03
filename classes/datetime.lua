local class = require('classes.class')

---@class DateTime
---@field private year number|string
---@field private month number|string
---@field private day number|string
---@field private hour number|string
---@field private minute number|string
---@field private second number|string
---@field private isDst boolean
---@field public init fun(self: DateTime, year: number, month: number, day: number, hour: number, min: number|nil, sec: number, isDst:boolean): DateTime
---@field public now fun(): DateTime
---@field public fromTimestamp fun(timestamp: number): DateTime
---@field public strftime fun(self: DateTime, format: string): string|osdate
---@field public compare fun(self: DateTime, other: DateTime): number
local DateTime = class("DateTime")

-- Class constants
DateTime.MIN_YEAR = 1970
DateTime.MAX_YEAR = 9999

-- Format constants
DateTime.ISO_FORMAT = "%Y-%m-%dT%H:%M:%S"
DateTime.DATE_FORMAT = "%Y-%m-%d"
DateTime.TIME_FORMAT = "%H:%M:%S"

function DateTime.now()
    local t = os.date("*t")
    return DateTime(t.year, t.month, t.day, t.hour, t.min, t.sec, t.isdst)
end

function DateTime.fromTimestamp(timestamp)
    local t = os.date("*t", timestamp)
    return DateTime(t.year, t.month, t.day, t.hour, t.min, t.sec, t.isdst)
end

function DateTime.insertTable(t)
    return DateTime(t.year, t.month, t.day, t.hour, t.min, t.sec, t.isdst)
end

function DateTime:init(year, month, day, hour, min, sec, isDst)
    assert(year >= DateTime.MIN_YEAR and year <= DateTime.MAX_YEAR, "Year out of range")
    self.year = year
    self.month = month
    self.day = day
    self.hour = hour or 0
    self.minute = min or 0
    self.second = sec or 0
    self.isDst = isDst or false
    return self
end

function DateTime:returnTable()
    return {
        year = self.year,
        month = self.month,
        day = self.day,
        hour = self.hour,
        min = self.minute,
        sec = self.second,
        isdst = self.isDst
    }
end

function DateTime:isoFormat()
    return self:strftime(DateTime.ISO_FORMAT)
end

function DateTime:strftime(format)
    return os.date(format, self:toTimestamp())
end

--- Convert DateTime to timestamp
---@return integer
function DateTime:toTimestamp()
    return os.time(self:returnTable())
end

--- Compare two DateTime objects
--- @param other DateTime
--- @return number
function DateTime:compare(other)
    return DateTime:toTimestamp() - other:toTimestamp()
end

function DateTime:__tostring()
    return self:isoFormat()
end

function DateTime:setFormats(full, date, time)
    DateTime.ISO_FORMAT = full
    DateTime.DATE_FORMAT = date
    DateTime.TIME_FORMAT = time
end

function DateTime:updateNow()
    local t = os.date("*t")
    self.year = t.year
    self.month = t.month
    self.day = t.day
    self.hour = t.hour
    self.minute = t.min
    self.second = t.sec
    self.isDst = t.isdst
end

_G.dt_now = function(option) return DateTime.now() end

_G.DateTime = DateTime
