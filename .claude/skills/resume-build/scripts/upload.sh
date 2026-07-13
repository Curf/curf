#!/usr/bin/env bash
# upload.sh — copy a tailored resume PDF to personal Google Drive via rclone.
#
# Usage: upload.sh <path/to/cm_resume.pdf> <slug>
#   -> delivered filename is  cm-resume-<YYYY-MM-DD>.pdf  (NEVER the company name,
#      so the file Colin attaches to an application carries no per-company tell).
#   -> writes a local copy   <pdf-dir>/cm-resume-<YYYY-MM-DD>.pdf
#   -> uploads to            gdrive-personal:Resumes/<slug>/cm-resume-<YYYY-MM-DD>.pdf
#      (the company slug lives ONLY in a private Drive subfolder, never on the
#       file itself; the subfolder also stops same-day variants colliding.)
#
# Uses an explicit rclone remote ("gdrive-personal"), NEVER gcloud — keeps the
# personal Drive account isolated from the machine's work gcloud auth.
#
# Exit codes:
#   0  uploaded
#   1  usage error / pdf missing
#   3  rclone not installed or "gdrive-personal" remote not configured
set -euo pipefail

REMOTE="gdrive-personal"
FOLDER="Resumes"

PDF="${1:-}"
SLUG="${2:-}"
if [[ -z "$PDF" || -z "$SLUG" || ! -f "$PDF" ]]; then
  echo "usage: upload.sh <path/to/file.pdf> <slug>  (pdf must exist)" >&2
  exit 1
fi

# Neutral, dated delivery name — no company/role on the file the recruiter sees.
DATE="$(date +%F)"
OUT_NAME="cm-resume-${DATE}.pdf"
LOCAL_COPY="$(cd "$(dirname "$PDF")" && pwd)/${OUT_NAME}"

print_setup() {
  cat >&2 <<'EOF'
rclone is not set up for personal Drive. One-time setup:

  brew install rclone
  rclone config
    n) New remote
    name> gdrive-personal
    Storage> drive            (Google Drive)
    ... follow the OAuth prompt and sign in as clnjmurph@gmail.com ...
    scope> 1                  (full access) or 3 (drive.file) — either works

Then re-run the upload.
EOF
}

if ! command -v rclone >/dev/null 2>&1; then
  echo "rclone not found." >&2
  print_setup
  exit 3
fi

# Confirm the remote exists (rclone listremotes prints "name:" per line).
if ! rclone listremotes 2>/dev/null | grep -qx "${REMOTE}:"; then
  echo "rclone remote '${REMOTE}:' not configured." >&2
  print_setup
  exit 3
fi

# Local delivery copy with the neutral dated name (kept next to the build).
cp "$PDF" "$LOCAL_COPY"
echo "local   -> $LOCAL_COPY"

# copyto (not copy) so the Drive object is named exactly cm-resume-<date>.pdf;
# the company slug is the parent folder only, never part of the filename.
DEST="${REMOTE}:${FOLDER}/${SLUG}/${OUT_NAME}"
rclone copyto "$LOCAL_COPY" "$DEST"
echo "uploaded -> $DEST"
exit 0
