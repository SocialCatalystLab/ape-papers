# Research Ideas

## Idea 1: Must-Access PDMP Mandates and Prime-Age Labor Force Participation

**Policy:** State mandates requiring prescribers to query the Prescription Drug Monitoring Program (PDMP) before prescribing controlled substances ("must-access" laws). Approximately 40 states adopted these mandates between 2012 and 2022, with staggered effective dates documented by PDAPS (pdaps.org).

**Outcome:** Labor force participation, employment, and disability receipt among prime-age adults (25-54), using CPS Annual Social and Economic Supplement (ASEC) microdata from IPUMS. Supplementary outcomes: self-reported health limitations, work-limiting disability, hours worked.

**Identification:** Staggered difference-in-differences exploiting state-level variation in must-access PDMP mandate adoption timing. Callaway-Sant'Anna (2021) estimator as primary specification. CPS ASEC data from 2007-2023 provides ≥5 pre-treatment years for most cohorts.

**Why it's novel:** While Kaestner & Ziedan (2023, Labour Economics) examined "modern PDMPs" and employment, their analysis used a different policy classification (not specifically must-access mandates), earlier time period, and conventional TWFE. This paper uses: (1) the specific must-access mandate coding from PDAPS, (2) extended sample through 2023 including later-adopting states, (3) heterogeneous treatment effects across Callaway-Sant'Anna framework, (4) focus on prime-age workers where opioid labor supply effects are most policy-relevant.

**Feasibility check:**
- Variation: ~40 states with staggered must-access mandates (strong)
- Data: IPUMS CPS ASEC accessible via API (confirmed API key)
- Novelty: Specific must-access mandate type + CS-DiD + extended sample period not previously studied
- Sample size: CPS ASEC ~100,000 observations/year × 17 years = ~1.7 million obs
- Pre-periods: 5-10 years for most cohorts (strong)
- DiD screen: ≥20 treated states ✓, ≥5 pre-periods ✓, staggered adoption ✓


## Idea 2: State Drug Price Transparency Laws and Out-of-Pocket Prescription Spending

**Policy:** State laws requiring pharmaceutical manufacturers to report or justify price increases above a threshold (e.g., 10-20%). Approximately 20+ states adopted some form of drug price transparency between 2016 and 2023.

**Outcome:** Out-of-pocket prescription drug spending and prescription drug utilization from CPS/MEPS data.

**Identification:** Staggered DiD comparing spending in adopting vs non-adopting states.

**Why it's novel:** Limited causal evidence on whether transparency laws actually reduce consumer costs. Most research is descriptive or focuses on manufacturer behavior.

**Feasibility check:**
- Variation: ~20-25 states (marginal)
- Data: CPS ASEC has health expenditure questions but limited Rx detail; MEPS has better Rx data but smaller sample
- Novelty: Moderate - some working papers exist
- Pre-periods: Limited (first laws in 2016)
- Risk: Small treatment effect, noisy outcome measures


## Idea 3: State Adoption of Crisis Intervention Team (CIT) Training Mandates → Mental Health Arrest Diversion

**Policy:** States mandating Crisis Intervention Team training for law enforcement officers. Staggered adoption of mandatory CIT requirements across states.

**Outcome:** Arrest rates for mental health-related offenses, use of force incidents, mental health emergency detentions. Data from UCR/NIBRS.

**Identification:** Staggered DiD.

**Why it's novel:** CIT training effectiveness has been studied in single-city evaluations but not in a multi-state DiD framework exploiting staggered mandates.

**Feasibility check:**
- Variation: Unclear exactly how many states have binding CIT mandates (need verification)
- Data: UCR/NIBRS publicly available
- Novelty: High
- Risk: CIT mandates may be poorly defined or inconsistently implemented
