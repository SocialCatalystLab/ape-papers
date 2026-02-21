# Research Ideas

## Idea 1: The Patriarchy of the Public Square — How Open-Air Assembly Voting Shapes Gender Politics

**Policy:** The Landsgemeinde — Switzerland's centuries-old open-air assembly where citizens gather in a public square and vote by raising hands. Three cantons abolished it in the 1990s (Nidwalden 1996, Appenzell Ausserrhoden 1997, Obwalden 1998), while two cantons retained it (Glarus and Appenzell Innerrhoden, both still active today). This creates sharp spatial variation: at canton borders, adjacent municipalities face radically different democratic institutions.

**Outcome:** Gemeinde-level federal referendum results from swissdd (1981–2024). Primary outcomes: (1) voting patterns on gender-related federal referendums (maternity insurance 2004, abortion 2002, paternity leave 2020, marriage equality 2021); (2) overall turnout as proxy for political engagement. Covariates: BFS Gemeinde-level population, demographics. Supplementary: female representation in municipal councils (OpenParlData).

**Identification:** Spatial RDD at canton borders + Difference-in-Discontinuities (DiDisc) panel design.
- **Cross-sectional RDD:** Compare Gemeinden on opposite sides of canton borders where one side has Landsgemeinde and the other uses ballot voting. Running variable: signed distance to canton boundary. Example: AI (Landsgemeinde) vs. SG (ballot); GL (Landsgemeinde) vs. SG (ballot).
- **DiDisc (strongest design):** The AR–AI border pair is the cleanest test. Before 1997, both Appenzell half-cantons had Landsgemeinde → expect NO discontinuity at the border. After AR abolished in 1997, AR switched to ballot → any emerging discontinuity identifies the institutional effect. This differences out permanent cross-border differences.
- Additional border pairs: OW(abolished 1998)↔LU, NW(abolished 1996)↔LU.
- Panel of ~150 federal referendums × ~80–100 border Gemeinden = ~10,000+ observations.
- Inference: wild cluster bootstrap at canton level; permutation inference on border pairs.

**Why it's novel:** No existing paper studies the Landsgemeinde abolition using spatial RDD or any causal design focused on gender. Funk (2010, JEEA) studied Swiss mail ballot reform and turnout. Slotwinski & Stutzer (2023, EJ) studied suffrage timing with DiD. Neither examined the format of democratic participation — public show-of-hands vs. secret ballot — and its differential gender effects. The Landsgemeinde is one of the oldest democratic institutions in the world (dating to the 1200s); showing that its format systematically suppresses women's political voice challenges the romantic view of "pure democracy" and contributes to the literature on institutional design, gender norms, and political participation.

**Feasibility check:**
- ✅ Variation exists: sharp institutional change at canton borders in 1990s
- ✅ Data accessible: swissdd R package provides Gemeinde-level referendum results 1981–present (no API key); BFS provides Gemeinde boundaries (R package BFS)
- ✅ Not overstudied: Web search confirms no spatial RDD or causal gender study on Landsgemeinde
- ⚠️ Sample size: AI has ~6 Gemeinden, AR ~20, GL 3 (post-2011 merger, was 25 pre-2011). Pooling border pairs and using panel structure provides sufficient power. Pre-2011 data for GL has 25 Gemeinden.
- ⚠️ GIS complexity: learned from apep_0088 — must use `get_policy_border()` approach to extract only internal treated-control borders

**Key references:**
- Funk (2010) "Social Incentives and Voter Turnout" JEEA — Swiss mail ballot, turnout decreased
- Slotwinski & Stutzer (2023) "Women Leaving the Playpen" EJ — Swiss suffrage timing DiD
- Keele & Titiunik (2015) — Geographic boundaries as regression discontinuities
- Eugster et al. (2017) — Culture at Röstigraben language border, JEEA
- apep_0088 (energy laws spatial RDD) — methodological template

---

## Idea 2: Mandatory Kindergarten and Maternal Labor Supply — Spatial Evidence from the HarmoS Concordat

**Policy:** The HarmoS intercantonal concordat standardized Swiss schooling, including mandatory kindergarten from age 4 (two years instead of one). Adoption was staggered: Basel-Stadt (2005), St. Gallen/Thurgau/Zürich (2008), Fribourg (2009), others through 2015. Several cantons (Graubünden, Luzern, Nidwalden, Obwalden, Schwyz, Uri, Zug) rejected HarmoS or never implemented mandatory early kindergarten.

**Outcome:** Female labor force participation at Gemeinde level from BFS Strukturerhebung (2010–2023). Secondary: maternal part-time rates, female-to-male earnings ratios, childcare infrastructure (places per child).

**Identification:** Spatial RDD at borders where one canton implemented HarmoS and the adjacent did not.
- Key border pairs: BS(2005)↔SO(2012), ZH(2008)↔AG(2013), SG(2008)↔GR(rejected), BE(2013)↔LU(rejected).
- Running variable: signed distance from Gemeinde centroid to canton boundary.
- Staggered treatment enables DiDisc panel estimates across multiple adoption events.

**Why it's novel:** Existing work (Felfe & Lalive 2018, SJE&S) used DiD on the federal Anstossfinanzierung childcare stimulus. A separate paper used birthday-cutoff RDD within cantons. A spatial RDD at canton borders — comparing GENERAL EQUILIBRIUM effects on local labor markets — is genuinely new. Different from apep_0070, which studied after-school care mandates (Tagesbetreuung), not kindergarten entry age.

**Feasibility check:**
- ✅ Variation: clear staggered adoption, 10+ year span
- ✅ Data: BFS Strukturerhebung at Gemeinde level
- ✅ Not duplicate: apep_0070 studied after-school care, not kindergarten age
- ✅ Sample size: large cantons on both sides → many border Gemeinden
- ⚠️ Outcome data only starts 2010 (Strukturerhebung), limiting pre-period for early adopters

---

## Idea 3: Tax Marriage Penalty Reform and Female Labor Supply at Canton Borders

**Policy:** Swiss cantons use different income tax models for married couples: joint taxation (penalizes secondary earners — usually wives), Splitting (divides income by 1.8–2.0 before applying rates), or separate filing. Several cantons reformed their systems in the 2000s–2010s, reducing the marriage penalty. This differential creates spatial variation in the effective marginal tax rate faced by married women.

**Outcome:** Female labor force participation, hours worked, full-time vs. part-time rates. From BFS Strukturerhebung and SAKE labor force survey at cantonal/Gemeinde level.

**Identification:** Spatial RDD at borders where one canton has Splitting and the neighbor has joint taxation. The reform dates create temporal variation for a DiDisc design.

**Why it's novel:** The Swiss marriage penalty is well-known in policy debates but poorly studied causally. Most research uses cross-sectional comparisons. A spatial RDD at canton borders isolates the tax incentive effect from cultural/geographic confounds.

**Feasibility check:**
- ✅ Tax variation exists and is well-documented (ESTV publishes cantonal tax data)
- ⚠️ Treatment is continuous (tax rate differential), not binary — complicates RDD
- ⚠️ Reform timing data requires research into German-language cantonal tax laws
- ⚠️ Confounded by many other cantonal tax differences (rates, deductions, progressivity)
- ❌ Lower novelty — tax-and-female-labor literature is large internationally

---

## Idea 4: Domestic Violence Police Removal Powers (Wegweisung) and Women's Safety

**Policy:** Swiss cantonal police laws govern the authority to immediately remove domestic violence perpetrators from the home (Wegweisung/Fernhaltung). Cantons adopted these powers at different times through the 2000s–2010s, creating staggered spatial variation.

**Outcome:** Police-reported domestic violence incidents, women's shelter usage, hospital admissions for assault. From cantonal police statistics and public health data.

**Identification:** Spatial RDD at borders where one canton adopted Wegweisung powers and the neighbor had not (yet). DiDisc panel with staggered adoption.

**Why it's novel:** Strong policy relevance, connects to global debates on DV intervention. No spatial RDD on Swiss DV policy exists.

**Feasibility check:**
- ⚠️ Adoption dates poorly documented — requires archival research in German/French legal databases
- ⚠️ Outcome data at Gemeinde level near borders may be very sparse (DV incidents are relatively rare)
- ⚠️ DV reporting rates themselves change with policy → measurement confound
- ❌ Data uncertainty is high — may not be feasible without significant manual data collection

---

## Idea 5: The Long Shadow of Late Suffrage — Persistence of Gender Norms at Canton Borders

**Policy:** Swiss women's suffrage adoption varied from 1959 (Vaud, Neuchâtel) to 1990 (Appenzell Innerrhoden, forced by Supreme Court). This 31-year span created permanent spatial discontinuities at canton borders in the "dose" of female political participation.

**Outcome:** Modern gender outcomes (2010–2023): female labor force participation, gender wage gap, female political representation, voting on gender referendums. From BFS Strukturerhebung, swissdd.

**Identification:** Spatial RDD at borders between early and late-adopting cantons. Treatment: years of female suffrage exposure (continuous dosage).

**Why it's novel:** Slotwinski & Stutzer (2023) studied suffrage effects with DiD but not spatial RDD. A persistence study asking whether DECADES of differential female political participation left lasting marks on local gender norms would contribute to the Acemoglu/Alesina institutional persistence literature.

**Feasibility check:**
- ✅ Treatment variation well-documented (Wikipedia-level dates)
- ⚠️ Most German cantons adopted within 1 year (1970–71), creating very little within-language variation
- ⚠️ French/German border is confounded by language/culture (Röstigraben)
- ⚠️ Already well-studied by Slotwinski & Stutzer (2023, Economic Journal) using DiD
- ❌ Insufficient within-language variation for clean spatial RDD (only BS 1966 vs SO 1971 = 5 years; AR 1989 vs SG 1972 = 17 years but tiny sample)
