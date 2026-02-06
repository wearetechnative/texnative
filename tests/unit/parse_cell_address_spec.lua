-- Unit tests for parse_cell_address function
-- Tests Excel-style cell address parsing (A1, B2, etc.)

-- Set up package path to find our modules
package.path = package.path .. ";./tests/?.lua;./tests/mocks/?.lua;./_extensions/texnative/?.lua"

-- Load the pandoc mock first
local pandoc = require("mocks.pandoc")
_G.pandoc = pandoc

-- Now load the core module
local core = require("texnative_core")

describe("parse_cell_address", function()
  describe("valid addresses", function()
    it("parses A1 as col=1, row=1", function()
      local col, row = core.parse_cell_address("A1")
      assert.are.equal(1, col)
      assert.are.equal(1, row)
    end)

    it("parses B2 as col=2, row=2", function()
      local col, row = core.parse_cell_address("B2")
      assert.are.equal(2, col)
      assert.are.equal(2, row)
    end)

    it("parses Z99 as col=26, row=99 (maximum supported)", function()
      local col, row = core.parse_cell_address("Z99")
      assert.are.equal(26, col)
      assert.are.equal(99, row)
    end)

    it("parses lowercase a1 as col=1, row=1", function()
      local col, row = core.parse_cell_address("a1")
      assert.are.equal(1, col)
      assert.are.equal(1, row)
    end)

    it("parses lowercase z50 as col=26, row=50", function()
      local col, row = core.parse_cell_address("z50")
      assert.are.equal(26, col)
      assert.are.equal(50, row)
    end)

    it("parses M15 as col=13, row=15", function()
      local col, row = core.parse_cell_address("M15")
      assert.are.equal(13, col)
      assert.are.equal(15, row)
    end)
  end)

  describe("invalid addresses", function()
    it("returns nil for reversed format 1A", function()
      local col, row = core.parse_cell_address("1A")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil for double-letter column AA1", function()
      local col, row = core.parse_cell_address("AA1")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil for row 0 (A0)", function()
      local col, row = core.parse_cell_address("A0")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil for row 100 (A100)", function()
      local col, row = core.parse_cell_address("A100")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil for empty string", function()
      local col, row = core.parse_cell_address("")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil for nil input", function()
      local col, row = core.parse_cell_address(nil)
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil for number input", function()
      local col, row = core.parse_cell_address(123)
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil for special characters", function()
      local col, row = core.parse_cell_address("$A$1")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil for space in address", function()
      local col, row = core.parse_cell_address("A 1")
      assert.is_nil(col)
      assert.is_nil(row)
    end)
  end)

  describe("boundary cases", function()
    it("handles minimum valid address A1", function()
      local col, row = core.parse_cell_address("A1")
      assert.are.equal(1, col)
      assert.are.equal(1, row)
    end)

    it("handles maximum supported address Z99", function()
      local col, row = core.parse_cell_address("Z99")
      assert.are.equal(26, col)
      assert.are.equal(99, row)
    end)

    it("handles single-digit row", function()
      local col, row = core.parse_cell_address("C5")
      assert.are.equal(3, col)
      assert.are.equal(5, row)
    end)

    it("handles double-digit row", function()
      local col, row = core.parse_cell_address("D42")
      assert.are.equal(4, col)
      assert.are.equal(42, row)
    end)
  end)
end)
