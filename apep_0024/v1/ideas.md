# Research Ideas: RDD Studies in Washington, Wyoming, Wisconsin

**Assigned States:** Washington, Wyoming, Wisconsin
**Method:** Regression Discontinuity Design (RDD)
**Preferences:** Maximum novelty + High feasibility
**Date:** January 18, 2026

---

## Idea 1: Wyoming's Zero Income Tax Border and High-Earner Location Decisions

**Policy:** Wyoming is one of only seven states with no individual income tax, while its neighbors Montana (graduated rates up to 6.75%) and Colorado (flat 4.4%) levy substantial income taxes. This creates a sharp geographic discontinuity at the state border.

**RDD Design:** Geographic regression discontinuity using distance to state border as the running variable. Compare labor market outcomes and residential sorting for individuals living just inside Wyoming versus just inside Montana/Colorado.

**Key Threshold:** State border (distance = 0)

**Hypothesis:** High-income earners strategically locate in Wyoming to avoid state income taxes, leading to sorting by income at the border. This may manifest as:
- Higher average incomes in Wyoming border PUMAs
- Differential migration patterns (net in-migration to WY for high earners)
- Cross-border commuting from Wyoming into Montana/Colorado jobs

**Data:** Census ACS PUMS 2015-2023 with PUMA geography. Wyoming shares borders with Montana (Park, Carbon, Big Horn counties) and Colorado (Laramie County/Cheyenne area). Wyoming's PUMAs can be matched to border proximity.

**Novelty:** While state tax competition literature exists, geographic RDD at no-income-tax borders is understudied. Wyoming's extreme case (0% vs 4-7%) provides sharp discontinuity. Most research focuses on New York-Florida migration, not Rocky Mountain borders.

**Feasibility:** HIGH. PUMS provides income, employment, and migration data at PUMA level. Wyoming has PUMAs near both borders. Border counties are identifiable.

---

## Idea 2: Wisconsin BadgerCare 100% FPL Cliff and Labor Supply Distortions

**Policy:** Wisconsin uniquely rejected ACA Medicaid expansion but covers adults up to 100% of the Federal Poverty Level (FPL) through BadgerCare. Adults above 100% FPL must purchase insurance on the exchange (often with substantial subsidies, but different coverage). This creates a sharp eligibility cliff at exactly 100% FPL.

**RDD Design:** Income-based regression discontinuity at 100% FPL threshold. Compare labor supply, hours worked, and employment outcomes for individuals just below versus just above 100% FPL in Wisconsin.

**Key Threshold:** 100% Federal Poverty Level (e.g., $15,060 for single individual in 2024)

**Hypothesis:** The 100% FPL cliff creates notch-like incentives:
- Workers may reduce hours/earnings to stay below threshold ("benefit cliff")
- Alternatively, the smooth ACA subsidy phase-out above 100% may mitigate bunching
- Wisconsin's unusual partial expansion (unique among non-expansion states) creates clean test of this cliff

**Data:** Census ACS PUMS 2014-2023. Wisconsin implemented current policy in 2014. Can identify individuals near 100% FPL threshold using income/poverty ratio variable in PUMS.

**Novelty:** Wisconsin is the ONLY state that covers adults to exactly 100% FPL without full ACA expansion. This creates a natural experiment unavailable elsewhere. Most Medicaid cliff research focuses on traditional categorical eligibility (pregnant women, children) or expansion states.

**Feasibility:** HIGH. PUMS includes poverty ratio variable (POVPIP), health insurance coverage (HICOV, HINS1-HINS7), and employment variables. Sample sizes at threshold may require pooling multiple years.

---

## Idea 3: Washington Cannabis Legalization Age 21 Threshold and Young Adult Employment

**Policy:** Washington legalized recreational cannabis for adults age 21+ in December 2012 (I-502), becoming one of the first two states to do so. The age 21 threshold creates a sharp discontinuity in legal access.

**RDD Design:** Age-based regression discontinuity using age (in months) as the running variable. Compare employment outcomes for individuals just above versus just below age 21 in Washington post-legalization, relative to control states.

**Key Threshold:** Age 21 (with precision to birth month in PUMS)

**Hypothesis:** Legal cannabis access at 21 may affect labor market outcomes through:
- Direct consumption effects on productivity/motivation (negative)
- Reduced criminal justice contact for 21+ users (positive)
- Labor supply shifts toward/away from cannabis industry employment
- Comparison to states without legalization isolates Washington-specific effect

**Data:** Census ACS PUMS 2013-2023 (post-legalization period). PUMS includes age at interview and state of residence. Can use birth cohort to identify those "just" turning 21 at legalization versus "just" missing threshold.

**Novelty:** Most cannabis research uses state-level DiD designs. Age-based RDD exploiting the 21 threshold is underutilized. Washington's early adoption (2012) provides longest time series. Combined with first-state novelty, this is fresh territory.

**Feasibility:** MEDIUM-HIGH. Age available in PUMS. Challenge: PUMS reports age in years, not months, limiting running variable precision. Can use quarter of birth (QUARTER variable) if available, or treat as fuzzy RDD. Large sample sizes in Washington.

---

## Idea 4: Wyoming Rule of 85 Pension Threshold and Public Employee Retirement Timing

**Policy:** Wyoming public employees qualify for unreduced pension benefits when age + years of service = 85 (the "Rule of 85"). Workers reaching this threshold face a sharp discontinuity in retirement incentives - continuing to work provides no additional pension benefit per year of service.

**RDD Design:** Kink-based RDD at the Rule of 85 threshold. Compare retirement hazard rates for workers just reaching 85 versus those just below. The running variable is (age + years of service - 85).

**Key Threshold:** Age + Years of Service = 85

**Hypothesis:** Workers bunch at the Rule of 85 threshold, retiring immediately upon reaching eligibility. Effects should be strongest for:
- Teachers (largest public employee group)
- Workers who started careers early (e.g., career at 25 = retire at 55 with 30 years)
- Tier 1 employees (pre-September 2012 hires) who face age 60 baseline

**Data:** Census ACS PUMS 2005-2023. Identify Wyoming public sector workers (industry codes for public administration, education). Approximate "years of service" using work experience proxies. Challenge: PUMS doesn't directly report pension eligibility.

**Novelty:** Pension rule-of-85 designs exist but are usually applied to administrative pension records (e.g., CalPERS). Using PUMS to study retirement bunching at this threshold in Wyoming specifically is novel. Wyoming's dependence on public sector employment (given small private sector) makes effects more detectable.

**Feasibility:** MEDIUM. Main limitation: PUMS doesn't report years of service or pension plan membership. Must use proxies (potential experience = age - education - 6). Identification relies on public sector workers in Wyoming who are near typical Rule of 85 range (age 50-65 with 20-35 years).

---

## Idea 5: Washington's WA Cares Veteran 70% Disability Exemption and Labor Supply

**Policy:** Washington's WA Cares Fund (long-term care payroll tax of 0.58%) exempts veterans with a VA service-connected disability rating of 70% or higher. This creates a sharp discontinuity at the 70% disability rating threshold.

**RDD Design:** Disability rating-based RDD using VA disability percentage as running variable. Compare labor supply and earnings for veterans rated just above versus just below 70%.

**Key Threshold:** 70% VA disability rating

**Hypothesis:** The 70% threshold creates differential labor supply incentives:
- Below 70%: Subject to 0.58% payroll tax on all earnings
- At/above 70%: Exempt from payroll tax (permanent exemption)
- This may affect labor supply at the margin, particularly for veterans with high earnings potential

**Data:** Census ACS PUMS 2008-2023. PUMS includes veteran status and service-connected disability status since 2008. Challenge: PUMS may not report exact disability rating percentage (typically reports binary disability status or rating categories).

**Novelty:** The WA Cares veteran exemption is very new (effective 2023 exemption availability) and entirely unstudied. The 70% threshold is a key VA disability milestone (qualifies for additional benefits like nursing home care). This intersection of veteran policy and state payroll tax is unique.

**Feasibility:** LOW-MEDIUM. Main limitation: Unclear if PUMS reports granular disability ratings (need to verify). The policy is also very new, limiting post-treatment data. May be better as a pre-registration for future study.

---

## Summary Ranking

| Idea | Novelty | Feasibility | RDD Quality | Recommendation |
|------|---------|-------------|-------------|----------------|
| 1. Wyoming No-Tax Border | HIGH | HIGH | Strong geographic disc. | **PURSUE** |
| 2. Wisconsin 100% FPL Cliff | HIGH | HIGH | Sharp income threshold | **PURSUE** |
| 3. Washington Cannabis Age 21 | MEDIUM-HIGH | MEDIUM-HIGH | Sharp age threshold | PURSUE |
| 4. Wyoming Rule of 85 | MEDIUM | MEDIUM | Kink-based RDD | Consider |
| 5. WA Cares Veteran 70% | HIGH | LOW-MEDIUM | Sharp if data allows | Monitor |

**Top Recommendation:** Ideas 1 and 2 offer the best combination of novelty and feasibility. The Wisconsin BadgerCare 100% FPL cliff is particularly compelling as Wisconsin is literally the only state with this exact policy design, creating a unique natural experiment unavailable anywhere else in the United States.
