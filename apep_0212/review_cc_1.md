# Internal Claude Code Review (Round 1)

**Paper:** Moral Foundations Under Digital Pressure: Does Broadband Internet Shift the Moral Language of Local Politicians?
**Reviewer:** Claude Code (claude-opus-4-6)
**Date:** 2026-02-07
**PDF:** paper.pdf (44 pages)

---

## PART 1: CRITICAL REVIEW

### Methodology Assessment

**Strengths:**
- Callaway & Sant'Anna (2021) staggered DiD is the appropriate estimator for this setting. The choice of not-yet-treated controls (rather than never-treated) is well-motivated given only 9 never-treated places out of 530.
- HonestDiD sensitivity analysis (Rambachan & Roth 2023) is the current gold standard and strengthens the null interpretation.
- Pre-trend tests pass convincingly (joint p = 0.998 for universalism index).
- MDE and TOST equivalence testing make the null informative by comparing detectable effects to Enke (2020) benchmarks.

**Concerns:**

1. **Power is the binding constraint.** With 98.3% eventually treated and only 9 never-treated places, the design is fundamentally underpowered. The MDE of 1.32 SD means the paper cannot rule out effects smaller than Enke's cross-sectional county-level estimates. This is honestly reported but limits the paper's ability to distinguish "no effect" from "small effect."

2. **Heterogeneity is largely infeasible.** Partisanship and rurality subgroup analyses fail due to insufficient control units. Only the moral orientation split produces estimates (binding-dominant ATT = 0.267, p = 0.053). The paper reports this honestly, but the inability to test mechanisms weakens the cheap-talk interpretation.

3. **MFD measurement noise.** Dictionary-based moral language scoring is coarse — it counts word stems without regard to context, negation, or framing. Measurement error attenuates effects toward zero, making it impossible to distinguish a true null from attenuation bias. The paper acknowledges this in limitations but cannot resolve it.

4. **ACS 5-year smoothing.** Treatment timing is determined by 5-year ACS broadband estimates (table B28002), which pool data from t-4 to t. This introduces measurement error in treatment timing. The 1-year anticipation window partially addresses this, but true treatment could be earlier than observed.

5. **2017 cohort pre-trend limitation.** The 2017 cohort (largest) has no pre-treatment periods in the data, so parallel trends cannot be verified for this group. The paper notes this but could be more explicit about what share of the aggregate ATT is identified from cohorts without pre-trend verification.

### Internal Consistency

- Sample sizes are consistent across tables (530 places, 2,751 place-years, 47 states).
- Moral foundation scores are correctly labeled as "scores" (words per 1,000), not "shares."
- The universalism index is defined as the simple difference (individualizing - binding), consistent throughout.
- Event study figures match the text descriptions.
- Table footnotes explain convergence failures for alternative thresholds and estimators.

### Statistical Reporting

- Standard errors in parentheses throughout.
- P-values reported for all main estimates.
- 95% CIs shown in event study figures.
- Cluster count (47 states) stated in empirical strategy.
- Sun-Abraham SE unavailable due to multicollinearity — reported honestly.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

### To Strengthen the Contribution

1. **Frame as a "methodological contribution with substantive null."** The paper demonstrates how to apply modern staggered DiD to text-as-data outcomes with near-universal treatment. This is novel and useful independent of the null result.

2. **Benchmark the null against other information shocks.** The paper compares MDEs to Enke (2020) cross-sectional effects. Additionally benchmarking against the internet-and-polarization literature (Boxell et al. 2017 finds 0.06-0.12 SD effects on affective polarization) would contextualize what effect sizes are "reasonable" for information shocks on political attitudes.

3. **The cheap-talk interpretation is the paper's strongest theoretical contribution.** The idea that local government speech is institutionally constrained ("potholes and permits") and therefore insensitive to information environment changes is compelling and novel. This could be elevated further — perhaps with a simple model comparing "cheap talk" equilibria with and without information shocks.

4. **Future IV suggestion is productive.** The FCC ARRA/BEAD grants discussion in Section 7.4 is well-motivated. A future paper exploiting quasi-random grant allocation thresholds could resolve the power issue by providing sharper treatment variation.

### Feasible Extensions (Lower Priority)

5. **Word-count placebo decomposition.** Instead of just testing whether total word count changes, decompose into moral vs. non-moral vocabulary to check whether broadband affects *any* vocabulary, or specifically moral language.

6. **Cross-referencing with survey data.** If Cooperative Election Study or similar survey data can be matched to treated places, comparing survey-measured moral attitudes to text-measured moral language would help validate the MFD approach.

---

## DECISION

The paper is methodologically rigorous, honest about limitations, and makes a genuine contribution through its informative null and cheap-talk interpretation. The power constraint is fundamental and cannot be resolved within the current design. Publication is warranted as a well-executed contribution to the political economy of moral language.

**DECISION: MINOR REVISION**
