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

**Key Constraint**: No new LaTeX packages required. The existing `\cellcolor[RGB]{r,g,b}` and `\textcolor[RGB]{r,g,b}{content}` commands used for header/body section coloring will be reused for individual cells.

#### Architecture: 2D Cell Properties Array

Before rendering, build a 2D array (`cell_styles[row][col]`) containing all cell properties. This array is populated by:
1. Section-level defaults (tbl-header-bgcolor, tbl-body-bgcolor, etc.)
2. Per-cell overrides from tbl-cells (applied on top)

```
┌─────────────────────────────────────────────────────────────┐
│  Caption Properties                                          │
│  tbl-cells="{A1: {bgcolor: '#ff0000'}, B2: {txtcolor: ...}}"│
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  texnative_core.parse_tbl_cells()                           │
│  - Parse JSON-like string to structured data                │
│  - Use parse_cell_address() to convert A1 → (col=1, row=1)  │
│  - Output: cell_styles[row][col] = {bgcolor, txtcolor}      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  generate_tabularray()                                       │
│  - Build 2D cell_styles array for entire table              │
│  - Initialize with section defaults (header/body colors)    │
│  - Overlay per-cell styles from parsed tbl-cells            │
│  - Pass cell_styles to get_rows_data()                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  get_rows_data(rows, cell_styles, start_row)                │
│  - For each cell at (row, col):                             │
│    - Look up cell_styles[row][col]                          │
│    - Apply bgcolor via \cellcolor[RGB]{r,g,b}               │
│    - Apply txtcolor via \textcolor[RGB]{r,g,b}{content}     │
│  - Same LaTeX commands already used for section colors      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  LaTeX Output (using EXISTING color commands)               │
│  \cellcolor[RGB]{255,0,0}\textcolor[RGB]{255,255,255}{text} │
└─────────────────────────────────────────────────────────────┘
```

#### Key Implementation Details

1. **Reuse existing color infrastructure**: The `resolve_color()` function and `\cellcolor[RGB]{}` / `\textcolor[RGB]{}` commands are already working for section-level styling. Cell styling uses identical LaTeX output.

2. **2D Array Structure**:
   ```lua
   cell_styles[row][col] = {
     bgcolor = "{RGB}{255,0,0}",  -- resolved color format
     txtcolor = "{RGB}{255,255,255}"
   }
   ```

3. **Row numbering**: Unified across header and body. Header row 1 = absolute row 1, body rows continue from header count + 1.

4. **Signature change for get_rows_data()**:
   ```lua
   -- Current signature
   get_rows_data(rows, cell_color, text_color, strong)
   
   -- New signature
   get_rows_data(rows, cell_styles, start_row, strong)
   ```
   The `start_row` parameter indicates the absolute row number of the first row in `rows`, enabling correct lookup in the 2D array.

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
