# Reply to Reviewers - Round 4

## Response to Internal Review

We thank the reviewer for the continued attention to detail. Below we respond to each issue raised in Round 4.

---

### Moderate Issues

**1. Figure Legend Inconsistency**

*Reviewer Concern:* Figure legends used "<138% FPL" while text was standardized to "≤138% FPL".

*Response:* Updated the figure generation code (`create_figures.py`) to use "≤138% FPL" notation in all figure legends. Regenerated Figures 1 and 4 to reflect this change. The figures now match the standardized text notation.

**2. Event Study Caption - Cluster Count Clarification**

*Reviewer Concern:* The caption incorrectly stated "28 state-year clusters" when clustering is actually at the state level (4 clusters).

*Response:* Corrected both the figure annotation (in the Python script) and the LaTeX caption to read "wild cluster bootstrap (200 iterations, 4 state clusters)". The previous wording was misleading as it conflated state-year observations with the actual number of clusters used for inference.

**3. Heterogeneity Figure Label Rendering**

*Reviewer Concern:* Age range labels (e.g., "Age 25-54") were rendering with character corruption in the PDF.

*Response:* Updated the figure generation code to use Unicode en-dashes (\\u2013) instead of ASCII hyphens for age ranges. The labels now render correctly as "Age 19–24", "Age 25–54", and "Age 55–64".

---

### Minor Issues

**4. Table A2 Notes Clarification**

*Response:* Expanded the table notes to clarify: "Hours worked is conditional on employment (average weekly hours among employed). Control means are for control states in the pre-period."

**5. SUTVA/No Interference Assumption**

*Response:* Added a new paragraph to the limitations section (Section 6.3) titled "No Interference Assumption" that explicitly acknowledges this standard causal inference assumption and discusses why it is likely satisfied given the geographic separation between states.

**6. Baicker Reference**

*Response:* Expanded the Baicker et al. (2013) reference to list all authors instead of using "et al." in the reference list, consistent with standard citation practice.

---

### Changes Summary

| Issue | Status | Location |
|-------|--------|----------|
| Figure legend notation | Fixed | Figures 1, 4 (regenerated) |
| Event study cluster count | Corrected | Figure 2 caption |
| Heterogeneity figure labels | Fixed | Figure 3 (regenerated) |
| Table A2 notes | Clarified | Appendix A.2 |
| No interference assumption | Added | Section 6.3 |
| Baicker reference | Expanded | References |

---

The paper is now at 32 pages. All substantive methodological issues have been addressed through Rounds 1-4. The remaining improvements are primarily cosmetic and consistency-focused. The paper is approaching final quality.
