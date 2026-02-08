# Research Ideas

## Idea 1: Do Energy Efficiency Resource Standards Reduce Residential Electricity Consumption? Evidence from Staggered State Adoption

**Policy:** Energy Efficiency Resource Standards (EERS) — state-level mandates requiring utilities to achieve specific energy savings targets through customer efficiency programs. ~27 states adopted EERS between 1999 (Texas, first) and 2015+, with staggered timing and varying stringency (0.5%-3% annual savings targets). Never-treated states provide a natural control group.

**Outcome:** State-level residential and total electricity consumption from EIA SEDS (State Energy Data System) and electricity retail sales data. Annual state-level data from 1990-2023. Also: residential electricity prices from EIA retail sales data. Secondary outcomes: per-capita consumption, industrial/commercial consumption.

**Identification:** Staggered difference-in-differences using Callaway and Sant'Anna (2021) estimator. Treatment = year of EERS adoption. Units = states × years. Exploit staggered timing across 27+ treated states with 10+ never-treated states as control. Pre-treatment periods: most states adopted after 2004, giving 5-15 years of pre-treatment data (1990-2004). Cluster SEs at state level.

**Why it's novel:** Despite EERS being one of the most widespread US energy policies, no rigorous causal study using modern staggered DiD estimators exists. Existing work is descriptive or uses simple panel regressions. The Callaway-Sant'Anna approach addresses treatment effect heterogeneity that is particularly relevant here since EERS stringency varies across states and over time. Novel contribution: first clean causal estimate of EERS effectiveness + event-study dynamics showing whether energy savings are immediate or cumulative.

**Feasibility check:**
- Variation: ✓ 27+ treated states, staggered 1999-2015+, 10+ never-treated controls
- Data access: ✓ EIA SEDS API confirmed working (DEMO_KEY), state-level annual data 1990-2023
- Pre-treatment: ✓ 5-15 years pre-treatment for most adoption cohorts
- Novelty: ✓ No staggered DiD study found in NBER/Google Scholar search
- Sample size: ✓ 50 states × 30+ years = 1,500+ state-year observations


## Idea 2: Renewable Portfolio Standards and Residential Energy Burden: Do Clean Energy Mandates Disproportionately Affect Low-Income Households?

**Policy:** Renewable Portfolio Standards (RPS) — state mandates requiring utilities to source a minimum percentage of electricity from renewable sources. 28 states + DC adopted RPS with staggered timing from 1997-2020. Well-documented adoption dates from NCSL.

**Outcome:** Energy burden = (household energy costs / household income). Constructed from ACS microdata (utility costs variables + household income) at the state-year level, stratified by income quintile. Secondary: residential electricity prices from EIA.

**Identification:** Staggered DiD with CS estimator. Treatment = year of RPS adoption. Key innovation: estimate heterogeneous treatment effects by income quintile to capture distributional consequences. Pre-treatment: 1997 first adoption, ACS available from 2005, so limited pre-treatment for early adopters but good coverage for post-2005 adopters.

**Why it's novel:** While RPS effects on average electricity prices are studied (NBER WP 30502), no paper examines the distributional incidence — specifically whether RPS increases energy burden disproportionately for low-income households. This is a first-order policy question given that low-income households already spend ~8-10% of income on energy vs ~3% for high-income households.

**Feasibility check:**
- Variation: ✓ 28+ treated states, staggered adoption
- Data access: ✓ ACS via IPUMS (API key confirmed), EIA API confirmed
- Pre-treatment: ⚠ Limited for early adopters (ACS starts 2005, many RPS adopted 2004-2007)
- Novelty: ✓ Distributional angle not studied
- Sample size: ✓ ACS individual-level data, millions of observations per year


## Idea 3: State Indoor Clean Air Acts (Smoking Bans) and Restaurant Employment: Revisiting the "Bar/Restaurant Apocalypse" Hypothesis with Modern DiD Methods

**Policy:** Comprehensive state-level smoking bans in restaurants and bars. ~30 states adopted comprehensive bans between 2003-2015 with staggered timing. Well-documented by American Nonsmokers' Rights Foundation.

**Outcome:** Restaurant and accommodation sector employment (NAICS 72) from BLS Quarterly Census of Employment and Wages (QCEW). State-quarter level data from 1995-2023. Secondary: establishment counts, average weekly wages.

**Identification:** Staggered DiD with CS estimator. Treatment = year of comprehensive statewide smoking ban. Exploit staggered adoption across ~30 states. Pre-treatment: bans started ~2003, data available from 1995, giving 8+ years pre-treatment.

**Why it's novel:** Early 2000s studies on smoking bans and employment used simple DiD or cross-sectional methods and found mixed results. No study applies modern heterogeneity-robust DiD estimators (CS, Sun-Abraham) to revisit this classic question. The original evidence was highly contested (tobacco industry-funded studies vs. public health studies). A modern re-evaluation with proper methods would clarify the record.

**Feasibility check:**
- Variation: ✓ ~30 treated states, staggered 2003-2015
- Data access: ✓ QCEW data publicly available via BLS
- Pre-treatment: ✓ 8+ years pre-treatment for most cohorts
- Novelty: ✓ No modern staggered DiD re-evaluation found
- Sample size: ✓ 50 states × 100+ quarters = 5,000+ state-quarter observations


## Idea 4: State Energy Efficiency Resource Standards and Electricity Prices: Does Mandated Conservation Lower or Raise Consumer Costs?

**Policy:** Same EERS policy as Idea 1.

**Outcome:** Residential and commercial electricity prices (cents/kWh) from EIA retail sales data. Annual state-level, 1990-2023.

**Identification:** Same staggered DiD as Idea 1, but with electricity prices as the outcome rather than consumption. Tests whether EERS-induced efficiency gains translate to lower bills (conservation effect) or whether utility revenue recovery mechanisms lead to higher per-kWh prices (rate impact effect).

**Why it's novel:** Theoretical ambiguity: EERS should reduce consumption, but utilities may raise rates to recover fixed costs from lower sales volume ("utility death spiral"). No causal study separates these two channels. This complements Idea 1 — together they tell the full story of EERS effectiveness.

**Feasibility check:**
- Variation: ✓ Same as Idea 1
- Data access: ✓ EIA retail sales API confirmed working
- Pre-treatment: ✓ Same as Idea 1
- Novelty: ✓ Price channel of EERS not causally estimated
- Sample size: ✓ Same as Idea 1
