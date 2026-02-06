-- Import core utility functions
local core = require("texnative_core")
local hex_to_rgb = core.hex_to_rgb
local escape_latex = core.escape_latex
local resolve_color = core.resolve_color
local render_inline_latex = core.render_inline_latex
local parse_tbl_cells = core.parse_tbl_cells

-- Debug to file
local debug_file = io.open("/tmp/texnative_debug.log", "w")
if debug_file then
  debug_file:write("TEXNATIVE.LUA: Filter loading...\n")
  debug_file:flush()
end

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
  dark_background = false,
  -- Cell styles from Div wrapper, keyed by table identifier
  div_cell_styles = {}
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

  -- Note: Cell styles are now passed via Div wrapper attributes, not pre-filter metadata

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

-- Note: escape_latex, hex_to_rgb, resolve_color, and render_inline_latex
-- are imported from texnative_core at the top of this file

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

local function get_rows_data(rows, cell_color, text_color, strong, cell_styles, row_offset)
  -- cell_styles: 2D array [col][row] with {bgcolor, txtcolor} for per-cell overrides
  -- row_offset: starting row number for unified addressing (1 for header, header_count+1 for body)

  local strong_begin = ''
  local strong_end = ''
  if(strong) then
    strong_begin = "\\bf{"
    strong_end = "}"
  end

  -- Helper to format a color for LaTeX
  local function format_cell_color(color)
    if not color or color == '' then return '' end
    if color:match("^{RGB}") then
      return '\\cellcolor[RGB]' .. color:gsub("^{RGB}", "") .. ''
    else
      return '\\cellcolor{' .. color .. '}'
    end
  end

  local function format_text_color_begin(color)
    if not color or color == '' then return '' end
    if color:match("^{RGB}") then
      return '\\textcolor[RGB]' .. color:gsub("^{RGB}", "") .. '{'
    else
      return '\\textcolor{' .. color .. '}{'
    end
  end

  local function format_text_color_end(color)
    if not color or color == '' then return '' end
    return '}'
  end

  local data = ''
  local current_row = row_offset or 1

  for _, row in ipairs(rows) do
    for col_idx, cell in ipairs(row.cells) do
      local cell_content = render_cell_contents(cell.contents)

      -- Determine colors: per-cell overrides section-level defaults
      local effective_bgcolor = cell_color
      local effective_txtcolor = text_color

      -- Check for per-cell style override
      if cell_styles and cell_styles[col_idx] and cell_styles[col_idx][current_row] then
        local style = cell_styles[col_idx][current_row]
        if style.bgcolor then
          effective_bgcolor = resolve_color(style.bgcolor, nil)
        end
        if style.txtcolor then
          effective_txtcolor = resolve_color(style.txtcolor, nil)
        end
      end

      -- Format colors for this cell
      local latex_cell_color = format_cell_color(effective_bgcolor)
      local latex_text_color_begin = format_text_color_begin(effective_txtcolor)
      local latex_text_color_end = format_text_color_end(effective_txtcolor)

      data = data .. latex_cell_color .. latex_text_color_begin .. strong_begin .. cell_content .. strong_end .. latex_text_color_end

      if (col_idx == #row.cells) then
        data = data .. ' \\\\ \n'
      else
        data = data .. ' & '
      end
    end
    data = data .. '\n \\hline \n'
    current_row = current_row + 1
  end
  return data
end


local function generate_tabularray(tbl)

  local caption_raw = pandoc.utils.stringify(tbl.caption.long)

  -- First, try to get attributes from tbl.attr.attributes (Quarto-processed tables)
  -- This is where Quarto stores caption attributes after processing FloatRefTarget
  local attr_dict = {}
  if tbl.attr and tbl.attr.attributes then
    for k, v in pairs(tbl.attr.attributes) do
      attr_dict[k] = v
    end
  end

  -- Extract the property block from caption, handling nested braces
  -- Find the outermost { } block by matching braces
  local function find_property_block(str)
    local start_pos = str:find("{")
    if not start_pos then return nil end

    local depth = 0
    local end_pos = nil
    for i = start_pos, #str do
      local c = str:sub(i, i)
      if c == "{" then
        depth = depth + 1
      elseif c == "}" then
        depth = depth - 1
        if depth == 0 then
          end_pos = i
          break
        end
      end
    end

    if end_pos then
      return str:sub(start_pos + 1, end_pos - 1)
    end
    return nil
  end

  -- Extract property block from caption and get caption text
  local caption_content = find_property_block(caption_raw)
  local caption_text
  if caption_content then
    -- Find and remove the entire property block including braces
    local start_pos = caption_raw:find("{")
    local depth = 0
    local end_pos = nil
    for i = start_pos, #caption_raw do
      local c = caption_raw:sub(i, i)
      if c == "{" then depth = depth + 1
      elseif c == "}" then
        depth = depth - 1
        if depth == 0 then end_pos = i; break end
      end
    end
    if end_pos then
      caption_text = (caption_raw:sub(1, start_pos - 1) .. caption_raw:sub(end_pos + 1)):match("^%s*(.-)%s*$")
    else
      caption_text = caption_raw:match("^%s*(.-)%s*$")
    end
  else
    caption_text = caption_raw:match("^%s*(.-)%s*$")
  end

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
    -- Match key="value" where value can contain nested braces
    -- We need to handle tbl-cells="{...}" specially
    local pos = 1
    while pos <= #caption_content do
      -- Try to match key="
      local key_start, key_end, key = caption_content:find('([%w%-]+)="', pos)
      if key_start then
        -- Find the matching closing quote, accounting for nested braces
        local value_start = key_end + 1
        local value_end = nil
        local brace_depth = 0
        for i = value_start, #caption_content do
          local c = caption_content:sub(i, i)
          if c == "{" then
            brace_depth = brace_depth + 1
          elseif c == "}" then
            brace_depth = brace_depth - 1
          elseif c == '"' and brace_depth == 0 then
            value_end = i - 1
            break
          end
        end
        if value_end then
          dict[key] = caption_content:sub(value_start, value_end)
          pos = value_end + 2
        else
          pos = key_end + 1
        end
      else
        break
      end
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

  -- If label not found in caption, try tbl.attr.identifier (Quarto moves it there)
  if not dict['label'] and tbl.attr and tbl.attr.identifier and tbl.attr.identifier ~= '' then
    dict['label'] = tbl.attr.identifier
  end

  -- Merge attributes from tbl.attr.attributes (Quarto extracts these from caption)
  -- This handles the case where Quarto processes a labeled table and moves
  -- custom attributes from the caption to tbl.attr.attributes
  if tbl.attr and tbl.attr.attributes then
    for key, value in pairs(tbl.attr.attributes) do
      if not dict[key] then
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

  -- Parse per-cell styles from tbl-cells attribute
  -- Priority: 1. table attr (from Div wrapper), 2. caption dict, 3. doc_meta.div_cell_styles
  local cell_styles = {}
  local tbl_id = dict['label'] or (tbl.attr and tbl.attr.identifier) or nil

  if tbl.attr and tbl.attr.attributes and tbl.attr.attributes['tbl-cells'] then
    -- Found in table attributes (set by DivFilter)
    cell_styles = parse_tbl_cells(tbl.attr.attributes['tbl-cells'])
  elseif dict['tbl-cells'] then
    -- Found in caption (works for unlabeled tables)
    cell_styles = parse_tbl_cells(dict['tbl-cells'])
  elseif tbl_id and doc_meta.div_cell_styles[tbl_id] then
    -- Found in Div wrapper (legacy, via div_cell_styles dict)
    cell_styles = parse_tbl_cells(doc_meta.div_cell_styles[tbl_id])
  end

  -- Count header rows for unified row addressing
  local header_row_count = #tbl.head.rows

  -- HEADER (row numbering starts at 1)
  local header_latex = get_rows_data(tbl.head.rows, header_color, header_txtcolor, false, cell_styles, 1)
  result = result .. pandoc.List:new{pandoc.RawBlock("latex", header_latex)}

  -- ROWS (row numbering continues after header)
  local rows_latex = ''
  local body_row_offset = header_row_count + 1
  for _, tablebody in ipairs(tbl.bodies) do
    rows_latex = get_rows_data(tablebody.body, body_color, body_txtcolor, false, cell_styles, body_row_offset)
    body_row_offset = body_row_offset + #tablebody.body
  end
  result = result .. pandoc.List:new{pandoc.RawBlock("latex", rows_latex)}

  -- FOOTER (continues row numbering)
  local footer_latex = get_rows_data(tbl.foot.rows, '', nil, false, cell_styles, body_row_offset)
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

-- Define the Table filter function for latex format
local function TableFilter(tbl)
  if FORMAT:match 'latex' then
    return generate_tabularray(tbl)
  end
  return nil
end

-- Div filter to extract tbl-cells from wrapper divs and pass to tables
-- This allows cell styling for labeled tables where Quarto consumes caption attributes
local function DivFilter(div)
  -- Check if this div has tbl-cells attribute
  local tbl_cells = div.attributes['tbl-cells']
  if not tbl_cells then
    return nil  -- Not a cell-styling div, leave unchanged
  end

  -- Find tables inside this div and set the tbl-cells attribute directly on them
  local modified = false
  local function process_table(tbl)
    -- Set the tbl-cells attribute directly on the table
    tbl.attr.attributes['tbl-cells'] = tbl_cells
    modified = true
    return tbl  -- Return modified table
  end

  -- Walk the div contents to find and modify tables
  local new_content = pandoc.walk_block(pandoc.Div(div.content), {Table = process_table}).content

  if modified then
    -- Return the div contents without the wrapper (unwrap), tables now have tbl-cells attr
    return new_content
  end

  return nil
end

-- Return a list of filter tables to ensure proper execution order:
-- 1. Meta runs first to collect document-level settings
-- 2. Div runs to extract tbl-cells from wrapper divs
-- 3. Table runs with access to those settings
return {
  { Meta = Meta },
  { Div = DivFilter },
  { Table = TableFilter }
}
