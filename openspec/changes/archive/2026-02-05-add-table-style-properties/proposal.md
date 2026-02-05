# Change: Add Table Style Properties

## Why
Users need finer control over table appearance beyond background colors. Currently tables lack options for text color, border styling, cell padding, and horizontal alignment. These properties are essential for professional document design and brand consistency.

## What Changes
Add six new table properties at both document-level (YAML) and per-table (caption) scope, following the existing pattern for background colors:

**Document-level YAML properties:**

| Property | Format | Default (light) | Default (dark) | Description |
|----------|--------|-----------------|----------------|-------------|
| `table-header-txtcolor` | RGB/Hex | Black | White | Header text color |
| `table-body-txtcolor` | RGB/Hex | Black | White | Body text color |
| `table-border-color` | RGB/Hex | Black | `#8b4513` | Border color |
| `table-border-width` | Number (pt) | 0.4 | 0.4 | Border width (0 = none) |
| `table-cell-padding` | Number (pt) | 6 | 6 | Cell padding |
| `table-alignment` | left/center/right | left | left | Horizontal placement |

**Per-table caption properties:**

| Property | Format | Description |
|----------|--------|-------------|
| `tbl-header-txtcolor` | RGB/Hex | Override header text color for this table |
| `tbl-body-txtcolor` | RGB/Hex | Override body text color for this table |
| `tbl-border-color` | RGB/Hex | Override border color for this table |
| `tbl-border-width` | Number (pt) | Override border width for this table |
| `tbl-cell-padding` | Number (pt) | Override cell padding for this table |
| `tbl-alignment` | left/center/right | Override alignment for this table |

All color properties use the same RGB/hex format as existing `tbl-header-bgcolor` and `tbl-body-bgcolor`. Per-table properties override document-level, which override theme defaults.

## Impact
- Affected specs: `table-formatting`
- Affected code: `_extensions/texnative/texnative.lua` (Meta function, generate_tabularray function)
- Affected partials: `_extensions/texnative/partials/page-cover.tex` (dark background defaults)
- Affected docs: `README.md` (Table Properties Reference section)
