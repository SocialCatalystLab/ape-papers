# Reply to Reviewers — Paper 109

**Paper:** Must-Access Prescription Drug Monitoring Program Mandates and State Employment
**Date:** 2026-01-29

---

## Summary of Changes

We thank the three reviewers for their thorough and constructive feedback. The revised manuscript addresses the major concerns as follows:

1. **Wyoming data restored:** The estimation sample now includes all 50 states (850 state-year observations), including Wyoming which was previously excluded.

2. **First-stage prescribing evidence:** Section 5.1 now provides first-stage calibration from the literature, documenting that must-access mandates reduce prescribing by 8–13% (Buchmueller & Carey 2018; Dave et al. 2021; Brady et al. 2014). A calibration table is provided in the appendix.

3. **Covariates in CS-DiD:** The preferred CS specification is now supplemented with a covariate-adjusted doubly-robust model controlling for 2007 baseline log employment and baseline unemployment rate. The covariate-adjusted ATT is +0.0076 (SE=0.0070, p=0.278)—still null.

4. **Borusyak-Jaravel-Spiess (BJS) imputation estimator:** Implemented as an alternative to CS-DiD. The BJS average post-treatment effect is -0.0075 (SE=0.0144)—small, negative, and insignificant. Event-study figure provided in the appendix.

5. **Pre-COVID subsample:** Re-estimated restricting to 2007–2019 (excluding pandemic-era data). ATT = +0.0069 (SE=0.0066, p=0.301) for log employment; -0.438 (SE=0.372, p=0.239) for unemployment rate. Both null.

6. **HonestDiD sensitivity:** Rambachan & Roth (2023) relative magnitudes bounds now reported with exact values. The null holds through Mbar=2.0 (violations twice the largest pre-treatment trend change). Smoothness-based bounds also all include zero.

7. **Formal MDE calculation:** MDE at 80% power = 2.4% for log employment. Back-of-envelope calibration shows this exceeds the plausible aggregate effect (0.1%), confirming the design may be underpowered for realistic subpopulation effects.

8. **Missing references added:** Borusyak, Jaravel & Spiess (2024); Rambachan & Roth (2023); Arkhangelsky et al. (2021); Conley & Taber (2011).

9. **Comprehensive robustness table:** New appendix table summarizes results across CS-DiD (unconditional), CS-DiD (with covariates), BJS imputation, pre-COVID subsample, and TWFE—all null.

---

## Point-by-Point Responses

### Reviewer 1

**R1.1: No in-sample first stage.**
We now provide a literature-based first-stage calibration in Section 5.1, documenting prescribing reductions of 8–13% from the existing literature. A calibration table (Table A.X in appendix) summarizes estimates from Buchmueller & Carey (2018), Dave et al. (2021), Patrick et al. (2016), and Brady et al. (2014). We acknowledge that in-sample estimation using CDC prescribing data would strengthen the analysis further; data access limitations prevented this in the current revision. The calibration approach, however, establishes that the treatment variable captures meaningful policy-relevant variation—the prescribing channel is well-documented—making the null employment result interpretable as genuine attenuation rather than weak treatment.

**R1.2: No covariates in CS-DiD.**
Addressed. We now report a covariate-adjusted CS specification with 2007 baseline log employment and unemployment rate. The ATT is +0.0076 (SE=0.0070, p=0.278), confirming the null. See Section 6.2 (Alternative Estimators).

**R1.3: Missing alternative estimators (BJS, SDID).**
We implement the Borusyak, Jaravel & Spiess (2024) imputation estimator (average post-treatment effect: -0.0075, SE=0.0144). Results and event-study figure are in the appendix. We do not implement Synthetic DiD (Arkhangelsky et al. 2021) as it is designed for settings with few treated units; with 46 treated states, the CS and BJS estimators are more appropriate.

**R1.4: COVID sensitivity.**
The pre-COVID (2007–2019) subsample yields ATT = +0.0069 (SE=0.0066, p=0.301), confirming the null is not driven by pandemic dynamics. See Section 6.6.

**R1.5: HonestDiD sensitivity.**
Updated with exact Rambachan & Roth (2023) bounds. At Mbar=0 (exact parallel trends), 95% CI = [-0.0047, 0.0037]; at Mbar=2.0, CI = [-0.0360, 0.0337]. All include zero. See Section 6.5.

**R1.6: CIs in main table.**
95% CIs are now reported in the comprehensive robustness table (appendix) alongside all estimators. The main text explicitly states the CI bounds for each key result.

**R1.7: Missing references.**
Added: Borusyak et al. (2024), Rambachan & Roth (2023), Arkhangelsky et al. (2021), Conley & Taber (2011).

---

### Reviewer 2

**R2.1: Wyoming exclusion unacceptable.**
Addressed. Wyoming is now included in the estimation sample (50 states, 850 observations). LAUS data for Wyoming were obtained from BLS published tables.

**R2.2: No covariates in DR model.**
See R1.2 above. Covariate-adjusted specification now reported.

**R2.3: First stage needed.**
See R1.1 above. Literature-based calibration provided.

**R2.4: Treatment heterogeneity / mandate strength.**
We acknowledge in the revised Limitations section (Section 7.3) that treating all mandates as homogeneous 0/1 may attenuate effects. A dose-response analysis exploiting variation in mandate provisions (substance coverage, enforcement mechanisms) is an important direction for future work. Data on mandate strength provisions were not systematically available for all states in this revision.

**R2.5: Power analysis / MDE.**
Formal MDE calculation now provided in Section 5.2. MDE at 80% power = 2.4% for log employment. Back-of-envelope calibration shows the plausible aggregate effect (~0.1%) is an order of magnitude below the MDE, confirming the design is underpowered for realistic subpopulation effects diluted in aggregate data.

**R2.6: Monthly LAUS data.**
We acknowledge this suggestion but retain annual averages for consistency with the treatment coding. Monthly data would introduce complications with partial-year exposure and seasonal adjustment. This is discussed in the Data section.

**R2.7: Alternative estimators.**
BJS imputation estimator now implemented (see R1.3). SDID is not implemented because it is designed for few-treated-unit settings.

---

### Reviewer 3

**R3.1: First stage / mechanism validation.**
See R1.1 above. Literature calibration provided. We now explicitly frame the paper as testing whether the well-documented prescribing channel translates into detectable labor market effects.

**R3.2: COVID contamination.**
Pre-COVID subsample (2007–2019) results confirm the null. See R1.4.

**R3.3: No covariates in CS specification.**
See R1.2. Covariate-adjusted results now reported.

**R3.4: BJS imputation needed.**
Implemented. See R1.3.

**R3.5: Writing improvements / sharper framing.**
We have tightened the introduction to lead with the puzzle (well-documented prescribing reductions but unknown downstream labor effects) and added the back-of-envelope magnitude calibration. The first-stage section now directly frames the interpretive challenge.

**R3.6: MDE / power calculation.**
See R2.5. Formal MDE now provided with calibration against plausible effect sizes.

**R3.7: HonestDiD sensitivity.**
See R1.5. Exact Rambachan & Roth bounds now reported.

**R3.8: Missing references.**
All requested references added. See R1.7.

---

## Remaining Limitations (acknowledged in revised manuscript)

1. **Aggregate outcome:** State-level employment cannot detect subpopulation effects. Individual-level data with prescription exposure would provide a more powerful test.

2. **Mandate homogeneity:** Binary 0/1 coding does not capture mandate strength variation. Future work should construct a mandate intensity index.

3. **No in-sample first stage:** Literature calibration is provided but in-sample estimation would be stronger.

4. **Near-universal adoption:** With 46 of 50 states adopting, the identification challenge inherent to near-universal policies remains.

5. **Power:** MDE of 2.4% exceeds plausible aggregate effects. The design is informative about large effects but cannot rule out meaningful subpopulation effects diluted in aggregate data.
