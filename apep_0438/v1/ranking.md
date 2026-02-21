# Research Idea Ranking

**Generated:** 2026-02-21T19:08:00.161717
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 9122

---

### Rankings

**#1: The Patriarchy of the Public Square — How Open-Air Assembly Voting Shapes Gender Politics**
- Score: **78/100**
- Strengths: Extremely distinctive institutional setting with a compelling **border-based difference-in-discontinuities** logic (AR–AI) that directly nets out permanent cross-border differences. Outcomes (referendum vote shares + turnout) are high-frequency, well-measured, and tightly linked to the political mechanism.
- Concerns: **Inference is fragile** because treatment is assigned at the **canton** level with very few treated/control cantons (even if many Gemeinde×referendum observations). Abolition may be endogenous to evolving social norms (AR modernizing faster than AI), so the key is demonstrating **no emerging discontinuity pre-1997** and stable covariates at the border.
- Novelty Assessment: **High.** Swiss direct democracy is studied, but Landsgemeinde abolition + *public vs secret ballot* effects on gender-referendum behavior via spatial RDD/DiDisc is not a “100 papers already” topic.
- DiD Assessment (if applicable): *(Primary design is spatial RDD/DiDisc rather than canonical state-panel DiD; ratings below interpret it as a border DiD/DiDisc.)*
  - Pre-treatment periods: **Strong** (1981–1996 provides many pre votes to test for pre-discontinuities)
  - Selection into treatment: **Marginal** (abolition was locally chosen; could correlate with liberalization trends)
  - Comparison group: **Strong** (AR vs AI is unusually well-matched culturally/geographically; same micro-region)
  - Treatment clusters: **Weak** (effectively a handful of cantons; canton-level assignment makes conventional clustered inference hard)
  - Concurrent policies: **Marginal** (other cantonal reforms in late 1990s could differ; DiDisc helps but not automatically)
  - Outcome-Policy Alignment: **Strong** (institution changes how votes are cast; outcomes are vote shares/turnout on precisely those votes)
  - Data-Outcome Timing: **Strong** (post-abolition federal referendums occur after the institutional switch; can drop transition-year votes if needed)
  - Outcome Dilution: **Strong** (the entire electorate in treated Gemeinden is exposed to the voting institution)
- Recommendation: **PURSUE (conditional on: (i) a pre-1997 “no discontinuity” event-study at the AR–AI border; (ii) an inference plan not relying on few-canton clustering—e.g., randomization/permutation inference over border segments + spatial HAC/Conley; (iii) tight bandwidth + covariate/balance and donut checks around border towns).**

---

**#2: Mandatory Kindergarten and Maternal Labor Supply — Spatial Evidence from the HarmoS Concordat**
- Score: **63/100**
- Strengths: High policy relevance (female labor supply/childcare constraint) and the **staggered rollout + borders** is potentially powerful if the outcome data support credible pre-trends. Plenty of potential border observations in large cantons.
- Concerns: As proposed, **Strukturerhebung starts in 2010**, which gives **too little/no pre-period** for early adopters (e.g., BS 2005; ZH/SG/TG 2008), making trend validation close to impossible. Also, big risk of **outcome dilution** if you use all women rather than mothers of 4–5 year-olds (the directly affected margin).
- Novelty Assessment: **Medium.** Kindergarten/early schooling and maternal labor supply is heavily studied internationally, but *Swiss HarmoS + spatial border design* is plausibly new.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Weak** (for key early adopters with 2010+ outcomes; can be fixed only by redesign—see below)
  - Selection into treatment: **Marginal** (cantons opted in/out; plausibly correlated with preferences/trends in family policy)
  - Comparison group: **Marginal** (border neighbors can be comparable, but HarmoS adopters vs rejecters may differ systematically)
  - Treatment clusters: **Marginal** (number of adopting cantons is decent, but effective clusters in any border-RDD/DiDisc window may be limited)
  - Concurrent policies: **Marginal** (HarmoS bundles standardization; cantons also changed childcare subsidies/places—must control/document)
  - Outcome-Policy Alignment: **Strong/Marginal** (strong if outcome is **labor supply of mothers with kindergarten-age youngest child**; marginal if using broad female LFP)
  - Data-Outcome Timing: **Marginal** (Structural Survey interviews occur throughout the year; exposure may be partial in the adoption year—need careful “first full school-year” coding)
  - Outcome Dilution: **Weak** if using all women; **Strong** if restricting to households with youngest child in the affected ages and/or using intensive-margin outcomes for that subgroup
- Recommendation: **CONSIDER (conditional on: (i) redesign around later-adopting cantons to obtain ≥5 pre-years in the *same* data; and/or (ii) obtaining pre-2010 small-area labor outcomes; (iii) restricting to mothers with age-eligible children to avoid dilution; (iv) careful school-year timing coding).**

---

**#3: Tax Marriage Penalty Reform and Female Labor Supply at Canton Borders**
- Score: **56/100**
- Strengths: Clear economic mechanism (secondary-earner tax wedge) and strong policy interest in Switzerland; border designs could, in principle, remove slow-moving cultural confounds.
- Concerns: Treatment is **not a clean binary**—it’s a bundle of cantonal tax schedules, deductions, and brackets, so “splitting vs joint” may be a poor proxy for the **effective marginal tax rate** facing the wife. Major risk of omitted-policy bias (cantons differ on many fiscal dimensions) and serious **dilution** unless you can isolate married women by spouse income/children (which is hard at Gemeinde level without microdata).
- Novelty Assessment: **Low–Medium.** Female labor supply responses to taxation/marriage penalties are a large literature; Swiss setting is less saturated, but the core question is well-trodden.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Marginal** (possible with SAKE/Structural Survey, but geography and consistent measurement over time are issues)
  - Selection into treatment: **Marginal/Weak** (tax reforms often respond to political/economic conditions and migration/tax competition)
  - Comparison group: **Marginal** (border areas comparable, but fiscal competition implies endogenous sorting/migration)
  - Treatment clusters: **Marginal** (more cantons than Landsgemeinde, but still not huge; and reforms vary in content)
  - Concurrent policies: **Weak** (tax reforms typically coincide with other cantonal fiscal changes affecting labor supply/migration)
  - Outcome-Policy Alignment: **Marginal** (alignment becomes strong only if you can construct household-level net-of-tax rates; “system type” is a noisy proxy)
  - Data-Outcome Timing: **Marginal** (depends on exact effective dates and survey reference periods)
  - Outcome Dilution: **Weak** unless restricted to married women likely at the participation margin
- Recommendation: **SKIP** (unless you can: (i) build credible household-level tax-rate variation from microdata + tax simulators; and (ii) isolate a reform with clean, narrow change and well-documented effective dates).

---

**#4: Domestic Violence Police Removal Powers (Wegweisung) and Women's Safety**
- Score: **49/100**
- Strengths: Very high policy relevance; staggered adoption could allow credible quasi-experimental work if outcomes and dates are pinned down. Potential to contribute to an important international policy debate with Swiss institutional detail.
- Concerns: Data feasibility is the core problem: **adoption dates and enforcement intensity** may be hard to code, DV incidents are **sparse** at small geography, and—most importantly—policy likely changes **reporting/recording** (measured DV) even if true violence falls, threatening outcome interpretability.
- Novelty Assessment: **High.** Likely not many (any) Swiss causal papers on Wegweisung using border-based designs.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Marginal/Weak** (depends on availability/consistency of police & hospital series; often short or redefined)
  - Selection into treatment: **Marginal** (cantons may adopt in response to DV concerns or advocacy pressure)
  - Comparison group: **Marginal** (neighbor cantons plausible, but policing/reporting regimes differ)
  - Treatment clusters: **Marginal** (could be enough cantons, but usable border comparisons may be fewer)
  - Concurrent policies: **Weak** (DV policy packages—hotlines, shelter funding, policing protocols—often change together)
  - Outcome-Policy Alignment: **Weak** if relying on police-reported DV alone (mechanically affected by reporting); **Marginal** with hospital assault admissions/shelter nights as complements
  - Data-Outcome Timing: **Marginal** (legal effective dates vs implementation/enforcement lags)
  - Outcome Dilution: **Strong** if using DV-specific outcomes (not general crime)
- Recommendation: **SKIP** (unless you first secure: (i) a consistent canton-by-month DV outcome less sensitive to reporting—e.g., hospital admissions; (ii) well-documented legal + implementation dates; (iii) evidence on reporting shifts, possibly via multiple outcomes).

---

**#5: The Long Shadow of Late Suffrage — Persistence of Gender Norms at Canton Borders**
- Score: **44/100**
- Strengths: Big-picture question (institutional persistence of political rights) that policymakers and scholars find interesting; outcomes are measurable in modern data.
- Concerns: Identification is weak: the cleanest “late vs early” borders tend to be entangled with **language/culture (Röstigraben)** or have **tiny samples** and limited within-language variation. Also, this topic is **already prominently studied** in Switzerland (notably Slotwinski & Stutzer), so the incremental contribution is limited unless the design is unusually clean.
- Novelty Assessment: **Low.** The Swiss suffrage timing shock is well known and already exploited; “persistence decades later” is a natural extension many have considered.
- DiD Assessment (if applicable): *(Mostly cross-sectional persistence RDD rather than DiD; judged against the spirit of the checklist.)*
  - Pre-treatment periods: **Weak** (treatment occurred decades earlier; no meaningful pre-trend testing for modern outcomes)
  - Selection into treatment: **Weak** (timing reflects deep preferences/norms—exactly what drives modern outcomes)
  - Comparison group: **Weak** (early/late borders often confounded by language/culture or are too small to be credible)
  - Treatment clusters: **Weak** (few informative borders with substantial “dose” differences)
  - Concurrent policies: **Marginal** (many other institutions co-evolved over decades)
  - Outcome-Policy Alignment: **Marginal** (modern labor/vote outcomes are plausibly linked to norms, but many channels)
  - Data-Outcome Timing: **Strong** (modern outcomes are long after treatment—timing isn’t the issue)
  - Outcome Dilution: **Marginal** (effects may be diffuse; hard to isolate who is “treated” besides broad population)
- Recommendation: **SKIP** (unless you can find a uniquely clean within-language border with substantial timing gap and strong balance, which is unlikely at scale).

---

### Summary

This is a strong batch conceptually, with one standout: **Idea 1** has unusually elegant identification logic (AR–AI “no-border-discontinuity-before, discontinuity-after”) and high-quality outcome data, making it the clear first project—provided inference is handled carefully with few treated cantons. **Idea 2** is worth considering but needs a redesign to avoid the **fatal pre-period problem** and to prevent **dilution** by focusing on directly affected mothers. Ideas **3–5** face either heavy confounding (tax bundles; suffrage persistence) or major feasibility/measurement threats (DV reporting), and should be deprioritized.