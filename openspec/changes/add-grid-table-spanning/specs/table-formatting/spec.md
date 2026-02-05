## ADDED Requirements

### Requirement: Grid Table Row Spanning

The table filter SHALL render grid table cells that span multiple rows using LaTeX `\multirow` commands, preserving the visual grouping of data across rows.

#### Scenario: Cell spanning two rows

- **GIVEN** a grid table with a cell that spans two rows (using Pandoc grid table syntax with merged row boundaries)
- **WHEN** the document is rendered
- **THEN** the LaTeX output SHALL include `\multirow{2}{*}{content}` for the spanning cell
- **AND** subsequent rows SHALL have empty placeholders in that column position

#### Scenario: Cell spanning three or more rows

- **GIVEN** a grid table with a cell that spans three or more rows
- **WHEN** the document is rendered
- **THEN** the LaTeX output SHALL include `\multirow{n}{*}{content}` where n is the number of rows spanned
- **AND** all placeholder positions in subsequent rows SHALL be empty

#### Scenario: Row spanning with styling

- **GIVEN** a grid table with row-spanning cells and custom colors/borders
- **WHEN** the document is rendered
- **THEN** the spanning cells SHALL preserve the table's color and border settings

### Requirement: Multi-Row Table Headers

The table filter SHALL support table headers that contain multiple rows, rendering each header row appropriately with header styling.

#### Scenario: Header with two rows

- **GIVEN** a grid table where the header section (above the `===` separator) contains two rows
- **WHEN** the document is rendered
- **THEN** both header rows SHALL be rendered with header styling (background color, text formatting)

#### Scenario: Multi-row header with cell spanning

- **GIVEN** a grid table header with cells spanning multiple rows or columns
- **WHEN** the document is rendered
- **THEN** the spanning cells in the header SHALL be rendered with `\multirow` and header styling applied

#### Scenario: Multi-row header with mixed alignment

- **GIVEN** a grid table with a multi-row header where different columns have different alignments
- **WHEN** the document is rendered
- **THEN** each column SHALL maintain its specified alignment across all header rows

### Requirement: Grid Table Spanning Documentation

The README SHALL document how to create grid tables with row-spanning cells and multi-row headers.

#### Scenario: Documentation covers row spanning syntax

- **WHEN** a user reads the README Tables section
- **THEN** they SHALL find instructions for creating cells that span multiple rows using Pandoc grid table syntax with examples

#### Scenario: Documentation covers multi-row headers

- **WHEN** a user reads the README Tables section
- **THEN** they SHALL find instructions for creating table headers with multiple rows using grid table syntax with examples
