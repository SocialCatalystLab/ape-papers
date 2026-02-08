# Research Ideas: Marijuana Legalization and Labor Market Equilibria

## Idea 1: High on Employment? A Spatial RDD of Recreational Marijuana Legalization Effects on Industry-Specific Labor Markets

**Policy:** Recreational marijuana legalization (RML) - State-level legalization of recreational cannabis for adults 21+:
- Colorado: Legalized Nov 2012, retail sales Jan 2014
- Washington: Legalized Nov 2012, retail sales July 2014
- Oregon: Legalized Nov 2014, retail sales Oct 2015
- Nevada: Legalized Nov 2016, retail sales July 2017
- California: Legalized Nov 2016, retail sales Jan 2018

**Outcome:** Census Quarterly Workforce Indicators (QWI) via Census API at county × quarter × sex × industry level:
- New hire earnings (EarnHirAS)
- Employment (Emp)
- Hiring rates (HirA)
- Available for 20+ NAICS 2-digit sectors
- API endpoint: api.census.gov/data/timeseries/qwi/se

**Identification:** Spatial RDD with GIS-based running variable (distance from county centroid to state border). Counties within bandwidth of treated/control state borders compared. Border-pair × quarter fixed effects absorb common shocks. Temporal placebo tests (8 pre-treatment quarters) validate design by testing for pre-existing spatial discontinuities. If placebos fail, Difference-in-Discontinuities (DiDisc) provides fallback that differences out level discontinuities.

### Theoretical Framework

**Model Setup:** Labor market with heterogeneous industries differing in drug testing prevalence and direct cannabis exposure.

**Labor Supply Effects:**
1. *Participation margin:* Legalization may increase labor force participation if marijuana substitutes for opioids/alcohol that cause disability
2. *Industry sorting:* Workers may sort into industries with/without drug testing; legalization relaxes this constraint
3. *Migration:* Cross-border commuting patterns change (addressed with Dorn's CZ data)

**Labor Demand Effects:**
1. *New industry creation:* Cannabis cultivation, retail, testing labs → agriculture/retail employment surge
2. *Productivity concerns:* Employers may fear reduced productivity; some industries may reduce hiring
3. *Drug testing relaxation:* Industries that previously required testing may expand hiring pool

**Industry-Specific Predictions:**

| Industry | Code | Predicted Effect | Mechanism |
|----------|------|------------------|-----------|
| Agriculture | 11 | Strong + | Direct: cannabis cultivation |
| Retail Trade | 44-45 | Moderate + | Dispensary employment |
| Accommodation/Food | 72 | Moderate + | Tourism, relaxed testing |
| Manufacturing | 31-33 | Null or - | Safety-sensitive, testing |
| Transportation | 48-49 | Null or - | DOT testing requirements |
| Finance | 52 | Null | Banking restrictions on cannabis |
| Health Care | 62 | Ambiguous | Treatment demand vs. testing |
| Construction | 23 | Ambiguous | Safety vs. relaxed testing |

### Key Design Features

**GIS Running Variable:**
- Download TIGER/Line county shapefiles via `tigris` R package
- Calculate county centroid to nearest state border using `sf::st_distance()`
- Sign distance: positive for treated side, negative for control side

**Multiple Hypothesis Correction:**
With 20+ industries, apply Benjamini-Hochberg FDR correction at q=0.05 level.

**Commuting Zone Spillover Analysis:**
- Use David Dorn's county-to-CZ crosswalk (ddorn.net/data.htm, file E7)
- Identify CZs that straddle treated/control borders
- Test for spillovers: do control counties in cross-border CZs show effects?

### Feasibility Confirmed

- [x] QWI API: tested in APEP-0176, returns county × industry × quarter data
- [x] TIGER/Line: available via tigris R package, no API key needed
- [x] Dorn CZ crosswalk: publicly downloadable from ddorn.net
- [x] 5 treated states provide border pairs with AZ, NM, UT, ID, NE, KS, OK
- [x] 2014-2023 gives 4+ years post-treatment for CO/WA

### Potential Failure Modes

1. **Spatial RDD invalid:** Placebos reveal pre-existing discontinuities → fallback to DiDisc
2. **QWI suppression:** County × industry cells suppressed → aggregate to state-level
3. **Limited border variation:** Few counties within bandwidth → widen or use all borders

---

## Idea 2: The Green Rush at State Borders: Difference-in-Discontinuities for Marijuana Effects on Employment

**Policy:** Same as Idea 1: Recreational marijuana legalization in CO (Jan 2014), WA (July 2014), OR (Oct 2015), NV (July 2017), CA (Jan 2018).

**Outcome:** Same as Idea 1: QWI county × quarter × industry data via Census API.

**Identification:** Difference-in-Discontinuities (DiDisc). Unlike pure Spatial RDD, DiDisc allows persistent level differences between treated and control sides of border. Identifies effects from *changes* in the discontinuity at treatment onset. Specification includes distance polynomials interacted with post-treatment indicator. Key coefficient is the interaction of Treated × Post × f(Distance). Border-pair and quarter fixed effects included.

### Why DiDisc May Be Preferred

Pure Spatial RDD assumes counties on opposite sides of the border are comparable except for treatment. This fails if:
- High-wage states border low-wage states (CA vs AZ)
- Urban density differs systematically
- Pre-existing industry composition differs

DiDisc relaxes this by first-differencing away the level discontinuity.

### Feasibility

Same data as Idea 1. DiDisc is a specification choice, not a data requirement.

---

## Idea 3: Cross-Border Commuting Zones: Labor Market Spillovers from Marijuana Legalization

**Policy:** Same as Idea 1: RML in CO, WA, OR, NV, CA (2014-2018 retail sales dates).

**Outcome:** QWI at county × quarter × industry level (Census API) combined with David Dorn's county-to-CZ crosswalk (cw_cty_czone.zip from ddorn.net/data.htm).

**Identification:** Within-commuting-zone comparison. CZs represent integrated labor markets where workers compete for jobs regardless of residence state. For CZs straddling treated/control state borders, compare treated vs control counties within the same CZ. CZ × quarter fixed effects absorb all CZ-level labor market shocks. Identification comes from within-CZ, across-state variation.

### Theoretical Motivation

Workers commute across state borders. A Colorado border county may have workers who:
1. Live in CO, work in CO (treated)
2. Live in CO, work in neighboring state (control exposure)
3. Live in neighboring state, work in CO (treated exposure)

Within-CZ comparison controls for labor market conditions that affect both sides of the border.

### Feasibility

- CZ crosswalk: ddorn.net file E7, maps 1990 counties to CZs
- Need FIPS code updates for county changes since 1990 (Dorn file E10)
- Verified: CZs exist that span CO-NM, CO-UT, WA-OR, etc.

---

## Idea 4: Drug Testing Industries vs. Non-Testing Industries: A Triple-Difference Approach

**Policy:** Same as Idea 1: RML in CO, WA, OR, NV, CA (2014-2018).

**Outcome:** QWI by industry (Census API) plus industry-level drug testing prevalence from Quest Diagnostics Drug Testing Index (publicly reported annually).

**Identification:** Triple-difference (DDD) with third difference being industry drug testing intensity. Specification: Y = Treated × Post × HighTesting + all two-way interactions + county-industry FE + state-quarter FE + industry-quarter FE. Tests whether legalization differentially affects employment in high-testing industries (transportation, manufacturing) vs. low-testing industries (professional services, information).

### Theoretical Prediction

If legalization relaxes the drug testing constraint: high-testing industries gain workers → τ > 0
If employers worry about productivity: high-testing industries reduce hiring → τ < 0

### Feasibility

- Quest Diagnostics publishes positivity rates by industry sector annually
- Need to map Quest categories to NAICS codes
- Alternative: use SAMHSA workplace testing data

---

## Idea 5: Age-Specific Effects: Youth Employment and the Minimum Legal Age

**Policy:** Same as Idea 1: RML in CO, WA, OR, NV, CA (2014-2018). All states set minimum legal age at 21.

**Outcome:** QWI by age group via Census API. QWI provides age bins: 14-18, 19-21, 22-24, 25-34, 35-44, 45-54, 55-64, 65+.

**Identification:** Age-based triple-difference comparing employment trends for 19-21 (just below legal age) vs 22-24 (just above) in treated vs control states, pre vs post. Specification: Y = Treated × Post × Over21 + all two-way interactions + county-age FE + state-quarter FE + age-quarter FE.

### Theoretical Motivation

- Legal purchase age is 21 in all states
- Workers 19-21 vs 22-24 face different legal access
- If marijuana impairs work capacity, effects should be larger for 22-24 (legal access)
- If drug testing matters, effects on 22-24 (testable consumption) may differ

### Feasibility

- QWI provides age groups at county level
- Suppression may be high for county × age cells
- Fallback: state × age analysis

---

## Summary

**Lead idea (Idea 1):** Spatial RDD with GIS running variable, temporal placebos, FDR-corrected industry heterogeneity, and CZ spillover analysis. Novel combination of spatial identification + administrative data + multiple hypothesis testing.

**Backup (Idea 2):** Difference-in-Discontinuities if Spatial RDD fails placebos.

**Complementary (Ideas 3-5):** CZ-based design, drug testing triple-diff, age heterogeneity.

**Theoretical contribution:** Model predicts industry-specific effects based on (1) direct cannabis industry creation, (2) drug testing prevalence, (3) tourism exposure. Tests which mechanism dominates.

**Methodological contribution:** Either validates Spatial RDD for labor market policy OR documents its limitations.
