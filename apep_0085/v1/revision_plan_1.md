# Revision Plan — Paper 109

**Date:** 2026-01-29
**Reviews:** 3 external (GPT 5.2): 2x REJECT AND RESUBMIT, 1x MAJOR REVISION

---

## Consolidated Reviewer Concerns (by priority)

### Priority 1: Critical (all 3 reviewers flagged)

**1. First-stage evidence missing (R1, R2, R3)**
- Reviewers demand evidence that mandates reduce prescribing in the same sample/time window
- Without this, null downstream effect is uninterpretable (weak treatment vs genuine null)
- **Action:** Fetch CDC state-level opioid prescribing rates (available 2006-2022). Run CS-DiD on prescribing as outcome. Add as Section 5.1 "First Stage: Prescribing Effects"

**2. No covariates in CS-DiD DR model (R1, R2, R3)**
- Current CS specification includes no covariates — relying on unconditional parallel trends
- DR is only doubly robust conditional on covariates; without them it's plain DiD
- **Action:** Add pre-treatment covariates to CS-DiD: log population, percent prime-age. Re-estimate with covariates and show results alongside baseline.

**3. COVID sensitivity (R1, R2, R3)**
- Late cohorts (2020-2021) confounded by pandemic
- **Action:** Re-estimate restricting sample to 2007-2019 (pre-COVID). Show main ATT and event studies.

**4. Alternative estimators (R1, R2, R3)**
- All reviewers want Borusyak-Jaravel-Spiess imputation estimator
- R3 also wants Synthetic DiD (Arkhangelsky et al. 2021)
- **Action:** Implement BJS via didimputation R package. Implement SDID via synthdid package. Report alongside CS.

**5. MDE / Power analysis (R1, R2, R3)**
- Paper claims "informative null" but no formal MDE calculation
- **Action:** Add formal MDE. Use CI bounds to compute implied job effects. Add back-of-envelope calibration.

**6. HonestDiD sensitivity (R1, R2)**
- Formal bounds on parallel trends violations
- **Action:** Implement HonestDiD R package for key specification.

### Priority 2: Important (2+ reviewers)

**7. Missing references (R1, R2, R3)**
- Borusyak, Jaravel & Spiess (2021), Rambachan & Roth (2023), Alpert et al. (2018), Arkhangelsky et al. (2021), Conley & Taber (2011)
- **Action:** Add all citations to bibliography and engage in text

**8. Wyoming data (R2)**
- Excluding a treated state due to "API extraction failure" is unacceptable
- **Action:** Fetch Wyoming LAUS data directly from BLS. Include in estimation sample.

**9. CIs in main results table (R1, R2, R3)**
- Table 3 reports only SEs, not 95% CIs
- **Action:** Add 95% CI column to Table 3

**10. Writing improvements (all 3)**
- Sharper puzzle framing in intro
- Back-of-envelope magnitude calibration early
- Reduce repetition
- **Action:** Revise intro, add calibration paragraph, tighten robustness

### Priority 3: Desirable but not feasible in this revision

- Monthly LAUS data, County-level analysis, CPS microdata, QCEW by sector, SSDI claims
- Treatment strength index (requires detailed legislative coding)
- All flagged as future work in revised Discussion

---

## Implementation Order

1. Fetch Wyoming + CDC prescribing data (new R script: 08_revision.R)
2. Re-run main analysis with Wyoming included
3. Add covariates to CS-DiD
4. Run first-stage (prescribing) analysis
5. Run BJS imputation estimator
6. Run SDID robustness
7. Run pre-COVID (2007-2019) sensitivity
8. Compute formal MDE
9. Run HonestDiD sensitivity
10. Update all tables and figures
11. Add references to bibliography
12. Revise paper.tex comprehensively
13. Recompile and visual QA
14. Write reply_to_reviewers.md
