# TeXnative PDF Format

**_Quarto PDF format Extension_**

Modern customizable Business Document Format for creating clean Reports,
Quotations, Letters etc...

## Installing

```bash
quarto use template wearetechnative/texnative
```

This will install the extension and create an example qmd file that you can use
as a starting place for your article.

## Features

- modern business document
- white and dark background
- custom letterhead en frontpage images
- filter to create modern looking tables
- advanced styling properties for markdown tables

![](./media/Screenshot-TexNative.png)

![](./media/Screenshot-white.png)

## Using

Include this in your front matter.

```yaml
format: texnative-pdf
filters:
  - texnative
```

Have a look at the `template.qmd`. This generates [this pdf](template.pdf).

## Documentation

For detailed documentation, see:

- **[Configuration Reference](docs/configuration.md)** - All YAML front matter options
- **[Table Formatting](docs/table-formatting.md)** - Professional table styling guide
- **[Documentation Index](docs/index.md)** - Complete documentation overview

## Quick Start

### Optional Frontmatter

When set, these values are used in the cover page.

```yaml
subtitle: Agreement for a typical business case
author: Jane Dean
date: last-modified
type: Report
document_version: 1
document_number: ABC013
```

### Custom letterhead

Change `letterhead_img`, `letterhead_img_darkbg`, `cover_illustration_img` and
`cover_illustration_img_darkbg` with images which fit your Corporate Identity.

## Examples

| Example | Description |
|:--------|:------------|
| [example_markdown_tables.qmd](./example_markdown_tables.qmd) | Markdown table examples ([PDF](./example_markdown_tables.pdf)) |
| [example_grid_tables.qmd](./example_grid_tables.qmd) | Pandoc grid table examples ([PDF](./example_grid_tables.pdf)) |
| [example_tables_frontmatter_configured.qmd](./example_tables_frontmatter_configured.qmd) | Document-level table styling ([PDF](./example_tables_frontmatter_configured.pdf)) |

## Credits

Illustration is created by Illustrations.co from the 'Life' collection.
