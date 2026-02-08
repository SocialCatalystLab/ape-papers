# Research Ideas: Swiss Spatial RDD on Gender Gaps

## Idea 1: Childcare Mandates and Maternal Employment at Canton Borders

**Policy:** In 2010, the cantons of Bern and Zurich amended their Volksschulgesetz (compulsory education law) to require municipalities to (a) annually survey parental demand for after-school care (Tagesbetreuung/Tagesschule), and (b) provide lunchtime and afternoon care if 10 or more children sign up for any time slot. Basel-Stadt, Graubünden, Lucerne, Neuchâtel, and Schaffhausen adopted similar regulations by 2016. Other cantons (AG, SO, SG, TG) had no such mandate.

**Outcome:** Gender gap in labor force participation, specifically:
- Female employment rate by Gemeinde (BFS STATPOP)
- Part-time employment rate for women (high part-time = 50%+ FTE)
- Gender employment gap (male - female participation rate)

**Identification:** Spatial regression discontinuity at canton borders. Treatment: Gemeinden in cantons with childcare mandates. Control: Gemeinden in adjacent cantons without mandates. Running variable: signed distance to nearest treated-control canton border (positive = treated side).

**Same-language borders (avoids Röstigraben):**
- BE-SO (Bern treated 2010, Solothurn control)
- ZH-AG (Zurich treated 2010, Aargau control until 2015+)
- ZH-SG (Zurich treated 2010, St. Gallen control)
- ZH-TG (Zurich treated 2010, Thurgau control)

**Why it's novel:**
1. Existing studies (Felfe et al. 2016, Ravazzini 2018) use canton-level DiD
2. No spatial RDD at Gemeinde level exists
3. Same-language borders provide clean identification without Röstigraben confound
4. Can combine with DiD for staggered adoption (2010 BE/ZH → later cantons)

**Feasibility check:**
- [x] Policy variation confirmed (LexFind cantonal laws)
- [x] Staggered timing confirmed (2010, 2014-2016)
- [x] BFS has Gemeinde-level employment by sex (STATPOP, since 2006)
- [x] swissdd provides voting data for pre-trends
- [x] BFS provides municipal boundaries for spatial RDD
- [x] Not studied with spatial RDD (checked Google Scholar)

**Data sources:**
- BFS STATPOP: Population by employment status, sex, Gemeinde
- BFS Employment Statistics: Erwerbstätige by Gemeinde, sex
- swissdd: Family policy referendum votes for pre-trends
- BFS bfs_get_base_maps(): Municipal boundaries for spatial analysis

---

## Idea 2: Nursing Care Financing Reform and Female Healthcare Employment

**Policy:** Implementation of federal nursing care financing law (2011) varied by canton in timing and generosity. AI (2010), BL (2011), AR (2016) adopted earlier/more generous provisions. This affects working conditions in the heavily female nursing workforce.

**Outcome:**
- Nursing workforce employment by Gemeinde
- Female healthcare employment rate
- Wages in healthcare sector (if available)

**Identification:** Spatial RDD at AI-AR, BL-SO, BL-AG borders.

**Why it's novel:** Existing literature focuses on patient outcomes, not labor market effects on the (predominantly female) nursing workforce.

**Feasibility check:**
- [x] Policy variation confirmed (swiss_policy_opportunities.json)
- [ ] Need to verify Gemeinde-level healthcare employment data availability
- [ ] Small number of treated cantons may limit border pairs

**Lower priority than Idea 1** due to data uncertainty and smaller geographic scope.

---

## Idea 3: Public Sector Personnel Regulation and Gender Pay Gap

**Policy:** Cantonal public sector personnel regulations (Personalgesetz) with varying provisions on pay transparency, part-time work rights, and parental leave. AG (2014), BE (2015), AR (2012), BL (2022) adopted reforms.

**Outcome:**
- Public sector gender wage gap by canton/Gemeinde
- Female share of public sector employment
- Part-time rates in public sector by sex

**Identification:** Spatial RDD at cantonal borders, focusing on public sector workers.

**Feasibility check:**
- [ ] Need to verify public sector wage data availability at Gemeinde level
- [ ] Public sector employment may be too sparse at Gemeinde level
- [ ] Staggered timing good (2012-2022)

**Lower priority** - data granularity concerns.

---

## Ranking

1. **Idea 1 (Childcare mandates)** - PURSUE
   - Best policy variation (2010 BE/ZH vs controls)
   - Confirmed Gemeinde-level outcome data
   - Multiple same-language border pairs
   - Clear theoretical mechanism (childcare → maternal LFP)
   - Not previously studied with spatial RDD

2. Idea 2 (Nursing care) - CONSIDER
   - Interesting gender angle (female-dominated workforce)
   - Need to verify data availability

3. Idea 3 (Public sector) - SKIP
   - Data granularity concerns
   - Less direct gender mechanism
