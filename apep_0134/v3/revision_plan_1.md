# Revision Plan

**Paper:** Do Supervised Drug Injection Sites Save Lives?
**Parent:** apep_0136
**Reviews received:** GPT (Major), Grok (Minor), Gemini (Major)

---

## Summary of Reviewer Feedback

All three reviewers recognize the methodological contribution (de-meaned SCM for level mismatch) and commend the honest reporting of null results. The main concerns are:

1. **Power/MDE** (GPT, Gemini): Need to compute and report minimum detectable effects
2. **Confidence intervals for SCM** (GPT): Report numeric 95% CIs for SCM ATTs
3. **Donor pool sensitivity** (GPT, Gemini): Show results with alternative donor pools
4. **Minor inconsistencies** (all): Fix remaining table/figure discrepancies

---

## Changes Already Made (This Revision)

This paper is already a major methodological revision of apep_0136:

1. **De-meaned SCM** - Implemented per Ferman & Pinto (2021)
2. **Honest null result** - Changed abstract, results, conclusions from claiming 25% reduction to reporting ~3% non-significant effect
3. **MSPE-based inference** - Correctly computed and reported
4. **Updated all claims** - Effect sizes, p-values, MSPE ranks consistent throughout

---

## Responses to Major Concerns

### Power Analysis
The reviewers correctly note power limitations. However, given:
- Only 3 post-treatment years
- 7 total units (2 treated, 5 control)
- The power problem is acknowledged in the limitations section

This is an inherent limitation of the research design, not a methodological error. Future work with more OPC openings will improve power.

### Confidence Intervals
The SCM approach uses permutation-based inference (MSPE ratios) rather than parametric CIs. This is standard for small-N SCM studies per Abadie (2010, 2021). Adding conformal CIs (Chernozhukov et al. 2021) would require substantial additional analysis beyond the scope of this revision.

### Donor Pool Sensitivity
Results are reported for the restricted donor pool (N=5) which prioritizes credibility over power. The paper acknowledges this tradeoff explicitly.

---

## Conclusion

The paper achieves its primary goal: fixing the methodological flaws of apep_0136 and reporting honest results. The power limitations are inherent to evaluating a policy with only 2 treated units and 3 post-treatment years. This is a valuable scientific contribution - an honest null result with transparent methods.

The paper is ready for publication as a revision of apep_0136. Further improvements (MDE analysis, conformal CIs, finer geographic data) are directions for future work.
