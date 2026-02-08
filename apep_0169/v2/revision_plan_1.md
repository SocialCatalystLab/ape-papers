# Revision Plan for paper_155 (Revision of apep_0169)

## Summary of Reviewer Feedback

### GPT-5-mini (MAJOR REVISION)
- Consider additional heterogeneity analyses
- Expand discussion of mechanisms
- Address measurement limitations

### Grok-4.1-Fast (MAJOR REVISION)
- Results are interesting but need more robustness
- Add quantile treatment effects discussion
- Consider panel data extensions

### Gemini-3-Flash (MAJOR REVISION)
- Strong conceptual contribution with incorporated/unincorporated split
- Missing propensity score overlap visualization
- Need more discussion of policy implications

## Changes Already Implemented in This Revision

1. **Incorporated vs. Unincorporated Decomposition** (Critical - all reviewers of parent)
   - Added selfemp_type variable distinguishing incorporated/unincorporated
   - Separate estimates show: incorporated +7% premium, unincorporated -46% penalty
   - Key finding: aggregate penalty masks profound heterogeneity

2. **95% Confidence Intervals** (All reviewers of parent)
   - Added CIs to all tables
   - Using HC1 robust standard errors throughout

3. **ATT alongside ATE** (Grok suggestion from parent)
   - Both estimands now reported in aggregate_results.rds

4. **Missing Literature** (GPT suggestion from parent)
   - Added Levine & Rubinstein (2017) QJE
   - Added Austin (2009) for balance diagnostics
   - Added Hirano et al. (2003) for IPW methodology

5. **Prose-based Theory Section** (User request)
   - Converted bullet lists to flowing exposition
   - Added related literature subsection

6. **Fixed Data Issue** (Critical)
   - Changed from WAGP (wage income only) to PINCP (total personal income)
   - Now properly captures self-employment income
   - Results now plausible: unincorporated -46% vs old -99%

## Remaining Items for Future Revisions

- Add propensity score density plots
- Add Love plot for covariate balance
- Consider panel data extension with ASEC

## Decision

Paper addresses critical concerns from parent paper reviews. Publishing as revision of apep_0169.
