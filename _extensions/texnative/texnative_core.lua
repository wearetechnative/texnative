-- texnative_core.lua
-- Core utility functions for texnative, exported for testing and reuse

local M = {}

-- Escape LaTeX special characters in plain text
function M.escape_latex(text)
  -- Use a placeholder for backslash to avoid double-escaping
  -- Process backslash first with a unique placeholder
  text = text:gsub('\\', '\000BACKSLASH\000')

  -- Escape other special characters (order matters for some)
  text = text:gsub('&', '\\&')
  text = text:gsub('%%', '\\%%')
  text = text:gsub('%$', '\\$')
  text = text:gsub('#', '\\#')
  text = text:gsub('_', '\\_')
  text = text:gsub('{', '\\{')
  text = text:gsub('}', '\\}')
  text = text:gsub('~', '\\textasciitilde{}')
  text = text:gsub('%^', '\\textasciicircum{}')

  -- Finally replace the placeholder with the actual backslash escape
  text = text:gsub('\000BACKSLASH\000', '\\textbackslash{}')

  return text
end

-- Convert hex color (e.g., "471d00") to RGB string (e.g., "71,29,0")
function M.hex_to_rgb(hex)
  hex = hex:gsub("^#", "") -- Remove leading # if present
  if #hex == 6 then
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if r and g and b then
      return string.format("%d,%d,%d", r, g, b)
    end
  end
  return nil
end

-- Generate LaTeX color definition or reference
-- Returns the color name to use with \cellcolor{}
-- If color_value is provided (RGB string like "255,0,0" or hex like "471d00"),
-- returns inline color definition
function M.resolve_color(color_value, default_color_name)
  if not color_value or color_value == '' then
    return default_color_name
  end

  -- Check if it's a hex color
  local rgb = color_value
  if color_value:match("^#?%x%x%x%x%x%x$") then
    rgb = M.hex_to_rgb(color_value)
  end

  -- Return inline RGB color specification
  if rgb and rgb:match("^%d+,%d+,%d+$") then
    return string.format("{RGB}{%s}", rgb)
  end

  -- Fallback to default
  return default_color_name
end

-- Render Pandoc inline elements to LaTeX, preserving rich text formatting
function M.render_inline_latex(inlines)
  local result = ''
  for _, inline in ipairs(inlines) do
    if inline.t == 'Str' then
      result = result .. M.escape_latex(inline.text)
    elseif inline.t == 'Space' then
      result = result .. ' '
    elseif inline.t == 'SoftBreak' then
      result = result .. ' '
    elseif inline.t == 'LineBreak' then
      result = result .. '\\\\'
    elseif inline.t == 'Strong' then
      result = result .. '\\textbf{' .. M.render_inline_latex(inline.content) .. '}'
    elseif inline.t == 'Emph' then
      result = result .. '\\textit{' .. M.render_inline_latex(inline.content) .. '}'
    elseif inline.t == 'Code' then
      result = result .. '\\texttt{' .. M.escape_latex(inline.text) .. '}'
    elseif inline.t == 'Link' then
      local url = inline.target
      local text = M.render_inline_latex(inline.content)
      result = result .. '\\href{' .. url .. '}{' .. text .. '}'
    elseif inline.t == 'RawInline' and inline.format == 'tex' then
      result = result .. inline.text
    else
      -- Fallback: stringify unknown elements
      result = result .. M.escape_latex(pandoc.utils.stringify(inline))
    end
  end
  return result
end

return M
