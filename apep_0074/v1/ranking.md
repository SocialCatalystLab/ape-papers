# Research Idea Ranking

**Generated:** 2026-01-28T16:35:42.640109
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 8322
**OpenAI Response ID:** resp_0124660b90ff376e00697a2c49e4ac8196bcdf024d9a83aef4

---

### Rankings

**#1: Extreme Risk Protection Orders (Red Flag Laws) and Firearm Suicide**
- Score: **72/100**
- Strengths: Strong outcome-policy match (ERPOs directly remove access to lethal means during acute suicidal crises), and the post-2018 wave creates meaningful staggered timing beyond the classic CT/IN case studies. CDC WONDER + PDAPS are immediately usable and transparent.
- Concerns: Treated states are politically/systematically different and may have concurrent firearm/mental-health policy shifts post-Parkland; parallel trends is not guaranteed. Annual mortality data risks partial-exposure attenuation if effective dates are mid-year, and ERPO usage volumes may be low enough that aggregate state suicide rates are “diluted.”
- Novelty Assessment: **Moderately novel.** CT/IN have been studied a lot; credible multi-state evidence on the 2018–2019 wave is thinner, and heterogeneity by age + intensity is a real contribution if done carefully.
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (as written 2014–2019 gives only ~4 pre-years for 2018 adopters; extend to 2000+ to become Strong)
  - Selection into treatment: **Marginal** (Parkland is a plausibly exogenous national shock, but adoption is still strongly correlated with state ideology/gun-policy trajectories)
  - Comparison group: **Marginal** (never-treated states differ on baseline gun ownership, urbanization, “blue” policy bundles)
  - Treatment clusters: **Marginal** (~17 treated by 2019; better than many state-policy papers, but still <20)
  - Concurrent policies: **Marginal** (post-Parkland packages—background checks, waiting periods, safe storage—could move suicides too)
  - Outcome-Policy Alignment: **Strong** (firearm suicide is exactly the margin ERPOs aim to reduce)
  - Data-Outcome Timing: **Marginal** (CDC WONDER is calendar-year; many ERPO laws effective mid-year → first “treated” year partially exposed; mitigate via month-level WONDER or coding treatment as effective the following Jan 1)
  - Outcome Dilution: **Marginal** (orders are issued to a small subset; mitigate by using ERPO petition/order counts to form an intensity design and by focusing on groups most likely targeted)
- Recommendation: **PURSUE (conditional on: extending the panel earlier than 2014; addressing timing with month-level or conservative exposure coding; explicitly controlling/handling concurrent gun-policy changes; using intensity/implementation measures to reduce dilution concerns)**

---

**#2: State Tobacco-21 Laws and Youth Smoking Initiation**
- Score: **56/100**
- Strengths: Clear policy relevance and a definable “pre-federal” window where state variation matters. Age-specific analysis (18–20 vs younger teens) can sharpen mechanism and reduce dilution.
- Concerns: Few treated clusters pre-2019 and substantial confounding from contemporaneous vaping shocks (2018–2019), flavor bans, taxes, local ordinances, and enforcement differences. Outcome timing is tricky because YRBSS is typically spring-fielded and may precede a mid-year effective date.
- Novelty Assessment: **Modestly novel to moderately studied.** Tobacco-21 has an existing literature (including sales/youth use outcomes); incremental novelty depends on a cleaner timing design and focusing on directly treated ages (18–20) rather than broad teen averages.
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (can be Strong if states have consistent YRBSS participation back to early 2000s; in practice many states have missing cycles)
  - Selection into treatment: **Marginal** (early adopters are strong tobacco-control states; adoption plausibly policy-preference-driven rather than outcome-spike-driven, but not “external”)
  - Comparison group: **Marginal** (never-treated/pre-federal states differ in tobacco control climate)
  - Treatment clusters: **Marginal** (~8–12 meaningful pre-federal adopters depending on coding)
  - Concurrent policies: **Marginal** (often co-moves with other tobacco/e-cigarette policies; could become Weak without careful policy controls and a narrow window)
  - Outcome-Policy Alignment: **Marginal → Strong depending on outcome** (Strong if using BRFSS 18–20 smoking; only Marginal if using YRBSS all-high-school mean, which is mostly <18)
  - Data-Outcome Timing: **Marginal** (YRBSS spring timing can pre-date July/Sept effective dates; need to code exposure based on survey month or use the next cycle)
  - Outcome Dilution: **Marginal** (can be **Weak** if using overall HS sample; can be **Strong** if restricting to 18-year-olds/young adults)
- Recommendation: **CONSIDER (only if: the outcome is tightly aligned to ages 18–20 and timing is handled with survey-month/effective-date alignment; otherwise SKIP)**

---

**#3: State Generic Drug Substitution Laws and Medication Adherence**
- Score: **50/100**
- Strengths: Policy is important for spending and access; adherence for chronic conditions is a meaningful welfare outcome. If you can get claims-based data, the design could be powerful.
- Concerns: With MEPS, state identifiers are restricted and state-year sample sizes for condition-specific adherence are often too small for credible DiD (high noise, compositional issues). Legal variation is nuanced (not clean “on/off”), and many contemporaneous insurance/drug-market changes (ACA, formularies, tiering, copay designs) threaten identification.
- Novelty Assessment: **Moderate.** Generic substitution has a big literature, but many papers are cross-sectional/price-focused; a credible causal link to adherence using policy changes could add value—if data are strong.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (2010–2020 provides ample pre if laws change mid-period)
  - Selection into treatment: **Marginal** (could respond to drug-cost pressures/insurer lobbying; not clearly exogenous)
  - Comparison group: **Marginal** (states changing laws may differ systematically in health policy environment)
  - Treatment clusters: **Marginal** (unclear how many truly discrete, comparable “major” changes exist)
  - Concurrent policies: **Marginal** (ACA, Medicaid expansion, insurance benefit design changes affect adherence)
  - Outcome-Policy Alignment: **Marginal** (law affects substitution/price; adherence responds only if patient OOP prices change and if substitution actually occurs—need utilization/price channels measured)
  - Data-Outcome Timing: **Marginal** (MEPS measures over interview rounds; mapping to policy effective dates is nontrivial)
  - Outcome Dilution: **Marginal** (can be Strong if restricting to users of drug classes where generics are available and substitution is relevant)
- Recommendation: **SKIP (unless you can secure large administrative pharmacy claims with precise state + date + drug identifiers and can define a clean treatment “shock”)**

---

**#4: State Extreme Risk Protection Orders and Firearm Homicide**
- Score: **48/100**
- Strengths: Newer question relative to the suicide-focused ERPO literature, and homicide is policy-salient. Data are feasible (CDC WONDER).
- Concerns: Core mechanism is much weaker: most firearm homicides are not plausibly prevented by an ERPO process (many are impulsive, criminal-network related, or not preceded by a reportable warning). This creates severe dilution and likely null effects that are hard to interpret causally (even if DiD is “clean”).
- Novelty Assessment: **Moderately novel, but for a reason.** The literature deemphasizes homicide because theory/first-stage (ERPO usage against likely homicide perpetrators) is thin.
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (same as Idea 1; needs longer pre-period)
  - Selection into treatment: **Marginal**
  - Comparison group: **Marginal**
  - Treatment clusters: **Marginal**
  - Concurrent policies: **Marginal**
  - Outcome-Policy Alignment: **Weak** (ERPOs target specific high-risk individuals; statewide homicide rate is dominated by cases unlikely to be affected)
  - Data-Outcome Timing: **Marginal** (annual timing/partial exposure issues remain)
  - Outcome Dilution: **Weak** (affected share of homicide risk pool is plausibly very small)
- Recommendation: **SKIP** (unless reframed to a more aligned outcome: domestic violence shootings, threats-to-intimates cases, or near-term gun removals linked to high-risk restraining contexts, ideally with ERPO usage data)

---

**#5: State Medicaid Work Requirements and Health Insurance Coverage**
- Score: **35/100**
- Strengths: High policy salience, and Arkansas offers a well-defined implementation-and-reversal episode. ACS/CPS are accessible and can support subgroup analysis.
- Concerns: Causal inference is the dealbreaker: effective treatment is essentially **one state** with sustained implementation (Arkansas), so DiD with <10 clusters is fragile and standard errors/inference are not credible; this topic is also already heavily studied. Additionally, using overall state coverage rates risks major dilution because the affected group is a subset (expansion adults subject to reporting).
- Novelty Assessment: **Low.** Arkansas Medicaid work requirements have a substantial existing empirical literature using surveys and administrative data.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (plenty of pre-years available)
  - Selection into treatment: **Marginal** (policy adoption tied to state politics/waiver environment)
  - Comparison group: **Marginal** (good comparisons are hard; waiver-seeking states differ)
  - Treatment clusters: **Weak** (effectively N≈1 for real implementation)
  - Concurrent policies: **Marginal** (Medicaid administration changes, outreach, other waiver features)
  - Outcome-Policy Alignment: **Strong** (coverage is directly targeted)
  - Data-Outcome Timing: **Marginal** (depends on ACS/CPS reference period; must map carefully to Jan 2018–Mar 2019 exposure)
  - Outcome Dilution: **Weak** *as stated* (statewide coverage is mostly unaffected; would need to restrict to likely-affected Medicaid expansion adults to avoid dilution)
- Recommendation: **SKIP** (unless redesigned as a single-state design—synthetic control / interrupted time series—using administrative enrollment/disenrollment data and a clearly defined affected sample)

---

### Summary

Only **Idea 1 (ERPOs and firearm suicide)** looks like a genuinely high-upside project, provided the team strengthens pre-periods, fixes exposure timing, and directly addresses policy bundling and dilution with intensity/implementation data. Ideas 4 and 5 fail mainly on **outcome alignment/dilution** (Idea 4) and **too few treated clusters + heavy prior literature** (Idea 5). Idea 2 and Idea 4 are “maybe” topics in principle, but with the proposed data/design they are unlikely to clear identification standards without substantial redesign.