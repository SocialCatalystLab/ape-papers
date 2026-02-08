# Initial Research Plan

## Research Question

Do salary history bans reduce overall wage inequality? When employers cannot anchor compensation offers to applicants' prior earnings, does this compress the wage distribution?

## Policy Context

Twenty-two US states have enacted salary history bans prohibiting employers from asking job applicants about their prior compensation. These laws aim to break cycles of wage discrimination by removing an anchoring signal that may perpetuate past inequities.

**Adoption Timeline:**
| State | Effective Date |
|-------|---------------|
| Massachusetts | July 2018 |
| California | January 2018 |
| Delaware | December 2017 |
| Oregon | October 2017 |
| New York City | October 2017 |
| New York State | January 2020 |
| Connecticut | January 2019 |
| Hawaii | January 2019 |
| Vermont | July 2018 |
| New Jersey | January 2020 |
| Illinois | September 2019 |
| Maine | September 2019 |
| Colorado | January 2021 |
| Maryland | October 2020 |
| Nevada | October 2021 |
| Rhode Island | January 2023 |
| Washington | July 2019 |
| Plus additional states |

## Identification Strategy

**Method:** Staggered Difference-in-Differences using Callaway and Sant'Anna (2021) estimator

**Treatment:** State enacts salary history ban
**Control:** States without bans at each time point (never-treated + not-yet-treated)

### Addressing GPT Ranking Concerns

**Concern 1: Outcome Dilution**
- Primary sample: **Recent job changers** (employed workers who changed employers in past 12 months)
- ACS variable: EMPSTAT, MIGRATE1 (moved in past year), or imputed from WKSWORK1 patterns
- Backup: Focus on **entry-level workers** (age 22-30, < 3 years tenure) who are disproportionately new hires

**Concern 2: Timing Alignment**
- Use ACS **interview month** (MONTH) to align with effective dates
- Construct treatment timing based on effective date (not passage date)
- Drop partial-exposure years or weight by months of exposure

**Concern 3: Concurrent Policies**
- Control for state minimum wage, pay transparency laws, equal pay laws
- Use only "clean" adopters (states passing salary history ban without bundled policies)
- Stacked DiD design: Compare early vs late adopters

## Primary Estimand

**Treatment Effect on the Treated (ATT):** Effect of salary history ban on within-state wage dispersion, measured by:
- 90/10 percentile ratio of log wages
- Variance of log wages
- Gini coefficient of wage income

## Expected Mechanisms

1. **Compression via anchor removal:** Without prior salary information, employers may converge toward posted ranges or "market rates"
2. **Bargaining power equalization:** Workers who were historically underpaid can negotiate freely without revealing disadvantage
3. **Firm standardization:** Employers may adopt more rigid pay bands to comply with bans

**Predicted direction:** Wage inequality *decreases* after salary history bans, driven by compression at the top (high earners lose anchoring advantage) or lifting at the bottom (previously underpaid workers negotiate better).

**Alternative prediction:** If high-ability workers are better negotiators when anchoring is removed, inequality could *increase*.

## Data Sources

**Primary:** IPUMS ACS 2012-2023
- Variables: INCWAGE (wage income), STATEFIP (state), YEAR, MONTH (interview month)
- Sample: Employed workers ages 18-64 with positive wage income
- Job changers identified via: MIGRATE1 (moved states), DIFFREM (changed employer)

**Secondary:** CPS MORG (Merged Outgoing Rotation Groups)
- Higher-frequency monthly data
- Detailed industry/occupation codes

## Planned Specifications

**Baseline (state-year level):**
```
Y_st = β × SHB_st + γ_s + δ_t + ε_st
```
Where Y is wage dispersion measure, SHB is salary history ban indicator.

**Individual-level with CS estimator:**
- Cohort-specific ATT estimates
- Aggregation across cohorts using Callaway-Sant'Anna weights
- Event-study specification for pre-trends

## Robustness Checks

1. **Pre-trends test:** Event study showing no differential trends before adoption
2. **Placebo outcomes:** Test for effects on non-labor income, self-employment income
3. **Heterogeneity:** By industry (high vs low wage dispersion), education, gender
4. **Synthetic DiD:** As alternative to CS estimator
5. **Border discontinuity:** Compare adjacent counties across state borders

## Exposure Alignment (for DiD papers)

- **Who is treated:** Job applicants/new hires in treated states after effective date
- **Primary estimand population:** Recent job changers (changed employers in past 12 months)
- **Placebo/control population:** Long-tenure workers who have not changed jobs recently
- **Design:** Standard DiD (state × time), with heterogeneity by job-change status

## Power Assessment

- Pre-treatment periods: 2012-2017 (6 years)
- Treated clusters: 22 states
- Post-treatment periods: 2018-2023 (6 years)
- Observations: ~2 million per year in ACS; ~200k job changers per year
- MDE: Well-powered to detect 1-2% changes in wage dispersion measures
