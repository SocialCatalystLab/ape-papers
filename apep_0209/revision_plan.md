# Revision Plan: apep_0208 → Structural Overhaul for AER

## Context

**Parent:** apep_0208 (μ=22.5, σ=3.15, conservative=13.1)
**Title:** Making Wages Visible: Labor Market Dynamics Under Salary Transparency (v10)
**Family:** apep_0054 → 0162 → 0195 → 0204 → 0206 → 0208 → **this revision**

The paper has strong results (2 Minor + 1 Major from external reviewers) and excellent prose (Grok: "rivals QJE leads"). But the structure is **clunky**: CPS and QWI results are presented in separate tables with different column layouts, making cross-dataset comparison harder than it should be. The user wants a fundamental structural reorganization.

**User's directive:** "it's still clunky. needs some coherent structuring of evidence, and make the two types of datasets show as much parallelism as possible when presented. why not start with QWI data first, before CPS. Even if it's in consolidated tables, maybe panel A and B, with similar progressions of specifications. make it AER ready."

---

## The Core Insight: QWI First

The paper currently buries the stronger evidence. The QWI has:
- 51 clusters (vs CPS's 8) → reliable asymptotic inference
- Quarterly frequency → sharper event timing and more pre-periods
- Administrative records → no survey measurement error
- Gender DDD p < 0.001 (vs CPS permutation p = 0.154)

**Leading with QWI makes the argument stronger.** Present the cleanest, best-identified evidence first. Then show CPS microdata confirms it with richer controls. This reversal transforms the narrative from "we found something in a survey, and admin data agrees" to "administrative records reveal a clear effect, and individual-level microdata confirms the mechanism."

---

## Workstream 1: Consolidated Tables (Panel A: QWI / Panel B: CPS)

### Design principle: Same columns, same progression, side by side.

**New Table 3: Aggregate Wage/Earnings Effects**
```
                      (1)        (2)        (3)        (4)
                    C-S ATT    TWFE     TWFE+Ctrl  State×Time FE
Panel A: QWI (N=2,603 state-quarters)
  Treated × Post   -0.001     0.030      —           —
                   (0.020)   (0.022)

Panel B: CPS (N=614,625 workers)
  Treated × Post   -0.004     0.005     0.008       —
                   (0.006)   (0.011)   (0.006)
```
- Columns progress from simplest (C-S ATT) to most demanding
- Both panels tell the same story: null
- QWI Panel A has fewer columns (no individual controls) — use "—" for inapplicable specs

**New Table 4: Gender Gap Effects (DDD)**
```
                      (1)        (2)        (3)        (4)
                    Basic DDD  + Occ/Ind  + Controls  State×Time FE
Panel A: QWI (state-quarter × sex, N=5,206)
  Treat × Post × F  0.061***    —          —         0.061***
                    (0.015)                          (0.015)

Panel B: CPS (individual, N=614,625)
  Treat × Post × F  0.049***  0.056***   0.040***   0.043***
                    (0.008)   (0.008)    (0.008)    (0.008)
```
- QWI has state×quarter FE built in (col 4 equivalent) — show this
- CPS progression adds controls — the classic 4-column buildup
- Both panels show significant gender gap narrowing

**New Table 5: Labor Market Dynamism (QWI only)**
- Keep existing structure — this is QWI-specific, no CPS parallel

**New Table 6: Industry Heterogeneity (QWI only)**
- Keep existing structure — QWI-specific

**New Table 7: Robustness Summary**
```
Panel A: QWI Robustness
  [estimator variants, industry splits]

Panel B: CPS Robustness
  [Sun-Abraham, not-yet-treated, border states, Lee bounds, etc.]
```

**New Table 8: Inference Methods**
- Keep existing `tab:alt_inference` structure but add QWI row

### What gets cut from main text tables:
- `tab:main` (CPS TWFE-only table) → absorbed into consolidated Table 3
- `tab:qwi_main` (3-panel QWI table) → absorbed into Tables 3 + 4
- `tab:cross_dataset` → **ELIMINATED** — the entire paper now IS the cross-dataset comparison

### R script changes:
- New `08_consolidated_tables.R` — loads `main_results.rds` + `qwi_results.rds`, generates consolidated LaTeX
- Or modify `07_tables.R` and `07b_qwi_tables.R` to produce the new format

---

## Workstream 2: Paper Structure Rewrite (QWI First)

### New section order within Results (Section 6):

**6.1 Pre-Trends and Visual Evidence**
- Figure 2 (QWI trends) FIRST — 52 quarters of clean parallel trends
- Figure 3 (CPS trends) — annual, confirming the same pattern
- "Both datasets provide compelling support..."

**6.2 Aggregate Wages: A Precisely Estimated Zero**
- Table 3 (consolidated) — QWI Panel A first, CPS Panel B second
- Lead prose with QWI: "Administrative records show no aggregate effect (ATT = -0.001, 51 clusters)"
- CPS confirms: "Individual-level data agrees (ATT = -0.004, 614K workers)"

**6.3 The Gender Gap Narrows**
- Table 4 (consolidated) — QWI Panel A first, CPS Panel B second
- Lead with QWI: "Women's quarterly earnings rise 6.1 pp relative to men's (p < 0.001, 51 clusters)"
- CPS confirms: "Microdata with rich controls yields 4.0-5.6 pp (p < 0.01)"
- The concordance paragraph lands harder when you've seen both panels side by side

**6.4 No Labor Market Disruption**
- Table 5 (QWI dynamism) — unchanged, QWI-only
- Precision interpretation paragraph

**6.5 Industry Heterogeneity**
- Table 6 (QWI industry) — unchanged

**6.6 Design-Based Inference**
- Move the Fisher RI / permutation p-value discussion HERE (from Robustness)
- This is where the CPS permutation p = 0.154 gets discussed
- But NOW it follows the QWI p < 0.001 — so the narrative is "QWI confirms what CPS suggests"

### Introduction changes:
- Reorder results preview: QWI first, then CPS confirms
- Frame the dual-dataset story as: "administrative records (QWI) establish the effect; household survey (CPS) confirms the mechanism"

### Data section changes:
- Present QWI first (Section 4.1), CPS second (Section 4.2)
- Swap current 4.1 (CPS) and 4.2 (QWI) subsection order
- Keep Complementarity subsection (now 4.3) but reframe: "The QWI provides the cleaner identification; the CPS provides the richer mechanism evidence"

### Empirical Strategy changes:
- Present QWI estimation first (Section 5.1), CPS estimation second (Section 5.2)
- Swap current subsection order

---

## Workstream 3: Figure Reordering

**Main text figures (6 total):**
1. Figure 1: Policy map (unchanged)
2. Figure 2: QWI combined trends (2 panels — earnings + gender gap) ← was Figure 3
3. Figure 3: CPS combined trends (2 panels — wages + gender gap) ← was Figure 2
4. Figure 4: CPS Event Study by Gender ← was Figure in current 6.3
5. Figure 5: QWI Dynamism coefficient plot ← was Figure 4
6. Figure 6: QWI Industry heterogeneity ← was Figure 5

**Moved to Appendix:**
- LOTO forest plot
- Permutation distribution
- QWI quarterly event studies (earnings, gap)
- QWI gap trends (standalone)

---

## Workstream 4: Prose Tightening

The v10 prose is already strong (Grok: "rivals QJE leads"). Focus changes:

1. **Introduction:** Restructure results preview paragraph to lead with QWI
2. **Data section:** QWI before CPS, reframe complementarity
3. **Results section:** Complete rewrite of subsection order and prose flow
4. **Discussion:** Tighten — the cross-dataset comparison is now built into the main tables, so the discussion can focus on mechanisms and limitations without rehashing the comparison
5. **Kill the "Cross-Dataset Comparison" subsection** (6.6 in current paper) — it's redundant when every main table IS a cross-dataset comparison

---

## What Does NOT Change

- All regression coefficients, standard errors, p-values
- Data (no new analysis, no new data)
- Code logic in `04_main_analysis.R`, `04b_qwi_analysis.R`
- Figure content (just reordered)
- Identification strategy, robustness checks
- References (maybe add 1-2 from reviewer suggestions)

---

## Execution Order

1. Initialize session, create workspace `output/paper_192/`, copy from `papers/apep_0208/`
2. Re-run all R scripts to regenerate all figures/tables fresh
3. Create `08_consolidated_tables.R` — generates Panel A/B consolidated tables
4. Rewrite `paper.tex`:
   - Swap Data subsection order (QWI → CPS)
   - Swap Empirical Strategy subsection order (QWI → CPS)
   - Restructure Results with consolidated tables, QWI-first prose
   - Kill cross-dataset comparison subsection
   - Reorder figures (QWI trends before CPS trends)
   - Update all cross-references
5. Rewrite Introduction results preview (QWI first)
6. Compile PDF, visual QA
7. Review pipeline: Exhibit → Prose → Advisor → External → Revision cycle
8. Publish with `--parent apep_0208`

---

## Files to Modify

- `paper.tex` — Major structural rewrite (QWI first, consolidated tables, reordered sections)
- `code/08_consolidated_tables.R` — NEW: generates Panel A/B tables from existing RDS
- `code/07_tables.R` — Minor: may need adjustment if consolidated tables replace individual ones
- `code/07b_qwi_tables.R` — Minor: same

## Key Source Files

- `papers/apep_0208/paper.tex` — Current v10 paper (1129 lines)
- `papers/apep_0208/code/07_tables.R` — CPS table generation (10 tables)
- `papers/apep_0208/code/07b_qwi_tables.R` — QWI table generation (5 tables)
- `papers/apep_0208/data/main_results.rds` — CPS regression results
- `papers/apep_0208/data/qwi_results.rds` — QWI regression results

## Verification

- PDF compiles cleanly
- All consolidated tables render with correct Panel A/B structure
- QWI appears before CPS in Data, Strategy, and Results sections
- Cross-dataset comparison subsection is gone (built into every table)
- Page count ≥ 25 (structural changes shouldn't affect length much)
- 3/4 advisor PASS
- 3 external reviews completed
- Table numbers in text match actual tables
