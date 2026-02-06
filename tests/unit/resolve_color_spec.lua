-- Unit tests for resolve_color function
-- Tests color resolution logic (hex, RGB, named colors)

-- Set up package path to find our modules
package.path = package.path .. ";./tests/?.lua;./tests/mocks/?.lua;./_extensions/texnative/?.lua"

-- Load the pandoc mock first
local pandoc = require("mocks.pandoc")
_G.pandoc = pandoc

-- Now load the core module
local core = require("texnative_core")

describe("resolve_color", function()
  describe("default color handling", function()
    it("returns default when color_value is nil", function()
      assert.are.equal("defaultcolor", core.resolve_color(nil, "defaultcolor"))
    end)

    it("returns default when color_value is empty string", function()
      assert.are.equal("defaultcolor", core.resolve_color("", "defaultcolor"))
    end)

    it("returns nil default when color_value is nil and default is nil", function()
      assert.is_nil(core.resolve_color(nil, nil))
    end)
  end)

  describe("hex color conversion", function()
    it("converts 6-digit hex without hash", function()
      assert.are.equal("{RGB}{255,0,0}", core.resolve_color("ff0000", "default"))
    end)

    it("converts 6-digit hex with hash", function()
      assert.are.equal("{RGB}{255,0,0}", core.resolve_color("#ff0000", "default"))
    end)

    it("converts uppercase hex", function()
      assert.are.equal("{RGB}{171,205,239}", core.resolve_color("#ABCDEF", "default"))
    end)

    it("converts typical header color (471d00)", function()
      assert.are.equal("{RGB}{71,29,0}", core.resolve_color("471d00", "tableheaderbgcolor"))
    end)
  end)

  describe("RGB string passthrough", function()
    it("passes through valid RGB string (255,0,0)", function()
      assert.are.equal("{RGB}{255,0,0}", core.resolve_color("255,0,0", "default"))
    end)

    it("passes through valid RGB string with various values", function()
      assert.are.equal("{RGB}{71,29,0}", core.resolve_color("71,29,0", "default"))
    end)

    it("passes through RGB string (0,0,0) for black", function()
      assert.are.equal("{RGB}{0,0,0}", core.resolve_color("0,0,0", "default"))
    end)

    it("passes through RGB string (255,255,255) for white", function()
      assert.are.equal("{RGB}{255,255,255}", core.resolve_color("255,255,255", "default"))
    end)
  end)

  describe("invalid color values", function()
    it("returns default for invalid hex (too short)", function()
      assert.are.equal("default", core.resolve_color("fff", "default"))
    end)

    it("returns default for invalid hex (non-hex chars)", function()
      assert.are.equal("default", core.resolve_color("gggggg", "default"))
    end)

    it("returns default for random string", function()
      assert.are.equal("default", core.resolve_color("notacolor", "default"))
    end)

    it("returns nil default for invalid color when default is nil", function()
      assert.is_nil(core.resolve_color("invalid", nil))
    end)
  end)
end)
