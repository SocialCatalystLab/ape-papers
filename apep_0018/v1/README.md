# APEP_0025: Head Start Replication Study

## Title
The Long-Run Effects of Head Start: Replicating Ludwig-Miller (2007) and a Framework for Studying Intergenerational Mobility

## Summary
This paper replicates the influential Ludwig and Miller (2007) regression discontinuity analysis of Head Start and develops a framework for extending it to study intergenerational mobility using Opportunity Insights data.

## Key Findings
- Counties above the OEO 59.2% poverty threshold show approximately 1.2-1.8 fewer deaths per 100,000 children ages 5-9 from Head Start-related causes
- Preferred specification: τ = -1.20, SE = 0.66, p = 0.07, 95% CI: [-2.49, 0.10]
- McCrary density test shows no manipulation (log discontinuity = -0.002)
- Pre-treatment placebo test passes (τ = -0.64, p = 0.72)

## Method
Regression Discontinuity Design (RDD) exploiting the OEO grant-writing assistance threshold at 59.1984% county poverty rate.

## Data Sources
- Ludwig-Miller (2007) replication data from Hansen's Econometrics repository
- Opportunity Insights county-level outcomes (for framework only)

## Limitations
1. Uses OLS inference rather than modern rdrobust bias-corrected methods
2. Does not show first-stage (Head Start funding discontinuity) in our analysis
3. Covariate continuity tests not formally implemented
4. Mobility analysis proposed but not executed due to county identifier linkage challenges
5. Preferred estimate is marginally significant (p = 0.07, CI includes zero)

## Status
Working paper. Received "Major Revision" recommendation after 6 review rounds. Key methodological improvements would require rdrobust implementation and first-stage data that are not available in the current dataset.

## Files
- `paper.pdf` - Final paper (32 pages)
- `paper.tex` - LaTeX source
- `pre_analysis.md` - Locked pre-analysis plan
- `ideas.md` - Initial research ideas
- `code/` - Analysis scripts
- `data/` - Processed data files
- `figures/` - Generated figures

## Citation
```
APEP Research Team (2026). The Long-Run Effects of Head Start: Replicating
Ludwig-Miller (2007) and a Framework for Studying Intergenerational Mobility.
APEP Working Paper 0025.
```
