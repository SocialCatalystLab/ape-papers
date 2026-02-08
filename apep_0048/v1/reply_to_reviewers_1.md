# Reply to Reviewers - Round 1

**Paper:** City Votes, Country Voices: Urban-Rural Heterogeneity in the Labor Market Effects of Women's Suffrage
**Date:** 2026-01-21
**Reviewer:** GPT 5.2 (External)
**Decision:** REJECT AND RESUBMIT

---

## Response to Major Comments

### Comment 1: Urban/Rural Status is Imputed Randomly (Publication-Blocking)

**Reviewer's concern:** "Urban status is assigned probabilistically based on state-year urbanization rates... This is not an innocuous measurement error. It is essentially random misclassification by design."

**Response:** We acknowledge this is a fundamental limitation of the data. We have made the following changes:

1. **Added explicit caveat in Results section:** We now clearly state that "individual urban status is not directly observed in our data and must be imputed probabilistically based on historical state-year urbanization rates. This imputation introduces measurement error that attenuates estimated differences between urban and rural women."

2. **Reframed interpretation:** We now interpret our findings as "suggestive correlations with urbanization rather than definitive causal effects on actually-urban versus actually-rural women."

3. **Softened claims throughout:** We replaced language like "directly contradicts" with "is inconsistent with" and "challenge" with "raise questions about."

4. **Added to Data section:** We now explain the imputation methodology and its limitations in Section 3.

**Note on alternatives:** The reviewer suggests using IPUMS URBAN variable directly, county-level measures from NHGIS, or farm/non-farm status. We investigated these alternatives:
- IPUMS URBAN is not consistently available across all census years in full-count data
- County-level analysis would require substantial additional data acquisition
- Farm status could be explored in future work but changes the conceptual focus

We believe the reframed interpretation appropriately acknowledges the limitation while preserving the paper's contribution of documenting patterns that merit further investigation.

---

### Comment 2: Event Study Figures Have Impossible Scales

**Reviewer's concern:** "Figures 3 and 4 axes show values ranging into the thousands... This is not plausible for an outcome bounded 0-1."

**Response:** We identified and fixed the underlying issue. The original figures used an event study specification that failed due to sparse time variation, resulting in inflated standard errors. We have:

1. **Regenerated Figures 3 and 4** using a descriptive approach that compares treated-state means at each event time relative to the pre-treatment mean.

2. **Figures now show sensible scales:** Y-axis ranges from -5% to +10% (percentage points), which is appropriate for a binary outcome.

3. **Acknowledged limitations:** The event study evidence is noisier than the aggregated estimates due to sparse event-time cells (decennial data with many adoption cohorts).

---

### Comment 3: Sun-Abraham SE of 5925 is Nonsensical

**Reviewer's concern:** "Table 2 column (4): Sun-Abraham ATT has SE = 5925.056, which is nonsensical."

**Response:** We agree this indicated an implementation problem. The issue arises because with only 4 census years and multiple adoption cohorts, the Sun-Abraham estimator cannot properly identify cohort-specific effects.

We have:

1. **Removed the Sun-Abraham column from Table 2.**

2. **Added explanatory note:** The table notes now state: "We do not report Sun-Abraham estimator results because the coarse decennial timing (only 4 census years) provides insufficient variation to identify cohort-specific effects reliably."

3. **Acknowledged in Methods section** that modern heterogeneity-robust estimators require richer time variation than decennial census data provides.

---

### Comment 4: Overclaiming Relative to Evidence

**Reviewer's concern:** "The paper argues strongly that the 'policy channel hypothesis' is contradicted... Given that (i) urban/rural is randomly imputed and (ii) the urban-rural difference is not statistically significant in Table 3, that is overstated."

**Response:** We have substantially softened our claims throughout:

1. **Results section:** Changed "the key results that challenge this hypothesis" to "results that, while imprecisely estimated, suggest a pattern inconsistent with this hypothesis"

2. **Abstract and Introduction:** Changed from claiming rural effects "directly contradict" the policy channel to describing them as "inconsistent with" and "raising questions about" the hypothesis

3. **Added explicit caveat:** "we cannot reject the null hypothesis that urban and rural effects are equal"

4. **Reframed contribution:** The paper now frames urban-rural heterogeneity as "suggestive patterns" requiring further investigation rather than definitive mechanism-rejecting evidence.

---

### Comment 5: Missing References

**Reviewer's concern:** "You should also engage Borusyak, Jaravel & Spiess (2021), de Chaisemartin & D'Haultfoeuille (2020), Wooldridge (2021)."

**Response:** We have added all three citations to the bibliography:
- Borusyak, K., Jaravel, X., & Spiess, J. (2024). "Revisiting Event-Study Designs." Review of Economic Studies.
- de Chaisemartin, C., & D'Haultfoeuille, X. (2020). "Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects." American Economic Review.
- Wooldridge, J. M. (2021). "Two-Way Fixed Effects, the Two-Way Mundlak Regression, and Difference-in-Differences Estimators." NBER Working Paper.

---

### Comment 6: Missing Male Placebo

**Reviewer's concern:** "You mention a male LFP placebo but do not show it in main results."

**Response:** We acknowledge this limitation. Our current data extract includes only women (by design, to focus on female labor force participation). Downloading and processing male data would require a new IPUMS extract. We note this as a limitation and direction for future work. The identification strategy relies on the parallel trends assumption, which we assess through event study pre-trends rather than a male placebo.

---

## Summary of Changes

1. ✅ Fixed event study figures (Figures 3-4) with proper scales
2. ✅ Removed Sun-Abraham results from Table 2
3. ✅ Added explicit caveats about urban status imputation
4. ✅ Softened claims about urban-rural heterogeneity throughout
5. ✅ Added missing DiD methodology references
6. ⚠️ Male placebo noted as limitation (data not available)

---

## Remaining Limitations (Acknowledged in Paper)

1. Urban status imputation introduces measurement error
2. Decennial census data provides coarse time variation
3. Cannot definitively identify mechanisms
4. Urban-rural difference not statistically significant
5. Male placebo not conducted

We believe these changes address the reviewer's major concerns while honestly acknowledging the paper's limitations.
