# Change: Add Table Color Properties

## Why

Currently, table header background color is hardcoded to `tableheaderbgcolor` (defined per theme in document-colors.tex), and table body rows have no background color option. Users need flexibility to customize these colors per-table or set document-wide defaults for consistent branding.

## What Changes

- **Document-level YAML options**: Add `table-header-bgcolor` and `table-body-bgcolor` metadata options to override theme defaults
- **Per-table caption properties**: Add `tbl-header-bgcolor` and `tbl-body-bgcolor` attributes in table captions to override document defaults for individual tables
- **Dark background theme defaults**: When `dark_background: true`, use header color `#471d00` and body color `#6d2b00` as defaults
- **Update README**: Document the new color configuration options

## Impact

- **Affected specs**: `table-formatting` (modified)
- **Affected code**: 
  - `_extensions/texnative/texnative.lua` - Parse new properties and apply colors
  - `_extensions/texnative/partials/document-colors.tex` - Update dark background table colors (header: #471d00, body: #6d2b00)
- **Affected docs**: `README.md` - Document new color options
