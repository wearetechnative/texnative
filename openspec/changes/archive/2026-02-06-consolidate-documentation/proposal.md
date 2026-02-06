# Change: Consolidate Documentation to Subdirectory

## Why
Documentation files are scattered in the root directory, making the project structure unclear and complicating future SSG website generation. Consolidating documentation into a dedicated `docs/` subdirectory prepares the project for Quarto-based documentation rendering.

## What Changes
- Create `docs/` subdirectory for all documentation files
- Move configuration reference documentation from README.md to `docs/configuration.md`
- Move table formatting documentation from README.md to `docs/table-formatting.md`
- Keep README.md minimal with project overview, installation, and links to examples
- Keep example files (`.qmd`) in root (they will be moved separately in ~1 week due to existing published links)

## Non-Goals
- SSG website implementation (deferred to subsequent proposal)
- Moving example files (they stay in root for now due to published links)
- Selecting Quarto documentation template (deferred to SSG proposal)

## Impact
- Affected specs: documentation (new capability)
- Affected files: README.md, new docs/ directory structure
- No breaking changes to extension functionality
- Prepares foundation for future SSG website in GitHub Actions
