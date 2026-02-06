-- Unit tests for parse_tbl_cells function
-- Tests parsing of JSON-like cell styles configuration

-- Set up package path to find our modules
package.path = package.path .. ";./tests/?.lua;./tests/mocks/?.lua;./_extensions/texnative/?.lua"

-- Load the pandoc mock first
local pandoc = require("mocks.pandoc")
_G.pandoc = pandoc

-- Now load the core module
local core = require("texnative_core")

describe("parse_tbl_cells", function()
  describe("valid JSON-like input", function()
    it("parses single cell with bgcolor only", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}}")
      assert.is_not_nil(styles[1])
      assert.is_not_nil(styles[1][1])
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)

    it("parses single cell with txtcolor only", function()
      local styles = core.parse_tbl_cells("{B2: {txtcolor: '#00ff00'}}")
      assert.is_not_nil(styles[2])
      assert.is_not_nil(styles[2][2])
      assert.are.equal('#00ff00', styles[2][2].txtcolor)
    end)

    it("parses single cell with both bgcolor and txtcolor", function()
      local styles = core.parse_tbl_cells("{C3: {bgcolor: '#ffffff', txtcolor: '#000000'}}")
      assert.is_not_nil(styles[3])
      assert.is_not_nil(styles[3][3])
      assert.are.equal('#ffffff', styles[3][3].bgcolor)
      assert.are.equal('#000000', styles[3][3].txtcolor)
    end)

    it("parses multiple cells", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#ff0000'}, B2: {bgcolor: '#00ff00'}, C3: {txtcolor: '#0000ff'}}")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
      assert.are.equal('#00ff00', styles[2][2].bgcolor)
      assert.are.equal('#0000ff', styles[3][3].txtcolor)
    end)

    it("parses with single quotes", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#aabbcc'}}")
      assert.are.equal('#aabbcc', styles[1][1].bgcolor)
    end)

    it("parses with double quotes", function()
      local styles = core.parse_tbl_cells('{A1: {bgcolor: "#aabbcc"}}')
      assert.are.equal('#aabbcc', styles[1][1].bgcolor)
    end)

    it("handles RGB format (comma-separated)", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '255,128,0'}}")
      assert.are.equal('255,128,0', styles[1][1].bgcolor)
    end)
  end)

  describe("edge cases with whitespace", function()
    it("handles extra whitespace around braces", function()
      local styles = core.parse_tbl_cells("  { A1: { bgcolor: '#ff0000' } }  ")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)

    it("handles no spaces", function()
      local styles = core.parse_tbl_cells("{A1:{bgcolor:'#ff0000'}}")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)
  end)

  describe("lowercase cell addresses", function()
    it("parses lowercase a1", function()
      local styles = core.parse_tbl_cells("{a1: {bgcolor: '#ff0000'}}")
      assert.are.equal('#ff0000', styles[1][1].bgcolor)
    end)

    it("parses mixed case b2", function()
      local styles = core.parse_tbl_cells("{b2: {txtcolor: '#00ff00'}}")
      assert.are.equal('#00ff00', styles[2][2].txtcolor)
    end)
  end)

  describe("invalid/malformed input", function()
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

    it("returns empty table for malformed JSON (no braces in inner)", function()
      local styles = core.parse_tbl_cells("{A1: bgcolor: '#ff0000'}")
      assert.are.same({}, styles)
    end)

    it("ignores invalid cell addresses", function()
      local styles = core.parse_tbl_cells("{AA1: {bgcolor: '#ff0000'}, A1: {bgcolor: '#00ff00'}}")
      -- AA1 should be ignored, only A1 should be parsed
      assert.is_nil(styles[27])  -- AA would be column 27 if supported
      assert.are.equal('#00ff00', styles[1][1].bgcolor)
    end)
  end)

  describe("empty property handling", function()
    it("returns empty cell object for empty properties", function()
      local styles = core.parse_tbl_cells("{A1: {}}")
      assert.is_not_nil(styles[1])
      assert.is_not_nil(styles[1][1])
      assert.is_nil(styles[1][1].bgcolor)
      assert.is_nil(styles[1][1].txtcolor)
    end)
  end)

  describe("realistic usage scenarios", function()
    it("parses typical table header highlighting", function()
      local styles = core.parse_tbl_cells("{A1: {bgcolor: '#003366', txtcolor: '#ffffff'}, B1: {bgcolor: '#003366', txtcolor: '#ffffff'}}")
      assert.are.equal('#003366', styles[1][1].bgcolor)
      assert.are.equal('#ffffff', styles[1][1].txtcolor)
      assert.are.equal('#003366', styles[2][1].bgcolor)
      assert.are.equal('#ffffff', styles[2][1].txtcolor)
    end)

    it("parses cell for alternating row colors in specific cells", function()
      local styles = core.parse_tbl_cells("{A2: {bgcolor: '#f0f0f0'}, A4: {bgcolor: '#f0f0f0'}}")
      assert.are.equal('#f0f0f0', styles[1][2].bgcolor)
      assert.are.equal('#f0f0f0', styles[1][4].bgcolor)
    end)
  end)
end)
