local class = require('classes.class')
---@class Subprocess
local Subprocess = class("Subprocess")

function Subprocess:init()
    self.running_tasks = {}
    return self
end

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

--- Runs a shell command with timeout
--- @param command string The command to run
--- @param with_user_env boolean Whether to use the user's environment
--- @param timeout number? Optional timeout in seconds (default: 30)
--- @return table { success: boolean, output: string, error: string?, code: number }
function Subprocess:run(command, with_user_env, timeout)
    if not command or type(command) ~= "string" or trim(command) == "" then
        return { success = false, output = "", error = "Invalid command", code = -1 }
    end

    timeout = timeout or 30
    local result = {}
    local completed = false

    -- Setup timeout timer
    local timer = hs.timer.delayed.new(timeout, function()
        if not completed then
            completed = true
            result = {
                success = false,
                output = "",
                error = string.format("Command timed out after %d seconds", timeout),
                code = -2
            }
        end
    end)

    timer:start()
    local success, output, code = hs.execute(command, with_user_env)
    timer:stop()
    completed = true

    if result.error then -- timeout occurred
        return result
    end

    return {
        success = success,
        output = output or "",
        error = not success and "Command failed with code: " .. tostring(code) or nil,
        code = code or -1
    }
end

_G.subprocess = Subprocess
