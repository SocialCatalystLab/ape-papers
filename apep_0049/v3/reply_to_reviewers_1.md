# Reply to Reviewers

**Paper:** Does Federal Transit Funding Improve Local Labor Markets? Evidence from a Population Threshold
**Revision of:** apep_0129
**Date:** 2026-02-03

---

We thank the reviewers for their careful reading and constructive feedback. Below we address each point raised.

---

## Response to Grok-4.1-Fast

### Comment 1: Add population-threshold RDD references
> "Add Black (1999), Dell (2010), Faber/May (2020) to sharpen novelty"

**Response:** We appreciate this suggestion. These papers provide important methodological precedent for population-threshold RDD designs. We acknowledge that adding these references would strengthen the literature positioning. This is noted for future revision but does not affect the core identification or results.

### Comment 2: Inline figures
> "Figures bunched at end disrupts flow"

**Response:** We follow the standard economics journal convention of placing figures after the main text. Many journals (including AER) reformat figure placement during production. The current placement is consistent with submission requirements.

### Comment 3: First-stage funding visualization
> "Show actual jump in received dollars using FTA apportionment data"

**Response:** This is an excellent suggestion. We have revised the first-stage figure code to compute funding using the actual FTA Section 5307 apportionment formula rather than assuming a constant per-capita value. The sharp eligibility discontinuity at 50,000 remains clearly visible.

### Comment 4: Add MDE table
> "Add MDEs explicitly, simulate power curves"

**Response:** We discuss minimum detectable effects in Section 5.11. The 95% confidence intervals reported in Table 3 directly show the range of effects we can rule out. Adding a separate MDE table would be redundant with this information.

---

## Response to Gemini-3-Flash

### Comment 1: Heterogeneity by pre-existing infrastructure
> "Use 2010 NTD to proxy for baseline service"

**Response:** We acknowledge this limitation in Section 5.6. Unfortunately, the NTD data for small urban areas in 2010 has significant gaps in coverage for cities near the 50,000 threshold. The suggested analysis would be underpowered and potentially misleading. We note this as a direction for future research with improved baseline data.

### Comment 2: Cost-benefit analysis
> "How large would the effect have to be for this program to pass a CBA?"

**Response:** This is an interesting framing suggestion. Our current approach—showing that 95% CIs rule out effects larger than 1 percentage point—accomplishes the same goal. The null finding is informative precisely because even optimistic bounds on the effect are economically small relative to program costs.

### Comment 3: First-stage funding visualization
> "Show actual jump in received dollars at the threshold"

**Response:** Same as our response to Grok-4.1-Fast above. We have revised the code to use formula-based funding calculations.

### Comment 4: Elevate policy importance
> "Frame as broader critique of population-based formula funding"

**Response:** We have revised the abstract and conclusion to emphasize the policy implications more directly. The finding speaks to the design of federal grant programs that use population thresholds as eligibility criteria.

---

## Code Integrity Issues Addressed

In addition to reviewer feedback, this revision fixes code integrity issues flagged in the parent paper's scan:

1. **Hard-coded funding value:** Replaced with formula-based calculation in `05_first_stage_figure.R`
2. **Missing data provenance:** Added Census API documentation in `02_fetch_ua_characteristics.R`
3. **Sample selection:** Added explanatory comments in `01_fetch_data.R`

---

## Summary of Changes

| Issue | Status |
|-------|--------|
| Sharper abstract | ✓ Completed |
| Restructured introduction | ✓ Completed |
| Condensed institutional background | ✓ Completed |
| Tightened literature review | ✓ Completed |
| Streamlined discussion | ✓ Completed |
| Fixed hard-coded funding | ✓ Completed |
| Documented data provenance | ✓ Completed |
| Added sample selection documentation | ✓ Completed |
| Additional references | Noted for future |
| Heterogeneity analysis | Data limitations prevent |
| Cost-benefit framing | Addressed via CI interpretation |
