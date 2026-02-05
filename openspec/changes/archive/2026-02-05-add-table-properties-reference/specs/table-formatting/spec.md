## ADDED Requirements

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
