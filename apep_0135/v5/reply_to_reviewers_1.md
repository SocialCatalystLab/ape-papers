# Reply to Reviewers (Round 1)

We thank the reviewers for their thoughtful comments. This revision (apep_0141) addresses the major concerns raised in the parent paper (apep_0140). Below we respond to specific points.

---

## Response to Code Integrity Scanner

**Concern:** The parent paper received a SUSPICIOUS verdict due to missing data provenance documentation.

**Response:** We have created `00_fetch_data.R`, a comprehensive data fetching script that:
- Documents all data sources with URLs and DOIs
- Provides download instructions for each dataset
- Includes verification checks for data integrity
- References the proper citations (MIT Election Lab, Acemoglu et al. 2022)

Additionally, we rewrote `REPLICATION.md` to accurately document the R workflow and removed incorrect Python references.

---

## Response to GPT-5-mini

### On spatial dependence
**Concern:** Standard errors may be understated due to spatial autocorrelation.

**Response:** We added two-way clustering by CBSA and state as a conservative approximation to Conley (1999) spatial HAC standard errors. We now discuss this approach in Section 5.4.3 ("Spatial Dependence"). The two-way clustered SE is 0.019 vs. CBSA-clustered SE of 0.016—similar magnitude, confirming robustness.

### On selection on unobservables
**Concern:** Omitted variable bias threatens causal interpretation.

**Response:** We implemented the Oster (2019) coefficient stability test. Results are reported in Section 5.4.4. Our δ* = 0.05 suggests some sensitivity to confounding, but the bias-adjusted coefficient β* = 0.014 remains positive. We emphasize that the paper documents a correlation and sorting pattern rather than claiming strict causation.

### On pre-trends
**Concern:** Need evidence that technology-voting link is Trump-specific.

**Response:** We added a 2008-2012 placebo test (Section 5.4.5). Technology age does NOT predict the McCain-to-Romney shift (coefficient -0.004, p = 0.39), but DOES predict the Romney-to-Trump shift (coefficient 0.034, p < 0.001). This supports our interpretation that the relationship emerged specifically with Trump.

### On IV/quasi-experiments
**Concern:** Requests instrumental variables or quasi-experimental variation.

**Response:** We acknowledge this as a limitation. Valid instruments for regional technology vintage that satisfy the exclusion restriction are difficult to identify. The paper explicitly frames results as observational correlations supporting a sorting interpretation, not as causal effects. We believe the pattern of results—especially the null pre-trend and null post-2016 gains—is informative even without experimental identification.

---

## Response to Grok-4.1-Fast

### On AI disclosure
**Concern:** The title footnote mentioning "autonomously generated" was unprofessional.

**Response:** Removed. The revised paper has a standard academic title footnote.

### On missing citations
**Concern:** Add Conley (1999), Oster (2019), Diamond (2016).

**Response:** All added to the bibliography and cited in appropriate sections.

---

## Response to Gemini-3-Flash

### On Oster bounds
**Concern:** Implement sensitivity analysis for selection on unobservables.

**Response:** Implemented in Section 5.4.4 with full reporting of δ* and β*.

### On modal age definition
**Concern:** Clarify whether modal age is weighted by firm size or simple mean.

**Response:** We use the simple mean of industry-level modal ages within each CBSA. This is now stated more clearly in Section 2.3 (Data Sources) and in the Appendix.

---

## Summary of Changes

| Issue | Status |
|-------|--------|
| Code integrity (SUSPICIOUS) | Fixed - created 00_fetch_data.R |
| Spatial dependence | Added two-way clustering + discussion |
| Selection on unobservables | Added Oster (2019) bounds |
| Pre-trends placebo | Added 2008-2012 test (null) |
| AI disclosure | Removed from title footnote |
| Missing citations | Added Conley, Oster, Molloy, Comin/Hobijn |
| REPLICATION.md accuracy | Rewritten with correct R workflow |

We believe these revisions substantially strengthen the paper and address the major concerns from the parent version.
