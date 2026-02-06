-- Unit tests for cell styling integration
-- Tests the interaction between parse_tbl_cells and resolve_color

package.path = package.path .. ";_extensions/texnative/?.lua"
require("tests.mocks.pandoc")
local core = require("texnative_core")

describe("Cell Styling Integration", function()

  describe("parse_tbl_cells with resolve_color", function()

    it("parses and resolves hex bgcolor to RGB format", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      assert.is_not_nil(styles[1])
      assert.is_not_nil(styles[1][1])
      assert.equals('#ff0000', styles[1][1].bgcolor)
      
      -- resolve_color converts hex to LaTeX RGB format
      local resolved = core.resolve_color(styles[1][1].bgcolor, nil)
      assert.equals('{RGB}{255,0,0}', resolved)
    end)

    it("parses and resolves RGB bgcolor", function()
      local styles = core.parse_tbl_cells("{B2: {bgcolor: '100,149,237'}}")
      assert.is_not_nil(styles[2])
      assert.is_not_nil(styles[2][2])
      assert.equals('100,149,237', styles[2][2].bgcolor)
      
      local resolved = core.resolve_color(styles[2][2].bgcolor, nil)
      assert.equals('{RGB}{100,149,237}', resolved)
    end)

    it("parses and resolves txtcolor", function()
      local styles = core.parse_tbl_cells("{C3: {txtcolor: '#006400'}}")
      assert.is_not_nil(styles[3])
      assert.is_not_nil(styles[3][3])
      assert.equals('#006400', styles[3][3].txtcolor)
      
      local resolved = core.resolve_color(styles[3][3].txtcolor, nil)
      assert.equals('{RGB}{0,100,0}', resolved)
    end)

    it("parses combined bgcolor and txtcolor", function()
      local styles = core.parse_tbl_cells("{B2: {bgcolor: '#DC143C', txtcolor: '#FFFFFF'}}")
      assert.is_not_nil(styles[2])
      assert.is_not_nil(styles[2][2])
      assert.equals('#DC143C', styles[2][2].bgcolor)
      assert.equals('#FFFFFF', styles[2][2].txtcolor)
      
      local resolved_bg = core.resolve_color(styles[2][2].bgcolor, nil)
      local resolved_txt = core.resolve_color(styles[2][2].txtcolor, nil)
      assert.equals('{RGB}{220,20,60}', resolved_bg)
      assert.equals('{RGB}{255,255,255}', resolved_txt)
    end)

    it("parses multiple cells with different styles", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#4169E1'}, C1: {bgcolor: '#4169E1'}, C2: {bgcolor: '#90EE90'}}")
      
      -- A1 = col 1, row 1
      assert.is_not_nil(styles[1])
      assert.is_not_nil(styles[1][1])
      assert.equals('#4169E1', styles[1][1].bgcolor)
      
      -- C1 = col 3, row 1
      assert.is_not_nil(styles[3])
      assert.is_not_nil(styles[3][1])
      assert.equals('#4169E1', styles[3][1].bgcolor)
      
      -- C2 = col 3, row 2
      assert.is_not_nil(styles[3][2])
      assert.equals('#90EE90', styles[3][2].bgcolor)
    end)

  end)

  describe("unified row numbering", function()

    it("addresses header row 1 correctly", function()
      -- In a table with 1 header row, B1 refers to header cell
      local styles = core.parse_tbl_cells("{B1: {bgcolor: '#e0e0e0'}}")
      assert.is_not_nil(styles[2])
      assert.is_not_nil(styles[2][1])
      assert.equals('#e0e0e0', styles[2][1].bgcolor)
    end)

    it("addresses body rows with offset", function()
      -- With 1 header row, B2 is first body row, B3 is second body row
      local styles = core.parse_tbl_cells("{B2: {bgcolor: '#90EE90'}, B3: {bgcolor: '#FFD700'}}")
      
      assert.is_not_nil(styles[2])
      assert.is_not_nil(styles[2][2])
      assert.equals('#90EE90', styles[2][2].bgcolor)
      
      assert.is_not_nil(styles[2][3])
      assert.equals('#FFD700', styles[2][3].bgcolor)
    end)

  end)

  describe("cell style precedence", function()

    it("returns nil for missing cell style", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      
      -- B1 has no style
      assert.is_nil(styles[2])
    end)

    it("returns default when resolve_color gets nil", function()
      local resolved = core.resolve_color(nil, 'defaultcolor')
      assert.equals('defaultcolor', resolved)
    end)

  end)

  describe("edge cases", function()

    it("handles empty tbl-cells string", function()
      local styles = core.parse_tbl_cells("")
      assert.same({}, styles)
    end)

    it("handles nil tbl-cells", function()
      local styles = core.parse_tbl_cells(nil)
      assert.same({}, styles)
    end)

    it("handles double-letter addresses by matching single-letter part", function()
      -- AA1 pattern extracts A1 (single-letter + digits) - acceptable behavior
      local styles = core.parse_tbl_cells("{AA1: {bgcolor: '#ff0000'}}")
      -- A1 is extracted from AA1
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)

  end)

end)
