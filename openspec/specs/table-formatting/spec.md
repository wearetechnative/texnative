# table-formatting Specification

## Purpose
TBD - created by archiving change update-table-formatting. Update Purpose after archive.
## Requirements
### Requirement: Rich Text Cell Content

The table filter SHALL preserve inline formatting within table cells when rendering to LaTeX. Supported inline elements include bold (Strong), italic (Emph), inline code (Code), and hyperlinks (Link).

#### Scenario: Bold text in cell

- **WHEN** a table cell contains `**bold text**`
- **THEN** the LaTeX output SHALL include `\textbf{bold text}`

#### Scenario: Italic text in cell

- **WHEN** a table cell contains `*italic text*`
- **THEN** the LaTeX output SHALL include `\textit{italic text}`

#### Scenario: Inline code in cell

- **WHEN** a table cell contains `` `code` ``
- **THEN** the LaTeX output SHALL include `\texttt{code}`

#### Scenario: Hyperlink in cell

- **WHEN** a table cell contains `[link text](https://example.com)`
- **THEN** the LaTeX output SHALL include `\href{https://example.com}{link text}`

#### Scenario: Mixed formatting

- **WHEN** a table cell contains `**bold** and *italic*`
- **THEN** the LaTeX output SHALL include both `\textbf{bold}` and `\textit{italic}` in sequence

### Requirement: Column Width Support

The table filter SHALL respect column width specifications from Quarto's `tbl-colwidths` attribute or from the table's `colspecs` width values.

#### Scenario: Explicit column widths via tbl-colwidths

- **WHEN** a table has caption attribute `{tbl-colwidths="[50,25,25]"}`
- **THEN** the LaTeX output SHALL use proportional column widths (e.g., `p{0.5\linewidth}`, `p{0.25\linewidth}`, `p{0.25\linewidth}`)

#### Scenario: No width specified

- **WHEN** a table has no `tbl-colwidths` attribute and no width in colspecs
- **THEN** the LaTeX output SHALL use automatic-width alignment specifiers (`l`, `c`, `r`)

### Requirement: Caption Property Support

The table filter SHALL apply caption properties parsed from the table caption to configure table output.

#### Scenario: Table with label property

- **WHEN** a table caption contains `{#tbl-myid}`
- **THEN** the LaTeX output SHALL include `\label{tbl-myid}` for cross-referencing

#### Scenario: Table with caption text

- **WHEN** a table has a non-empty caption (excluding property block)
- **THEN** the LaTeX output SHALL include `\caption{caption text}` within a table environment

### Requirement: Table Configuration Documentation

The README SHALL document how to configure tables, including column widths, rich text formatting, and caption properties.

#### Scenario: Documentation covers column widths

- **WHEN** a user reads the README Tables section
- **THEN** they SHALL find instructions for setting column widths using `tbl-colwidths` attribute with example markdown

#### Scenario: Documentation covers rich text in cells

- **WHEN** a user reads the README Tables section
- **THEN** they SHALL find a list of supported inline formatting (bold, italic, code, links) with example syntax

#### Scenario: Documentation covers caption properties

- **WHEN** a user reads the README Tables section
- **THEN** they SHALL find instructions for adding captions and labels for cross-referencing

### Requirement: Table Header Background Color Configuration

The table filter SHALL support configurable header background colors at both document and per-table levels.

#### Scenario: Document-level header color via YAML

- **WHEN** the document YAML contains `table-header-bgcolor: "255,0,0"`
- **THEN** all table headers SHALL use RGB(255,0,0) as background color instead of the theme default

#### Scenario: Per-table header color via caption property

- **WHEN** a table caption contains `{tbl-header-bgcolor="0,128,255"}`
- **THEN** that table's header SHALL use RGB(0,128,255) as background color, overriding any document-level setting

#### Scenario: No header color specified

- **WHEN** neither document YAML nor caption specifies a header color
- **THEN** the table header SHALL use the theme default `tableheaderbgcolor`

#### Scenario: Dark background theme default header color

- **WHEN** `dark_background: true` is set and no custom header color is specified
- **THEN** the table header SHALL use `#471d00` as the default background color

### Requirement: Table Body Background Color Configuration

The table filter SHALL support configurable body background colors at both document and per-table levels.

#### Scenario: Document-level body color via YAML

- **WHEN** the document YAML contains `table-body-bgcolor: "240,240,240"`
- **THEN** all table body rows SHALL use RGB(240,240,240) as background color

#### Scenario: Per-table body color via caption property

- **WHEN** a table caption contains `{tbl-body-bgcolor="255,255,200"}`
- **THEN** that table's body rows SHALL use RGB(255,255,200) as background color

#### Scenario: No body color specified

- **WHEN** neither document YAML nor caption specifies a body color
- **THEN** the table body rows SHALL have no background color (transparent)

#### Scenario: Dark background theme default body color

- **WHEN** `dark_background: true` is set and no custom body color is specified
- **THEN** the table body rows SHALL use `#6d2b00` as the default background color

### Requirement: Table Color Documentation

The README SHALL document how to configure table header and body background colors.

#### Scenario: Documentation covers YAML options

- **WHEN** a user reads the README Tables section
- **THEN** they SHALL find instructions for `table-header-bgcolor` and `table-body-bgcolor` YAML options with RGB format

#### Scenario: Documentation covers caption properties

- **WHEN** a user reads the README Tables section
- **THEN** they SHALL find instructions for `tbl-header-bgcolor` and `tbl-body-bgcolor` caption properties with examples

### Requirement: Table Properties Reference Documentation

The README SHALL include a dedicated "Table Properties Reference" section that consolidates all available table configuration options in a quick-reference format, listing property names, value formats, defaults, and scope.

#### Scenario: User looks up document-level table properties

- **WHEN** a user reads the "Table Properties Reference" section
- **THEN** they SHALL find a reference listing all document-level YAML properties (`table-header-bgcolor`, `table-body-bgcolor`) with their value formats and default values

#### Scenario: User looks up per-table caption properties

- **WHEN** a user reads the "Table Properties Reference" section
- **THEN** they SHALL find a reference listing all per-table caption properties (`tbl-colwidths`, `tbl-header-bgcolor`, `tbl-body-bgcolor`, `#tbl-label`) with their value formats and usage examples

#### Scenario: User understands property precedence

- **WHEN** a user reads the "Table Properties Reference" section
- **THEN** they SHALL find documentation explaining that per-table properties override document-level properties, which override theme defaults

### Requirement: Document-level Table Style Defaults

Tables SHALL support document-level YAML properties for text color, border, padding, and alignment that apply to all tables unless overridden. When `dark_background: true`, text colors SHALL default to white and border color SHALL default to a warm brown (#8b4513).

#### Scenario: Dark background sets default text colors

- **GIVEN** a document with `dark_background: true` and no explicit text color settings
- **WHEN** a table is rendered
- **THEN** header and body text SHALL default to white for readability

#### Scenario: Dark background sets default border color

- **GIVEN** a document with `dark_background: true` and no explicit border color
- **WHEN** a table is rendered
- **THEN** the border color SHALL default to #8b4513 (warm brown)

#### Scenario: Document-level text color applies to all tables

- **GIVEN** a document with `table-header-txtcolor: "0,100,200"` in YAML
- **WHEN** multiple tables are rendered
- **THEN** all table headers SHALL use the specified blue text color

### Requirement: Table Text Color Properties

Tables SHALL support text color configuration via document-level YAML properties (`table-header-txtcolor`, `table-body-txtcolor`) and per-table caption properties (`tbl-header-txtcolor`, `tbl-body-txtcolor`), using the same RGB/hex format as background color properties.

#### Scenario: User sets header text color per-table

- **GIVEN** a table with caption property `tbl-header-txtcolor="255,255,255"`
- **WHEN** the document is rendered
- **THEN** the header row text SHALL be rendered in white (#FFFFFF)

#### Scenario: User sets body text color per-table

- **GIVEN** a table with caption property `tbl-body-txtcolor="#336699"`
- **WHEN** the document is rendered
- **THEN** the body row text SHALL be rendered in the specified blue color

#### Scenario: Per-table text color overrides document-level

- **GIVEN** a document with `table-body-txtcolor: "0,0,0"` and a table with `tbl-body-txtcolor="255,0,0"`
- **WHEN** the document is rendered
- **THEN** that table's body text SHALL be red, overriding the document default

### Requirement: Table Border Properties

Tables SHALL support border configuration via document-level YAML properties (`table-border-color`, `table-border-width`) and per-table caption properties (`tbl-border-color`, `tbl-border-width`). Border width uses pt units and 0 is allowed for no border.

#### Scenario: User sets custom border color

- **GIVEN** a table with caption property `tbl-border-color="100,100,100"`
- **WHEN** the document is rendered
- **THEN** the table borders SHALL be rendered in gray (#646464)

#### Scenario: User removes borders

- **GIVEN** a table with caption property `tbl-border-width="0"`
- **WHEN** the document is rendered
- **THEN** the table SHALL have no visible borders

#### Scenario: User sets thick borders

- **GIVEN** a table with caption property `tbl-border-width="2"`
- **WHEN** the document is rendered
- **THEN** the table borders SHALL be 2pt thick

### Requirement: Table Cell Padding Property

Tables SHALL support cell padding configuration via document-level YAML property (`table-cell-padding`) and per-table caption property (`tbl-cell-padding`). Padding uses pt units.

#### Scenario: User sets cell padding

- **GIVEN** a table with caption property `tbl-cell-padding="10"`
- **WHEN** the document is rendered
- **THEN** the table cells SHALL have 10pt padding

### Requirement: Table Horizontal Alignment Property

Tables SHALL support horizontal placement configuration via document-level YAML property (`table-alignment`) and per-table caption property (`tbl-alignment`) with values `left`, `center`, or `right`.

#### Scenario: User centers a table

- **GIVEN** a table with caption property `tbl-alignment="center"`
- **WHEN** the document is rendered
- **THEN** the table SHALL be horizontally centered on the page

#### Scenario: User right-aligns a table

- **GIVEN** a table with caption property `tbl-alignment="right"`
- **WHEN** the document is rendered
- **THEN** the table SHALL be aligned to the right margin

