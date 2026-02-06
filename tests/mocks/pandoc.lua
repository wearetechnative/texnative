-- Mock Pandoc module for unit testing texnative_core.lua
-- This module provides minimal stubs for Pandoc API functions used by the filter

local pandoc = {}

-- pandoc.utils module
pandoc.utils = {}

-- Stringify: converts any Pandoc element to plain string
-- For testing, just return the value if it's already a string,
-- or convert common test structures
function pandoc.utils.stringify(element)
  if type(element) == "string" then
    return element
  end
  if type(element) == "table" then
    -- Handle Str element
    if element.t == "Str" then
      return element.text
    end
    -- Handle elements with text field
    if element.text then
      return element.text
    end
    -- Handle elements with content (like Strong, Emph)
    if element.content then
      local result = ""
      for _, item in ipairs(element.content) do
        result = result .. pandoc.utils.stringify(item)
      end
      return result
    end
    -- Handle list of inlines
    if #element > 0 then
      local result = ""
      for _, item in ipairs(element) do
        result = result .. pandoc.utils.stringify(item)
      end
      return result
    end
  end
  return tostring(element)
end

-- Pandoc element constructors
function pandoc.Str(text)
  return { t = "Str", text = text }
end

function pandoc.Space()
  return { t = "Space" }
end

function pandoc.SoftBreak()
  return { t = "SoftBreak" }
end

function pandoc.LineBreak()
  return { t = "LineBreak" }
end

function pandoc.Strong(content)
  if type(content) == "string" then
    content = { pandoc.Str(content) }
  end
  return { t = "Strong", content = content }
end

function pandoc.Emph(content)
  if type(content) == "string" then
    content = { pandoc.Str(content) }
  end
  return { t = "Emph", content = content }
end

function pandoc.Code(text, attr)
  return { t = "Code", text = text, attr = attr or {} }
end

function pandoc.Link(content, target, title, attr)
  if type(content) == "string" then
    content = { pandoc.Str(content) }
  end
  return { 
    t = "Link", 
    content = content, 
    target = target,
    title = title or "",
    attr = attr or {}
  }
end

function pandoc.RawInline(format, text)
  return { t = "RawInline", format = format, text = text }
end

function pandoc.RawBlock(format, text)
  return { t = "RawBlock", format = format, text = text }
end

function pandoc.Plain(content)
  if type(content) == "string" then
    content = { pandoc.Str(content) }
  end
  return { t = "Plain", content = content }
end

function pandoc.Para(content)
  if type(content) == "string" then
    content = { pandoc.Str(content) }
  end
  return { t = "Para", content = content }
end

-- List helper with concat operation
pandoc.List = {}
pandoc.List.__index = pandoc.List

function pandoc.List:new(items)
  local list = setmetatable({}, pandoc.List)
  if items then
    for _, item in ipairs(items) do
      table.insert(list, item)
    end
  end
  return list
end

function pandoc.List:__concat(other)
  local result = pandoc.List:new()
  for _, item in ipairs(self) do
    table.insert(result, item)
  end
  if type(other) == "table" then
    for _, item in ipairs(other) do
      table.insert(result, item)
    end
  end
  return result
end

setmetatable(pandoc.List, {
  __call = function(cls, items)
    return cls:new(items)
  end
})

return pandoc
