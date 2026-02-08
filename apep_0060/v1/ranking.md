# Research Idea Ranking

**Generated:** 2026-01-25T14:01:30.395977
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 7088
**OpenAI Response ID:** resp_051cda60e6ec6a4500697613e2b760819185b3e7114be21be0

---

### Rankings

**#1: The 1906 Shock: Individual-Level Migration Responses to the San Francisco Earthquake**
- **Score: 74/100**
- **Strengths:** A large, salient, plausibly exogenous shock with clear behavioral margins (exit vs stay, destination choice) and strong policy resonance (disaster recovery, housing shocks, forced migration). Individual-level linking is a real value-add over aggregate flow studies and enables rich heterogeneity (SES, nativity, family structure).
- **Concerns:** The biggest risk is **linkage/attrition interpretation**: “not found in 1910” conflates death, linkage failure, emigration, and name changes with migration. Also, fine-grained “intensity” analyses may be limited if you cannot credibly map individuals to damaged areas (ward/ED may be too coarse).
- **Novelty Assessment:** **Moderately novel.** The earthquake has been studied (including aggregate migration and long-run city outcomes), but *micro-level, person-linked trajectories and selection* are much less saturated.
- **Recommendation:** **PURSUE (conditional on: a transparent attrition/“not-linked” accounting with bounds or validation; a feasible geography/intensity measure such as ward/ED-level burn/damage maps; benchmarking against at least one comparison city to separate quake effects from decade-wide trends).**

---

**#2: The Making of a City: Multigenerational Origins of San Francisco's 1950 Population**
- **Score: 68/100**
- **Strengths:** Very high-concept novelty: treating a city’s population as a *genealogically accumulated stock* and “reverse-linking” from an endpoint is genuinely original and could become a flagship descriptive piece. San Francisco is a compelling case with distinct historical migration regimes (Gold Rush, Asian immigration, internal migration).
- **Concerns:** Compounding linkage rates across many censuses will produce a **highly selected “traceable” subsample** (native-born, stable names, stable residence), so the genealogical composition risks reflecting linkage mechanics more than history unless you correct/benchmark carefully. Interpretation also gets tricky: you’ll be describing the ancestry of *survivors who are in SF in 1950*, not the full set of lineages that ever built SF.
- **Novelty Assessment:** **High novelty.** There is a huge migration literature, but far less on population-scale “reverse genealogy” of a city’s residents using linked complete-count censuses.
- **Recommendation:** **CONSIDER (lean toward PURSUE if you pre-specify representativeness diagnostics: linkage-rate-by-covariate tables, reweighting strategies, and sensitivity checks showing how conclusions change with linkage propensity).**

---

**#3: Occupational Alchemy: Upward Mobility Among San Francisco Gold Rush Migrants**
- **Score: 63/100**
- **Strengths:** A classic question (“did the frontier deliver mobility?”) with unusually strong historical salience and a plausible empirical contribution via individual longitudinal tracking rather than anecdote or aggregates. The comparison to other destinations (other Western cities) is a good design choice to avoid romanticizing SF-specific patterns.
- **Concerns:** Strong **selection into migration** means you must frame results carefully as mobility *among movers* rather than causal “SF raised mobility.” Linkage quality around 1850–1860 is a major operational constraint; occupational measures (OCCSCORE/OCC1950) are useful but still noisy and may be missing or inconsistently reported for key subgroups.
- **Novelty Assessment:** **Moderate-high novelty.** Frontier/mobility is studied, and linked-census mobility is studied, but *Gold Rush-era SF migrant panels* are not a crowded niche.
- **Recommendation:** **CONSIDER (best if paired with clear counterfactual benchmarking—e.g., movers to Sacramento/Stockton/Portland, and/or propensity/balancing comparisons using pre-move observables).**

---

**#4: Selection into the Frontier: Comparing San Francisco Arrivals Across Eras (1850–1920)**
- **Score: 58/100**
- **Strengths:** Cohort comparisons across distinct historical “regimes” (Gold Rush, railroad era, post-earthquake rebuilding) are intuitive and can generate publishable descriptive facts about changing selection (age/sex, literacy, occupations, family structure).
- **Concerns:** Defining “arrivals” using decennial censuses induces **timing ambiguity** (arrived anytime in the prior 10 years) and survivorship bias (you only observe those present at the census date). Cross-era comparisons are also confounded by changing measurement, changing occupational structure, and changing migration costs; without a tight framework it can become a facts-only catalog.
- **Novelty Assessment:** **Moderate.** Arrival-cohort selection is a common idea; the SF-specific, multi-era implementation is less common, but not conceptually new.
- **Recommendation:** **CONSIDER (stronger as a module inside a broader paper—e.g., feeding into Idea #3 and/or anchoring Idea #1’s genealogical narrative—than as a standalone contribution).**

---

**#5: Roots and Routes: Intergenerational Mobility in San Francisco, 1880–1950**
- **Score: 52/100**
- **Strengths:** Intergenerational mobility is intrinsically important and comparing SF to other major cities is straightforward for readers and policymakers. The MLP is well-suited to father-son linking, and the “did the West differ?” framing is coherent.
- **Concerns:** **Low novelty** relative to the large existing literature on intergenerational mobility using linked historical censuses and on place-based mobility more generally. Also, city comparisons are vulnerable to compositional differences (immigration, race, industry mix) and to linkage/co-residence selection in father-son samples—so it risks being both “known” and hard to interpret cleanly.
- **Novelty Assessment:** **Low-moderate.** There is extensive work on intergenerational mobility over time and (in modern data) across places; historical city-level comparisons are less standardized but not an empty space.
- **Recommendation:** **SKIP as a standalone project (unless you can articulate a distinctly new mechanism or measurement angle—e.g., exploiting SF-specific shocks/regimes or building a novel mobility measure beyond standard rank-rank/transition matrices).**

---

### Summary

This is a strong batch for a **descriptive, historically grounded** agenda using the MLP; the best ideas leverage either a sharp historical episode (the 1906 earthquake) or a genuinely novel measurement concept (reverse genealogy of a city). I would start with **Idea #5 (earthquake)** for its clearer quasi-exogenous narrative and policy salience, and develop **Idea #1** in parallel as a distinctive descriptive “signature” contribution—while treating Ideas #2–#3 as supporting modules and deprioritizing the more saturated intergenerational-city comparison (Idea #4).