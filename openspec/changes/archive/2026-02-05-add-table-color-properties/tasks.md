## 1. Document-Level Color Configuration

- [x] 1.1 Store document metadata in module-level variable accessible from `Table` filter
- [x] 1.2 Read `table-header-color` from document metadata in `Meta` filter
- [x] 1.3 Read `table-body-color` from document metadata in `Meta` filter
- [x] 1.4 Read `dark_background` from document metadata to determine theme defaults

## 2. Dark Background Theme Defaults

- [x] 2.1 Set default header color to `#471d00` when `dark_background: true`
- [x] 2.2 Set default body color to `#6d2b00` when `dark_background: true`
- [x] 2.3 Update `document-colors.tex` to define `tablebodybgcolor` for dark background theme

## 3. Per-Table Color Properties

- [x] 3.1 Parse `tbl-header-color` from caption properties in `generate_tabularray`
- [x] 3.2 Parse `tbl-body-color` from caption properties in `generate_tabularray`

## 4. Apply Colors in Table Generation

- [x] 4.1 Create helper function to define inline LaTeX color from RGB/hex string
- [x] 4.2 Use per-table header color if specified, else document-level, else theme default
- [x] 4.3 Pass resolved header color to `get_rows_data` for header rows
- [x] 4.4 Use per-table body color if specified, else document-level, else theme default (or none for light)
- [x] 4.5 Pass resolved body color to `get_rows_data` for body rows

## 5. Documentation

- [x] 5.1 Add YAML options documentation to README Tables section
- [x] 5.2 Add caption properties documentation to README Tables section
- [x] 5.3 Document dark background default colors in README
- [x] 5.4 Include examples showing both document-level and per-table usage

## 6. Testing

- [x] 6.1 Add table example with custom header color to `template.qmd`
- [x] 6.2 Add table example with custom body color to `template.qmd`
- [x] 6.3 Verify PDF renders without LaTeX errors
- [x] 6.4 Visual validation of custom colors in output
