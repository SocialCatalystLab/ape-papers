# Research Prompt: State Paid Sick Leave Mandates and Low-Wage Worker Labor Supply

## Research Question

Do state mandatory paid sick leave (PSL) laws increase work hours and employment stability among low-wage service sector workers?

## Policy Background

Between 2012 and 2023, 13 U.S. states plus D.C. enacted mandatory paid sick leave laws with staggered implementation:
- Connecticut (Jan 2012)
- California (July 2015)
- Massachusetts (July 2015)
- Oregon (Jan 2016)
- Vermont (Jan 2017)
- Arizona (July 2017)
- Washington (Jan 2018)
- Maryland (Feb 2018)
- New Jersey (Oct 2018)
- Rhode Island (July 2018)
- Michigan (March 2019)
- Nevada (Jan 2020)
- Maine (Jan 2021)
- New York (Sept 2020)
- Colorado (Jan 2021)
- New Mexico (July 2022)

## Method

Difference-in-Differences (DiD) with staggered adoption, using modern estimators (Callaway-Sant'Anna or Sun-Abraham) to address heterogeneous treatment timing bias.

## Data

Census PUMS ACS 1-year data (2010-2023)

**Key Variables:**
- Outcomes: WKHP (hours worked per week), ESR (employment status)
- Treatment: ST (state) × year interaction based on PSL implementation dates
- Covariates: AGEP, SEX, RAC1P, SCHL, INDP, OCCP, MAR
- Weights: PWGTP

**Sample:**
- Adults aged 18-64
- Service sector industries (retail, food service, accommodation: INDP codes)
- Low-wage workers (bottom tercile of wage distribution within industry)

## Hypotheses

**H1:** PSL mandates increase average weekly hours worked among low-wage service workers by 0.5-1.5 hours (2-5% of baseline ~30 hours).

**Mechanisms:**
- Reduced presenteeism (workers don't come in sick, recover faster)
- Reduced turnover (workers don't quit to care for sick family)
- Possible employer hours adjustment for coverage needs

**Heterogeneity:**
- Effects larger for workers with children
- Effects larger in high-contact service occupations
- Effects larger in states without prior private-sector sick leave prevalence

## Pre-Analysis Plan Required

Before running regressions, lock:
- Exact sample restrictions
- Model specifications
- Outcome definitions
- Treatment coding
- Subgroup analyses
