# Initial Research Plan

**Paper 110: The Price of Distance: Cannabis Dispensary Access and Alcohol-Related Traffic Fatalities**

**Date:** 2026-01-29
**Status:** Pre-registered before data collection

---

## Research Question

Does proximity to legal marijuana dispensaries reduce alcohol-related traffic fatalities in neighboring illegal states through marijuana-alcohol substitution?

---

## Theoretical Framework

### Behavioral Model of Substance Substitution with Travel Costs

Consider a consumer in an illegal state who can choose between:
- **Alcohol:** Available locally at price $p_a$
- **Marijuana:** Available via cross-border trip at "full price" $p_m = p_{retail} + c \cdot t$

Where:
- $p_{retail}$ = dispensary price (approximately constant across legal states)
- $c$ = cost per minute of driving (time, fuel, inconvenience)
- $t$ = driving time to nearest legal dispensary (our treatment variable)

**Key assumptions:**
1. Marijuana and alcohol are imperfect substitutes for recreational intoxication
2. Consumers face a trade-off between substances based on relative prices
3. Driving time creates meaningful variation in effective marijuana price

**Predictions:**
1. Lower driving time to dispensary → lower effective marijuana price → more marijuana consumption
2. More marijuana consumption → less alcohol consumption (substitution)
3. Less alcohol consumption → fewer alcohol-impaired driving episodes → fewer alcohol-related fatalities

**Testable implications:**
- H1: Alcohol-related fatalities decline in areas with lower driving time to dispensaries
- H2: Non-alcohol crashes should show no effect (placebo)
- H3: Effects should be concentrated in border regions where cross-border purchasing is feasible

---

## Identification Strategy

### Design: Cross-Sectional with Continuous Treatment Intensity

**Treatment variable:** $DriveTime_{s,t}$ = driving time (minutes) from road segment $s$ to nearest legal dispensary at time $t$

**Key innovation:** We study effects in **illegal states only**, where:
- The policy shock is *access* to legal marijuana (via dispensaries across the border)
- There is no contamination from within-state composition changes
- Variation in driving time creates continuous treatment intensity

### Estimating Equation

$$Y_{s,t} = \beta \cdot DriveTime_{s,t} + \gamma \cdot X_{s,t} + \alpha_s + \delta_t + \epsilon_{s,t}$$

Where:
- $Y_{s,t}$ = indicator for alcohol-involved fatal crash on segment $s$ in period $t$
- $DriveTime_{s,t}$ = driving time to nearest dispensary (varies as dispensaries open)
- $X_{s,t}$ = controls (distance to border, road type × year, etc.)
- $\alpha_s$ = road segment fixed effects
- $\delta_t$ = year-month fixed effects

**Expected sign:** $\beta > 0$ (longer drive time → more alcohol fatalities)

### Identifying Variation

1. **Spatial variation:** Segments at different distances from dispensaries within the same state
2. **Temporal variation:** New dispensary openings that reduce driving time for some segments
3. **Border-specific event studies:** Focus on specific border pairs (e.g., ID-OR) around retail opening dates

### Comparison with Prior Literature

| Study | Treatment | Outcome | Finding | Our Advance |
|-------|-----------|---------|---------|-------------|
| Anderson & Rees (2013) | Medical marijuana laws | All fatalities | -9% fatalities | We use continuous distance, not binary |
| Hansen et al. (2020) | Recreational legalization | Fatal crashes | No effect | We study illegal states (cleaner) |
| Hao & Cowan (2020) | Border county exposure | Arrests | +30% possession arrests | We study crashes, not arrests |

---

## Sample and Data

### Geographic Scope

**Illegal states (outcome sample):**
- Idaho, Wyoming, Nebraska, Kansas, Utah
- Arizona (through Oct 2020), Montana (through Dec 2020), New Mexico (through Jun 2021)

**Legal states (dispensary locations):**
- Colorado (retail Jan 2014)
- Washington (retail Jul 2014)
- Oregon (retail Oct 2015)
- Nevada (retail Jul 2017)
- California (retail Jan 2018)

### Time Period

- **Full sample:** 2012-2023 (12 years)
- **Pre-period (placebo):** 2012-2013 (no legal retail dispensaries anywhere)
- **Staggered treatment:** 2014-2023 (as states open retail)

### Unit of Analysis

**Primary:** Road segments (5-10km sections) in illegal states
- Constructed from OpenStreetMap highway network
- Major roads only (motorway, trunk, primary, secondary)
- Approximately 50,000-100,000 segments

**Secondary (robustness):** County × year-month panels

### Data Sources

1. **FARS (Fatality Analysis Reporting System)**
   - Source: NHTSA FTP
   - Variables: crash location (lat/lon), alcohol involvement (drunk_dr), date/time
   - Coverage: All fatal crashes, 2012-2023

2. **Dispensary locations**
   - Colorado: MED Licensed Facilities
   - Oregon: OLCC marijuana license list
   - Washington: LCB license database
   - California: DCC license search
   - Nevada: Cannabis Compliance Board
   - Supplement: OpenStreetMap `shop=cannabis` tags
   - Geocode all addresses to lat/lon

3. **Road network**
   - Source: OpenStreetMap via osmnx
   - Compute driving times using networkx with speed limits by road class

4. **Traffic volume (for robustness)**
   - Source: FHWA HPMS (Highway Performance Monitoring System)
   - Variable: AADT (Annual Average Daily Traffic)

---

## Primary Specification

### Main Model (Poisson or OLS)

$$AlcoholCrashes_{s,ym} = \exp(\beta \cdot \log(DriveTime_{s,ym}) + \alpha_s + \delta_{ym}) + \epsilon$$

Or in levels:

$$AlcoholCrashes_{s,ym} = \beta \cdot DriveTime_{s,ym} + \alpha_s + \delta_{ym} + \epsilon$$

**Clustering:** Two-way clustering at county × year-month, or Conley spatial HAC

### Bandwidth Restriction

Focus on segments within 200km of legal-state border (where cross-border purchasing is plausible)

---

## Robustness and Falsification Tests

### Placebo Tests

1. **Pre-period (2012-2013):** Same specification should yield null effect
2. **Non-alcohol crashes:** No effect on crashes without alcohol involvement
3. **Far-from-border segments:** Attenuated effect for segments >200km from any legal state

### Alternative Specifications

1. **County-level aggregation:** Collapse to county × year-month
2. **Border-pair event studies:** Separate analysis for each border pair (ID-OR, WY-CO, etc.)
3. **Donut specification:** Exclude segments within 10km of border (tourism confounds)

### Mechanism Tests

1. **THC-involved crashes (2018+):** Expect increase with dispensary access (reverse of alcohol)
2. **Time-of-day:** Nighttime alcohol crashes should show larger effects
3. **Heterogeneity:** Rural vs urban segments

### Inference

- Wild cluster bootstrap (Cameron, Gelbach, Miller 2008)
- Conley spatial HAC with 50km bandwidth
- Randomization inference over dispensary opening dates

---

## Expected Results

### Point Estimate Magnitude

Based on Anderson & Rees (2013) finding of 9% reduction from medical marijuana laws, and our more targeted variation:
- Expect 1-5% reduction in alcohol crashes per 30-minute reduction in driving time
- Effect concentrated within 100km of border

### Potential Outcomes

1. **Strong negative effect:** Supports substitution hypothesis
2. **Null effect:** Substitution may not extend to driving behavior, or effect size is small
3. **Positive effect:** Marijuana tourism increases driving exposure (would require alternative interpretation)

---

## Limitations (Acknowledged Ex Ante)

1. **Dispensary location endogeneity:** Dispensaries may locate near borders strategically
   - Mitigation: Use only within-illegal-state variation; dispensary location is not a choice of illegal-state residents

2. **Traffic volume confounds:** Marijuana tourism increases border-area VMT
   - Mitigation: Control for total crashes or AADT where available; focus on alcohol *share* not count

3. **Spatial spillovers:** Effects may extend beyond segment boundaries
   - Mitigation: Conley SEs; spatial lag models in robustness

4. **Measurement error in driving time:** OSM routing is approximate
   - Mitigation: Sensitivity to different routing algorithms; Google Maps API validation sample

---

## Paper Outline

1. **Introduction**
   - Motivation: 10,000 alcohol-related traffic deaths annually
   - Contribution: Novel continuous treatment, focus on illegal states

2. **Conceptual Framework**
   - Model of substance substitution with travel costs
   - Testable predictions

3. **Data**
   - FARS crash data
   - Dispensary locations and geocoding
   - Road network construction
   - Summary statistics with maps

4. **Empirical Strategy**
   - Identification
   - Estimating equations
   - Threats to validity

5. **Results**
   - Main effects
   - Event studies by border pair
   - Mechanism tests

6. **Robustness**
   - Placebos
   - Alternative specifications
   - Inference

7. **Conclusion**
   - Policy implications for cross-border spillovers
   - Limitations

---

## Figures and Tables (Planned)

### Main Figures
1. Map: Study region with legal/illegal states, dispensary locations
2. Map: Treatment intensity (driving time) across illegal state segments
3. Event study: Border-pair-specific estimates
4. Binscatter: Alcohol crash rate vs driving time

### Main Tables
1. Summary statistics
2. Main regression results
3. Placebo tests (pre-period, non-alcohol crashes)
4. Heterogeneity (border distance, road type, time of day)
5. Robustness (alternative specifications, inference)
