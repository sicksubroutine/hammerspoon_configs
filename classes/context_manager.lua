local class = require("classes.30log")

-- Context manager base class
local Context = class("Context")
function Context:__close()
    if self.cleanup then
        self:cleanup()
    end
end

-- Try/catch utility
local function try(f, catch_f, finally_f)
    local status, err = pcall(f)
    if not status and catch_f then
        catch_f(err)
    end
    if finally_f then
        finally_f()
    end
    return status, err
end

-- File class with context management
local File = Context:extend("File")
function File:init(filename, mode)
    self.file = io.open(filename, mode or "r")
    if not self.file then
        error("Could not open file: " .. filename)
    end
end

function File:cleanup()
    if self.file then
        print("Closing file automatically!")
        self.file:close()
    end
end

function File:read()
    return self.file:read("*a")
end

function File:write(data)
    return self.file:write(data)
end

--- timer class
--- @class Timer
local Timer = Context:extend("Timer")


function Timer:init(name)
    self.name = name or "Timer"
    self.start_time = os.clock()
end

function Timer:elapsed()
    return os.clock() - self.start_time
end

function Timer:format_elapsed()
    local elapsed = self:elapsed()
    if elapsed < 1 then
        local ms = elapsed * 1000
        return "${ms} ms" % {ms = string.format("%.2f", ms)}
    else
        return "${seconds} seconds" % {seconds = string.format("%.4f", elapsed)}
    end
end

function Timer:print()
    return "${name} took: ${time}" % {
        name = self.name, 
        time = self:format_elapsed()
    }
end

function Timer:cleanup()
    self.final_time = self:elapsed()
end

local function with(resource, func)
    local r <close> = resource
    return try(
        function() return func(r) end,
        function(err) 
            print("Error in with block:", err)
        end
    )
end

_G.with = with
_G.File = File
_G.Timer = Timer


-- Use both together:
-- try(function()
--     local f <close> = File("test.txt", "w")
--     f:write("Hello")
--     error("Something went wrong!")  -- This will be caught, but file still closes
-- end,
-- function(err)
--     print("Caught error:", err)
-- end,
-- function()
--     print("All cleaned up!")
-- end)

-- Use it:
-- with(File("test.txt", "w"), function(f)
--     f:write("Hello")
--     error("oops")  -- Error is caught, file is still closed
-- end)
