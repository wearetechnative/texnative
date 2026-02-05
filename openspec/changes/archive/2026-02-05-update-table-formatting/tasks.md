## 1. Preserve Rich Text in Table Cells

- [x] 1.1 Create helper function `render_inline_latex(inlines)` to convert Pandoc inline elements to LaTeX
- [x] 1.2 Support Strong (bold) elements with `\textbf{}`
- [x] 1.3 Support Emph (italic) elements with `\textit{}`
- [x] 1.4 Support Code elements with `\texttt{}`
- [x] 1.5 Support Link elements with `\href{url}{text}`
- [x] 1.6 Replace `pandoc.utils.stringify(cell.contents)` with `render_inline_latex(cell.contents)` in `get_rows_data`
- [x] 1.7 Ensure LaTeX special characters are escaped within rendered content

## 2. Support Column Widths

- [x] 2.1 Modify `generate_tabularray` to read width from `col_spec[2]` (already extracted but unused)
- [x] 2.2 Parse `tbl-colwidths` from caption properties if present
- [x] 2.3 Convert percentage widths to LaTeX `p{Xcm}` or `p{X\linewidth}` column specifiers
- [x] 2.4 Fall back to simple alignment specifiers (`l`, `c`, `r`) when no width is specified

## 3. Respect Caption Properties

- [x] 3.1 Apply parsed `dict` from caption content to table configuration
- [x] 3.2 Support `label` property for cross-references
- [x] 3.3 Output caption with `\caption{}` when present

## 4. Documentation

- [x] 4.1 Add Tables section to `README.md` with overview of table features
- [x] 4.2 Document column width configuration using `tbl-colwidths` attribute
- [x] 4.3 Document supported rich text formatting in cells (bold, italic, code, links)
- [x] 4.4 Document caption properties and cross-referencing with labels
- [x] 4.5 Include example markdown snippets for each feature

## 5. Testing and Validation

- [x] 5.1 Add table examples to `template.qmd` demonstrating rich text cells
- [x] 5.2 Add table example with explicit column widths
- [x] 5.3 Verify PDF renders without LaTeX errors using `quarto render template.qmd`
- [x] 5.4 Visual validation of output against expected formatting
