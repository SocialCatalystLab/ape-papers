# Reply to Reviewers

**Paper:** Medicaid Postpartum Coverage Extensions (apep_0157, v4)
**Date:** 2026-02-04

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Thin Control Group
We acknowledge this as the paper's primary structural limitation. The leave-one-out analysis (referenced in Section 7.10) confirms that no single control state drives the results; all four leave-one-out specifications produce nearly identical ATTs. We have added observation counts and cluster counts to all tables. Synthetic control methods for the late-adopter cohort are noted as a promising extension for future work.

### Permutation Inference (200 draws)
With an observed p-value of 0.75, the Monte Carlo standard error is approximately sqrt(0.75 * 0.25 / 200) = 0.031, yielding a 95% CI of [0.69, 0.81]. Since the p-value is far from any conventional significance threshold, increasing to 1,000+ permutations would not change the qualitative conclusion. We note this in the paper. Each permutation runs the full CS-DiD pipeline (att_gt + aggte), which is computationally intensive.

### Inference Comparison Table
Table 3 now reports cluster-robust SEs, 95% CIs, WCB p-values, and CS-DiD permutation p-values side-by-side for all main specifications. The CS-DiD state-cluster bootstrap p-values are also reported.

### Unwinding Intensity Index
This is an excellent suggestion that we plan to pursue in a future revision using CMS/KFF administrative data on state-level disenrollment rates. Currently, the paper provides indirect evidence: the DDD employer insurance placebo is null, cohort-specific ATTs do not correlate with unwinding timing, and the DDD pre-trend joint test is insignificant (F = 0.77, p = 0.547).

### Missing References
We have added Ferman & Pinto (2021) and cite it in the inference discussion. The Ibragimov-Müller and Athey-Imbens references are noted for a future revision.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Power Limitations
We now report an explicit DDD power analysis (Section 7.9): MDE = 3.4 pp at 80% power, with 55% power at 2.5 pp and 99% power at 5 pp. This makes transparent what effect sizes the design can and cannot detect.

### ACS Measurement Limitations
The Monte Carlo attenuation calibration now covers four adoption-timing scenarios (Jan/Apr/Jul/Oct), showing ITT scaling factors ranging from 0.21 to 0.83. We acknowledge that administrative data with exact enrollment dates would avoid this attenuation.

### Missing Literature
Ferman & Pinto (2021) has been added and cited. Additional references (Eggers et al., Goldin et al.) are noted for future revision.

### DDD as Primary Specification
The paper now more clearly frames the DDD as the preferred specification (Section 8.3) and the standard DiD as a stepping stone that motivates the DDD.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### DDD Event Study Clarity
Figure 8 confidence intervals are wide at extreme event times (e=-2, e=2) due to the thin control group and the differenced outcome's higher variance. We have added the joint Wald test (Table 6) as a formal complement to the visual evidence.

### Table 3 Panel C
The table now clearly labels "TWFE DDD (Treated x PP)" and "CS-DiD on Diff. Outcome" as separate rows with distinct footnotes explaining the specification differences.

### Hispanic Heterogeneity
This is an important observation. The larger negative effect for Hispanic women may reflect differential unwinding patterns (Hispanic women were disproportionately affected by procedural disenrollments). We note this as a concern requiring further investigation with administrative data.

---

## Summary of Changes

| Concern | Action | Status |
|---------|--------|--------|
| SE precision mismatch | Fixed all text/table discrepancies | Done |
| Permutation count (500 vs 200) | Made consistent throughout | Done |
| Table 7 missing N (states) | Added cohort counts | Done |
| Table 3 observation counts | Added state-year N | Done |
| 2024 data availability | Added footnote with Census URL | Done |
| Monte Carlo as "simulated data" | Added explicit calibration disclaimer | Done |
| July 1 rule for 2024 cohort | Added clarifying text | Done |
| DDD power analysis | Added MDE and power table | Done |
| HonestDiD plain language | Added paragraph summarizing CI interpretation | Done |
| Ferman & Pinto reference | Added and cited | Done |
| Unwinding intensity index | Deferred to future revision | Noted |
| Synthetic controls | Deferred to future revision | Noted |
| 1000+ permutations | Justified current 200 | Noted |
