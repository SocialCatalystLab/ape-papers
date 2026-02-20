# Initial Research Plan — apep_0426

## Research Question

Does household access to piped water improve school enrollment in rural India? We evaluate the Jal Jeevan Mission (JJM), a $50 billion program launched in 2019 to deliver household tap water connections to every rural household, using district-level staggered completion and annual school enrollment data.

## Identification Strategy

**Design:** Staggered Difference-in-Differences (DiD)

**Treatment:** District achieves "Har Ghar Jal" status (≥90% functional household tap connections, FHTC). Treatment is binary — a district switches from untreated to treated in the school year following certification. Treatment is irreversible (no district has lost Har Ghar Jal status).

**Treatment cohorts:** Districts achieved full coverage at different times between 2021 and 2024, creating 3-4 annual treatment cohorts. Approximately 188 districts certified by August 2024.

**Control group:** Not-yet-treated districts (districts that had not achieved Har Ghar Jal by the end of the sample period).

**Estimator:** Callaway-Sant'Anna (2021) doubly robust DiD, which is robust to heterogeneous treatment effects and staggered adoption. Implemented via R package `did`.

**Unit of analysis:** District × school year (academic year April-March).

**Clustering:** Standard errors clustered at the state level (28-36 clusters).

## Expected Effects and Mechanisms

**Primary channel:** Piped water → reduced time burden for water collection (disproportionately borne by women and girls) → increased school attendance, especially for girls in upper-primary and secondary school.

**Secondary channels:**
- Improved sanitation → reduced waterborne disease (diarrhea, typhoid) → fewer school absences
- Improved hygiene facilities at schools → reduced dropout for adolescent girls
- Reduced caregiving burden (mothers freed from water collection) → daughters sent to school

**Expected signs:**
- Positive effect on total enrollment (rural schools)
- Larger effect for girls than boys (gender gap reduction)
- Larger effect in upper-primary and secondary (where dropout is most common)
- Larger effect in water-scarce districts (desert, arid regions vs high-rainfall)

**Null hypothesis:** JJM had no measurable effect on school enrollment (possible if: water collection was already minimal, schools already had water access, or enrollment was already near-universal at primary level).

## Primary Specification

$$Y_{d,t} = \alpha_d + \gamma_t + \delta \cdot \text{Treated}_{d,t} + X_{d,t}'\beta + \varepsilon_{d,t}$$

Where:
- $Y_{d,t}$: Log total enrollment (or enrollment rate) in district $d$, school year $t$
- $\alpha_d$: District fixed effects
- $\gamma_t$: Year fixed effects
- $\text{Treated}_{d,t}$: 1 if district $d$ achieved Har Ghar Jal before school year $t$
- $X_{d,t}$: Time-varying controls (population growth proxy from nightlights)
- $\varepsilon_{d,t}$: Error term, clustered at state level

**CS-DiD specification (primary):**
Using `att_gt()` from R `did` package with:
- `yname`: log enrollment
- `gname`: treatment cohort year
- `tname`: school year
- `idname`: district ID
- `xformla`: baseline controls (Census 2011 literacy rate, SC/ST share, urbanization)
- `control_group`: "notyettreated"

## Exposure Alignment (DiD)

- **Who is treated:** Rural households in districts that achieved Har Ghar Jal status
- **Primary estimand:** District-level average treatment effect on rural school enrollment
- **Placebo/control population:** Districts not yet treated; also urban schools within treated districts (piped water already ubiquitous in urban areas)
- **Design:** Staggered DiD (not triple-diff), with event-study plots

## Power Assessment

- **Pre-treatment periods:** 7 (school years 2012-13 through 2018-19)
- **Treated clusters:** ~188 districts (across ~25 states)
- **Post-treatment periods:** 1-4 per cohort (2020-21 through 2023-24)
- **Total districts:** ~640 (2011 boundaries)
- **MDE:** With ~640 district-years pre-treatment and ~188 treated districts, power is strong. Even a 1-2% change in enrollment is detectable.

## Planned Robustness Checks

1. **Pre-trend test:** Event-study plot with 7 leads and 4 lags
2. **Placebo outcome:** Nightlights (should not respond to water access)
3. **Placebo population:** Urban school enrollment (already had piped water)
4. **Alternative treatment definition:** Continuous FHTC coverage % instead of binary
5. **Heterogeneity:** By baseline water scarcity, gender, school level (primary vs secondary)
6. **Alternative estimator:** Sun & Abraham (2021) interaction-weighted estimator
7. **Bacon decomposition:** De Chaisemartin & D'Haultfoeuille (2020) to check TWFE issues

## Data Sources

| Source | Geographic Level | Time Period | Key Variables |
|--------|-----------------|-------------|---------------|
| UDISE+ (data.gov.in) | District | 2012-2024 | Enrollment by gender, location, school level |
| JJM IMIS (ejalshakti.gov.in) | District | 2021-2025 | FHTC coverage %, Har Ghar Jal certification |
| SHRUG Census PCA | Village (aggregated to district) | 2001, 2011 | Population, literacy, SC/ST share, workers |
| SHRUG Nightlights | Village (aggregated to district) | 1994-2023 | Economic activity proxy |
| Census 2011 | District | 2011 | Baseline covariates |
