# Proposal: Add Individual Cell Styling

## Summary

Add the ability to style individual table cells with custom background colors and text colors, using familiar Excel-style cell addressing (A1, B2, etc.).

## Motivation

Currently, table styling applies uniformly to all cells in a section (header or body). Users need per-cell control for:
- Highlighting specific data points
- Conditional formatting (e.g., status indicators)
- Visual hierarchy within tables
- Custom table designs

## Scope

### In Scope
- New `tbl-cells` YAML property for per-cell `bgcolor` and `txtcolor`
- Excel-style cell addressing (A1, B2) with unified row numbering (headers = row 1)
- Single-cell targeting in initial implementation
- Per-table caption property support

### Out of Scope (Future Work)
- Range syntax (`A1:C3`) - deferred to follow-up proposal
- Wildcard patterns (`A*`, `row:odd`) - deferred
- Document-level cell styles applying to all tables - deferred
- Cell borders, padding, alignment per-cell - deferred

### Non-Goals
- Breaking existing table styling behavior
- Changing the precedence of existing style properties
- Implement future row and column spanning features.

## Design

See [design.md](./design.md) for detailed trade-off analysis on:
- Cell position syntax options
- Header row numbering approaches
- Spanning compatibility strategy

### Key Decisions (Pending User Confirmation)

1. **Cell Syntax**: Excel-style (`A1`, `B2`) - familiar, compact
2. **Header Numbering**: Unified (row 1 = header) - matches visual layout
3. **Spanning**: Anchor cell styling only - covered cells are no-ops

### Configuration Example

```yaml
# Per-table via caption property
| Col A | Col B |
|-------|-------|
| Data  | Data  |

: Example {#tbl-demo tbl-cells="{A1: {bgcolor: '#ff0000', txtcolor: '#ffffff'}, B2: {bgcolor: '#e0e0e0'}}"}
```

## Examples

Example file: [`examples/individual_table_cell_styling.qmd`](../../../examples/individual_table_cell_styling.qmd)

This file demonstrates:
- Single cell background color
- Single cell text color
- Combined bgcolor + txtcolor on one cell
- Multiple cells with different styles
- Cell styles combined with section-level styles

## Dependencies

- Existing `resolve_color()` function for color parsing
- Existing `get_rows_data()` for row iteration
- Related: `add-grid-table-spanning` (for spanning compatibility)

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Complex LaTeX edge cases | Medium | Medium | Comprehensive test matrix |
| Spanning interaction issues | Low | Low | Clear spec for undefined behavior |

## Success Criteria

- [ ] Single cells can be styled via `tbl-cells` property
- [ ] Header and body cells addressable with unified numbering
- [ ] Cell styles override section styles (proper precedence)
- [ ] Documentation updated with examples
- [ ] Existing table tests continue to pass
