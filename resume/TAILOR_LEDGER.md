# Tailor Ledger

Persistent memory for `/resume-build`. Committed so it travels with the repo.
Only facts here (plus the corpus: `cm_resume.tex`, `technical_achievements.md`,
`case_studies/`) may appear on a tailored resume.

## Verified facts

- Authored on 1 peer-reviewed paper (chemistry, ~2016 era) plus 1 arXiv
  preprint; older, not ML. Has *a* publication record but not an active ML one.
  [confirmed by Colin 2026-06-20]
- PACT (03/2026–06/2026): Diagnosed production incidents and hardened async
  (Pub/Sub) clinical-trial matching against message-redelivery and
  race-condition failures; ran on GCP (Cloud Run, Firestore, Pub/Sub) with
  PHI-safe logging (hashed identifiers). [cut from cm_resume.tex for space; PACT repo history]
- PACT: Built net-new Terraform — a Cloud Monitoring module (~20 alert
  policies) and a BigQuery + Datastream CDC data-warehouse module, plus the
  deploy service-account / WIF IAM. [pact-ai-infrastructure + match-warehouse git history]
- PACT: Standardized CI across 4 service repos — automated Claude PR-review
  action via a shared org-level reusable workflow; added Dependabot auto-merge. [repo git history]

<!-- Atomic, true statements about Colin's experience confirmed during a review
     loop. Add a source pointer when one exists. Example:
- Led a team of 4 at HealthyMe AI (10/2023–02/2026). [cm_resume.tex] -->

## Approved phrasings

<!-- Reusable bullet wordings Colin approved, with the JD context they fit.
     Example:
- (LLM eval roles) "Built criteria-level evaluation harnesses for an LLM
  clinical-trial matcher, raising matching reliability." -->

- (reliability / platform / SRE roles) "Diagnosed production incidents and
  hardened async (Pub/Sub) matching against redelivery and race-condition
  failures, under PHI-safe logging." [PACT]

## Never claim

- Do NOT claim 5+ first-author ML papers or an active ML publication record.
  Do NOT bridge "surpassed peer-reviewed literature" into "published research"
  — beating published benchmarks is not publishing. (Real: 1 chem paper + 1
  arXiv preprint, dated.)

<!-- Claims Colin rejected as false or overclaimed. Checked before every
     proposal; never resurface these. Example:
- Do NOT claim production Kubernetes experience. -->
