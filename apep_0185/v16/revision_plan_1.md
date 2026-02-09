# Revision Plan — v16 Code Integrity Restoration

**Parent paper:** apep_0211 (v15 of apep_0185 family)
**Revision type:** Code integrity restoration + minor paper fixes

---

## Workstream 1: Code Decontamination (CRITICAL)

| Step | Action | Status |
|------|--------|--------|
| 1 | Restore 11 clean R scripts from v12 | DONE |
| 2 | Port 3 clean v15-only scripts (06b, 07, 08) | DONE |
| 3 | Verify zero contamination via grep | DONE |
| 4 | Fix 01_fetch_data.R for Census API changes | DONE |
| 5 | Fix 02_clean_data.R dplyr formula syntax | DONE |

## Workstream 2: Minor Paper Improvements

| Step | Action | Status |
|------|--------|--------|
| 6 | Update revision footnote (apep_0207 → apep_0211) | DONE |
| 7 | Fix balance table cross-reference | DONE |
| 8 | Clarify Figure 4 first-stage discrepancy note | DONE |
| 9 | Add Andrews et al. (2019) citation + AR test annotation | DONE |
| 10 | Add de Chaisemartin & D'Haultfoeuille (2024) citation | DONE |

## Workstream 3: Regenerate & Review

| Step | Action | Status |
|------|--------|--------|
| 11 | Run full R pipeline (01-08) | DONE |
| 12 | Compile PDF (54 pages) | DONE |
| 13 | Advisor review (3/4 PASS) | DONE |
| 14 | Exhibit review | DONE |
| 15 | Prose review | DONE |
| 16 | External review (2 Minor, 1 Major) | DONE |
| 17 | Publish with --parent apep_0211 | PENDING |

## Reviewer Feedback (External — not addressed in this revision)

This is a code integrity restoration. Reviewer feedback on substantive content (SCI timing, magnitude interpretation, complier characterization) is noted for future revisions but not the focus of this v16:

- **GPT-5-mini (Major Revision):** SCI timing, exclusion restriction breadth, pre-trend sensitivity
- **Grok-4.1-Fast (Minor Revision):** Pre-trend level imbalances, complier enrichment
- **Gemini-3-Flash (Minor Revision):** Magnitude plausibility, reservation wage mechanism
