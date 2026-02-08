# Research Ideas

Generated after exploration phase for assigned states: **Missouri (MO), Hawaii (HI), Utah (UT)**.

Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Hawaii Kupuna Caregivers Program and Caregiver Employment

**Policy:** Hawaii's Kupuna Caregivers Program (2017) - the first state program in the nation providing financial assistance ($70/day, later $210/week) to employed caregivers of elderly relatives. Requires caregiver to work at least 30 hours/week to be eligible.

**Method:** DiD

**Research Question:** Did Hawaii's Kupuna Caregivers Program reduce labor force exit among working-age adults with elderly co-residents, compared to similar caregivers in other states?

**Data:**
- Source: Census PUMS 2015-2022 (multi-year)
- Key variables: ESR (employment status), WKHP (hours worked), ST (state), AGEP (age), RELSHIPP (relationship), PWGTP (person weight)
- Sample: Adults aged 30-64 with elderly household members (65+) in the household, comparing Hawaii to control states
- Sample size estimate: ~2,000-3,000 Hawaii observations per year; ~100,000 control group observations

**Hypotheses:**
- Primary: The program increased labor force participation among caregivers by 2-4 percentage points
- Mechanism: Financial support for respite care reduces the need to exit workforce to provide full-time care
- Heterogeneity: Effect should be strongest among women, middle-income earners, and households with older elderly (75+)

**Novelty:**
- Literature search: Found only 1 policy analysis thesis (McCarthy 2018, UKY). No causal inference studies identified. Searches for "Kupuna Caregivers causal effect" and "Hawaii caregiver employment study" yielded no peer-reviewed empirical papers.
- Gap: No rigorous causal evaluation of this first-in-nation program exists
- Contribution: First DiD analysis of a state caregiver support program's labor market effects

---

## Idea 2: Utah Universal License Recognition and Interstate Migration of Licensed Workers

**Policy:** Utah's Universal License Recognition law (2019) - allows workers with valid occupational licenses from other states to practice in Utah without re-licensing. Utah was among the first states to adopt this reform without requiring "substantial equivalence."

**Method:** DiD

**Research Question:** Did Utah's universal license recognition law increase in-migration of licensed professionals and improve employment outcomes for movers?

**Data:**
- Source: Census PUMS 2016-2022
- Key variables: ST (state), MIG (migration status), MIGSP (migration from state), ESR (employment), WAGP (wages), OCCP (occupation), PWGTP
- Sample: Workers in licensed occupations (nurses, teachers, cosmetologists, etc.) who migrated across state lines
- Sample size estimate: ~500-1,000 movers into Utah per year; larger control pool of movers to non-ULR states

**Hypotheses:**
- Primary: In-migration of licensed workers to Utah increased by 15-25% relative to control states
- Mechanism: Reduced barriers to entry make Utah more attractive destination for licensed workers seeking to relocate
- Heterogeneity: Effect should be largest for occupations with most burdensome re-licensing requirements

**Novelty:**
- Literature search: Found 2-3 papers on ULR (Bae & Timmons 2023 at WVU, Archbridge Institute reports). These use ACS and find positive effects but don't focus specifically on Utah or use PUMS microdata.
- Gap: No paper uses PUMS to examine individual-level outcomes for Utah specifically
- Contribution: Person-level analysis of migration and employment outcomes for a leading ULR state

---

## Idea 3: Missouri Minimum Wage Phase-In and Low-Wage Employment

**Policy:** Missouri's Proposition B (2018) - voter-approved minimum wage increases from $7.85 in 2018 to $12.00 by 2023 in annual increments ($8.60, $9.45, $10.30, $11.15, $12.00).

**Method:** DiD

**Research Question:** What was the effect of Missouri's 2018-2023 minimum wage increases on employment and hours worked among low-wage workers?

**Data:**
- Source: Census PUMS 2016-2023
- Key variables: ST (state), WAGP (wages), WKHP (hours worked), ESR (employment), PWGTP, AGEP, SCHL (education), INDP (industry)
- Sample: Low-education workers (high school or less) aged 16-64 in Missouri vs neighboring states (KS, NE, IA, IL, KY, TN, AR, OK)
- Sample size estimate: ~10,000 low-education Missouri workers per year; ~50,000 in control states

**Hypotheses:**
- Primary: The minimum wage increases raised wages for affected workers with minimal disemployment effects (-1 to -2 percentage points at most)
- Mechanism: Wage floors compress the low end of the distribution; firms adjust through prices, productivity, or reduced hours rather than layoffs
- Heterogeneity: Effects concentrated in retail, food service, and accommodation industries

**Novelty:**
- Literature search: Minimum wage literature is extensive (Neumark & Shirley 2022 review). Missouri-specific studies are limited to policy briefs (NELP, EPI). No peer-reviewed DiD study specifically on Missouri's 2018 phase-in using PUMS microdata.
- Gap: Missouri's staggered phase-in creates a cleaner identification than cross-sectional state comparisons
- Contribution: State-specific analysis of a large, multi-year minimum wage reform with detailed worker outcomes

---

## Idea 4: Hawaii Prepaid Health Care Act 20-Hour Threshold

**Policy:** Hawaii's Prepaid Health Care Act (1974) - requires employers to provide health insurance to employees working 20+ hours/week for 4+ consecutive weeks. This is unique to Hawaii (federal ACA threshold is 30 hours).

**Method:** RDD

**Research Question:** Does Hawaii's lower employer health insurance mandate threshold (20 hours vs. 30 hours federally) create bunching in work hours just below 20, and does this threshold affect health insurance coverage?

**Data:**
- Source: Census PUMS 2015-2022
- Key variables: ST (state), WKHP (usual hours worked), HINS1-HINS4 (health insurance), ESR, PWGTP
- Sample: Hawaii workers compared to workers in states with only the 30-hour ACA threshold
- Sample size estimate: ~15,000-20,000 Hawaii workers per year; running variable is weekly hours

**Hypotheses:**
- Primary: There is a discontinuity in hours distribution at 20 hours in Hawaii (bunching just below) not present in other states
- Mechanism: Employers avoid mandate costs by scheduling workers under 20 hours
- Heterogeneity: Effect strongest in industries with high part-time prevalence (retail, food service)

**Novelty:**
- Literature search: Found Buchmueller & Valletta (2009, IZA) studying Hawaii using CPS and DiD/permutation tests. They found evidence of hours bunching but did not use RDD design or PUMS data.
- Gap: No RDD analysis exploiting the 20-hour discontinuity directly
- Contribution: First RDD on Hawaii's unique health insurance threshold using PUMS microdata

---

## Idea 5: Utah Medicaid Expansion and Labor Supply at the 138% FPL Threshold

**Policy:** Utah's ACA Medicaid Expansion (January 2020) - expanded eligibility to adults under 65 with incomes up to 138% of the Federal Poverty Level. Utah also uniquely requires beneficiaries to enroll in employer-sponsored insurance if available.

**Method:** RDD

**Research Question:** Does Medicaid eligibility at the 138% FPL threshold affect labor supply decisions (employment, hours worked) for adults near the income cutoff in Utah?

**Data:**
- Source: Census PUMS 2018-2022
- Key variables: ST (state), PINCP (personal income), POVPIP (income-to-poverty ratio), ESR, WKHP, HINS4 (Medicaid coverage), PWGTP
- Sample: Adults aged 19-64 in Utah with incomes between 50% and 200% FPL
- Sample size estimate: ~3,000-5,000 near-threshold observations per year

**Hypotheses:**
- Primary: Labor supply shows no sharp discontinuity at 138% FPL threshold (income effect dominates substitution effect)
- Mechanism: Health insurance expansion may reduce "job lock" but also creates notch where losing eligibility could reduce work incentives
- Heterogeneity: Effects may differ for those with vs. without employer-sponsored insurance options

**Novelty:**
- Literature search: Medicaid expansion literature is extensive (Finkelstein et al., Miller et al.). Utah-specific analysis is limited. Utah's unique ESI enrollment requirement is unstudied.
- Gap: Utah's 2020 expansion with work-related requirements creates unique research opportunity
- Contribution: RDD analysis of labor supply effects in a state with employer-sponsored insurance coordination

---

## Exploration Notes

**Assigned states:** Missouri (MO), Hawaii (HI), Utah (UT)

**Search strategy:**
1. State-specific policy searches (unique laws, recent reforms)
2. Domain searches (occupational licensing, minimum wage, health insurance, caregiving)
3. NBER/academic literature checks for novelty assessment

**Considered and rejected:**
- Missouri Right-to-Work Proposition A (2018): The measure was *rejected* by voters, so there's no treatment to study
- Missouri ban-the-box (St. Louis, 2021): Already well-studied (Doleac & Hansen, Agan & Starr); local ordinance limits PUMS geographic precision
- Utah intergenerational poverty initiative: Program design doesn't have clean thresholds; more of a tracking/coordination system

**Why these 5:**
1. **Kupuna Caregivers (Idea 1)**: First-in-nation policy, virtually unstudied, clean DiD design, novel contribution
2. **Utah ULR (Idea 2)**: Recent reform with emerging literature, can contribute person-level analysis
3. **Missouri Minimum Wage (Idea 3)**: Clean multi-year phase-in, less studied than CA/NY/WA reforms
4. **Hawaii 20-hour threshold (Idea 4)**: Unique policy feature, RDD opportunity, builds on prior work with new method
5. **Utah Medicaid (Idea 5)**: RDD at FPL threshold, unique ESI requirement, recent implementation
