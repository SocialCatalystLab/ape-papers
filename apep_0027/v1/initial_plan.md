# Initial Research Plan - Paper 34

**Title:** The Long Shadow of the Paddle: State Corporal Punishment Bans and Adult Economic Outcomes

**Created:** 2026-01-18
**Status:** LOCKED - Original plan, do not modify after creation

---

## Research Question

Do individuals whose K-12 schooling occurred entirely after their state banned corporal punishment have better long-term educational attainment and economic outcomes compared to cohorts schooled before the ban?

---

## Policy Background

### Historical Context
Corporal punishment in American public schools was nearly universal until the 1970s. Teachers and administrators routinely used paddling, spanking, and other physical discipline to enforce classroom rules. Despite psychological research documenting potential harms, the U.S. Supreme Court in *Ingraham v. Wright* (1977) held that the Eighth Amendment's prohibition on cruel and unusual punishment did not apply to school discipline.

### Staggered State Bans
Between 1971 and 2023, 33 states and D.C. banned corporal punishment in public schools. The timing varied dramatically:

| Period | States |
|--------|--------|
| 1867 | New Jersey (outlier) |
| 1971-1977 | Massachusetts (1971), Hawaii (1973), Maine (1975), Rhode Island (1977) |
| 1983-1989 | New Hampshire (1983), New York & Vermont (1985), California (1986), Wisconsin & Nebraska (1988), Alaska, Michigan, Minnesota, North Dakota, Oregon (1989) |
| 1990-1994 | South Dakota (1990), Montana (1991), Nevada (1993), West Virginia (1994) |
| 2005-2023 | Pennsylvania (2005), Colorado & Idaho (2023) |
| Never | Alabama, Arizona, Arkansas, Florida, Georgia, Indiana, Kansas, Kentucky, Louisiana, Mississippi, Missouri, North Carolina, Oklahoma, South Carolina, Tennessee, Texas, Wyoming |

This staggered timing provides quasi-experimental variation for causal identification.

---

## Identification Strategy

### Difference-in-Differences Design

**Treatment:** Born in a state that banned corporal punishment before completing K-12 education (by age ~18)

**Control:** Born in a state that never banned, or banned after completing K-12

**Identification Assumption:** Absent the ban, trends in adult outcomes would have been parallel between treatment and control cohorts across states.

### Cohort Construction
For a person born in year *y* in state *s*:
- If state *s* banned corporal punishment in year *b*, and *y* + 6 > *b* (started school after ban), they are "fully treated"
- If *y* + 18 < *b* (completed school before ban), they are "fully untreated"
- Partial treatment for cohorts schooled during transition

### Key Specification

$$Y_{ist} = \alpha + \beta \cdot BannedDuringSchool_{is} + \gamma_s + \delta_t + \theta_c + X_{ist}\lambda + \epsilon_{ist}$$

Where:
- $Y_{ist}$ = outcome for individual *i* born in state *s* observed in year *t*
- $BannedDuringSchool_{is}$ = indicator for exposure to ban during K-12
- $\gamma_s$ = birth state fixed effects
- $\delta_t$ = survey year fixed effects
- $\theta_c$ = birth cohort fixed effects
- $X_{ist}$ = individual controls (age, sex, race)

---

## Data

### Census PUMS
- **Source:** IPUMS-USA, 5% samples from 2000, 2010; ACS 2006-2022
- **Sample:** U.S.-born individuals aged 25-64
- **Key variables:**
  - `BPLD` (birth state) + `BIRTHYR` → treatment assignment
  - `EDUC` → educational attainment (primary outcome)
  - `INCWAGE` → wage income (primary outcome)
  - `INCTOT` → total income
  - `EMPSTAT` → employment status
  - `DIFFREM`, `DIFFPHYS` → cognitive/physical difficulty (health proxies)
  - `SEX`, `RACE`, `AGE` → controls

### Corporal Punishment Ban Data
- Construct state × year ban database from legal sources
- Verify against Wikipedia timeline, state education department records, and legal databases

---

## Expected Results

### Primary Hypothesis
Exposure to corporal punishment bans during schooling is associated with:
1. **Higher educational attainment** (0.1-0.3 years additional schooling)
2. **Higher adult wages** (2-5% increase)
3. **Lower rates of cognitive/physical difficulty** (health proxy)

### Mechanisms (Speculative)
- Reduced school-related trauma → better school attachment → higher attainment
- Lower dropout rates in ban states
- Substitution toward non-physical discipline may improve classroom climate

### Heterogeneity
- Effects may be larger for:
  - Males (historically higher corporal punishment rates)
  - Black students (documented racial disparities in punishment)
  - Students in Southern states (higher historical prevalence)

---

## Robustness Checks

1. **Event Study:** Plot coefficients by years since/before ban to test parallel pre-trends
2. **Migration Adjustment:** Restrict to individuals residing in birth state, or instrument with birth state
3. **Placebo Outcomes:** Test outcomes unrelated to schooling (e.g., height, inherited conditions)
4. **Placebo Timing:** Assign fake ban years and show null effects
5. **Alternative Control Groups:** Compare to states that never banned vs. late adopters

---

## Potential Concerns

### Identification Threats
1. **Migration:** Birth state ≠ schooling state for movers. PUMS shows ~30% interstate migration. Will conduct robustness restricting to non-movers.

2. **Correlated Reforms:** Bans may coincide with broader education reforms. Will control for state education spending, school finance reforms, other discipline policies.

3. **Selection into Banning:** States that banned earlier may differ systematically. Address with state fixed effects and event study to show parallel pre-trends.

4. **District Heterogeneity:** Bans are state-level but enforcement varied by district. Treatment is intent-to-treat; actual exposure may be smaller. This attenuates estimates toward zero.

---

## Timeline

1. **Data Collection:** Fetch PUMS microdata for birth cohorts 1950-1995, survey years 2000-2022
2. **Ban Database:** Compile verified state × year ban dates
3. **Sample Construction:** Merge ban data with PUMS by birth state
4. **Descriptive Analysis:** Summary statistics by treatment status
5. **Main Estimation:** Run DiD with fixed effects
6. **Robustness:** Event studies, migration adjustments, placebos
7. **Writing:** Full paper with 25+ pages

---

## Contribution

This paper makes the following contributions:

1. **First U.S. causal evidence:** Most corporal punishment research uses correlational designs or international data (e.g., India). We provide the first quasi-experimental estimates using the staggered adoption of U.S. state bans.

2. **Long-run outcomes:** Existing economics research focuses on short-term school behavior. We estimate effects on adult educational attainment, wages, and health—outcomes that accumulate the lifetime costs or benefits of childhood discipline policy.

3. **Policy relevance:** Corporal punishment remains legal in 17 U.S. states and is practiced in 12. Our estimates inform ongoing debates about abolition, providing benefit-cost evidence for policymakers.
