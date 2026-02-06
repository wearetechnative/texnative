# Design: Individual Cell Styling

## Problem Statement

Currently, table styling in TexNative applies uniformly to entire sections (all header cells or all body cells). Users need to style individual cells for emphasis, conditional formatting, or visual hierarchy.

## Design Decisions

### 1. Cell Position Syntax

**Decision Required**: How do we reference individual cells?

| Option | Example | Pros | Cons |
|--------|---------|------|------|
| **Excel-style (Recommended)** | `A1`, `B3`, `A1:C3` | Familiar to users, compact, supports ranges naturally | Column letters limited (AA+ for >26 cols) |
| RC notation | `R1C1`, `R2C3` | Explicit, unlimited | Verbose, less familiar |
| Tuple notation | `(1,1)`, `(2,3)` | Pure numeric | Requires parsing, no range syntax |

**Recommendation**: Excel-style (`A1`, `B2`) because:
- Universally familiar from spreadsheets
- Natural range syntax (`A1:C3`)
- Tables rarely exceed 26 columns
- Matches mental model of visual table layout

### 2. Header Row Numbering

**Decision Required**: Do header cells count as row 1, or have separate numbering?

| Option | Header Cell | First Body Cell | Rationale |
|--------|-------------|-----------------|-----------|
| **Unified (Recommended)** | `A1` | `A2` | Matches visual layout, simpler mental model |
| Separate sections | `HA1` or header-specific | `A1` | Matches internal header/body separation |

**Recommendation**: Unified numbering because:
- What you see is what you address
- Row 1 = first visible row (header)
- No need to know internal structure
- Consistent with spreadsheet conventions

### 3. Spanning Compatibility

**Decision Required**: How does cell styling interact with future rowspan/colspan?

| Scenario | Behavior |
|----------|----------|
| Style `A1` which spans to `B2` | Style applies to entire spanned region |
| Style `B1` which is covered by span from `A1` | **Ignored** - covered cells have no independent existence |

**Recommendation**: Target anchor cell only
- Styling a cell that is the anchor of a span: style applies to entire merged region
- Styling coordinates covered by a span: no effect (those cells don't exist visually)
- Document this behavior explicitly in spec

### 4. Property Naming Convention

Following existing patterns (`tbl-header-bgcolor`, `tbl-body-txtcolor`):

```yaml
# New per-cell properties
tbl-cells:
  A1:
    bgcolor: "#ff0000"
    txtcolor: "#ffffff"
  B2:C4:
    bgcolor: "#e0e0e0"
```

Alternative considered: caption property syntax
```markdown
{#tbl-example tbl-cell-A1-bgcolor="#ff0000"}
```
**Rejected**: Too verbose for multiple cells, hard to read.

### 5. Implementation Approach

```
┌─────────────────────────────────────────────────────────────┐
│  YAML Frontmatter / Caption Properties                      │
│  tbl-cells: {A1: {bgcolor: "#ff0000"}, ...}                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Meta() Filter                                              │
│  - Parse tbl-cells into cell_styles lookup table            │
│  - Key: "col,row" → Value: {bgcolor, txtcolor}              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  get_rows_data()                                            │
│  - For each cell, check cell_styles[col..","..row]          │
│  - If match: apply cell-specific colors                     │
│  - Else: fall back to section colors (header/body)          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  LaTeX Output                                               │
│  \cellcolor[HTML]{FF0000} \textcolor[HTML]{FFFFFF}{content} │
└─────────────────────────────────────────────────────────────┘
```

### 6. Precedence Rules

Most specific wins:
1. **Per-cell style** (`tbl-cells.A1.bgcolor`)
2. Per-table section style (`tbl-header-bgcolor` in caption)
3. Document-level section style (`tbl-header-bgcolor` in YAML)
4. Theme defaults

## Open Questions for User

1. **Range support in v1?** Should `A1:C3` work in initial implementation, or defer to follow-up?
2. **Conditional patterns?** Future support for `row:odd`, `col:2`, `A*` wildcards?
3. **Per-table vs document-level?** Should `tbl-cells` work at document level (all tables)?

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Complex LaTeX generation | Extensive test cases for edge combinations |
| Spanning interaction bugs | Clear spec that covered cells are no-ops |
| Performance with many styled cells | Defer optimization until measured |
