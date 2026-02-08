# Research Ideas

## Idea 1: Cantonal Energy Laws and Federal Referendum Voting (RECOMMENDED)

**Policy:** Comprehensive Cantonal Energy Law Reform (Kantonale Energiegesetze)
- Staggered adoption across 8 cantons: GR (2010), BE (2011), AG (2012), BL (2016), BS (2016), LU (2017), FR (2019), AI (2020)
- Laws implement MuKEn building efficiency standards, promote renewables, mandate heat pump adoption
- Official sources verified: LexFind URLs available for all laws

**Outcome:** Municipal voting patterns on the May 21, 2017 federal Energy Strategy 2050 referendum (Energiegesetz, Vote ID 612)
- 58.2% approval nationally
- Data: swissdd R package provides gemeinde-level yes/no votes, turnout

**Identification Strategy:** Spatial Regression Discontinuity Design
- Running variable: Distance from gemeinde centroid to nearest canton border
- Treatment: Gemeinden in cantons that had adopted energy laws before May 2017 (GR, BE, AG, BL, BS)
- Control: Adjacent gemeinden in cantons without energy laws at the time of the vote
- Border pairs: AG-ZH, AG-SO, BE-JU, BE-NE, BL-SO, BS-SO, GR-SG, GR-TI

**Why it's novel:**
1. First study examining policy "priming" effects on referendum behavior
2. Tests whether cantonal policy exposure shapes federal voting preferences
3. Uses spatial RDD at Swiss canton borders—well-suited to ~2,100 gemeinden
4. Clean identification: adjacent municipalities share labor markets, culture, and media exposure

**Feasibility check:**
- ✅ Policy timing: Verified via LexFind cantonal law portals
- ✅ Outcome data: swissdd package provides gemeinde-level referendum results 1981-present
- ✅ Geography: BFS R package provides gemeinde shapefiles (bfs_get_base_maps)
- ✅ Merger mapping: SMMT package handles gemeinde boundary changes
- ✅ Not overstudied: No APEP papers on Swiss voting behavior; spatial RDD on referendum voting is rare

**Expected effect:** Gemeinden in "treated" cantons (with prior energy laws) should show higher support for the federal Energy Strategy 2050, as residents have already been exposed to policy messaging and implementation.

---

## Idea 2: Cantonal Energy Laws and Solar Panel Adoption (Alternative)

**Policy:** Same cantonal energy law reform as Idea 1

**Outcome:** Solar electricity production / solar installation density by gemeinde
- Data source: BFE "Studie Winterstrom aus Photovoltaik" provides gemeinde-level PV production profiles
- Limitation: Cross-sectional (may not have full time series for DiD)

**Identification:** Spatial RDD at canton borders comparing solar adoption rates

**Why it's novel:** Tests whether cantonal mandates accelerate residential solar uptake

**Feasibility check:**
- ✅ Policy: Verified
- ⚠️ Outcome data: BFE solar data exists but temporal coverage unclear
- ✅ Not overstudied

---

## Idea 3: Building Terms Harmonization (IVHB) and Construction Activity

**Policy:** Intercantonal Agreement on Harmonization of Building Terms (IVHB)
- Staggered adoption: LU (2010), BE (2011), OW (2012), AI (2015)
- Standardizes building definitions (height, floor area) across cantons

**Outcome:** Construction permit processing time, number of building applications
- Data: BFS construction statistics, Bauprojekte datasets

**Identification:** Spatial RDD at canton borders comparing construction activity

**Why it's novel:** Tests regulatory harmonization effects on housing supply

**Feasibility check:**
- ✅ Policy: Verified via LexFind
- ⚠️ Only 4 cantons—limited border pairs
- ⚠️ Outcome data may be aggregated to canton level

---

## Recommendation

**Pursue Idea 1: Cantonal Energy Laws and Referendum Voting**

Rationale:
1. Best data availability: swissdd provides clean gemeinde-level voting data
2. Most cantons (8) providing multiple border pairs for spatial RDD
3. Novel research question with clear policy relevance
4. Clean temporal structure: cantonal laws adopted 2010-2016, federal vote in May 2017
5. Strong identification: spatial discontinuity at canton borders

The paper tells a compelling story about how local policy experience shapes national political preferences—a "bottom-up federalism" effect.
