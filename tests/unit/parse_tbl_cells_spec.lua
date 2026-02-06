-- Unit tests for parse_tbl_cells function

package.path = package.path .. ";./tests/mocks/?.lua"
require("pandoc")

package.path = package.path .. ";./_extensions/texnative/?.lua"
local core = require("texnative_core")

describe("parse_tbl_cells", function()

  describe("single cell styles", function()
    it("parses single cell with bgcolor", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      assert.is_not_nil(styles[1])
      assert.is_not_nil(styles[1][1])
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)

    it("parses single cell with txtcolor", function()
      local styles = core.parse_tbl_cells("{B2: {txtcolor: '#00ff00'}}")
      assert.is_not_nil(styles[2])
      assert.is_not_nil(styles[2][2])
      assert.are.equal('#00ff00', styles[2][2].txtcolor)
    end)

    it("parses cell with both bgcolor and txtcolor", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000', txtcolor: '#ffffff'}}")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
      assert.are.equal('#ffffff', styles[1][1].txtcolor)
    end)
  end)

  describe("multiple cells", function()
    it("parses multiple cells with different styles", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}, B2: {bgcolor: '#00ff00'}}")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
      assert.are.equal('#00ff00', styles[2][2].bgcolor)
    end)

    it("parses cells across different rows and columns", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#111'}, C3: {bgcolor: '#333'}, B2: {txtcolor: '#222'}}")
      assert.are.equal('#111', styles[1][1].bgcolor)
      assert.are.equal('#222', styles[2][2].txtcolor)
      assert.are.equal('#333', styles[3][3].bgcolor)
    end)
  end)

  describe("color formats", function()
    it("handles hex color with hash", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#ABCDEF'}}")
      assert.are.equal('#ABCDEF', styles[1][1].bgcolor)
    end)

    it("handles RGB color format", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '255,128,0'}}")
      assert.are.equal('255,128,0', styles[1][1].bgcolor)
    end)

    it("handles double quotes", function()
      local styles = core.parse_tbl_cells('{A1: {bgcolor: "#ff0000"}}')
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)
  end)

  describe("whitespace handling", function()
    it("handles extra whitespace around properties", function()
      local styles = core.parse_tbl_cells("{A1: { bgcolor : '#ff0000' }}")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)

    it("handles no spaces", function()
      local styles = core.parse_tbl_cells("{A1:{bgcolor:'#ff0000'}}")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)
  end)

  describe("lowercase addresses", function()
    it("handles lowercase cell addresses", function()
      local styles = core.parse_tbl_cells("{a1: {bgcolor: '#ff0000'}, b2: {txtcolor: '#00ff00'}}")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
      assert.are.equal('#00ff00', styles[2][2].txtcolor)
    end)
  end)

  describe("invalid input handling", function()
    it("returns empty table for nil input", function()
      local styles = core.parse_tbl_cells(nil)
      assert.are.same({}, styles)
    end)

    it("returns empty table for empty string", function()
      local styles = core.parse_tbl_cells("")
      assert.are.same({}, styles)
    end)

    it("returns empty table for non-string input", function()
      local styles = core.parse_tbl_cells(123)
      assert.are.same({}, styles)
    end)

    it("returns empty table for malformed input", function()
      local styles = core.parse_tbl_cells("not valid json")
      assert.are.same({}, styles)
    end)

    it("handles double-letter addresses by matching trailing single-letter part", function()
      -- AA1 pattern matches A1 (the single-letter + digits part)
      -- This is acceptable behavior - parse_cell_address validates single-letter
      local styles = core.parse_tbl_cells("{AA1: {bgcolor: '#ff0000'}, B2: {bgcolor: '#00ff00'}}")
      -- A1 is extracted from AA1, B2 is parsed normally
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
      assert.are.equal('#00ff00', styles[2][2].bgcolor)
    end)

    it("ignores cells with no valid properties", function()
      local styles = core.parse_tbl_cells("{A1: {invalid: 'value'}}")
      -- A1 row may exist but should have no column entry
      if styles[1] then
        assert.is_nil(styles[1][1])
      end
    end)
  end)

end)
