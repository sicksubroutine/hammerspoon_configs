

---@class List : Collection
local List = Collection:extend({name = "List"})

function List:init(...)
    print("List init called")
    print("Self before init:", self)
    print("Args:", ...)
    
    if not self then
        print("WARNING: self is nil")
        return nil
    end
    
    self.data = {}  -- Always ensure data is a table
    
    local args = {...}
    
    if #args == 1 and type(args[1]) == 'table' then
        self.data = args[1]
    elseif #args > 0 then
        self.data = args
    end
    
    print("Self after init:", self)
    print("Self.data after init:", self.data)
    
    return self
end


-- Additional List-specific methods
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
    return nil
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

--- Deep copy a table
--- @param orig any
--- @return any
local function deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deep_copy(orig_key)] = deep_copy(orig_value)
        end
        setmetatable(copy, deep_copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

---@class Dict : Collection
local Dict = Collection:extend({name = "Dict"})

function Dict:init(...)
    Collection:init(...)
    return self
end

-- Dict-specific methods
function Dict:update(other)
    for k, v in pairs(other) do
        self:set(k, v)
    end
    return self
end

function Dict:pop(key, default)
    local value = self.data[key]
    if value ~= nil then
        self.data[key] = nil
        if self.maintain_order then
            for i, k in ipairs(self._key_order) do
                if k == key then
                    table.remove(self._key_order, i)
                    break
                end
            end
        end
    end
    return value or default
end

function Dict:get(key, default)
    return self.data[key] or default
end

function Dict:setdefault(key, default)
    if self.data[key] == nil then
        self:set(key, default)
    end
    return self.data[key]
end

function Dict:keys()
    local keys = {}
    for k, _ in pairs(self.data) do
        table.insert(keys, k)
    end
    return List(keys)
end

function Dict:values()
    local values = {}
    for _, v in pairs(self.data) do
        table.insert(values, v)
    end
    return List(values)
end

function Dict:items()
    local items = {}
    for k, v in pairs(self.data) do
        table.insert(items, {k, v})
    end
    return List(items)
end

function Dict:copy()
    return Dict(deep_copy(self.data), self.maintain_order)
end

function Dict:clear()
    self.data = {}
    if self.maintain_order then
        self._key_order = {}
    end
    return self
end

-- ---@class Set : Collection
-- local Set = Collection:extend({name = "Set"})

-- function Set:init(...)
--     Collection:init(...)

--     local unique = {}
--     for _, v in ipairs(self.data) do
--         unique[v] = true
--     end
--     self.data = unique
--     return self
-- end

-- -- Set-specific methods
-- function Set:add(value)
--     self.data[value] = true
--     return self
-- end

-- function Set:remove(value)
--     self.data[value] = nil
--     return self
-- end

-- function Set:contains(value)
--     return self.data[value] ~= nil
-- end

-- function Set:union(other)
--     local result = self:copy()
--     for k in pairs(other.data) do
--         result:add(k)
--     end
--     return result
-- end

-- function Set:intersection(other)
--     local result = Set()
--     for k in pairs(self.data) do
--         if other:contains(k) then
--             result:add(k)
--         end
--     end
--     return result
-- end

-- function Set:difference(other)
--     local result = Set()
--     for k in pairs(self.data) do
--         if not other:contains(k) then
--             result:add(k)
--         end
--     end
--     return result
-- end

-- function Set:symmetric_difference(other)
--     local result = Set()
--     for k in pairs(self.data) do
--         if not other:contains(k) then
--             result:add(k)
--         end
--     end
--     for k in pairs(other.data) do
--         if not self:contains(k) then
--             result:add(k)
--         end
--     end
--     return result
-- end

-- function Set:issubset(other)
--     for k in pairs(self.data) do
--         if not other:contains(k) then
--             return false
--         end
--     end
--     return true
-- end

-- function Set:issuperset(other)
--     return other:issubset(self)
-- end

-- function Set:copy()
--     local new_set = Set()
--     for k in pairs(self.data) do
--         new_set:add(k)
--     end
--     return new_set
-- end

-- function Set:clear()
--     self.data = {}
--     return self
-- end

-- function Set:pop()
--     for k in pairs(self.data) do
--         self.data[k] = nil
--         return k
--     end
-- end

-- function Set:values()
--     local values = {}
--     for k in pairs(self.data) do
--         table.insert(values, k)
--     end
--     return List(values)
-- end

-- ---@class Stack : Collection
-- local Stack = Collection:extend({name = "Stack"})

-- function Stack:init(...)
--     Collection:init(...)
--     return self
-- end

-- function Stack:push(value)
--     table.insert(self.data, value)
--     return self
-- end

-- function Stack:pop()
--     return table.remove(self.data)
-- end

-- function Stack:peek()
--     return self.data[#self.data]
-- end

-- function Stack:isEmpty()
--     return #self.data == 0
-- end

-- ---@class Queue : Collection
-- local Queue = Collection:extend({name = "Queue"})

-- function Queue:init(...)
--     Collection:init(...)
--     return self
-- end

-- function Queue:enqueue(value)
--     table.insert(self.data, value)
--     return self
-- end

-- function Queue:dequeue()
--     return table.remove(self.data, 1)
-- end

-- function Queue:front()
--     return self.data[1]
-- end

-- function Queue:isEmpty()
--     return #self.data == 0
-- end

-- ---@class Deque : Collection
-- local Deque = Collection:extend({name = "Deque"})

-- function Deque:init(...)
--     Collection:init(...)
--     return self
-- end

-- function Deque:pushFront(value)
--     table.insert(self.data, 1, value)
--     return self
-- end

-- function Deque:pushBack(value)
--     table.insert(self.data, value)
--     return self
-- end

-- function Deque:popFront()
--     return table.remove(self.data, 1)
-- end

-- function Deque:popBack()
--     return table.remove(self.data)
-- end

-- function Deque:front()
--     return self.data[1]
-- end

-- function Deque:back()
--     return self.data[#self.data]
-- end

-- function Deque:isEmpty()
--     return #self.data == 0
-- end

-- ---@class OrderedDict : Dict
-- local OrderedDict = Dict:extend({name = "OrderedDict"})

-- function OrderedDict:init(...)
--     Dict.init(self, ...)
--     self.maintain_order = true
--     return self
-- end

-- _G.list = function(...) 
--     local instance = List()
--     instance.data = {}  -- Explicitly set data to an empty table
--     if select('#', ...) > 0 then
--         return instance:init(...)
--     end
--     return instance
-- end

---comment
---@param t table
---@return Dict|nil
_G.dict = function(t) 
    local instance = Dict():init(t)
    if not instance then return nil end
    return instance
end

-- _G.set = function(...) 
--     local instance = Set()
--     return instance:init(...)
-- end

-- _G.stack = function(...) 
--     local instance = Stack()
--     return instance:init(...)
-- end

-- _G.queue = function(...) 
--     local instance = Queue()
--     return instance:init(...)
-- end

-- _G.deque = function(...) 
--     local instance = Deque()
--     return instance:init(...)
-- end

-- _G.ordereddict = function(...)
--     local instance = OrderedDict()
--     return instance:init(...)
-- end
