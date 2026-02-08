# Research Ideas

## Idea 1: State Auto-IRA Mandates and Retirement Savings

**Policy:** State-mandated auto-enrollment IRA programs for private-sector workers without employer-sponsored retirement plans. Staggered adoption:
- Oregon (OregonSaves): October 2017
- Illinois (Secure Choice): October 2018
- California (CalSavers): July 2019
- Connecticut (MyCTSavings): April 2022
- Maryland (Maryland$aves): September 2022
- Colorado (Secure Savings): January 2023
- Virginia (RetirePath): June 2023
- Maine: January 2024
- New Jersey: June 2024
- Delaware: July 2024
- Vermont: December 2024
- Nevada: June 2025
- Minnesota: January 2026

**Outcome:** Retirement account ownership and participation rates from IPUMS CPS Annual Social and Economic Supplement (ASEC). The ASEC asks about pension plan coverage and participation. Secondary outcomes: household savings rates, financial stress indicators.

**Identification:** Difference-in-differences exploiting staggered state adoption. Treatment varies at state×year level. Never-treated states (no mandate) serve as comparison. Use Callaway-Sant'Anna estimator for heterogeneity-robust estimates.

**Why it's novel:** While individual state program evaluations exist (OregonSaves has been studied), no paper has evaluated the POOLED effect across all state programs using modern staggered DiD methods. The staggered rollout from 2017-2024 provides excellent variation for dynamic treatment effects and treatment effect heterogeneity analysis.

**Feasibility check:**
- Variation exists: 13+ states with clean adoption dates, never-treated comparison states
- Data accessible: IPUMS CPS ASEC available 2015-2024 (API key confirmed)
- Not overstudied: Individual program evaluations exist but no multi-state DiD with modern methods
- Sample size: CPS ASEC ~100k households/year, sufficient power for state-level clustering

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | CPS ASEC available 2015+; Oregon adopted Oct 2017 → 2+ pre-periods for all treated states | **Strong** |
| Selection into treatment | States adopted based on legislative/political factors, not trending retirement outcomes. Democratic states more likely to adopt. | **Marginal** (political selection, but not outcome-based) |
| Comparison group quality | Never-treated states include red states with different demographics but similar private-sector worker composition | **Marginal** |
| Treatment clusters | 13 treated states + 37 never-treated → 50 states total | **Strong** |
| Concurrent policies | SECURE Act (2019) affected 401(k) rules federally; may interact | **Marginal** (federal policy affects all states equally) |

**Decision:** PURSUE - Strong cluster count, adequate pre-periods, selection not outcome-based. Will need to control for state political lean and test robustness to SECURE Act timing.

---

## Idea 2: Salary History Bans and the Gender Wage Gap

**Policy:** State laws prohibiting employers from asking job applicants about salary history. Staggered adoption:
- California: January 2018
- Massachusetts: July 2018
- Delaware: December 2017
- Oregon: January 2019
- Maine: August 2019
- New Jersey: January 2020
- New York State: January 2020
- Colorado: January 2021
- (Plus ~15 more states through 2024)

**Outcome:** Gender wage gap measured from IPUMS CPS Outgoing Rotation Group (ORG) or ACS. Can measure wages conditional on demographics/occupation for job changers vs. stayers.

**Identification:** Difference-in-differences exploiting staggered state adoption. Treatment varies at state×year level. Can use triple-diff: compare job changers (affected) vs. job stayers (unaffected) across treated vs. untreated states.

**Why it's novel:** Several papers examine early adopters (Massachusetts, California), but no comprehensive multi-state evaluation exists using the full 2017-2024 policy wave. The triple-diff design with job changers provides cleaner identification than existing work.

**Feasibility check:**
- Variation exists: 22+ states with adoption dates, staggered 2017-2024
- Data accessible: IPUMS CPS ORG has hourly wages, job tenure, and state identifiers
- Not overstudied: Early papers exist but no pooled staggered DiD
- Sample size: CPS ORG ~200k workers/year

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | CPS ORG available continuously; early adopters (2018) have 2017 as pre-period only | **Weak** (earliest adopters have 1 pre-period) |
| Selection into treatment | Blue states adopted; gender wage gap may have been trending differently in these states | **Weak** (possible selection on wage gap trends) |
| Comparison group quality | Red states as controls may have different labor market dynamics | **Marginal** |
| Treatment clusters | 22+ treated states → good | **Strong** |
| Concurrent policies | #MeToo movement (2017), minimum wage changes, pay transparency laws overlap | **Weak** (many concurrent factors) |

**Decision:** CONSIDER with caution - Strong cluster count but weak pre-periods for early adopters and potential selection bias. The triple-diff design (job changers vs. stayers) helps, but concurrent policy environment is messy.

---

## Idea 3: Automatic Voter Registration and Voter Turnout

**Policy:** Automatic voter registration (AVR) at DMV and other state agencies. Staggered adoption:
- Oregon: January 2016
- California: April 2018
- Vermont: January 2017
- Alaska: October 2016
- Colorado: 2017
- (Plus 19 more states through 2023)

**Outcome:** Voter turnout from CPS Voting and Registration Supplement (conducted in November of even years). Also voter registration rates.

**Identification:** Difference-in-differences comparing turnout in AVR states vs. non-AVR states before/after adoption.

**Why it's novel:** Several papers estimate AVR effects, but most focus on single states. A multi-state evaluation with proper staggered DiD methods would be valuable.

**Feasibility check:**
- Variation exists: 24 states + DC with adoption dates
- Data accessible: CPS Voting Supplement (biennial)
- Studied: MODERATELY studied - several state-specific papers exist
- Sample size: CPS Voting Supplement ~50k per cycle

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | CPS Voting only biennial (2014, 2016, 2018...). Oregon (2016 adopter) has only 2014 pre-period | **Weak** (biennial data limits pre-periods) |
| Selection into treatment | Democratic states adopted; turnout may have been trending differently | **Weak** |
| Comparison group quality | Non-AVR states are largely red states with different political dynamics | **Marginal** |
| Treatment clusters | 24 treated states → good | **Strong** |
| Concurrent policies | Voter ID laws, felon re-enfranchisement, early voting changes all concurrent | **Weak** |

**Decision:** SKIP - Biennial outcome data severely limits pre-trends testing. Political selection is strong and concurrent voting policies create attribution problems. This topic is also already moderately studied.

---

## Idea 4: State Pay Transparency Laws and Wage Dispersion

**Policy:** State laws requiring employers to disclose salary ranges in job postings. Staggered adoption:
- Colorado: January 2021
- California: January 2023
- Washington: January 2023
- New York City: November 2022
- Rhode Island: January 2023
- (Plus several more through 2025)

**Outcome:** Within-firm and within-occupation wage dispersion from CPS ORG. Wage levels by gender, race, tenure.

**Identification:** Difference-in-differences on wage dispersion measures (Gini, 90/10 ratio) within occupations pre/post law.

**Why it's novel:** These laws are very recent (2021+). Only Colorado has been studied. First multi-state evaluation possible.

**Feasibility check:**
- Variation exists: 6-8 states with adoption dates, very recent
- Data accessible: CPS ORG
- Not overstudied: Very new policy, minimal existing research
- Sample size: CPS ORG sufficient

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | Colorado (2021) has 2019-2020 pre-periods; others have longer | **Marginal** |
| Selection into treatment | Blue states; may have pre-existing wage compression trends | **Weak** |
| Comparison group quality | Non-adopter states as controls | **Marginal** |
| Treatment clusters | Only 6-8 treated states so far | **Weak** |
| Concurrent policies | Salary history bans, minimum wage, overlapping | **Weak** |

**Decision:** SKIP - Too few treated units (6-8 states), too recent for adequate pre-periods, confounded with salary history bans.

---

## Idea 5: State Clean Energy Standards and Electricity Prices

**Policy:** State 100% clean energy standards (CES) requiring utilities to achieve zero-carbon electricity. Staggered adoption:
- Hawaii: 2015 (100% by 2045)
- California: 2018 (100% by 2045)
- New Mexico: 2019 (100% by 2045)
- Washington: 2019 (100% by 2045)
- Virginia: 2020 (100% by 2045/2050)
- Oregon: 2021 (100% by 2040)
- Minnesota: 2023 (100% by 2040)

**Outcome:** Residential and commercial electricity prices from EIA State Energy Data System (SEDS). Also renewable energy share, reliability metrics.

**Identification:** Difference-in-differences comparing electricity prices in states with 100% CES vs. states with weaker or no RPS targets.

**Why it's novel:** Extensive RPS literature exists, but 100% CES is a distinct policy (stronger mandate). Few papers specifically evaluate 100% standards, which are relatively new.

**Feasibility check:**
- Variation exists: 7+ states with 100% CES, staggered 2015-2023
- Data accessible: EIA SEDS provides state×year electricity prices, freely available
- Partially studied: RPS studied extensively; 100% CES less so
- Sample size: State-level annual data

### DiD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | EIA data available 2000+; Hawaii (2015) has 15+ pre-periods | **Strong** |
| Selection into treatment | Blue states with environmental preferences adopted; may have pre-existing renewable trends | **Marginal** |
| Comparison group quality | States with weaker RPS targets as controls; varying baseline renewable shares | **Marginal** |
| Treatment clusters | Only 7-8 states with 100% CES | **Weak** |
| Concurrent policies | Federal ITC/PTC tax credits, natural gas price fluctuations, solar cost declines | **Marginal** |

**Decision:** SKIP - Only 7-8 treated states provides weak inference with state-level clustering. Also, 100% CES targets are for 2040-2050, so near-term effects may be minimal.

---

## Summary

| Idea | Decision | Primary Concern |
|------|----------|-----------------|
| 1. Auto-IRA Mandates | **PURSUE** | Political selection (manageable with controls) |
| 2. Salary History Bans | **CONSIDER** | Weak pre-periods, concurrent policies |
| 3. Automatic Voter Registration | SKIP | Biennial data, political selection |
| 4. Pay Transparency | SKIP | Too few treated states |
| 5. Clean Energy Standards | SKIP | Too few treated states |

**Recommended:** Idea 1 (State Auto-IRA Mandates) is the strongest candidate with adequate pre-periods, strong cluster count, and a clear mechanism (automatic enrollment → retirement savings participation).
