local class = require("30log")
local lines = require("classes.lines")

---@class Path
---@field private path string
---@field private _exists boolean
---@field private _isFile boolean
---@field private _isDir boolean
---@field private _attributes table
---@field public name string
---@field public parent string
---@field public stem string
---@field public extension string
---@field public init fun(self: Path, path: string): Path
---@field public expandUser fun(self: Path): string
---@field public repr fun(self: Path): string
---@field public update fun(self: Path)
---@field public exists fun(self: Path): boolean
---@field public isFile fun(self: Path): boolean
---@field public isDir fun(self: Path): boolean
---@field public attributes fun(self: Path): table
---@field public getName fun(self: Path): string
---@field public resolve fun(self: Path): string|nil
---@field public getParent fun(self: Path): string
---@field public getStem fun(self: Path): string
---@field public getExtension fun(self: Path): string
---@field public size fun(self: Path): number|nil
---@field public Home fun(self: Path): string|nil
---@field public read_text fun(self: Path): string|nil
---@field public write_text fun(self: Path, content: string): boolean|nil
---@field public readLines fun(self: Path): Lines|nil
---@field public writeLines fun(self: Path, lines: string[]): boolean
---@field public append fun(self: Path, content: string): boolean
---@field public str fun(self: Path): string

local Path = class({ name = "Path" })

---comment
---@param path string
---@return Path
function Path:init(path)
    self.path = path
    -- check if ~ is used for home directory, if so expand it
    if path:sub(1, 1) == "~" then
        self.path = self:expandUser()
    end
    self._exists = nil
    self._isFile = nil
    self._isDir = nil
    self._attributes = {}
    self:update()
    self.name = self:getName()
    self.parent = self:getParent()
    self.stem = self:getStem()
    self.extension = self:getExtension()
    return self
end

---Expands the ~ to the home directory
---@return string
function Path:expandUser()
    local home = self:Home()
    if not home then return "" end
    local path = self.path:gsub("^~", home)
    return hs.fs.pathToAbsolute(path)
end

---Returns the string representation of the path
---@return string
function Path:repr()
    return "Path(path=" .. self.path ..", exists="..tostring(self._exists)..", isFile="..tostring(self._isFile)..", isDir="..tostring(self._isDir)..")"
end

function Path:update()
    self._exists = hs.fs.attributes(self.path) ~= nil
    self._isFile = self._exists and hs.fs.attributes(self.path, "mode") == "file"
    self._isDir = self._exists and hs.fs.attributes(self.path, "mode") == "directory"
    self._attributes = hs.fs.attributes(self.path) or {}
end

---Returns true if the path exists
---@return boolean
function Path:exists()
    local exists = hs.fs.attributes(self.path) ~= nil
    if self._exists ~= exists then
        self:update()
    end
    return self._exists
end

---Returns true if the path is a file
---@return boolean
function Path:isFile()
    local isFile = self:exists() and hs.fs.attributes(self.path, "mode") == "file"
    if self._isFile ~= isFile then
        self:update()
    end
    return self._isFile
end

--- Returns true if the path is a directory
---@return boolean
function Path:isDir()
    local isDir = self:exists() and hs.fs.attributes(self.path, "mode") == "directory"
    if self._isDir ~= isDir then
        self:update()
    end
    return self._isDir
end

---Returns the attributes of the file
---@return table
function Path:attributes()
    return self._attributes
end

---Returns the basename of the path
---@return string
function Path:getName()
    return hs.fs.displayName(self.path)
end

---Returns the absolute path of the file
---@return string | nil
function Path:resolve()
    return hs.fs.pathToAbsolute(self.path)
end

---Returns the parent directory of the path
---@return string
function Path:getParent()
    return hs.fs.pathToAbsolute(self.path .. "/..")
end

---Returns the name of the file without the extension
---@return string
function Path:getStem()
    local basename = self.name
    local parts = {}
    for part in basename:gmatch("[^%.]+") do
        table.insert(parts, part)
    end
    return table.concat(parts, ".", 1, #parts - 1)
end

---Returns the extension of the path
---@return string
function Path:getExtension()
    -- manually parse if there is an extension in the basename
    local basename = self.name
    local parts = {}
    for part in basename:gmatch("[^%.]+") do
        table.insert(parts, part)
    end
    return #parts > 1 and parts[#parts] or ""
end

---Returns the size of the file in bytes
---@return number | nil
function Path:size()
    if not self._exists then return nil end
    return self._attributes.size
end

---Returns Home Directory
---@return string | nil
function Path:Home()
    return os.getenv('HOME')
end

---Reads the file and returns the content as a string
---@return string | nil
function Path:read_text()
    if not self._exists then return nil end
    local file = io.open(self.path, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end


---Writes to the file and returns true if successful
---@param content string
---@return boolean | nil
function Path:write_text(content)
    local file = io.open(self.path, "w")
    if not file then return nil end
    file:write(content)
    file:close()
    return true
end

---Reads the file line by line and returns a table for each line
---@return Lines | nil
function Path:readLines()
    if not self._exists then return nil end
    local lines = lines.fromFile(self)
    return lines
end

---Writes to the file line by line and returns true if successful
---@param lines table<string>
---@return boolean
function Path:writeLines(lines)
    local file = io.open(self.path, "w")
    if not file then return false end
    for _, line in ipairs(lines) do
        file:write(line .. "\n")
    end
    file:close()
    return true
end

---Appends to the file and returns true if successful
---@param content string
---@return boolean
function Path:append(content)
    local file = io.open(self.path, "a")
    if not file then return false end
    file:write(content)
    file:close()
    return true
end

function Path:str()
    return self.path
end

_G.Path = Path