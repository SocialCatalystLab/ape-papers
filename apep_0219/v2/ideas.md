# Research Ideas

## Idea 1: The Distress Label Trap — Does ARC's "Distressed" Designation Help or Harm Appalachian Counties?

**Policy:** The Appalachian Regional Commission (ARC) classifies ~428 Appalachian counties annually into five economic tiers based on a Composite Index Value (CIV) combining unemployment, per capita market income, and poverty rates. Counties ranked in the worst national decile receive the "Distressed" label, unlocking an 80% federal match rate (vs. 70% for "At-Risk") and exclusive access to the ARC Distressed Counties Program. The threshold is the 10th national percentile of the CIV.

**Outcome:** County-level economic outcomes from BLS LAUS (unemployment), Census SAIPE (poverty, median income), BEA REIS (employment, personal income), ACS (population, demographics, insurance), and County Health Rankings (health outcomes). Panel: FY2007-FY2017+ (11+ years of CIV data).

**Identification:** Regression Discontinuity Design at the 10th-percentile CIV threshold. The running variable (CIV) is continuous and publicly available with 11+ years of annual data. Treatment: crossing from "At-Risk" to "Distressed" status. This creates a sharp discontinuity in federal match rates (80% vs 70%) and access to exclusive distressed-county funding. Panel RDD pooling across years with county and year fixed effects.

**Why it's novel:**
- **Zero existing RDD papers** using the ARC distressed threshold as a forcing variable
- **Counter-intuitive hypothesis:** The "distressed" label may stigmatize counties, discouraging private investment and creating dependency traps — even as public funding increases. Place-based aid may substitute for rather than complement private economic activity.
- **Strategic behavior angle:** Counties near the threshold may manipulate their statistics to maintain distressed status (moral hazard), similar to school accountability gaming
- Challenges the conventional wisdom that more federal aid → better local outcomes

**Feasibility check:**
- ✅ Running variable (CIV) confirmed available as Excel downloads from ARC for FY2007-2017+
- ✅ Threshold confirmed sharp: ~0.3 CIV-point gap at boundary, ~41 counties within ±5 CIV points per year
- ✅ Treatment: 80% vs 70% match rate is a concrete, measurable fiscal discontinuity
- ✅ Outcome data: abundant county-level panel from BLS, Census, BEA (all free APIs)
- ✅ Not in APEP database, not found in existing RDD literature
- ⚠️ Potential concern: counties near threshold may be serially correlated across years (same counties hover near cutoff). Solution: cluster SEs at county level, use donut-hole RDD as robustness.

---

## Idea 2: Does Superfund Listing Improve Community Health? Revisiting the HRS Score Threshold with an Environmental Justice Lens

**Policy:** EPA scores contaminated sites using the Hazard Ranking System (HRS). Sites scoring ≥28.5 are placed on the National Priorities List (NPL) and become eligible for federal Superfund cleanup funds. The HRS score is a continuous running variable with a sharp regulatory cutoff.

**Outcome:** CDC WONDER county-level mortality (cancer, respiratory), County Health Rankings (health outcomes, premature death), ACS demographics (population composition, income, race), HMDA lending data. Cross-sectional + long-run panel.

**Identification:** RDD at HRS score = 28.5, following Greenstone & Gallagher (2008, QJE). They studied housing prices and found nulls. No one has applied this clean RDD to health outcomes or demographic sorting despite 18 years of additional data and the explosion of environmental justice research.

**Why it's novel:**
- The last RDD at HRS 28.5 was Greenstone & Gallagher (2008) — 18-year gap in the literature
- Fresh angle: health outcomes + environmental justice (73 million Americans live near Superfund sites, disproportionately minority/low-income)
- Potential to overturn the famous null: cleanup may help health even if housing prices don't respond

**Feasibility check:**
- ✅ HRS scores available from EPA SEMS database
- ✅ ~690 sites with scores near 28.5 threshold
- ✅ Health outcome data: CDC WONDER, County Health Rankings (free)
- ✅ Proven RDD design (QJE 2008 precedent)
- ⚠️ Cross-sectional nature limits panel exploitation; sample size ~690 total sites
- ⚠️ Existing literature (Currie et al. 2011 AER) used DiD rather than RDD for health — may indicate RDD is underpowered for health outcomes

---

## Idea 3: Flood Zone Mandates and Credit Access — An NFIP Boundary Discontinuity Design

**Policy:** FEMA designates Special Flood Hazard Areas (SFHAs) via the National Flood Hazard Layer. Properties inside SFHA zones face a mandatory flood insurance purchase requirement for federally-backed mortgages. This creates a sharp spatial discontinuity at the SFHA boundary.

**Outcome:** HMDA mortgage lending data (loan volume, denial rates, interest rate spreads, loan-to-value ratios) and CRA small business lending data, both available at census tract level. ACS demographics for sorting effects.

**Identification:** Spatial RDD at the SFHA boundary, following Keele & Titiunik (2015) methodology. Running variable: share of census tract area inside SFHA (or signed distance from tract centroid to nearest SFHA boundary). Treatment: mandatory flood insurance requirement increases cost of homeownership and tightens lending conditions.

**Why it's novel:**
- Existing flood zone RDDs focus on housing prices (4-6 papers). Zero papers examine credit access, lending patterns, or small business formation at the boundary.
- Counter-intuitive angle: the insurance mandate (designed to protect) may restrict credit access for marginal borrowers, creating a regressive wealth gap at flood boundaries
- Fresh data: HMDA post-2018 has much richer loan-level variables than older studies used

**Feasibility check:**
- ✅ SFHA boundaries available as GIS polygons (FEMA NFHL)
- ✅ HMDA data available at census tract level (millions of loans, 2018-2024)
- ✅ CRA small business lending at tract level
- ⚠️ No property-level geocoding in public NFIP data (1-decimal lat/lon precision)
- ⚠️ Spatial RDD requires careful boundary segment analysis (Keele-Titiunik methodology)
- ⚠️ SFHA boundary reflects *flood risk*, so outcomes may reflect risk avoidance rather than insurance mandate effects
