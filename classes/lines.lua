local class = require('classes.30log')

---A class for working with lines of strings.
---@class Lines
---@field private lines string[]
---@field public init fun(self: Lines, lines: string[]): Lines
---@field public fromFile fun(path: Path): Lines|nil
---@field public count fun(self: Lines): number
---@field public get fun(self: Lines, index: number): string
---@field public first fun(self: Lines): string
---@field public last fun(self: Lines): string
---@field public join fun(self: Lines, separator: string): string
local Lines = class({ name = "Lines" })

---Initializes the Lines class
---@param lines table<string>
---@return Lines
function Lines:init(lines)
    self.lines = lines
    return self
end

---Takes a path object and returns a new instance of the Lines class
---@param path Path
---@return Lines | nil
function Lines.fromFile(path)
    if not path:exists() or not path:isFile() then return nil end
    local content = with(File(path:str(), "r") , function(f)
        return f:read_text()
    end)
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    return Lines(lines)
end

---Returns the number of lines in the Lines class
---@return number
function Lines:count()
    return #self.lines
end

---Returns the line at the given index
---@param index number
---@return string
function Lines:get(index)
    return self.lines[index]
end

---Returns the first line
---@return string
function Lines:first()
    return self:get(1)
end

---Returns the last line
---@return string
function Lines:last()
    return self:get(self:count())
end

---Returns the lines as a string
---@param separator string
---@return string
function Lines:join(separator)
    return table.concat(self.lines, separator)
end

_G.Lines = Lines
