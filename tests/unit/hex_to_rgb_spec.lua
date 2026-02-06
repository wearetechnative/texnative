-- Unit tests for hex_to_rgb function
-- Tests hexadecimal color to RGB conversion

-- Set up package path to find our modules
package.path = package.path .. ";./tests/?.lua;./tests/mocks/?.lua;./_extensions/texnative/?.lua"

-- Load the pandoc mock first
local pandoc = require("mocks.pandoc")
_G.pandoc = pandoc

-- Now load the core module
local core = require("texnative_core")

describe("hex_to_rgb", function()
  describe("valid 6-digit hex colors", function()
    it("converts black (000000)", function()
      assert.are.equal("0,0,0", core.hex_to_rgb("000000"))
    end)

    it("converts white (ffffff)", function()
      assert.are.equal("255,255,255", core.hex_to_rgb("ffffff"))
    end)

    it("converts white uppercase (FFFFFF)", function()
      assert.are.equal("255,255,255", core.hex_to_rgb("FFFFFF"))
    end)

    it("converts pure red (ff0000)", function()
      assert.are.equal("255,0,0", core.hex_to_rgb("ff0000"))
    end)

    it("converts pure green (00ff00)", function()
      assert.are.equal("0,255,0", core.hex_to_rgb("00ff00"))
    end)

    it("converts pure blue (0000ff)", function()
      assert.are.equal("0,0,255", core.hex_to_rgb("0000ff"))
    end)

    it("converts mixed color (471d00)", function()
      assert.are.equal("71,29,0", core.hex_to_rgb("471d00"))
    end)

    it("converts another mixed color (a5c4d4)", function()
      assert.are.equal("165,196,212", core.hex_to_rgb("a5c4d4"))
    end)
  end)

  describe("hex colors with hash prefix", function()
    it("strips leading hash and converts (#ff0000)", function()
      assert.are.equal("255,0,0", core.hex_to_rgb("#ff0000"))
    end)

    it("handles hash with uppercase (#ABCDEF)", function()
      assert.are.equal("171,205,239", core.hex_to_rgb("#ABCDEF"))
    end)
  end)

  describe("invalid hex colors", function()
    it("returns nil for empty string", function()
      assert.is_nil(core.hex_to_rgb(""))
    end)

    it("returns nil for 3-digit hex (short form)", function()
      assert.is_nil(core.hex_to_rgb("fff"))
    end)

    it("returns nil for 5-digit hex", function()
      assert.is_nil(core.hex_to_rgb("12345"))
    end)

    it("returns nil for 7-digit hex", function()
      assert.is_nil(core.hex_to_rgb("1234567"))
    end)

    it("returns nil for non-hex characters", function()
      assert.is_nil(core.hex_to_rgb("gggggg"))
    end)
  end)
end)
