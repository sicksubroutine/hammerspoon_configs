local Collection = require("classes.data_structures.collection")

---@class Set : Collection
---@field data table<any, boolean>
---@field add fun(self: Set, value: any): Set
---@field remove fun(self: Set, value: any): Set
---@field contains fun(self: Set, value: any): boolean
---@field union fun(self: Set, other: Set): Set
---@field intersection fun(self: Set, other: Set): Set
---@field difference fun(self: Set, other: Set): Set
---@field symmetric_difference fun(self: Set, other: Set): Set
---@field issubset fun(self: Set, other: Set): boolean
---@field issuperset fun(self: Set, other: Set): boolean
---@field copy fun(self: Set): Set
---@field clear fun(self: Set): Set
---@field pop fun(self: Set): any
---@field values fun(self: Set): List
local Set = Collection:extend("Set")

function Set:init(...)
    Collection:init(...)
    -- Convert input table to set structure
    local unique = {}
    for _, v in ipairs(self.data) do
        unique[v] = true
    end
    self.data = unique
    return self
end

function Set:add(value)
    self.data[value] = true
    return self
end

function Set:remove(value)
    self.data[value] = nil
    return self
end

function Set:contains(value)
    return self.data[value] ~= nil
end

function Set:union(other)
    local result = self:copy()
    for k in pairs(other.data) do
        result:add(k)
    end
    return result
end

function Set:intersection(other)
    local result = Set()
    for k in pairs(self.data) do
        if other:contains(k) then
            result:add(k)
        end
    end
    return result
end

function Set:difference(other)
    local result = Set()
    for k in pairs(self.data) do
        if not other:contains(k) then
            result:add(k)
        end
    end
    return result
end

function Set:symmetric_difference(other)
    local result = Set()
    for k in pairs(self.data) do
        if not other:contains(k) then
            result:add(k)
        end
    end
    for k in pairs(other.data) do
        if not self:contains(k) then
            result:add(k)
        end
    end
    return result
end

function Set:issubset(other)
    for k in pairs(self.data) do
        if not other:contains(k) then
            return false
        end
    end
    return true
end

function Set:issuperset(other)
    return other:issubset(self)
end

function Set:copy()
    local new_set = Set()
    for k in pairs(self.data) do
        new_set:add(k)
    end
    return new_set
end

function Set:clear()
    self.data = {}
    return self
end

function Set:pop()
    for k in pairs(self.data) do
        self.data[k] = nil
        return k
    end
end

function Set:values()
    local values = {}
    for k in pairs(self.data) do
        table.insert(values, k)
    end
    return List(values)
end

function Set:getSet(...)
    return Set(...)
end

_G.Set = function(...) return Set:getSet(...) end
return Set
