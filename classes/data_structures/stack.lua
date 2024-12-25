local Collection = require("classes.data_structures.collection")

---@class Stack : Collection
---@field data table
---@field push fun(self: Stack, value: any): Stack
---@field pop fun(self: Stack): any
---@field peek fun(self: Stack): any
---@field isEmpty fun(self: Stack): boolean
---@field size fun(self: Stack): number
---@field clear fun(self: Stack): Stack
---@field copy fun(self: Stack): Stack
---@field toList fun(self: Stack): List
local Stack = Collection:extend("Stack")

function Stack:init(...)
    Collection:init(...)
    return self
end

function Stack:push(value)
    table.insert(self.data, value)
    return self
end

function Stack:pop()
    if self:isEmpty() then return nil end
    return table.remove(self.data)
end

function Stack:peek()
    if self:isEmpty() then return nil end
    return self.data[#self.data]
end

function Stack:isEmpty()
    return #self.data == 0
end

function Stack:size()
    return #self.data
end

function Stack:clear()
    self.data = {}
    return self
end

function Stack:copy()
    local new_stack = Stack()
    for _, v in ipairs(self.data) do
        new_stack:push(v)
    end
    return new_stack
end

function Stack:toList()
    return List(self.data)
end

function Stack:getStack(...)
    return Stack(...)
end

_G.Stack = function(...) return Stack:getStack(...) end
return Stack
