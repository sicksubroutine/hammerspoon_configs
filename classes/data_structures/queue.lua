local Collection = require("classes.data_structures.collection")

---@class Queue : Collection
---@field data table
---@field enqueue fun(self: Queue, value: any): Queue
---@field dequeue fun(self: Queue): any
---@field front fun(self: Queue): any
---@field isEmpty fun(self: Queue): boolean
---@field size fun(self: Queue): number
---@field clear fun(self: Queue): Queue
---@field copy fun(self: Queue): Queue
---@field toList fun(self: Queue): List
local Queue = Collection:extend("Queue")

function Queue:init(...)
    Collection:init(...)
    return self
end

function Queue:enqueue(value)
    table.insert(self.data, value)
    return self
end

function Queue:dequeue()
    if self:isEmpty() then return nil end
    return table.remove(self.data, 1)
end

function Queue:front()
    if self:isEmpty() then return nil end
    return self.data[1]
end

function Queue:isEmpty()
    return #self.data == 0
end

function Queue:size()
    return #self.data
end

function Queue:clear()
    self.data = {}
    return self
end

function Queue:copy()
    local new_queue = Queue()
    for _, v in ipairs(self.data) do
        new_queue:enqueue(v)
    end
    return new_queue
end

function Queue:toList()
    return List(self.data)
end

function Queue:getQueue(...)
    return Queue(...)
end

_G.Queue = function(...) return Queue:getQueue(...) end
return Queue
