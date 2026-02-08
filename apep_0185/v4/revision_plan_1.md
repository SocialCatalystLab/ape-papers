# Revision Plan 1

**Paper:** Social Network Minimum Wage Exposure: Causal Evidence from Out-of-State Instrumental Variables
**Date:** 2026-02-06
**Reviews:** GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash (all MAJOR REVISION)

## Summary of Reviewer Concerns

All three reviewers praised the novel dataset and creative IV strategy (F=290.5) but raised consistent concerns:

### Critical Issues (All Reviewers)

1. **Missing 95% Confidence Intervals** - All tables report SEs and p-values but not CIs
2. **Balance Test Failures** - Pre-treatment outcomes differ by IV quartile (p=0.094 for main IV, p<0.001 for distance IVs)
3. **Missing References** - Borusyak, Hull & Jaravel (2022) on shift-share designs

### Methodological Concerns

4. **Shift-Share Inference** - Need AKM/Adão-style shock-level inference for the IV
5. **Within-County Variation Limited** - Only 26.5% of IV variance is within-county
6. **Employment Effect Insignificant** - β=0.27, p=0.12 (not statistically significant)
7. **LATE Interpretation Missing** - Who are the compliers?

### Presentation Issues

8. **Causal Claims Overstated** - Should be more cautious given balance test results
9. **Number of Clusters Not Reported** - Need state cluster counts in tables
10. **Repetition** - IV explanation appears multiple times

## Prioritized Revision Plan

### Priority 1: Statistical Reporting (Immediate)
- [ ] Add 95% CIs to all main results tables (Tables 7, 8, 10)
- [ ] Report number of state clusters (51) in all tables
- [ ] Add weak-instrument robust CIs (Anderson-Rubin) for 2SLS

### Priority 2: Balance Test Discussion (Required)
- [ ] Add county-specific linear time trends as robustness
- [ ] More prominently acknowledge balance test limitations
- [ ] Temper causal language throughout

### Priority 3: Literature (Required)
- [ ] Add Borusyak, Hull & Jaravel (2022) citation and discussion
- [ ] Position paper explicitly as shift-share design
- [ ] Discuss implications of non-random shares

### Priority 4: Additional Diagnostics (If Time)
- [ ] Decompose IV by source state
- [ ] Leave-one-source-state-out robustness
- [ ] Event-study pre-trends by IV quartile
- [ ] Industry heterogeneity (Retail, Leisure & Hospitality)

## Scope for This Revision

Given the MAJOR REVISION decisions, I will focus on Priority 1-3 items. The paper already has extensive robustness checks; the main gaps are:

1. Confidence intervals in tables
2. Cluster counts in tables
3. More cautious language about causality
4. Shift-share literature positioning

This revision addresses the fatal flaws while acknowledging limitations honestly.
