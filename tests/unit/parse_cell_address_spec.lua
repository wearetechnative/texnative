-- Unit tests for parse_cell_address function

package.path = package.path .. ";./tests/mocks/?.lua"
require("pandoc")

package.path = package.path .. ";./_extensions/texnative/?.lua"
local core = require("texnative_core")

describe("parse_cell_address", function()

  describe("valid addresses", function()
    it("parses A1 to col=1, row=1", function()
      local col, row = core.parse_cell_address("A1")
      assert.are.equal(1, col)
      assert.are.equal(1, row)
    end)

    it("parses B2 to col=2, row=2", function()
      local col, row = core.parse_cell_address("B2")
      assert.are.equal(2, col)
      assert.are.equal(2, row)
    end)

    it("parses Z99 to col=26, row=99", function()
      local col, row = core.parse_cell_address("Z99")
      assert.are.equal(26, col)
      assert.are.equal(99, row)
    end)

    it("handles lowercase a1 to col=1, row=1", function()
      local col, row = core.parse_cell_address("a1")
      assert.are.equal(1, col)
      assert.are.equal(1, row)
    end)

    it("handles lowercase z50 to col=26, row=50", function()
      local col, row = core.parse_cell_address("z50")
      assert.are.equal(26, col)
      assert.are.equal(50, row)
    end)

    it("parses single digit row C5", function()
      local col, row = core.parse_cell_address("C5")
      assert.are.equal(3, col)
      assert.are.equal(5, row)
    end)
  end)

  describe("invalid addresses", function()
    it("returns nil,nil for reversed format 1A", function()
      local col, row = core.parse_cell_address("1A")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for double-letter columns AA1", function()
      local col, row = core.parse_cell_address("AA1")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for row 0", function()
      local col, row = core.parse_cell_address("A0")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for row 100 (exceeds max)", function()
      local col, row = core.parse_cell_address("A100")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for empty string", function()
      local col, row = core.parse_cell_address("")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for nil input", function()
      local col, row = core.parse_cell_address(nil)
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for non-string input", function()
      local col, row = core.parse_cell_address(123)
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for Excel absolute reference $A$1", function()
      local col, row = core.parse_cell_address("$A$1")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for address with spaces", function()
      local col, row = core.parse_cell_address(" A1")
      assert.is_nil(col)
      assert.is_nil(row)
    end)

    it("returns nil,nil for address with special characters", function()
      local col, row = core.parse_cell_address("A1!")
      assert.is_nil(col)
      assert.is_nil(row)
    end)
  end)

end)
