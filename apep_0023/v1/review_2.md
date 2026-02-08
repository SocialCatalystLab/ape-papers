# Internal Review - Round 2

**Paper:** Does Bundling Workforce Services with Medicaid Expansion Improve Employment Outcomes? Evidence from Montana's HELP-Link Program

**Date:** January 2026

**Review Type:** Claude Code Internal (Adversarial)

---

## Summary

The Round 1 revisions substantially improved the paper. Bootstrap standard errors are now correctly implemented for the event study and heterogeneity analyses, Figure 4 has been added, and the limitations discussion has been expanded. However, several issues remain that should be addressed before the paper reaches publication quality.

---

## Remaining Issues

### Major Issues

**1. Parallel Trends Test Not Formally Reported**

*Issue:* The paper states that pre-treatment coefficients are "not statistically distinguishable from zero" but does not report a formal joint test of parallel trends. With a 2014 coefficient of 0.16 (and SE ~0.17), the pre-period pattern warrants more rigorous analysis.

*Recommendation:* Add a formal joint F-test or chi-squared test of whether all pre-period coefficients jointly equal zero. Report the test statistic and p-value explicitly.

**2. Table 2 Column (3) Empty**

*Issue:* Column (3) labeled "Event Study" shows "---" for all coefficients, which is confusing and wastes space. The event study results are in Figure 2, not the table.

*Recommendation:* Either (a) remove column (3) from Table 2, or (b) replace it with a meaningful alternative specification (e.g., "Placebo" using near-eligible as treatment).

**3. Figure 3 Visual Clutter**

*Issue:* In Figure 3 (heterogeneity), the group category labels ("Age", "Sex", "Education", "Disability") appear mispositioned in the figure, with "Disability" appearing below the plot area rather than aligned with its section.

*Recommendation:* Reposition the category labels to be properly aligned, or use horizontal lines/separators between groups instead of floating text labels.

---

### Moderate Issues

**4. Robustness Checks Inconsistently Documented**

*Issue:* Section 5.4 mentions "Alternative Control States" with Wyoming and "Placebo Tests" but these are not shown in any table. Table A1 only shows four specifications (Baseline, 100% FPL, State Trends, No 2014).

*Recommendation:* Either (a) add the Wyoming and placebo results to Table A1, or (b) remove the claims from the text if results were not actually computed.

**5. Figure 4 Counterfactual Computation Unclear**

*Issue:* The counterfactual line in Figure 4 is labeled "MT Elig. Counterfactual" but the paper doesn't explain how this counterfactual is constructed in the text. For a DDD, the counterfactual involves multiple components.

*Recommendation:* Add a sentence in Section 5.5 explaining how the counterfactual is computed (i.e., what Montana eligible employment would have been if it followed control state eligible trends, adjusted for the near-eligible comparison).

**6. HELP-Link Take-Up Not Discussed**

*Issue:* The paper mentions 3,150 completed training in 2016 but doesn't contextualize this. With ~95,000 Medicaid expansion enrollees mentioned, this represents only ~3% participation. This has implications for interpreting the ITT estimate.

*Recommendation:* Add a paragraph discussing HELP-Link participation rates and what this implies for the treatment-on-treated effect (if ITT is 4.9pp with ~3-5% participation, implied TOT would be implausibly large, suggesting broader spillovers or measurement issues).

**7. Heterogeneity Statistical Tests Missing**

*Issue:* The paper reports different point estimates across subgroups but doesn't test whether these differences are statistically significant. For example, is the 0.070 effect for non-disabled statistically different from the -0.078 for disabled?

*Recommendation:* Add formal tests for heterogeneity, at minimum reporting whether the most striking contrasts (e.g., disabled vs. non-disabled) are statistically distinguishable.

---

### Minor Issues

**8. Figure Captions Could Be More Informative**

*Issue:* Figure 3 caption doesn't mention that error bars represent 95% CIs from cluster bootstrap. Figure 4 caption doesn't explain the counterfactual line.

*Recommendation:* Expand figure captions to be self-contained (reader should understand the figure without referring to the text).

**9. State-Specific Economic Shocks**

*Issue:* The paper doesn't discuss whether Montana experienced any differential economic conditions during 2016-2019 (e.g., commodity prices, agricultural conditions, energy sector) that could confound the estimates.

*Recommendation:* Add a brief discussion in the limitations section noting that state-specific economic shocks are a potential confounder that the DDD cannot fully rule out.

**10. Bootstrap SE vs Analytic SE Discrepancy**

*Issue:* Table 2 reports analytic SEs (0.018) while the event study uses bootstrap SEs (~0.17-0.20). The bootstrap SEs are much larger. Should report bootstrap SEs for the main estimate as well, or explain why analytic SEs are appropriate for the pooled estimate.

*Recommendation:* Either (a) report bootstrap SE for the main DDD estimate in Table 2, or (b) add a footnote explaining that analytic SEs are used for the pooled estimate because [reason].

---

## Summary of Required Changes

| Issue | Priority | Action |
|-------|----------|--------|
| Formal parallel trends test | High | Add joint test of pre-period coefficients |
| Table 2 empty column | High | Remove or repurpose column (3) |
| Figure 3 label positioning | Medium | Reposition group labels |
| Robustness documentation | Medium | Add missing results or remove claims |
| Counterfactual explanation | Medium | Add text explaining Figure 4 construction |
| HELP-Link take-up | Medium | Discuss participation rate implications |
| Heterogeneity tests | Medium | Add statistical tests for subgroup differences |
| Figure captions | Low | Expand to be self-contained |
| Economic shocks | Low | Add to limitations |
| Bootstrap vs analytic SE | Low | Clarify or report bootstrap SE |

---

## Overall Assessment

The paper has improved substantially after Round 1 revisions. The remaining issues are largely about completeness and clarity rather than fundamental methodological problems. Addressing these issues would bring the paper to a strong working paper standard.
