## ADDED Requirements

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
