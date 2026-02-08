# Paper 44: Research Ideas

**Generated:** 2026-01-19
**Method:** Difference-in-Differences (staggered adoption)

---

## Idea 1: Financial Literacy Graduation Requirements and Long-Run Labor Market Outcomes

### Policy
State mandates requiring personal finance or financial literacy courses as a high school graduation requirement.

### Variation
- **First adopter:** Utah (2008)
- **Current count:** 29 states by 2025
- **Key adopters:** Utah (2008), Virginia (2011), Alabama (2013), Texas (2014), Missouri (2016), Georgia (2020), Florida (2027 implementation)
- **Staggered adoption:** Clear variation in timing across 15+ years

### Research Question
Do state financial literacy graduation requirements improve long-run employment outcomes and earnings for exposed cohorts?

### Outcomes (via IPUMS ACS/CPS)
- Employment rate (EMPSTAT)
- Weeks worked (WKSWORK1/2)
- Usual hours worked (UHRSWORK)
- Wage/salary income (INCWAGE)
- Self-employment status (CLASSWKR)
- Educational attainment (EDUC)

### Identification Strategy
Cohort-based DiD: Compare labor market outcomes for cohorts who graduated after state adoption vs. cohorts who graduated before, relative to never-treated states. Use birth year × state of birth to assign treatment status.

### Data Feasibility
- **Source:** IPUMS ACS (2005-2024) or CPS ASEC
- **Sample:** Adults 18-30 by birth cohort and state of residence at age 18
- **Clusters:** 50 states → robust inference

### Novelty Assessment
**HIGH.** Existing research focuses on financial outcomes (credit scores, student loan decisions, payday loan avoidance). Limited rigorous evidence on employment/earnings effects.

### Concerns
- **Lag time:** Affected cohorts are still young; may need to focus on early career outcomes
- **Treatment intensity:** Some states require standalone course vs. integration into existing curriculum
- **Pre-trends:** Early adopters (Utah, Virginia) may differ systematically from late adopters

### Preliminary Verdict: PURSUE

---

## Idea 2: Salary History Bans and Job Tenure / Occupational Mobility

### Policy
State laws prohibiting employers from asking job applicants about their prior salary history during hiring.

### Variation
- **First adopter:** Massachusetts (2016), effective 2018
- **Current count:** 20 states + DC
- **Key adopters:** MA (2018), CA (2018), NY (2017), NJ (2020), CO (2021), WA (2019)
- **Clear treatment dates:** Laws specify effective dates for compliance

### Research Question
Do salary history bans affect job tenure, turnover rates, and occupational mobility—beyond their documented effects on wages?

### Outcomes (via IPUMS CPS Job Tenure Supplement)
- Job tenure in years (JTYEARS)
- Occupation change from prior year (JTOCC)
- Industry change (JTIND)
- Reason for job change
- Employer change rates

### Identification Strategy
Standard two-way fixed effects DiD with state and year FE. Compare job tenure and mobility for workers in treated states before/after adoption vs. untreated states. Use Callaway-Sant'Anna or Sun-Abraham for heterogeneous treatment effects.

### Data Feasibility
- **Source:** IPUMS CPS Job Tenure Supplement (biennial since 1996; available for 2018, 2020, 2022, 2024)
- **Sample:** Employed workers age 16+
- **Clusters:** 20 treated states + 30 control states

### Novelty Assessment
**MODERATE-HIGH.** Extensive research on wage effects (Barach & Horton 2021, Bessen et al. 2020). Job tenure and mobility are understudied outcomes.

### Concerns
- **Power:** CPS supplement is biennial with ~60,000 respondents; subgroup analyses may be underpowered
- **Timing:** Only 3-4 post-treatment supplements available for early adopters
- **Compliance:** Difficult to verify employer compliance; may underestimate true effects

### Preliminary Verdict: PURSUE (with power analysis caveat)

---

## Idea 3: Non-Compete Agreement Restrictions and Self-Employment/Entrepreneurship

### Policy
State laws restricting or prohibiting non-compete agreement (NCA) enforcement in employment contracts.

### Variation
- **Complete bans:** California (historical), Oklahoma (historical), North Dakota (historical), Minnesota (2023)
- **Partial restrictions:** 33 states have some form of restriction (wage thresholds, duration limits, occupation-specific bans)
- **Recent reforms:** Oregon (2008 hourly workers), Massachusetts (2018 expansion), Washington (2020), DC (2021)

### Research Question
Do state restrictions on non-compete enforcement increase self-employment rates and new business formation?

### Outcomes (via IPUMS ACS)
- Self-employment status (CLASSWKR = self-employed)
- Incorporated vs. unincorporated self-employment
- Self-employment income (INCEARN where CLASSWKR = self-employed)
- Industry of self-employment (IND)
- Occupation of self-employment (OCC)

### Identification Strategy
Event-study DiD around state NCA reforms. Compare self-employment rates in reform states before/after vs. non-reform states. Focus on occupations with high baseline NCA prevalence (tech, sales, professional services).

### Data Feasibility
- **Source:** IPUMS ACS (2005-2024), 1% sample annually
- **Sample:** Working-age adults 25-64
- **Clusters:** 33+ states with variation; 50 states total

### Novelty Assessment
**MODERATE.** Research exists on wages (Marx et al. 2015) and job mobility (Starr et al. 2019). Self-employment/entrepreneurship channel is theoretically important but less rigorously studied with DiD.

### Concerns
- **Heterogeneous policies:** Different states have different restrictions (wage thresholds vary widely)
- **Enforcement vs. law:** California has long banned NCAs but tech firms use other mechanisms
- **Treatment coding:** Need careful documentation of what exactly changed and when

### Preliminary Verdict: PURSUE (requires careful treatment definition)

---

## Idea 4: Extended Foster Care Eligibility and Youth Employment Outcomes

### Policy
Fostering Connections to Success Act (2008) gave states the option to extend Title IV-E federal foster care eligibility from age 18 to 21.

### Variation
- **Federal enabling:** 2008
- **Early adopters:** California, Illinois, New York (2010-2012)
- **Later adopters:** Staggered across ~30 states by 2020
- **Never adopters:** Several states still cap at 18

### Research Question
Does extending foster care eligibility to age 21 improve employment outcomes for foster youth in their early 20s?

### Outcomes (via IPUMS CPS/ACS)
- Employment status (EMPSTAT)
- Labor force participation
- Earnings (INCEARN)
- Poverty status (POVERTY)
- Living arrangement (independent vs. group quarters)

### Identification Strategy
DiD comparing employment outcomes for 19-24 year-olds in states that adopted extended care vs. non-adopting states, before and after adoption.

### Data Feasibility
- **Source:** IPUMS ACS or CPS
- **Challenge:** Cannot directly identify foster youth in public use microdata
- **Workaround:** Use age × state × year to estimate intent-to-treat effects on general youth population, or proxy with demographic indicators (group quarters, institutional history)

### Novelty Assessment
**MODERATE.** Some DiD research exists on homelessness (Courtney et al. 2024) and education outcomes. Employment outcomes studied but often with program-level data rather than population-level microdata.

### Concerns
- **Identification:** Cannot directly identify foster youth in ACS/CPS
- **Small affected population:** ~400,000 youth in foster care nationally; state-level samples may be very small
- **Intent-to-treat dilution:** Effects averaged over entire youth population will be small
- **First-stage evidence:** Need to show foster care utilization actually increased

### Preliminary Verdict: CONSIDER (identification challenges may be prohibitive)

---

## Summary Assessment

| Idea | States | Data | Novelty | Power | Verdict |
|------|--------|------|---------|-------|---------|
| 1. Financial Literacy | 29 | IPUMS ACS | HIGH | Strong | **PURSUE** |
| 2. Salary History Bans | 20 | CPS Job Tenure | MOD-HIGH | Moderate | **PURSUE** |
| 3. Non-Compete Restrictions | 33 | IPUMS ACS | MODERATE | Strong | **PURSUE** |
| 4. Extended Foster Care | ~30 | IPUMS ACS | MODERATE | Weak | CONSIDER |

**Recommended:** Ideas 1 or 3 offer the best combination of novelty, geographic variation, and data availability.
