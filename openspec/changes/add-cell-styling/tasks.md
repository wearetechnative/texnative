# Tasks: add-cell-styling

## Phase 1: Core Parsing Functions (texnative_core.lua)

- [ ] **1.1** Add `parse_cell_address(addr)` function to texnative_core.lua
  - Convert Excel-style addresses (A1, B2) to (col, row) indices
  - Handle columns A-Z (single letter, 26 columns max)
  - Handle row numbers 1-99
  - Support lowercase (a1 → col=1, row=1)
  - Return nil, nil for invalid addresses

- [ ] **1.2** Add `parse_tbl_cells(str)` function to texnative_core.lua
  - Parse JSON-like config: `"{A1: {bgcolor: '#fff'}, B2: {txtcolor: '#000'}}"`
  - Build 2D lookup table: `cell_styles[row][col] = {bgcolor=..., txtcolor=...}`
  - Use parse_cell_address() for address conversion
  - Handle missing/invalid entries gracefully (return empty table)

- [ ] **1.3** Unit tests for `parse_cell_address()`
  - Valid: A1→(1,1), B2→(2,2), Z99→(26,99), a1→(1,1)
  - Invalid: 1A, AA1, A0, A100, "", nil, "$A$1"
  - _File_: tests/unit/parse_cell_address_spec.lua
  - _Depends on_: 1.1

- [ ] **1.4** Unit tests for `parse_tbl_cells()`
  - Single cell with bgcolor
  - Multiple cells with different styles
  - Combined bgcolor + txtcolor
  - Hex and RGB color formats
  - Invalid/malformed input returns {}
  - _File_: tests/unit/parse_tbl_cells_spec.lua
  - _Depends on_: 1.2

## Phase 2: 2D Cell Styles Array & Rendering

- [ ] **2.1** Build 2D cell_styles array in `generate_tabularray()`
  - Parse `tbl-cells` from caption properties
  - Create `cell_styles[row][col]` structure
  - Initialize with section defaults (tbl-header-bgcolor, tbl-body-bgcolor, etc.)
  - Overlay per-cell styles from parsed tbl-cells
  - Use `resolve_color()` to convert all colors to LaTeX format
  - _Depends on_: 1.4

- [ ] **2.2** Modify `get_rows_data()` signature and implementation
  - Change from: `get_rows_data(rows, cell_color, text_color, strong)`
  - Change to: `get_rows_data(rows, cell_styles, start_row, strong)`
  - `start_row` = absolute row number of first row in `rows` (1 for header, header_count+1 for body)
  - Lookup colors per-cell: `cell_styles[start_row + row_idx - 1][col_idx]`
  - Apply `\cellcolor[RGB]{r,g,b}` and `\textcolor[RGB]{r,g,b}{content}` per cell
  - _Note_: Reuses existing LaTeX color commands, no new packages needed
  - _Depends on_: 2.1

- [ ] **2.3** Integration tests for cell styling
  - Single cell bgcolor in LaTeX output
  - Single cell txtcolor in LaTeX output
  - Combined bgcolor + txtcolor on same cell
  - Cell style overrides section-level style
  - Multiple cells across header and body
  - Cell outside table bounds (ignored)
  - Multi-row headers with unified row numbering
  - _File_: tests/unit/cell_styling_integration_spec.lua
  - _Depends on_: 2.2

## Phase 3: Documentation & Validation

- [ ] **3.1** Verify example file renders correctly
  - Render `example_table_cell_styling.qmd` to PDF
  - Visual verification of all cell styling scenarios
  - _Depends on_: 2.3

- [ ] **3.2** Update documentation (if needed)
  - Cell address syntax (A1, B2, etc.)
  - tbl-cells configuration format
  - Precedence rules (cell > table > document > theme)
  - _Depends on_: 3.1

## Implementation Notes

### No New LaTeX Packages
The existing `\cellcolor[RGB]{r,g,b}` and `\textcolor[RGB]{r,g,b}{content}` commands already work for section-level styling. Cell styling uses the same commands.

### 2D Array Approach
```lua
-- cell_styles structure
cell_styles[row][col] = {
  bgcolor = "{RGB}{255,0,0}",   -- resolved LaTeX color format
  txtcolor = "{RGB}{255,255,255}"
}

-- Usage in get_rows_data
local style = cell_styles[abs_row] and cell_styles[abs_row][col]
if style and style.bgcolor then
  cell_content = "\\cellcolor" .. style.bgcolor .. cell_content
end
```

### Row Numbering
Unified across header and body:
- Header row 1 = absolute row 1
- Body rows start at header_count + 1
- tbl-cells addresses use absolute row numbers

## Parallelization Notes

- Tasks 1.1 and 1.2 can run in parallel
- Tasks 1.3 and 1.4 can run in parallel (after their implementations)
- Phase 2 tasks are sequential (2.1 → 2.2 → 2.3)
- Phase 3 can start after 2.3
