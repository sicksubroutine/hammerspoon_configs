local class = require("30log")

---@class JsonHelp
---@field private json_path Path
---@field private data table|nil
---@field public init fun(self: JsonHelp, json_path: Path): JsonHelp
---@field public setData fun(self: JsonHelp, data: table|nil)
---@field public getData fun(self: JsonHelp): table|nil
---@field public get fun(self: JsonHelp, key, default:any|nil): string
---@field public getString fun(self: JsonHelp, key: string, default:any|nil): string
---@field public read fun(self: JsonHelp): table|nil
---@field public write fun(self: JsonHelp, prettyprint: boolean|nil): boolean
---@field public loads fun(self: JsonHelp, json_string: string): table|nil
---@field public dumps fun(self: JsonHelp, data: table|nil, prettyprint: boolean): string
---@field public json fun(self: JsonHelp, path: Path): table|nil
---@field public getInstance fun(self: JsonHelp, path: Path): JsonHelp|nil
local JsonHelp = class({ name = "JsonHelp" })

--- Initializes the JsonHelp class
---@param json_path Path
---@return JsonHelp
function JsonHelp:init(json_path)
    self.json_path = json_path
    self.data = self:read()
    return self
end

---Sets the data
---@param data table|nil
function JsonHelp:setData(data)
    if not data then return end
    self.data = data
end

---Returns the data
---@return table
function JsonHelp:getData()
    return self.data
end

---Returns the value of the key
---@param key string
---@param default any|nil
---@return string|nil
function JsonHelp:get(key, default)
    if not self.data or not self.data[key] then return default end
    return self.data[key]
end

---Returns the value of a key as a string
---@param key string
---@param default any|nil
---@return string|nil
function JsonHelp:getString(key, default)
    if not self.data or not self.data[key] then return tostring(default) end
    return tostring(self.data[key])
end

---Reads the file and returns the content as a table
---@return table | nil
function JsonHelp:read()
    if not self.json_path:exists() or not self.json_path:isFile() then return nil end
    local text = self.json_path:read_text()
    local json_output = hs.json.decode(text)
    if not json_output then return nil end
    return json_output
end

---Writes the data to the file
---@param prettyprint boolean|nil
---@return boolean
function JsonHelp:write(prettyprint)
    if not prettyprint then prettyprint = false end
    local text = hs.json.encode(self.data, prettyprint)
    if not text then return false end
    self.json_path:write_text(text)
    return true
end

---Converts the json string to a table
---@param json_string string
---@return nil
function JsonHelp:loads(json_string)
    local data = hs.json.decode(json_string)
    return data
end

---Converts the data to a json string, prettyprint is optional
---@param data table|nil
---@param prettyprint boolean
---@return string
function JsonHelp:dumps(data, prettyprint)
    if not data then return "{}" end
    if not prettyprint then prettyprint = false end
    return hs.json.encode(data, prettyprint)
end

--- Returns a table from a json file
--- @param path Path
--- @return table | nil
function JsonHelp:json(path)
    local instance = JsonHelp():init(path)
    local data = instance:getData()
    return data
end

--- Returns a JsonHelp object
--- @param path Path
--- @return JsonHelp | nil
function JsonHelp:getInstance(path)
    local instance = JsonHelp():init(path)
    if not instance then return nil end
    return instance
end

_G.json = function(path) return JsonHelp:json(path) end
_G.jsonI = function(path) return JsonHelp:getInstance(path) end
