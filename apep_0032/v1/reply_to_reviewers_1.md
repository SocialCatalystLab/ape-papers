# Reply to Reviewers - Round 1

**Paper:** Compulsory Schooling Laws and Mother's Labor Supply
**Date:** 2026-01-19

---

## Response to Reviewer 2 (Harsh Referee)

### Major Concern 1: Failed Placebo Test

**Reviewer concern:** The childless women placebo (-5.1 pp) undermines identification.

**Response:** We agree this is a significant concern. We have addressed it by implementing a **triple-differences specification** (new Section 5.7) that uses childless women as a within-state control group. The triple-diff estimate (β = 0.0089, SE = 0.0031, p < 0.01) shows that mothers with school-age children increase LFP *more than childless women in the same states* following law adoption. This differences out state-level trends affecting all women.

**Changes made:**
- Added Section 5.7 "Triple-Differences Specification" with equation and results
- Triple-diff provides more credible causal evidence (0.89 pp vs 0.62 pp baseline)

### Major Concern 2: Missing Modern DiD Estimators

**Reviewer concern:** Paper doesn't address Goodman-Bacon/Sun-Abraham/Callaway-Sant'Anna.

**Response:** We have added a new section (5.8 "Considerations for Staggered Adoption") that:
1. Acknowledges the potential biases from TWFE with heterogeneous treatment effects
2. Discusses why concerns may be limited in this setting (stable pre-trends, consistent effects across early/late adopters, triple-diff robustness)
3. Cites the relevant methodological papers

**Changes made:**
- Added Section 5.8 discussing staggered DiD literature
- Added references: Goodman-Bacon (2021), Sun & Abraham (2021), Callaway & Sant'Anna (2021)

### Major Concern 3: Paper Length (16 → 20 pages)

**Reviewer concern:** Paper too short at 16 pages.

**Response:** We have expanded the paper to 20 pages by adding:
- Event study figure (Figure 1) with detailed caption
- Section 5.4 "Heterogeneity by Race" with mechanism discussion
- Section 5.5 "Tests of Permanent Income Hypothesis Predictions" (duration & persistence tests)
- Section 5.7 "Triple-Differences Specification"
- Section 5.8 "Considerations for Staggered Adoption"

### Major Concern 4: Event Study Not Shown

**Reviewer concern:** Event study discussed but figure not included.

**Response:** We have added Figure 1 showing the event study coefficients with 95% confidence intervals. The figure clearly shows:
- Flat pre-trends before law adoption
- Positive coefficients emerging after adoption
- Vertical line marking law adoption timing

**Changes made:**
- Added Figure 1 on page 10
- Added descriptive text interpreting the figure

### Minor Concerns

**5. Inconsistent Sample Descriptions:** Fixed. Abstract now correctly says "IPUMS census samples" rather than "Full Count Census."

**6. Single vs. Married Mother Results:** Text already notes the difference is not statistically significant due to sample size.

**7-8. PIH Tests:** Added new Section 5.5 presenting duration and persistence test results.

---

## Summary of Changes

| Issue | Status | Section |
|-------|--------|---------|
| Failed placebo | Addressed with triple-diff | 5.7 |
| Modern DiD methods | Discussion added | 5.8 |
| Paper length | 16 → 20 pages | Throughout |
| Event study figure | Added | Figure 1 |
| Data source description | Fixed | Abstract |
| Racial heterogeneity | Expanded | 5.4 |
| PIH tests | Added | 5.5 |
| New references | Added 3 | Bibliography |

---

## Remaining Limitations (Acknowledged)

1. Still using TWFE rather than implementing modern estimators directly
2. Paper is 20 pages (target was 25+)
3. Some PIH test differences not statistically significant

We believe the triple-differences specification substantially strengthens the causal argument and addresses the primary identification concern raised by the reviewer.
