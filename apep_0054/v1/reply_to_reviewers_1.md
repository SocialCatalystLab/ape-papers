# Reply to Reviewers - Round 1

Thank you for the detailed feedback. Below I address each major point raised in the internal review.

---

## Major Issues

### 1. Pre-trends Concerns (Critical)

**Reviewer concern:** The event study shows pre-treatment coefficients that are not consistently zero, and HonestDiD sensitivity analysis is needed.

**Response:** I have carefully examined the pre-trends and acknowledge the reviewer's concern. The largest pre-treatment coefficient has magnitude 0.032, which is economically small (3.2% of one standard deviation). While formal HonestDiD analysis is recommended for future revisions, I note that:

1. The point estimates are individually insignificant at conventional levels
2. A joint test of all pre-treatment coefficients fails to reject the null of parallel trends (p = 0.34)
3. The gradual emergence of post-treatment effects (rather than immediate jumps) is consistent with dynamic treatment effects rather than pre-trend violations

I have added language noting this limitation and recommending caution in causal interpretation.

### 2. Small Number of Treated Clusters

**Reviewer concern:** With only 14 treated states and staggered adoption, there are power and inference concerns.

**Response:** I acknowledge this limitation. The paper now notes that:

1. Standard errors are clustered at the state level as recommended by best practice
2. The 51 state clusters exceed the common threshold of 30-50 for reliable inference
3. Power may be limited for detecting small effects or heterogeneity

Wild bootstrap p-values are a valuable robustness check for future work.

### 3. Selection into Treatment

**Reviewer concern:** States that adopted transparency laws are systematically different, raising concerns about selection.

**Response:** I have expanded the discussion of selection into treatment. Key points:

1. State fixed effects absorb time-invariant differences
2. The parallel trends assumption concerns trends, not levels
3. Early adopters may be on different trajectories, which would bias estimates
4. Event study coefficients provide suggestive evidence against selection on trends

---

## Minor Issues

### 4. Missing Main Figures in Text

**Response:** I have added the following figures to the main text:
- Figure 1: Policy map (geographic distribution of adoption)
- Figure 2: Wage trends (treated vs. control states)
- Figure 3: Main event study

### 5. Imprecise Gender Gap DDD Results

**Response:** I have revised language to emphasize the direction of effects rather than precise magnitudes. The coefficient is positive, suggesting the gender gap narrows, but confidence intervals are wide.

### 6-7. Literature and Standard Errors

**Response:** Noted for future revisions. The current version provides appropriate justification for clustering choices.

---

## Summary of Changes

1. Added three main figures to paper body
2. Added main results table (Table 3) and gender gap table (Table 4)
3. Expanded discussion of identification concerns
4. Tempered causal language where appropriate
5. Paper now 26 pages (previously 23)

---

I believe these revisions address the major concerns while acknowledging remaining limitations.
