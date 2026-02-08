# Research Ideas — Paper 65

## Idea 1: Transit Funding Discontinuity: The Effect of Urbanized Area Designation on Public Transportation Access and Employment

**Policy:** Federal Transit Administration's Urbanized Area Formula Funding Program (49 U.S.C. 5307) — areas with population ≥50,000 qualify as "urbanized" and become eligible for dedicated federal transit capital and operating assistance. The threshold creates a sharp discontinuity in transit funding eligibility.

**Outcome:** Labor market outcomes (employment, commute times, car ownership) for residents of areas near the 50,000 population threshold. Data from ACS PUMS with geographic identifiers to identify residents near threshold.

**Identification:** RDD using Census-measured population relative to the 50,000 threshold. Population is determined by decennial census, creating exogenous variation since the exact boundary of urbanized areas is determined by Census Bureau algorithms, not local manipulation. Areas just below 50,000 lack federal transit formula funding; areas just above receive it.

**Why it's novel:** While metropolitan statistical area thresholds have been discussed conceptually, there is no published RDD study specifically examining how crossing the 50,000 urbanized area threshold affects local transit availability and subsequent labor market outcomes. The 2020 Census urbanized area redesignation creates a new cohort of areas crossing the threshold.

**Feasibility check:**
- Variation exists: Dozens of urban areas cluster near the 50,000 threshold
- Data accessible: ACS PUMS provides individual-level data with PUMA geographic identifiers; Census urbanized area boundary files are public
- Not overstudied: Novel application
- Challenge: Need to link PUMA geography to urbanized area boundaries

---

## Idea 2: The Credit CARD Act and Young Adult Financial Behavior: An RDD at Age 21

**Policy:** Credit Card Accountability Responsibility and Disclosure Act of 2009 — individuals under age 21 cannot obtain a credit card without either (a) a cosigner or (b) documented independent income to repay. At exactly age 21, this restriction lifts and young adults gain unrestricted credit card access.

**Outcome:** Credit card ownership, credit utilization, credit scores, and financial distress (delinquency, collections). Secondary outcomes: consumption patterns, labor supply responses.

**Identification:** RDD at age 21 birthday. The policy creates a sharp discontinuity in credit access. Individuals just under 21 face barriers; those just over 21 have unrestricted access. Running variable is age in months/days relative to 21st birthday.

**Why it's novel:** Debbaut, Ghent, and Kudlyak (2016) studied the CARD Act using difference-in-differences comparing cohorts before/after implementation. However, there is limited RDD research exploiting the *ongoing* age-21 discontinuity post-implementation to study how crossing that birthday affects credit behavior and downstream outcomes. The age threshold creates a sharp, ongoing discontinuity suitable for RDD.

**Feasibility check:**
- Variation exists: Sharp policy discontinuity at age 21
- Data accessible: IPUMS CPS has age and credit-related variables; Federal Reserve's Survey of Consumer Finances; potentially CFPB public datasets
- Not overstudied: Existing research used DiD; RDD on ongoing age threshold less explored
- Challenge: Finding individual-level credit data with precise age is difficult; may need to use CPS/ACS proxies (credit card debt questions)

---

## Idea 3: WIC Aging Out and Child Nutrition: RDD at Age 5

**Policy:** Special Supplemental Nutrition Program for Women, Infants, and Children (WIC) — children lose WIC eligibility in the month following their 5th birthday. This creates a sharp discontinuity in nutritional assistance.

**Outcome:** Household food security, child diet quality, BMI, and healthcare utilization for children near age 5.

**Identification:** RDD using age in months relative to 5th birthday. Children just under 5 receive WIC benefits; those just over 5 lose eligibility (unless they enroll in school meals, which has different eligibility).

**Why it's novel:** Smith (2024, American Journal of Agricultural Economics) studied WIC aging out effects on diet quality. However, the labor market implications for parents (particularly mothers) of losing WIC support at age 5 have not been examined. Does losing food assistance affect maternal employment as mothers must either earn more to replace food support or work less to prepare more food at home?

**Feasibility check:**
- Variation exists: Sharp eligibility cutoff at age 5
- Data accessible: CPS Food Security Supplement, NHANES for diet/health data
- Partially studied: Diet effects examined (Smith 2024); maternal labor supply effects are novel
- Challenge: Concurrent kindergarten enrollment complicates clean identification

---

## Idea 4: Federal Student Loan Limits and College Completion: RDD at the Dependent/Independent Threshold

**Policy:** Federal student loan annual and aggregate limits differ for dependent vs. independent undergraduate students. Independent students can borrow up to $57,500 total ($9,500-$12,500/year) while dependent students are limited to $31,000 total ($5,500-$7,500/year). Students automatically become independent at age 24.

**Outcome:** College enrollment persistence, time to degree, degree completion, student debt levels, and post-graduation earnings.

**Identification:** RDD at age 24. Students who turn 24 before December 31 of the award year are classified as independent and gain access to higher loan limits without needing parental information on FAFSA.

**Why it's novel:** Denning (2018) examined the age-24 threshold but focused on Pell Grant eligibility effects, not the differential loan limits. The loan limit discontinuity creates a different margin — students from middle-income families who don't qualify for Pell but face credit constraints may benefit from higher borrowing limits. This is unexplored territory.

**Feasibility check:**
- Variation exists: Sharp discontinuity at age 24 for loan limits
- Data accessible: IPUMS Higher Ed, NPSAS (restricted), College Scorecard for institutional outcomes
- Partially studied: Denning (2018) studied Pell effects at this threshold; loan limit effects not examined
- Challenge: Distinguishing loan limit effects from Pell eligibility effects requires careful design

---

## Idea 5: OSHA Electronic Recordkeeping Threshold and Workplace Safety: RDD at 100 Employees

**Policy:** As of January 2024, establishments with 100+ employees in high-hazard industries must electronically submit detailed injury/illness records (Forms 300 and 301) to OSHA. Establishments with 20-99 employees only submit summary data (Form 300A). This creates a discontinuity in reporting requirements and associated regulatory scrutiny.

**Outcome:** Workplace injury rates, workers' compensation claims, and firm safety investments.

**Identification:** RDD using establishment size relative to the 100-employee threshold. Establishments just below 100 face lighter reporting requirements; those at or above 100 face enhanced scrutiny. The threshold is based on peak employment in the prior calendar year.

**Why it's novel:** This rule took effect January 1, 2024 — very recent. No published research examines the causal effect of enhanced electronic reporting requirements on workplace safety outcomes. The 100-employee threshold creates sharp variation in regulatory burden.

**Feasibility check:**
- Variation exists: Sharp threshold at 100 employees
- Data accessible: BLS Injuries, Illnesses, and Fatalities data; state workers' compensation data
- Not overstudied: Rule is only 2 years old
- Challenge: Need firm-level injury data with establishment size; BLS Survey of Occupational Injuries and Illnesses may have this

---

## Summary Ranking

| Idea | Novelty | Data Access | Clean Threshold | Overall |
|------|---------|-------------|-----------------|---------|
| 1. Transit/Urbanized Area | High | Medium | High | Strong |
| 2. CARD Act Age 21 | Medium | Low | High | Medium |
| 3. WIC Age 5 (maternal LFP) | Medium | High | High | Strong |
| 4. Loan Limits Age 24 | High | Medium | High | Strong |
| 5. OSHA 100 Employees | High | Medium | Medium | Medium |

**Recommended:** Ideas 1, 3, or 4 for their combination of novelty and data feasibility.
