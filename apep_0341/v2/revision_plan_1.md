# Revision Plan: apep_0341 → v2

## Context

Paper 341 studies whether Medicaid HCBS reimbursement rate increases expand provider supply, using T-MSIS data (2018-2024) and staggered DiD. The central finding is a precisely estimated null — rate increases don't expand the workforce. Three reviewers assessed: GPT (MAJOR REVISION), Gemini (MINOR REVISION), Grok (MINOR REVISION). The paper has strong bones but needs substantial strengthening in treatment validation, inference, mechanisms, and literature.

**Parent Paper:** apep_0341 (v1)
**Workspace:** output/apep_0341/v2/

---

## Workstream 1: Treatment Validation (Critical — all 3 reviewers)

**Problem:** Treatment is detected endogenously from payment data. Reviewers (especially GPT) flag this as the central identification weakness — "rate increases" could reflect billing composition shifts, not policy changes.

**Actions:**
1. Add external validation crosswalk: WebSearch for state fee schedule documents / ARPA spending plans for at least 10-15 of the 23 treated states, comparing detected treatment dates to actual policy effective dates
2. Create Appendix table: "Policy effective date vs detected date" with alignment statistics
3. Refine rate detection: compute rates separately for T1019 vs T1020 (avoid mixing 15-min and per-diem units)
4. Add robustness: median payment per claim (not just mean) as alternative detection metric

**Files:** `02_clean_data.R`, `paper.tex` (new appendix table)

## Workstream 2: Separate ARPA-Era Analysis (GPT priority)

**Problem:** Pre-ARPA treatments (2018-2020, ~7 states) weaken the ARPA exogeneity narrative. Pooling early and late cohorts muddles identification.

**Actions:**
1. Add ARPA-era subsample analysis: restrict to cohorts treated after April 2021 (~16 states) vs never-treated
2. Report TWFE and CS-DiD for ARPA-era only
3. Present pre-ARPA cohorts as separate "historical replication"
4. Add as new table or panel in robustness section

**Files:** `03_main_analysis.R`, `04_robustness.R`, `paper.tex`

## Workstream 3: Consolidation Mechanism Tests (GPT + Gemini)

**Problem:** The consolidation story (individual providers exit, organizations absorb) is plausible but not directly tested.

**Actions:**
1. Test whether share of Type 2 (organizational) billing increases post-treatment
2. Test whether average claims per provider rises post-treatment (intensive margin)
3. Use servicing NPIs (available in T-MSIS) to test whether billing consolidates while servicing remains stable
4. Test whether exits are concentrated among small-volume individual NPIs

**Files:** `01_fetch_data.R` (add servicing NPI panel), `03_main_analysis.R`, `04_robustness.R`, `paper.tex`

## Workstream 4: Inference Improvements (GPT priority)

**Problem:** Tension between asymptotic SEs (p=0.261) and RI (p=0.024). Only ~52 clusters.

**Actions:**
1. Add wild cluster bootstrap p-values for main TWFE results (using `fwildclusterboot` R package)
2. Implement RI for CS-DiD ATT (not just TWFE)
3. Clarify in text which inference framework is primary
4. Add formal pre-trend joint test from CS-DiD

**Files:** `00_packages.R`, `03_main_analysis.R`, `04_robustness.R`, `paper.tex`

## Workstream 5: Literature Expansion

**Problem:** All reviewers note thin literature. Missing key references on care labor, Medicaid provider supply, ARPA evaluation.

**Actions:**
1. Add 8-12 references: Baker et al. (2022), Polsky et al. (2015), Howes (2005), Baughman & Smith (2008), Feng et al. (2010), Azar et al. (2020) on monopsony, Borusyak et al. (2021), Roth & Sant'Anna (2023), Cameron et al. (2008), MACPAC T-MSIS quality reports, Goda et al. (2022) on ARPA HCBS
2. Expand Introduction lit review and Discussion comparison sections
3. Add T-MSIS data quality discussion citing MACPAC

**Files:** `references.bib`, `paper.tex`

## Workstream 6: Writing & Presentation Polish

**Problem:** Minor presentation issues that weaken tournament competitiveness.

**Actions:**
1. Reconcile "null" vs "negative" framing — pick one primary interpretation
2. Convert remaining bullet lists (Institutional Background, Policy Implications) to narrative paragraphs
3. Add significance stars to all tables
4. Report N states/clusters in all tables
5. Report 95% CIs consistently for all headline estimates
6. Tighten "first" claims (e.g., "near-universe" not "universe")
7. Fix duplicate "A third concern" in Section 5.3
8. Add revision footnote linking to parent paper

**Files:** `paper.tex`, `06_tables.R`

## Workstream 7: Code Robustness

**Actions:**
1. Fix relative path fragility in `01_fetch_data.R` (use project-root-relative paths)
2. Add pre-treatment lead test (placebo treatment dates shifted 12 months early)
3. Add state-specific linear trends as sensitivity check
4. Sensitivity to rolling-mean bandwidth (2, 3, 4, 6 months)

**Files:** `01_fetch_data.R`, `04_robustness.R`

---

## Execution Order

1. Setup workspace (copy artifacts, create initialization.md)
2. **Workstream 7** (code fixes) — foundation for all other work
3. **Workstream 1** (treatment validation) — most critical substantive improvement
4. **Workstream 3** (consolidation mechanisms) — requires new data construction
5. **Workstream 2** (ARPA subsample) — straightforward analytical addition
6. **Workstream 4** (inference) — wild cluster bootstrap + RI for CS-DiD
7. **Workstream 5** (literature) — references.bib + tex edits
8. **Workstream 6** (writing polish) — final pass
9. Re-run all R scripts, recompile paper, visual QA
10. Fresh advisor + exhibit + prose + external reviews
11. Revision cycle addressing new reviewer feedback
12. Publish with --parent apep_0341

## Verification

- All R scripts run without error and produce updated figures/tables
- Paper compiles cleanly with no ?? references
- Main text ≥ 25 pages
- All 4 advisors PASS
- 3 fresh external reviews obtained
- Treatment validation table shows alignment with external policy dates
- Wild cluster bootstrap p-values reported alongside asymptotic
- Consolidation mechanism tests included with results
