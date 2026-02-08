# Research Plan: Salary Transparency Laws and New Hire Earnings

## Revision of apep_0158

This is a major methodological revision addressing reviewer feedback that identified inability to separate new hires from incumbents as the core limitation.

## Key Change: CPS → QWI

Replace CPS ASEC survey data with Census Quarterly Workforce Indicators (QWI):
- **Variable**: `EarnHirAS` - average monthly earnings of new hires
- **Granularity**: County × Quarter × Sex
- **Coverage**: 18 states (6 treated + 12 border controls), 2015-2023

## Empirical Strategy

### 1. Main Analysis: Callaway-Sant'Anna
- County-level staggered DiD
- Never-treated counties as controls
- Doubly-robust estimation
- State-clustered standard errors

### 2. Border Discontinuity Design
Following Dube, Lester & Reich (2010):
- Identify 129 county pairs sharing physical borders
- One county treated, one control
- Pair × Quarter fixed effects
- Pair-clustered standard errors

### 3. Gender Analysis
- Separate C-S by sex
- DDD in border design (Post × Female interaction)

## Results Summary

| Specification | ATT | SE | Significant |
|--------------|-----|-----|-------------|
| Callaway-Sant'Anna | +0.7% | 1.2% | No |
| Border county-pairs | +11.5% | 2.0% | Yes*** |
| TWFE | +2.5% | 1.5% | No |

## Key Finding

Contrary to theoretical predictions, transparency associated with HIGHER new hire earnings in border design. No evidence of wage declines through employer commitment.

## Status
- [x] QWI data fetch
- [x] Data cleaning and border identification
- [x] Main analysis (C-S)
- [x] Robustness checks
- [x] Figures generated
- [x] Tables generated
- [x] Paper.tex updated
- [x] PDF compiled (39 pages)
- [ ] Advisor review
- [ ] External review
- [ ] Publish
