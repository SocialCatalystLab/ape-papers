# Research Ideas for Paper 66

**Method:** Difference-in-Differences (randomly selected)
**Date:** 2026-01-22

---

## Idea 1: Salary Transparency Laws and Wage Outcomes

### Policy
State salary transparency laws requiring employers to disclose salary ranges in job postings. Staggered adoption 2021-2025:

| State | Effective Date | Employer Threshold |
|-------|---------------|-------------------|
| Colorado | Jan 1, 2021 | All employers (1+) |
| California | Jan 1, 2023 | 15+ employees |
| Washington | Jan 1, 2023 | 15+ employees |
| New York State | Sept 17, 2023 | 4+ employees |
| Hawaii | Jan 1, 2024 | 50+ employees |
| D.C. | June 30, 2024 | All employers |
| Maryland | Oct 1, 2024 | All employers |
| Illinois | Jan 1, 2025 | 15+ employees |
| Minnesota | Jan 1, 2025 | 30+ employees |
| New Jersey | June 1, 2025 | 10+ employees |
| Vermont | July 1, 2025 | 5+ employees |
| Massachusetts | Oct 29, 2025 | 25+ employees |
| Maine | Jan 1, 2026 | 10+ employees |

### Outcome
Individual wage levels and gender wage gaps using CPS MORG (EARNWEEK, HOURWAGE) or ACS PUMS (WAGP/INCWAGE). State identifiers available via STATEFIP.

### Identification
Staggered DiD comparing treated states to not-yet-treated and never-treated states. Event study design with Callaway-Sant'Anna estimator. Pre-treatment period: 2018-2020 for early adopters.

### Why Novel
- Most existing research focuses on Colorado only (e.g., Arnold 2023)
- No published DiD studying the full 2023-2025 wave of state adoptions
- First comprehensive analysis of heterogeneous law designs (different thresholds)

### DiD Early Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | 5+ years (2018-2022 for CO; 2018-2020 for CA/WA) | Strong |
| Selection into treatment | Correlated with blue states, but staggered timing helps | Marginal |
| Comparison group | ~35 never-treated states, but geographic clustering concern | Marginal |
| Treatment clusters | 13+ treated states by end-2025 | Strong |
| Concurrent policies | Some states bundle with equal pay laws | Marginal |
| Outcome-Policy Alignment | Wages directly measured; law directly affects wage offers | Strong |

**Overall: PURSUE** - Strong staggered variation, direct outcome measurement, novel multi-state analysis.

---

## Idea 2: Predictive Scheduling Laws and Worker Outcomes

### Policy
Fair workweek/predictive scheduling laws requiring advance notice of work schedules. Staggered adoption 2015-2025:

| Jurisdiction | Effective Date | Industries | Advance Notice |
|--------------|---------------|------------|----------------|
| San Francisco, CA | July 3, 2015 | Retail | 14 days |
| Emeryville, CA | July 1, 2017 | Retail, Fast Food | 14 days |
| Seattle, WA | July 1, 2017 | Retail, Food Service | 14 days |
| New York City (Fast Food) | Nov 26, 2017 | Fast Food | 14 days |
| Oregon (statewide) | July 1, 2018 | Retail, Hospitality, Food | 14 days |
| Philadelphia, PA | April 1, 2020 | Retail, Hospitality, Food | 14 days |
| Chicago, IL | July 1, 2020 | Multiple | 14 days |
| New York City (Retail) | 2021 | Retail | 72 hours |
| Los Angeles City, CA | April 1, 2023 | Retail | 14 days |
| Evanston, IL | Jan 1, 2024 | Multiple | 14 days |
| Berkeley, CA | Jan 12, 2024 | Multiple | 14 days |
| Los Angeles County, CA | July 1, 2025 | Retail | 14 days |

### Outcome
Worker hours, earnings, and employment stability using CPS MORG (hours worked, earnings) for workers in retail/food service industries. Can identify industry using occupation codes.

### Identification
Staggered DiD with Oregon as the only statewide treatment. City-level analysis challenging due to data granularity, but can exploit Oregon vs. other states.

### Why Novel
- Limited empirical evidence on effects of predictive scheduling laws
- Oregon's statewide adoption creates clean state-level treatment
- Can examine effects on worker hours volatility and earnings stability

### DiD Early Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | 5+ years (2013-2017 for Oregon) | Strong |
| Selection into treatment | Progressive cities self-select; Oregon somewhat unique | Marginal |
| Comparison group | 49 states without statewide laws; 10+ states with preemption | Strong |
| Treatment clusters | Only 1 statewide (Oregon), rest city-level | Weak |
| Concurrent policies | Minimum wage increases often coincide | Marginal |
| Outcome-Policy Alignment | Hours/schedule stability directly affected | Strong |

**Overall: SKIP** - Too few state-level clusters (essentially single treated unit for statewide policy). City-level analysis requires geocoded microdata not available in public CPS.

---

## Idea 3: PBM Spread Pricing Bans and Pharmacy Reimbursement

### Policy
State laws prohibiting pharmacy benefit managers (PBMs) from retaining spread pricing (difference between what PBMs charge health plans and pay pharmacies). Staggered adoption:

| State | Effective Date | Scope |
|-------|---------------|-------|
| Georgia | July 1, 2019 | Medicaid |
| Iowa | July 1, 2019 | Medicaid |
| Kansas | July 1, 2019 | Medicaid |
| Michigan | July 1, 2019 | Medicaid |
| Minnesota | July 1, 2019 | Medicaid |
| Mississippi | July 1, 2019 | Medicaid |
| New Jersey | July 1, 2019 | Medicaid |
| North Dakota | July 1, 2019 | Medicaid |
| Texas | July 1, 2019 | Medicaid |
| Ohio | FY 2020-2021 | Medicaid |
| Kentucky | 2021 | Medicaid (single PBM) |
| Arkansas | July 24, 2020 | Medicaid |
| Virginia | 2022 | Medicaid |
| Florida | Jan 1, 2024 | Commercial + Medicaid |
| Pennsylvania | Nov 14, 2024 | Commercial + Medicaid |
| Idaho | 2024 | Commercial |
| Vermont | 2024 | Commercial |
| California | Jan 1, 2026 | Commercial (phased) |

### Outcome
Pharmacy closures, independent pharmacy counts, and prescription drug prices. Potential data: NCPDP pharmacy database, state pharmacy board licensure data, drug price indices.

### Identification
Staggered DiD comparing treated states to never-treated states. Large wave in July 2019 creates natural experiment.

### Why Novel
- Extensive policy variation (20+ states)
- Understudied despite significant policy activity
- Direct implications for pharmacy market structure

### DiD Early Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | 5+ years (2014-2018 for 2019 wave) | Strong |
| Selection into treatment | Both red and blue states adopted | Strong |
| Comparison group | ~30 never-treated states | Strong |
| Treatment clusters | 20+ treated states | Strong |
| Concurrent policies | Some states bundled with other PBM reforms | Marginal |
| Outcome-Policy Alignment | Spread pricing ban → pharmacy reimbursement → pharmacy viability | Marginal |

**Challenge:** Outcome data accessibility uncertain. Need to verify pharmacy closure/viability data availability.

**Overall: CONSIDER** - Strong policy variation but outcome data feasibility unclear. Would need pharmacy-level data.

---

## Idea 4: Drug Pricing Transparency Laws and Pharmaceutical Pricing

### Policy
State laws requiring pharmaceutical manufacturers to report/justify price increases above specified thresholds. Staggered adoption 2016-2025:

| State | Effective Date | WAC Threshold | Price Increase Trigger |
|-------|---------------|---------------|----------------------|
| Vermont | 2016 | Varies | Top-spend drugs |
| California | Jan 1, 2019 | Varies | 60-day advance notice |
| Oregon | July 1, 2019 | $100+ for 30-day | >10% for drugs >$100 |
| Louisiana | 2018 | $100+ for 30-day | >50% increase |
| Connecticut | Jan 1, 2020 | $40+ for course | >16% over 2 years |
| Nevada | 2021 (expanded) | $40+ | >10% (1-year) |
| Washington | Oct 1, 2019 | $100+ for 30-day | >20% (1-year) |
| Maine | Feb 4, 2020 | Varies | Comprehensive |
| Colorado | Jan 1, 2022 | $30,000+/year | >10% (brand) |
| Minnesota | Oct 1, 2021 | $100+ | >16% (brand) |
| Utah | Oct 30, 2020 | $100+ for 30-day | >16% (2-year) |
| Texas | 2021 | $100+ for 30-day | >15% (1-year) |
| Virginia | Jan 1, 2022 | $100+ for 30-day | >15% |
| New York | June 19, 2024 | $40+ for course | >16% |
| Florida | July 1, 2023 | $100+ for course | >15% (1-year) |
| New Jersey | Aug 1, 2024 | $10+ (generic) | >10% |
| New Mexico | June 1, 2025 | $400+ for 30-day | >10% (1-year) |

### Outcome
Drug price growth rates using Medicaid drug rebate data, NDC-level pricing databases (Medi-Span, First Databank), or aggregate prescription drug price indices.

### Identification
Staggered DiD comparing price trajectories of drugs in treated vs. untreated states. Challenge: most drugs have national pricing, so need to identify drugs primarily sold in specific states.

### Why Novel
- 15+ states with clear adoption dates
- Directly addresses policy-relevant question of transparency effects
- Can test whether sunshine laws reduce price increases

### DiD Early Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | 5+ years (2011-2015 for Vermont) | Strong |
| Selection into treatment | Mix of blue/red states | Strong |
| Comparison group | ~30 never-treated states | Strong |
| Treatment clusters | 15+ treated states | Strong |
| Concurrent policies | ACA drug provisions, Part D negotiations | Marginal |
| Outcome-Policy Alignment | Drug prices directly targeted, but national pricing complicates | Weak |

**Challenge:** Drug prices are typically set nationally, not state-by-state. State transparency laws may not affect prices if manufacturers use uniform national pricing. Need state-specific outcome measure.

**Overall: SKIP** - Fundamental identification problem: drug prices are set nationally, so state-level policy variation may not produce state-level price variation. Outcome doesn't align with treatment geography.

---

## Idea 5: State AI Hiring Regulation and Employment Outcomes

### Policy
State and local laws regulating AI/algorithmic tools in hiring decisions. Staggered adoption:

| Jurisdiction | Effective Date | Key Requirements |
|--------------|---------------|------------------|
| Illinois AIVIA | Jan 1, 2020 | AI video interview notice/consent |
| Maryland | Oct 1, 2020 | Facial recognition consent |
| NYC Local Law 144 | July 5, 2023 | Bias audit, disclosure |
| Utah | May 1, 2024 | AI disclosure |
| California FEHA | Oct 1, 2025 | Anti-bias testing, notices |
| Illinois HB 3773 | Jan 1, 2026 | Notice, anti-discrimination |
| Texas | Jan 1, 2026 | AI governance |
| Colorado | June 30, 2026 | Impact assessments |

### Outcome
Employment rates, hiring patterns, potentially discrimination claims using EEOC data or CPS employment by demographics.

### Identification
Staggered DiD comparing employment outcomes in treated vs. untreated jurisdictions.

### Why Novel
- Rapidly emerging policy area
- NYC Local Law 144 is landmark legislation
- No empirical studies yet on employment effects

### DiD Early Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | Limited - most laws 2023-2026 | Weak |
| Selection into treatment | Tech-heavy progressive states | Marginal |
| Comparison group | 40+ untreated states | Strong |
| Treatment clusters | Only 8 jurisdictions, mostly 2025-2026 | Weak |
| Concurrent policies | General AI regulation overlap | Marginal |
| Outcome-Policy Alignment | Employment effects are second-order; law targets hiring process | Weak |

**Overall: SKIP** - Too few treated units, mostly future effective dates (2025-2026), and outcome (employment) is far downstream from the policy mechanism (hiring process disclosure). Better studied with job posting or audit study data.

---

## Summary

| Idea | Policy | Assessment | Recommendation |
|------|--------|------------|----------------|
| 1 | Salary Transparency Laws | Strong variation, direct outcomes | **PURSUE** |
| 2 | Predictive Scheduling Laws | Only 1 statewide treatment | SKIP |
| 3 | PBM Spread Pricing Bans | Strong variation, data feasibility uncertain | CONSIDER |
| 4 | Drug Pricing Transparency | National pricing problem | SKIP |
| 5 | AI Hiring Regulation | Too few/future treatments | SKIP |

**Primary recommendation: Idea 1 (Salary Transparency Laws)**

This has the strongest combination of:
- Clear staggered adoption (13+ states, 2021-2025)
- Direct outcome measurement (wages in CPS/ACS)
- Policy-outcome alignment (laws directly affect wage offers)
- Novel contribution (first multi-state DiD)
- Sufficient pre-treatment periods for early adopters

Backup option: Idea 3 (PBM Spread Pricing Bans) if pharmacy-level data can be secured.
