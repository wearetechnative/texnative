# documentation Specification

## Purpose
TBD - created by archiving change consolidate-documentation. Update Purpose after archive.
## Requirements
### Requirement: Documentation Directory Structure
The project SHALL maintain a `docs/` subdirectory containing all detailed documentation files.

#### Scenario: Documentation files organized in docs directory
- **WHEN** a user looks for detailed documentation
- **THEN** configuration reference, table formatting, and other detailed docs are found in `docs/`

#### Scenario: Root README remains minimal
- **WHEN** a user views the project root
- **THEN** README.md contains project overview, installation instructions, and links to docs/

### Requirement: Configuration Reference Documentation
The project SHALL provide a dedicated configuration reference document at `docs/configuration.md`.

#### Scenario: YAML frontmatter options documented
- **WHEN** a user needs to configure the TexNative extension
- **THEN** they can find all YAML options documented in `docs/configuration.md`

### Requirement: Table Formatting Documentation
The project SHALL provide table formatting documentation at `docs/table-formatting.md`.

#### Scenario: Table styling options documented
- **WHEN** a user wants to style tables in their document
- **THEN** they can find table formatting syntax and options in `docs/table-formatting.md`

### Requirement: Example Files Location
Example files (example_*.qmd) SHALL remain in the project root during the transition period.

#### Scenario: Published example links preserved
- **WHEN** external links point to example files in the repository root
- **THEN** the example files are accessible at their current root location

