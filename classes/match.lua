-- local class = require('classes.class')

-- ---@class Match
-- local Match = class("Match")

-- function Match:init(value)
--     self.value = value
--     self.patterns = {}
--     self.default_fn = nil
--     self.has_default = false
--     return self
-- end

-- function Match:case(pattern, fn, guard)
--     if self.has_default then
--         error("Cannot add patterns after default")
--     end
--     table.insert(self.patterns, {
--         pattern = pattern,
--         fn = fn,
--         guard = guard
--     })
--     return self
-- end

-- function Match:when(guard, fn)
--     return self:case(nil, fn, guard)
-- end

-- function Match:type(t, fn)
--     return self:case("type:" .. t, fn)
-- end

-- function Match:_(fn)
--     if self.has_default then
--         error("Default already set")
--     end
--     self.default_fn = fn
--     self.has_default = true
--     return self:e()
-- end

-- function Match:e()
--     local value = self.value
    
--     for _, case in ipairs(self.patterns) do
--         local matches = false
        
--         if case.guard and not case.guard(value) then
--             goto continue
--         end
        
--         if case.pattern == nil then
--             matches = true
--         elseif type(case.pattern) == "string" and case.pattern:match("^type:") then
--             matches = type(value) == case.pattern:sub(6)
--         elseif type(case.pattern) == "function" then
--             matches = case.pattern(value)
--         elseif type(case.pattern) == "table" then
--             matches = true
--             for k,v in pairs(case.pattern) do
--                 if value[k] ~= v then
--                     matches = false
--                     break
--                 end
--             end
--         else
--             matches = value == case.pattern
--         end
--         if matches then
--             return case.fn(value)
--         end
--         ::continue::
--     end
    
--     return self.default_fn and self.default_fn(value) or nil
-- end

-- local function match(value)
--     return Match(value)
-- end



-- local v1 = 25
-- local v2 = 100
-- local v3 =  "1000"
-- local random_number = math.random(1, 500)


-- local m = match(random_number)
--     :case(25, function() print("25") end)
--     :case(100, function() print("100") end)
--     :case("type:string", function() print("string") end)
--     :case({v1 = 25, v2 = 100}, function() print("v1 = 25, v2 = 100") end)
--     :_ (function() print("default") end)

--     print("value of random_number: ", random_number)
--     print("Value of m:", m:e())

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

-- local function run_tests()
--     local tests_run = 0
--     local tests_passed = 0
--     local failures = {}

--     local function assert_test(name, expected, got)
--         tests_run = tests_run + 1
--         if expected == got then
--             tests_passed = tests_passed + 1
--             print(string.format("✓ PASS: %s", name))
--         else
--             table.insert(failures, {
--                 name = name,
--                 expected = expected,
--                 got = got
--             })
--             print(string.format("✗ FAIL: %s\n  Expected: %s\n  Got: %s", 
--                 name, 
--                 tostring(expected), 
--                 tostring(got)))
--         end
--     end

--     print("\nRunning switch statement tests...\n")

--     -- Test 1: Should Pass - Basic matching
--     do
--         local result = switch("greet") {
--             case("greet") >> "Hello!",
--             case("quit") >> "Goodbye!",
--             default("Unknown command")
--         }
--         assert_test("Basic string matching", "Hello!", result)
--     end

--     -- Test 2: Should Fail - Wrong default expectation
--     do
--         local result = switch("invalid_command") {
--             case("greet") >> "Hello!",
--             case("quit") >> "Goodbye!",
--             default("Unknown command")
--         }
--         assert_test("Default case handling", "Wrong expectation!", result)
--     end

--     -- Test 3: Should Fail - Function returns unexpected value
--     do
--         local counter = 0
--         local result = switch("count") {
--             case("count") >> function()
--                 counter = counter + 1
--                 return counter
--             end,
--             default("No count")
--         }
--         assert_test("Counter function", 2, result)  -- Expects 2, but gets 1
--     end

--     -- Test 4: Should Pass - Number handling
--     do
--         local result = switch(1) {
--             case(1) >> "One",
--             case(2) >> "Two",
--             default("Other number")
--         }
--         assert_test("Number handling", "One", result)
--     end

--     -- Test 5: Should Fail - Type mismatch
--     do
--         local result = switch("1") {  -- String "1" not number 1
--             case(1) >> "One",
--             case(2) >> "Two",
--             default("Other number")
--         }
--         assert_test("Type matching", "One", result)  -- Expects "One" but gets "Other number"
--     end

--     -- Test 6: Should Pass - Boolean handling
--     do
--         local result = switch(true) {
--             case(true) >> "True",
--             case(false) >> "False",
--             default("Not boolean")
--         }
--         assert_test("Boolean handling", "True", result)
--     end

--     -- Test 7: Should Fail - Case order matters
--     do
--         local result = switch("greeting") {
--             case("greet") >> "Just greet",
--             case("greeting") >> "Full greeting",
--             default("No greeting")
--         }
--         assert_test("Case order", "Full greeting", result)
--     end

--     -- Print summary
--     print(string.format("\nTest Summary:"))
--     print(string.format("Tests run: %d", tests_run))
--     print(string.format("Tests passed: %d", tests_passed))
--     print(string.format("Tests failed: %d", tests_run - tests_passed))

--     if #failures > 0 then
--         print("\nFailures:")
--         for _, failure in ipairs(failures) do
--             print(string.format("\n%s:", failure.name))
--             print(string.format("  Expected: %s", tostring(failure.expected)))
--             print(string.format("  Got: %s", tostring(failure.got)))
--         end
--     end

--     return tests_passed == tests_run
-- end

-- -- Run the tests
-- local success = run_tests()
-- print(string.format("\nOverall: %s", success and "✓ PASSED" or "✗ FAILED"))