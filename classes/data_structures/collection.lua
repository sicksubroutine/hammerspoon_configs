local class = require("30log")

---@class Collection
local Collection = class({name = "Collection"})

--- comment t table maintain_order boolean in the args passed
--- @param t table
--- @param maintain_order boolean|nil
--- @return Collection
function Collection:init(t, maintain_order)
    if t then
        self.data = t
    else
        self.data = {}
    end

    -- if #args == 1 and type(args[1]) == 'table' then
    --     self.data = args[1]
    -- elseif #args > 0 then
    --     self.data = args
    -- end

    self.maintain_order = maintain_order or false

    if self.maintain_order then
        self._key_order = {}
        for k in pairs(self.data) do
            table.insert(self._key_order, k)
        end
    end

    return self
end
-- Data Manipulation Methods
----------------------------
function Collection:append(value)
    table.insert(self.data, value)
    return self
end

function Collection:extend(t)
    for _, v in ipairs(t) do
        table.insert(self.data, v)
    end
    return self
end

function Collection:pop(index)
    return table.remove(self.data, index)
end

function Collection:set(key, value)
    if self.maintain_order and not self.data[key] then
        table.insert(self._key_order, key)
    end
    self.data[key] = value
    return self
end

-- Data Access Methods
----------------------
function Collection:get(key)
    return self.data[key]
end

function Collection:getData()
    return self.data
end

function Collection:len()
    local count = 0
    for _ in pairs(self.data) do count = count + 1 end
    return count
end

-- Iteration Methods
--------------------
function Collection:enumerate()
    local i = 0
    local t = self.data
    return function()
        i = i + 1
        if t[i] then
            return i, t[i]
        end
    end
end

function Collection:items()
    for k, v in pairs(self.data) do
        print(k, v)
    end
end

function Collection:values()
    for _, v in pairs(self.data) do
        print(v)
    end
end

function Collection:keys()
    for k, _ in pairs(self.data) do
        print(k)
    end
end

-- Functional Programming Methods
--------------------------------
function Collection:map(f)
    local mapped = {}
    for k, v in pairs(self.data) do
        mapped[k] = f(v)
    end
    return Collection(mapped)
end

function Collection:filter(fn)
    local filtered = {}
    for _, v in pairs(self.data) do
        if fn(v) then
            table.insert(filtered, v)
        end
    end
    return Collection(filtered)
end

function Collection:reduce(fn, initial)
    local acc = initial
    for _, v in pairs(self.data) do
        acc = fn(acc, v)
    end
    return acc
end

function Collection:any(fn)
    fn = fn or function(x) return x end
    for _, v in pairs(self.data) do
        if fn(v) then return true end
    end
    return false
end

function Collection:all(fn)
    fn = fn or function(x) return x end
    for _, v in pairs(self.data) do
        if not fn(v) then return false end
    end
    return true
end

-- Array Operation Methods
--------------------------
function Collection:range(start, stop, step)
    step = step or 1
    local t = {}
    for i = start, stop, step do
        table.insert(t, i)
    end
    return Collection(t)
end

function Collection:reversed()
    local reversed = {}
    for i = #self.data, 1, -1 do
        table.insert(reversed, self.data[i])
    end
    return Collection(reversed)
end

function Collection:sorted(fn)
    local sorted = {}
    for k, v in pairs(self.data) do
        sorted[k] = v
    end
    table.sort(sorted, fn)
    return Collection(sorted)
end

function Collection:zip(...)
    local args = {self.data, ...}
    local idx = 1
    return function()
        local values = {}
        local all_valid = true
        for _, t in ipairs(args) do
            if t[idx] == nil then
                all_valid = false
                break
            end
            table.insert(values, t[idx])
        end
        if all_valid then
            idx = idx + 1
            return table.unpack(values)
        end
    end
end

-- String and Display Methods
----------------------------
function Collection:str(s)
    return tostring(s)
end

function Collection:pp(indent_spaces)
    indent_spaces = indent_spaces or 2

    local function pp_internal(obj, depth)
        local indent = string.rep(" ", depth * indent_spaces)
        local indent_end = string.rep(" ", (depth - 1) * indent_spaces)
        
        if type(obj) ~= 'table' then
            if type(obj) == 'string' then
                return string.format('"%s"', obj)
            else
                return tostring(obj)
            end
        end

        if next(obj) == nil then
            return "{}"
        end

        local parts = {}
        local is_array = #obj > 0

        -- Use ordered keys if available, otherwise sort them
        local keys
        if self.maintain_order and obj == self.data then
            keys = self._key_order
        else
            keys = {}
            for k in pairs(obj) do
                table.insert(keys, k)
            end
            table.sort(keys, function(a, b)
                if type(a) == type(b) then
                    return a < b
                else
                    return type(a) < type(b)
                end
            end)
        end

        for _, k in ipairs(keys) do
            local v = obj[k]
            local key_str
            if is_array then
                key_str = ""
            else
                if type(k) == 'string' then
                    key_str = string.format('"%s": ', k)
                else
                    key_str = string.format('%s: ', tostring(k))
                end
            end
            table.insert(parts, string.format('%s%s%s',
                indent,
                key_str,
                pp_internal(v, depth + 1)
            ))
        end

        return string.format('{\n%s\n%s}',
            table.concat(parts, ',\n'),
            indent_end
        )
    end

    return pp_internal(self.data, 1)
end

function Collection:join(separator)
    return table.concat(self.data, separator)
end

-- Mathematical Methods
----------------------
function Collection:sum()
    return self:reduce(function(acc, v) return acc + v end, 0)
end


_G.Collection = Collection
