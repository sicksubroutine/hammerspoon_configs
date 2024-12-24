---@diagnostic disable: param-type-mismatch
local Collection = require("classes.data_structures.collection")

---@class DictInstance : CollectionInstance
---@field update fun(self: DictInstance, other: table): DictInstance
---@field pop fun(self: DictInstance, key: any, default?: any): any
---@field get fun(self: DictInstance, key: any, default?: any): any
---@field setdefault fun(self: DictInstance, key: any, default: any): any
---@field keys fun(self: DictInstance): CollectionInstance
---@field values fun(self: DictInstance): CollectionInstance
---@field items fun(self: DictInstance): CollectionInstance
---@field clear fun(self: DictInstance): DictInstance

---@class Dict : Collection
---@field private data table
---@field private maintain_order boolean
---@field public new fun(self: Dict, t?: table): DictInstance
---@field public getDict fun(self, table): Dict
---@field public update fun(self: Dict, other: table): Dict
local Dict = Collection:extend("Dict")

--- Initialize a new Dict instance
---@param t table
---@return Dict
function Dict:init(t)
---@diagnostic disable-next-line: param-type-mismatch
    Dict.super.init(self, t)
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
    return keys
end

function Dict:values()
    local values = {}
    for _, v in pairs(self.data) do
        table.insert(values, v)
    end
    return values
end

function Dict:items()
    local items = {}
    for k, v in pairs(self.data) do
        items[k] = v
    end
    return items
end

-- function Dict:copy()
--     return Dict(deep_copy(self.data), self.maintain_order)
-- end

function Dict:clear()
    self.data = {}
    if self.maintain_order then
        self._key_order = {}
    end
    return self
end

function Dict:getDict(table)
    return Dict(table)
end

function Dict:__pairs()
    return pairs(self.data)
end

function Dict:__name()
    return "Dict"
end

_G.Dict = function(...) return Dict:getDict(...) end
