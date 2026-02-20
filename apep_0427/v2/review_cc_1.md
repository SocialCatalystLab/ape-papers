# Internal Review (Round 1) — Claude Code

**Paper:** The €6,000 Question: Do Apprenticeship Subsidies Create Jobs or Relabel Hiring?

## PART 1: CRITICAL REVIEW

### Identification Strategy
The paper uses two complementary designs: (1) a sector-level exposure DiD exploiting variation in pre-reform apprenticeship intensity across 19 NACE sectors, and (2) a cross-country DiD comparing French youth employment to 7 EU comparators. Both designs have well-known limitations that the paper now acknowledges more transparently than v1.

**Sector-level design:** The exposure variable (2019 apprenticeship share by NACE section) is plausibly exogenous to post-2023 shocks, and the balance test confirms no correlation with pre-2023 sector growth trends. However, 19 clusters is low for cluster-robust inference. The paper addresses this with WCB and RI, which is appropriate.

**Cross-country design:** France as a single treated unit is inherently weak for causal inference. The paper now frames this appropriately as "suggestive" and supplements with SCM. The SCM Fisher p-value of 0.625 confirms the imprecision.

### Total Employment Red Flag
The paper correctly flags that total employment also responds positively in high-exposure sectors (Column 4). This is the paper's most serious identification concern. If broader sectoral trends drive the result, the youth share coefficient is confounded. The paper discusses this honestly but could push harder on what would be needed to resolve it (e.g., matched sector-level controls from other countries).

### Coefficient Magnitudes
With the rescaled exposure (percentage points), coefficients are now sensibly sized: 0.074 pp of youth share per pp of exposure. This is economically meaningful but not implausible.

### Pre-Trend Volatility
The event study shows substantial pre-period noise (largest pre-period coefficient exceeds the post-treatment estimate). This is honest but weakens confidence in the parallel trends assumption.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Sector-level controls from other countries:** The paper could strengthen identification by showing that the same high-exposure sectors in Germany or Spain did NOT see differential youth employment growth post-2023.

2. **Heterogeneity by firm size:** The paper mentions the 2025 reform differentiated by firm size. If sector-level data can be disaggregated by establishment size, this would provide a powerful additional test.

3. **Longer post-period:** As more quarters become available, the persistence of the effect (or lack thereof) would help distinguish mechanisms.

4. **Formal power analysis:** Given the noise in pre-treatment estimates, a formal MDE calculation would help readers calibrate the precision of the null rejection.

## DECISION

DECISION: MINOR REVISION
