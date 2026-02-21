# Reply to Reviewers — Round 1

## Responses to Referee 1 (GPT-5.2)

### Pre-trend failures undermine identification
**Response:** We agree this is the most important limitation. We have restructured the paper to lead with the cultivator share result—where pre-trends pass (p=0.398)—as the primary finding, and downgraded the non-farm result to "suggestive" given failing pre-trends. The abstract and introduction now explicitly note this distinction.

### Randomization inference design mismatch
**Response:** Added an explicit caveat in Section 7.3 noting that RI permutes treatment labels uniformly rather than conditional on the Backwardness Index assignment mechanism. The RI p-value is now framed as a diagnostic measure rather than an exact test.

### Estimand ambiguity
**Response:** Added explicit language in Section 5.1: "The coefficient β captures the effect of approximately two additional years of MGNREGA exposure, not the effect of MGNREGA itself. Since all districts were treated by 2011, no pure treatment-versus-control comparison is possible."

### Within-agriculture story incomplete
**Response:** The paper already documents all four Census worker categories (cultivators, ag laborers, household industry, other workers) in Table 2. The cultivator decline and ag laborer increase are complementary; household industry and other workers (which compose non-farm share) show no significant change.

### Missing references
**Response:** de Chaisemartin & D'Haultfœuille (2020) was already cited. The paper focuses on MGNREGA's structural transformation effects rather than the broader India rural non-farm literature.

---

## Responses to Referee 2 (Grok-4.1-Fast)

### Pre-trend failures
**Response:** Same as above. Paper restructured to lead with cultivator proletarianization, the outcome with clean identification.

### Estimand as intensity effect
**Response:** Now explicit throughout. The Phase I vs III comparison captures differential exposure intensity (5 vs 3 years), not binary treatment.

### Nightlights estimator disagreement
**Response:** Section 6.5 now honestly discusses the TWFE/CS-DiD vs Sun-Abraham discrepancy. The text notes that positive TWFE/CS estimates may reflect heterogeneous treatment timing weights and interprets the nightlights evidence as inconclusive.

### Repetitive pre-trends discussion
**Response:** Tightened throughout.

---

## Responses to Referee 3 (Gemini-3-Flash)

### Reframe structural transformation claim
**Response:** Done. The paper now leads with proletarianization as primary finding. Non-farm result downgraded to null/ambiguous.

### Baseline covariate imbalance
**Response:** Addressed in Section 4.4 and the existing discussion of identification challenges. The large baseline differences between Phase I and Phase III are openly acknowledged.

### No never-treated group for 2008 cohort
**Response:** Added explicit clarification in Section 5.2 that the 2008 cohort serves as control for earlier cohorts but has no untreated comparison for its own post-treatment periods.

### Implementation quality heterogeneity
**Response:** We acknowledge this as an important dimension but it requires external administrative data on MGNREGA implementation that is not available in SHRUG. This is noted as a limitation.

---

## Responses to Exhibit Review

- **Figure 1 (rollout bar chart):** Removed from paper.
- **Figure 5 (RI histogram):** Moved to appendix.
- **Table 4:** Added observations, FE indicators, and unit of observation rows.

---

## Responses to Prose Review

- **Opening hook:** Rewritten in Shleifer style with concrete historical observation.
- **Roadmap paragraph:** Deleted.
- **Results narration:** Section 6.1 now leads with finding ("MGNREGA's most striking effect was within agriculture") rather than table reference.
- **Abstract:** Restructured to lead with proletarianization finding.
