## ADDED Requirements

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
