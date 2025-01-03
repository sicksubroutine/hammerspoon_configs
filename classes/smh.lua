local class = require("classes.class")


---@class SymbolWrapper
local SymbolWrapper = class("SymbolWrapper")

SymbolWrapper.metamethod_map = {
    ["+"] = "__add",
    ["-"] = "__sub",
    ["*"] = "__mul",
    ["/"] = "__div",
    ["%"] = "__mod",
    ["^"] = "__pow",
    [".."] = "__concat",
    ["#"] = "__len",
    ["=="] = "__eq",
    ["<"] = "__lt",
    ["<="] = "__le",
    ["&"] = "__band",
    ["|"] = "__bor",
    ["~"] = "__bxor",
    ["<<"] = "__shl",
    [">>"] = "__shr"
}

function SymbolWrapper.mapContains(symbol)
    return hs.fnutils.contains(SymbolWrapper.metamethod_map, symbol)
end

function SymbolWrapper:__init(symbol)
    if type(symbol) ~= "string" then
        error("Symbol must be a string")
    end
    if #symbol ~= 1 then
        error("Symbol must be a single character")
    end
    if not self.mapContains(symbol) then
        error("Symbol is not a valid metamethod")
    end
    self.symbol = symbol
    self.oldMetaTable = getmetatable("")
    return self
end

-- getmetatable("").__mod = interp

function SymbolWrapper:overrideOn(func)
    if type(func) ~= "function" then
        error("Metamethod must be a function")
    end
    getmetatable("").__shl = func
end

function SymbolWrapper:overrideOff()
    local old_value = self.oldMetaTable[self:convertSymbol()]
    getmetatable("").__shl = old_value
end

function SymbolWrapper:convertSymbol()
    return SymbolWrapper.metamethod_map[self.symbol]
end

return SymbolWrapper
