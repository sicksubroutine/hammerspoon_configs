local class = require("classes.class")

---@class TestOutput
---@field private indent number
local TestOutput = class("Test Output")

function TestOutput:init()
    self.indent = 0
    return self
end

function TestOutput:printf(fmt, ...)
    local indent_str = string.rep("  ", self.indent)
    print(string.format(indent_str .. fmt, ...))
end

function TestOutput:indent_push()
    self.indent = self.indent + 1
end

function TestOutput:indent_pop()
    self.indent = math.max(0, self.indent - 1)
end


---@class TestData
---@field name string
---@field fn function
---@field error string|nil
---@field duration number
local TestData = class("Test Data")

function TestData:init(name, fn)
    self.name = name
    self.fn = fn
    self.error = nil
    self.duration = 0
    return self
end

---@class LuaTest
---@field private _tests TestData[]
---@field private _fixtures table<string, function>
---@field private _failedTests TestData[]
---@field private _passed number
---@field private _total number
local LuaTest = class("Lua Test")

-- Class variables
LuaTest._tests = {}
LuaTest._fixtures = {}
LuaTest._failedTests = {}
LuaTest._passed = 0
LuaTest._total = 0

---@param name string
---@param fn function
function LuaTest.test(name, fn)
    table.insert(LuaTest._tests, TestData(name, fn))
end

---@param name string
---@param fn function
function LuaTest.fixture(name, fn)
    LuaTest._fixtures[name] = fn
end

---@param expected any
---@param got any
---@param message string|nil
function LuaTest.assert_equals(expected, got, message)
    if expected ~= got then
        error(string.format("%s\nExpected: %s\nGot: %s", 
            message or "Values not equal", 
            tostring(expected), 
            tostring(got)))
    end
end

---@param value any
---@param message string|nil
function LuaTest.assert_true(value, message)
    if not value then
        error(message or "Expected true, got false")
    end
end

function LuaTest.run()
    print("\nRunning tests...\n")
    local start_time = os.clock()
    
    -- Reset counters
    LuaTest._passed = 0
    LuaTest._total = #LuaTest._tests
    LuaTest._failedTests = {}
    
    -- Run fixtures first
    local fixture_values = {}
    for name, fixture_fn in pairs(LuaTest._fixtures) do
        fixture_values[name] = fixture_fn()
    end
    
    -- Run each test
    for _, test_data in ipairs(LuaTest._tests) do
        local test_start = os.clock()
        local success, error_msg = pcall(function()
            test_data.fn(fixture_values)  -- Pass fixture values to test
        end)
        test_data.duration = os.clock() - test_start
        
        if success then
            print(string.format("✓ PASS: %s (%.3fs)", test_data.name, test_data.duration))
            LuaTest._passed = LuaTest._passed + 1
        else
            test_data.error = error_msg
            table.insert(LuaTest._failedTests, test_data)
            print(string.format("✗ FAIL: %s (%.3fs)\n  %s", 
                test_data.name, 
                test_data.duration, 
                error_msg))
        end
    end

    local total_duration = os.clock() - start_time
    print(string.format("\nTest Summary:"))
    print(string.format("Total tests: %d", LuaTest._total))
    print(string.format("Passed: %d", LuaTest._passed))
    print(string.format("Failed: %d", #LuaTest._failedTests))
    print(string.format("Time: %.3f seconds", total_duration))
    
    if #LuaTest._failedTests > 0 then
        print("\nFailures:")
        for _, failed_test in ipairs(LuaTest._failedTests) do
            print(string.format("\n%s: (%.3fs)", failed_test.name, failed_test.duration))
            print(string.format("  %s", failed_test.error))
        end
    end
    
    return LuaTest._passed == LuaTest._total
end

-- -- Usage example:
-- LuaTest.fixture("test_data", function()
--     return {
--         commands = {"greet", "quit", "invalid"},
--         counter = 0
--     }
-- end)

-- LuaTest.test("basic string matching", function(fixtures)
--     local result = switch("greet") {
--         case("greet") >> "Hello!",
--         case("quit") >> "Goodbye!",
--         default("Unknown command")
--     }
--     LuaTest.assert_equals("Hello!", result)
-- end)

-- LuaTest.test("using fixtures", function(fixtures)
--     local cmd = fixtures.test_data.commands[1]
--     local result = switch(cmd) {
--         case("greet") >> "Hello!",
--         case("quit") >> "Goodbye!",
--         default("Unknown command")
--     }
--     LuaTest.assert_equals("Hello!", result)
-- end)

-- local success = LuaTest.run()
-- print(string.format("\nOverall: %s", success and "✓ PASSED" or "✗ FAILED"))

