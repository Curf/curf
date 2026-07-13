---
name: resume-build
description: Use when Colin wants to tailor his resume to a specific job description (a pasted JD or a job-posting URL) and produce a tailored PDF. Triggers on "/resume-build", "tailor my resume to this", "make a resume for this job/posting/role".
---

# resume-build

Tailor Colin's resume to one job description, compile a one-page PDF, and upload it
to personal Google Drive — **without ever putting a false or unverified claim on the
resume.**

## Core principle — the truthfulness gate

**Every factual claim on the tailored resume MUST trace to one of the ground-truth
sources.** You may reword and reorder existing facts to match the JD's language. You
may NOT invent, inflate, or extrapolate. A claim with no source is a bug, not a flourish.

**Ground-truth sources (the only things you may draw from):**
- `resume/cm_resume.tex` (the master)
- `technical_achievements.md`
- `case_studies/*.md`
- `resume/TAILOR_LEDGER.md` → `## Verified facts` and `## Approved phrasings`

**Before proposing any claim, check `resume/TAILOR_LEDGER.md` → `## Never claim`.**
Anything on that list is forbidden and must never resurface.

### Red flags — STOP if you catch yourself thinking:
- "This is close enough to what he did" → not grounded = don't write it.
- "Most engineers with this background can do X" → he didn't say it; don't claim it.
- "I'll strengthen the number / scope to match the JD" → no inflation. Use the real figure.
- "The JD wants X, I'll add X" → only if X is in a ground-truth source. Else flag it to Colin.

A new fact reaches the resume ONLY after Colin confirms it in the review loop — then
you append it to `## Verified facts` so it's reusable next time.

## Workflow

1. **Resolve the JD.** If given a URL, scrape it (firecrawl-scrape skill, or WebFetch).
   If a fetch fails, ask Colin to paste the JD. Derive a slug `<company>-<role>`
   (lowercase, kebab-case); if you can't parse company/role, ask. Write the JD text +
   source URL + date to `resume/tailored/<slug>/job.md`.
2. **Extract requirements** from the JD: key skills, keywords, responsibilities, seniority.
   - **Optional company lookup:** if the JD alone leaves the company's domain, product,
     or stack genuinely unclear *and* that would change how you emphasize Colin's
     experience, do a quick web lookup (firecrawl-search / firecrawl-scrape, or
     WebSearch) — e.g. "is this a payer, provider, or pharma?", "what's their stack?".
     Keep it to 1-2 lookups; skip it when the JD is already clear. Note in `job.md`
     what you looked up and what you learned.
   - **Boundary:** company research informs only *which of Colin's real facts to
     surface and what vocabulary to use*. It is NOT a ground-truth source — it can
     never add, justify, or inflate a claim about Colin. The gate sources in the
     Core Principle remain the only basis for anything written on the resume.
3. **Load truth:** read the four ground-truth sources above.
4. **Plan edits** against the master `resume/cm_resume.tex`:
   - reorder bullets so the most JD-relevant surface first
   - reword bullets to use the JD's keywords (same fact, JD's vocabulary)
   - surface stronger bullets that exist in the corpus but aren't on the master
   - drop weaker bullets to hold one page
   - **annotate every proposed claim with its grounding source** (file + what it maps to)
   - preserve the LaTeX structure and custom commands (`\resumeItem`,
     `\resumeSubheading`, `\resumeItemPlain`, list start/end macros)
5. **Review loop with Colin** (this is the gate, do not skip):
   - Present the proposed changes + the grounding for each.
   - Colin approves / edits / rejects each.
   - Approved new phrasings → append to `## Approved phrasings`. A newly confirmed fact
     → also append to `## Verified facts`. Rejections → append to `## Never claim`.
6. **Write & build:** write `resume/tailored/<slug>/cm_resume.tex`, then
   `bash .claude/skills/resume-build/scripts/build.sh resume/tailored/<slug>/cm_resume.tex`.
   Exit 2 = over one page → trim a bullet and rebuild. Never ship >1 page.
7. **Upload:** `bash .claude/skills/resume-build/scripts/upload.sh resume/tailored/<slug>/cm_resume.pdf <slug>`.
   The delivered file is named `cm-resume-<YYYY-MM-DD>.pdf` (neutral — never the
   company/role, so the attached file carries no per-application tell); the slug
   is only the private Drive subfolder. Lands a local copy at
   `resume/tailored/<slug>/cm-resume-<date>.pdf` and uploads to
   `gdrive-personal:Resumes/<slug>/cm-resume-<date>.pdf`.
   Exit 3 = rclone not set up → show Colin the setup steps the script printed; do NOT
   claim the upload succeeded.
8. **Record:** write `resume/tailored/<slug>/changes.md` (what changed vs master + the
   grounding per claim) and make sure ledger updates from step 5 are saved.

## Outputs & what's committed

- `resume/cm_resume.tex` / `.pdf` — the MASTER. **Never auto-edit.** Source of truth.
- `resume/TAILOR_LEDGER.md` — persistent memory. **Committed** (travels with the repo).
- `resume/tailored/**` — per-job variants + outputs. **Gitignored.** Also in Drive.

## One-time setup (Colin runs once)

Upload needs rclone bound to personal Drive (`clnjmurph@gmail.com`), isolated from the
machine's work gcloud:

```bash
brew install rclone
rclone config        # new remote named exactly "gdrive-personal", type=drive,
                     # OAuth as clnjmurph@gmail.com
```

`upload.sh` detects a missing remote and prints these steps; it never fakes success.

## Common mistakes

- **Editing the master.** Tailored output goes in `resume/tailored/<slug>/`, never `resume/cm_resume.tex`.
- **Skipping the review loop** because the edits "look safe." The loop is how the ledger
  learns and how false claims get caught. Always present grounding and wait for Colin.
- **Claiming the upload worked** when rclone exited 3. Surface the setup steps instead.
- **Letting it spill to two pages.** build.sh exit 2 means trim, not ship.
- **Using gcloud/gsutil for the upload.** Drive only, via the `gdrive-personal` rclone remote.
