# Reply to Reviewers - Round 1

## Response to Reviewer 1

Thank you for the thorough review. We address the key concerns:

**1. First-stage evidence (missing)**
- *Concern*: No evidence the mandate increased childcare provision near the border
- *Response*: This is a valid limitation. Administrative data on childcare slots and spending by municipality is not readily available through the data sources we accessed (swissdd, BFS base maps). We acknowledge this as a fundamental limitation in Section 4.3.

**2. Turnout discontinuity (−4.6 pp, p=0.001)**
- *Concern*: Major red flag for identification
- *Response*: We agree this is concerning. We interpret it as a diagnostic that municipalities differ in political engagement, which could confound the main estimate. The direction (lower turnout on treated side) would bias against finding negative effects, but we cannot rule out selection effects.

**3. Spatial inference**
- *Concern*: Need Conley SEs or border-segment clustering
- *Response*: Valid concern. We use rdrobust's robust SEs but acknowledge this does not fully address spatial correlation. Future work should implement spatial HAC corrections.

**4. Language restriction too crude**
- *Concern*: Bern is bilingual; need municipality-level language data
- *Response*: We acknowledge this in Section 4.3 and note the primary border segments are in German-speaking eastern Bern.

**5. Missing RDD references**
- *Concern*: Missing Imbens & Lemieux (2008), Lee & Lemieux (2010)
- *Response*: We add these citations to the bibliography.

---

## Response to Reviewer 2

**1. No first stage / policy delivery validation**
- *Response*: We acknowledge this limitation. The paper estimates an intent-to-treat effect of being in a mandate canton, not the effect of actual childcare expansion.

**2. Pre-treatment balance not tested**
- *Response*: We attempted to merge 2004 maternity referendum data but the match was unsuccessful. This limitation is documented.

**3. Difference-in-discontinuities approach**
- *Response*: This would strengthen identification considerably. Future work should examine pre-2010 referenda on similar topics.

---

## Response to Reviewer 3

All concerns from Reviewer 3 mirror those from Reviewers 1 and 2. We acknowledge:

1. The design has fundamental limitations regarding pre-treatment balance
2. Turnout discontinuity is a major concern
3. First-stage evidence is missing
4. Spatial inference could be improved
5. Main result is imprecise (p = 0.24)

## Summary

The reviewers have identified fundamental design limitations that would require:
- Administrative childcare data (not readily available)
- Successful pre-treatment covariate merge (attempted but failed)
- Municipality-level language classification (not obtained)

These limitations are acknowledged in the paper. The paper provides suggestive evidence consistent with thermostatic policy feedback but cannot establish a credible causal claim at top-journal standards.
