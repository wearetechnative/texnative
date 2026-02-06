-- Unit tests for escape_latex function
-- Tests LaTeX special character escaping

-- Set up package path to find our modules
package.path = package.path .. ";./tests/?.lua;./tests/mocks/?.lua;./_extensions/texnative/?.lua"

-- Load the pandoc mock first (sets up global pandoc)
local pandoc = require("mocks.pandoc")
_G.pandoc = pandoc

-- Now load the core module
local core = require("texnative_core")

describe("escape_latex", function()
  describe("single special characters", function()
    it("escapes backslash", function()
      assert.are.equal("\\textbackslash{}", core.escape_latex("\\"))
    end)

    it("escapes ampersand", function()
      assert.are.equal("\\&", core.escape_latex("&"))
    end)

    it("escapes percent", function()
      assert.are.equal("\\%", core.escape_latex("%"))
    end)

    it("escapes dollar", function()
      assert.are.equal("\\$", core.escape_latex("$"))
    end)

    it("escapes hash", function()
      assert.are.equal("\\#", core.escape_latex("#"))
    end)

    it("escapes underscore", function()
      assert.are.equal("\\_", core.escape_latex("_"))
    end)

    it("escapes opening brace", function()
      assert.are.equal("\\{", core.escape_latex("{"))
    end)

    it("escapes closing brace", function()
      assert.are.equal("\\}", core.escape_latex("}"))
    end)

    it("escapes tilde", function()
      assert.are.equal("\\textasciitilde{}", core.escape_latex("~"))
    end)

    it("escapes caret", function()
      assert.are.equal("\\textasciicircum{}", core.escape_latex("^"))
    end)
  end)

  describe("plain text without special characters", function()
    it("returns empty string unchanged", function()
      assert.are.equal("", core.escape_latex(""))
    end)

    it("returns plain text unchanged", function()
      assert.are.equal("Hello World", core.escape_latex("Hello World"))
    end)

    it("preserves numbers", function()
      assert.are.equal("12345", core.escape_latex("12345"))
    end)
  end)

  describe("mixed content", function()
    it("escapes special chars in mixed text", function()
      assert.are.equal("Price: \\$100", core.escape_latex("Price: $100"))
    end)

    it("escapes multiple different special chars", function()
      assert.are.equal("10\\% \\& 20\\%", core.escape_latex("10% & 20%"))
    end)

    it("escapes all special characters in one string", function()
      local input = "\\&%$#_{}~^"
      local expected = "\\textbackslash{}\\&\\%\\$\\#\\_\\{\\}\\textasciitilde{}\\textasciicircum{}"
      assert.are.equal(expected, core.escape_latex(input))
    end)

    it("handles realistic table content with special chars", function()
      local input = "AWS S3 bucket_name & region"
      local expected = "AWS S3 bucket\\_name \\& region"
      assert.are.equal(expected, core.escape_latex(input))
    end)

    it("handles currency and percentages", function()
      local input = "Revenue: $1000 (50% growth)"
      local expected = "Revenue: \\$1000 (50\\% growth)"
      assert.are.equal(expected, core.escape_latex(input))
    end)
  end)
end)
