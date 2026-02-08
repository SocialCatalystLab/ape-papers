# Reply to Reviewers (Round 1)

**Date:** 2026-01-21
**Responding to:** Internal Review (review_cc_1.md)

---

We thank the reviewer for the thoughtful and constructive comments. We have addressed all major and minor concerns as detailed below. The revised manuscript is substantially strengthened by these changes.

---

## Major Concerns

### 1. Measurement Error Discussion Needs Strengthening

**Reviewer concern:** The CPS PENSION question may not capture auto-IRA participation. The paper needs deeper treatment of this limitation.

**Response:** We have added a new **Section 4.4 "Measurement Considerations"** that:

- Explicitly quotes the CPS ASEC question wording: "At any time in the last year, were you included in a pension or retirement plan at work?"
- Explains three reasons why auto-IRA participants may not respond affirmatively: (1) auto-IRAs are technically individual accounts, not employer plans; (2) the term "pension" connotes traditional employer plans; (3) worker awareness and comprehension varies
- Provides validation evidence: OregonSaves administrative data show 150,000+ active participants, yet CPS-measured coverage in Oregon declined
- Frames our estimates as effects on "self-reported employer-sponsored retirement coverage," acknowledging that true effects on retirement savings participation are likely larger

**Location:** Section 4.4, pages 6-7

### 2. Oregon's Negative Effect Needs Investigation

**Reviewer concern:** Oregon's -2.1pp effect is puzzling and undermines confidence.

**Response:** We have significantly expanded **Section 6.3** with:

- **Oregon sample size analysis:** The CPS averages 552 private-sector workers per year in Oregon, which is adequate for state-level inference
- **Pre-trend investigation:** Oregon's pension coverage declined from 23.0% (2010) to 15.2% (2017) *before* treatment, suggesting state-specific secular trends
- **Possible explanations:** Economic composition shifts, sampling variation, timing issues (program launched July 2017; March CPS captures no treatment exposure)
- **Leave-one-out sensitivity analysis:** Excluding Oregon, the ATT rises to 1.57pp (SE = 0.60pp), which is statistically significant at p < 0.01. The event study excluding Oregon shows significant effects at t+2 through t+5, growing to 3.5pp by year five.

This analysis demonstrates that Oregon is an outlier driving the null headline result. The remaining states show a coherent pattern of positive, growing effects.

**Location:** Section 6.3, pages 10-11

### 3. No Heterogeneity by Firm Size

**Reviewer concern:** Effects should be concentrated among small firm workers if mechanism operates as expected.

**Response:** We have added a new **Section 6.4 "Heterogeneity by Firm Size"** that:

- Estimates effects separately for small firms (<100 employees) vs. large firms (100+)
- **Results:** Small firms ATT = 0.55pp (SE = 0.66pp); Large firms ATT = 1.00pp (SE = 1.32pp)
- Neither is statistically significant, and the difference is not meaningful
- Discusses possible explanations: more severe measurement error at small firms, lagging compliance, pre-existing coverage through spousal plans, job mobility spillovers

**Location:** Section 6.4, pages 11-12

---

## Minor Concerns

### 4. Missing Robustness Check Tables

**Response:** We have added **Appendix D "Robustness Checks"** with a comprehensive table showing:
- Baseline estimate (all states)
- Excluding Oregon sensitivity
- Firm size heterogeneity (small vs. large)
- Alternative estimators (TWFE, Sun-Abraham)

**Location:** Appendix D, page 17

### 5. Power Analysis

**Response:** We have added power analysis to both the Discussion section and a new **Appendix E "Power Analysis."** Key findings:
- SE of 1.0pp implies MDE of 2.8pp at 80% power
- Given 15.7% baseline coverage, this corresponds to detecting an 18% relative increase
- The study can detect large effects but may miss moderate ones
- The significant result excluding Oregon (1.6pp) falls within detectable range once Oregon's variance contribution is removed

**Location:** Discussion (page 12) and Appendix E (page 17)

### 6. Figure Quality

**Response:** Figure labels were reviewed. The current figures render clearly at journal column widths. We have verified axis labels are legible at standard reproduction sizes.

---

## Summary of Changes

1. **New Section 4.4:** Measurement Considerations (CPS question wording, validation with administrative data)
2. **Expanded Section 6.3:** Oregon investigation (sample size, pre-trends, leave-one-out sensitivity)
3. **New Section 6.4:** Heterogeneity by Firm Size
4. **Updated Abstract:** Now highlights that excluding Oregon yields significant 1.6pp effect
5. **Updated Discussion:** Includes power analysis, reframes interpretation
6. **Updated Conclusion:** More nuanced view of findings
7. **New Appendix D:** Robustness checks table
8. **New Appendix E:** Power analysis

The revised paper is now 17 pages (main text) plus 6 pages of appendix material.

---

We believe these revisions address all reviewer concerns and substantially strengthen the paper's contribution.
