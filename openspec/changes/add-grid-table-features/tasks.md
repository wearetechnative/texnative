## Test Document
Use `example_grid_tables.qmd` (from Pandoc documentation) as the primary test file for all features.

## 1. Column Alignment Support (via Pandoc colon syntax)
- [ ] 1.1 Verify Pandoc parses colon syntax and populates `tbl.colspecs[i][1]` with alignment values
- [ ] 1.2 Confirm current `generate_tabularray` correctly reads alignment from colspecs
- [ ] 1.3 Test alignment with fixed-width columns (`p{width}`) - may need `\raggedright`/`\centering`/`\raggedleft`
- [ ] 1.4 Verify alignment examples in `example_grid_tables.qmd` render correctly (lines 62-72)

## 2. Block Content Support (Bullet Lists)
- [ ] 2.1 Extend `render_cell_contents` to handle `BulletList` block type
- [ ] 2.2 Generate LaTeX `\begin{itemize}...\end{itemize}` for bullet lists
- [ ] 2.3 Recursively render inline formatting within list items using existing `render_inline_latex`
- [ ] 2.4 Handle nested lists if present in Pandoc AST
- [ ] 2.5 Verify bullet list example in `example_grid_tables.qmd` renders correctly (lines 23-31)

## 3. Hard Line Breaks
- [ ] 3.1 Verify `LineBreak` inline element is correctly rendered as `\\` (exists at line 130)
- [ ] 3.2 Test hard line breaks within grid table cells render correctly in `example_grid_tables.qmd`

## 4. Multiple Paragraphs Support
- [ ] 4.1 Modify `render_cell_contents` to insert paragraph separators between multiple `Para` blocks
- [ ] 4.2 Choose appropriate LaTeX separator (`\\[0.5em]` or `\par`)
- [ ] 4.3 Verify multi-row cell content in `example_grid_tables.qmd` renders correctly

## 5. Documentation
- [ ] 5.1 Add "Advanced Grid Table Features" section to README.md
- [ ] 5.2 Document column alignment colon syntax with grid table examples
- [ ] 5.3 Document bullet list usage in cells with grid table example
- [ ] 5.4 Document hard line break syntax within cells

## 6. Validation
- [ ] 6.1 Run `quarto render example_grid_tables.qmd` to verify no LaTeX errors
- [ ] 6.2 Visually verify PDF output matches expected formatting for all examples
- [ ] 6.3 Test with dark_background: true to ensure colors work with new features
