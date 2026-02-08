# Research Idea Ranking

**Generated:** 2026-01-28T18:13:54.743820
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 8247
**OpenAI Response ID:** resp_0bd73006510922d000697a4348454c8193950325f1b881109b

---

### Rankings

**#1: Salary History Bans and the Wage Penalty for Job Stayers**
- **Score: 68/100**
- **Strengths:** Good “modern DiD” setting with multiple adopters and a clear mechanism-based extension beyond the existing SHB/job-changer focus. CPS MORG is plausibly rich enough to compare wage dynamics for stayers vs. changers and to run event studies.
- **Concerns:** Endogenous adoption (progressive states; correlated pay-equity agendas) and concurrent labor-market policies are real threats. Measuring *true* job staying/changing and wage growth in CPS is noisy (rotation matching, tenure misreporting, top-coding), and the “stayer spillover” channel is inherently more diffuse (risk of attenuation).
- **Novelty Assessment:** **Medium-high.** Salary history bans have a small but real literature; the *job-stayer spillover/compression* angle is less studied and is a genuine contribution if executed cleanly.
- **DiD Assessment (staggered adoption; Callaway–Sant’Anna):**
  - **Pre-treatment periods:** **Marginal** — with 2014–2024 and first effective date ~2018, you only get ~4 pre-years for early adopters. (Fixable by extending CPS back further.)
  - **Selection into treatment:** **Marginal** — adoption likely correlated with unobserved “equity” preferences and other reforms; needs strong controls/event-study diagnostics and perhaps border-county or policy-bundle controls.
  - **Comparison group:** **Marginal** — never-treated states may differ systematically (region, labor institutions). Consider using not-yet-treated comparisons and/or region×time controls.
  - **Treatment clusters:** **Marginal** — ~19 treated states is decent but still not “comfortably large” for inference under staggered timing.
  - **Concurrent policies:** **Marginal** — SHBs often arrive with pay-transparency/pay-equity, min-wage changes, leave mandates; you need explicit coincident-policy coding.
  - **Outcome-Policy Alignment:** **Strong (with caveat)** — wages and wage growth map to SHB mechanisms, but SHBs directly constrain *hiring/negotiation information*; stayer effects are indirect, so interpret as equilibrium spillovers (not “direct treatment”).
  - **Data-Outcome Timing:** **Marginal** — CPS wages are monthly; SHB effective dates vary (often Jan 1/July 1). You must code treatment by effective month and define exposure windows so “treated” observations actually occur post-effective-date.
  - **Outcome Dilution:** **Marginal** — SHBs directly hit new negotiations; stayers are affected only through internal equity/retention bargaining. Likely <50% of the “stayer” sample meaningfully exposed in the short run unless you target sectors/firms with active wage posting/renegotiation.
- **Recommendation:** **PURSUE (conditional on: extend pre-period earlier than 2014; build a coincident-policy database; implement careful exposure timing at the month/quarter level; show convincing event-study pre-trends for stayers separately from changers).**

---

**#2: State EITC Generosity and Property Crime by Type**
- **Score: 58/100**
- **Strengths:** Policy-relevant and conceptually sharp: different property crimes plausibly respond differently to income shocks/liquidity. If monthly timing around refund season is credible, that’s a potentially novel and policy-salient contribution.
- **Concerns:** UCR/NIBRS measurement and reporting changes (especially post-2020) are a serious feasibility/validity risk, and “monthly UCR” coverage is often incomplete/nonrandom. EITC changes may be bundled with other anti-poverty or public-safety shifts, and aggregate state crime rates risk dilution relative to the treated population.
- **Novelty Assessment:** **Medium.** There is an established literature on EITC and crime (and transfers and crime). The “by property-crime type + refund-season timing” angle is less saturated, but not completely untouched.
- **DiD Assessment (continuous treatment; TWFE proposed):**
  - **Pre-treatment periods:** **Strong** — 1999–2023 provides long pre-trends for many policy changes (but early adopters are always-treated; you’ll rely on generosity changes, not initial adoption, for them).
  - **Selection into treatment:** **Marginal** — generosity expansions are political and may respond to economic conditions; not obviously driven by crime, but still plausibly correlated with unobservables.
  - **Comparison group:** **Marginal** — states with no/low changes may differ; credibility hinges on parallel trends by crime type.
  - **Treatment clusters:** **Strong** — many states change generosity over time; inference is feasible at the state level (though serial correlation must be handled).
  - **Concurrent policies:** **Marginal (borderline)** — crime is affected by policing, sentencing, drug policy, macro shocks; unless EITC changes are orthogonal to these, omitted-variable bias is a core risk. You likely need to restrict to “clean” EITC changes or add rich controls (police per capita, incarceration, unemployment, opioid shocks).
  - **Outcome-Policy Alignment:** **Strong** — property crime rates are directly relevant to an income-support policy’s hypothesized mechanism (liquidity/income reducing acquisitive crime).
  - **Data-Outcome Timing:** **Marginal** — annual crime rates blur the within-year “refund season” mechanism; monthly timing helps, but only if monthly data are complete and consistently measured. Also EITC is a *tax-year* policy with refunds typically Feb–Apr.
  - **Outcome Dilution:** **Marginal** — EITC-eligible households are a minority of the population; aggregate crime rates reflect everyone. Effects could be detectable but are mechanically diluted.
- **Recommendation:** **CONSIDER (conditional on: demonstrate stable UCR measurement/coverage or limit to a defensible pre-NIBRS window; avoid naive TWFE—use modern continuous-staggered methods; pre-specify how you handle early always-treated states and reporting changes).**

---

**#3: Paid Sick Leave Mandates and Worker Turnover**
- **Score: 46/100**
- **Strengths:** Policy-important and plausibly understudied *specifically for quits/turnover mechanisms*; JOLTS separations (if truly usable by state/industry) could align well with the outcome concept.
- **Concerns:** As written, the design risks a **pre-period failure** (2010 start is too late for early adopters) and **coverage/dilution** problems (mandates often exclude small firms/segments, and CPS can’t cleanly isolate covered workers). Adoption is plausibly endogenous and bundled with other “job quality” reforms (min wage, leave, scheduling rules).
- **Novelty Assessment:** **Medium.** There is substantial PSL research on employment/health; turnover is less central but not completely novel. The contribution depends on a clean covered-worker design.
- **DiD Assessment (staggered adoption; Callaway–Sant’Anna):**
  - **Pre-treatment periods:** **Weak** — starting 2010 with CT 2011 means ≤2 pre-years for the earliest treated (dealbreaker unless you extend back substantially).
  - **Selection into treatment:** **Marginal** — likely correlated with labor-market trends and progressive policy bundles.
  - **Comparison group:** **Marginal** — never-treated states differ; not-yet-treated helps but doesn’t fix differential trending without strong evidence.
  - **Treatment clusters:** **Marginal** — ~15 states is workable but not large; adding city laws doesn’t help if outcomes are state-level (it mostly adds noise/dilution).
  - **Concurrent policies:** **Marginal** — many coincident labor standards reforms.
  - **Outcome-Policy Alignment:** **Strong/Marginal** — turnover/quits are conceptually linked to job-quality changes, but CPS ASEC is not an ideal turnover instrument; JOLTS is better if available at the right granularity.
  - **Data-Outcome Timing:** **Marginal** — effective dates vary; annual ASEC timing is awkward (March survey; mixed exposure). Monthly JOLTS would be much cleaner.
  - **Outcome Dilution:** **Weak** — mandates often don’t cover >50% of the workforce (small-firm exemptions; sector targeting like CT). CPS cannot perfectly identify covered workers (especially firm size), so estimated effects likely attenuate heavily.
- **Recommendation:** **SKIP (unless redesigned)** — viable only if you (i) extend pre-period well before first adoption, (ii) focus on outcomes with clean timing (monthly JOLTS/QWI/LEHD-style data), and (iii) construct a credible “covered worker” sample (e.g., covered industries + firm-size proxy from another dataset).

---

**#4: Predictive Scheduling Laws and Worker Well-Being (Oregon)**
- **Score: 35/100**
- **Strengths:** Substantively important and genuinely rare statewide policy variation; synthetic control is the right instinct for a single treated unit.
- **Concerns:** The policy targets a narrow slice (retail/hospitality/food service in **500+ employee firms**), and CPS cannot identify large-firm workers well—**outcome dilution is extreme** and likely fatal. Single-state identification is fragile to Oregon-specific shocks (minimum wage path, local cycles, composition changes), and Oregon CPS subsamples for target sectors will be noisy.
- **Novelty Assessment:** **High** in the sense of “few credible statewide evaluations,” but novelty cannot rescue weak measurement/dilution.
- **DiD Assessment:** *N/A (synthetic control rather than DiD).* Key identification threats are single-unit fragility + inability to measure/target the treated population.
- **Recommendation:** **SKIP** (unless you can get employer-employee administrative data or a dataset with firm size + scheduling outcomes; CPS is not adequate for this policy’s targeting).

---

### Summary

This is a solid batch in terms of policy interest and intent to use modern methods, but only **Idea 1** is close to “ready to run” with a credible path to identification (conditional on longer pre-periods and careful timing/policy-bundle controls). **Idea 2** is promising but hinges on overcoming UCR measurement/coverage problems and avoiding naive TWFE with staggered/continuous treatment. **Ideas 3 and 4** have **dealbreaker-level weaknesses as written** (pre-period failure and/or severe outcome dilution), and should be redesigned or dropped.