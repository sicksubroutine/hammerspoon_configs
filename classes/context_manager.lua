local class = require("classes.30log")

---@class Context
---@field private cleanup fun(self: Context): nil
---@field private __close fun(self: Context): nil
---@field public extend fun(self: Context, name: string): Context
local Context = class("Context")


function Context:__close()
    if self.cleanup then
        self:cleanup()
    end
end

--- Cleanup Metamethod
--- This metamethod is called when the object is garbage collected
function Context:cleanup()
    -- Override this method to cleanup resources
end



---@class File : Context
---@field private file file*|nil
---@field public init fun(self: File, filename: string, mode: string|nil): File
---@field public cleanup fun(self: File): nil
---@field public read fun(self: File, content:string): string
---@field public write fun(self: File, data: string)
local File = Context:extend("File")
function File:init(filename, mode)
    self.file = io.open(filename, mode or "r")
    if not self.file then
        error("Could not open file: " .. filename)
    end
    return self
end

---@override -- THIS IS PYTHON-ISH AND I WILL DECORATE IF I WANT TO! 😤
--- Cleanup the file resources
---@return nil
function File:cleanup()
    if self.file then
        --print("Closing file automatically!")
        self.file:close()
    end
end

--- Read a file and return the contents
---@return string
function File:read(content)
    return self.file:read(content)
end

--- Write data to a file
--- @param data string
function File:write(data)
    return self.file:write(data)
end


--[[ Timer Class ]]--
---@class Timer : Context
---@field private name string
---@field private start_time number
---@field private final_time number
---@field public init fun(self: Timer, name: string|nil): Timer
---@field public elapsed fun(self: Timer): number
---@field public format_elapsed fun(self: Timer): string
---@field public print fun(self: Timer): string
---@field public cleanup fun(self: Timer): nil
local Timer = Context:extend("Timer")

function Timer:init(name)
    self.name = name or "Timer"
    self.start_time = os.clock()
    return self
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

---@override
--- Cleanup the timer resources
---@return nil
function Timer:cleanup()
    self.final_time = self:elapsed()
end

-- ---@alias T { __close: function } -- This is a type alias for a table with a __close method
-- ---@param resource T
-- ---@param func function
-- ---@return boolean, any
-- local function with(resource, func)
--     local r <close> = resource
--     return try(
--         function() return func(r) end,
--         function(err) 
--             print("Error in with block:", err)
--         end
--     )
-- end

---@param f fun(): boolean, any
---@param catch_f fun(err: string)|nil
---@param finally_f fun()|nil
---@return boolean, any
local function try(f, catch_f, finally_f)
    local status, result = pcall(f)
    if not status and catch_f then
        catch_f(result)
    end
    if finally_f then
        finally_f()
    end
    return status, result
end

---@alias T { __close: function } -- This is a type alias for a table with a __close method
---@param resource T
---@param func function
---@return any
local function with(resource, func)
    local r <close> = resource
    local status, result = try(
        function() return func(r) end,
        function(err) 
            print("Error in with block:", err)
        end
    )
    if status then
        return result
    end
    return nil
end

_G.with = with
_G.File = File
_G.Timer = Timer


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

-- with(File("test.txt", "w"), function(f)
--     f:write("Hello")
--     error("oops")  -- Error is caught, file is still closed
-- end)
