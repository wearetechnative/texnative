# TexNative Format

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

![](Screenshot-TexNative.png)

![](Screenshot-white.png)

## Using

Include this in your front matter.

```yaml
format: texnative-pdf
filters:
  - texnative
```

Have a look at the `temlate.qmd`. This generates [this pdf](template.pdf).

## Optional Frontmatter

When set, these values are used in the cover page.

```yaml
subtitle: Agreement for a typical business case
author: Jane Dean
date: last-modified
type: Report
document_version: 1
document_number: ABC013
```

## Format Options

```yaml
# DOCUMENT DEFAULT CONFIGURATION
toc: true                                        # show table of contents
toc-title: Contents                              # title of table of contents
cover_page: true                                 # generate cover page
letterhead: true                                 # use a letterhead background
dark_background: true                            # use the dark bg or letterhead with white text
page_numbers: true                               # show page numbers
paragraph_numbers: true                          # show paragraph numbers before headers
papersize: a4
letterhead_img: bgwhite.jpg                      # path to background image
letterhead_img_darkbg: bgdark.jpg                # path to background image for dark background
cover_illustration_img: cover-ill.png            # path to cover page illustration image
cover_illustration_img_darkbg: cover-ill.png     # path to cover page illustration image for dark background
disable_justify: false                           # true: justify left and right, false: only justify left;
```

## Custom letterhead

Change `letterhead_img`, `letterhead_img_darkbg`, `cover_illustration_img` and
`cover_illustration_img_darkbg` with images which fit your Corporate Identity.
At TechNative we use an extra internal extension which provides all assets
with our corporate identity.

Our `_quarto.yml` looks like this: 

```yaml
filters:
  - quarto
  - texnative
dark_background: true
disable_justify: true
format: texnative-pdf
toc-depth: 4
letterhead_img: _extensions/technative-internal/quarto-technative-branding/letterhead-technative.png
letterhead_img_darkbg: _extensions/technative-internal/letterhead-technative-dia.png
cover_illustration_img: _extensions/technative-internal/quarto-technative-branding/unleash_white.jpg
cover_illustration_img_darkbg: _extensions/technative-internal/quarto-technative-branding/unleash.jpg
```

## Credits

Illustration is created by Illustrations.co from the 'Life' collection.
