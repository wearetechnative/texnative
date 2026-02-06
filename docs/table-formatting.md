# Table Formatting

TeXnative includes a custom table filter that renders professional tables with colored headers and proper formatting.

## Basic Tables

Tables support standard markdown syntax with rich text formatting:

```markdown
| Feature    | Description           | Status     |
|:-----------|:---------------------:|------------|
| **Parser** | Handles *all* formats | `complete` |
| Exporter   | [Docs](https://x.com) | _pending_  |
```

### Rich Text in Cells

Table cells preserve inline formatting:

- **Bold**: `**bold text**`
- *Italic*: `*italic text*`
- `Code`: `` `code` ``
- Links: `[text](https://example.com)`

## Column Widths

Control column widths using `tbl-colwidths` in the caption. Values are percentages that should sum to 100 or less:

```markdown
| Name       | Description                          | Price |
|:-----------|:-------------------------------------|------:|
| Widget     | A useful widget for various tasks    |  9.99 |
| Gadget     | An advanced gadget with features     | 19.99 |

: Product catalog {tbl-colwidths="[20,60,20]"}
```

When no widths are specified, columns use automatic sizing.

## Captions and Labels

Add captions and cross-reference labels using Quarto's standard syntax:

```markdown
| Head 1 | Head 2 |
|--------|--------|
| A      | B      |

: My table caption {#tbl-mytable}
```

Reference the table elsewhere with `@tbl-mytable`.

## Custom Colors

### Document-Level Colors

Set default colors in YAML front matter:

```yaml
table-header-bgcolor: "255,128,0"    # RGB format
table-body-bgcolor: "255,240,220"    # RGB format
```

### Per-Table Colors

Override colors for individual tables in the caption:

```markdown
| Feature | Status |
|---------|--------|
| Auth    | Done   |
| API     | WIP    |

: Status table {tbl-header-bgcolor="0,100,200" tbl-body-bgcolor="230,240,255"}
```

### Color Formats

Colors can be specified as:
- RGB: `"255,128,0"`
- Hex: `"#ff8000"` or `"ff8000"`

### Dark Theme Defaults

When `dark_background: true` is set, tables automatically use:
- Header: `#471d00` (dark orange-brown)
- Body: `#6d2b00` (medium orange-brown)

## Properties Reference

### Document-Level Properties (YAML)

| Property | Format | Default (light) | Default (dark) | Description |
|:---------|:-------|:----------------|:---------------|:------------|
| `table-header-bgcolor` | RGB or Hex | Theme default | `#471d00` | Header background |
| `table-body-bgcolor` | RGB or Hex | Transparent | `#6d2b00` | Body background |
| `table-header-txtcolor` | RGB or Hex | Black | White | Header text color |
| `table-body-txtcolor` | RGB or Hex | Black | White | Body text color |
| `table-border-color` | RGB or Hex | Black | `#8b4513` | Border color |
| `table-border-width` | Number (pt) | 0.4 | 0.4 | Border width (0 = none) |
| `table-cell-padding` | Number (pt) | 6 | 6 | Cell padding |
| `table-alignment` | `left`/`center`/`right` | left | left | Table placement |

### Per-Table Properties (Caption)

| Property | Format | Description |
|:---------|:-------|:------------|
| `#tbl-<id>` | Label ID | Cross-reference label |
| `tbl-colwidths` | `"[n,n,...]"` | Column widths (percentages) |
| `tbl-header-bgcolor` | RGB or Hex | Header background |
| `tbl-body-bgcolor` | RGB or Hex | Body background |
| `tbl-header-txtcolor` | RGB or Hex | Header text color |
| `tbl-body-txtcolor` | RGB or Hex | Body text color |
| `tbl-border-color` | RGB or Hex | Border color |
| `tbl-border-width` | Number (pt) | Border width (0 = none) |
| `tbl-cell-padding` | Number (pt) | Cell padding |
| `tbl-alignment` | `left`/`center`/`right` | Table placement |

**Precedence:** Per-cell styles > Per-table properties > Document-level YAML > Theme defaults

## Individual Cell Styling

Style specific cells using Excel-style addressing (A1, B2, etc.) with the `tbl-cells` property.

### Cell Address Syntax

- **Column**: Single letter A-Z (case-insensitive)
- **Row**: Number 1-99
- **Unified Numbering**: Header rows are row 1, body starts after headers

Examples: `A1` (first column, first row), `B2` (second column, second row), `Z99` (26th column, row 99)

### Basic Cell Styling

```markdown
| Status | Q1  | Q2  | Q3  |
|--------|-----|-----|-----|
| Sales  | 100 | 150 | 200 |
| Costs  | 80  | 90  | 100 |

: Quarterly Report {tbl-cells="{B2: {bgcolor: '#90EE90'}, D3: {txtcolor: '#FF0000'}}"}
```

- `B2`: Green background on Q1 Sales value
- `D3`: Red text on Q3 Costs value

### Combined Cell Styles

Apply both background and text color to the same cell:

```markdown
| Task   | Priority |
|--------|----------|
| Review | High     |

: Task List {tbl-cells="{B2: {bgcolor: '#FF6B6B', txtcolor: '#FFFFFF'}}"}
```

### Multiple Cells

Style multiple cells in one declaration:

```markdown
| A  | B  | C  |
|----|----|----|
| 1  | 2  | 3  |
| 4  | 5  | 6  |

: Grid {tbl-cells="{A2: {bgcolor: '#FFE4B5'}, B2: {bgcolor: '#E6E6FA'}, C2: {bgcolor: '#98FB98'}, B3: {bgcolor: '#87CEEB'}}"}
```

### Cell Style Precedence

Individual cell styles override section-level colors:

```markdown
| Feature | Status |
|---------|--------|
| Auth    | Done   |

: Status {tbl-header-bgcolor="#3498DB" tbl-cells="{A1: {bgcolor: '#E74C3C'}}"}
```

The header cell A1 will be red (`#E74C3C`) instead of blue, while B1 uses the table header color.

### tbl-cells Syntax Reference

```
tbl-cells="{ADDR: {PROP: 'VALUE', ...}, ...}"
```

| Component | Description | Example |
|:----------|:------------|:--------|
| `ADDR` | Cell address (column letter + row number) | `A1`, `B2`, `Z99` |
| `bgcolor` | Background color (hex or RGB) | `'#FF0000'` or `'255,0,0'` |
| `txtcolor` | Text color (hex or RGB) | `'#FFFFFF'` or `'255,255,255'` |

**Notes:**
- Addresses are case-insensitive (`a1` = `A1`)
- Quotes around color values are required
- Out-of-bounds addresses are silently ignored
- Invalid addresses are silently ignored

### Complete Example

```markdown
| Feature | Description | Status |
|:--------|:------------|-------:|
| Auth    | OAuth 2.0   | Done   |

: Feature status {#tbl-features tbl-colwidths="[30,50,20]" tbl-header-bgcolor="0,100,180" tbl-header-txtcolor="255,255,255" tbl-border-color="0,100,180" tbl-border-width="1" tbl-alignment="center"}
```

## Grid Tables

TeXnative supports Pandoc grid tables with advanced features.

### Column Alignment

Specify alignment using colons at separator boundaries:

```markdown
+---------------+---------------+--------------------+
| Right         | Left          | Centered           |
+==============:+:==============+:==================:+
| Bananas       | 1.34          | built-in wrapper   |
+---------------+---------------+--------------------+
```

- Right-aligned: `+==============:+` (colon on right)
- Left-aligned: `+:==============+` (colon on left)
- Centered: `+:==============:+` (colons on both sides)
- Default: `+===============+` (no colons)

### Bullet Lists in Cells

```markdown
+---------------+---------------+--------------------+
| Fruit         | Price         | Advantages         |
+===============+===============+====================+
| Bananas       | 1.34          | - built-in wrapper |
|               |               | - bright color     |
+---------------+---------------+--------------------+
| Oranges       | 2.10          | - cures scurvy     |
|               |               | - tasty            |
+---------------+---------------+--------------------+
```

### Additional Features

- **Hard line breaks**: Use two trailing spaces or backslash
- **Multiple paragraphs**: Separate with blank lines within cells

## Examples

For more examples, see:
- [example_markdown_tables.qmd](../example_markdown_tables.qmd) ([PDF](../example_markdown_tables.pdf))
- [example_grid_tables.qmd](../example_grid_tables.qmd) ([PDF](../example_grid_tables.pdf))
- [example_tables_frontmatter_configured.qmd](../example_tables_frontmatter_configured.qmd) ([PDF](../example_tables_frontmatter_configured.pdf))
- [individual_table_cell_styling.qmd](../examples/individual_table_cell_styling.qmd) - Individual cell styling examples
