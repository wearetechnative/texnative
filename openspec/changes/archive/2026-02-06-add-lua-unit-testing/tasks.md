# Tasks: Add Lua Unit Testing

## Phase 1: Infrastructure Setup

- [x] **Task 1**: Install and verify Busted framework
  - Run `luarocks install busted` or `nix-shell -p luaPackages.busted`
  - Verify with `busted --version`
  - Document NixOS-specific setup if needed
  - **Fallback**: Download LuaUnit if Busted fails

- [x] **Task 2**: Create test directory structure
  - Create `tests/mocks/`, `tests/unit/`
  - Add `.busted` config file for project settings

- [x] **Task 3**: Create pandoc mock module
  - Implement `tests/mocks/pandoc.lua`
  - Stub `pandoc.utils.stringify`, `pandoc.RawInline`, `pandoc.RawBlock`
  - Add stubs for other pandoc functions as needed during test development

## Phase 2: Module Refactoring

- [x] **Task 4**: Extract testable core module
  - Create `_extensions/texnative/texnative_core.lua`
  - Move function implementations to core module with exports
  - Keep `texnative.lua` as thin wrapper importing from core
  - **Validation**: Run `quarto render template.qmd` to verify no regression

## Phase 3: Unit Test Implementation

- [x] **Task 5**: Write escape_latex tests
  - Test all LaTeX special characters: `\ & % $ # _ { } ~ ^`
  - Test empty string, nil input, normal text
  - Test combined special characters

- [x] **Task 6**: Write hex_to_rgb tests
  - Test standard hex: `#ff0000` → `255,0,0`
  - Test lowercase/uppercase: `#aabbcc`, `#AABBCC`
  - Test without hash: `ff0000`
  - Test edge cases: `#000000`, `#ffffff`

- [x] **Task 7**: Write resolve_color tests
  - Test hex color input
  - Test RGB tuple input
  - Test nil with default fallback
  - Test invalid color handling

- [x] **Task 8**: Write render_inline_latex tests (with mocks)
  - Test Str elements
  - Test Strong/Emph elements
  - Test Space elements
  - Test mixed inline sequences

## Phase 4: Documentation & Validation

- [x] **Task 9**: Add test runner script
  - Create `tests/run_tests.sh` for convenience
  - Support both Busted and LuaUnit execution

- [x] **Task 10**: Update project documentation
  - Add testing section to README or docs/
  - Document how to run tests
  - Document how to add new tests

- [x] **Task 11**: Final validation
  - Run full unit test suite
  - Run `quarto render template.qmd` for integration check
  - Verify no regressions in PDF output

## Dependencies

```
Task 1 ─┬─► Task 2 ─► Task 3 ─► Task 4 ─┬─► Tasks 5-8 (parallelizable)
        │                               │
        └───────────────────────────────┴─► Task 9 ─► Task 10 ─► Task 11
```

## Verification Criteria

- `busted tests/unit/` exits with code 0
- All unit tests pass
- `quarto render template.qmd` produces identical output to before refactoring
