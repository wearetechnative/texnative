# testing Specification

## Purpose
TBD - created by archiving change add-lua-unit-testing. Update Purpose after archive.
## Requirements
### Requirement: Test Framework Setup

The project SHALL provide a configured Lua testing framework (Busted primary, LuaUnit fallback) that can execute unit tests without requiring Pandoc or Quarto runtime.

#### Scenario: Run unit tests with Busted
- **Given** Busted is installed via luarocks or nix-shell
- **When** the user runs `busted tests/unit/`
- **Then** all unit test specs execute and report pass/fail status

#### Scenario: Fallback to LuaUnit on NixOS
- **Given** Busted installation fails on NixOS
- **When** the user runs `lua tests/run_tests.lua`
- **Then** LuaUnit executes all unit tests and reports results

---

### Requirement: Pandoc API Mocking

The test infrastructure SHALL provide mock implementations of pandoc API functions sufficient to test filter functions in isolation.

#### Scenario: Mock pandoc.utils.stringify
- **Given** a test file loads the pandoc mock module
- **When** a function under test calls `pandoc.utils.stringify(content)`
- **Then** the mock returns a string representation without requiring real Pandoc

#### Scenario: Mock pandoc.RawInline
- **Given** a test file loads the pandoc mock module
- **When** a function calls `pandoc.RawInline("latex", "\\textbf{x}")`
- **Then** the mock returns a table structure compatible with test assertions

---

### Requirement: Testable Module Structure

The Lua filter code SHALL be structured to export functions for unit testing while maintaining backward compatibility with Quarto filter interface.

#### Scenario: Import functions for testing
- **Given** the `texnative_core.lua` module exists
- **When** a test file requires the module
- **Then** functions like `escape_latex`, `hex_to_rgb`, `resolve_color` are accessible

#### Scenario: Quarto filter compatibility preserved
- **Given** the refactored `texnative.lua` entry point
- **When** Quarto renders a document with `format: texnative-pdf`
- **Then** the filter processes tables identically to before refactoring

---

### Requirement: Core Function Unit Tests

The project SHALL include unit tests for pure/isolated functions with high coverage of edge cases.

#### Scenario: Test escape_latex function
- **Given** the escape_latex unit test spec
- **When** tests run for inputs containing `%`, `&`, `\`, `$`, `#`, `_`, `{`, `}`, `~`, `^`
- **Then** all special characters are correctly escaped for LaTeX

#### Scenario: Test hex_to_rgb function
- **Given** the hex_to_rgb unit test spec
- **When** tests run for inputs like `#ff0000`, `#00FF00`, `000000`
- **Then** correct RGB values are returned (255,0,0), (0,255,0), (0,0,0)

#### Scenario: Test resolve_color function
- **Given** the resolve_color unit test spec
- **When** tests run for hex colors, RGB tuples, and nil values
- **Then** valid LaTeX color definitions are generated or defaults applied

