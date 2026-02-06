# Proposal: Add Lua Unit Testing

**Change ID**: `add-lua-unit-testing`  
**Status**: Draft  
**Created**: 2026-02-06

## Summary

Add unit testing infrastructure for the TexNative Lua filter (`texnative.lua`) using Busted framework with a hybrid approach: mocked pandoc API for fast unit tests plus Quarto-based integration tests.

## Motivation

Currently, the only testing approach is manual visual validation via `quarto render`. This proposal adds:

- Fast, automated unit tests for pure functions
- Regression detection before rendering
- Confidence for refactoring
- Foundation for CI/CD integration

## Scope

### In Scope
- Busted test framework setup (LuaUnit fallback for NixOS)
- Mock pandoc module for isolated testing
- Unit tests for core functions (escape_latex, hex_to_rgb, resolve_color, etc.)
- Minor refactoring to make functions exportable/testable
- Test runner scripts

### Out of Scope
- Full integration test suite (existing render tests remain)
- CI/CD pipeline setup (future proposal)
- Code coverage reporting

## Approach

### Hybrid Testing Strategy
1. **Unit tests**: Test pure functions with mocked pandoc API
2. **Integration tests**: Existing Quarto render tests for end-to-end validation

### Module Refactoring
Extract testable functions to `texnative_core.lua` module while keeping `texnative.lua` as the Quarto entry point (no breaking changes to filter interface).

## Configuration

### Test Execution
```bash
# Run all unit tests
busted tests/unit/

# Run specific test file
busted tests/unit/escape_latex_spec.lua

# NixOS alternative
nix-shell -p luaPackages.busted --run "busted tests/unit/"
```

### Directory Structure
```
tests/
├── mocks/pandoc.lua         # Mock pandoc API
├── unit/                    # Unit test specs
└── busted_config.lua        # Framework config
```

## Affected Components

| Component | Change |
|-----------|--------|
| `_extensions/texnative/texnative.lua` | Minor refactor to import from core |
| `_extensions/texnative/texnative_core.lua` | New: exportable functions |
| `tests/` | New: test infrastructure |

## Related Changes

- None (foundational testing infrastructure)

## Risks

| Risk | Mitigation |
|------|------------|
| Mock pandoc drifts from real API | Integration tests catch drift |
| Busted install issues on NixOS | LuaUnit fallback documented |
| Refactoring introduces bugs | Incremental changes, render validation |
