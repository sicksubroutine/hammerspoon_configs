---@diagnostic disable: lowercase-global
local class = require("30log")

function dataclass(class_name, fields)
    print("Creating dataclass:", class_name)
    ---@class DataClass
    local NewClass = class({name = class_name})

    function NewClass:init(data)
        print("Init called with:", data) -- Debugging
        data = data or {}
        for field_name, field_def in pairs(fields) do
            local value = data[field_name]
            
            -- Type checking
            if value ~= nil and type(value) ~= field_def.type then
                error(string.format("Field %s must be of type %s, got %s", 
                    field_name, field_def.type, type(value)))
            end
            
            self[field_name] = value
        end
        return self
    end

    
    function NewClass:__tostring()
        local parts = {}
        for field_name, _ in pairs(fields) do
            table.insert(parts, string.format("%s=%s", 
                field_name, tostring(self[field_name])))
        end
        return string.format("%s(%s)", class_name, table.concat(parts, ", "))
    end

    function NewClass:__repr()
        local parts = {}
        for field_name, field_def in pairs(fields) do
            local value = self[field_name]
            -- More detailed formatting based on type
            if type(value) == "string" then
                value = string.format("%q", value)  -- Adds quotes
            elseif type(value) == "nil" then
                value = "nil"
            elseif type(value) == "table" then
                value = "table:" .. tostring(value)
            end
            table.insert(parts, string.format("%s<%s>=%s", 
                field_name,
                field_def.type,  -- Show the field's type
                tostring(value)))
        end
        return string.format("%s{%s}", class_name, table.concat(parts, ", "))
    end

    function NewClass:__eq(other)
        if getmetatable(other) ~= getmetatable(self) then
            return false
        end
        for field_name, _ in pairs(fields) do
            if self[field_name] ~= other[field_name] then
                return false
            end
        end
        return true
    end

    function NewClass:__lt(other)
        -- Example implementation - compare by first field
        local first_field = next(fields)
        return self[first_field] < other[first_field]
    end

    function NewClass:__le(other)
        return self < other or self == other
    end

    function NewClass:__add(other)
        -- Example: merge fields from both instances
        local new_data = {}
        for field_name, _ in pairs(fields) do
            new_data[field_name] = self[field_name]
        end
        for field_name, _ in pairs(fields) do
            if other[field_name] ~= nil then
                new_data[field_name] = other[field_name]
            end
        end
        return NewClass(new_data)
    end

    function NewClass:__len()
        local count = 0
        for _ in pairs(fields) do
            count = count + 1
        end
        return count
    end

    -- Python's __newindex (called when setting new fields)
    function NewClass:__newindex(key, value)
        if fields[key] then
            rawset(self, key, value)
        else
            error(string.format("Cannot add new field '%s' to %s instance", 
                key, class_name))
        end
    end

    return NewClass
end

_G.dataclass = dataclass


-- local Person = dataclass("Person", {
--     name = {type = "string"},
--     age = {type = "number"},
--     email = {type = "string"}
-- })

-- local person1 = Person():init({name = "Alice", age = 30, email = "alice@diagnostic.com"})
-- local person2 = Person():init({name = "Alice", age = 30, email = "alice@diagnostic.com"})

-- -- __tostring
-- print("\n__tostring test:")
-- print("person1:", person1)
-- print("person2:", person2)

-- -- __repr
-- print("\n__repr test:")
-- print("person1 repr:", person1:__repr())
-- print("person2 repr:", person2:__repr())

-- -- __eq
-- print("\n__eq tests:")
-- print("person1 == person2:", person1 == person2)
-- local person3 = Person():init({name = "Alice", age = 30, email = "alice@diagnostic.com"})
-- print("person1 == person3 (should be true):", person1 == person3)

-- -- __lt
-- print("\n__lt test:")
-- print("person1 < person2:", person1 < person2)

-- -- __le
-- print("\n__le tests:")
-- print("person1 <= person2:", person1 <= person2)
-- print("person1 <= person3:", person1 <= person3)

-- -- __add
-- print("\n__add test:")
-- print("person1 + person2:", person1 + person2)

-- -- __len
-- print("\n__len test:")
-- print("Length of person1 (#person1):", #person1)
