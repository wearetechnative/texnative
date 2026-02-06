-- Pre-filter: Extract tbl-cells attributes from table captions before Quarto's crossref processing
-- NOTE: This filter has limited effectiveness because Quarto processes captions before Lua filters.
-- The recommended approach is to use Div wrappers for labeled tables:
--   ::: {tbl-cells="{A1: {bgcolor: '#ff0000'}}"}
--   | Header |
--   |--------|
--   | Data   |
--
--   : Caption {#tbl-label}
--   :::

-- Global storage for cell styles, keyed by table identifier or position
local table_cell_styles = {}
local table_counter = 0

-- Extract the property block from caption text, handling nested braces
local function find_property_block(str)
  if not str then return nil end
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

-- Parse tbl-cells value from property block
local function extract_tbl_cells(property_block)
  if not property_block then return nil end

  -- Normalize quotes
  property_block = property_block:gsub("\226\128\156", '"')
  property_block = property_block:gsub("\226\128\157", '"')
  property_block = property_block:gsub("\226\128\152", "'")
  property_block = property_block:gsub("\226\128\153", "'")

  -- Find tbl-cells="..." handling nested braces
  local key_start, key_end = property_block:find('tbl%-cells="')
  if not key_start then return nil end

  local value_start = key_end + 1
  local value_end = nil
  local brace_depth = 0

  for i = value_start, #property_block do
    local c = property_block:sub(i, i)
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
    return property_block:sub(value_start, value_end)
  end
  return nil
end

-- Extract label from property block
local function extract_label(property_block)
  if not property_block then return nil end
  return property_block:match('#([%w%-]+)')
end

-- Table filter that runs pre-crossref to capture tbl-cells
local function Table(tbl)
  table_counter = table_counter + 1

  -- Get caption as raw text
  local caption_raw = ""

  if tbl.caption and tbl.caption.long then
    for _, block in ipairs(tbl.caption.long) do
      if block.t == "Plain" or block.t == "Para" then
        for _, inline in ipairs(block.content or block.c or {}) do
          if inline.t == "Str" then
            caption_raw = caption_raw .. (inline.text or inline.c or "")
          elseif inline.t == "Space" then
            caption_raw = caption_raw .. " "
          end
        end
      end
    end
  end

  -- If still empty, try stringify as fallback
  if caption_raw == "" then
    caption_raw = pandoc.utils.stringify(tbl.caption.long)
  end

  if not caption_raw or caption_raw == "" then
    return nil
  end

  -- Extract property block from caption
  local property_block = find_property_block(caption_raw)
  if not property_block then
    return nil
  end

  -- Extract tbl-cells attribute
  local tbl_cells = extract_tbl_cells(property_block)
  if not tbl_cells then
    return nil
  end

  -- Get label for identification
  local label = extract_label(property_block)
  local key = label or ("table-" .. table_counter)

  -- Store the tbl-cells value
  table_cell_styles[key] = tbl_cells

  -- Add tbl-cells to the table's attributes so our main filter can access it
  if not tbl.attr then
    tbl.attr = pandoc.Attr()
  end
  tbl.attr.attributes['tbl-cells'] = tbl_cells

  -- Also store the label in attributes if we extracted it
  if label and (not tbl.attr.identifier or tbl.attr.identifier == "") then
    tbl.attr.identifier = label
  end

  return tbl
end

-- Make the table_cell_styles available globally for the main filter
function Meta(meta)
  if next(table_cell_styles) then
    meta['_texnative_cell_styles'] = pandoc.MetaMap({})
    for k, v in pairs(table_cell_styles) do
      meta['_texnative_cell_styles'][k] = pandoc.MetaString(v)
    end
    return meta
  end
end

return {
  { Table = Table },
  { Meta = Meta }
}
