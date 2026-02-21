# Research Ideas

## Idea 1: Where Cultural Borders Cross — Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy

**Policy:** Switzerland's cultural geography was shaped by two historical events: (1) the Roman-Germanic language settlement boundary (established ~5th century CE, codified in federal language law of 1938, Art. 70 revised 1996), which created the Röstigraben dividing French- and German-speaking municipalities; and (2) the Protestant Reformation (1520s–1530s), when cantons chose either Protestant or Catholic confession — a choice preserved in cantonal constitutions through the present day. These two pre-determined cultural boundaries jointly shape modern gender attitudes and outcomes. French-speaking Switzerland is more gender-progressive; Protestant areas tend toward greater economic individualism (Basten & Betz 2013, AEJ:Policy). But nobody has studied how these two cleavages *interact*: Is a French-Catholic municipality more like a French-Protestant one (language dominates) or a German-Catholic one (religion dominates)?

**Outcome:** Municipality-level referendum voting on gender-relevant issues (1981–2024) from swissdd: equal rights (1981), maternity insurance (1984, 1999, 2004), paternity leave (2020), marriage for all (2021), plus ~15 additional gender-adjacent referenda. Secondary outcomes: marriage/divorce rates from BFS vital statistics. N ≈ 2,100 municipalities × 20+ gender referenda ≈ 40,000+ observations.

**Identification:** Multi-dimensional spatial RDD exploiting two borders:
1. **Language border RDD** (replicates/extends Eugster et al. 2011): Running variable = distance from municipality centroid to nearest language border segment. Sharp discontinuity: within 5 km, French-speaker share drops from 80%+ to below 20%.
2. **Religion heterogeneity**: Interact language border estimate with historical confessional affiliation (majority Protestant vs. Catholic from 2000 census or earlier). Estimate whether the language gap in gender progressivism is amplified or attenuated in Catholic regions.
3. **Religion border RDD** (extends Basten & Betz 2013): Separate RDD at the confessional boundary, now applied to gender outcomes (never done).
4. **Full intersection**: Multi-score RDD (Cattaneo, Titiunik, Vazquez-Bare 2020) with two running variables at the frontier where both borders are nearby — concentrated in the Fribourg region, where French-Catholic, German-Catholic, French-Protestant, and German-Protestant municipalities all coexist.

Time-varying estimates: Compute the border gaps for each referendum year (1981–2024) to track convergence dynamics. Does the language gap close faster than the religion gap?

**Why it's novel:**
- **No paper has combined language and religion borders** in Switzerland (confirmed via exhaustive literature review — Eugster et al. study language only; Basten & Betz study religion only; nobody studies their interaction)
- **No multi-dimensional spatial RDD** has been applied to cultural borders anywhere
- **First intersectional spatial design** in cultural economics — tests whether cultural cleavages are additive or multiplicative
- Gender outcomes at the Röstigraben are understudied: only Steinhauer (2018 WP, unpublished) examines female LFP; no paper studies gender referendum voting at the border
- Dynamic analysis (40-year evolution of border gaps) is new
- Speaks to fundamental question: does culture operate modularly (each dimension independent) or intersectionally (dimensions interact)?

**Feasibility check:**
- ✅ swissdd validated: 4,194 rows for 1981, 4,244 rows for 2021, ~2,122 unique municipalities
- ✅ BFS validated: 12 marriage/divorce datasets, 113 gender/population datasets at municipal level
- ✅ SMMT validated: municipality harmonization across time
- ✅ Language border well-defined (BFS codes dominant language per municipality)
- ✅ Religious classification available from historical census (2000 census has municipal-level dominant religion)
- ✅ Spatial shapefiles available from BFS (EPSG:2056 LV95)
- ✅ RDD methodology established: `rdrobust`, `rdmulti`, `SpatialRDD` R packages
- ✅ Sample size: ~2,100 municipalities × 20+ referenda = 40,000+ observations
- ✅ Not in APEP list (existing Swiss papers study different questions: policy feedback, voter demobilization, Landsgemeinde, attitude convergence)

---

## Idea 2: Childcare Mandates and the Maternal Employment Gap — Spatial Evidence from Swiss Canton Borders

**Policy:** In 2010, cantons of Bern and Zurich mandated municipal childcare provision. Other cantons (Aargau, Solothurn, Thurgau, Lucerne) had no such mandate. This creates spatial discontinuities at canton borders. Additional cantons adopted childcare mandates between 2012–2020 (Basel-Stadt, Vaud, Geneva), creating staggered timing.

**Outcome:** Female employment rates, part-time work shares, gender earnings gaps at the municipal level from BFS STATENT (2011–2024). Secondary: fertility rates from BFS vital statistics.

**Identification:** Spatial RDD at canton borders where mandates change, combined with staggered DiD for cantons adopting at different times. Compare municipalities 0–10 km from border on mandate side vs. no-mandate side.

**Why it's novel:** apep_0070 studied childcare mandates for *policy feedback* (how mandates affect voting on federal family policy). Nobody has studied the *economic* effects — female employment, earnings, fertility — using the spatial design.

**Feasibility check:**
- ✅ Policy dates confirmed (Bern/Zurich 2010)
- ⚠️ Need to verify BFS has employment-by-gender at municipal level from STATENT
- ⚠️ Only 2 treated cantons initially (thin for DiD); more if later adopters confirmed
- ✅ Spatial design at borders is proven (used in apep_0069, 0070, 0438)

---

## Idea 3: The Long Shadow of Late Suffrage — How Women's Political Enfranchisement Shaped Economic Equality in Swiss Cantons

**Policy:** Swiss cantons adopted women's suffrage between 1959 (Vaud, Neuchâtel) and 1971 (federal mandate), with Appenzell Innerrhoden forced by federal court in 1990. This staggered adoption provides 12+ years of variation in exposure to female political participation.

**Outcome:** Long-run gender equality outcomes: female representation in cantonal parliaments, female labor force participation, gender pay gaps (cantonal data from BFS), and gender referendum voting patterns (swissdd).

**Identification:** Staggered DiD exploiting cantonal suffrage adoption timing (1959–1971). Event study with 10+ pre-periods (1949–1959) and 50+ post-periods (1971–2024). Treatment = years since women's suffrage adoption.

**Why it's novel:** Most suffrage literature studies the US or cross-country. Swiss within-country variation with rich outcome data is unique. Long-run effects (50+ years) rarely studied due to data limitations.

**Feasibility check:**
- ✅ Suffrage dates well-documented (15 cantons adopted 1959–1971)
- ⚠️ Only 15 treated units before 1971 (then ALL adopt = no control group after 1971)
- ⚠️ Cantonal-level data only (26 units) — thin for inference
- ⚠️ BFS time series at cantonal level may not go back to 1959
- ❌ Sample size concern: 26 cantons × ~65 years = ~1,700 observations at cantonal level
