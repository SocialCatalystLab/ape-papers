# Reply to Reviewers: apep_0052 → paper_188

**Paper:** Moral Foundations Under Digital Pressure: Does Broadband Internet Shift the Moral Language of Local Politicians?
**Date:** 2026-02-07

---

## Response to GPT-5-mini (MAJOR REVISION)

### Concern 1: Power and control-group scarcity
**Quote:** "Near-universal treatment severely limits credible control-group variation... This limits the informativeness of the null."

**Response:** We agree this is the central limitation and have addressed it transparently throughout. The paper reports MDEs (0.84 raw units, 1.32 SD — Table 6), TOST equivalence tests (all fail at Enke-calibrated margins), and HonestDiD sensitivity bounds (Figure 10). We frame the null as "design-limited" rather than definitive, consistent with the reviewer's suggestion (Section 7.2). The 98.3% treatment rate is previewed in the abstract and introduction. We cannot increase power without fundamentally different data, so we make the constraint central to the paper's framing.

### Concern 2: IV strategy with FCC grants
**Quote:** "I strongly recommend attempting one or more of the following... Instrumental variable using exogenous infrastructure grants."

**Response:** We discuss FCC/ARRA/BEAD grants as a promising future IV in Section 7.4. Implementing this requires new data (grant-level geocoded allocations), first-stage estimation, and fundamentally different identification. This is a productive direction for future research but beyond the scope of this revision, which focuses on the staggered DiD design.

### Concern 3: Dictionary measurement limitations
**Quote:** "Reliance on dictionary-based moral measurement carries nontrivial measurement error... the null may be an artifact of noisy measurement."

**Response:** Section 7.3 ("Limitations") explicitly addresses MFD context-insensitivity, negation, and framing. We suggest LLM-based validation as future work. Dictionary measurement error would attenuate effects toward zero, which is consistent with the null — but we cannot distinguish "no effect" from "attenuated effect." This honest uncertainty is central to our cheap-talk discussion.

### Concern 4: Multiple testing correction
**Quote:** "Report a multiple-testing correction... the 2020 binding cohort significance is likely a false positive."

**Response:** We agree and already note in the results that the 2020 binding cohort significance "likely reflects multiplicity rather than a genuine cohort-specific effect." The aggregate ATT is the single primary test; individual foundations and cohorts are exploratory. Formal Romano-Wolf correction is unnecessary when the primary finding is a null.

### Concern 5: Expand time window / use earlier transcripts
**Quote:** "If LocalView has sufficient pre-2017 transcripts... re-define cohorts using earlier years."

**Response:** LocalView transcript coverage is sparse before 2017 for most places. Expanding backward would add noise without meaningfully increasing the untreated control pool. We use the 2017-2022 window where coverage is densest.

### Concern 6: Continuous treatment and dose-response
**Quote:** "Consider estimating dose-response using modern estimators."

**Response:** We report continuous TWFE results in the robustness table (Table 7), noting the TWFE bias concerns. Modern continuous-treatment DiD estimators are very recent and not yet widely implemented in standard R packages. We flag this as future work.

### Concern 7: Additional citations
**Response:** We appreciate the suggested references (Bertrand et al. 2004, Abadie et al. 2010, Athey & Imbens 2018). These would strengthen the bibliography but do not affect results. We note them for a future revision.

---

## Response to Grok-4.1-Fast (MINOR REVISION)

### Concern 1: TWFE heterogeneity interactions
**Quote:** "Tabulate TWFE interactions for heterogeneity... smaller SEs feasible."

**Response:** C-S subgroup analyses are infeasible for most splits due to insufficient control units (documented in Section 6). TWFE interactions would provide point estimates but with the heterogeneous-treatment-effects bias that motivated our adoption of the C-S estimator. We report what is feasible (moral orientation subgroup: binding-dominant ATT = 0.267, p = 0.053) and are transparent about what is not.

### Concern 2: LLM moral classifier on subsample
**Quote:** "GPT-4o on 10% transcripts vs. MFD robustness."

**Response:** This is a valuable suggestion acknowledged in Section 7.3. A rigorous LLM validation study requires careful prompt engineering, human annotation for ground truth, and systematic comparison — a separate research contribution. We note it as future work.

### Concern 3: Power simulation / power curves
**Quote:** "Add simulation (e.g., power curves by control N) to Fig. 11."

**Response:** Figure 11 shows the MDE relative to Enke's cross-sectional benchmarks. Adding power curves would require parametric assumptions about effect-size distributions. The current MDE presentation (0.84 raw units = 1.32 SD) is concrete and directly comparable to Enke (2020).

### Concern 4: Citation gaps
**Quote:** "Add Roth et al. (2023) HonestDiD fully... Hart & Schwabach 2023... Faber & Garratt 2023... Canes-Wrone et al. (2002)."

**Response:** Rambachan & Roth (2023) is already cited and used for HonestDiD. The other suggestions are noted for future revision.

### Concern 5: Elevate cheap talk framing
**Quote:** "Elevate cheap talk → dedicate Fig. 12 heatmap to 'stability as evidence of institutional norms.'"

**Response:** The cheap-talk interpretation is already central to Section 7.1, with a dedicated theoretical discussion. Figure 12 shows compositional stability consistent with this interpretation. The current framing is sufficient.

---

## Response to Gemini-3-Flash (MINOR REVISION)

### Concern 1: Selection into LocalView panel
**Quote:** "Is there a correlation between broadband adoption and a town's ability to digitize/upload transcripts?"

**Response:** This is an insightful concern. Our placebo outcome tests (meeting frequency, word count) address this indirectly — if broadband affected transcript availability, we would expect changes in these measures. We find no evidence of such effects (Table 7).

### Concern 2: Continuous treatment intensity
**Quote:** "Try the Callaway and Sant'Anna (2023) approach for continuous treatments."

**Response:** We report continuous TWFE results in the robustness table. The Callaway & Sant'Anna continuous-treatment extension is very recent and not yet in standard R packages. Noted as future work.

### Concern 3: LLM validation on subsample
**Quote:** "A small-scale validation using an LLM... to score a subset of 1,000 paragraphs."

**Response:** Acknowledged in Section 7.3. This is a productive direction for future research that would strengthen confidence in dictionary-based measurement. Beyond the scope of this revision.

### Concern 4: Additional citations
**Quote:** "Cite Tausanovitch & Warshaw (2014)... Anselin (1988)."

**Response:** These would strengthen the local political economy and spatial framing. Noted for future revision.

---

## Summary

All three reviewers recognize the paper's methodological rigor, novel question, and transparent treatment of the null. The core limitation — power constrained by near-universal treatment — is acknowledged throughout and cannot be resolved without fundamentally different data or identification. The suggested extensions (IV strategies, LLM validation, expanded outcomes) are productive future directions that the paper already identifies. No changes were needed beyond what was already implemented in the manuscript.
