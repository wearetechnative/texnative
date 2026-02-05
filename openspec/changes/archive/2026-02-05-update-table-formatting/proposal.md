# Change: Update Table Formatting

## Why

The current table formatting implementation in `texnative.lua` has limitations that reduce document quality: cell content is flattened to plain text (losing bold, italic, and links), column widths from Quarto's `tbl-colwidths` attribute are ignored, and caption properties are parsed but never applied. These gaps prevent users from creating professional tables with rich content and precise layout control.

## What Changes

- **Preserve rich text in table cells**: Replace `pandoc.utils.stringify()` with proper LaTeX rendering of inline elements (bold, italic, code, links)
- **Support column widths**: Apply `tbl-colwidths` or `colspecs` width values to generate fixed-width columns using LaTeX `p{}` specifiers
- **Respect caption properties**: Use parsed caption properties to control table behavior (e.g., custom labels, positioning)
- **Update README documentation**: Add instructions for configuring tables, including column widths, rich text formatting, and caption properties

## Impact

- **Affected specs**: `table-formatting` (new capability)
- **Affected code**: `_extensions/texnative/texnative.lua` (functions `get_rows_data` and `generate_tabularray`)
- **Affected docs**: `README.md` (new Tables section)
