local dataclasses = require("classes.dataclasses.dataclass")
local field = dataclasses.field
local dataclass = dataclasses.dataclass

---@class Command: Dataclass
---@field name string
---@field key string
---@field action function
---@field showInMenu boolean
---@field menuTitle string
local Command = dataclass("Command", {
        name = field "string" {required = true},
        key = field "string" {required = true},
        action = field "function" {required = false, hidden = true},
        showInMenu = field "boolean" {required = false, default = false},
        menuTitle = field "string" {required = false, default = nil},
        disabled = field "boolean" {required = false, default = false}
    },
    {order=true}
)

function Command:__post_init()
    if self.showInMenu then
        self.menuTitle = self.menuTitle or self.name
    end
    hyper:registerCommand(self)
end

return Command