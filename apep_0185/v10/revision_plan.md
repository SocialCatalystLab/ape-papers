# Revision Plan: apep_0197 → apep_0198+

## Parent Paper
- **ID**: apep_0197
- **Title**: Friends in High Places: How Social Networks Transmit Minimum Wage Shocks

## Problems Identified

### 1. Weight Normalization Bug
Weights `w_pop` are normalized over the full SCI network, then connections get dropped (coordinate join filter, NA population joins). `na.rm=TRUE` in `sum(w_pop * log_min_wage)` produces a weighted SUM, not a weighted AVERAGE. Result: 20% of obs have exposure < log(7.25), which is theoretically impossible.

**Fix**: Re-normalize weights after ALL filtering, inside each exposure computation block.

### 2. Missing Job Flow Analysis
QWI API fetched HirA, Sep, FrmJbC, FrmJbD but they were dropped during `02_clean_data.R` (only Emp and EarnS were renamed). These variables test the mechanism: does network exposure increase hiring? reduce separations?

**Fix**: Preserve all QWI variables through the pipeline, add job flow analysis script.

### 3. Uninterpretable Magnitudes
The 2SLS coefficient (β=0.82) is hard to contextualize. Need USD-denominated specifications for plain-English interpretation ("a $1 increase in network avg MW → X% employment change").

**Fix**: Add USD exposure measures with properly normalized weights, add USD specifications to main analysis.

## Changes by File

### 02_clean_data.R
- Re-normalize weights after NA filtering in all exposure computations
- Preserve HirA, Sep, FrmJbC, FrmJbD through pipeline
- Add USD-denominated exposure measures
- Add job flow log transformations and rate variables

### 03_main_analysis.R
- Make earnings co-primary with full battery (OLS, 2SLS, balance test)
- Add USD-denominated specifications for employment and earnings
- Add magnitude interpretation section

### 04d_job_flows.R (NEW)
- OLS + 2SLS for job flow outcomes (hires, separations, firm job creation/destruction)

### 05_figures.R
- Add earnings event study panel alongside employment

### 06_tables.R
- Restructure tab2 with Panel A (Employment) and Panel B (Earnings)
- Add USD specification columns
- Add job flow results table

### paper.tex
- Extend theory section for earnings predictions and job flows
- Restructure results section with co-primary outcomes
- Add USD magnitude discussion
- Update abstract
