local class = require("classes.class")

---@class DebugTheme
---@field title string
---@field prefix string | nil
---@field mid string | nil
---@field sep string | nil
---@field data table {title: string, value: string}
---@field theme table {title: string, prefix: string, mid: string, sep: string}
DebugTheme = class("Debug Theme")

---Initializes a new DebugTheme instance
---@return DebugTheme
function DebugTheme:init(data)
  if type(data) == "table" then self:setAll(data) return self end
  self.title = "Debug"
  self.prefix = "-- "
  self.mid = ": "
  self.sep = "\n"
  self.attrColor = "\033[0;36m"
  self.valueColor = "\033[0m"
  return self
end

function DebugTheme:set(key, value)
  self[key] = value
end

function DebugTheme:setAll(data)
  for k, v in pairs(data) do
    self:set(k, v)
  end
end

---@class DebugLine
---@field title string
---@field value string
DebugLine = class("DebugLine")

function DebugLine:init(title, value)
  self.title = title
  self.value = value
  return self
end

---@class DebugTable
---@field title string
---@field prefix string
---@field mid string
---@field sep string
---@field data table {title: string, value: string}
DebugTable = class("DebugTable")

---@alias DataPair {title: string, value: string}
---@alias ThemeConfig {title: string, prefix: string, mid: string, sep: string}
---@alias DebugTableInput {theme: DebugTheme, data: DataPair[]}

---Initializes a new DebugTable instance
---@param input DebugTableInput
---@return DebugTable
function DebugTable:init(input)
  local theme, data = input.theme, input.data
  local localTheme = theme or DebugTheme()
  self.title = localTheme.title
  self.prefix = localTheme.prefix
  self.mid = localTheme.mid
  self.sep = localTheme.sep
  self.attrColor = localTheme.attrColor
  self.valueColor = localTheme.valueColor
  self.data = self:setAll(data) or {}
  return self
end
function DebugTable:setAll(data)
  temp_data = {}
  for k, v in pairs(data) do
    table.insert(temp_data, DebugLine(k, v))
  end
  return temp_data
end

function DebugTable:prettySelf()
  local str = ""
  for _, v in pairs(self.data) do
    str = "${s}${p}${t}${m}${v}${s2}" % {s=str, p=self.prefix, t=v.title, v=v.value, m=self.mid, s2=self.sep}
  end
  return str
end

function DebugTable:debugPrint()
  dPrint(self.title, self:prettySelf())
end

return {
    DebugTheme = DebugTheme,
    DebugTable = DebugTable
}