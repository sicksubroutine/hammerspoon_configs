
-- -- ---@class Set : Collection
-- -- local Set = Collection:extend("Set")

-- -- function Set:init(...)
-- --     Collection:init(...)

-- --     local unique = {}
-- --     for _, v in ipairs(self.data) do
-- --         unique[v] = true
-- --     end
-- --     self.data = unique
-- --     return self
-- -- end

-- -- -- Set-specific methods
-- -- function Set:add(value)
-- --     self.data[value] = true
-- --     return self
-- -- end

-- -- function Set:remove(value)
-- --     self.data[value] = nil
-- --     return self
-- -- end

-- -- function Set:contains(value)
-- --     return self.data[value] ~= nil
-- -- end

-- -- function Set:union(other)
-- --     local result = self:copy()
-- --     for k in pairs(other.data) do
-- --         result:add(k)
-- --     end
-- --     return result
-- -- end

-- -- function Set:intersection(other)
-- --     local result = Set()
-- --     for k in pairs(self.data) do
-- --         if other:contains(k) then
-- --             result:add(k)
-- --         end
-- --     end
-- --     return result
-- -- end

-- -- function Set:difference(other)
-- --     local result = Set()
-- --     for k in pairs(self.data) do
-- --         if not other:contains(k) then
-- --             result:add(k)
-- --         end
-- --     end
-- --     return result
-- -- end

-- -- function Set:symmetric_difference(other)
-- --     local result = Set()
-- --     for k in pairs(self.data) do
-- --         if not other:contains(k) then
-- --             result:add(k)
-- --         end
-- --     end
-- --     for k in pairs(other.data) do
-- --         if not self:contains(k) then
-- --             result:add(k)
-- --         end
-- --     end
-- --     return result
-- -- end

-- -- function Set:issubset(other)
-- --     for k in pairs(self.data) do
-- --         if not other:contains(k) then
-- --             return false
-- --         end
-- --     end
-- --     return true
-- -- end

-- -- function Set:issuperset(other)
-- --     return other:issubset(self)
-- -- end

-- -- function Set:copy()
-- --     local new_set = Set()
-- --     for k in pairs(self.data) do
-- --         new_set:add(k)
-- --     end
-- --     return new_set
-- -- end

-- -- function Set:clear()
-- --     self.data = {}
-- --     return self
-- -- end

-- -- function Set:pop()
-- --     for k in pairs(self.data) do
-- --         self.data[k] = nil
-- --         return k
-- --     end
-- -- end

-- -- function Set:values()
-- --     local values = {}
-- --     for k in pairs(self.data) do
-- --         table.insert(values, k)
-- --     end
-- --     return List(values)
-- -- end

-- -- ---@class Stack : Collection
-- -- local Stack = Collection:extend("Stack")

-- -- function Stack:init(...)
-- --     Collection:init(...)
-- --     return self
-- -- end

-- -- function Stack:push(value)
-- --     table.insert(self.data, value)
-- --     return self
-- -- end

-- -- function Stack:pop()
-- --     return table.remove(self.data)
-- -- end

-- -- function Stack:peek()
-- --     return self.data[#self.data]
-- -- end

-- -- function Stack:isEmpty()
-- --     return #self.data == 0
-- -- end

-- -- ---@class Queue : Collection
-- -- local Queue = Collection:extend("Queue")

-- -- function Queue:init(...)
-- --     Collection:init(...)
-- --     return self
-- -- end

-- -- function Queue:enqueue(value)
-- --     table.insert(self.data, value)
-- --     return self
-- -- end

-- -- function Queue:dequeue()
-- --     return table.remove(self.data, 1)
-- -- end

-- -- function Queue:front()
-- --     return self.data[1]
-- -- end

-- -- function Queue:isEmpty()
-- --     return #self.data == 0
-- -- end

-- -- ---@class Deque : Collection
-- -- local Deque = Collection:extend("Deque")

-- -- function Deque:init(...)
-- --     Collection:init(...)
-- --     return self
-- -- end

-- -- function Deque:pushFront(value)
-- --     table.insert(self.data, 1, value)
-- --     return self
-- -- end

-- -- function Deque:pushBack(value)
-- --     table.insert(self.data, value)
-- --     return self
-- -- end

-- -- function Deque:popFront()
-- --     return table.remove(self.data, 1)
-- -- end

-- -- function Deque:popBack()
-- --     return table.remove(self.data)
-- -- end

-- -- function Deque:front()
-- --     return self.data[1]
-- -- end

-- -- function Deque:back()
-- --     return self.data[#self.data]
-- -- end

-- -- function Deque:isEmpty()
-- --     return #self.data == 0
-- -- end

-- -- ---@class OrderedDict : Dict
-- -- local OrderedDict = Dict:extend("OrderedDict")

-- -- function OrderedDict:init(...)
-- --     Dict.init(self, ...)
-- --     self.maintain_order = true
-- --     return self
-- -- end

-- -- _G.list = function(...) 
-- --     local instance = List()
-- --     instance.data = {}  -- Explicitly set data to an empty table
-- --     if select('#', ...) > 0 then
-- --         return instance:init(...)
-- --     end
-- --     return instance
-- -- end

-- ---comment
-- ---@param t table
-- ---@return Dict|nil
-- _G.dict = function(t) 
--     local instance = Dict():init(t)
--     if not instance then return nil end
--     return instance
-- end

-- -- _G.set = function(...) 
-- --     local instance = Set()
-- --     return instance:init(...)
-- -- end

-- -- _G.stack = function(...) 
-- --     local instance = Stack()
-- --     return instance:init(...)
-- -- end

-- -- _G.queue = function(...) 
-- --     local instance = Queue()
-- --     return instance:init(...)
-- -- end

-- -- _G.deque = function(...) 
-- --     local instance = Deque()
-- --     return instance:init(...)
-- -- end

-- -- _G.ordereddict = function(...)
-- --     local instance = OrderedDict()
-- --     return instance:init(...)
-- -- end
