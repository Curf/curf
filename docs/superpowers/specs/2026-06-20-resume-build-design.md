# resume-build — design spec

**Date:** 2026-06-20
**Status:** approved-pending-review
**Repo:** curf (personal resume repo)

## Purpose

A one-command workflow that takes a job description (URL or pasted text), tailors
the resume to align with it, compiles a PDF, and uploads that PDF to a personal
Google Drive folder — while never allowing a false or unverified claim onto the
resume. The system improves over time by remembering approved phrasings and
rejected claims.

## Type & scope decision

- **Project-scoped skill**, not user-scoped. The resume *is* this repo's data;
  the skill travels with the repo and runs exactly where the data lives, so the
  "remote, repo isn't here" failure can't occur. A user-scoped (`~/.claude`)
  skill would have to locate `curf` on each machine.
- **Skill + helper scripts**, not a single Claude/MCP tool. The skill is the
  orchestrator; two small bash scripts do the mechanical work (compile, upload).

## Trigger

```
/resume-build <job-description-URL  OR  pasted JD text>
```

The skill detects whether the argument is a URL (→ scrape) or raw text (→ use
directly). If a URL fetch fails, it asks the user to paste the JD instead.

## File layout

```
curf/
  .claude/skills/resume-build/
    SKILL.md                 # the workflow
    scripts/build.sh         # tectonic: .tex -> .pdf, assert single page
    scripts/upload.sh        # rclone copy pdf -> personal Drive
  resume/
    cm_resume.tex            # MASTER — committed, never auto-edited
    cm_resume.pdf            # MASTER — committed
    TAILOR_LEDGER.md         # COMMITTED memory (see below)
    .gitignore               # add: tailored/
    tailored/                # GITIGNORED — output + per-job state
      <company>-<role>/
        job.md               # JD text + source URL + fetch date
        cm_resume.tex        # tailored variant
        cm_resume.pdf        # tailored output (also uploaded to Drive)
        changes.md           # what changed vs master + grounding per claim
```

### Why the ledger is committed but `tailored/` is gitignored

`TAILOR_LEDGER.md` is persistent *memory* — it must survive across machines and
be backed up, exactly like the already-committed `technical_achievements.md`. The
per-job `tailored/` artifacts are bulky, numerous, and ephemeral (they also live
in Drive), so they are gitignored — matching the "local gitignored location +
cloud" requirement.

## Ground-truth corpus

The only sources a tailored claim may draw from:

- `resume/cm_resume.tex` (the master)
- `technical_achievements.md`
- `case_studies/*.md`
- Approved facts in `resume/TAILOR_LEDGER.md`

## TAILOR_LEDGER.md structure

```markdown
# Tailor Ledger

## Verified facts
- <atomic, true statements about Colin's experience, with optional source pointer>

## Approved phrasings
- <JD-context> → <approved bullet wording>   # reusable on future matching JDs

## Never claim
- <claim Colin rejected as false/overclaim>  # checked before every proposal; never resurfaced
```

## Truthfulness mechanism (core)

Hard rule in SKILL.md:

1. **Every factual claim on the tailored resume must trace** to a line in the
   corpus or an approved ledger fact. Reframing/keyword-aligning an existing fact
   is allowed. Introducing a *new* fact is **blocked** until the user confirms it
   in the review loop; on confirmation it is appended to `Verified facts`.
2. The **Never claim** list is checked before every proposal — rejected claims
   never resurface.
3. This is why output "starts mediocre and improves": the ledger accretes the
   user's approvals and rejections across runs.

## Workflow

1. **Resolve JD** — detect URL vs text; scrape or use directly; write
   `tailored/<slug>/job.md` with source + date. `<slug>` = `<company>-<role>`
   lowercased/kebab-cased; if company/role can't be parsed, ask the user.
2. **Extract requirements** — pull key skills, keywords, responsibilities,
   seniority from the JD.
3. **Load truth** — read corpus + ledger (facts, approved phrasings, never-claim).
4. **Plan edits** — map JD requirements onto existing corpus facts: reorder
   bullets to surface relevant ones, reword for the JD's keywords, surface
   stronger bullets that exist in the corpus but aren't on the master, drop
   weaker bullets to hold one page. Never invent. Every proposed claim is
   annotated with its grounding source.
5. **Review loop** — present the proposed diff + grounding per claim. User
   approves / edits / rejects each. Approved new phrasings → ledger
   `Approved phrasings` (+ `Verified facts` if a new fact was confirmed).
   Rejections → `Never claim`.
6. **Write & build** — write `tailored/<slug>/cm_resume.tex`; run `build.sh`
   (tectonic → pdf; assert single page; on overflow, trim a bullet and rebuild).
7. **Upload** — run `upload.sh` → `rclone copy` the pdf to
   `gdrive-personal:Resumes/<slug>.pdf`.
8. **Record** — write `changes.md`; update ledger.

## Helper scripts

### scripts/build.sh
- Input: path to a tailored `.tex`.
- Runs `tectonic` to produce the `.pdf` next to it.
- Asserts the output is a single page (e.g. via `pdfinfo`/page count); exits
  nonzero with a clear message if >1 page so the skill can trim and retry.

### scripts/upload.sh
- Input: path to the tailored `.pdf`, destination slug.
- Runs `rclone copyto <pdf> gdrive-personal:Resumes/<slug>.pdf` — `copyto`
  (not `copy`) so the Drive filename is the slug. The tailored file is always
  named `cm_resume.pdf` locally; a plain `copy` into `Resumes/` would overwrite
  the previous job's upload.
- **Pre-flight:** if the `gdrive-personal` rclone remote isn't configured, print
  the one-time setup steps and exit nonzero. Never report success when no upload
  happened.

## One-time setup (user runs once; documented in SKILL.md)

```bash
brew install rclone
rclone config        # new remote named exactly "gdrive-personal",
                     # type=drive, OAuth as clnjmuroph@gmail.com
```
Default Drive destination: `Resumes/` (folder created on first upload if absent).

## Boundary safety

`upload.sh` uses the explicit `gdrive-personal:` rclone remote and **never
touches gcloud**. The machine's gcloud is authed to the work account
(`colin@pact-ai.com`, project `pact-ai-dev`); keeping uploads on a separate
rclone remote prevents the work/personal credential mixing and env-boundary
leakage that CLAUDE.md warns about. No gcloud/gsutil involvement in this workflow.

## Error handling

| Condition | Behavior |
|-----------|----------|
| URL fetch fails | Ask user to paste the JD text |
| Company/role unparseable for slug | Ask user for the slug |
| tectonic overflow > 1 page | Trim a bullet, rebuild; surface to user if still over |
| rclone remote missing | Print setup steps, exit nonzero, do NOT claim upload succeeded |
| Proposed claim not grounded in corpus | Block it; require user confirmation → ledger |

## Testing / verification

- Dry run with a sample JD (pasted) end-to-end producing a tailored pdf locally,
  before wiring upload.
- Verify single-page assertion fires on an intentionally overlong variant.
- Verify `upload.sh` fails loudly when `gdrive-personal` is unconfigured.
- Verify a rejected claim added to `Never claim` does not reappear on a re-run
  with the same JD.

## Out of scope (YAGNI)

- Multiple resume templates / multi-page resumes.
- Cover-letter generation.
- ATS scoring integrations.
- Auto-committing tailored outputs.
- Any GCS-bucket path (Drive only, per decision).
