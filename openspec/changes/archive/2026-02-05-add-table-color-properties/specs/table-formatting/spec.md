## ADDED Requirements

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
