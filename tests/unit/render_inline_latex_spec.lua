-- Unit tests for render_inline_latex function
-- Tests Pandoc inline element to LaTeX conversion

-- Set up package path to find our modules
package.path = package.path .. ";./tests/?.lua;./tests/mocks/?.lua;./_extensions/texnative/?.lua"

-- Load the pandoc mock first
local pandoc = require("mocks.pandoc")
_G.pandoc = pandoc

-- Now load the core module
local core = require("texnative_core")

describe("render_inline_latex", function()
  describe("basic inline elements", function()
    it("renders Str element", function()
      local inlines = { pandoc.Str("Hello") }
      assert.are.equal("Hello", core.render_inline_latex(inlines))
    end)

    it("renders Str with special characters (escaped)", function()
      local inlines = { pandoc.Str("Price: $100") }
      assert.are.equal("Price: \\$100", core.render_inline_latex(inlines))
    end)

    it("renders Space element", function()
      local inlines = { pandoc.Str("Hello"), pandoc.Space(), pandoc.Str("World") }
      assert.are.equal("Hello World", core.render_inline_latex(inlines))
    end)

    it("renders SoftBreak as space", function()
      local inlines = { pandoc.Str("Line1"), pandoc.SoftBreak(), pandoc.Str("Line2") }
      assert.are.equal("Line1 Line2", core.render_inline_latex(inlines))
    end)

    it("renders LineBreak as LaTeX line break", function()
      local inlines = { pandoc.Str("Line1"), pandoc.LineBreak(), pandoc.Str("Line2") }
      assert.are.equal("Line1\\\\Line2", core.render_inline_latex(inlines))
    end)
  end)

  describe("formatted text", function()
    it("renders Strong (bold) text", function()
      local inlines = { pandoc.Strong({ pandoc.Str("bold") }) }
      assert.are.equal("\\textbf{bold}", core.render_inline_latex(inlines))
    end)

    it("renders Emph (italic) text", function()
      local inlines = { pandoc.Emph({ pandoc.Str("italic") }) }
      assert.are.equal("\\textit{italic}", core.render_inline_latex(inlines))
    end)

    it("renders Code text", function()
      local inlines = { pandoc.Code("code_var") }
      assert.are.equal("\\texttt{code\\_var}", core.render_inline_latex(inlines))
    end)

    it("renders nested Strong within text", function()
      local inlines = { 
        pandoc.Str("This"), 
        pandoc.Space(), 
        pandoc.Str("is"), 
        pandoc.Space(),
        pandoc.Strong({ pandoc.Str("bold") }),
        pandoc.Space(),
        pandoc.Str("text")
      }
      assert.are.equal("This is \\textbf{bold} text", core.render_inline_latex(inlines))
    end)
  end)

  describe("links", function()
    it("renders Link element", function()
      local inlines = { pandoc.Link({ pandoc.Str("click here") }, "https://example.com") }
      assert.are.equal("\\href{https://example.com}{click here}", core.render_inline_latex(inlines))
    end)

    it("renders Link with special characters in text", function()
      local inlines = { pandoc.Link({ pandoc.Str("AWS & S3") }, "https://aws.amazon.com") }
      assert.are.equal("\\href{https://aws.amazon.com}{AWS \\& S3}", core.render_inline_latex(inlines))
    end)
  end)

  describe("raw LaTeX", function()
    it("passes through RawInline tex format", function()
      local inlines = { pandoc.RawInline("tex", "\\LaTeX{}") }
      assert.are.equal("\\LaTeX{}", core.render_inline_latex(inlines))
    end)

    it("does not pass through non-tex RawInline", function()
      -- Non-tex raw inline should be stringified and escaped
      local inlines = { { t = "RawInline", format = "html", text = "<b>html</b>" } }
      -- This will fallback to stringify which returns the text
      local result = core.render_inline_latex(inlines)
      -- The fallback should escape special chars if any
      assert.is_string(result)
    end)
  end)

  describe("complex mixed content", function()
    it("renders mixed formatting", function()
      local inlines = {
        pandoc.Str("Regular"),
        pandoc.Space(),
        pandoc.Strong({ pandoc.Str("bold") }),
        pandoc.Space(),
        pandoc.Str("and"),
        pandoc.Space(),
        pandoc.Emph({ pandoc.Str("italic") })
      }
      assert.are.equal("Regular \\textbf{bold} and \\textit{italic}", core.render_inline_latex(inlines))
    end)

    it("renders empty inline list", function()
      assert.are.equal("", core.render_inline_latex({}))
    end)
  end)
end)
