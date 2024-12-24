local class = require('classes.30log')

---@class Match
local Match = class("Match")

function Match:init(value)
    self.value = value
    self.patterns = {}
    self.default_fn = nil
    self.has_default = false
    return self
end

function Match:case(pattern, fn, guard)
    if self.has_default then
        error("Cannot add patterns after default")
    end
    table.insert(self.patterns, {
        pattern = pattern,
        fn = fn,
        guard = guard
    })
    return self
end

function Match:when(guard, fn)
    return self:case(nil, fn, guard)
end

function Match:type(t, fn)
    return self:case("type:" .. t, fn)
end

function Match:_(fn)
    if self.has_default then
        error("Default already set")
    end
    self.default_fn = fn
    self.has_default = true
    return self:e()
end

function Match:e()
    local value = self.value
    
    for _, case in ipairs(self.patterns) do
        local matches = false
        
        if case.guard and not case.guard(value) then
            goto continue
        end
        
        if case.pattern == nil then
            matches = true
        elseif type(case.pattern) == "string" and case.pattern:match("^type:") then
            matches = type(value) == case.pattern:sub(6)
        elseif type(case.pattern) == "function" then
            matches = case.pattern(value)
        elseif type(case.pattern) == "table" then
            matches = true
            for k,v in pairs(case.pattern) do
                if value[k] ~= v then
                    matches = false
                    break
                end
            end
        else
            matches = value == case.pattern
        end
        if matches then
            return case.fn(value)
        end
        ::continue::
    end
    
    return self.default_fn and self.default_fn(value) or nil
end

local function match(value)
    return Match(value)
end



local v1 = 25
local v2 = 100
local v3 =  "1000"
local random_number = math.random(1, 500)


local m = match(random_number)
    :case(25, function() print("25") end)
    :case(100, function() print("100") end)
    :case("type:string", function() print("string") end)
    :case({v1 = 25, v2 = 100}, function() print("v1 = 25, v2 = 100") end)
    :_ (function() print("default") end)

    print("value of random_number: ", random_number)
    print("Value of m:", m:e())