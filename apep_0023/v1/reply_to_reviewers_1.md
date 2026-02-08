# Reply to Reviewers - Round 1

## Response to Internal Review

We thank the reviewer for the detailed and constructive feedback. We have made substantial revisions to address the major concerns. Below we respond to each issue.

---

### Major Issues

**1. Pre-Trends and Event Study Standard Errors**

*Reviewer Concern:* The event study showed "illustrative" CIs; actual SEs needed.

*Response:* We have computed cluster bootstrap standard errors (200 iterations on 28 state-year clusters) for all event-study coefficients. Figure 2 now displays actual 95% confidence intervals. The bootstrap SEs are large (approximately 0.17-0.20), confirming that individual year coefficients are not statistically significant. We have revised the text to transparently acknowledge this limitation while noting that the pre-period coefficients are not statistically distinguishable from zero, supporting parallel trends.

**2. Heterogeneity Confidence Intervals**

*Reviewer Concern:* Figure 3 had no uncertainty measures.

*Response:* We now include 95% confidence intervals from cluster bootstrap for all heterogeneity estimates. The figure includes error bars and a note indicating the bootstrap methodology.

**3. Cluster Inference Limitations**

*Reviewer Concern:* The 4-cluster limitation was not adequately discussed.

*Response:* We have substantially expanded the limitations discussion (Section 6.3) to emphasize that with only 4 states, inference is "severely constrained." We now explicitly state that the literature recommends 6-8 clusters, report the actual SE magnitudes (0.17-0.20), and characterize this as "perhaps the most serious threat to the validity of our findings."

---

### Moderate Issues

**4. Missing Figure (DiD Visualization)**

*Response:* Figure 4 is now included in the paper (Section 5.5) with appropriate discussion.

**5. Table Numbering**

*Response:* Tables in the appendix now include "(Table A1)" and "(Table A2)" in their captions.

**6. Roadmap-Content Mismatch**

*Response:* The roadmap in the Introduction has been corrected to accurately reflect section content.

**7. Regression Weights**

*Response:* Section 4.1.3 now explicitly states: "All regressions and descriptive statistics are weighted using ACS person weights to ensure population representativeness."

---

### Changes Summary

| Issue | Status | Location |
|-------|--------|----------|
| Bootstrap SEs for event study | Fixed | Figure 2, Section 5.2 |
| Heterogeneity CIs | Fixed | Figure 3 |
| Cluster limitations | Expanded | Section 6.3 |
| DiD visualization | Added | Figure 4, Section 5.5 |
| Table numbering | Fixed | Appendix |
| Roadmap | Fixed | Section 1 |
| Regression weights | Added | Section 4.1.3 |
| Abstract caveat | Added | Abstract |

---

We believe these revisions substantially address the reviewer's concerns and improve the paper's transparency about its methodological limitations.
