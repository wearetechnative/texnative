# Project Context

## Purpose
TexNative is a modern, customizable Quarto extension for creating professional business documents (reports, quotations, letters, agreements). It provides branded PDF output with support for cover pages, letterheads, dark/light themes, and corporate identity customization.

## Tech Stack
- **Quarto** - Publishing system for scientific and technical documents
- **LaTeX** - Underlying typesetting engine for PDF generation
- **Lua** - Pandoc filters for document processing and table formatting
- **YAML** - Configuration and front matter
- **Bash** - Build scripts and automation (RUNME.sh)

## Project Conventions

### Code Style
- Lua filters follow Pandoc filter conventions with clear function separation
- LaTeX partials are organized by concern (colors, background, header-footer, text-style)
- YAML configuration uses snake_case for custom options (e.g., `cover_page`, `dark_background`)
- Comments should explain the "why" not just the "what"

### Architecture Patterns
- **Extension-based architecture**: Core functionality in `_extensions/texnative/`
- **Partial templates**: LaTeX components split into reusable partials in `partials/`
- **Filter pipeline**: Lua filters process document before LaTeX rendering
- **Asset management**: Images and backgrounds in `images/` with format-resources declarations

### Testing Strategy
- **Unit tests**: Lua core functions tested with Busted framework (`busted tests/unit/` or `./tests/run_tests.sh`)
  - Tests for `escape_latex`, `hex_to_rgb`, `resolve_color`, `render_inline_latex`
  - Mock Pandoc API in `tests/mocks/pandoc.lua` enables testing without Quarto runtime
  - Run via `nix-shell -p luaPackages.busted --run "busted tests/unit/"` on NixOS
- **Render tests**: Verify documents render to PDF without errors using `quarto render`
- **Visual validation**: Check generated PDFs against expected output (screenshots provided)
- **Template validation**: Use `template.qmd` as reference implementation

### Git Workflow
- **GitHub Flow**: Feature branches with pull requests to main
- **Simple commit messages**: Plain English descriptions of changes
- **No formal branching model**: Direct feature branches off main

## Domain Context
- **Business documents**: Reports, agreements, quotations, letters
- **Corporate identity**: Customizable letterheads, cover pages, and branding
- **Print-ready output**: A4 papersize, proper margins, professional typography
- **TechNative internal use**: Extension designed for TechNative's document workflow

## Important Constraints
- Must produce valid LaTeX that compiles without errors
- Background images must be properly referenced in format-resources
- Table formatting must escape special LaTeX characters (%, &, etc.)
- Date formatting follows "DD Mon YYYY" pattern

## External Dependencies
- **Quarto**: Required for document rendering (`quarto use template`)
- **LaTeX distribution**: TeX Live or similar for PDF compilation
- **Pandoc**: Bundled with Quarto, used for document conversion
- **Optional**: LibreOffice for DOCX export with macro support
