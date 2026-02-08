# Research Idea Ranking

**Generated:** 2026-01-30T20:07:37.686547
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 7195
**OpenAI Response ID:** resp_083178da8b5701b400697d01005654819083cb54ef35b87d3a

---

### Rankings

**#1: Do Energy Efficiency Resource Standards Reduce Residential Electricity Consumption? Evidence from Staggered State Adoption**
- **Score: 72/100**
- **Strengths:** Strong outcome–policy match (EERS targets efficiency; residential kWh is the object). Long panel (1990–2023) with many treated states makes modern staggered DiD/event-study feasible and informative about dynamics.
- **Concerns:** **Adoption is plausibly endogenous** (states with rising consumption, “green” preferences, or high prices may adopt), and EERS often arrives as part of a broader demand-side package (building codes, utility decoupling, rebates) that can confound interpretation. Annual data also risks **partial-year exposure** in the first “treated” calendar year.
- **Novelty Assessment:** **Moderately novel.** There’s a sizable policy/engineering evaluation literature on utility efficiency programs and some energy-econ work on related mandates, but fewer clean, heterogeneity-robust staggered DiD estimates focused specifically on EERS adoption timing at the state level.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (typically 8–15+ pre years for post-2004 adopters)
  - **Selection into treatment:** **Marginal** (policy choice likely correlated with environmental preferences and energy trends)
  - **Comparison group:** **Marginal** (never-treated states are systematically different; rely on not-yet-treated + diagnostics)
  - **Treatment clusters:** **Strong** (~27 treated states)
  - **Concurrent policies:** **Marginal** (RPS, building codes, DSM expansions, decoupling—must address explicitly)
  - **Outcome-Policy Alignment:** **Strong** (EERS targets reductions in electricity sales/usage; residential consumption is direct)
  - **Data-Outcome Timing:** **Marginal** (SEDS/EIA are calendar-year aggregates; EERS effective dates vary—first treated year may have <12 months exposure)
  - **Outcome Dilution:** **Strong** for **residential consumption** (broadly affected); **Marginal** if emphasizing **total** consumption (industrial/commercial dilute)
- **Recommendation:** **PURSUE (conditional on: (i) coding “first full exposure year” using effective dates; (ii) explicitly controlling/stratifying by other major energy policies—RPS, building codes, decoupling/DSM mandates; (iii) presenting strong pre-trend/event-study evidence and placebo outcomes such as industrial sales)**

---

**#2: State Energy Efficiency Resource Standards and Electricity Prices: Does Mandated Conservation Lower or Raise Consumer Costs?**
- **Score: 63/100**
- **Strengths:** High policy relevance (distributional and political economy hinges on bills/rates, not only kWh). Same strong panel structure and treatment clustering as Idea 1.
- **Concerns:** Prices are **much more confounded** than consumption (fuel mix shocks, wholesale market changes, cost recovery rules, grid investments). EERS is frequently bundled with **rate design changes (e.g., decoupling)** that directly affect prices—making the “EERS effect” hard to interpret without richer regulatory data.
- **Novelty Assessment:** **Moderately novel.** RPS→prices is well studied; EERS→prices is less developed in clean causal designs, but the outcome is inherently noisier and more policy-bundled.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong**
  - **Selection into treatment:** **Marginal**
  - **Comparison group:** **Marginal**
  - **Treatment clusters:** **Strong**
  - **Concurrent policies:** **Marginal → Weak risk** (if decoupling/rate reforms coincide tightly with EERS adoption and can’t be measured/controlled)
  - **Outcome-Policy Alignment:** **Marginal** (EERS targets savings; price impacts are a secondary/general-equilibrium outcome mediated by regulation)
  - **Data-Outcome Timing:** **Marginal** (annual average prices; partial-year exposure and regulatory lags likely)
  - **Outcome Dilution:** **Strong** (residential rates apply broadly to the measured population)
- **Recommendation:** **CONSIDER (only if paired with regulatory controls or design tweaks: e.g., add decoupling adoption, restructuring status, fuel-cost pass-through proxies; emphasize medium-run effects with lags; interpret as “policy bundle associated with EERS adoption” if separation is impossible)**

---

**#3: Renewable Portfolio Standards and Residential Energy Burden: Do Clean Energy Mandates Disproportionately Affect Low-Income Households?**
- **Score: 48/100**
- **Strengths:** Distributional incidence is a genuinely important policy question, and ACS microdata offers large samples for heterogeneity by income group.
- **Concerns:** As written, this fails a key DiD requirement: **ACS starts in 2005**, so many prominent RPS adopters have **0–2 pre-years** (or none), undermining pre-trends tests. Also, “energy burden” can be a **mismatched/attenuated outcome** if it includes non-electric fuels or if many renters have utilities included in rent (systematic measurement issues by income).
- **Novelty Assessment:** **Fairly novel angle** (distributional burden is less studied than average price effects), but the identification/data alignment problems are first-order.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (for early/mid adopters; cannot credibly test parallel trends on the full adoption set with ACS-only)
  - **Selection into treatment:** **Marginal** (policy adoption correlated with preferences and possibly energy market conditions)
  - **Comparison group:** **Marginal** (never-treated states differ; also many “controls” already treated early)
  - **Treatment clusters:** **Strong** in principle (28+), but **effective clusters with adequate pre-periods shrink** if you drop early adopters
  - **Concurrent policies:** **Marginal** (RPS often bundled with net metering, tax credits, cap-and-trade in some states)
  - **Outcome-Policy Alignment:** **Marginal → Weak risk** unless you use **electricity-only burden** (RPS should primarily affect electricity prices; total home energy can be dominated by gas/heating oil)
  - **Data-Outcome Timing:** **Marginal** (ACS utility costs refer to recent/monthly amounts; RPS impacts may phase in with compliance schedules—timing/lag structure needs care)
  - **Outcome Dilution:** **Marginal** (RPS affects electricity users broadly, but “burden” dilution occurs if the numerator includes large non-electric components or missingness among renters)
- **Recommendation:** **SKIP (unless redesigned)**. To become viable: **(i)** restrict to **late adopters** with ≥5 pre-ACS years (or find earlier expenditure microdata), **(ii)** focus on **electricity-only burden** (and handle “utilities included in rent”), **(iii)** pre-register a lag structure tied to RPS compliance ramps, not adoption dates alone.

---

**#4: State Indoor Clean Air Acts (Smoking Bans) and Restaurant Employment: Revisiting the "Bar/Restaurant Apocalypse" Hypothesis with Modern DiD Methods**
- **Score: 42/100**
- **Strengths:** Excellent data frequency (state-quarter QCEW) and ample pre-periods; modern staggered DiD would improve on some early methods.
- **Concerns:** **Low novelty** (this is one of the most studied policy questions in applied public economics/health econ). Identification is also muddied because many “state” bans were preceded by **local ordinances** and partial restrictions, so the statewide adoption date may not represent a sharp treatment change; plus NAICS 72 aggregates businesses differentially affected (bars vs hotels), risking dilution.
- **Novelty Assessment:** **Low.** There are many papers and reports on smoking bans and hospitality employment; a modern estimator is incremental rather than agenda-setting.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (1995 onward; bans mostly 2003+)
  - **Selection into treatment:** **Marginal** (public health politics; could correlate with local trends/urbanization)
  - **Comparison group:** **Marginal** (remaining never-treated are atypical; also local bans create contamination)
  - **Treatment clusters:** **Strong** (~30)
  - **Concurrent policies:** **Weak risk** (local pre-emption/local bans, tax changes on tobacco, and other contemporaneous public health policies can coincide and blur “treatment”)
  - **Outcome-Policy Alignment:** **Marginal** (ban targets bars/restaurants; NAICS 72 includes accommodation and segments less affected)
  - **Data-Outcome Timing:** **Marginal** (quarterly helps, but effective dates can be mid-quarter; need “first full quarter/year” exposure coding)
  - **Outcome Dilution:** **Marginal** (policy primarily affects a subset of NAICS 72 and potentially only the smoking clientele margin)
- **Recommendation:** **SKIP** (unless the institute specifically wants a replication/cleanup of a classic debate). If pursued, it needs a design that handles **local policy rollout** (e.g., county/city variation) rather than state adoption alone.

---

### Summary

This is a solid batch conceptually, but only **Idea 1** clears the bar as a genuinely promising institute project without major redesign. **Idea 4** is policy-relevant and feasible but more vulnerable to confounding from regulatory/rate-setting bundles. **Idea 2** is the most interesting distributional question but currently fails on **pre-treatment coverage and outcome alignment**; **Idea 3** is largely a low-novelty replication with real treatment-contamination risks.