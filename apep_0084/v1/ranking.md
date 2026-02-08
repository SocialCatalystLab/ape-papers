# Research Idea Ranking

**Generated:** 2026-01-29T17:43:44.572160
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 8047
**OpenAI Response ID:** resp_06f1bc2d15f75d2a00697b8dcb0f0881959af31eb999cc7ac3

---

### Rankings

**#1: Recreational Marijuana Legalization and Entrepreneurship: Industry-Level Evidence from Business Formation Statistics**
- **Score:** 69/100
- **Strengths:** Excellent data: high-frequency monthly BFS with a long pre-period and many treated states gives real power and flexibility (event studies, cohort heterogeneity). The sector-based DDD is a sensible attempt to separate cannabis-adjacent responses from broader macro trends.
- **Concerns:** “Legalization date” is often not the economically relevant treatment moment (licensing, first legal sales, banking/tax rules), creating serious timing/mismeasurement risk. Industry coding is coarse and cannabis activity may be misclassified, so the “cannabis-adjacent” DDD could still be quite diluted and hard to interpret without validation.
- **Novelty Assessment:** **Moderately novel.** Marijuana legalization has a large literature; entrepreneurship/business dynamics has some coverage (including Census-based work), but **BFS monthly** + **long panel through 2025** + **modern staggered DiD + sector DDD** is a meaningful incremental contribution if the treatment definition is nailed down.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (2004/2005–2011 gives 7+ clean pre years for early adopters)
  - **Selection into treatment:** **Marginal** (policy adoption correlated with political ideology and possibly economic trajectories; must document pre-trends by cohort and consider state-specific trends / covariates)
  - **Comparison group:** **Strong** (substantial never-treated pool through much of the sample; can also use not-yet-treated in CS framework)
  - **Treatment clusters:** **Strong** (≈24 treated states + DC)
  - **Concurrent policies:** **Marginal** (medical marijuana laws, decriminalization, local licensing/tax regimes, COVID-era shocks; needs careful controls and robustness)
  - **Outcome-Policy Alignment:** **Marginal** — BFS measures **business applications**, not openings, and NAICS sectors are broad; legalization should affect cannabis and ancillary formation, but mapping to “retail/ag/manufacturing” is imperfect and needs validation (e.g., show concentrated effects in the most plausible sub-industries available).
  - **Data-Outcome Timing:** **Marginal** — BFS is **monthly (application month)**; many laws are effective on a date, but **market opening (licenses/first sales)** often occurs months later. Using legalization alone risks mechanical attenuation; primary treatment should likely be *first legal retail sales* (or licensing start) rather than statute date.
  - **Outcome Dilution:** **Marginal** — cannabis firms are a small share of *all* applications; even within “adjacent” sectors, the directly affected share may be well below 50%. Mitigation is to (i) focus on the narrowest industry cuts BFS allows, (ii) emphasize distributional/percent outcomes if available, and (iii) treat “spillovers to broader entrepreneurship” as a separate estimand from “cannabis-firm formation.”
- **Recommendation:** **PURSUE (conditional on: redefining treatment timing around market opening/licensing/first sales; demonstrating industry mapping validity and reporting sensitivity to alternative NAICS groupings; explicitly addressing medical marijuana and other cannabis-policy bundling).**

---

**#2: Breaking Health Insurance Job Lock: ACA Medicaid Expansion and Adult College Enrollment**
- **Score:** 61/100
- **Strengths:** Policy relevance is high and the question is plausibly under-studied relative to the enormous Medicaid-expansion literature. ACS microdata can support rich subgroup analysis (income, prior education, employment), which is crucial for mechanism credibility.
- **Concerns:** The never-expansion states are few and regionally distinctive, making parallel trends harder to defend (and inference can become sensitive to specification). The headline outcome (overall adult enrollment 25–54) risks substantial dilution unless the analysis targets the plausibly affected population (low-income, uninsured/low-education adults).
- **Novelty Assessment:** **Somewhat novel.** Medicaid expansion has hundreds of papers; however, “adult re-enrollment/college attendance as job-lock relief” is not a standard outcome and could be a real contribution if tightly executed.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (2005–2013 gives 9 pre years)
  - **Selection into treatment:** **Marginal** (political selection; likely correlated with unobservables that may also affect education trends)
  - **Comparison group:** **Marginal** (≈12 never-expansion states, disproportionately Southern; compositional differences and different education/labor market trajectories are a real risk)
  - **Treatment clusters:** **Strong** (38+ adopters, though many treated in 2014 reduces the amount of “clean” staggered timing variation)
  - **Concurrent policies:** **Marginal** (national ACA components are common shocks—fine—but state higher-ed funding/tuition and workforce policies around the 2010s could confound enrollment trends if correlated with expansion decisions)
  - **Outcome-Policy Alignment:** **Marginal** — ACS measures **enrollment directly** (good), but Medicaid expansion changes insurance; the enrollment channel is indirect. To align outcome with mechanism, the estimand should focus on groups for whom insurance/job-lock is binding (low-income, working adults without a BA, etc.).
  - **Data-Outcome Timing:** **Marginal** — ACS enrollment is measured at **interview date (monthly throughout the year)**. For **Jan 1** expansions, exposure is essentially full-year; for mid-year expansions (some 2014 adopters and later), “first treated year” contains partial exposure unless treatment is coded with effective-month weights or the first full year is used.
  - **Outcome Dilution:** **Marginal** — expansion directly affects adults **<138% FPL** (often on the order of ~15–25% of ages 25–54, varying by state/year). Using the full 25–54 population likely attenuates effects; restricting to low-income (and plausibly previously uninsured) adults is important.
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: you commit to ACS microdata subgroup targeting <150% FPL and/or low-education adults; handle partial-year expansions explicitly; and use robustness designs such as border-county comparisons, reweighting/matching, or synthetic DiD for the South-heavy control issue).**

---

**#3: Opening the Practice: Nurse Practitioner Full Practice Authority and Primary Care Utilization**
- **Score:** 45/100
- **Strengths:** Policy question is important and the post-2010 wave gives some modern relevance; BRFSS offers large samples and multiple access/utilization measures. There is a coherent theory that relaxing scope-of-practice constraints can improve access, especially in underserved areas.
- **Concerns:** Two identification problems are close to dealbreakers with the proposed design: (i) major coincident shocks/policies (ACA Medicaid expansion and other health reforms) line up with many adoptions, and (ii) key BRFSS outcomes are defined over the **past 12 months**, creating serious timing contamination around adoption dates.
- **Novelty Assessment:** **Low-to-moderate.** NP scope-of-practice and utilization/access has a pre-existing literature (including DiD-style work). Using modern staggered DiD estimators is an incremental methodological update, but not a big novelty jump.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (depends on which cohorts you keep; many early adopters limit clean pre-periods unless you restrict)
  - **Selection into treatment:** **Marginal** (likely related to provider shortages/rural needs and political economy; could correlate with changing access trends)
  - **Comparison group:** **Strong** (restricted/reduced states are a natural comparison set, though still heterogeneous)
  - **Treatment clusters:** **Marginal** (post-2010 adopters likely in the 10–20 range; inference may be fragile depending on final cohort definition)
  - **Concurrent policies:** **Weak** — Medicaid expansion and other ACA-era state health policy changes plausibly move the same access/utilization outcomes and are correlated with FPA adoption timing in many states.
  - **Outcome-Policy Alignment:** **Strong** — “personal doctor,” “routine checkup,” and cost barriers are conceptually close to primary care access affected by scope-of-practice rules.
  - **Data-Outcome Timing:** **Weak** — several BRFSS measures reference **the past 12 months**; with an adoption effective date (often Jan/Jul), the “first treated” survey responses mechanically include substantial pre-treatment months, biasing effects toward zero or producing ambiguous timing.
  - **Outcome Dilution:** **Marginal** — effects likely concentrated among people seeking primary care, in shortage/rural areas, or among the uninsured; statewide averages can dilute.
- **Recommendation:** **SKIP (unless redesigned)**. To salvage: use outcomes measured at a point in time (or administrative claims/visit data with service dates), explicitly control for Medicaid expansion with interaction/event-time structure, and/or focus on a setting with sharper quasi-experimental leverage (borders, court/ballot-driven adoptions, or credible instruments).

---

### Summary

This is a strong batch in terms of policy relevance and basic feasibility, but only **Idea 1** is close to “ready to run” because it combines many treated units, high-frequency data, and a long pre-period—its main risk is **treatment timing/mapping to actual market opening** and **industry misclassification/dilution**. **Idea 2** is promising but will live or die on subgroup targeting and credibility with a South-heavy control group. **Idea 3** has **two “Weak” DiD checklist items (concurrent policies and timing)** and should be deprioritized unless the design is substantially reworked.