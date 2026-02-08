# Research Idea Ranking

**Generated:** 2026-02-01T23:34:59.469004
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7645

---

### Rankings

**#1: America’s First Supervised Drug Injection Sites and Neighborhood Overdose Deaths (NYC)**
- **Score: 78/100**
- **Strengths:** Extremely high policy salience (“first in the U.S.”) with a clear intervention date and credible within-city counterfactual construction (synthetic control / matched neighborhood controls). NYC has unusually long, stable pre-policy overdose series and large baseline overdose counts, so power is plausible even at neighborhood level.
- **Concerns:** Only **two sites** and coarse public geography (UHF=42 areas) creates risk that results hinge on a small number of treated units and any idiosyncratic neighborhood shock (encampment sweeps, service-provider changes, policing). Spillovers (people traveling to OPCs from nearby UHFs) can blur “treated vs control,” biasing estimates toward zero.
- **Novelty Assessment:** **High.** There is work on SIF/OPC impacts in Canada and some U.S. descriptive/short-run outcomes (and crime/public order), but **credible U.S. evidence on overdose mortality** remains thin and this would be among the first serious causal designs.
- **Recommendation:** **PURSUE (conditional on: securing outcome data at finer geography than UHF or demonstrating robustness to geography choice; pre-specifying spillover rings/“donut” buffers; implementing randomization inference/placebo tests appropriate for few treated units).**

---

**#2: Naloxone Vending Machines and Neighborhood Overdose Deaths (Clark County, NV)**
- **Score: 66/100**
- **Strengths:** Clear “cool” intervention with known placement and an existing descriptive evaluation to beat; large county with meaningful overdose counts and multiple years post-rollout. Strong opportunity to improve on prior ARIMA-style forecasting using SCM, augmented SCM, or within-county distance-to-machine designs.
- **Concerns:** County-level SCM is vulnerable because the intervention is **hyper-local** (3 machines) while outcomes are county aggregates—likely **dilution** unless you can measure outcomes in tight catchments (ZIP/tract). 2019–2021 is a messy window (COVID-era shocks, fentanyl shifts, other harm-reduction expansions), raising confounding risk if not handled carefully.
- **Novelty Assessment:** **Moderate.** “Naloxone access” is heavily studied, but **vending machines specifically** have far fewer rigorous causal papers; still, this is not as frontier as OPC mortality or psychedelics.
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: you can obtain ZIP/tract-level overdose deaths or EMS overdose calls and credibly define near/far exposure; document other naloxone initiatives and control for them).**

---

**#3: Fentanyl Test Strip (FTS) Distribution Intensity and Overdose Deaths (Massachusetts)**
- **Score: 49/100**
- **Strengths:** Massachusetts data infrastructure (EMS incidents + program distribution) is unusually strong, and the policy debate is real—if you could identify effects cleanly, it would matter. Quarterly EMS outcomes are well-aligned with near-term behavioral harm reduction channels.
- **Concerns:** The core threat is **selection/endogeneity**: distribution intensity almost surely rises where overdoses are rising (reverse causality). Even with an IV like “distance to harm reduction program,” exclusion is questionable (program locations correlate with unobserved risk environment), and **county-level aggregation (14 counties)** is a serious inference and dilution problem.
- **Novelty Assessment:** **Moderate.** FTS effectiveness is debated and studied in public health; fewer clean causal designs exist, but the topic is not “empty.”
- **DiD Assessment (if using DiD on county intensity):**
  - **Pre-treatment periods:** **Strong** (2017–2021 gives ≥5 years/20 quarters)
  - **Selection into treatment:** **Weak** (distribution intensity responds to overdose conditions; likely targeted to rising-need areas)
  - **Comparison group:** **Marginal** (MA counties differ a lot; would need rich controls or move to smaller geographies)
  - **Treatment clusters:** **Marginal/Weak** (only ~14 counties; effective clusters even fewer if intensity changes are correlated)
  - **Concurrent policies:** **Marginal/Weak** (simultaneous naloxone, MOUD, policing, funding changes)
  - **Outcome-Policy Alignment:** **Strong** for **EMS overdoses**; **Marginal** for mortality if mechanism is mainly behavior change among a subset
  - **Data-Outcome Timing:** **Strong** with quarterly outcomes *if* treatment is measured quarterly and lagged appropriately
  - **Outcome Dilution:** **Weak** (FTS reaches a small fraction of people at risk; county-level deaths/EMS totals include many unaffected)
- **Recommendation:** **SKIP as currently framed.** Becomes **CONSIDER** only if you can (i) move to **ZIP/tract** outcomes, (ii) credibly instrument supply shocks (e.g., procurement disruptions, funding formula discontinuities), or (iii) evaluate **intermediate outcomes** tightly linked to FTS use (toxicology mix, fentanyl-involved share among overdoses in exposed micro-areas).

---

**#4: Oregon Psilocybin “Opt-Out” Bans and Mental Health Outcomes**
- **Score: 46/100**
- **Strengths:** Very high “wow factor” and genuine first-mover policy with lots of within-state variation (many local opt-outs). The policy is salient nationally, and a well-designed study would attract attention.
- **Concerns:** Biggest issue is **outcome dilution/mismatch**: psilocybin clients are tiny relative to county population, and many clients travel across jurisdictions, so county-level suicide/BRFSS mental-health-days effects are likely mechanically near zero even if the therapy works. Treatment timing is also tricky: bans pass in November elections, service-center availability rolls out gradually, and “access” is not a sharp on/off at the county boundary.
- **Novelty Assessment:** **Very high** on legalized psychedelic therapy access; close to no economics/policy causal evidence exists yet.
- **DiD Assessment (for staggered DiD on local bans):**
  - **Pre-treatment periods:** **Marginal** (effectively 2020–2022 is only 3 years; and “pre” is weird because services weren’t operating yet)
  - **Selection into treatment:** **Marginal/Weak** (local votes may reflect underlying attitudes/risk trends correlated with outcomes)
  - **Comparison group:** **Marginal** (opt-out places may systematically differ—rurality, politics, baseline drug mortality)
  - **Treatment clusters:** **Strong** (100+ jurisdictions if you truly analyze at city/jurisdiction level; weaker if collapsed to counties)
  - **Concurrent policies:** **Marginal** (ongoing opioid/mental health initiatives; plus post-pandemic dynamics)
  - **Outcome-Policy Alignment:** **Marginal** (population suicide/BRFSS are very distal to a niche therapy market)
  - **Data-Outcome Timing:** **Marginal/Weak** (ban vote timing vs actual access; BRFSS measured throughout year; “treated year” may have partial/zero exposure)
  - **Outcome Dilution:** **Weak** (affected share of population is far <10% in most places)
- **Recommendation:** **SKIP for population mental health outcomes.** Becomes **CONSIDER** if re-scoped to outcomes with tight alignment and less dilution, e.g., **utilization, travel patterns, prices/wait times, substitution away from illicit self-medication**, or localized outcomes among likely-user subpopulations (if data exist).

---

**#5: Rhode Island’s First State-Regulated OPC and Geographic Overdose Patterns**
- **Score: 44/100**
- **Strengths:** Data environment is excellent (rapid reporting, granular geography), and the institutional angle (state-regulated model) is genuinely distinctive. If you can get enough post-period, RI could become the cleanest U.S. OPC evaluation setting.
- **Concerns:** It’s simply **too early** (Jan 2025 start) for credible mortality evaluation—post-period is short, and early months often reflect startup friction rather than steady-state effects. Single-site inference is also delicate; you’ll need design-based placebo/permutation inference and careful handling of spillovers.
- **Novelty Assessment:** **High** (state-regulated OPC model is new; essentially no published causal evaluation yet).
- **Recommendation:** **CONSIDER (conditional on: at least 2–3 full post years; focusing on higher-frequency outcomes like EMS overdoses, naloxone reversals, nonfatal overdoses; pre-registering a small-number-of-treated inference strategy).**

---

**#6: Colorado Psychedelic “Healing Centers” and Municipal Zoning Workarounds**
- **Score: 32/100**
- **Strengths:** Clever institutional hook (local zoning as de facto preemption circumvention) and high novelty. If it matures, it could be a template for studying how “implementation politics” shape access under statewide legalization.
- **Concerns:** Not evaluation-ready: centers are only beginning (Dec 2024 onward), outcomes will lag, and early adoption is highly selected. Municipal zoning changes are likely endogenous to local politics/trends, and population mental health outcomes will again be heavily diluted.
- **Novelty Assessment:** **Very high** (virtually no causal work yet), but novelty doesn’t rescue weak feasibility/timing.
- **DiD Assessment (municipal zoning restrictions):**
  - **Pre-treatment periods:** **Weak** (effectively ≤2 years of meaningful pre, and “pre” occurs before centers exist)
  - **Selection into treatment:** **Weak** (political selection; zoning responds to anticipated effects and local trends)
  - **Comparison group:** **Marginal** (municipalities differ substantially)
  - **Treatment clusters:** **Marginal** (unclear how many restrictive municipalities will exist soon; likely <20 initially)
  - **Concurrent policies:** **Marginal** (other mental health/substance policies; post-pandemic shifts)
  - **Outcome-Policy Alignment:** **Marginal** for population outcomes; better for licensing/access metrics
  - **Data-Outcome Timing:** **Weak** (outcomes won’t reflect full exposure for years)
  - **Outcome Dilution:** **Weak** (tiny treated share of population)
- **Recommendation:** **SKIP (for now).** Revisit in 2–3 years with an access/utilization-focused design and a clearly measured treatment (e.g., license approvals, openings, capacity).

---

### Summary

This is a strong, attention-grabbing batch, but only one idea is currently both **novel and evaluation-ready** with a plausible identification story: **NYC OPCs and overdose mortality**, provided you handle few-treated-units inference and spillovers carefully. The main reasons the psychedelics and FTS ideas fall down are the checklist killers: **outcome dilution**, **timing/access not sharp**, and **endogenous treatment intensity/selection**. If you want a credible “backup” project that can start immediately, the **Clark County naloxone vending machine** study is next-best, contingent on moving from county aggregates to tight geographic exposure.