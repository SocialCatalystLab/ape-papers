# Research Idea Ranking

**Generated:** 2026-01-30T20:00:02.548495
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6414
**OpenAI Response ID:** resp_07ed4f26e9e6dd9a00697cff59776881938ce2af5930dadd4e

---

### Rankings

**#1: State Minimum Wage Increases and Young Adult Household Formation**
- **Score: 72/100**
- **Strengths:** Big policy variation (30+ states) with extremely well-measured outcomes in ACS, and a welfare-relevant mechanism (earnings capacity → independent living) that the minimum-wage literature hasn’t centered. Large samples make heterogeneous effects (by education, student status, wage position) feasible and potentially illuminating.
- **Concerns:** Treated states are systematically different (housing costs, urbanization, politics), and contemporaneous progressive-policy bundles (EITC expansions, paid leave, housing policies) risk confounding. “State-year” treatment coding can mis-time exposure because many increases occur mid-year.
- **Novelty Assessment:** **Moderately novel.** Minimum wage is heavily studied, but *young adult co-residence/household formation* is not a saturated outcome in the canonical MW DiD literature; still, expect some related work on family formation/housing outcomes, so novelty is not “clean slate.”
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** — ACS can give ≥5 pre-years for most states if you start ~2005/2006 (not just 2010).
  - **Selection into treatment:** **Marginal** — increases are politically driven and correlated with cost-of-living/urban trends that also affect co-residence.
  - **Comparison group:** **Marginal** — “never-treated” federal-floor states are disproportionately Southern/low-cost; you’ll likely need matching/reweighting or border-county designs as robustness.
  - **Treatment clusters:** **Strong** — 30+ states with multiple adoption years.
  - **Concurrent policies:** **Marginal** — progressive states often change multiple labor/housing policies around the same time.
  - **Outcome-Policy Alignment:** **Strong** — living with parents vs. independent household status is a direct margin plausibly affected by low-wage income changes.
  - **Data-Outcome Timing:** **Marginal** — ACS is fielded year-round; many MW hikes are Jan 1 or Jul 1, so “treated year” can include substantial pre-exposure unless you construct an exposure-weighted treatment intensity (share of months at higher MW) or move to monthly microdata (not available in ACS).
  - **Outcome Dilution:** **Marginal** — MW directly shifts earnings for a subset of 18–30-year-olds (low-wage workers), but household formation could respond more broadly; still, effects will be diluted if you keep all young adults. (Mitigation: focus on low-education, non-students, or predicted MW exposure using baseline wage distribution.)
- **Recommendation:** **PURSUE (conditional on: exposure-weighted treatment timing; explicit controls/robustness for housing-cost trends and policy bundling; heterogeneity by MW exposure to address dilution)**

---

**#2: State Ban-the-Box Laws and Racial Employment Disparities**
- **Score: 64/100**
- **Strengths:** Important policy debate with credible theoretical ambiguity (reduced barriers vs. statistical discrimination) and lots of staggered adoption. DDD (Black–White gaps) is a sensible way to soak up many confounders that hit both races similarly within a state.
- **Concerns:** Treatment measurement is messy (state vs. local coverage; public-only vs private; firm-size thresholds), creating attenuation and interpretability issues. Adoption is likely endogenous to political/activism trends and may coincide with other criminal-justice reforms (expungement, policing changes) affecting employment.
- **Novelty Assessment:** **Moderately studied.** There is a well-known experimental literature and several observational policy evaluations; a comprehensive modern staggered-adoption design across *all* states could still add value, but it’s not “new terrain.”
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** — CPS/ACS can deliver long pre-periods (well over 5 years) for most adoptions.
  - **Selection into treatment:** **Marginal** — states/localities adopting BTB differ systematically; adoption may respond to (or be correlated with) labor-market and justice-system trends.
  - **Comparison group:** **Marginal** — never-treated states may be meaningfully different; also, local ordinances in “control” states contaminate comparisons.
  - **Treatment clusters:** **Strong** — 35+ states (but note: effective clusters depend on how many *statewide private-sector* laws you truly have).
  - **Concurrent policies:** **Marginal** — criminal justice and labor-market policy packages often move together.
  - **Outcome-Policy Alignment:** **Strong** — employment/earnings by race is a direct equilibrium outcome potentially affected by hiring-screen changes.
  - **Data-Outcome Timing:** **Marginal-to-Strong** — if you use **CPS monthly** outcomes and code effective dates precisely, timing can be strong; if you collapse to state-year, partial-year exposure becomes a real attenuation risk.
  - **Outcome Dilution:** **Marginal** — BTB directly applies to applicants with records (minority share often far below 50%), but the *statistical discrimination* channel could affect a broad set of Black men, making dilution less fatal than for narrowly targeted programs.
- **Recommendation:** **CONSIDER (conditional on: high-quality policy database distinguishing private-sector vs public-only; precise effective dates with monthly CPS; explicit strategy for local-policy contamination—e.g., drop/flag high-ordinance states or use metro-level designs)**

---

**#3: State Conversion Therapy Bans and Youth Suicide Rates**
- **Score: 42/100**
- **Strengths:** Substantively important and plausibly highly policy-relevant, with genuinely limited causal evidence in economics/policy evaluation relative to salience. Long pre-period is feasible in principle for mortality outcomes.
- **Concerns:** The proposed main outcome (all youth suicide) is an extremely noisy, highly diluted proxy for effects on LGBTQ minors specifically, and treated states simultaneously adopt many LGBTQ-affirming/mental-health-related policies—making attribution very difficult. Data continuity issues (your noted 2018–2019 gap) and small state-year counts further undermine power and inference.
- **Novelty Assessment:** **High novelty** for rigorous causal estimation of downstream health outcomes, but novelty does not compensate for major identification/proxy problems here.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** — 2005–2011 gives 7+ pre-years (and mortality data exist earlier if needed).
  - **Selection into treatment:** **Weak** — bans are strongly correlated with underlying social attitudes and broader policy shifts likely trending with youth mental health and reporting.
  - **Comparison group:** **Marginal-to-Weak** — never-treated states differ sharply on politics, religiosity, and baseline LGBTQ climate; common-trends is hard to defend.
  - **Treatment clusters:** **Strong** — ~20 treated states.
  - **Concurrent policies:** **Weak** — high risk of coincident LGBTQ protections, school policies, Medicaid/mental-health initiatives, and secular changes in reporting/diagnosis.
  - **Outcome-Policy Alignment:** **Marginal** — suicide is relevant to mental health, but the policy targets a specific practice among a small subgroup; all-youth suicide is not tightly mapped to the mechanism.
  - **Data-Outcome Timing:** **Marginal** — mortality is annual; bans often take effect mid-year, creating partial exposure in first “treated” year unless you exposure-weight by effective month.
  - **Outcome Dilution:** **Weak** — the directly affected population (minors who would otherwise be subjected to conversion therapy) is far below 10% of all 15–24-year-olds; even effects on LGBTQ youth are diluted heavily in the all-youth suicide rate.
- **Recommendation:** **SKIP (unless redesigned around outcomes/populations with much tighter alignment—e.g., LGBTQ-specific survey outcomes such as YRBS where available, or administrative mental-health utilization with subgroup identification—and a strategy to address concurrent LGBTQ-policy bundles)**

---

### Summary

This is a decent batch: Ideas 1 and 2 are feasible with modern staggered-adoption methods, but both face the classic DiD threats of endogenous adoption and non-comparable controls; Idea 1 is the cleanest to execute with strong measurement and lots of data, and should be pursued first. Idea 3 is highly novel but fails on multiple *critical* DiD criteria—especially outcome dilution and concurrent-policy confounding—so I would not fund it without a major redesign toward better-aligned outcomes and identification.