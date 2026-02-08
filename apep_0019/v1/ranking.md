# Research Idea Ranking

**Generated:** 2026-01-17T17:23:10.998071
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6241
**OpenAI Response ID:** resp_01fe36532256abc400696bb71da3108196aa70dd7fab76f73f

---

### Rankings

**#1: Head Start Grant-Writing Assistance and Intergenerational Mobility (Idea 1)**
- **Score: 76/100**
- **Strengths:** Leverages a well-known, credibly sharp historical discontinuity (Ludwig–Miller) with a strong documented first stage in Head Start funding; merging to Opportunity Insights mobility outcomes is straightforward and would speak directly to long-run mobility rather than intermediate outcomes. Identification is comparatively clean because the running variable is predetermined (1960 poverty) and the cutoff rule is transparent (top-300-poorest).
- **Concerns:** The “top 300” rule is a rank-based threshold (not a natural poverty-rate kink), so you must be careful about discreteness/ties and about how the cutoff is constructed in replication data; inference can be fragile if many counties share similar poverty rates. Also, by the 1978–83 cohorts you are relying on persistence of the Head Start funding discontinuity into the late 1970s/early 1980s—this needs to be re-documented in your sample window (or the first stage becomes weak).
- **Novelty Assessment:** **Moderate.** The design is heavily studied for other outcomes (mortality, crime, etc.), but explicit intergenerational mobility (rank-rank style) is plausibly new and policy-relevant.
- **Recommendation:** **PURSUE**

---

**#2: Community Development Block Grant Entitlement Threshold and Mobility (Idea 3)**
- **Score: 68/100**
- **Strengths:** High-upside novelty: the 50,000 entitlement threshold is a clear institutional rule that has not (to my knowledge) been widely exploited for intergenerational mobility. If you can implement it at neighborhood level, it speaks directly to place-based policy design (formula grants vs competitive grants).
- **Concerns:** Data construction is the core risk: Opportunity Insights outcomes are not naturally “city-level,” and building a credible city-to-tract (or city-to-county) exposure measure is nontrivial and could introduce substantial measurement error. Identification may be compromised by sorting/manipulation through annexation and boundary changes around Census years, plus the treatment is fuzzy over time (entitlement status and funding intensity can change).
- **Novelty Assessment:** **High.** CDBG is studied, but this specific RDD (and especially with mobility outcomes) is not standard in the literature.
- **Recommendation:** **CONSIDER** (pursue only if you can credibly solve the geography/exposure mapping)

---

**#3: Clean Air Act 1970 Nonattainment and Intergenerational Mobility (Idea 2)**
- **Score: 61/100**
- **Strengths:** The nonattainment designation provides a relatively crisp regulatory threshold with a documented first stage on pollution reductions; linking early-life environmental improvements to adult mobility is conceptually tight and policy-relevant. Data merging is feasible using historical EPA monitor/nonattainment data and OI county outcomes.
- **Concerns:** Novelty is limited because closely related questions (pollution → adult earnings/human capital) are already well studied; “mobility ranks” may be seen as a repackaging unless you show something qualitatively different (distributional effects, racial gaps, relative-position changes). The monitored-county sample is selective (non-random), and nonattainment regulation also affects local economic structure (potential labor-demand effects) that can confound “health-only” interpretation.
- **Novelty Assessment:** **Low-to-moderate.** Many papers exploit CAA nonattainment; fewer use OI mobility ranks specifically, but the core causal chain has a deep literature.
- **Recommendation:** **CONSIDER**

---

**#4: Voting Rights Act Section 5 Coverage and Intergenerational Mobility (Idea 5)**
- **Score: 57/100**
- **Strengths:** Substantively important and politically salient; potential to speak to long-run economic consequences of civil-rights enforcement and to racial mobility gaps—high policy relevance. If a credible quasi-experimental design is achieved, the contribution could be meaningful.
- **Concerns:** The proposed “sharp RDD” is likely not sharp in practice: Section 5 coverage was determined by a multi-component formula (turnout/registration plus use of tests/devices), sometimes at state and sometimes at sub-state levels, and the forcing variable may not be a single continuous measure with clean local randomization. Data on 1964 registration/turnout at county level can be noisy/incomplete, and the effective near-threshold sample may be small, making results fragile.
- **Novelty Assessment:** **Moderate.** There is a large VRA consequences literature (spending, representation, public employment, etc.), but much less directly on intergenerational income mobility—still, the identification challenge is the binding constraint.
- **Recommendation:** **CONSIDER** (but likely needs an alternative design—e.g., border discontinuities or different instrument—rather than a simple one-dimensional RDD)

---

**#5: Medicaid Early Expansions and Intergenerational Mobility (Idea 4)**
- **Score: 39/100**
- **Strengths:** Policy relevance is clear, and there is strong prior evidence that childhood Medicaid access affects later-life outcomes—so the question matters. In principle, birthdate cutoffs can be clean.
- **Concerns:** With Opportunity Insights data (county-by-birth-year style aggregates), you generally cannot implement a true birthdate-based RDD; you’d need micro data (exact DOB) or at least much finer cohort cells than OI provides, otherwise the “sharp” design collapses into a noisy cohort-level exposure design. Novelty is also limited because OBRA expansions’ long-run effects are already extensively studied; adding “OI mobility ranks” alone is unlikely to overcome identification/data limitations.
- **Novelty Assessment:** **Low.** The policy and long-run outcomes have a crowded literature; the incremental twist (OI mobility) does not rescue weak feasibility here.
- **Recommendation:** **SKIP** (unless you obtain individual-level DOB-linked outcomes or redesign as a different quasi-experiment)

---

### Summary

This is a solid batch conceptually, but only one idea clearly combines strong identification with feasible data *and* enough novelty: **the Head Start OEO discontinuity (Idea 1)**. **CDBG (Idea 3)** is the highest-upside “new policy lever,” but it lives or dies on whether you can credibly map children’s exposure to entitlement-city funding using OI geographies. The **Clean Air Act idea (Idea 2)** is safest technically but has the most novelty risk; **VRA Section 5 (Idea 5)** is important but the proposed RDD is likely not as clean as it sounds.