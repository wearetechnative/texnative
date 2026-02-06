-- Unit tests for cell styling integration
-- Tests the application of per-cell bgcolor/txtcolor in LaTeX output

-- Set up package path to find our modules
package.path = package.path .. ";./tests/?.lua;./tests/mocks/?.lua;./_extensions/texnative/?.lua"

-- Load the pandoc mock first
local pandoc = require("mocks.pandoc")
_G.pandoc = pandoc

-- Now load the core module
local core = require("texnative_core")

-- Helper function to generate cell color LaTeX (mimics texnative.lua logic)
local function apply_cell_style(cell_styles, col, row)
  local cell_bgcolor = ''
  local cell_txtcolor_begin = ''
  local cell_txtcolor_end = ''
  
  if cell_styles and cell_styles[col] and cell_styles[col][row] then
    local cs = cell_styles[col][row]
    
    -- Apply per-cell bgcolor if specified
    if cs.bgcolor then
      local resolved_bgcolor = core.resolve_color(cs.bgcolor, nil)
      if resolved_bgcolor then
        if resolved_bgcolor:match("^{RGB}") then
          cell_bgcolor = '\\cellcolor[RGB]' .. resolved_bgcolor:gsub("^{RGB}", "") .. ''
        else
          cell_bgcolor = '\\cellcolor{' .. resolved_bgcolor .. '}'
        end
      end
    end
    
    -- Apply per-cell txtcolor if specified
    if cs.txtcolor then
      local resolved_txtcolor = core.resolve_color(cs.txtcolor, nil)
      if resolved_txtcolor then
        if resolved_txtcolor:match("^{RGB}") then
          cell_txtcolor_begin = '\\textcolor[RGB]' .. resolved_txtcolor:gsub("^{RGB}", "") .. '{'
          cell_txtcolor_end = '}'
        else
          cell_txtcolor_begin = '\\textcolor{' .. resolved_txtcolor .. '}{'
          cell_txtcolor_end = '}'
        end
      end
    end
  end
  
  return cell_bgcolor, cell_txtcolor_begin, cell_txtcolor_end
end

describe("cell styling integration", function()
  describe("per-cell bgcolor in LaTeX output", function()
    it("applies hex bgcolor to specific cell", function()
      local cell_styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      local bgcolor, _, _ = apply_cell_style(cell_styles, 1, 1)
      assert.are.equal('\\cellcolor[RGB]{255,0,0}', bgcolor)
    end)

    it("applies RGB bgcolor to specific cell", function()
      local cell_styles = core.parse_tbl_cells("{B2: {bgcolor: '128,64,32'}}")
      local bgcolor, _, _ = apply_cell_style(cell_styles, 2, 2)
      assert.are.equal('\\cellcolor[RGB]{128,64,32}', bgcolor)
    end)

    it("returns empty string for cell without bgcolor", function()
      local cell_styles = core.parse_tbl_cells("{A1: {txtcolor: '#000000'}}")
      local bgcolor, _, _ = apply_cell_style(cell_styles, 1, 1)
      assert.are.equal('', bgcolor)
    end)
  end)

  describe("per-cell txtcolor in LaTeX output", function()
    it("applies hex txtcolor to specific cell", function()
      local cell_styles = core.parse_tbl_cells("{A1: {txtcolor: '#ffffff'}}")
      local _, txtcolor_begin, txtcolor_end = apply_cell_style(cell_styles, 1, 1)
      assert.are.equal('\\textcolor[RGB]{255,255,255}{', txtcolor_begin)
      assert.are.equal('}', txtcolor_end)
    end)

    it("applies RGB txtcolor to specific cell", function()
      local cell_styles = core.parse_tbl_cells("{C3: {txtcolor: '0,128,255'}}")
      local _, txtcolor_begin, txtcolor_end = apply_cell_style(cell_styles, 3, 3)
      assert.are.equal('\\textcolor[RGB]{0,128,255}{', txtcolor_begin)
      assert.are.equal('}', txtcolor_end)
    end)

    it("returns empty strings for cell without txtcolor", function()
      local cell_styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      local _, txtcolor_begin, txtcolor_end = apply_cell_style(cell_styles, 1, 1)
      assert.are.equal('', txtcolor_begin)
      assert.are.equal('', txtcolor_end)
    end)
  end)

  describe("combined styles on same cell", function()
    it("applies both bgcolor and txtcolor", function()
      local cell_styles = core.parse_tbl_cells("{A1: {bgcolor: '#003366', txtcolor: '#ffffff'}}")
      local bgcolor, txtcolor_begin, txtcolor_end = apply_cell_style(cell_styles, 1, 1)
      assert.are.equal('\\cellcolor[RGB]{0,51,102}', bgcolor)
      assert.are.equal('\\textcolor[RGB]{255,255,255}{', txtcolor_begin)
      assert.are.equal('}', txtcolor_end)
    end)
  end)

  describe("multiple cells with different styles", function()
    it("applies different styles to different cells", function()
      local cell_styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}, B2: {bgcolor: '#00ff00'}, C3: {txtcolor: '#0000ff'}}")
      
      local bgcolor_a1, _, _ = apply_cell_style(cell_styles, 1, 1)
      local bgcolor_b2, _, _ = apply_cell_style(cell_styles, 2, 2)
      local _, txtcolor_c3_begin, txtcolor_c3_end = apply_cell_style(cell_styles, 3, 3)
      
      assert.are.equal('\\cellcolor[RGB]{255,0,0}', bgcolor_a1)
      assert.are.equal('\\cellcolor[RGB]{0,255,0}', bgcolor_b2)
      assert.are.equal('\\textcolor[RGB]{0,0,255}{', txtcolor_c3_begin)
      assert.are.equal('}', txtcolor_c3_end)
    end)

    it("returns empty for unstyled cells", function()
      local cell_styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      
      -- Cell B2 has no style defined
      local bgcolor, txtcolor_begin, txtcolor_end = apply_cell_style(cell_styles, 2, 2)
      assert.are.equal('', bgcolor)
      assert.are.equal('', txtcolor_begin)
      assert.are.equal('', txtcolor_end)
    end)
  end)

  describe("out-of-bounds cells (silently ignored)", function()
    it("returns empty for non-existent column", function()
      local cell_styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      
      -- Column 5 not defined
      local bgcolor, txtcolor_begin, txtcolor_end = apply_cell_style(cell_styles, 5, 1)
      assert.are.equal('', bgcolor)
      assert.are.equal('', txtcolor_begin)
      assert.are.equal('', txtcolor_end)
    end)

    it("returns empty for non-existent row", function()
      local cell_styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      
      -- Row 10 not defined for column 1
      local bgcolor, txtcolor_begin, txtcolor_end = apply_cell_style(cell_styles, 1, 10)
      assert.are.equal('', bgcolor)
      assert.are.equal('', txtcolor_begin)
      assert.are.equal('', txtcolor_end)
    end)
  end)

  describe("row addressing with unified numbering", function()
    it("header row 1 is addressed as row 1", function()
      local cell_styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      -- Row 1 should match header (row_offset=0 + row_idx=1 = abs_row=1)
      local bgcolor, _, _ = apply_cell_style(cell_styles, 1, 1)
      assert.are.equal('\\cellcolor[RGB]{255,0,0}', bgcolor)
    end)

    it("body row 1 (after 1 header) is addressed as row 2", function()
      local cell_styles = core.parse_tbl_cells("{A2: {bgcolor: '#00ff00'}}")
      -- With 1 header row (row_offset=1), first body row has abs_row=2
      local bgcolor, _, _ = apply_cell_style(cell_styles, 1, 2)
      assert.are.equal('\\cellcolor[RGB]{0,255,0}', bgcolor)
    end)

    it("body row 2 (after 1 header) is addressed as row 3", function()
      local cell_styles = core.parse_tbl_cells("{B3: {txtcolor: '#0000ff'}}")
      -- With 1 header row, second body row has abs_row=3
      local _, txtcolor_begin, _ = apply_cell_style(cell_styles, 2, 3)
      assert.are.equal('\\textcolor[RGB]{0,0,255}{', txtcolor_begin)
    end)

    it("with 2 header rows, body row 1 is addressed as row 3", function()
      local cell_styles = core.parse_tbl_cells("{A3: {bgcolor: '#ff00ff'}}")
      -- With 2 header rows (row_offset=2), first body row has abs_row=3
      local bgcolor, _, _ = apply_cell_style(cell_styles, 1, 3)
      assert.are.equal('\\cellcolor[RGB]{255,0,255}', bgcolor)
    end)
  end)

  describe("empty or nil cell_styles", function()
    it("handles nil cell_styles gracefully", function()
      local bgcolor, txtcolor_begin, txtcolor_end = apply_cell_style(nil, 1, 1)
      assert.are.equal('', bgcolor)
      assert.are.equal('', txtcolor_begin)
      assert.are.equal('', txtcolor_end)
    end)

    it("handles empty cell_styles gracefully", function()
      local cell_styles = core.parse_tbl_cells("")
      local bgcolor, txtcolor_begin, txtcolor_end = apply_cell_style(cell_styles, 1, 1)
      assert.are.equal('', bgcolor)
      assert.are.equal('', txtcolor_begin)
      assert.are.equal('', txtcolor_end)
    end)
  end)

  describe("default inline RGB colors (no named color dependency)", function()
    -- Tests for the inline RGB default fix that eliminates dependency on
    -- predefined named colors like 'tableheaderbgcolor'
    
    it("resolve_color returns inline RGB format when given hex color", function()
      local result = core.resolve_color('#DDDDDD', 'fallback')
      assert.are.equal('{RGB}{221,221,221}', result)
    end)

    it("resolve_color returns inline RGB format when given RGB string", function()
      local result = core.resolve_color('71,29,0', 'fallback')
      assert.are.equal('{RGB}{71,29,0}', result)
    end)

    it("resolve_color returns default when nil color provided", function()
      local result = core.resolve_color(nil, '{RGB}{221,221,221}')
      assert.are.equal('{RGB}{221,221,221}', result)
    end)

    it("resolve_color returns default when empty string color provided", function()
      local result = core.resolve_color('', '{RGB}{71,29,0}')
      assert.are.equal('{RGB}{71,29,0}', result)
    end)

    it("default light mode header color is inline RGB 221,221,221", function()
      -- When no header color specified in light mode, default is gray
      local default_header_light = '{RGB}{221,221,221}'
      local result = core.resolve_color(nil, default_header_light)
      assert.are.equal('{RGB}{221,221,221}', result)
    end)

    it("default dark mode header color is inline RGB 71,29,0", function()
      -- When no header color specified in dark mode, default is dark brown
      local default_header_dark = '{RGB}{71,29,0}'
      local result = core.resolve_color(nil, default_header_dark)
      assert.are.equal('{RGB}{71,29,0}', result)
    end)

    it("default dark mode body color is inline RGB 109,43,0", function()
      -- When no body color specified in dark mode, default is brown
      local default_body_dark = '{RGB}{109,43,0}'
      local result = core.resolve_color(nil, default_body_dark)
      assert.are.equal('{RGB}{109,43,0}', result)
    end)
  end)
end)
