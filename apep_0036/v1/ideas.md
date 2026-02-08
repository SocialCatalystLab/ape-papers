# Research Ideas: AI and Labor (RDD)

## Idea 1: Does Income Support Help Workers Escape Automation Risk? EITC Eligibility and Occupational Mobility at Age 25

**Policy:** Earned Income Tax Credit (EITC) age 25 eligibility threshold for childless workers. At age 24, childless workers are ineligible for EITC. At age 25, they become eligible for a credit of approximately $600 (2024).

**Outcome:** Labor market outcomes from the Current Population Survey (CPS):
- Employment and labor force participation
- Weekly hours worked
- Annual earnings
- **Occupational switching** (key outcome): transition out of high-automation occupations
- Industry switching

**Identification:** Regression discontinuity at age 25 for childless workers. Bandwidth of ±2-3 years around cutoff. Standard RDD validity checks (McCrary density test, covariate smoothness).

**Novel Contribution:** Prior research (Bastian & Jones, NBER WP 30632) found null average effects of EITC eligibility at age 25 on employment. However, no study has examined **heterogeneous effects by automation exposure**. Workers in high-automation-risk occupations may respond differently to income support:
- EITC could facilitate occupational transitions by providing income buffer during job search
- Workers in declining occupations may use EITC to fund retraining or reduce hours
- Alternatively, income effect could reduce labor supply, trapping workers in automation-exposed jobs

**Data:**
- CPS Annual Social and Economic Supplement (ASEC): age, presence of children, employment, earnings, detailed occupation codes (SOC)
- O*NET Work Context "Degree of Automation" and LMI Institute Automation Exposure Score (1-10 scale by occupation)
- Merge on SOC codes

**Feasibility:**
- ✓ CPS data publicly available via IPUMS (10+ years of data, ~200k observations per year)
- ✓ O*NET automation scores downloadable (Creative Commons license)
- ✓ Clear age discontinuity with minimal manipulation concerns
- ✓ Novel heterogeneity angle not previously studied
- ⚠ Small EITC amount (~$600) may limit effect size
- ⚠ Prior null findings mean effects may concentrate in heterogeneity

**Sample size estimate:** CPS ASEC has ~200k person records per year. Ages 23-27 (~5% of sample) = ~10k per year. Childless workers = ~40% = ~4k per year. With 10 years of data = ~40k observations around the discontinuity.

---

## Idea 2: WIOA Youth Program Eligibility and Labor Market Outcomes at Age 24

**Policy:** Workforce Innovation and Opportunity Act (WIOA) Out-of-School Youth programs: eligible if age 16-24, ineligible at age 25+. Provides job training, work experience, and support services.

**Outcome:** Employment, earnings, training participation, occupational upgrading (CPS)

**Identification:** RDD at age 24/25 boundary

**Complication:** EITC eligibility for childless workers begins at age 25, creating simultaneous treatment and control at the same threshold. Solutions:
1. Focus on workers WITH qualifying children (already EITC eligible) — isolates WIOA effect
2. Difference-in-discontinuities: compare discontinuity for workers with vs without children

**Novel Contribution:** WIOA age eligibility hasn't been studied with RDD. Interaction with automation exposure is completely novel.

**Data:** CPS + O*NET

**Feasibility:**
- ✓ Clear age threshold
- ✓ Data available
- ⚠ EITC confound requires careful handling
- ⚠ WIOA take-up not directly observed in CPS (reduced form only)

---

## Idea 3: Automation Exposure Threshold and Occupational Dynamics

**Policy/Treatment:** Occupational automation exposure score as a continuous treatment. Compare workers in occupations just above vs below the median automation exposure score (fuzzy RDD or dose-response).

**Outcome:** Occupational switching, wage growth, unemployment duration

**Identification:** Not a true policy RDD — more of a correlational design exploiting the continuous automation score. Could examine how labor market dynamics differ around key thresholds in automation exposure distribution.

**Limitations:**
- No exogenous policy variation
- Occupation selection is endogenous
- Would require careful selection controls

**Feasibility:** Lower priority — useful as sensitivity check but not primary identification.

---

## Recommendation

**Pursue Idea 1 (EITC × Automation Heterogeneity)** as the primary research question:
- Cleanest identification (sharp age discontinuity)
- Most novel contribution (heterogeneous effects by automation not studied)
- Policy relevance (EITC expansion for childless workers is active policy debate)
- Manageable data requirements

**Secondary:** Idea 2 could provide robustness check using different program threshold

---

## Key Literature

1. Bastian, J. & Jones, M. (2022). "Effects of the Earned Income Tax Credit for Childless Adults: A Regression Discontinuity Approach." NBER WP 30632. [Found null average effects]

2. Acemoglu, D. & Restrepo, P. (2020). "Robots and Jobs: Evidence from US Labor Markets." JPE. [Automation exposure methodology]

3. Webb, M. (2020). "The Impact of Artificial Intelligence on the Labor Market." Stanford working paper. [AI exposure measures]

4. Frey, C.B. & Osborne, M.A. (2017). "The Future of Employment." Technological Forecasting and Social Change. [Automation probability scores]

5. LMI Institute (2024). "Automation Exposure Score." [1-10 scale using O*NET data]
