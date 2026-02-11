# Research Idea Ranking

**Generated:** 2026-02-11T13:31:42.324403
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6577

---

### Rankings

**#1: Educational Content Restriction (“Divisive Concepts”) Laws and Teacher Labor Markets**
- **Score: 72/100**
- **Strengths:** High novelty with a clear, timely policy shock and unusually rich pre-period (2015–2020 quarterly). The proposed **triple-diff (education vs healthcare within state)** is a smart way to net out many state-level confounders (COVID recovery, inflation, migration).
- **Concerns:** Biggest risks are (i) **outcome-policy mismatch/dilution** because NAICS 61 is broader than K–12 teaching, and (ii) **concurrent education-specific policies** (pay raises, certification changes, school choice, culture-war governance changes) that affect education but not healthcare—triple-diff won’t difference those out.
- **Novelty Assessment:** **High.** There’s lots of commentary/surveys, but I’m not aware of a well-identified multi-state causal estimate of these laws on *labor market outcomes*.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (2015–2020 = 24 quarters).
  - **Selection into treatment:** **Marginal** (political adoption could correlate with pre-existing teacher shortages or broader education turbulence; not obviously “responding to QWI trends,” but plausibly correlated with unobservables).
  - **Comparison group:** **Marginal** (healthcare is a reasonable within-state control sector, but you still need education vs healthcare **parallel trends** in the absence of the law; this is testable with the long pre-period).
  - **Treatment clusters:** **Strong** (20+ states).
  - **Concurrent policies:** **Marginal** (many education-sector contemporaneous policies; must measure/control/limit sample to mitigate).
  - **Outcome-Policy Alignment:** **Marginal** (NAICS 61 includes higher ed/private training in many states; the law targets K–12 classroom practice. Alignment becomes **Strong** if you can restrict to K–12/public-school employers or a narrower industry/ownership cut).
  - **Data-Outcome Timing:** **Strong** if coded correctly. **QWI is quarterly** (UI-based); many laws are effective mid-quarter (e.g., May/July/Sept). You should define treatment as starting the **first full quarter of exposure** (and/or use treatment-intensity by share-of-quarter exposed) to avoid mechanical attenuation.
  - **Outcome Dilution:** **Marginal** (affected group = K–12 instructional staff; QWI NAICS 61 includes others. If K–12 is <50% of NAICS 61 employment in many states, effects will be diluted; mitigate by narrowing the sample or using sub-industry/ownership if available).
- **Recommendation:** **PURSUE (conditional on: (1) verifying QWI can isolate K–12/public education reasonably well (industry detail and/or ownership); (2) building a concurrent-policy database for major education labor/pay/certification reforms 2021–2023; (3) pre-trend/event-study diagnostics for edu vs healthcare within-state).**

---

**#2: State Noncompete Agreement Bans and Business Dynamism**
- **Score: 61/100**
- **Strengths:** Strong policy relevance and good outcomes (job-to-job flows, hires/separations) that are conceptually close to the mechanism. QWI is well-suited to detect mobility changes around effective dates.
- **Concerns:** Novelty is only moderate because noncompetes are heavily studied; also **treated-state count is borderline (<20)** and adoption may be endogenous to labor-market conditions and broader pro-worker policy bundles (confounding).
- **Novelty Assessment:** **Medium–Low.** There is an extensive empirical literature on noncompetes and mobility/earnings/entrepreneurship; the “new wave” of bans helps, but it’s not a wide-open space.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (most reforms are 2018–2023; QWI allows many years pre).
  - **Selection into treatment:** **Marginal** (legislative choice plausibly correlated with worker-mobility trends and broader labor agenda; not cleanly external).
  - **Comparison group:** **Marginal** (never-treated states differ systematically; synthetic DiD / matched comparisons likely needed).
  - **Treatment clusters:** **Marginal** (~13–15 treated states; inference and robustness to influential states become important).
  - **Concurrent policies:** **Marginal** (minimum wage, paid leave, union/contractor rules, sectoral policies—often co-move with noncompete reforms).
  - **Outcome-Policy Alignment:** **Strong** for QWI job-to-job flows/hires/separations; **Marginal** for BDS births/deaths (plausible but more indirect and slower-moving).
  - **Data-Outcome Timing:** **Marginal** (QWI quarterly can be aligned well; **BDS is annual**, and policy effective dates mid-year can create partial-exposure “treated years”—best to define post as first full calendar year after effective date).
  - **Outcome Dilution:** **Marginal** (only a subset of workers are bound by noncompetes; aggregate state outcomes dilute effects. Mitigate by focusing on industries/earnings groups with high noncompete incidence or using wage-bin/industry heterogeneity).
- **Recommendation:** **CONSIDER (conditional on: (1) a pre-analysis plan emphasizing heterogeneity where noncompetes are prevalent; (2) careful effective-date timing for annual BDS; (3) robustness to small-cluster inference—randomization inference / wild bootstrap; (4) credible controls/exclusions for bundled labor-market reforms).**

---

**#3: State Anti-ESG Legislation and Public Sector Financial Outcomes**
- **Score: 35/100**
- **Strengths:** Timely and potentially important for state budgets/borrowing costs; cross-state adoption creates apparent variation.
- **Concerns:** As proposed, **outcomes are poorly aligned** with the policy mechanism (finance-sector employment is not a direct measure of state investment performance or borrowing costs). Post-treatment windows are short (mostly 2022–2023 adoption) and key fiscal outcomes have publication lags and timing complications.
- **Novelty Assessment:** **Medium.** The topic is newer, but the identification/outcome design here is not yet convincing, and there are emerging papers focused on bond spreads/borrowing costs in specific states.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (you can have many years pre).
  - **Selection into treatment:** **Weak** (highly political; likely correlated with many simultaneous state fiscal/financial actions and partisan trends).
  - **Comparison group:** **Weak** (anti-ESG adopters are systematically different; “never-treated” states are not close counterfactuals without heavy modeling).
  - **Treatment clusters:** **Strong** (20+ adopters claimed).
  - **Concurrent policies:** **Weak** (states often change contracting rules, pension governance, banking relationships, and fiscal policy alongside anti-ESG moves; plus macro interest-rate shocks in 2022–2023 interact strongly with the outcomes you propose).
  - **Outcome-Policy Alignment:** **Weak** (NAICS 52 employment/earnings do not directly capture state investment constraints or borrowing-cost effects; interest expenditures are closer, but still noisy and lagged).
  - **Data-Outcome Timing:** **Weak** (many laws effective mid/late year; government finance outcomes are annual and lagged, making “first treated year” often partial or even pre-exposure depending on fiscal year definitions).
  - **Outcome Dilution:** **Weak** (policy targets a narrow slice of state investment/contracting relationships; broad finance-sector labor outcomes are overwhelmingly unaffected).
- **Recommendation:** **SKIP** (unless redesigned around tightly aligned outcomes like municipal bond yields/spreads, underwriting fees, pension returns/benchmarks, bank participation in state contracts—measured at appropriate frequency with clear exposure timing).

---

### Summary

This is a relatively strong batch in terms of topical importance and modern policy variation, but only **Idea 1** currently looks like a genuinely promising “institute-quality” causal project—*if* you can tighten outcome alignment to K–12/public education and account for concurrent education policies. **Idea 2** is feasible and policy-relevant but sits in a crowded literature and faces small-cluster/bundled-policy challenges. **Idea 3** fails the DiD checklist on multiple critical dimensions (alignment, timing, dilution, selection) and should be skipped unless substantially reframed.