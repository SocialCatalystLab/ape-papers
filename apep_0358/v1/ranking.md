# Research Idea Ranking

**Generated:** 2026-02-18T14:35:09.401802
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8738

---

### Rankings

**#1: Medicaid Postpartum Coverage Extensions and Maternal Health Provider Supply (Idea 1)**
- **Score: 77/100**
- **Strengths:** Very strong policy variation (47 adopting units with rich staggered timing) and long pre-periods make this one of the rare DiD setups that can credibly support event studies. The supply-side angle using T‑MSIS/NPPES is meaningfully novel and directly policy-relevant given access concerns in maternal care.
- **Concerns:** The **FFCRA/PHE “continuous coverage” period (2020–Mar/Apr 2023)** likely blunted real eligibility loss at 60 days postpartum in *all* states, so “adoption in 2022” may not translate into differential postpartum coverage until redeterminations resume—creating a major **timing/exposure** complication. T‑MSIS encounter/claims completeness changes over time and by state could masquerade as “provider entry” unless you aggressively use quality flags and falsification tests.
- **Novelty Assessment:** **High for the specific question** (provider supply response to postpartum extension). Postpartum extensions themselves have many demand-side papers, but the supply-side Medicaid provider-market response is comparatively unstudied.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (Jan 2018 onward gives ≥4 years pre for earliest 2022 adopters; more for later adopters)
  - **Selection into treatment:** **Marginal** (near-universal adoption reduces selection concerns, but adoption timing could still correlate with maternal-health priorities/capacity)
  - **Comparison group:** **Marginal** (not-yet-treated states provide good comparisons early; by late periods, reliance on AR/WI as “never treated” is risky because they are atypical)
  - **Treatment clusters:** **Strong** (>>20 states)
  - **Concurrent policies:** **Marginal → potentially Weak if unaddressed** (PHE continuous coverage, Medicaid unwinding timing, postpartum-related initiatives; must explicitly model/stratify by the unwinding period)
  - **Outcome-Policy Alignment:** **Strong (for postpartum-specific claims like 59430; contraceptive claims also plausible)**; **Marginal (for “# OB/GYN billing Medicaid” overall)** unless you define provider supply tied to postpartum services (e.g., providers with any postpartum visit claim)
  - **Data-Outcome Timing:** **Strong if handled carefully** (T‑MSIS is by service date; many adoptions are effective **Apr 1 / Jul 1 / Jan 1**—define treatment as the **first full month** of exposure and consider dropping partial months)
  - **Outcome Dilution:** **Marginal** (statewide OB/GYN Medicaid participation may be only partially driven by postpartum revenue; dilution is much lower if outcomes are postpartum-visit providers/claims specifically)
- **Recommendation:** **PURSUE (conditional on: explicitly addressing PHE continuous-coverage/unwinding timing; defining “supply” using postpartum-linked provider measures; using T‑MSIS quality screens + state-specific reporting-break controls; showing robust pre-trends and placebo outcomes such as antepartum codes).**

---

**#2: Medicaid Coverage of Doula Services and Birth Outcomes (Idea 2)**
- **Score: 62/100**
- **Strengths:** The policy is timely and comparatively under-researched in multi-state settings; provider-market response is a natural first-order outcome. If doula billing can be cleanly observed, this can become a sharp “does coverage translate into actual services?” evaluation.
- **Concerns:** The biggest risk is **measurement/operationalization**: doula services may be billed under nonstandard codes, bundled, or billed by agencies—so “doula NPIs in T‑MSIS” may miss most real provision. Also, with only ~12–15 adopters, inference is fragile and policy packages (maternal-health bundles) create meaningful confounding risk.
- **Novelty Assessment:** **Moderately high.** There are program/state-specific doula evaluations, but fewer credible multi-state Medicaid reimbursement studies, especially on supply responses.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (likely ≥5 years pre for many adopters if using 2013/2015+ T‑MSIS/TAF; even 2018+ gives 3–5 for later adopters)
  - **Selection into treatment:** **Marginal** (often adopted as part of maternal mortality equity agendas; could correlate with trends)
  - **Comparison group:** **Marginal** (never-treated states exist, but treated states may differ systematically; need careful balancing/event-study diagnostics)
  - **Treatment clusters:** **Marginal** (~12–15)
  - **Concurrent policies:** **Marginal** (many states roll out doula reimbursement alongside other perinatal reforms; you’ll need a policy-stack control strategy)
  - **Outcome-Policy Alignment:** **Marginal (potentially Strong if you verify a consistent taxonomy/code pathway in claims)**; as written it’s not yet proven that T‑MSIS cleanly captures doula services/providers
  - **Data-Outcome Timing:** **Strong if defined as first full quarter/month post-implementation** (implementations are often mid-year with administrative ramp-up)
  - **Outcome Dilution:** **Strong for outcomes like “doula claims” or “doula-billing providers”**; **Weak if the main outcome becomes statewide birth outcomes** (doula uptake is likely well below 10–20% of Medicaid births in many states, heavily diluting mean outcomes)
- **Recommendation:** **CONSIDER (conditional on: confirming a harmonized doula identification strategy in T‑MSIS—codes + taxonomy + enrollment rules; keeping outcomes tightly aligned to doula service use/entry rather than diluted statewide birth outcomes; pre-specifying how you handle small-cluster inference).**

---

**#3: Medicaid Adult Dental Benefit Expansions and Dentist Participation (Idea 4)**
- **Score: 45/100**
- **Strengths:** Clear economic mechanism and high policy relevance; provider participation is a direct, decision-relevant outcome. If you can assemble enough expansions over a longer horizon, this could be a strong design.
- **Concerns:** As stated, **too few treated states (≈8–10)** is a **dealbreaker for DiD inference** (small-cluster problems, fragile standard errors, high sensitivity to any one state). There is also meaningful heterogeneity in what “comprehensive” means, plus frequent concurrent changes (managed care carve-ins, reimbursement, provider enrollment changes) that directly affect dentist billing.
- **Novelty Assessment:** **Medium.** Adult Medicaid dental expansions have a sizable literature (utilization, ED dental visits, health), though “dentist participation using T‑MSIS at scale” is less saturated.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong**
  - **Selection into treatment:** **Marginal** (expansions often respond to budgets/politics and sometimes worsening access—trend endogeneity possible)
  - **Comparison group:** **Marginal** (never-treated vs treated states can differ systematically in Medicaid generosity and dental markets)
  - **Treatment clusters:** **Weak** (<10 as proposed)
  - **Concurrent policies:** **Marginal → Weak** (rate hikes, delivery-system changes, and administrative simplifications often coincide and directly affect participation)
  - **Outcome-Policy Alignment:** **Strong** (dentists billing Medicaid + dental claims/spend directly reflect the benefit)
  - **Data-Outcome Timing:** **Strong if you align to the benefit effective date and drop partial-year months**
  - **Outcome Dilution:** **Strong** (adult dental benefit changes affect a large share of adult enrollees; participation outcomes are not inherently diluted)
- **Recommendation:** **SKIP (unless redesigned).** A viable redesign would: (i) expand the study window back far enough to capture **≥20** expansion/contraction events; (ii) code benefit generosity continuously; (iii) use robust small-cluster methods only as a supplement, not the core identification.

---

**#4: State Behavioral Health Parity Enforcement and Medicaid Provider Supply (Idea 3)**
- **Score: 28/100**
- **Strengths:** The Medicaid behavioral health access problem is enormous, and a credible enforcement study would be valuable. Using provider-side Medicaid claims is a good instinct.
- **Concerns:** The treatment is **not well-defined or cleanly dated** (“enforcement regulations” are heterogeneous, multi-part, and hard to code), creating severe risk of misclassification and post-treatment anticipation. Selection into enforcement is likely highly endogenous (states act when problems are acute) and the period is saturated with concurrent behavioral health changes (telehealth expansions, 988 rollout, CCBHC expansion, opioid settlement spending), making DiD attribution extremely fragile.
- **Novelty Assessment:** **Moderate.** Parity is heavily studied in commercial markets; Medicaid MCO parity enforcement is less studied, but the identification barriers are substantial.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (depends on when “enforcement” is coded; likely insufficient clean pre for many states once you define the policy precisely)
  - **Selection into treatment:** **Weak** (enforcement likely responds to access shortfalls, lawsuits, audits, or spending overruns—directly tied to outcomes)
  - **Comparison group:** **Weak/Marginal** (states with strong enforcement are structurally different from low-enforcement states)
  - **Treatment clusters:** **Marginal** (unclear how many truly comparable “enforcement events” exist once precisely defined)
  - **Concurrent policies:** **Weak** (too many same-sector coincident shocks/policies)
  - **Outcome-Policy Alignment:** **Marginal** (H-codes/provider counts are noisy proxies for “parity compliance”; parity may change utilization management rather than raw provider counts)
  - **Data-Outcome Timing:** **Marginal** (policy “enforcement” affects plans with implementation lags; timing is hard)
  - **Outcome Dilution:** **Marginal** (effects may be concentrated in MCO subpopulations or specific services; statewide aggregates dilute)
- **Recommendation:** **SKIP** unless you can (i) identify a *single, sharp, externally triggered* enforcement shock (e.g., court order/settlement with a clear effective date) and (ii) focus on narrowly aligned outcomes.

---

### Summary

This is a relatively strong batch because Idea 1 is unusually close to “publication-grade” DiD in terms of treated clusters and pre-period length, but it **must** grapple with the PHE continuous-coverage/unwinding timing or risk estimating a mechanically attenuated or mis-timed effect. Idea 2 is promising but hinges on whether doula services/providers are **actually observable** in T‑MSIS in a harmonized way. Ideas 3 and 4, as currently framed, have **identification dealbreakers** (diffuse treatment definition for parity; too few treated states for dental) and should be redesigned before investing heavily.