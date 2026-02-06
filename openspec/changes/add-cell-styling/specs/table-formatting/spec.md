# Spec Delta: table-formatting

## ADDED Requirements

### Requirement: Individual Cell Background Color

The system SHALL allow users to specify a background color for individual cells using Excel-style cell addressing (column letter + row number). Cell styles MUST override section-level styles (header/body) for the targeted cell.

**Properties:**
- Cells are addressed using `A1` syntax where A=first column, 1=first row (header)
- Row numbering is unified: header row(s) start at 1, body rows continue sequentially
- Supports hex colors (#rrggbb) and RGB format (r,g,b)
- Per-cell styles take precedence over `tbl-header-bgcolor` and `tbl-body-bgcolor`

#### Scenario: Single header cell with custom background

Given a table with a header row and body rows
When `tbl-cells="{A1: {bgcolor: '#ff0000'}}"` is specified in the caption
Then cell A1 (first header cell) renders with red background
And other header cells retain the header background color
And body cells retain the body background color

#### Scenario: Body cell background overrides section color

Given a table with `tbl-body-bgcolor="#e0e0e0"` 
When `tbl-cells="{B2: {bgcolor: '#00ff00'}}"` is specified
Then cell B2 (second column, first body row) renders with green background
And other body cells render with gray background (#e0e0e0)

#### Scenario: Multiple cells with different backgrounds

Given a table with 3 columns and 3 rows (1 header + 2 body)
When `tbl-cells="{A1: {bgcolor: '#ff0000'}, C2: {bgcolor: '#00ff00'}, B3: {bgcolor: '#0000ff'}}"` is specified
Then each targeted cell renders with its specified background color
And non-targeted cells retain default or section-level styling

---

### Requirement: Individual Cell Text Color

The system SHALL allow users to specify a text color for individual cells using the same Excel-style addressing. Cell text color MUST override section-level text colors for the targeted cell.

**Properties:**
- Uses same `A1` addressing syntax as background colors
- Supports hex colors (#rrggbb) and RGB format (r,g,b)
- Per-cell text color takes precedence over `tbl-header-txtcolor` and `tbl-body-txtcolor`
- Can be combined with cell background color in same cell spec

#### Scenario: Single cell with custom text color

Given a table with default text colors
When `tbl-cells="{A1: {txtcolor: '#ffffff'}}"` is specified
Then cell A1 text renders in white
And other cells retain default text color

#### Scenario: Cell with both background and text color

Given a table with default styling
When `tbl-cells="{B2: {bgcolor: '#000000', txtcolor: '#ffffff'}}"` is specified
Then cell B2 renders with black background and white text
And other cells retain default styling

---

### Requirement: Cell Addressing with Multi-Row Headers

When a table has multiple header rows (via `tbl-header-rows`), all header rows SHALL be numbered sequentially starting at 1, and body rows MUST continue from there.

**Properties:**
- With `tbl-header-rows: 2`, header cells are rows 1-2, body starts at row 3
- Consistent numbering regardless of header/body boundary
- Matches visual row order from top of table

#### Scenario: Styling cell in second header row

Given a table with `tbl-header-rows: 2`
When `tbl-cells="{A2: {bgcolor: '#ff0000'}}"` is specified
Then cell A2 (first column, second header row) renders with red background
And row 1 (first header row) cells are unaffected

#### Scenario: First body row with multi-row header

Given a table with `tbl-header-rows: 2` and 2 body rows
When `tbl-cells="{A3: {bgcolor: '#00ff00'}}"` is specified
Then cell A3 (first column, first body row) renders with green background
And header rows (1-2) are unaffected

---

### Requirement: Cell Style Precedence

Cell-level styles SHALL have highest precedence, followed by per-table section styles, then document-level styles, then theme defaults.

**Precedence (highest to lowest):**
1. `tbl-cells` individual cell styles
2. Per-table caption properties (`tbl-header-bgcolor`, `tbl-body-bgcolor`, etc.)
3. Document-level YAML (`table.header-bgcolor`, etc.)
4. Theme defaults

#### Scenario: Cell style overrides per-table section style

Given a table with `tbl-header-bgcolor="#cccccc"` in caption
When `tbl-cells="{A1: {bgcolor: '#ff0000'}}"` is also specified
Then cell A1 renders with red background (#ff0000)
And other header cells render with gray background (#cccccc)

#### Scenario: Cell style overrides document-level style

Given document YAML with `table.body-txtcolor: "#333333"`
And a table with `tbl-cells="{B2: {txtcolor: '#ff0000'}}"`
Then cell B2 text renders in red (#ff0000)
And other body cells render with dark gray text (#333333)

---

### Requirement: Invalid Cell Address Handling

Invalid cell addresses (out of bounds, malformed) SHALL be silently ignored without affecting table rendering. A warning MAY be logged for debugging.

**Properties:**
- Addresses beyond table dimensions are ignored (e.g., `Z99` in a 3x3 table)
- Malformed addresses (e.g., `1A`, `AA`, `11`) are ignored
- Table renders successfully with valid addresses applied
- Does not cause rendering errors

#### Scenario: Cell address beyond table bounds

Given a 3-column, 3-row table
When `tbl-cells="{D1: {bgcolor: '#ff0000'}, Z99: {bgcolor: '#00ff00'}}"` is specified
Then the table renders without errors
And no cells have the specified colors (addresses out of bounds)

#### Scenario: Malformed cell address

Given a valid table
When `tbl-cells="{1A: {bgcolor: '#ff0000'}}"` is specified (malformed)
Then the table renders without errors
And no styling is applied from the malformed address

---

### Requirement: Cell Styling with Spanning (Future Compatibility)

When `add-grid-table-spanning` is implemented, cell styles SHALL apply to the anchor cell (top-left) of a spanned region. Covered cells (those hidden by the span) MUST ignore any styles.

**Properties:**
- Anchor cell: top-left cell of a merged region; styles apply here
- Covered cells: cells hidden by rowspan/colspan; styles ignored
- Styling the anchor affects the visual appearance of the entire merged cell
- This requirement becomes active when spanning is available

#### Scenario: Styling anchor cell of spanned region

Given a table with cell A1 spanning 2 columns (A1:B1)
When `tbl-cells="{A1: {bgcolor: '#ff0000'}}"` is specified
Then the entire merged cell renders with red background

#### Scenario: Style on covered cell is ignored

Given a table with cell A1 spanning 2 columns (A1:B1)
When `tbl-cells="{B1: {bgcolor: '#00ff00'}}"` is specified (B1 is covered by A1's span)
Then the merged cell retains default styling
And no error occurs
