local class = require('30log')

-- Constants
local END = "\027[0m"
local BLUE = "\027[0;34m"

---@class TextWrapper
local TextWrapper = class("TextWrapper")

function TextWrapper:init(start, end_str, color)
    self.start = start
    self.end_str = end_str
    self.color = color
    return self
end

function TextWrapper.custom(start, end_str, color)
    return TextWrapper(start, end_str, color)
end

---@class Theme
local Theme = class("Theme")

function Theme:init(name, color, wrapper, wrapper_color, theme_set)
    self.name = name
    self.color = color
    self.wrapper = wrapper
    self.wrapper_color = wrapper_color
    self.theme_set = theme_set
    self:post_init()
    return self
end

function Theme:post_init()
    if not self.wrapper and not self.theme_set then
        return
    end
    if self.wrapper and not self.theme_set then
        self.wrapper_color = self.wrapper.color
        return
    end
    self.wrapper = self.wrapper or self.theme_set.wrapper
    self.wrapper_color = self.wrapper_color or self.theme_set.color
    if self.wrapper then
        self.wrapper.color = self.wrapper_color
    end
end

---@class ThemeSet
local ThemeSet = class("ThemeSet")

function ThemeSet:init(wrapper, color)
    self.wrapper = wrapper
    self.color = color
    return self
end

---@class ThemeHolder
local ThemeHolder = class("ThemeHolder")

function ThemeHolder:init()
    self.themes = {}
    self.styles = {}
    self.wrapper = nil
    return self
end

function ThemeHolder:add(theme)
    self.themes[theme.name] = theme
    self:_parse_style(theme.name, theme)
end

function ThemeHolder:_parse_style(name, theme)
    if theme.wrapper then
        self.styles[name] = {
            color = theme.wrapper.color,
            start = theme.wrapper.start,
            ["end"] = theme.wrapper.end_str,
            inner = {name .. "_inner", theme.color}
        }
    elseif self.wrapper then
        self.styles[name] = {
            color = self.wrapper.color,
            start = self.wrapper.start,
            ["end"] = self.wrapper.end_str,
            inner = {name .. "_inner", theme.color}
        }
    else
        self.styles[name] = {
            color = theme.color,
            start = "",
            ["end"] = ""
        }
    end
end

---@class MethodFactory
local MethodFactory = class("MethodFactory")

function MethodFactory:init(color, name, opening_text, closing_text, inner_method)
    self.color = color
    self.name = name or ""
    self.opening_text = opening_text or ""
    self.closing_text = closing_text or ""
    self.inner_method = inner_method
    return self
end

function MethodFactory:__call(text)
    local content = tostring(text)
    if self.inner_method then
        content = self.inner_method(content)
    end

    if self.opening_text ~= "" and self.closing_text ~= "" then
        return string.format("%s%s%s%s%s%s%s", 
            self.color, self.opening_text, END, 
            content, 
            self.color, self.closing_text, END)
    end
    return string.format("%s%s%s", self.color, content, END)
end

---@class ColorBuilder
local ColorBuilder = class("ColorBuilder")

function ColorBuilder:init(default_method)
    self.default_method = default_method
    self.result = ""
    self.last_pos = 1  -- Lua strings start at 1
    self.methods = {}
    return self
end

function ColorBuilder:add_method(name, method)
    self.methods[name] = method
end

function ColorBuilder:_handle_default_text(text, start, end_pos)
    if end_pos > start then
        local segment = text:sub(start, end_pos - 1)
        self.result = self.result .. self.default_method(segment)
    end
end

function ColorBuilder:_handle_tag(method_name, content)
    local method = self.methods[method_name] or self.default_method
    self.result = self.result .. method(content)
end

function ColorBuilder:build(text)
    self.result = ""
    self.last_pos = 1

    -- Lua pattern for matching [tag]content[/tag]
    for tag, content, end_pos in text:gmatch("()%[(%w+)%](.-]%[/%1%])()") do
        self:_handle_default_text(text, self.last_pos, tag)
        self:_handle_tag(content:match("^(.-)%["), content:match("^(.-)%["))
        self.last_pos = end_pos
    end

    self:_handle_default_text(text, self.last_pos, #text + 1)
    return self.result
end

---@class ColorText
local ColorText = class("ColorText")

function ColorText:init(default, theme)
    self.default_method = MethodFactory(default or BLUE)
    self.builder = ColorBuilder(self.default_method)
    if theme then
        self:apply_theme(theme)
    end
    return self
end

function ColorText:apply_theme(theme)
    for name, style in pairs(theme.styles) do
        local inner_method = nil
        if style.inner then
            local inner_name, inner_color = table.unpack(style.inner)
            inner_method = MethodFactory(inner_color, inner_name)
        end

        local method = MethodFactory(
            style.color,
            name,
            style.start or "",
            style["end"] or "",
            inner_method
        )
        self.builder:add_method(name, method)
    end
end

function ColorText:print(text, end_str)
    end_str = end_str or "\n"
    local result = self.builder:build(text)
    io.write(result .. end_str)
end

-- Predefined TextWrappers
local SQUARE = TextWrapper("[", "]")
local CURLY = TextWrapper("{", "}")
local ANGLE = TextWrapper("<", ">")
local PAREN = TextWrapper("(", ")")

return {
    TextWrapper = TextWrapper,
    Theme = Theme,
    ThemeSet = ThemeSet,
    ThemeHolder = ThemeHolder,
    ColorText = ColorText,
    SQUARE = SQUARE,
    CURLY = CURLY,
    ANGLE = ANGLE,
    PAREN = PAREN,
    END = END,
    BLUE = BLUE
}
