local class = require('classes.30log')

---@class JsonHelp
---@field private json_path Path
---@field private data table|nil
---@field private name string|nil
---@field public init fun(self: JsonHelp, json_path: Path, name: string|nil): JsonHelp
---@field public getInstance fun(self: JsonHelp, path: Path, name: string): JsonHelp|nil
---@field public instanceGetter fun(self: JsonHelp, path: Path, name: string): JsonHelp|nil
---@field public pretty fun(self: JsonHelp, sep: string|nil): string
---@field public setData fun(self: JsonHelp, data: table|nil)
---@field public getData fun(self: JsonHelp): table|nil
---@field public get fun(self: JsonHelp, key, default:any|nil): string
---@field public getStr fun(self: JsonHelp, key: string, default:any|nil): string
---@field public read fun(self: JsonHelp): table|nil
---@field public write fun(self: JsonHelp, prettyprint: boolean|nil): boolean
---@field public loads fun(self: JsonHelp, json_string: string): table|nil
---@field public dumps fun(self: JsonHelp, data: table|nil, prettyprint: boolean): string
---@field public json fun(self: JsonHelp, path: Path): table|nil
local JsonHelp = class({ name = "JsonHelp" })

---Initialize JsonHelp instance
---@param json_path Path
---@param name string|nil
---@return JsonHelp
function JsonHelp:init(json_path, name)
    self.json_path = json_path
    self.data = self:read()
    self.name = name
    return self
end

--- Set the value of a key
--- @param key string
--- @param value any
function JsonHelp:set(key, value)
    self.data:set(key, value)
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
    return self.data:getAll()
end

---Returns the value of the key
---@param key string
---@param default any|nil
---@return string|nil
function JsonHelp:get(key, default)
    local data = self.data:get(key, default)
    return data
end

---Returns the value of a key as a string
---@param key string
---@param default any|nil
---@return string|nil
function JsonHelp:getStr(key, default)
    if not self.data or not self.data[key] then return tostring(default) end
    return tostring(self.data[key])
end

---Returns a pretty version of the self.data done in a specific format
---@param sep string|nil -- the separator, default is "\n"
---@return string
function JsonHelp:pretty(sep)
    if not sep then sep = "\n" end
    local prettyStr = "-- ${name}(" % {name = self.name}
    local count = 0
    local total = self.data:len()
    for k, v in pairs(self.data:items()) do
        count = count + 1
        prettyStr = '${prettyStr}"${k}": ${v}' % {prettyStr=prettyStr, k=k, v=v}
        if count < total then
            prettyStr = prettyStr .. sep
        end
    end
    prettyStr = prettyStr .. ")"
    return prettyStr
end

---Reads the file and returns the content as a table
---@return DictInstance
function JsonHelp:read()
    if not self.json_path:exists() or not self.json_path:isFile() then return nil end
    local text = self.json_path:read_text()
    local json_output = hs.json.decode(text)
    local json_dict = Dict(json_output)
    if not json_dict then return nil end
    return json_dict
end

---Writes the data to the file
---@param prettyprint boolean|nil
---@return boolean
function JsonHelp:write(prettyprint)
    if not prettyprint then prettyprint = false end
    local text = hs.json.encode(self.data:getAll(), prettyprint)
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
    local instance = JsonHelp(path)
    local data = instance:getData()
    return data
end

--- Returns a JsonHelp object
--- @param path Path
--- @param name string| nil
--- @return JsonHelp | nil
function JsonHelp:instanceGetter(path, name)
    if not name then name = "Json" end
    local instance = JsonHelp(path, name)
    if not instance then return nil end
    return instance
end

_G.json = function(...) return JsonHelp:json(...) end
_G.jsonI = function(...) return JsonHelp:instanceGetter(...) end
