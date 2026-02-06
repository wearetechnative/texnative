# Configuration Reference

This page documents all YAML front matter options available in TeXnative.

## Document Metadata

These values appear on the cover page when enabled:

```yaml
subtitle: Agreement for a typical business case
author: Jane Dean
date: last-modified
type: Report
document_version: 1
document_number: ABC013
```

## Document Options

```yaml
# Document structure
toc: true                    # Show table of contents
toc-title: Contents          # Title for table of contents
cover_page: true             # Generate cover page
letterhead: true             # Use letterhead background
page_numbers: true           # Show page numbers
paragraph_numbers: true      # Show paragraph numbers before headers

# Theme
dark_background: true        # Use dark background with white text

# Layout
papersize: a4
disable_justify: false       # true = left-align only; false = justify both sides

# Links
urlcolor: magenta            # Color of URLs
linkcolor: magenta           # Color of markdown links
colorlinks: true             # Enable colored links
```

## Custom Images

Customize the letterhead and cover page with your own branding:

```yaml
letterhead_img: bgwhite.jpg              # Background for light theme
letterhead_img_darkbg: bgdark.jpg        # Background for dark theme
cover_illustration_img: cover-ill.png    # Cover illustration for light theme
cover_illustration_img_darkbg: cover-ill.png  # Cover illustration for dark theme
```

### Corporate Identity Example

For custom corporate identity, create an internal extension with your assets:

```yaml
filters:
  - quarto
  - texnative
format: texnative-pdf
dark_background: true
disable_justify: true
toc-depth: 4
letterhead_img: _extensions/your-org/branding/letterhead.png
letterhead_img_darkbg: _extensions/your-org/branding/letterhead-dark.png
cover_illustration_img: _extensions/your-org/branding/cover.jpg
cover_illustration_img_darkbg: _extensions/your-org/branding/cover-dark.jpg
```

## Table Styling (Document-Level)

Set default table styling for all tables in the document:

```yaml
table-header-bgcolor: "255,128,0"      # Header background (RGB or Hex)
table-body-bgcolor: "255,240,220"      # Body background (RGB or Hex)
table-header-txtcolor: "255,255,255"   # Header text color
table-body-txtcolor: "0,0,0"           # Body text color
table-border-color: "0,0,0"            # Border color
table-border-width: 0.4                # Border width in points (0 = none)
table-cell-padding: 6                  # Cell padding in points
table-alignment: left                  # Table alignment: left, center, right
```

For per-table styling options, see [Table Formatting](table-formatting.md).

## Complete Example

```yaml
---
title: Project Proposal
subtitle: Q4 Planning Document
author: Jane Dean
date: last-modified
type: Report
document_version: 1
document_number: PROP-2024-001

format: texnative-pdf
filters:
  - texnative

toc: true
toc-title: Contents
cover_page: true
letterhead: true
dark_background: true
page_numbers: true
paragraph_numbers: true

papersize: a4
colorlinks: true
urlcolor: cyan
linkcolor: cyan

table-header-bgcolor: "71,29,0"
table-body-bgcolor: "109,43,0"
---
```
