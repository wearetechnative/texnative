
-- Module-level variables for document metadata
local doc_meta = {
  table_header_color = nil,
  table_body_color = nil,
  table_header_txtcolor = nil,
  table_body_txtcolor = nil,
  table_border_color = nil,
  table_border_width = nil,
  table_cell_padding = nil,
  table_alignment = nil,
  dark_background = false
}

-- FILTERS/DATE-FORMAT.LUA
function Meta(meta)
  -- Store table color settings from document metadata
  if meta['table-header-bgcolor'] then
    doc_meta.table_header_color = pandoc.utils.stringify(meta['table-header-bgcolor'])
  end
  if meta['table-body-bgcolor'] then
    doc_meta.table_body_color = pandoc.utils.stringify(meta['table-body-bgcolor'])
  end
  if meta['table-header-txtcolor'] then
    doc_meta.table_header_txtcolor = pandoc.utils.stringify(meta['table-header-txtcolor'])
  end
  if meta['table-body-txtcolor'] then
    doc_meta.table_body_txtcolor = pandoc.utils.stringify(meta['table-body-txtcolor'])
  end
  if meta['table-border-color'] then
    doc_meta.table_border_color = pandoc.utils.stringify(meta['table-border-color'])
  end
  if meta['table-border-width'] then
    doc_meta.table_border_width = pandoc.utils.stringify(meta['table-border-width'])
  end
  if meta['table-cell-padding'] then
    doc_meta.table_cell_padding = pandoc.utils.stringify(meta['table-cell-padding'])
  end
  if meta['table-alignment'] then
    doc_meta.table_alignment = pandoc.utils.stringify(meta['table-alignment'])
  end
  if meta['dark_background'] then
    doc_meta.dark_background = meta['dark_background'] == true or pandoc.utils.stringify(meta['dark_background']) == 'true'
  end

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

-- Convert hex color (e.g., "471d00") to RGB string (e.g., "71,29,0")
local function hex_to_rgb(hex)
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
local function resolve_color(color_value, default_color_name)
  if not color_value or color_value == '' then
    return default_color_name
  end
  
  -- Check if it's a hex color
  local rgb = color_value
  if color_value:match("^#?%x%x%x%x%x%x$") then
    rgb = hex_to_rgb(color_value)
  end
  
  -- Return inline RGB color specification
  if rgb and rgb:match("^%d+,%d+,%d+$") then
    return string.format("{RGB}{%s}", rgb)
  end
  
  -- Fallback to default
  return default_color_name
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

-- Render a bullet list to LaTeX
local function render_bullet_list(list)
  local result = '\\begin{itemize}[nosep,leftmargin=*]\n'
  for _, item in ipairs(list.content) do
    result = result .. '\\item '
    -- Each item is a list of blocks
    for j, block in ipairs(item) do
      if block.t == 'Plain' or block.t == 'Para' then
        result = result .. render_inline_latex(block.content)
      elseif block.t == 'BulletList' then
        -- Nested bullet list
        result = result .. '\n' .. render_bullet_list(block)
      else
        result = result .. escape_latex(pandoc.utils.stringify(block))
      end
      if j < #item then
        result = result .. ' '
      end
    end
    result = result .. '\n'
  end
  result = result .. '\\end{itemize}'
  return result
end

-- Render cell contents (which may be blocks containing inlines)
local function render_cell_contents(contents)
  local result = ''
  local block_count = #contents
  for i, block in ipairs(contents) do
    if block.t == 'Plain' then
      result = result .. render_inline_latex(block.content)
    elseif block.t == 'Para' then
      result = result .. render_inline_latex(block.content)
      -- Add paragraph separator between multiple Para blocks
      if i < block_count then
        local next_block = contents[i + 1]
        if next_block and next_block.t == 'Para' then
          result = result .. '\\par\\vspace{0.5em}'
        end
      end
    elseif block.t == 'BulletList' then
      result = result .. render_bullet_list(block)
    elseif block.t == 'OrderedList' then
      -- Handle ordered lists similarly
      result = result .. '\\begin{enumerate}[nosep,leftmargin=*]\n'
      for _, item in ipairs(block.content) do
        result = result .. '\\item '
        for j, inner_block in ipairs(item) do
          if inner_block.t == 'Plain' or inner_block.t == 'Para' then
            result = result .. render_inline_latex(inner_block.content)
          else
            result = result .. escape_latex(pandoc.utils.stringify(inner_block))
          end
          if j < #item then
            result = result .. ' '
          end
        end
        result = result .. '\n'
      end
      result = result .. '\\end{enumerate}'
    else
      -- Fallback for other block types
      result = result .. escape_latex(pandoc.utils.stringify(block))
    end
  end
  return result
end

local function get_rows_data(rows, cell_color, text_color, strong)

  local latex_cell_color = ''
  local latex_text_color_begin = ''
  local latex_text_color_end = ''
  local strong_begin = ''
  local strong_end = ''

  if(cell_color and cell_color ~='') then
    -- Check if it's an inline RGB color specification or a named color
    if cell_color:match("^{RGB}") then
      latex_cell_color = '\\cellcolor[RGB]' .. cell_color:gsub("^{RGB}", "") .. ''
    else
      latex_cell_color = '\\cellcolor{'..cell_color..'}'
    end
  end
  if(text_color and text_color ~= '') then
    -- Check if it's an inline RGB color specification or a named color
    if text_color:match("^{RGB}") then
      latex_text_color_begin = '\\textcolor[RGB]' .. text_color:gsub("^{RGB}", "") .. '{'
      latex_text_color_end = '}'
    else
      latex_text_color_begin = '\\textcolor{' .. text_color .. '}{'
      latex_text_color_end = '}'
    end
  end
  if(strong) then
    strong_begin = "\\bf{"
    strong_end = "}"
  end
  local data = ''
  for _, row in ipairs(rows) do

    for k, cell in ipairs(row.cells) do
      local cell_content = render_cell_contents(cell.contents)
      data = data .. latex_cell_color .. latex_text_color_begin .. strong_begin .. cell_content .. strong_end .. latex_text_color_end
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

  -- Normalize quotes: convert Unicode curly quotes to ASCII quotes
  if caption_content then
    caption_content = caption_content:gsub("\226\128\156", '"')  -- LEFT DOUBLE QUOTATION MARK "
    caption_content = caption_content:gsub("\226\128\157", '"')  -- RIGHT DOUBLE QUOTATION MARK "
    caption_content = caption_content:gsub("\226\128\152", "'")  -- LEFT SINGLE QUOTATION MARK '
    caption_content = caption_content:gsub("\226\128\153", "'")  -- RIGHT SINGLE QUOTATION MARK '
  end

  -- Parse caption properties into dict
  local dict = {}
  if caption_content then
    -- First, try to match quoted values like key="value"
    for key, value in string.gmatch(caption_content, '([%w%-]+)="([^"]*)"') do
      dict[key] = value
    end
    -- Then match unquoted values like key=value (no spaces in value)
    for key, value in string.gmatch(caption_content, '([%w%-]+)=(%[?[^%s"]+%]?)') do
      if not dict[key] then  -- Don't overwrite quoted values
        dict[key] = value
      end
    end
    -- Finally match label syntax like #tbl-myid
    local label = caption_content:match('#([%w%-]+)')
    if label then
      dict['label'] = label
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

  -- Resolve header color: per-table > document-level > theme default
  local header_color
  if dict['tbl-header-bgcolor'] and dict['tbl-header-bgcolor'] ~= '' then
    header_color = resolve_color(dict['tbl-header-bgcolor'], 'tableheaderbgcolor')
  elseif doc_meta.table_header_color then
    header_color = resolve_color(doc_meta.table_header_color, 'tableheaderbgcolor')
  else
    header_color = 'tableheaderbgcolor'
  end

  -- Resolve body color: per-table > document-level > theme default (dark) or none (light)
  local body_color
  if dict['tbl-body-bgcolor'] and dict['tbl-body-bgcolor'] ~= '' then
    body_color = resolve_color(dict['tbl-body-bgcolor'], nil)
  elseif doc_meta.table_body_color then
    body_color = resolve_color(doc_meta.table_body_color, nil)
  elseif doc_meta.dark_background then
    body_color = 'tablebodybgcolor'
  else
    body_color = nil
  end

  -- Resolve body text color: per-table > document-level > nil (use default)
  local body_txtcolor
  if dict['tbl-body-txtcolor'] and dict['tbl-body-txtcolor'] ~= '' then
    body_txtcolor = resolve_color(dict['tbl-body-txtcolor'], nil)
  elseif doc_meta.table_body_txtcolor then
    body_txtcolor = resolve_color(doc_meta.table_body_txtcolor, nil)
  else
    body_txtcolor = nil
  end

  -- Resolve header text color: per-table > document-level > nil (use default)
  local header_txtcolor
  if dict['tbl-header-txtcolor'] and dict['tbl-header-txtcolor'] ~= '' then
    header_txtcolor = resolve_color(dict['tbl-header-txtcolor'], nil)
  elseif doc_meta.table_header_txtcolor then
    header_txtcolor = resolve_color(doc_meta.table_header_txtcolor, nil)
  else
    header_txtcolor = nil
  end

  -- Resolve border color: per-table > document-level > nil (use default black)
  local border_color
  if dict['tbl-border-color'] and dict['tbl-border-color'] ~= '' then
    border_color = resolve_color(dict['tbl-border-color'], nil)
  elseif doc_meta.table_border_color then
    border_color = resolve_color(doc_meta.table_border_color, nil)
  else
    border_color = nil
  end

  -- Resolve border width: per-table > document-level > nil (use default)
  local border_width
  if dict['tbl-border-width'] and dict['tbl-border-width'] ~= '' then
    border_width = dict['tbl-border-width']
  elseif doc_meta.table_border_width then
    border_width = doc_meta.table_border_width
  else
    border_width = nil
  end

  -- Resolve cell padding: per-table > document-level > nil (use default)
  local cell_padding
  if dict['tbl-cell-padding'] and dict['tbl-cell-padding'] ~= '' then
    cell_padding = dict['tbl-cell-padding']
  elseif doc_meta.table_cell_padding then
    cell_padding = doc_meta.table_cell_padding
  else
    cell_padding = nil
  end

  -- Resolve table alignment: per-table > document-level > left (default)
  local table_alignment
  if dict['tbl-alignment'] and dict['tbl-alignment'] ~= '' then
    table_alignment = dict['tbl-alignment']
  elseif doc_meta.table_alignment then
    table_alignment = doc_meta.table_alignment
  else
    table_alignment = 'left'
  end

  -- Convert alignment to LaTeX command
  local alignment_latex
  local caption_align
  if table_alignment == 'left' then
    alignment_latex = '\\raggedright'
    caption_align = 'raggedright'
  elseif table_alignment == 'right' then
    alignment_latex = '\\raggedleft'
    caption_align = 'raggedleft'
  else
    alignment_latex = '\\centering'
    caption_align = 'centering'
  end

  -- COLSPECS
  local col_specs = tbl.colspecs
  local col_specs_latex = '| '

  for i, col_spec in ipairs(col_specs) do
    local align = col_spec[1]
    local width = col_spec[2]

    -- Check if we have explicit width from tbl-colwidths
    local has_explicit_width = col_widths[i] ~= nil

    -- Determine alignment command for p{} columns
    local align_cmd = ''
    if align == 'AlignLeft' then
      align_cmd = '\\raggedright\\arraybackslash'
    elseif align == 'AlignRight' then
      align_cmd = '\\raggedleft\\arraybackslash'
    elseif align == 'AlignCenter' then
      align_cmd = '\\centering\\arraybackslash'
    end

    if has_explicit_width then
      -- Use proportional width with p{} specifier
      local width_fraction = col_widths[i] / 100
      if align_cmd ~= '' then
        col_specs_latex = col_specs_latex .. '>{' .. align_cmd .. '}p{' .. string.format('%.2f', width_fraction) .. '\\linewidth} |'
      else
        col_specs_latex = col_specs_latex .. 'p{' .. string.format('%.2f', width_fraction) .. '\\linewidth} |'
      end
    elseif width and width > 0 then
      -- Use width from colspecs if available
      if align_cmd ~= '' then
        col_specs_latex = col_specs_latex .. '>{' .. align_cmd .. '}p{' .. string.format('%.2f', width) .. '\\linewidth} |'
      else
        col_specs_latex = col_specs_latex .. 'p{' .. string.format('%.2f', width) .. '\\linewidth} |'
      end
    else
      -- Fall back to simple alignment specifiers
      if align == 'AlignLeft' then
        col_specs_latex = col_specs_latex .. 'l |'
      elseif align == 'AlignRight' then
        col_specs_latex = col_specs_latex .. 'r |'
      elseif align == 'AlignCenter' then
        col_specs_latex = col_specs_latex .. 'c |'
      else
        col_specs_latex = col_specs_latex .. 'l |'
      end
    end
  end

  -- Determine if we need a table environment (for caption/label)
  local has_caption = caption_text and caption_text ~= ''
  local has_label = dict['label'] ~= nil
  local use_table_env = has_caption or has_label

  local result = pandoc.List:new{}

  if use_table_env then
    result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\begin{table}[htbp]\n' .. alignment_latex)}
    if has_label then
      result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\label{' .. dict['label'] .. '}')}
    end
  end

  -- Apply border color if specified
  local border_color_begin = ''
  local border_color_end = ''
  if border_color and border_color ~= '' then
    if border_color:match("^{RGB}") then
      border_color_begin = '\\arrayrulecolor[RGB]' .. border_color:gsub("^{RGB}", "") .. '\n'
    else
      border_color_begin = '\\arrayrulecolor{' .. border_color .. '}\n'
    end
    border_color_end = '\\arrayrulecolor{black}\n'  -- Reset to default
  end

  -- Apply border width if specified
  local border_width_begin = ''
  local border_width_end = ''
  if border_width and border_width ~= '' then
    border_width_begin = '\\setlength{\\arrayrulewidth}{' .. border_width .. 'pt}\n'
    border_width_end = '\\setlength{\\arrayrulewidth}{0.4pt}\n'  -- Reset to default
  end

  -- Apply cell padding if specified (controls both horizontal via tabcolsep and vertical via arraystretch)
  local cell_padding_begin = ''
  local cell_padding_end = ''
  local array_stretch = '1.5'  -- default
  if cell_padding and cell_padding ~= '' then
    cell_padding_begin = '\\setlength{\\tabcolsep}{' .. cell_padding .. 'pt}\n'
    cell_padding_end = '\\setlength{\\tabcolsep}{6pt}\n'
    -- Scale arraystretch based on padding, reduced factor to position text higher
    local padding_num = tonumber(cell_padding) or 6
    array_stretch = string.format('%.2f', 1.0 + (padding_num / 12))
  end

  result = result .. pandoc.List:new{pandoc.RawBlock("latex", border_color_begin .. border_width_begin .. cell_padding_begin .. '\\renewcommand{\\arraystretch}{' .. array_stretch .. '}\n\\begin{tabular}{ '.. col_specs_latex .. ' } \n \\hline')}

  -- HEADER
  local header_latex = get_rows_data(tbl.head.rows, header_color, header_txtcolor, false)
  result = result .. pandoc.List:new{pandoc.RawBlock("latex", header_latex)}

  -- ROWS
  local rows_latex = ''
  for _, tablebody in ipairs(tbl.bodies) do
    rows_latex = get_rows_data(tablebody.body, body_color, body_txtcolor, false)
  end
  result = result .. pandoc.List:new{pandoc.RawBlock("latex", rows_latex)}

  -- FOOTER
  local footer_latex = get_rows_data(tbl.foot.rows, '', nil, false)
  result = result .. pandoc.List:new{pandoc.RawBlock("latex", footer_latex)}

  result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\end{tabular}\n' .. cell_padding_end .. border_width_end .. border_color_end)}

  if use_table_env then
    if has_caption then
      result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\captionsetup{justification=' .. caption_align .. ',singlelinecheck=false}\n\\caption{' .. caption_text .. '}')}
    end
    result = result .. pandoc.List:new{pandoc.RawBlock("latex", '\\end{table}')}
  end

  return result
end

if FORMAT:match 'latex' then

  function Table (tbl)
    return generate_tabularray(tbl)
  end

end
