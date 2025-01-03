---@diagnostic disable: lowercase-global

local class = require('classes.class')

local fieldDefs = require('classes.dataclasses.field')
local field = fieldDefs.field
local FieldDefinition = fieldDefs.FieldDefinition

---@class DataClassOptions
---@field frozen boolean Prevent modification after creation
---@field slots boolean Only allow defined fields
---@field order boolean Preserve field order
---@field eq boolean Enable equality comparison
---@field repr boolean Enable string representation

function createDataclass(class_name, fields, options)
    options = options or {}
    local field_order = {}

    if options.order then
        for field_name, _ in pairs(fields) do
            table.insert(field_order, field_name)
        end
    else
        for field_name, _ in pairs(fields) do
            table.insert(field_order, field_name)
        end
        table.sort(field_order)
    end

    ---@class Dataclass:Class
    ---@field _fields table<string, FieldDefinition>
    ---@field _field_order string[]
    ---@field _options DataClassOptions
    local Dataclass = class(class_name)

    Dataclass.__fields = fields
    Dataclass.__field_order = field_order
    Dataclass.__options = options

    ---@param self Dataclass
    ---@param data table
    ---@return Dataclass
    function Dataclass:init(data)
        if type(data) ~= "table" and data ~= nil then
            error("Data must be a table or nil")
        end
        if Dataclass.__fields == nil then
            error("DataClass requires _fields to be defined")
        end
        if Dataclass.__field_order == nil then
            error("DataClass requires _field_order to be defined")
        end

        data = data or {}

        self._fields = fields
        self._field_order = field_order
        self._options = options
        local instance_fields = {}

        for _, field_name in ipairs(self._field_order) do
            local field_def = self._fields[field_name]
            local value = data[field_name]

            if value == nil and field_def.default ~= nil then
                value = field_def.default_factory and field_def.default() or field_def.default
            end

            if value == nil and field_def.required then
                error(string.format("Required field '%s' missing", field_name))
            end

            if value ~= nil then
                if type(value) ~= field_def.type then
                    error(string.format(
                        "Field '%s' must be %s, got %s",
                        field_name, field_def.type, type(value)
                    ))
                end

                if field_def.validator then
                    local valid, msg = field_def.validator(value)
                    if not valid then
                        error(string.format(
                            "Validation failed for '%s': %s",
                            field_name, msg or "invalid value"
                        ))
                    end
                end
            end
            instance_fields[field_name] = value
        end

    local currentMT = getmetatable(self)
    local currentIndex = currentMT.__index

    local function indexLookup(t, k)
        if instance_fields[k] then
            return instance_fields[k]
        end
        if currentIndex[k] then
            return currentIndex[k]
        end
        return nil
    end

    local newMT = {
        __index = indexLookup,
        __newindex = function(t, k, v)
            if not fields[k] then
                error(string.format(
                    "Cannot add new field '%s' to %s instance",
                    k, class_name
                ))
            end
            instance_fields[k] = v
        end
    }

    for k, v in pairs(currentMT) do
        if k ~= "__index" and k ~= "__newindex" then
            newMT[k] = v
        end
    end

    setmetatable(self, newMT)
        self:__post_init()
        return self
    end

    function Dataclass.__post_init() print("Please override this method") end

    function Dataclass:to_table()
        local t = {}
        local field_order = self._field_order or {}
        for _, field_name in ipairs(field_order) do
            t[field_name] = self[field_name]
        end
        return t
    end

    function Dataclass:__tostring()
        local parts = {}
        local field_order = self.__field_order or {}
        local fields =  self.__fields or {}

        for _, field_name in ipairs(field_order) do
            local field_def = fields[field_name]
            if not field_def.hidden then
                local value = self[field_name]
                table.insert(parts, string.format(
                    "%s=%s",
                    field_name,
                    tostring(value)
                ))
            end
        end
        return string.format(
            "%s(%s)",
            self._className,  -- Use class's class name
            table.concat(parts, ", ")
        )
    end

    if options.eq ~= false then
        function Dataclass:__eq(other)
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
    end
    return Dataclass
end

function dataclass(class_name, fields, options)
    return createDataclass(class_name, fields, options)
end

-- ---@class Person: Dataclass
-- local Person = dataclass("Person", {
--     name = field "string" {required = true},
--     age = field "number" {required = true},
--     email = field "string" {required = false, hidden = true}
-- }, {order=true})

-- function Person:__post_init()
--     print("Overriding the post init method")
-- end

-- local bob = Person({name = "Bob", age = 30, email = "bob@bob.com"})

-- print(bob)

return {
    dataclass = dataclass,
    field = field
}

