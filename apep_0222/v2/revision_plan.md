# Revision Plan: apep_0222 v2

## Context

Paper apep_0222 ("The Dog That Didn't Bark: Educational Content Restriction Laws and Teacher Labor Markets") scored μ=19.6 in tournament (17W-33L). All three referees and tournament judges flagged **NAICS 61 breadth** as the #1 weakness — it lumps K-12 schools with colleges, tutoring, and other educational services, diluting any K-12-specific effect. The female share result (the only non-null finding) uses TWFE only, not the CS estimator used for all other outcomes.

**Goal:** Switch primary analysis from NAICS 61 → NAICS 6111 (Elementary & Secondary Schools), run CS estimates for all outcomes including female share, add formal MDE calculations.

## Workspace

- Parent: `papers/apep_0222/v1/`
- New workspace: `output/apep_0222/v2/`
- Copy `code/`, `paper.tex`, `references.bib`, treatment data from parent
- Do NOT copy `figures/`, `tables/`, or stale review files

---

## Workstream 1: Data Pipeline (R Scripts)

### 1a. `01_fetch_data.R` — Add NAICS 6111 + 6112

- Add `"6111"` (K-12 Schools) and `"6112"` (Colleges) to the industries list alongside existing 61, 62, 44-45, 31-33, 00
- Update sex-disaggregated fetch from `industry=61` → `industry=6111`
- Handle data suppression: count and report suppressed state-quarters at 4-digit level
- ~440 API calls total (was ~360), adds ~8 seconds

### 1b. `02_clean_data.R` — Switch primary panel to 6111

- Change `edu_panel` filter from `industry == "61"` to `industry == "6111"`
- Keep broad `edu_broad_panel` (NAICS 61) for robustness comparison
- Add `college_panel` (NAICS 6112) for decomposition
- Update triple-diff dataset: `"6111"` vs `"62"` (was `"61"` vs `"62"`)
- Build `female_share_panel` from sex-disaggregated 6111 data (currently built on-the-fly in robustness script)

### 1c. `03_main_analysis.R` — Add CS for female share

- Existing 5 CS models (emp, sep, earn, hire, turn) will automatically use 6111 data via updated `edu_panel`
- **Add 6th CS model**: `att_gt(yname = "female_share", ...)` with event study
- Add TWFE for female share alongside CS for direct comparison
- Save all results including `cs_female`, `agg_female`, `es_female`

### 1d. `04_robustness.R` — MDE + NAICS comparison

- Add **formal MDE calculations** at 80% power: `MDE = 2.8 × SE` for each outcome
- Add **NAICS 61 (broad) CS estimate** as a robustness row showing results unchanged at broader aggregation
- Update gender composition section: reference CS estimate from main analysis (no longer TWFE-only)
- Add retail event study extraction for addressing marginal placebo concern

### 1e. `05_figures.R` — New figures

- Update all subtitles from "NAICS 61" to "NAICS 6111 (K-12 Schools)"
- **Add Figure 7**: Female share CS event study (addresses Gemini referee)
- **Add Figure 8**: NAICS 6111 vs. 61 comparison event study (shows narrowing doesn't change conclusions)

### 1f. `06_tables.R` — Updated tables

- Table 1: Update to 6111 data, note any suppressed observations
- Table 2 Panel D: Report **both CS and TWFE** for female share
- Table 3: Add rows for "Broad Education (NAICS 61)" and "MDE (80% power)"
- Table 5: Rename "Education (61)" → "K-12 Schools (6111)", add "Broad Education (61)" row

---

## Workstream 2: Paper Text (`paper.tex`)

### Data Section
- Replace "NAICS 61 (Educational Services)" → "NAICS 6111 (Elementary and Secondary Schools)" throughout
- Add paragraph explaining the narrowing choice and why 6111 is appropriate
- Update sample size N (will be slightly smaller due to 4-digit suppressions)

### Results Section
- Update all coefficient values, SEs, p-values, CIs with new 6111-based estimates
- Rewrite Section 5.5 (Compositional Effects) to present CS female share estimate alongside TWFE
- Reference new Figure 7 (female share event study)

### Robustness Section
- Add subsection: "NAICS 6111 vs. NAICS 61 Comparison" with Figure 8
- Add subsection: "Minimum Detectable Effects" with formal MDE table
- Expand retail placebo discussion (address GPT's concern about p=0.088)

### Discussion/Limitations
- Remove/weaken the NAICS 61 breadth limitation (no longer applicable)
- Replace with remaining limitations (4-digit suppression, public vs private within 6111)
- Update compositional finding interpretation with CS estimates

### References
- Add: Rothstein (2015), Goldhaber et al. (2022), Jackson et al. (2014)

---

## Workstream 3: Review & Publish Pipeline

1. Run all 7 R scripts in sequence
2. Compile paper: `pdflatex → bibtex → pdflatex → pdflatex`
3. Visual QA: verify page 1 front matter, no `??` references, 25+ pages
4. Stage A: Advisor review (3/4 must PASS)
5. Stage A.5: Exhibit review → fix exhibits
6. Stage A.6: Prose review → improve writing
7. Stage B: External review (3 referees)
8. Stage C: Create `revision_plan_1.md` + `reply_to_reviewers_1.md`
9. Publish: `python3 scripts/revise_and_publish.py output/apep_0222/ --parent apep_0222 --push`

---

## Risk Mitigation

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| NAICS 6111 suppression >10% | Low-Medium | Report exact suppression count; show dropping affected states doesn't change results |
| Female share CS estimate is null | Medium | Report honestly — makes the "precise null" story cleaner |
| NAICS 6111 reveals significant effect | Low | Major finding — update narrative from "null" to "K-12 effect masked by broad aggregation" |
| Coefficient values change substantially | Medium | Mechanical updates; grep all hardcoded numbers |

---

## Execution Order

1. Create workspace + initialization.md
2. Modify R scripts (1a → 1b → 1c → 1d → 1e → 1f)
3. Run all R scripts
4. Update paper.tex with new results
5. Compile and visual QA
6. Full review pipeline
7. Publish
