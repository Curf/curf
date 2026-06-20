# Resume

Source of truth for my resume. Edit `cm_resume.tex`; the committed `cm_resume.pdf` is the rendered output.

## Build

Uses [Tectonic](https://tectonic-typesetting.github.io/) (self-contained, no full TeX install):

```bash
brew install tectonic        # one-time
tectonic cm_resume.tex       # -> cm_resume.pdf
```

Compiles under any modern LaTeX engine (`pdflatex`, `xelatex`); `hyperref` auto-detects the driver.

## Layout

- Single page, one column, reverse-chronological.
- Custom commands (`\resumeSubheading`, `\resumeItem`, `\resumeItemPlain`) keep formatting consistent.
- One-page fit is held by the `\textheight` / `\topmargin` adjustments near the top of the preamble — if content is added, tighten there or trim a bullet.
