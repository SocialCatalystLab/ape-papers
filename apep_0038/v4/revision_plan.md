# Revision Plan: apep_0038 → v3

## Context

**Paper:** "Betting on Jobs? The Employment Effects of Legal Sports Betting in the United States"
**Parent:** apep_0038 (v2, published as apep_0094)
**Current Rating:** 20.7 (conservative: 16.7) — top ~3 APEP paper
**Scan Verdict:** SEVERE — receiving 10 virtual tournament losses
**Reviews:** 2 ACCEPT, 1 CONDITIONAL ACCEPT

The paper studies the employment effects of sports betting legalization using staggered DiD (Callaway-Sant'Anna). It's well-written and methodologically sophisticated, but has a **critical code integrity problem**: the script `01b_create_cached_qcew.R` generates simulated QCEW data with a treatment effect mechanically baked in. The data pipeline (`03_clean_data.R`) silently picks up this fabricated data. This must be fixed as the #1 priority — it accounts for 10 virtual losses that are dragging down an otherwise strong paper.

---

## Workstreams

### Workstream 1: Fix SEVERE Code Integrity Issues (CRITICAL)

**Problem:** `01b_create_cached_qcew.R` simulates the main outcome variable with a hard-coded treatment effect. `03_clean_data.R` loads whichever CSV exists without provenance checks.

**Fix:**
1. **Delete `01b_create_cached_qcew.R`** entirely — this file must not exist in the codebase
2. **Rewrite `01_fetch_qcew.R`** to reliably fetch real BLS QCEW data via the annual API endpoint:
   - `https://data.bls.gov/cew/data/api/{YEAR}/a/industry/{NAICS}.csv`
   - Fetch NAICS 7132 (Gambling), 31-33 (Manufacturing), 11 (Agriculture) for 2010-2024
   - Filter to `own_code == 5` (private), state-level aggregation
   - Include `annual_avg_wkly_wage` for new wage analysis (Workstream 3)
   - Add SHA256 checksum of downloaded data for provenance verification
3. **Fix `03_clean_data.R`** to:
   - Remove fallback logic that silently picks up any CSV
   - Add explicit provenance check (verify data source hash)
   - Only load `qcew_annual.csv` (the real BLS data)
   - Log data provenance metadata

**Files:** `code/01_fetch_qcew.R` (rewrite), `code/01b_create_cached_qcew.R` (delete), `code/03_clean_data.R` (fix provenance)

### Workstream 2: Fix Methodology Issues (HIGH)

**Problem 1:** Pre-trend F-test uses nonstandard statistic (average of squared t-stats with F reference distribution df=Inf). Should use proper joint Wald test accounting for covariance.

**Fix:** In `04_main_analysis.R`, replace the manual F-stat computation with a proper joint Wald test using the variance-covariance matrix from the CS estimator. The `did` package provides this via `aggte()` which already computes a proper Wald test statistic.

**Problem 2:** Leave-one-out only runs for first 10 treated states, but paper claims all treated states.

**Fix:** In `05_robustness.R`, run leave-one-out for ALL treated states (not `treated_states[1:min(10, ...)]`).

**Problem 3:** HonestDiD implementation is a manual approximation rather than using the actual `HonestDiD` package functions.

**Fix:** Use `HonestDiD::createSensitivityResults()` or `HonestDiD::createSensitivityResults_relativeMagnitudes()` properly.

**Files:** `code/04_main_analysis.R`, `code/05_robustness.R`

### Workstream 3: Add Wage Analysis (NEW — all 3 reviewers requested)

All three reviewers independently asked: "Are these good jobs?" QCEW data includes `annual_avg_wkly_wage` which we'll now fetch in Workstream 1.

**Analysis:**
- DiD on log(avg_weekly_wage) using same CS framework
- Compare gambling wage levels to state median
- Report in new Table (wage effects) and discuss in Results

**Files:** `code/04_main_analysis.R` (add wage DiD), `code/07_tables.R` (new wage table), `paper.tex` (new results subsection)

### Workstream 4: Add Spillover/Border Analysis (NEW — all 3 reviewers requested)

Construct neighbor treatment exposure variable (proportion of bordering states that have legalized) and test whether a state's own employment changes when neighbors legalize.

**Analysis:**
- Construct full state adjacency matrix (the parent only had ~10 states)
- Create `neighbor_exposure` = share of neighbors with legal sports betting at time t
- TWFE regression: `empl_7132 ~ treated + neighbor_exposure | state + year`
- Test for competitive dynamics (does neighbor legalization reduce own employment?)

**Files:** `code/03_clean_data.R` (full adjacency matrix), `code/05_robustness.R` (spillover regression), `paper.tex` (new subsection)

### Workstream 5: Paper Improvements

1. **Fix title footnote URL** — currently points to private repo (`anthropics/auto-policy-evals`), must use public repo (`SocialCatalystLab/ape-papers`)
2. **Add suggested references** — Strumpf (2005), Garrett (2003), Grote & Matheson (2020)
3. **Add revision footnote** — noting this is a revision of the v2 paper
4. **Update results** — all numbers in paper.tex will change because we're now using real BLS data instead of simulated data. Results must be regenerated from scratch and paper text updated to match.
5. **Expand discussion** — integrate wage findings and spillover results into Discussion section

**Files:** `paper.tex`, `references.bib`

---

## Execution Order

1. Set up workspace (copy parent artifacts, create `output/paper_N/vX/`)
2. **Workstream 1** — Fix data pipeline (delete simulated data script, rewrite fetch, fix provenance)
3. Run `00_packages.R` → `01_fetch_qcew.R` → `02_fetch_policy.R` → verify real data downloaded
4. **Workstream 2** — Fix methodology (F-test, leave-one-out, HonestDiD)
5. **Workstream 3** — Add wage analysis code
6. **Workstream 4** — Add spillover analysis code
7. Fix `03_clean_data.R` (provenance + adjacency matrix)
8. Run full pipeline: `03_clean_data.R` → `04_main_analysis.R` → `05_robustness.R` → `06_figures.R` → `07_tables.R`
9. **Workstream 5** — Update paper.tex with new results, references, discussion
10. Compile PDF, visual QA
11. Review workflow (advisor → exhibit → prose → external → revision)
12. Publish with `--parent apep_0038`

---

## Verification

- Scan verdict should change from SEVERE to CLEAN (no `01b_create_cached_qcew.R`, no simulated data)
- All R scripts run end-to-end and produce output
- Pre-trend F-test uses proper joint Wald test
- Leave-one-out covers ALL treated states
- QCEW data has SHA256 provenance hash
- Wage analysis table appears in paper
- Spillover analysis discussed in paper
- All paper.tex numbers match R script output
- Paper compiles cleanly, 25+ pages
