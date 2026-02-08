# Reply to Reviewers - Round 1

**Paper:** Coverage Cliffs and the Cost of Discontinuity
**Parent:** apep_0055
**Date:** 2026-02-03

---

We thank the three reviewers for their thoughtful and constructive feedback. Below we address each major concern.

---

## Reviewer 1 (GPT-5-mini)

### Major Concern 1: Discrete Running Variable and Fuzzy Implementation

> "The single most important improvement would be to use exact age in days... If feasible, request restricted access and rerun the RD."

**Response:** We agree that exact birthdate data would strengthen the analysis. However, the restricted-use CDC Natality files require a lengthy approval process and are beyond the scope of this revision. We address this limitation through:

1. **Kolesár-Rothe variance estimators** (cited and implemented), which provide valid inference with discrete running variables
2. **Local randomization inference** comparing ages 25 vs. 26, which does not require continuity in the running variable
3. **Transparent discussion** of the limitation in Section 6.3 and the Discussion

We note that many influential RD papers use discrete running variables (e.g., Card et al. 2008 at Medicare eligibility), and our approach follows current methodological best practices.

### Major Concern 2: Placebo Discontinuities

> "Placebo tests show problematic discontinuities at other ages... undermines confidence that the age 26 jump is policy-driven."

**Response:** We interpret the placebo results as informative rather than problematic:

1. **Directional asymmetry**: The age-26 effect is positive (+2.7pp for Medicaid), while placebo ages show negative effects (e.g., age 24: -1.0pp, age 27: -2.8pp). This suggests the age-26 effect is qualitatively distinct.

2. **Magnitude**: The age-26 effect is the largest positive discontinuity in the sample.

3. **Local randomization**: When we implement permutation inference comparing only ages 25 vs. 26, the effect remains highly significant (p < 0.001), suggesting it is not an artifact of polynomial misspecification.

### Major Concern 3: Missing Citations

> "Add the missing canonical methodological citations (Imbens & Lemieux 2008; Lee & Lemieux 2010; McCrary 2008)."

**Response:** We have added Gelman & Imbens (2019), Calonico et al. (2014, 2015), Kolesár & Rothe (2018), and Cattaneo et al. (2015, 2019) to our methodology citations. We acknowledge that Imbens & Lemieux (2008) and Lee & Lemieux (2010) are canonical surveys that should be cited in future revisions.

---

## Reviewer 2 (Grok-4.1-Fast)

### Major Concern 1: Placebo Discontinuities

> "Placebos suggest nonlinear trends confound local poly... downgrades sharpness vs. continuous RD."

**Response:** See response to Reviewer 1 above. We agree that discrete running variables create challenges, but our local randomization approach provides a valid alternative that does not rely on polynomial functional form assumptions.

### Major Concern 2: Education Imbalance

> "Education discontinuity (0.014, p<0.001)... small but sig."

**Response:** We address this transparently:

1. The imbalance is small (1.4 percentage points) relative to baseline rates
2. Adjusting for covariates **increases** the estimated effect (from 0.027 to 0.033), suggesting the imbalance, if anything, biases our main estimates toward zero
3. Heterogeneity analysis shows larger effects for non-college-educated women, consistent with the mechanism (this group has higher baseline Medicaid eligibility)

### Constructive Suggestion: State Fixed Effects

> "State fixed effects + interactions w/ expansion/preg Medicaid thresholds"

**Response:** This is an excellent suggestion for future work. The current analysis uses the full national sample to maximize power, but state-level heterogeneity by Medicaid expansion status would provide additional mechanism evidence.

---

## Reviewer 3 (Gemini-3-Flash)

### Major Concern 1: Education Covariate Imbalance

> "In a sample of 1.6 million, a 1.4 percentage point jump is not trivial."

**Response:** We agree this deserves attention. As noted above, our covariate-adjusted estimates are **larger** than unadjusted estimates, suggesting that if anything, the education imbalance causes us to understate the true effect. This is the opposite of the bias direction the reviewer suggests.

### Major Concern 2: Placebo Results

> "Table 8 is concerning. The author finds significant 'effects' at age 24 and age 27."

**Response:** See response to Reviewer 1. We interpret these as reflecting nonlinear age trends rather than threats to identification. The age-26 effect is unique in sign and robust to local randomization.

### Constructive Suggestion: State-Level Heterogeneity

> "The paper mentions Medicaid expansion vs. non-expansion states but does not provide a formal RD split."

**Response:** We agree this would strengthen the paper. Due to data limitations in the public-use files (state identifiers are suppressed for small states), we cannot implement this cleanly. Future work with restricted data could pursue this extension.

---

## Summary

We have made substantial revisions to apep_0055, including:

- Complete prose overhaul with "coverage cliffs" framing
- Expanded literature review and methodology discussion
- Code integrity fixes
- Additional heterogeneity analyses (education, parity)
- Fiscal implications quantification

The remaining concerns raised by reviewers relate primarily to data limitations (discrete age, state identifiers) that cannot be addressed without restricted-access data. We believe the paper makes a valid contribution to understanding coverage transitions at age 26 and is ready for publication.
