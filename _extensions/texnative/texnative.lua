
-- FILTERS/DATE-FORMAT.LUA
function Meta(meta)
  if meta.date then
    local format = "(%d+)-(%d+)-(%d+)"
    local y, m, d = pandoc.utils.stringify(meta.date):match(format)
    local date = os.time({
      year = y,
      month = m,
      day = d,
    })
    local date_string = os.date("%d %b %Y", date)

    meta.date = pandoc.Str(date_string)
    return meta
  end
end

-- Escape LaTeX special characters in plain text
local function escape_latex(text)
  local replacements = {
    ['\\'] = '\\textbackslash{}',
    ['&'] = '\\&',
    ['%%'] = '\\%%',
    ['%$'] = '\\$',
    ['#'] = '\\#',
    ['_'] = '\\_',
    ['{'] = '\\{',
    ['}'] = '\\}',
    ['~'] = '\\textasciitilde{}',
    ['%^'] = '\\textasciicircum{}',
  }
  for char, replacement in pairs(replacements) do
    text = text:gsub(char, replacement)
  end
  return text
end

-- Render Pandoc inline elements to LaTeX, preserving rich text formatting
local function render_inline_latex(inlines)
  local result = ''
  for _, inline in ipairs(inlines) do
    if inline.t == 'Str' then
      result = result .. escape_latex(inline.text)
    elseif inline.t == 'Space' then
      result = result .. ' '
    elseif inline.t == 'SoftBreak' then
      result = result .. ' '
    elseif inline.t == 'LineBreak' then
      result = result .. '\\\\'
    elseif inline.t == 'Strong' then
      result = result .. '\\textbf{' .. render_inline_latex(inline.content) .. '}'
    elseif inline.t == 'Emph' then
      result = result .. '\\textit{' .. render_inline_latex(inline.content) .. '}'
    elseif inline.t == 'Code' then
      result = result .. '\\texttt{' .. escape_latex(inline.text) .. '}'
    elseif inline.t == 'Link' then
      local url = inline.target
      local text = render_inline_latex(inline.content)
      result = result .. '\\href{' .. url .. '}{' .. text .. '}'
    elseif inline.t == 'RawInline' and inline.format == 'tex' then
      result = result .. inline.text
    else
      -- Fallback: stringify unknown elements
      result = result .. escape_latex(pandoc.utils.stringify(inline))
    end
  end
  return result
end

-- Render cell contents (which may be blocks containing inlines)
local function render_cell_contents(contents)
  local result = ''
  for _, block in ipairs(contents) do
    if block.t == 'Plain' or block.t == 'Para' then
      result = result .. render_inline_latex(block.content)
    else
      -- Fallback for other block types
      result = result .. escape_latex(pandoc.utils.stringify(block))
    end
  end
  return result
end

local function get_rows_data(rows, cell_color, strong)

  local latex_cell_color = ''
  local strong_begin = ''
  local strong_end = ''

  if(cell_color ~='') then
    latex_cell_color = '\\cellcolor{'..cell_color..'}'
  end
  if(strong) then
    strong_begin = "\\bf{"
    strong_end = "}"
  end
  local data = ''
  for _, row in ipairs(rows) do

    for k, cell in ipairs(row.cells) do
      local cell_content = render_cell_contents(cell.contents)
      data = data .. latex_cell_color .. strong_begin .. cell_content .. strong_end
      if (k == #row.cells) then
        data = data .. ' \\\\ \n'
      else
        data = data .. ' & '
      end
    end
    data = data ..'\n \\hline \n'

  end
  return data
end


local function generate_tabularray(tbl)

  local caption_raw = pandoc.utils.stringify(tbl.caption.long)
  local caption_content = caption_raw:match("{(.-)}")
  local caption_text = caption_raw:gsub("%s*{.-}%s*", ""):match("^%s*(.-)%s*$") -- Remove property block and trim

  -- Parse caption properties into dict
  local dict = {}
  if caption_content then
    for key, value in string.gmatch(caption_content, '([#%w%-]+)=?([^%s]*)') do
      if key:match("^#") then
        dict['label'] = key:sub(2) -- Remove leading #
      else
        dict[key] = value
      end
    end
  end

  -- Parse tbl-colwidths if present
  local col_widths = {}
  if dict['tbl-colwidths'] then
    local widths_str = dict['tbl-colwidths']:match('%[(.-)%]')
    if widths_str then
      for w in string.gmatch(widths_str, '([%d%.]+)') do
        table.insert(col_widths, tonumber(w))
      end
    end
  end

  -- COLSPECS
  local col_specs = tbl.colspecs
  local col_specs_latex = '| '

  for i, col_spec in ipairs(col_specs) do
    local align = col_spec[1]
    local width = col_spec[2]

    -- Check if we have explicit width from tbl-colwidths
    local has_explicit_width = col_widths[i] ~= nil

    if has_explicit_width then
      -- Use proportional width with p{} specifier
      local width_fraction = col_widths[i] / 100
      col_specs_latex = col_specs_latex .. 'p{' .. string.format('%.2f', width_fraction) .. '\\linewidth} |'
    elseif width and width > 0 then
      -- Use width from colspecs if available
      col_specs_latex = col_specs_latex .. 'p{' .. string.format('%.2f', width) .. '\\linewidth} |'
    else
      -- Fall back to simple alignment specifiers
      if align == 'AlignLeft' then
        col_specs_latex = col_specs_latex .. 'l |'
      elseif align == 'AlignRight' then
        col_specs_latex = col_specs_latex .. 'r |'
      else
        col_specs_latex = col_specs_latex .. 'c |'
      end
    end
  end

  -- Determine if we need a table environment (for caption/label)
  local has_caption = caption_text and caption_text ~= ''
  local has_label = dict['label'] ~= nil
  local use_table_env = has_caption or has_label

  local result = pandoc.List:new{}

  if use_table_env then
    result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\begin{table}[htbp]\n\\centering')}
    if has_caption then
      result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\caption{' .. caption_text .. '}')}
    end
    if has_label then
      result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\label{' .. dict['label'] .. '}')}
    end
  end

  result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\renewcommand{\\arraystretch}{1.5}\n\\begin{tabular}{ '.. col_specs_latex .. ' } \n \\hline')}

  -- HEADER
  local header_latex = get_rows_data(tbl.head.rows, 'tableheadercolor', false)
  result = result .. pandoc.List:new{pandoc.RawBlock("latex", header_latex)}

  -- ROWS
  local rows_latex = ''
  for _, tablebody in ipairs(tbl.bodies) do
    rows_latex = get_rows_data(tablebody.body, '', false)
  end
  result = result .. pandoc.List:new{pandoc.RawBlock("latex", rows_latex)}

  -- FOOTER
  local footer_latex = get_rows_data(tbl.foot.rows, '', false)
  result = result .. pandoc.List:new{pandoc.RawBlock("latex", footer_latex)}

  result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\end{tabular}')}

  if use_table_env then
    result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\end{table}')}
  end

  return result
end

if FORMAT:match 'latex' then

  function Table (tbl)
    return generate_tabularray(tbl)
  end

end
