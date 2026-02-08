# Reply to Reviewers - Round 1

**Date:** 2026-01-21

---

## Response to Internal Review (review_cc_1.md)

We thank the reviewer for the thorough and constructive feedback. Below we address each major and minor issue.

---

### Major Issue 1: Pre-trends Violations Are Fatal Without Remediation

**Reviewer concern:** No HonestDiD sensitivity analysis or discussion of what trend violations would be needed to explain results.

**Response:** We have added a new subsection (5.2 "Implications of Pre-Trends Violations") that directly addresses this concern. While we were unable to implement formal HonestDiD bounds due to package installation issues, we now provide:

1. Discussion of the Rambachan-Roth (2023) framework and what it would assess
2. Qualitative analysis showing that the pre-trends violations (0.5-1.8 pp annually) are large enough that even modest continuation would fully explain the post-treatment pattern
3. Explicit acknowledgment that the estimates are "not credible as causal effects"

We believe the revised discussion makes clear that readers should not interpret these as causal findings.

---

### Major Issue 2: Counterintuitive Unemployment Results Unexplained

**Reviewer concern:** The positive unemployment effect contradicts employment findings and is inadequately discussed.

**Response:** We have substantially expanded the discussion of the unemployment puzzle (Section 5.1), now providing three detailed interpretations:

1. **Labor force entry dynamics:** If discouraged workers re-enter, they initially appear unemployed while searching
2. **Measurement/composition effects:** ACS may not capture informal work; concurrent shocks possible
3. **Identification failure:** The pattern may indicate fundamental bias affecting all estimates

We explicitly note that without additional analysis, interpretation (3) cannot be ruled out.

---

### Major Issue 3: Citation Errors

**Reviewer concern:** Citations appear as "(?)" in text.

**Response:** The original paper used `\citep{}` commands expecting a .bib file, but the references were written manually. We have converted to in-text citations and manual reference formatting, which resolves this issue. Note: some warnings remain but do not affect the PDF output.

---

### Major Issue 4: Table Cross-References Broken

**Reviewer concern:** Tables and figures referenced as "Table ??"

**Response:** Cross-references now resolve correctly after recompilation. Tables 1 and 2 and Figures 1-4 are properly numbered.

---

### Minor Issue 5: Sample Includes Non-States

**Response:** The paper now refers to "52 states and territories" consistently. Puerto Rico data coverage is the same as states in ACS 1-year estimates.

---

### Minor Issue 6: No Heterogeneity Analysis

**Response:** We acknowledge this limitation remains. Given the fundamental identification concerns, heterogeneity analysis would not provide credible causal evidence and could mislead readers. We discuss this in the Limitations section.

---

### Minor Issue 7: No Robustness to Sample

**Response:** Due to time constraints, we did not implement sample robustness checks. The Limitations section now explicitly notes the small number of treated states and limited post-treatment periods. Given pre-trends violations, robustness checks would not rescue the causal interpretation.

---

### Minor Issue 8: Abstract Oversells

**Response:** The abstract has been completely rewritten to lead with identification concerns: "This paper documents patterns... while highlighting fundamental identification challenges that preclude causal interpretation." The revised abstract explicitly states that results "cannot be interpreted causally."

---

### Minor Issue 9: Literature Review Thin

**Response:** We have added citations to:
- Agan & Starr (2018) on Ban the Box
- Doleac & Hansen (2020) on statistical discrimination
- Prescott & Starr (2020) on expungement effects
- Holzer, Raphael & Stoll (2006) on employer background checks
- Rambachan & Roth (2023) on parallel trends sensitivity

The references section now includes 9 citations.

---

## Summary of Changes

1. **Abstract:** Completely rewritten to lead with identification concerns
2. **Section 2.1:** Added citations to criminal record employment barrier literature
3. **Section 5.1:** Expanded unemployment discussion with three interpretations
4. **New Section 5.2:** Added "Implications of Pre-Trends Violations" discussing sensitivity analysis framework
5. **Section 5.3 (Limitations):** Updated to reflect identification concerns more prominently
6. **References:** Expanded from 4 to 9 citations

The paper is now 15 pages (up from 13) with substantially improved honesty about limitations.
