
local Collection = require("classes.data_structures.collection")

---@class List : Collection
---@field data table
---@field maintain_order boolean
---@field first fun(self: List): any
---@field last fun(self: List): any
---@field slice fun(self: List, start: number, stop: number): List
---@field insert fun(self: List, index: number, value: any): List
---@field index fun(self: List, value: any): number
---@field count fun(self: List, value: any): number
---@field clear fun(self: List): List
---@field map fun(self: List, f: fun(value: any): any): List
local List = Collection:extend("List")
function List:init(...)
    self.super.init(...)
    return self
end

function List:first()
    return self.data[1]
end

function List:last()
    return self.data[#self.data]
end

function List:slice(start, stop)
    start = start or 1
    stop = stop or #self.data
    local sliced = {}
    for i = start, stop do
        table.insert(sliced, self.data[i])
    end
    return List(sliced)
end

function List:insert(index, value)
    table.insert(self.data, index, value)
    return self
end

function List:index(value)
    for i, v in ipairs(self.data) do
        if v == value then
            return i
        end
    end
    return -1
end

function List:count(value)
    local count = 0
    for _, v in ipairs(self.data) do
        if v == value then
            count = count + 1
        end
    end
    return count
end

function List:clear()
    self.data = {}
    if self.maintain_order then
        self._key_order = {}
    end
    return self
end

-- Override some methods to ensure list-like behavior
function List:map(f)
    local mapped = {}
    for i, v in ipairs(self.data) do
        mapped[i] = f(v)
    end
    return List(mapped)
end

function List:filter(fn)
    local filtered = {}
    for _, v in ipairs(self.data) do
        if fn(v) then
            table.insert(filtered, v)
        end
    end
    return List(filtered)
end
