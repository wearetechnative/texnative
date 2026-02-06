# Tasks: add-cell-styling

## Phase 1: Core Infrastructure

- [x] **1.1** Add `parse_cell_address(addr)` function to convert Excel-style addresses (A1, B2) to (col, row) indices
  - Handle columns A-Z (single letter for now, 26 columns max)
  - Handle row numbers 1-99
  - Return nil for invalid addresses

- [x] **1.2** Add `parse_tbl_cells(str)` function to parse the JSON-like cell styles config
  - Parse `{A1: {bgcolor: '#fff', txtcolor: '#000'}, B2: {...}}`
  - Build lookup table: `cell_styles[col][row] = {bgcolor=..., txtcolor=...}`
  - Handle missing/invalid entries gracefully

- [x] **1.3** Unit tests for `parse_cell_address()`
  - Test valid addresses: A1, B2, Z99, a1 (lowercase)
  - Test invalid addresses: 1A, AA1, A0, A100, empty string, nil
  - Test boundary cases: A1 (minimum), Z99 (maximum supported)
  - _Depends on_: 1.1

- [x] **1.4** Unit tests for `parse_tbl_cells()`
  - Test valid JSON-like input with single cell
  - Test valid input with multiple cells
  - Test bgcolor only, txtcolor only, both combined
  - Test invalid/malformed input (graceful handling)
  - Test empty input
  - _Depends on_: 1.2

## Phase 2: Rendering Integration

- [x] **2.1** Extend `get_rows_data()` to accept optional `cell_styles` parameter
  - Track current row index during iteration
  - Pass cell position to cell renderer
  - _Depends on_: 1.3, 1.4

- [x] **2.2** Modify cell rendering to apply per-cell styles
  - Lookup cell in `cell_styles` by (col, row)
  - Override section colors with cell colors when present
  - Apply `\cellcolor{}` and `\textcolor{}` per cell
  - _Depends on_: 2.1

- [x] **2.3** Parse `tbl-cells` from caption properties in `generate_tabularray()`
  - Extract from caption like other `tbl-*` properties
  - Pass to `get_rows_data()` for header and body
  - _Depends on_: 2.1, 2.2

- [x] **2.4** Unit tests for cell rendering integration
  - Test single cell bgcolor applied correctly in LaTeX output
  - Test single cell txtcolor applied correctly in LaTeX output
  - Test combined bgcolor + txtcolor on same cell
  - Test cell style overrides section-level style
  - Test multiple cells with different styles
  - Test cell outside table bounds (should be ignored)
  - _Depends on_: 2.3

## Phase 3: Documentation & Testing

- [x] **3.1** Add cell styling examples to `examples/individual_table_cell_styling.qmd`
  - Single cell bgcolor
  - Single cell txtcolor
  - Combined bgcolor + txtcolor
  - Multiple cells styled
  - Cell styles combined with section-level styles
  - _Depends on_: 2.4

- [x] **3.2** Update `docs/table-formatting.md` with cell styling reference
  - Cell address syntax explanation
  - Configuration examples
  - Precedence documentation
  - _Depends on_: 3.1

- [x] **3.3** Full render validation
  - Render all example files
  - Visual verification of cell styles
  - _Depends on_: 3.1, 3.2

## Phase 4: Inline RGB Default Colors Fix

- [x] **4.1** Fix default header/body colors to use inline RGB instead of named colors
  - Changed `tableheaderbgcolor` reference to inline `{RGB}{221,221,221}` for light mode
  - Changed `tableheaderbgcolor` reference to inline `{RGB}{71,29,0}` for dark mode
  - Changed `tablebodybgcolor` reference to inline `{RGB}{109,43,0}` for dark mode
  - This eliminates dependency on predefined named colors in LaTeX template partials

- [x] **4.2** Unit tests for inline RGB default colors
  - Test resolve_color with hex color input returns inline RGB format
  - Test resolve_color with RGB string input returns inline RGB format  
  - Test resolve_color returns default when nil/empty color provided
  - Test default light mode header color (221,221,221)
  - Test default dark mode header color (71,29,0)
  - Test default dark mode body color (109,43,0)
  - _Depends on_: 4.1

## Parallelization Notes

- Tasks 1.1 and 1.2 can run in parallel
- Tasks 1.3 and 1.4 can run in parallel (after their respective implementations)
- Phase 2 tasks are sequential (dependency chain)
- Phase 3 tasks can start after 2.4, documentation in parallel with examples
