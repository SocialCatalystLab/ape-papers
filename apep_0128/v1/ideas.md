# Research Ideas: Netherlands Policy Evaluation (Revised)

## PIVOTED: Original plan required CBS municipality-level data that is currently unavailable.

---

## Idea 1 (REVISED): The Nitrogen Shock and Dutch Housing Prices: A Synthetic Control Analysis

**Policy:** On May 29, 2019, the Dutch Council of State (Raad van State) invalidated the Integrated Approach to Nitrogen (PAS), immediately halting ~18,000 construction projects. This created a sharp, unanticipated supply shock to the Dutch housing market.

**Outcome:** National-level real house price indices from FRED (Bank for International Settlements data) and Eurostat.

**Identification:**
- **Synthetic control method (SCM):** Construct a synthetic Netherlands from weighted average of comparison countries (Germany, Belgium, France, Austria, UK, Denmark, Sweden, Finland)
- Treatment: May 2019 nitrogen ruling
- Pre-treatment fit: 2010-2019Q1
- Post-treatment: 2019Q2-2023

**Economic mechanisms:**
- Supply constraint → higher prices at national level
- Netherlands-specific shock with well-documented cause
- Clear policy date with no anticipation

**Why it's novel:** While the nitrogen crisis has been extensively covered in Dutch media, there is no rigorous causal analysis using synthetic control methods. This would be the first to quantify the aggregate housing price effect.

**Feasibility check:**
- ✓ FRED has BIS housing price indices for Netherlands and ~30 comparison countries
- ✓ Eurostat has harmonized house price indices (prc_hpi_q)
- ✓ Clean treatment date (May 29, 2019)
- ✓ No access barriers - all data publicly available via API
- ✓ Sufficient pre-treatment periods for SCM fit
- ⚠️ Single treated unit limits statistical inference (placebo tests needed)

**Data sources:**
- FRED: QNLR628BIS (Netherlands), QDER628BIS (Germany), QBER628BIS (Belgium), etc.
- Eurostat: prc_hpi_q (House Price Index by country)

---

## Idea 2: Netherlands Online Gambling Legalization and Problem Gambling

**Policy:** October 1, 2021: Netherlands legalized online gambling with licensed operators (Wet op de Kansspelen).

**Outcome:** Google Trends data on gambling-related search terms, consumer spending patterns from Eurostat.

**Identification:**
- Difference-in-differences comparing Netherlands to Belgium/Germany before and after October 2021
- Sharp policy date with no spillovers to neighboring countries

**Economic mechanisms:**
- Legal access → increased gambling participation
- Substitution from illegal to legal gambling operators
- Potential effects on household spending and debt

**Why it's novel:** First causal analysis of Dutch online gambling legalization using comparative methods.

**Feasibility check:**
- ✓ Clear treatment date
- ⚠️ Limited outcome data at granular level
- ⚠️ COVID-19 timing overlap reduces power
- Status: CONSIDER - may proceed if primary idea fails

---

## Idea 3: Dutch Squatting Ban and Housing Market Outcomes

**Policy:** October 1, 2010: Netherlands criminalized squatting (Wet kraken en leegstand), previously tolerated.

**Outcome:** BIS housing price indices, residential vacancy rates from CBS.

**Identification:**
- Synthetic control comparing Netherlands to European countries without similar policy changes
- Pre-treatment: 2005-2010Q3, Post-treatment: 2010Q4-2015

**Economic mechanisms:**
- Reduced squatting risk → higher returns for property owners
- Potentially increased investment in previously vacant properties
- Effects concentrated in urban areas with historical squatting

**Why it's novel:** Unique natural experiment on property rights enforcement and housing investment.

**Feasibility check:**
- ✓ Clean policy date
- ✓ Historical BIS data available via FRED
- ⚠️ Housing market crisis (2008-2012) confounds interpretation
- Status: CONSIDER - historical data period feasible but confounded

---

## Idea 4: Dutch Carbon Tax and Industrial Emissions

**Policy:** Netherlands CO2 tax introduced in 2021, escalating annually for industrial emitters.

**Outcome:** EU ETS emissions data, industrial production indices from Eurostat.

**Identification:**
- Difference-in-differences with other EU countries under ETS
- Compare high-emitting vs. low-emitting sectors within Netherlands

**Economic mechanisms:**
- Carbon pricing → reduced emissions or relocation
- Technology adoption and capital investment shifts
- Competitiveness effects relative to non-taxed countries

**Why it's novel:** Assesses marginal effect of national carbon pricing above EU ETS.

**Feasibility check:**
- ✓ ETS data publicly available
- ⚠️ Recent implementation limits post-treatment data
- ⚠️ Energy crisis (2022) severely confounds interpretation
- Status: SKIP - too many confounding shocks in treatment period

---

## Recommended Approach: Idea 1 (Synthetic Control)

The nitrogen crisis synthetic control study offers:
1. **Clean identification:** Sharp, unanticipated shock with documented date
2. **Available data:** FRED/BIS and Eurostat data accessible via public APIs
3. **Novel contribution:** First rigorous causal estimate of aggregate price effects
4. **Replicable:** All data sources are public and permanent

**Limitations to address:**
- Single treated unit: Will use placebo tests (permutation inference)
- COVID-19 confound: Will truncate at 2020Q1 for main analysis, show extended results
- General equilibrium: May understate effect if construction workers migrated
