# Initial Research Plan: Paper 110

## Research Question

Does recreational marijuana legalization increase new business formation? Specifically, how does the opening of legal recreational cannabis markets affect business application rates, both in cannabis-adjacent industries and in the broader economy?

## Identification Strategy

**Staggered Difference-in-Differences (DiD)** exploiting state-level variation in the timing of first legal recreational marijuana retail sales.

- **Treatment:** State-year when first legal recreational retail sales begin
- **Treatment group:** ~21 states with active retail sales (2014–2024)
- **Comparison group:** ~29 states plus DC that never legalized recreational marijuana (or legalized but have not yet opened retail sales)
- **Estimator:** Callaway-Sant'Anna (2021) with never-treated comparison group
- **Additional design:** Triple-difference (DDD) comparing cannabis-adjacent NAICS sectors (agriculture, retail, manufacturing) to non-adjacent sectors, within treated vs. control states

## Expected Effects and Mechanisms

**Direct channel:** Legalization creates a new legal market, directly generating business applications for dispensaries (retail), cultivation (agriculture), and processing (manufacturing).

**Ancillary channel:** Supporting businesses emerge — testing labs, packaging companies, security firms, marketing agencies, real estate, legal/compliance services.

**Spillover channel:** Broader entrepreneurship may increase through: tax revenue investment, reduced drug testing barriers expanding the labor pool, cultural/economic optimism effects, tourism-driven demand for hospitality businesses.

**Expected sign:** Positive effect on total business applications, with larger effects in cannabis-adjacent sectors.

**Magnitude:** Given that cannabis businesses are a small share of total business applications, the aggregate effect may be modest (1-5% increase in total BA). Within cannabis-adjacent sectors, the effect should be larger (5-20%).

## Primary Specification

### DiD (State-Year Level)

$$Y_{st} = \alpha_s + \alpha_t + \beta \cdot \text{RecRetailSales}_{st} + X_{st}\gamma + \epsilon_{st}$$

where $Y_{st}$ is log business applications per capita in state $s$, year $t$; $\text{RecRetailSales}_{st}$ indicates first legal recreational retail sales; $\alpha_s$, $\alpha_t$ are state and year fixed effects; $X_{st}$ includes controls for medical marijuana status.

### CS Estimator

Group-time ATTs using Callaway-Sant'Anna with:
- Cohorts defined by year of first retail sales
- Never-treated states as comparison group
- Aggregated to overall ATT and dynamic event-study

### DDD (State-Year-Sector Level)

$$Y_{sjt} = \alpha_{sj} + \alpha_{jt} + \alpha_{st} + \delta \cdot (\text{RecRetailSales}_{st} \times \text{Adjacent}_j) + \epsilon_{sjt}$$

where $j$ indexes NAICS sectors and $\text{Adjacent}_j$ indicates cannabis-adjacent sectors.

## Planned Robustness Checks

1. **Alternative treatment timing:** Use legalization date instead of first retail sales
2. **Alternative NAICS groupings:** Narrow (retail only), baseline (agric+retail+manuf), broad (+ professional services + accommodation)
3. **Medical marijuana control:** Restrict comparison to states with medical marijuana only
4. **Randomization inference:** Permutation-based p-values
5. **Wild cluster bootstrap:** For inference with ~21 treated clusters
6. **Pre-trends:** Event-study dynamics showing parallel pre-trends
7. **COVID robustness:** Exclude 2020-2021 or include COVID controls
8. **Per capita normalization:** Use population-adjusted rates
9. **High-propensity BA:** Use BA_HBA (applications most likely to become employer businesses) instead of total BA
10. **Placebo sectors:** Show null effects in sectors where no cannabis effect is expected

## Exposure Alignment (DiD-Specific)

- **Who is actually treated?** States with active legal recreational marijuana retail markets
- **Primary estimand population:** Business applicants in states with legal recreational markets
- **Placebo/control population:** Business applicants in never-legal states and states without retail markets
- **Design:** DiD for aggregate effects; DDD for industry-level decomposition

## Power Assessment

- **Pre-treatment periods:** 2005–2013 (9 years for earliest cohort)
- **Treated clusters:** ~21 states with retail sales
- **Post-treatment periods per cohort:** Varies from 1 year (OH, 2024) to 11 years (CO/WA, 2014–2025)
- **Outcome variation:** Business applications are count data with large state-level variation; log transformation recommended
- **MDE:** With ~50 states × 20 years × 21 treated states, the design should detect effects as small as 2-3% of the mean, though this needs formal calculation

## Data Sources

1. **Census Business Formation Statistics (BFS):** Monthly business applications by state and NAICS sector, 2004–2025. Downloaded as CSV from census.gov/econ/bfs/.
2. **State population:** ACS 1-year estimates by state for per-capita normalization
3. **Treatment timing:** First legal recreational retail sales dates from NCSL, MJBizDaily, Ballotpedia
4. **Medical marijuana status:** ProCon.org or RAND-OPTIC database
5. **State-level controls:** Unemployment rate, GDP per capita from BLS/BEA (if needed)
