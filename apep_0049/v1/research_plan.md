# Initial Research Plan — Paper 65

## Research Question

**Does federal transit formula funding improve local labor market outcomes?**

Specifically: Does crossing the 50,000 population threshold—which triggers eligibility for FTA Section 5307 Urbanized Area Formula Grants—lead to improvements in transit service provision, commuting patterns, and employment outcomes for residents of newly eligible urban areas?

---

## Policy Background

The Federal Transit Administration (FTA) provides formula-based capital and operating assistance to transit agencies through the Urbanized Area Formula Program (49 U.S.C. § 5307). Eligibility requires classification as an "urbanized area" by the U.S. Census Bureau, defined as an area with **population ≥ 50,000**.

This threshold creates a sharp discontinuity:
- Areas with population < 50,000: No Section 5307 formula funding
- Areas with population ≥ 50,000: Eligible for population-based formula allocations

For FY2024, total 5307 apportionments exceeded $5 billion nationally. For small urbanized areas (50,000-199,999), the formula is based on population, low-income population, and population density—meaning the first stage (funding) is mechanical.

---

## Identification Strategy

**Regression Discontinuity Design (RDD)** exploiting the 50,000 population threshold.

**Running variable:** Population as measured by the U.S. Census Bureau for urbanized area classification.

**Treatment:** Eligibility for FTA Section 5307 formula grants.

**Key assumption:** Population near the threshold is as-good-as-random. The Census Bureau determines urbanized area boundaries using automated algorithms based on housing unit and population density thresholds, not local manipulation. Importantly:
- Local governments do not directly control Census Bureau boundary determinations
- The algorithm aggregates census blocks based on density criteria
- Population counts are from actual enumeration, not self-reported

**Bandwidth:** Focus on urbanized areas with population 35,000-65,000 (approximately ±30% of threshold). Will test sensitivity to bandwidth choice.

---

## Data Sources

### Primary Data

1. **Census Urbanized Area Population** (2010, 2020 vintages)
   - Source: U.S. Census Bureau API
   - Variables: Urbanized area name, state, population, land area
   - Granularity: Urbanized area level

2. **FTA Apportionments Data**
   - Source: FTA National Transit Database
   - Variables: Section 5307 allocations by urbanized area
   - Years: 2012-2024

3. **National Transit Database (NTD)**
   - Source: FTA NTD
   - Variables: Vehicle revenue miles, passenger trips, operating expenses by agency/urbanized area
   - Years: 2012-2024

4. **ACS 5-Year Estimates by Place/County**
   - Source: Census API
   - Variables: Employment, commute mode, commute time, vehicle ownership, labor force participation
   - Years: 2010-2022 (5-year estimates)

### Geographic Matching Strategy

Urbanized areas do not align perfectly with Census places or counties. Strategy:
1. Identify principal place(s) within each urbanized area using Census geographic concordance files
2. Use place-level ACS data for urbanized areas dominated by a single principal city
3. For multi-place urbanized areas, aggregate component places
4. As robustness: use county-level data for counties substantially contained within urbanized areas

---

## Outcome Variables

### Primary Outcomes (Labor Market)
1. **Employment rate** — Share of working-age population employed
2. **Commute mode share** — Fraction using public transit
3. **Mean commute time** — Average minutes to work
4. **Vehicle ownership** — Vehicles per household

### Secondary Outcomes (Mechanisms)
5. **Transit service supply** — Vehicle revenue miles per capita
6. **Transit ridership** — Passenger trips per capita
7. **Low-income employment** — Employment rate among low-income residents

---

## Empirical Specification

### Main RDD Specification

For urbanized area $i$ with running variable $X_i$ (population) and threshold $c = 50,000$:

$$Y_i = \alpha + \tau \cdot \mathbf{1}[X_i \geq c] + f(X_i - c) + \varepsilon_i$$

where:
- $Y_i$ is the outcome variable
- $\tau$ is the treatment effect of crossing the 50,000 threshold
- $f(\cdot)$ is a flexible function of the running variable (linear or polynomial)
- $\mathbf{1}[X_i \geq c]$ is the treatment indicator

### Estimation
- Local linear regression with triangular kernel weights
- Bandwidth selection: Imbens-Kalyanaraman (2012) optimal bandwidth, with robustness to 50%, 150%, 200% of optimal
- Standard errors: Robust heteroskedasticity-consistent

### Required Diagnostics
1. **McCrary (2008) density test** — Check for bunching at threshold
2. **Covariate balance** — Pre-determined characteristics smooth at threshold
3. **Placebo thresholds** — No effects at 40,000, 45,000, 55,000, 60,000
4. **Bandwidth sensitivity** — Results robust across bandwidth choices

---

## Threats to Validity

### Potential Concerns

1. **Sorting/manipulation:** Local governments might try to influence Census counts
   - Mitigation: Population determined by Census enumeration algorithms, not local choice
   - Test: McCrary density test for discontinuous bunching

2. **Simultaneous thresholds:** Other programs may use 50,000 threshold
   - Mitigation: Search for other federal programs with this exact threshold; control if found

3. **Anticipation effects:** Areas expecting to cross may invest in transit before crossing
   - Mitigation: Compare pre-crossing outcomes; examine effect dynamics

4. **Geographic imprecision:** Matching urbanized areas to outcome data
   - Mitigation: Multiple matching strategies; robustness to different geographic definitions

---

## Timeline and Milestones

1. **Data acquisition** — Fetch Census UA data, FTA NTD data, ACS data
2. **Data cleaning** — Construct analysis sample with geographic matching
3. **Descriptive analysis** — Document sample characteristics, threshold crossing patterns
4. **First stage** — Confirm funding discontinuity at threshold
5. **Validity checks** — McCrary test, covariate balance, placebo tests
6. **Main estimates** — RDD effects on transit and labor outcomes
7. **Robustness** — Bandwidth sensitivity, alternative specifications
8. **Writing** — Full paper with figures and tables

---

## Expected Contribution

This paper provides the first causal evidence on whether federal transit formula funding improves local labor market outcomes. By exploiting the sharp 50,000 population eligibility threshold, we identify the effect of transit funding separate from other correlates of city size. The results inform ongoing debates about the value of federal transit investment and place-based transportation policy.
