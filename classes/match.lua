local class = require('classes.class')
local Switch = class("Switch")

-- Class Variables
Switch._value = nil
Switch._cases = {}


function Switch:init(value)
    self._value = value
    return setmetatable(self, {
        __call = function(_, cases)
            for _, c in ipairs(cases) do
                if c.pattern == "_" or c.pattern == self._value then
                    return c.fn()
                end
            end
        end
    })
end

local function case(pattern)
    return setmetatable({pattern = pattern}, {
        __shr = function(self, result)  -- >> operator
            if type(result) == "string" then
                self.fn = function() return result end
            else
                self.fn = result
            end
            return self
        end
    })
end

---Helper function to set the default case, can be simple or complex
---@param result string | function
---@return any
local function default(result)
    return case("_") >> result
end

local function switch(value)
    return Switch(value)
end

_G.switch = switch
_G.case = case
_G._d = default

return Switch
