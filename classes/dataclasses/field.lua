local class = require("classes.class")

---@class FieldDefinition
---@field type string
---@field default any
---@field required boolean
---@field validator function|nil
---@field hidden boolean
---@field default_factory boolean
---@field to_table fun(self: FieldDefinition): table
---@field validate fun(self: FieldDefinition, fn: function): FieldDefinition
---@field default fun(self: FieldDefinition, value: any): FieldDefinition
---@field set_required fun(self: FieldDefinition, required: boolean): FieldDefinition
---@field set_hidden fun(self: FieldDefinition, hidden: boolean): FieldDefinition
local FieldDefinition = class("FieldDefinition")

function FieldDefinition:init(type_name)
    self.type = type_name
    self.required = false
    self.hidden = false
    self.default = nil
    self.default_factory = false
    self.validator = nil
    return self
end

function FieldDefinition:to_table()
    return {
        type = self.type,
        required = self.required,
        hidden = self.hidden,
        default = self.default,
        default_factory = self.default_factory,
        validator = self.validator
    }
end

function FieldDefinition:validate(fn)
    self.validator = fn
    return self
end

function FieldDefinition:default(value)
    self.default_factory = type(value) == "function"
    self.default = value
    self.required = false
    return self
end

function FieldDefinition:set_required(required)
    self.required = required
    return self
end

function FieldDefinition:set_hidden(hidden)
    self.hidden = hidden
    return self
end

local function apply_options(field_def, opts)
    if type(opts) ~= "table" then
        return field_def
    end

    for k, v in pairs(opts) do
        if k == "required" then
            field_def:set_required(v)
        elseif k == "hidden" then
            field_def:set_hidden(v)
        elseif k == "default" then
            field_def:default(v)
        elseif k == "validator" then
            field_def:validate(v)
        end
    end

    return field_def
end

local function create_field_definition(type_name)
    local field_def = FieldDefinition(type_name)
    local original_mt = getmetatable(field_def)
    
    setmetatable(field_def, {
        __index = original_mt.__index,
        __call = function(t, opts)
            apply_options(t, opts)
            return t:to_table()
        end
    })
    
    return field_def
end

local function field(type_name)
    return create_field_definition(type_name)
end

return {
    field = field,
    FieldDefinition = FieldDefinition
}
