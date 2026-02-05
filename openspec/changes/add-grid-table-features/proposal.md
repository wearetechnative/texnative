# Change: Add Grid Table Advanced Features

## Why
Grid tables in TexNative currently render with basic content support, but Pandoc's grid table syntax supports advanced features that are not yet rendered correctly:
- Column alignment via colon syntax in separator lines (e.g., `+==============:+:==============+:==================:+`)
- Block content within cells (bullet lists, multiple paragraphs)
- Hard line breaks within cell content

This limits the expressiveness of tables in professional documents.

## What Changes
- Add support for column alignment specified via Pandoc's colon syntax in grid table separator lines
- Add support for block content (bullet lists, multiple paragraphs) within table cells
- Ensure hard line breaks within cell content render correctly

## Pandoc Grid Table Alignment Syntax
Alignment is specified with colons at column boundaries in the header separator line:
- Right-aligned: `+==============:+`
- Left-aligned: `+:==============+`
- Centered: `+:==============:+`
- Default (no colons): `+===============+`

For headerless tables, colons go on the top line instead.

## Test File
The file `example_grid_tables.qmd` (sourced from Pandoc documentation) serves as the test document for validating all grid table features. It includes examples of:
- Basic grid tables with bullet lists in cells
- Cell spanning (multiple columns/rows)
- Multi-row headers
- Column alignment via colon syntax
- Headerless tables with alignment
- Table footers

## Impact
- Affected specs: `table-formatting`
- Affected code: `_extensions/texnative/texnative.lua` (table filter)
- Test document: `example_grid_tables.qmd`
