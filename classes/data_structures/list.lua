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
---@field filter fun(self: List, fn: fun(value: any): boolean): List
---@field remove fun(self: List, index: number): any
---@field extend fun(self: List, other: List|table): List
---@field copy fun(self: List): List
---@field reverse fun(self: List): List
---@field sort fun(self: List, comp?: fun(a: any, b: any): boolean): List
---@field contains fun(self: List, value: any): boolean
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

---Remove element at index
---@param self List
---@param index number
---@return any removed value
function List:remove(index)
    return table.remove(self.data, index)
end

---Extend list with elements from another list/table
---@param self List
---@param other List|table
---@return List self
function List:extend(other)
    local to_add = other
    if getmetatable(other) == List then
        to_add = other.data
    end
    for _, v in ipairs(to_add) do
        table.insert(self.data, v)
    end
    return self
end

---Create a shallow copy of the list
---@param self List
---@return List new list
function List:copy()
    local copied = {}
    for i, v in ipairs(self.data) do
        copied[i] = v
    end
    return List(copied)
end

---Reverse the list in place
---@param self List
---@return List self
function List:reverse()
    local left, right = 1, #self.data
    while left < right do
        self.data[left], self.data[right] = self.data[right], self.data[left]
        left = left + 1
        right = right - 1
    end
    return self
end

---Sort the list in place
---@param self List
---@param comp? fun(a: any, b: any): boolean comparison function
---@return List self
function List:sort(comp)
    table.sort(self.data, comp)
    return self
end

---Check if list contains value
---@param self List
---@param value any
---@return boolean
function List:contains(value)
    return self:index(value) ~= -1
end

function List:getList(...)
    return List(...)
end

_G.List = function(...) return List:getList(...) end
return List
