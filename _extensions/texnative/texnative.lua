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

      -- change % into \% hack
      data = data:gsub('([^\\])%%', '%1\\%%')
      data = data:gsub('^%%', '\\%%')
    end
    data = data .. '\n \\hline \n'

  end
  return data
end

-- \begin{tabular}{| >{\raggedleft\arraybackslash}p{1.7cm} | >{\raggedright\arraybackslash}p{4.7cm} | >{\raggedright\arraybackslash}p{2.7cm}  | >{\raggedright\arraybackslash}p{2.7cm} | }
--
--   \hline
--
--   \cellcolor{tableheadercolor} \bf{Priority} &
--   \cellcolor{tableheadercolor} \bf{Response time (within service hours)} &
--   \cellcolor{tableheadercolor} \bf{Incident type} &
--   \cellcolor{tableheadercolor} \bf{Standard}
--   \\
--   \hline
--
--   \cellcolor{tableheadercolor} {\bf Critical}
--   & Within 30 minutes
--   & Entire infrastructure not accessible, security incident.
--   & 80\% \\ [0.2cm]
--   \hline
--
--   \cellcolor{tableheadercolor} {\bf High}
--   & Within 4 hours
--   & Part of the infrastructure is not accessible
--   & 80\% \\ [0.2cm]
--   \hline
--
--   \cellcolor{tableheadercolor} {\bf Medium}
--   & Withing 8 hours
--   & Account creation, changes etc..
--   & 80\% \\ [0.2cm]
--   \hline
--
--   \cellcolor{tableheadercolor} {\bf Low}
--   & Within 5 days
--   & Non-blocking changes, information requests
--   & 80\% \\ [0.2cm]
--   \hline
--
-- \end{tabular}


local function generate_tabularray(tbl)
--  local table_class = 'tabular'
--
--print(tbl.attributes)
--  if (tbl.attributes['tablename'] ~= nil) then
--    table_class = tbl.attributes['tablename']
--  end

local caption = pandoc.utils.stringify(tbl.caption.long)
local caption_content = caption:match("{(.-)}")
if caption_content then
  caption = caption:gsub("{.-}", "")
end

  -- COLSPECS
  local col_specs = tbl.colspecs
  --print(col_specs)
  local col_specs_latex = '| '

  for i, col_spec in ipairs(col_specs) do
    local align = col_spec[1]
    local width = col_spec[2]

--    if width ~= 0 and width ~= nil then
--      col_specs_latex = col_specs_latex .. width..'\\linewidth,'
--    end

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
      --print(key)
      --print(value)
   end

    --print(dict)

--   if dict["tablename"] then
--     table_class = dict["tablename"]
--   end
--   if dict["colspec"] then
--     col_specs_latex = dict["colspec"]
--   end
 end

  local result = pandoc.List:new{pandoc.RawBlock("latex", '\\begin{tabular}{ '.. col_specs_latex .. ' } \n \\hline')}

  --local result = pandoc.List:new{pandoc.RawBlock("latex", '\\begin{tabular}{| >{\\raggedleft\\arraybackslash}p{1.7cm} | >{\\raggedright\\arraybackslash}p{4.7cm} | >{\\raggedright\arraybackslash}p{2.7cm}  | >{\\raggedright\arraybackslash}p{2.7cm}}')}

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

