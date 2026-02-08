# Internal Review: Identification and Methodology

**Paper:** "Making Wages Visible: Labor Market Dynamics Under Salary Transparency"
**Reviewer:** CC-1 (Identification/Econometrics Focus)
**Date:** February 2026

---

## 1. Summary

This paper studies the effects of salary transparency laws---which require employers to post pay ranges in job listings---on wages, the gender wage gap, and labor market dynamism. The analysis exploits staggered adoption across eight U.S. states (Colorado, Connecticut, Nevada, Rhode Island, California, Washington, New York, Hawaii) between 2021 and 2024. The paper combines two datasets: CPS ASEC microdata (614,625 individual observations, income years 2014--2024) and Census QWI administrative records (2,603 state-quarter observations, 2012Q1--2024Q4). Three main findings are reported: (1) null effects on aggregate wages (CPS C-S ATT = -0.004, QWI C-S ATT = -0.001), (2) a narrowing of the gender wage gap by 4--6 percentage points in CPS and 6.1 pp in QWI, and (3) null effects on all five labor market flow variables. The paper argues these findings are consistent with an information equalization channel and inconsistent with employer commitment or costly adjustment.

## 2. Methodology Assessment

The methodological toolkit is commendable and reflects current best practice in applied microeconomics. The use of Callaway and Sant'Anna (2021) as the primary estimator is appropriate given the staggered treatment timing and well-documented biases in TWFE under heterogeneous treatment effects. The paper also reports TWFE and Sun-Abraham (2021) estimates for comparison. The triple-difference design for the gender gap---interacting treatment with a female indicator---is cleanly identified, particularly in the state-by-year fixed effects specification (Table 5, Column 4), which isolates the gender effect from all aggregate state-year shocks.

The robustness toolkit is thorough: Fisher randomization inference (5,000 permutations), HonestDiD sensitivity analysis (Rambachan and Roth 2023), Lee bounds for sample selection, leave-one-treated-state-out analysis, synthetic DiD for the Colorado case, placebo tests (temporal and outcome), and composition diagnostics. This is a notably comprehensive battery for a DiD paper.

The QWI estimation with state-by-quarter fixed effects in the sex-disaggregated DDD (Equation 2) is well designed. With 51 state clusters, the QWI inference is on much firmer ground than the CPS for the gender result.

## 3. Strengths

**Dual-dataset convergent validity.** The central methodological innovation is the use of two independent datasets measuring different populations at different frequencies with different sources of measurement error. The CPS provides individual-level controls that address compositional concerns; the QWI provides administrative precision, quarterly frequency, and labor market flow variables the CPS cannot measure. That both datasets converge on the same qualitative findings---null aggregate, significant gender DDD, same sign and approximate magnitude---is the paper's most convincing feature. This cross-validation substantially reduces the probability that any single-dataset artifact drives the conclusions.

**Honest engagement with inferential limitations.** The paper is commendably transparent about the Fisher p = 0.154 for the CPS gender DDD (Table 8). Rather than burying this or relying exclusively on asymptotic p-values, the authors present both, explain the divergence, and argue---correctly---that the QWI's 51-cluster test provides independent confirmation. The leave-one-out stability ([0.042, 0.054]) and HonestDiD bounds ([0.043, 0.100] at M = 0) are appropriate supplementary evidence.

## 4. Weaknesses

**W1: Eight treated states remain a fundamental limitation.** The paper acknowledges this, but the consequences deserve more weight. With only eight treated clusters in the CPS, the Fisher p = 0.154 is not merely a nuisance---it reflects genuine uncertainty about whether the observed treatment assignment is unusual relative to random permutations. The argument that the QWI "independently confirms" the gender result (Section 7.2) somewhat overstates the independence: both datasets observe the same eight states being treated. The QWI's superior inference comes from having 51 clusters for the control group, but the treatment variation is identical. A confounder affecting all eight treated states simultaneously---for example, if transparency-adopting states also experienced differential post-pandemic labor market recovery by gender---would appear in both datasets.

**W2: Short and heterogeneous post-treatment windows.** Colorado provides four post-treatment years, Connecticut and Nevada three, the 2023 cohort two, and New York/Hawaii only one (Table A.1). The cohort-specific ATTs (Table A.5) reveal wide confidence intervals, particularly for the 2024 cohort ([-0.033, 0.037]). This raises concerns about whether the aggregate estimates are dominated by early adopters with longer exposure. The paper does not report cohort-specific gender DDDs, which would clarify whether the effect is driven primarily by Colorado's four years of post-treatment data.

**W3: Pre-trend concern at t = -2.** The event study (Table A.3) shows a marginally significant coefficient at t = -2 (-0.013, p < 0.10). The paper argues this is unremarkable given multiple testing, and the sign is in the wrong direction for a spurious positive trend. This is a reasonable defense, but the HonestDiD analysis (Table A.8) shows that bounds become completely uninformative for M >= 0.5 (CI: [-1.58, 1.88]). This means the results are sensitive to very modest violations of parallel trends---the design has essentially no power to detect the gender effect once any pre-trend slope is allowed. The paper should discuss this fragility more explicitly.

**W4: QWI industry-level gender DDD magnitudes are imprecise.** The text (Section 6.4) reports high-bargaining industry DDD of 8.8 pp and low-bargaining of 7.0 pp, but Table 7 shows individual industry TWFE coefficients for the gender gap that are mostly insignificant (retail: -0.008, SE = 0.016; finance: 0.030, SE = 0.029). The 8.8 pp and 7.0 pp figures appear to come from a separate pooled specification not shown in the table. This discrepancy should be resolved---either show the specification that produces those estimates or revise the text to match Table 7.

## 5. Suggestions

1. **Report cohort-specific gender DDDs.** The cohort-specific aggregate ATTs are in Table A.5, but the parallel table for the gender DDD is missing. Given that the 2024 cohort (NY, HI) has only one post-treatment year, showing that the gender effect is not entirely driven by Colorado's longer window would strengthen the analysis considerably.

2. **Discuss the common shock problem more carefully.** The eight treated states are all relatively high-income, urban, politically progressive states (Table A.2 shows treated states have higher wages, more education, more metro residents). If post-pandemic gender-specific labor market dynamics differed systematically in these states for reasons unrelated to transparency, both datasets would capture this. A placebo test using a "synthetic treated" group of similar but untreated states (e.g., Massachusetts, Oregon, New Jersey before they adopt) would help.

3. **Clarify the HonestDiD fragility.** The jump from informative bounds at M = 0 to completely uninformative bounds at M = 0.5 (Table A.8) suggests the identifying power depends entirely on exact parallel trends. State this limitation explicitly and discuss what M = 0.5 means in substantive terms.

4. **Reconcile Table 7 with the industry narrative.** The text claims DDD effects of 8.8 pp (high-bargaining) and 7.0 pp (low-bargaining), but Table 7 shows only TWFE coefficients on the gender gap by individual industry, most of which are insignificant. Either add the pooled DDD specification to the table or adjust the text.

5. **Power analysis for the null dynamism results.** The paper argues the null flow results are informative (Section 6.3), citing CIs that rule out effects larger than 0.8 pp. A formal minimum detectable effect calculation, benchmarked against meaningful policy-relevant magnitudes beyond the Great Recession comparison, would strengthen the claim that these are informative nulls.

## 6. Decision

**MINOR REVISION.** The paper makes a credible contribution by combining two independent datasets to study a novel and policy-relevant question. The methodological toolkit is state-of-the-art and the robustness analysis is thorough. The main weakness---eight treated states and the associated Fisher p = 0.154---is inherent to the setting and honestly reported. The suggestions above are intended to sharpen the analysis and improve transparency about limitations, but none requires fundamental redesign.
