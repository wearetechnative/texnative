# Change: Add Grid Table Row Spanning and Multi-Row Headers

## Why
Pandoc's grid table syntax supports cells spanning multiple rows and headers with multiple rows, but TexNative currently renders these as flat tables without the spanning structure. This limits the ability to create complex professional tables with grouped data.

## What Changes
- Add support for cells spanning multiple rows (rowspan) in grid tables using LaTeX `\multirow`
- Add support for table headers with multiple rows, preserving the header structure
- Update the table filter to detect and render rowspan/colspan attributes from Pandoc's table model

## Impact
- Affected specs: `table-formatting`
- Affected code: `_extensions/texnative/texnative.lua` (get_rows_data and generate_tabularray functions)
- Test document: `example_grid_tables.qmd` contains examples at lines 57-82
