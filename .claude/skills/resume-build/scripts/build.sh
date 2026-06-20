#!/usr/bin/env bash
# build.sh — compile a tailored resume .tex to .pdf and assert it fits one page.
#
# Usage: build.sh <path/to/cm_resume.tex>
# Exit codes:
#   0  built, single page
#   2  built, but >1 page (caller should trim a bullet and rebuild)
#   1  usage / build error
set -euo pipefail

TEX="${1:-}"
if [[ -z "$TEX" || ! -f "$TEX" ]]; then
  echo "usage: build.sh <path/to/file.tex>  (file must exist)" >&2
  exit 1
fi

if ! command -v tectonic >/dev/null 2>&1; then
  echo "tectonic not found. Install once: brew install tectonic" >&2
  exit 1
fi

DIR="$(cd "$(dirname "$TEX")" && pwd)"
BASE="$(basename "$TEX" .tex)"
PDF="$DIR/$BASE.pdf"

# Compile (tectonic writes the pdf next to the .tex).
tectonic "$TEX" >/dev/null 2>&1

if [[ ! -f "$PDF" ]]; then
  echo "build failed: no pdf produced at $PDF" >&2
  exit 1
fi

# Page count: prefer pdfinfo, fall back to macOS mdls.
pages=""
if command -v pdfinfo >/dev/null 2>&1; then
  pages="$(pdfinfo "$PDF" 2>/dev/null | awk '/^Pages:/{print $2}')"
elif command -v mdls >/dev/null 2>&1; then
  pages="$(mdls -name kMDItemNumberOfPages -raw "$PDF" 2>/dev/null)"
fi

echo "$PDF"
if [[ -n "$pages" && "$pages" =~ ^[0-9]+$ ]]; then
  if (( pages > 1 )); then
    echo "WARNING: $pages pages — resume must be 1 page. Trim a bullet and rebuild." >&2
    exit 2
  fi
  echo "ok: 1 page" >&2
else
  echo "note: could not determine page count; verify manually." >&2
fi
exit 0
