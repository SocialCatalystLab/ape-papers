# Pre-Analysis Plan: Pennsylvania Fostering Independence Tuition Waiver and College Enrollment

**Study ID:** APEP-PA-FOSTERD-2026
**Date:** 2026-01-17
**Status:** Pre-registration (prior to data analysis)

---

## 1. Research Question

**Primary Question:** Did Pennsylvania's Fostering Independence Tuition Waiver (FosterED, Act 16 of 2019) increase college enrollment and educational attainment among former foster youth?

**Secondary Questions:**
1. Are effects concentrated among young adults aged 18-21 (most recently aged out of foster care)?
2. Do effects differ by gender, race/ethnicity, or urban/rural residence?
3. Is there evidence of spillover effects to states bordering Pennsylvania?

---

## 2. Policy Background

### Treatment Policy

**Pennsylvania Act 16 of 2019 (Fostering Independence Tuition Waiver / "FosterED")**:
- **Effective Date:** July 1, 2019 for academic year 2019-2020
- **Eligibility:** Youth who were in foster care at age 16 or older when achieving permanency (adoption, guardianship) or aging out
- **Benefit:** Full waiver of tuition and mandatory fees at Pennsylvania public and private postsecondary institutions
- **Duration:** Up to 5 years (need not be consecutive), or until age 26
- **Exclusions:** Youth who achieved permanency before age 16 are ineligible

### Theoretical Mechanism

Foster youth face substantial barriers to higher education: housing instability, financial constraints, lack of family support, and trauma history. The FosterED waiver removes direct cost barriers (tuition and fees), which should:
1. **Increase enrollment:** Lower price of college increases demand
2. **Improve persistence:** Reduced financial stress allows focus on academics
3. **Shift institution choice:** May redirect students toward public institutions with full coverage

---

## 3. Identification Strategy

### Ideal Design (Infeasible with Available Data)

The policy creates a sharp eligibility threshold at age 16: youth exiting foster care at age 16 or older qualify for the waiver, while those exiting before age 16 do not. An RDD using age at foster care exit as the running variable would provide clean causal identification.

**Data Constraint:** Census PUMS does not observe:
- Foster care history
- Age at foster care exit or permanency
- Exact eligibility for FosterED

### Implemented Design: Difference-in-Differences

Given data constraints, we implement a difference-in-differences (DiD) design comparing:
- **Treatment group:** Pennsylvania young adults ages 18-26 (the eligible age range for FosterED)
- **Control group:** Comparable young adults in neighboring states without equivalent programs (New York, New Jersey, Ohio, West Virginia)
- **Pre-period:** 2015-2018 (before Act 16)
- **Post-period:** 2020-2024 (after implementation; excluding 2019 as transition year)

### Key Identifying Assumption

**Parallel Trends:** Absent the FosterED policy, college enrollment trends among young adults in Pennsylvania would have evolved similarly to trends in control states.

### Threats to Identification

1. **Selection on observables:** Mitigated by controlling for demographics, economic conditions
2. **Confounding policies:** May coincide with other PA education policies
3. **COVID-19:** 2020-2021 affected all states; addressed via state-by-year fixed effects
4. **Small treatment population:** Foster youth are ~1% of population; expecting small aggregate effect

---

## 4. Data

### Primary Data Source

**American Community Survey (ACS) Public Use Microdata Sample (PUMS)**, 2015-2024

**Key Variables:**
- **Outcome:** SCH (school enrollment), SCHL (educational attainment)
- **Treatment Assignment:** ST (state) = Pennsylvania (42)
- **Post-Period Indicator:** YEAR >= 2020
- **Demographics:** AGEP, SEX, RAC1P, HISP, POVPIP, PUMA
- **Relationship:** RELSHIPP (can identify foster children currently in household)

### Sample Construction

1. Universe: Persons aged 18-26
2. Geographic scope: Pennsylvania and control states (NY, NJ, OH, WV)
3. Years: 2015-2024 (excluding 2019)
4. Weights: PWGTP (person weights)

### Proxy for Foster Youth Population

While we cannot directly identify former foster youth, we use two approaches:
1. **Intent-to-Treat (ITT):** Estimate effect on entire PA young adult population (diluted by non-foster youth majority)
2. **Subgroup Analysis:** Focus on populations with higher foster care prevalence:
   - Lower income (POVPIP < 200)
   - Non-relative household arrangements (RELSHIPP codes)
   - Previously institutional group quarters residents (where available)

---

## 5. Empirical Specification

### Primary Specification

$$Y_{ist} = \beta_0 + \beta_1 (PA_s \times Post_t) + \gamma_s + \delta_t + X_{ist}'\theta + \varepsilon_{ist}$$

Where:
- $Y_{ist}$: College enrollment indicator for individual $i$ in state $s$ at time $t$
- $PA_s$: Indicator for Pennsylvania
- $Post_t$: Indicator for years 2020 and later
- $\gamma_s$: State fixed effects
- $\delta_t$: Year fixed effects
- $X_{ist}$: Individual covariates (age, sex, race, poverty ratio)
- $\beta_1$: **DiD estimate** (primary coefficient of interest)

### Outcome Variables

| Variable | Definition | Coding |
|----------|------------|--------|
| `enrolled_college` | Currently enrolled in college | SCH == 1 & SCHG >= 15 |
| `any_college` | Has some college education | SCHL >= 18 |
| `bachelors` | Has bachelor's degree or higher | SCHL >= 21 |

### Heterogeneity Analysis

1. **By age group:** 18-21 vs. 22-26 (recent vs. older aging out)
2. **By income:** Below vs. above 200% FPL
3. **By race/ethnicity:** Black, Hispanic, White non-Hispanic
4. **By sex:** Male vs. Female

### Robustness Checks

1. **Event study:** Year-by-year treatment effects with 2018 as reference
2. **Placebo test:** Use 2015-2016 as "fake" treatment period
3. **Alternative controls:** Include only border counties
4. **Triple-difference:** Add foster child indicator (RELSHIPP) where available

---

## 6. Hypotheses and Expected Results

### Primary Hypothesis (H1)

**H1:** Pennsylvania's FosterED waiver increased college enrollment among young adults.

**Expected Sign:** Positive
**Expected Magnitude:** Small (0.5-2 percentage points) due to intent-to-treat dilution
**Statistical Threshold:** α = 0.05, two-tailed

### Heterogeneity Hypotheses

**H2:** Effects are larger for younger adults (18-21) who more recently aged out of foster care.

**H3:** Effects are larger for low-income populations where foster youth are concentrated.

---

## 7. Limitations

1. **Cannot identify foster youth directly:** ITT analysis dilutes treatment effect
2. **Treatment assignment imprecise:** PA residence is proxy for foster care in PA
3. **Control states may have partial programs:** Some may have smaller or different waivers
4. **COVID-19 confounding:** 2020-2021 severely disrupted higher education
5. **Migration:** Foster youth may leave PA; PA college students may be from other states

---

## 8. Analysis Timeline

1. Fetch ACS PUMS data for PA and control states (2015-2024)
2. Construct analysis sample and variables
3. Estimate primary DiD specification
4. Conduct heterogeneity analysis
5. Run robustness checks (event study, placebo)
6. Generate figures and tables
7. Write paper

---

## 9. Pre-Registration Commitment

This pre-analysis plan specifies the primary hypothesis, specification, and outcome variables before data analysis begins. Deviations from this plan will be clearly documented and labeled as exploratory.

**Checksum will be generated upon lock.**
