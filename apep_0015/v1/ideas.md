# Research Ideas: Education Policy RDD Studies

**Assigned States:** Pennsylvania, Arizona, Wisconsin
**Method:** Regression Discontinuity Design (RDD)
**Topic Preference:** Education Policy

---

## Idea 1: Pennsylvania Act 101 Program and Educational Attainment

### Policy
Pennsylvania's Higher Education Equal Opportunity Act (Act 101), enacted in 1988, provides academic support services and financial assistance to economically and educationally disadvantaged students at Pennsylvania colleges and universities.

### RDD Threshold
Students must have family income at or below **200% of the Federal Poverty Level (FPL)** to be eligible. For 2024, this is approximately $62,400 for a family of four.

### Research Question
Does eligibility for Pennsylvania Act 101 program increase college completion rates and post-graduation earnings for students from disadvantaged backgrounds?

### Identification Strategy
- Running variable: Family income as a percentage of FPL
- Cutoff: 200% FPL
- Compare educational outcomes for students just above vs. just below the threshold
- Use Census PUMS data to construct income-to-FPL ratios and track educational attainment

### Expected Effect
Positive effect on degree completion and earnings due to enhanced academic support and financial assistance.

### Feasibility
- **Data:** Census PUMS provides income, poverty ratio (POVPIP), and educational attainment
- **Challenge:** Cannot directly observe Act 101 participation; use intent-to-treat design
- **Strength:** Sharp statutory threshold at 200% FPL

---

## Idea 2: Wisconsin GI Bill Dependent Education Benefits and the 30% Disability Threshold

### Policy
Wisconsin's state GI Bill (enacted 2005) provides full tuition remission at UW System and WTCS schools for dependents (children and spouses) of veterans with VA service-connected disability ratings of at least 30%.

### RDD Threshold
Dependents of veterans with **exactly 30% or higher** disability rating receive 100% tuition remission; those below 30% receive no dependent benefits.

### Research Question
Does access to free college tuition through Wisconsin's GI Bill increase educational attainment among children of disabled veterans?

### Identification Strategy
- Running variable: Veteran's VA disability rating percentage
- Cutoff: 30%
- Compare educational outcomes for children of veterans rated 30%+ vs. 20-29%
- Use Census PUMS to identify veteran households with service-connected disabilities in Wisconsin

### Expected Effect
Positive effect on college enrollment and completion for children of veterans above the threshold.

### Feasibility
- **Data:** PUMS identifies veteran households, service-connected disability, and children's education
- **Challenge:** PUMS reports any disability, not exact VA rating; may need fuzzy RDD or proxy approach
- **Strength:** Sharp discontinuity at 30% rating; large benefit (full tuition)

---

## Idea 3: Arizona Promise Program and Pell Grant Eligibility

### Policy
Arizona Promise Program (implemented 2018) guarantees that all tuition and fees are covered at Arizona's three public universities (ASU, UA, NAU) for Arizona residents who receive a federal Pell Grant.

### RDD Threshold
Students must receive a **federal Pell Grant** to qualify. Pell Grant eligibility depends on Student Aid Index (SAI), with maximum grants for SAI ≤ 0 and reduced grants for higher SAI values up to approximately $7,395.

### Research Question
Does the Arizona Promise Program's free tuition guarantee increase enrollment and completion at Arizona public universities for students near the Pell Grant eligibility threshold?

### Identification Strategy
- Running variable: Student Aid Index (SAI) or family income
- Cutoff: Pell Grant eligibility threshold (approximately $60,000-$65,000 AGI for family of 4)
- Compare enrollment and completion for students just above vs. just below Pell eligibility

### Expected Effect
Positive effect on Arizona public university enrollment and completion among newly Pell-eligible students.

### Feasibility
- **Data:** PUMS provides income, enrollment status, and institution type for Arizona residents
- **Challenge:** SAI not directly observed; use income as proxy for Pell eligibility
- **Strength:** Clear policy link between Pell receipt and Promise eligibility

---

## Idea 4: Pennsylvania Foster Care Education Benefits (Age 16 Threshold)

### Policy
Pennsylvania's Fostering Independence Tuition Waiver (FosterED, Act 16 of 2019) provides full tuition waivers at Pennsylvania colleges for youth who exited foster care at age 16 or older. Youth who achieved permanency (adoption/guardianship) before age 16 are ineligible.

### RDD Threshold
Youth must have been in foster care **at age 16 or older** when achieving permanency or aging out. Those who exit foster care before age 16 are ineligible.

### Research Question
Does eligibility for Pennsylvania's FosterED tuition waiver (conditional on exiting foster care at age 16+) increase college enrollment and completion among former foster youth?

### Identification Strategy
- Running variable: Age at foster care exit
- Cutoff: Age 16
- Compare educational outcomes for youth who exited foster care at 16+ vs. before 16
- Use PUMS or administrative data to identify foster youth populations

### Expected Effect
Positive effect on college enrollment and completion for youth who qualify for the waiver.

### Feasibility
- **Data:** Foster youth status not in standard PUMS; may need supplementary data sources
- **Challenge:** Identification of foster youth in survey data is difficult
- **Strength:** Sharp age discontinuity; substantial benefit (full tuition waiver)

---

## Idea 5: Wisconsin Bucky's Tuition Promise Income Threshold

### Policy
UW-Madison's Bucky's Tuition Promise (launched 2018) guarantees that tuition and fees are fully covered by grants and scholarships for Wisconsin resident students with household AGI of $65,000 or less.

### RDD Threshold
Students with household AGI at or below **$65,000** receive full tuition coverage; those above do not.

### Research Question
Does Bucky's Tuition Promise increase enrollment, retention, and completion at UW-Madison for students near the income threshold?

### Identification Strategy
- Running variable: Household adjusted gross income (AGI)
- Cutoff: $65,000
- Compare enrollment and retention for students just above vs. just below the threshold

### Expected Effect
Positive effect on UW-Madison enrollment and retention for newly eligible students.

### Feasibility
- **Data:** PUMS provides household income and enrollment status
- **Challenge:** Research by Dziesinski (2025) already examined retention effects; novelty limited
- **Strength:** Sharp income threshold; single institution focus allows clean identification

---

## Summary Ranking (Preliminary)

| Idea | Novelty | Data Feasibility | Threshold Sharpness | Recommended |
|------|---------|------------------|---------------------|-------------|
| 1. PA Act 101 | High | High | High | **PURSUE** |
| 2. WI GI Bill 30% | High | Medium | High | **PURSUE** |
| 3. AZ Promise/Pell | Medium | High | Medium | Consider |
| 4. PA FosterED | High | Low | High | Data constraint |
| 5. WI Bucky's Promise | Low | High | High | Already studied |

**Recommendation:** Proceed with Idea 1 (PA Act 101) or Idea 2 (WI GI Bill 30%) for maximum novelty and methodological rigor.
