local Queue = require("classes.data_structures.queue")

---@class PriorityQueue : Queue
---@field private data table[] Array of {priority, value} pairs
---@field enqueue fun(self: PriorityQueue, value: any, priority: number): PriorityQueue
---@field dequeue fun(self: PriorityQueue): any
---@field front fun(self: PriorityQueue): any
---@field isEmpty fun(self: PriorityQueue): boolean
---@field size fun(self: PriorityQueue): number
---@field clear fun(self: PriorityQueue): PriorityQueue
---@field copy fun(self: PriorityQueue): PriorityQueue
---@field toList fun(self: PriorityQueue): List
local PriorityQueue = Queue:extend("PriorityQueue")

function PriorityQueue:init(...)
    Queue.init(self, ...)
    self.data = {}
    return self
end

---Helper function to get parent index
---@param idx number
---@return number
local function parent(idx)
    return math.floor(idx / 2)
end

---Helper function to get left child index
---@param idx number
---@return number
local function left(idx)
    return 2 * idx
end

---Helper function to get right child index
---@param idx number
---@return number
local function right(idx)
    return 2 * idx + 1
end

---Bubble up an element to maintain heap property
---@param idx number
function PriorityQueue:bubbleUp(idx)
    while idx > 1 and self.data[parent(idx)][1] > self.data[idx][1] do
        self.data[idx], self.data[parent(idx)] = self.data[parent(idx)], self.data[idx]
        idx = parent(idx)
    end
end

---Bubble down an element to maintain heap property
---@param idx number
function PriorityQueue:bubbleDown(idx)
    local size = #self.data
    while true do
        local smallest = idx
        local l, r = left(idx), right(idx)
        
        if l <= size and self.data[l][1] < self.data[smallest][1] then
            smallest = l
        end
        if r <= size and self.data[r][1] < self.data[smallest][1] then
            smallest = r
        end
        
        if smallest == idx then break end
        
        self.data[idx], self.data[smallest] = self.data[smallest], self.data[idx]
        idx = smallest
    end
end

---Add an item with associated priority
---@param value any
---@param priority number
---@return PriorityQueue
function PriorityQueue:enqueue(value, priority)
    table.insert(self.data, {priority, value})
    self:bubbleUp(#self.data)
    return self
end

---Remove and return highest priority item
---@return any
function PriorityQueue:dequeue()
    if self:isEmpty() then return nil end
    
    local result = self.data[1][2]
    self.data[1] = self.data[#self.data]
    table.remove(self.data)
    
    if #self.data > 0 then
        self:bubbleDown(1)
    end
    
    return result
end

---Get highest priority item without removing
---@return any
function PriorityQueue:front()
    if self:isEmpty() then return nil end
    return self.data[1][2]
end

function PriorityQueue:isEmpty()
    return #self.data == 0
end

function PriorityQueue:size()
    return #self.data
end

function PriorityQueue:clear()
    self.data = {}
    return self
end

function PriorityQueue:copy()
    local new_queue = PriorityQueue()
    for _, pair in ipairs(self.data) do
        new_queue:enqueue(pair[2], pair[1])
    end
    return new_queue
end

function PriorityQueue:toList()
    local list = {}
    for _, pair in ipairs(self.data) do
        table.insert(list, pair[2])
    end
    return List(list)
end

function PriorityQueue:getPriorityQueue(...)
    return PriorityQueue(...)
end

_G.PriorityQueue = function(...) return PriorityQueue:getPriorityQueue(...) end
return PriorityQueue