
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
      data = data .. latex_cell_color .. strong_begin .. pandoc.utils.stringify(cell.contents) .. strong_end
      if (k == #row.cells) then
        data = data .. ' \\\\ \n'
      else
        data = data .. ' & '
      end

      -- CHANGE % INTO \% HACK
      data = data:gsub('([^\\])%%', '%1\\%%')
      data = data:gsub('^%%', '\\%%')
    end
    data = data ..'\n \\hline \n'

  end
  return data
end


local function generate_tabularray(tbl)

local caption = pandoc.utils.stringify(tbl.caption.long)
local caption_content = caption:match("{(.-)}")
if caption_content then
  caption = caption:gsub("{.-}", "")
end

  -- COLSPECS
  local col_specs = tbl.colspecs
  local col_specs_latex = '| '

  for i, col_spec in ipairs(col_specs) do
    local align = col_spec[1]
    local width = col_spec[2]

    if align == 'AlignLeft' then
      col_specs_latex = col_specs_latex .. 'l |'
    elseif align == 'AlignRight' then
      col_specs_latex = col_specs_latex .. 'r |'
    else
      col_specs_latex = col_specs_latex .. 'c |'
    end

  end

  -- If there's caption data, we override previous data
 if caption_content then

   local dict = {}
   for key, value in string.gmatch(caption_content, '(%w+)=([^%s]+)') do
       dict[key] = value
   end

 end

  local result = pandoc.List:new{pandoc.RawBlock("latex", '\\renewcommand{\\arraystretch}{1.5}\n\\begin{tabular}{ '.. col_specs_latex .. ' } \n \\hline')}

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

  return result
end

if FORMAT:match 'latex' then

  function Table (tbl)
    return generate_tabularray(tbl)
  end

end
