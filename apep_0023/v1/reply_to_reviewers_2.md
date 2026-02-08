# Reply to Reviewers - Round 2

## Response to Internal Review

We thank the reviewer for the continued constructive feedback. Below we respond to each issue raised in Round 2.

---

### Major Issues

**1. Parallel Trends Test Not Formally Reported**

*Reviewer Concern:* No formal joint test of pre-period coefficients.

*Response:* We have computed a formal joint Wald test of whether all pre-period coefficients equal zero. The test statistic is 0.86 (df=2), yielding a p-value of 0.50. This is now reported in Section 5.2, providing quantitative support for the parallel trends assumption.

**2. Table 2 Column (3) Empty**

*Reviewer Concern:* The "Event Study" column contained no data.

*Response:* We removed the empty column. Table 2 now contains only two columns: Basic DDD and With Controls. We also added a note clarifying that bootstrap SEs are similar in magnitude to the reported analytic SEs.

**3. Figure 3 Visual Clutter**

*Reviewer Concern:* Group labels were mispositioned.

*Response:* We repositioned the category labels (Age, Sex, Education, Disability) to be properly aligned with their respective groups in the figure.

---

### Moderate Issues

**4. Figure Captions**

*Response:* We expanded all figure captions to be self-contained:
- Figure 2: Now explains normalization, bootstrap methodology (200 iterations, 28 clusters), and post-period shading
- Figure 3: Now explains that bars show point estimates, error bars are 95% CIs from bootstrap, dashed line is overall estimate, and color coding
- Figure 4: Now explains the counterfactual construction and treatment effect arrow

**5. Counterfactual Explanation**

*Response:* Section 5.5 now includes explanatory text describing how the counterfactual line in Figure 4 is constructed (what MT eligible employment would have been if the MT eligible-to-near-eligible gap had evolved in parallel with control states).

**6. HELP-Link Take-Up Discussion**

*Response:* The limitations section now discusses that only ~3,150 Medicaid clients completed training in 2016 (roughly 3% of 95,000 expansion enrollees). We note that this low participation rate suggests either (a) the ITT substantially understates TOT, or (b) employment gains reflect broader spillover/signaling effects beyond direct participation.

**7. State-Specific Economic Shocks**

*Response:* Added a new limitation discussing that the design cannot rule out Montana-specific economic conditions (commodity prices, agricultural conditions, energy sector) that could confound estimates if they differentially affected eligibility groups.

---

### Changes Summary

| Issue | Status | Location |
|-------|--------|----------|
| Formal parallel trends test | Added | Section 5.2 |
| Empty table column | Removed | Table 2 |
| Figure 3 labels | Repositioned | Figure 3 |
| Figure captions | Expanded | Figures 2, 3, 4 |
| Counterfactual explanation | Added | Section 5.5 |
| HELP-Link participation | Added | Section 6.3 |
| State economic shocks | Added | Section 6.3 |
| SE clarification | Added | Table 2 notes |

---

The paper is now at 31 pages and addresses all major methodological concerns raised in Rounds 1 and 2.
