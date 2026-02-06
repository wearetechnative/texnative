# Design: Lua Unit Testing Architecture

## Overview

This document captures architectural decisions for adding unit testing to the TexNative Lua filter.

## Testing Layers

```
┌─────────────────────────────────────────────────────┐
│  Integration Tests (Quarto render)                  │
│  - Full pipeline: .qmd → filter → PDF              │
│  - Validates visual output, end-to-end behavior    │
└─────────────────────────────────────────────────────┘
                        ▲
┌─────────────────────────────────────────────────────┐
│  Unit Tests (Busted + mock pandoc)                  │
│  - Isolated function testing                        │
│  - Fast feedback, no Quarto/LaTeX dependency       │
└─────────────────────────────────────────────────────┘
```

## Framework Choice

### Primary: Busted
- BDD-style assertions (`describe`, `it`, `assert.are.equal`)
- Wide adoption in Lua community
- Requires: `luarocks install busted`

### Fallback: LuaUnit
- If Busted installation is problematic on NixOS
- Single-file, zero dependencies
- xUnit-style assertions

## Pandoc API Mocking Strategy

The filter depends heavily on `pandoc.*` functions. For unit tests to run without Pandoc:

### Mock Module (`tests/mocks/pandoc.lua`)

```lua
-- Provides stub implementations of pandoc API
local pandoc = {}

-- Stub pandoc.utils.stringify
pandoc.utils = {
  stringify = function(content)
    if type(content) == "string" then return content end
    if type(content) == "table" and content.text then return content.text end
    return tostring(content)
  end
}

-- Stub pandoc.RawInline
function pandoc.RawInline(format, text)
  return { t = "RawInline", format = format, text = text }
end

-- Additional stubs as needed...
return pandoc
```

### Test Loading Pattern

```lua
-- In test file, load mock before the module under test
package.loaded["pandoc"] = require("tests.mocks.pandoc")
local texnative = require("_extensions.texnative.texnative_testable")
```

## Module Refactoring

To enable unit testing, the filter needs minor refactoring:

### Current Structure
```lua
-- texnative.lua (monolithic)
local function escape_latex(text) ... end
local function hex_to_rgb(hex) ... end
-- All functions local, not exportable
```

### Testable Structure
```lua
-- texnative.lua (entry point, unchanged externally)
local M = require("_extensions.texnative.texnative_core")
function Meta(meta) return M.Meta(meta) end
function Table(tbl) return M.TableFilter(tbl) end

-- texnative_core.lua (testable module)
local M = {}
function M.escape_latex(text) ... end
function M.hex_to_rgb(hex) ... end
-- Functions exported via M table
return M
```

## Directory Structure

```
tests/
├── mocks/
│   └── pandoc.lua           # Mock pandoc API
├── unit/
│   ├── escape_latex_spec.lua
│   ├── hex_to_rgb_spec.lua
│   ├── resolve_color_spec.lua
│   └── render_cell_contents_spec.lua
├── integration/
│   └── table_rendering_spec.lua  # Quarto-based tests
└── busted_config.lua        # Busted configuration
```

## Functions to Test (Priority Order)

| Function | Complexity | Dependencies | Priority |
|----------|------------|--------------|----------|
| `escape_latex` | Low | None | High |
| `hex_to_rgb` | Low | None | High |
| `resolve_color` | Medium | None | High |
| `render_inline_latex` | Medium | pandoc.utils | Medium |
| `render_bullet_list` | Medium | pandoc.RawInline | Medium |
| `render_cell_contents` | High | Multiple pandoc | Medium |
| `get_rows_data` | High | Multiple | Low (integration) |
| `generate_tabularray` | Very High | Full pandoc | Low (integration) |

## Test Runner Integration

### Local Development
```bash
# Run unit tests
busted tests/unit/

# Run integration tests (requires Quarto)
./tests/integration/run_integration.sh
```

### CI/CD (Future)
```yaml
# GitHub Actions example
- run: luarocks install busted
- run: busted tests/unit/
- run: quarto render tests/integration/*.qmd
```

## Trade-offs

### Mock Approach
- **Pro**: Fast tests, no external dependencies
- **Con**: Mocks may drift from real pandoc API

### Mitigation
- Integration tests catch mock drift
- Keep mocks minimal (only what's needed)
- Document pandoc API version assumed

## NixOS Considerations

If Busted installation fails on NixOS:

1. Try `nix-shell -p luaPackages.busted`
2. Fall back to LuaUnit (copy single file to tests/)
3. Document working approach in README
