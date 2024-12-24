---@diagnostic disable: lowercase-global
---@class DataClass
---@field fields function
---@field to_table function
local class = require('classes.30log')

function dataclass(class_name, fields)
    print("Creating dataclass:", class_name)
    ---@class DataClass
    local NewClass = class(class_name)

    function NewClass:init(data)
        print("Init called with:", data) -- Debugging
        data = data or {}
        for field_name, field_def in pairs(fields) do
            local value = data[field_name]
            
            -- Use default if value is nil
            if value == nil and field_def.default ~= nil then
                value = field_def.default
            end
            
            -- Type checking
            if value ~= nil and type(value) ~= field_def.type then
                error("Field ${field} must be of type ${expected}, got ${actual}" % {
                    field = field_name,
                    expected = field_def.type,
                    actual = type(value)
                })
            end
            
            -- Validation if provided
            if value ~= nil and field_def.validate then
                local valid, msg = field_def.validate(value)
                if not valid then
                    error("Validation failed for ${field}: ${msg}" % {
                        field = field_name,
                        msg = msg or "invalid value"
                    })
                end
            end
            
            self[field_name] = value
        end
        return self
    end

    -- Get all field names
    function NewClass:fields()
        return fields
    end

    -- Convert to plain table
    function NewClass:to_table()
        local t = {}
        for field_name, _ in pairs(fields) do
            t[field_name] = self[field_name]
        end
        return t
    end

    -- From table (class method)
    function NewClass.from_table(t)
        return NewClass(t)
    end

    
    function NewClass:__tostring()
        local parts = {}
        for field_name, field_def in pairs(fields) do
            -- Skip fields marked as hidden
            if not field_def.hidden then
                table.insert(parts, "${field}=${value}" % {
                    field = field_name,
                    value = tostring(self[field_name])
                })
            end
        end
        return "${class_name}(${fields})" % {
            class_name = class_name,
            fields = table.concat(parts, ", ")
        }
    end

    function NewClass:__repr()
        local parts = {}
        for field_name, field_def in pairs(fields) do
            -- Skip hidden fields unless they're system fields (start with _)
            if not field_def.hidden or field_name:match("^_") then
                local value = self[field_name]
                -- More detailed formatting based on type
                if type(value) == "string" then
                    value = string.format("%q", value)
                elseif type(value) == "nil" then
                    value = "nil"
                elseif type(value) == "table" then
                    value = "table:" .. tostring(value)
                end

                table.insert(parts, "${field}<${type}>=${value}" % {
                    field = field_name,
                    type = field_def.type,
                    value = value
                })
            end
        end

        return "${class_name}{${fields}}" % {
            class_name = class_name,
            fields = table.concat(parts, ", ")
        }
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

_G.dataclass = function(...) return dataclass(...) end
