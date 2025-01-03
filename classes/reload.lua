-- reload.lua
local class = require('classes.class')
---@class Reload
local Reload = class("Reload")

function Reload:init()
    self.files = nil
    self.doReload = false
    print("-- Reload initialized")
    return self
end

function Reload:start()
    print("-- Reload Start initialized")
    hs.pathwatcher.new(HammerspoonPath, function(files)
        --- @type string[] files
        self:setterFiles(files)
        self:reloadConfig()
    end):start()
end

--- Setter for files
---@param files string[] List of files that have changed
function Reload:setterFiles(files)
    self.files = files
end

function Reload:reloadConfig()
    for _, file in pairs(self.files) do
        if file:sub(-4) == ".lua" then
            self.doReload = true
            break
        end
    end
    if self.doReload then
        hs.reload()
    end
    self.doReload = false
end

return Reload
