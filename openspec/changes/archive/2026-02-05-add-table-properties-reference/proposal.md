# Change: Add Table Properties Reference Section to README

## Why
Users currently need to read through multiple subsections to understand all available table configuration options. A consolidated quick-reference section listing all table properties with their types, defaults, and scopes would improve discoverability and usability.

## What Changes
- Add new "Table Properties Reference" section to README.md
- Consolidate all document-level YAML options and per-table caption properties in one table/list
- Include property names, value formats, defaults, and scope (document vs per-table)

## Impact
- Affected specs: `table-formatting` (documentation requirement)
- Affected code: `README.md`
