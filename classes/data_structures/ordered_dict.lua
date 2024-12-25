local Dict = require("classes.data_structures.dictionary")

---@class OrderedDict : Dict
---@field data table
---@field private _key_order table
---@field move_to_front fun(self: OrderedDict, key: any): OrderedDict
---@field move_to_end fun(self: OrderedDict, key: any): OrderedDict
---@field popitem fun(self: OrderedDict, last?: boolean): table
---@field first_key fun(self: OrderedDict): any
---@field last_key fun(self: OrderedDict): any
---@field get_by_index fun(self: OrderedDict, index: number): any
---@field set_by_index fun(self: OrderedDict, index: number, value: any): OrderedDict
---@field reverse fun(self: OrderedDict): OrderedDict
---@field copy fun(self: OrderedDict): OrderedDict
local OrderedDict = Dict:extend("OrderedDict")

function OrderedDict:init(...)
    Dict.init(self, ...)
    self.maintain_order = true
    self._key_order = self._key_order or {}
    return self
end

function OrderedDict:move_to_front(key)
    if not self.data[key] then return self end
    for i, k in ipairs(self._key_order) do
        if k == key then
            table.remove(self._key_order, i)
            table.insert(self._key_order, 1, key)
            break
        end
    end
    return self
end

function OrderedDict:move_to_end(key)
    if not self.data[key] then return self end
    for i, k in ipairs(self._key_order) do
        if k == key then
            table.remove(self._key_order, i)
            table.insert(self._key_order, key)
            break
        end
    end
    return self
end

function OrderedDict:popitem(last)
    if #self._key_order == 0 then return nil end
    local idx = last and #self._key_order or 1
    local key = self._key_order[idx]
    local value = self.data[key]
    self.data[key] = nil
    table.remove(self._key_order, idx)
    return {key, value}
end

function OrderedDict:first_key()
    return self._key_order[1]
end

function OrderedDict:last_key()
    return self._key_order[#self._key_order]
end

function OrderedDict:get_by_index(index)
    local key = self._key_order[index]
    return key and self.data[key] or nil
end

function OrderedDict:set_by_index(index, value)
    local key = self._key_order[index]
    if key then
        self.data[key] = value
    end
    return self
end

function OrderedDict:reverse()
    local left, right = 1, #self._key_order
    while left < right do
        self._key_order[left], self._key_order[right] = 
            self._key_order[right], self._key_order[left]
        left = left + 1
        right = right - 1
    end
    return self
end

function OrderedDict:copy()
    local new_dict = OrderedDict(self.data)
    new_dict._key_order = table.move(self._key_order, 1, #self._key_order, 1, {})
    return new_dict
end

function OrderedDict:getOrderedDict(...)
    return OrderedDict(...)
end

_G.OrderedDict = function(...) return OrderedDict:getOrderedDict(...) end
return OrderedDict
