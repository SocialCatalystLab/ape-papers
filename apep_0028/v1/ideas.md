# Research Ideas - Paper 35

**Geographic Focus:** Montana, Vermont, Rhode Island
**Date:** 2026-01-18

---

## Idea 1: Montana's "Montana Miracle" Zoning Reform and Housing Construction

### Policy
- **SB 528** (ADU legalization) and **SB 323** (duplex legalization)
- **Effective Date:** January 1, 2024
- **Scope:** Applies to municipalities with >5,000 residents in counties with >70,000 population
- SB 528 requires all Montana municipalities to allow at least one ADU per single-family lot by right, with permit fees capped at $250
- SB 323 legalizes duplexes anywhere single-family homes are permitted in qualifying cities

### Research Question
Does statewide zoning liberalization for ADUs and duplexes increase residential construction permits?

### Method
**Regression Discontinuity Design (RDD)** exploiting the 5,000 population threshold for municipal applicability, OR **Difference-in-Differences** comparing Montana municipalities to similar municipalities in states without zoning reform.

### Data Sources
- **Census Bureau Building Permits Survey** (state/county monthly data, downloadable Excel)
- **Minneapolis Fed Montana Housing Dashboard** (state-level housing indicators)
- **Census population data** for threshold analysis

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Clear implementation date | Yes (January 1, 2024) |
| Geographic variation | Yes (Montana vs. other states; large vs. small cities) |
| Data access | Yes (Census BPS publicly available) |
| Novel | Yes (very recent, no existing studies) |
| Parallel trends plausible | Moderate (housing markets vary by state) |

### Concerns
- Limited post-treatment period (2 years as of 2026)
- Legal challenge created uncertainty (injunction Dec 2023, resolved Mar 2025)
- May need synthetic control for short time series

### Verdict: **PROMISING** - Novel policy, clear identification strategy, accessible data

---

## Idea 2: Vermont Universal School Meals and Student Outcomes

### Policy
- **Act 151** (2022): Universal free breakfast and lunch for all Vermont public school students in SY 2022-23
- **Act 64** (2023): Made program permanent
- **Effective Date:** School Year 2022-23 (August 2022)
- Vermont was 3rd state (after California, Maine) to implement statewide universal school meals

### Research Question
Did Vermont's universal school meals policy reduce chronic absenteeism and improve student outcomes?

### Method
**Difference-in-Differences** comparing Vermont to control states (New Hampshire, other New England states without universal meals) before and after August 2022.

### Data Sources
- **NCES/Ed Data Express** chronic absenteeism data (state/district level, 2017-2024)
- **Return to Learn Tracker** (school district chronic absenteeism, 2016-2025)
- **FutureEd State Tracker** (state-level chronic absenteeism trends)
- **Vermont Agency of Education** (state-specific detailed data)

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Clear implementation date | Yes (SY 2022-23) |
| Geographic variation | Yes (Vermont vs. control states) |
| Data access | Yes (NCES, state agencies publicly available) |
| Novel | Moderate (some Vermont research exists, but causal identification limited) |
| Parallel trends plausible | Good (New England states similar demographics) |

### Concerns
- COVID recovery effects may confound results (post-pandemic attendance patterns)
- Selection of control states matters
- Existing research on universal meals generally, but Vermont-specific DiD may be novel

### Verdict: **PROMISING** - Clear policy variation, good data availability, timely topic

---

## Idea 3: Rhode Island Temporary Caregiver Insurance and Labor Market Outcomes

### Policy
- **Temporary Caregiver Insurance (TCI)** program
- **Effective Date:** January 5, 2014
- First state-level paid family leave program in the United States
- Provides partial wage replacement for employees caring for family members or new children
- Initially 4 weeks, expanded to 7 weeks (2025), scheduled for 8 weeks (2026)

### Research Question
Did Rhode Island's TCI program affect labor force participation, employment stability, or earnings, particularly for women?

### Method
**Synthetic Control Method** constructing a synthetic Rhode Island from donor pool of comparable states, OR **Difference-in-Differences** with carefully selected control states (Delaware, Connecticut before their programs).

### Data Sources
- **American Community Survey (ACS)** via IPUMS - labor force participation, employment by demographic
- **Current Population Survey (CPS)** - monthly labor force data
- **Bureau of Labor Statistics (BLS)** - state employment statistics
- **Rhode Island DLT** - program participation data

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Clear implementation date | Yes (January 5, 2014) |
| Geographic variation | Yes (RI vs. other states without paid leave at that time) |
| Data access | Yes (IPUMS API available) |
| Novel | Moderate (some studies exist, but long-term effects understudied) |
| Parallel trends plausible | Moderate (Northeast states with different policies) |

### Concerns
- 10+ years since implementation - effects may have dissipated or compounded
- Other states adopted similar policies since (contaminating control group over time)
- Existing literature on paid leave generally, but RI-specific long-term analysis may add value

### Verdict: **FEASIBLE** - Long time series, IPUMS access, first-in-nation provides clean identification

---

## Idea 4: Montana Permitless Carry Law and Violent Crime

### Policy
- **HB 102** - Permitless (Constitutional) Carry Law
- **Effective Date:** February 18, 2021
- Eliminated permit requirements for concealed carry
- Also eliminated gun-free zones including college campuses

### Research Question
Did Montana's permitless carry law affect violent crime rates?

### Method
**Difference-in-Differences with staggered adoption** - Montana adopted in Feb 2021; many other states adopted permitless carry at different times (29 states by 2025), enabling a staggered DiD design.

### Data Sources
- **FBI Uniform Crime Reports (UCR)** - state/county crime data
- **CDC WISQARS** - firearm injury and mortality data
- **Montana Board of Crime Control** - state-specific crime statistics

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Clear implementation date | Yes (February 18, 2021) |
| Geographic variation | Yes (staggered adoption across states) |
| Data access | Yes (FBI UCR publicly available) |
| Novel | Moderate (permitless carry studied, but Montana specifically may be novel) |
| Parallel trends plausible | Moderate (crime trends vary by state) |

### Concerns
- Politically contentious topic
- COVID-era crime changes may confound
- Substantial existing literature on right-to-carry laws
- UCR data quality issues (voluntary reporting)

### Verdict: **FEASIBLE BUT RISKY** - Data accessible but topic well-studied and politically sensitive

---

## Idea 5: Vermont Automatic Voter Registration and Electoral Participation

### Policy
- **Automatic Voter Registration (AVR)** at DMV
- **Effective Date:** January 2017
- Voters automatically registered when receiving/updating driver's license
- Vermont was among first states to implement AVR

### Research Question
Did Vermont's automatic voter registration increase voter registration rates and turnout, particularly among traditionally underrepresented groups?

### Method
**Difference-in-Differences** comparing Vermont to states without AVR before and after January 2017.

### Data Sources
- **Census Voting and Registration Supplement (CPS)** - turnout by demographics
- **Vermont Secretary of State** - voter registration data
- **Brennan Center for Justice** - AVR implementation data

### Feasibility Assessment
| Criterion | Assessment |
|-----------|------------|
| Clear implementation date | Yes (January 2017) |
| Geographic variation | Yes (Vermont vs. control states) |
| Data access | Yes (CPS public, state data available) |
| Novel | Limited (substantial existing research on AVR effects) |
| Parallel trends plausible | Moderate |

### Concerns
- Well-studied policy - Brennan Center and academics have published extensively
- Finding novel angle would be challenging

### Verdict: **LESS PROMISING** - Too much existing research for novel contribution

---

## Summary Rankings

| Rank | Idea | Novelty | Data | Identification | Overall |
|------|------|---------|------|----------------|---------|
| 1 | Montana Zoning Reform | High | Good | Strong (RDD) | **Top choice** |
| 2 | Vermont School Meals | Moderate | Good | Strong (DiD) | **Strong** |
| 3 | Rhode Island Paid Leave | Moderate | Good | Good (SCM) | **Strong** |
| 4 | Montana Permitless Carry | Low | Good | Good | Feasible |
| 5 | Vermont AVR | Low | Good | Good | Less promising |

## Recommendation

**Proceed with Idea 1 (Montana Zoning Reform)** as the primary research question. This offers:
- Highest novelty (cutting-edge housing policy, no existing research)
- Clean identification strategy (RDD at 5,000 population threshold OR DiD)
- Publicly accessible data (Census Building Permits Survey)
- Policy-relevant topic (housing affordability crisis)

**Backup: Idea 2 (Vermont School Meals)** if housing permit data proves insufficient for the short post-treatment window.
