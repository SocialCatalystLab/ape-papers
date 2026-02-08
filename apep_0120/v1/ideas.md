# Research Ideas

## Idea 1: State Minimum Wage Increases and Young Adult Household Formation

**Policy:** State minimum wage increases above the federal floor ($7.25), staggered across 30+ states from 2012-2023. Key treated states include California, New York, Washington, Massachusetts, Colorado, Illinois, Arizona, Maine, and many others. Most increases occurred in waves: 2014-2016 (Fight for $15 movement) and 2019-2023 (continued escalation). States like Texas, Pennsylvania, and Georgia remained at the federal floor throughout.

**Outcome:** Share of young adults (ages 18-30) living independently (not in parental household) measured from Census ACS PUMS microdata. Secondary outcomes: employment rate, wages, household size, and residential mobility among young adults. The RELP/RELSHIPP variable in PUMS identifies relationship to householder (child of householder = living with parents). Person-weighted aggregation to state-year cells.

**Identification:** Staggered DiD exploiting state × year variation in minimum wage levels. Treatment defined as state MW exceeding the federal level by a meaningful threshold (e.g., $1+ above $7.25). Callaway-Sant'Anna (2021) estimator with never-treated states as the comparison group. State and year fixed effects absorb time-invariant state characteristics and national trends.

**Why it's novel:** The minimum wage literature focuses on employment, hours, and wages. Effects on household formation — whether young adults can afford to live independently — remain virtually unstudied despite being a first-order welfare consequence. Young adult co-residence with parents reached historic highs (52% of 18-29 year-olds in 2020), making this a pressing policy question. The mechanism is theoretically ambiguous: higher MW → higher earnings → more independence, vs. higher MW → job loss → less independence. This ambiguity makes the empirical question interesting regardless of the sign.

**Feasibility check:**
- Variation: 30+ states raised MW above $7.25 between 2012-2023, with staggering across multiple years ✓
- Data access: Census PUMS API works without authentication (tested: 2010-2022 all return HTTP 200) ✓
- Not in APEP list: Papers 0005, 0067, 0075, 0078 study MW but none study living arrangements ✓
- Sample size: ACS samples ~3.5M people/year; young adults 18-30 = ~600K/year, providing large state-year cells ✓
- Pre-periods: 2010-2013 (4 years before major MW acceleration), or 2010-2011 for earliest treated states ✓
- MW treatment data: DOL publishes complete state × year tables (dol.gov/agencies/whd/state/minimum-wage/history) ✓

---

## Idea 2: State Ban-the-Box Laws and Racial Employment Disparities

**Policy:** State and local ban-the-box (fair chance hiring) laws prohibiting employers from asking about criminal history on initial job applications. Over 35 states and 150+ localities adopted some form of BTB between 2004-2021, with major acceleration 2013-2019. Laws vary in scope (public sector only vs. private employers, number of employees threshold).

**Outcome:** Employment rate and earnings by race (Black vs. White young men ages 18-40) from CPS/ACS microdata. The key outcome is the Black-White employment gap, measured at the state-year level.

**Identification:** Staggered DiD exploiting state × year adoption of BTB laws. Triple-difference (DDD) specification: (Black vs. White) × (BTB state vs. non-BTB state) × (post vs. pre). CS-DiD estimator with never-treated states as comparison.

**Why it's novel:** The existing literature (Agan & Starr 2018; Doleac & Hansen 2020) finds that BTB may unintentionally increase statistical discrimination against Black applicants. These studies use correspondence experiments or limited state samples. A comprehensive multi-state DiD using modern CS estimators across all state adoptions, with focus on equilibrium employment outcomes (not callbacks), would provide new evidence. APEP paper 0003 studies only Indiana's ban-the-box preemption — a single state.

**Feasibility check:**
- Variation: 35+ states with staggered adoption 2004-2021 ✓
- Data access: Census PUMS API for ACS microdata ✓
- Not overstudied by APEP: Only paper 0003 (single state) ✓
- Concern: Treatment heterogeneity is high (public-only vs. private sector scope)
- Concern: Some adoption is at city, not state level — state-level analysis may attenuate effects

---

## Idea 3: State Conversion Therapy Bans and Youth Suicide Rates

**Policy:** 20+ states banned conversion therapy on minors by licensed mental health professionals between 2012-2023. California was first (2012), followed by NJ (2013), DC (2014), OR/IL (2015), VT (2016), NM/CT/NV/RI (2017), WA/MD/HI/NH/DE (2018), NY/MA/ME/CO (2019), VA (2020), UT/MN/MI (2023).

**Outcome:** Youth suicide rate (ages 15-24) by state-year from CDC mortality data. Secondary: BRFSS self-reported mental health indicators (depression prevalence, days of poor mental health).

**Identification:** Staggered DiD across states with CS-DiD estimator. 25+ never-treated states serve as comparison. Pre-treatment period: 2005-2011 (7 years before first ban).

**Why it's novel:** Conversion therapy bans are primarily studied from a civil rights perspective. Quantitative causal evidence on health outcomes is scarce. The mechanism: bans signal state acceptance of LGBTQ identity → reduced internalized stigma → improved mental health outcomes. Alternatively: bans prevent harmful practices directly → reduced trauma.

**Feasibility check:**
- Variation: 20+ treated states with staggering from 2012-2023 ✓
- Data access concern: CDC mortality data by state/year has a gap (1999-2017 via bi63-dtpu; 2020-2023 via muzy-jte6; 2018-2019 missing from APIs). BRFSS covers 2011-2024 ✗/✓
- Outcome precision concern: Youth suicide is a rare event; state-year cells may be too small to detect effects driven by LGBTQ youth specifically ✗
- Not in APEP list ✓
- Could use BRFSS "Fair or Poor Health" or depression prevalence as alternative outcomes — available 2011-2024 ✓
