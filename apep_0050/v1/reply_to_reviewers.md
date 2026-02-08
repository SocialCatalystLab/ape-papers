# Reply to Reviewers

**Paper:** Salary Transparency Laws and Wage Outcomes: Evidence from Staggered State Adoption
**Date:** 2026-01-22

---

## Response to Reviewer 1 (GPT 5.2)

We thank Reviewer 1 for their thorough and constructive review.

### Pre-Trend Concerns
> The event study shows a statistically significant pre-trend (Table 6 reports event time −3 = +0.027, SE 0.007)

**Response:** We acknowledge this is a serious concern. We have added sensitivity analysis (Figure 13, Table 11) showing that the confidence interval includes zero when allowing for trend deviations similar to those observed. We have reframed our conclusions to emphasize the suggestive nature of the findings.

### Outcome-Treatment Mismatch
> The policy targets job postings/new hires, but the outcome is wages of all workers

**Response:** This is a valid point. The CPS MORG does not allow clean identification of new hires. Future work with administrative data (LEHD/QWI) or matched employer-employee data would be valuable.

### Missing Citations
> Missing Rambachan-Roth, Borusyak et al.

**Response:** We acknowledge these important methodological advances and would add these citations in a revision.

---

## Response to Reviewer 2 (GPT 5.2)

We thank Reviewer 2 for their detailed feedback.

### Parallel Trends Violation
> Parallel trends fails for the main wage outcome... the paper's main wage result should not be treated as causal

**Response:** We agree. Our sensitivity analysis shows the breakdown point is M_bar = 0.01, below the observed pre-trend magnitude of 0.027. We acknowledge the results are best interpreted as associations requiring further investigation.

### Pandemic Confounding
> Wage dynamics in these years differ sharply by state/industry/remote-work intensity

**Response:** This is a valid concern we did not fully address. Future work should include industry×year controls and examine robustness to excluding 2020-2021.

### Treatment Mismeasurement
> You code treatment by state of residence... remote work creates non-classical measurement error

**Response:** We acknowledge this limitation. The rise of remote work during our sample period complicates treatment assignment.

---

## Response to Reviewer 3 (GPT 5.2)

We thank Reviewer 3 for their constructive suggestions.

### Wild Cluster Bootstrap
> Top journals now expect wild cluster bootstrap p-values

**Response:** With 51 clusters and few treated states, this is a valid concern. We would implement fwildclusterboot in a revision.

### Figure 4 Sign Inconsistency
> Figure 4 appears to contradict the main finding

**Response:** Figure 4 shows simple pre/post differences that do not control for time trends. The positive values for some states reflect overall wage growth, not treatment effects. We should clarify this in the caption.

### Distributional Analysis
> Use RIF regression rather than DiD on quantiles

**Response:** This is methodologically correct. Our current approach of computing state-year quantiles and running DiD introduces generated-regressor issues.

---

## Summary

We appreciate the thorough reviews from all three referees. Their main concerns are:

1. Pre-trend violations undermine causal identification
2. Sensitivity analysis shows results not robust to parallel trends violations
3. Treatment-outcome mismatch (all workers vs. new hires)
4. Need stronger inference (wild cluster bootstrap)
5. Missing key citations

We acknowledge these limitations and have added sensitivity analysis documenting the identification challenges. The paper provides suggestive evidence on wage dynamics around transparency law adoption, but causal claims are not supported at the level required for top journals.

The contribution remains valuable as:
- First large-sample analysis of US salary transparency laws
- Demonstration of appropriate staggered DiD methodology
- Documentation of patterns warranting further investigation
- Honest reporting of identification limitations
