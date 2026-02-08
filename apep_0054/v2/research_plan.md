# Research Plan: Revision of APEP-0054

**Parent Paper:** apep_0054 — Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap

**Revision Date:** 2026-02-03

---

## Revision Objectives

### Part A: Integrity Fixes (Addressing SUSPICIOUS scan verdict)

1. **Data Provenance** (HIGH priority)
   - Create `00_policy_data.R` with officially-cited treatment dates
   - Document source URLs for each state's transparency law
   - Generate `data/transparency_laws.rds` with full provenance

2. **Variable References** (HIGH priority)
   - Fix undefined variables in `05_robustness.R`
   - Ensure `g`, `y`, `event_time`, `treat_post` are properly defined before use

3. **Selection Bias** (HIGH priority)
   - Calculate wage bounds from pre-treatment period only (2014-2020)
   - Apply same bounds to all observations
   - Document methodology in paper

### Part B: Content Improvements (Tournament enhancement)

1. **HonestDiD Sensitivity Analysis**
   - Add Rambachan-Roth bounds on parallel trends violations
   - Show robustness to bounded PT violations up to M = 2
   - New figure: fig7_honestdid.pdf

2. **Pre-Trends Power Analysis**
   - Calculate MDE for pre-trend tests
   - Document power to detect violations
   - Strengthen parallel trends validation

3. **Enhanced Documentation**
   - Add legislative citations section to appendix
   - Update data section with provenance details
   - Add revision footnote linking to parent

---

## Research Question (Inherited)

Do state salary transparency laws—requiring employers to disclose salary ranges in job postings—affect:
1. Overall wage levels for workers?
2. The gender wage gap?

## Identification Strategy (Inherited)

Staggered difference-in-differences using Callaway-Sant'Anna estimator with never-treated controls. Triple-difference for gender effects.

## Data Sources (Inherited)

- **Primary:** IPUMS CPS ASEC 2015-2024 (income years 2014-2023)
- **Treatment:** State salary transparency laws (now with official citations)

## Key Findings (Expected to be confirmed)

1. Transparency laws reduce average wages by ~1.5-2%
2. Gender wage gap narrows by ~1 percentage point
3. Effects concentrated in high-bargaining occupations

## Files Modified in This Revision

| File | Change |
|------|--------|
| `code/00_policy_data.R` | NEW — Policy data with citations |
| `code/00_packages.R` | Updated — HonestDiD, removed inline policy data |
| `code/02_clean_data.R` | Fixed — Pre-treatment wage bounds |
| `code/05_robustness.R` | Fixed — Variable definitions, added HonestDiD |
| `paper.tex` | Updated — New sections, citations, revision footnote |

---

## Quality Checklist

- [x] Treatment dates have official citations
- [x] Wage trimming uses pre-treatment bounds only
- [x] Variables defined before use in robustness scripts
- [x] HonestDiD sensitivity analysis added
- [x] Pre-trends power analysis documented
- [x] Revision footnote links to parent paper
- [ ] Paper compiles to PDF
- [ ] Paper is 25+ pages
- [ ] Advisor review passes (3/4)
- [ ] External reviews completed (3)
- [ ] Published with --parent apep_0054
