## 1. Document-level YAML Properties (Meta function)
- [x] 1.1 Add `table-header-txtcolor` to Meta function with dark_background default (white)
- [x] 1.2 Add `table-body-txtcolor` to Meta function with dark_background default (white)
- [x] 1.3 Add `table-border-color` to Meta function with dark_background default (#8b4513)
- [x] 1.4 Add `table-border-width` to Meta function (default: 0.4pt)
- [x] 1.5 Add `table-cell-padding` to Meta function (default: 6pt)
- [x] 1.6 Add `table-alignment` to Meta function (default: left)

## 2. Per-table Caption Properties (generate_tabularray function)
- [x] 2.1 Add caption property parsing for `tbl-header-txtcolor` (reuse resolve_color pattern)
- [x] 2.2 Add caption property parsing for `tbl-body-txtcolor` (reuse resolve_color pattern)
- [x] 2.3 Add caption property parsing for `tbl-border-color` (reuse resolve_color pattern)
- [x] 2.4 Add caption property parsing for `tbl-border-width` (numeric, pt unit)
- [x] 2.5 Add caption property parsing for `tbl-cell-padding` (numeric, pt unit)
- [x] 2.6 Add caption property parsing for `tbl-alignment` (left/center/right enum)

## 3. LaTeX Output Generation
- [x] 3.1 Apply text colors using LaTeX `\textcolor` command in cell output
- [x] 3.2 Apply border styling using `\arrayrulewidth` and `\arrayrulecolor`
- [x] 3.3 Apply cell padding using `\setlength{\tabcolsep}` or tabularray options
- [x] 3.4 Apply table alignment using LaTeX centering/flushleft/flushright

## 4. Documentation Update
- [x] 4.1 Add new document-level properties to "Table Properties Reference" in README.md
- [x] 4.2 Add new per-table properties to "Table Properties Reference" in README.md
- [x] 4.3 Add usage examples for text color, border, padding, and alignment

## 5. Validation
- [x] 5.1 Create test table in template.qmd exercising all new properties
- [x] 5.2 Render template.qmd and verify PDF output
- [x] 5.3 Test edge cases: border-width=0, alignment variations, dark_background defaults
