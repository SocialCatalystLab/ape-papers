# Reply to Reviewers: apep_0158 → apep_0159

We thank the reviewers for their thoughtful feedback. The core concern—that CPS cannot separate new hires from incumbents—has been fully addressed by switching to Census QWI administrative data, which directly measures new hire earnings.

---

## Reviewer 1 (GPT-5-mini)

> "The main limitation is the inability to distinguish between new hires and incumbents... Bring in job posting data or LEHD for new-hire earnings."

**Response:** We have replaced CPS entirely with Census QWI, which is derived from LEHD administrative records. The key variable `EarnHirAS` provides average monthly earnings of **stable new hires** at the county-quarter-sex level. This directly addresses the core concern.

> "Consider a border discontinuity design."

**Response:** Done. We now implement a border county-pair design following Dube, Lester & Reich (2010), identifying 129 treated-control county pairs sharing physical boundaries.

---

## Reviewer 2 (Grok-4.1-Fast)

> "Consider linked LEHD/employer data for incumbent/new-hire split."

**Response:** QWI is the public-use derivative of LEHD and provides exactly the new-hire wage data requested. We can now cleanly identify the population affected by job-posting requirements.

> "Add more robustness checks."

**Response:** Added: (1) border county-pair design, (2) placebo test (fake treatment 2 years early), (3) excluding CA/WA (concurrent policies).

---

## Reviewer 3 (Gemini-3-Flash)

> "Bring in firm-size data or new hire vs incumbent separation."

**Response:** QWI provides new hire earnings directly. Firm size heterogeneity is not available at the county-sex level, but the data now directly measures the relevant population.

> "The gender gap interpretation needs clarification."

**Response:** Fixed. We now correctly interpret the results: male ATT (2.0%) > female ATT (1.3%), implying the gender gap modestly **widens** rather than narrows, contrary to the information equalization hypothesis.

---

## Summary of Changes

| Concern | Response |
|---------|----------|
| Cannot separate new hires | Switched to QWI (new hire earnings) |
| Border design requested | Implemented (129 county pairs) |
| More robustness | Added placebos, CA/WA exclusion |
| Gender gap interpretation | Corrected (gap widens, not narrows) |
| NY in control group | Excluded (adopted Sept 2023) |
