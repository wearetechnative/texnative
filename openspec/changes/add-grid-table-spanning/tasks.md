## 1. Implementation
- [x] 1.1 Add LaTeX `multirow` package import to the extension (if not already present)
- [x] 1.2 Modify `get_rows_data` function to detect and handle `rowspan` attribute on cells
- [x] 1.3 Generate `\multirow{n}{*}{content}` LaTeX for cells with rowspan > 1
- [x] 1.4 Skip rendering placeholder cells that are part of a rowspan (empty cells in subsequent rows)
- [x] 1.5 Support multi-row headers by processing `tbl.head.rows` with rowspan handling

## 2. Testing
- [x] 2.1 Verify "Table width cell spanning over multiple rows" (example_grid_tables.qmd:57-67) renders correctly
- [x] 2.2 Verify "Table width header with multiple rows" (example_grid_tables.qmd:71-82) renders correctly
- [x] 2.3 Test that existing simple tables continue to work (regression test)
- [x] 2.4 Test rowspan combined with existing features (colors, borders, alignment)

## 3. Documentation
- [x] 3.1 Update README.md to document row spanning support in grid tables
- [x] 3.2 Update README.md to document multi-row header support
- [x] 3.3 Add examples showing the grid table syntax for rowspan

## 4. Final Validation
- [x] 4.1 Run `quarto render example_grid_tables.qmd` to verify no LaTeX errors
- [x] 4.2 Visual inspection of generated PDF matches expected output
