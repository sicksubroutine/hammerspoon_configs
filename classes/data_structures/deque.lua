local Collection = require("classes.data_structures.collection")

---@class Deque : Collection
---@field data table
---@field pushFront fun(self: Deque, value: any): Deque
---@field pushBack fun(self: Deque, value: any): Deque
---@field popFront fun(self: Deque): any
---@field popBack fun(self: Deque): any
---@field front fun(self: Deque): any
---@field back fun(self: Deque): any
---@field isEmpty fun(self: Deque): boolean
---@field size fun(self: Deque): number
---@field clear fun(self: Deque): Deque
---@field copy fun(self: Deque): Deque
---@field toList fun(self: Deque): List
local Deque = Collection:extend("Deque")

function Deque:init(...)
    Collection:init(...)
    return self
end

function Deque:pushFront(value)
    table.insert(self.data, 1, value)
    return self
end

function Deque:pushBack(value)
    table.insert(self.data, value)
    return self
end

function Deque:popFront()
    if self:isEmpty() then return nil end
    return table.remove(self.data, 1)
end

function Deque:popBack()
    if self:isEmpty() then return nil end
    return table.remove(self.data)
end

function Deque:front()
    if self:isEmpty() then return nil end
    return self.data[1]
end

function Deque:back()
    if self:isEmpty() then return nil end
    return self.data[#self.data]
end

function Deque:isEmpty()
    return #self.data == 0
end

function Deque:size()
    return #self.data
end

function Deque:clear()
    self.data = {}
    return self
end

function Deque:copy()
    local new_deque = Deque()
    for _, v in ipairs(self.data) do
        new_deque:pushBack(v)
    end
    return new_deque
end

function Deque:toList()
    return List(self.data)
end

function Deque:getDeque(...)
    return Deque(...)
end

_G.Deque = function(...) return Deque:getDeque(...) end
return Deque
