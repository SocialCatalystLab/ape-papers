# Research Idea Ranking

**Generated:** 2026-02-01T05:03:23.388394
**Model:** openai/gpt-5-mini (reasoning: high)
**Tokens:** 9501

---

### Rankings

#1: Distance Thresholds and School Choice: A Spatial RDD at the Skolskjuts Eligibility Boundary
- Score: 82/100
- Strengths: Clean, high-quality local identification if you can measure students’ locations precisely — municipal distance cutoffs are plausibly sharp and exist across most municipalities; outcomes (school take-up, travel distance, meritvärde) map directly to the policy mechanism. Large potential sample (many municipalities, ~1M students) and high policy relevance for equity and school-market debates.
- Concerns: The design depends on access to geocoded home addresses (restricted microdata) or else will rely on DeSO centroids (which induces measurement error and a fuzzy RD). Municipal rules include exceptions (safety exemptions, eligibility for friskola students, grade-specific thresholds) and the running-variable definition (straight-line vs road/walking distance) must be coded exactly.
- Novelty Assessment: High — I know of few (if any) papers exploiting Swedish skolskjuts thresholds via a spatial RDD. There is related international literature on transport and school choice, but this exact natural experiment appears understudied.
- Identification quality (notes, not a DiD): RDD is plausibly sharp (eligibility rule is deterministic), manipulation risk is low (home address is hard to manipulate at scale), but watch for heterogeneous municipal exceptions and measurement error if address-level data are unavailable.
- Recommendation: PURSUE (conditional on: gaining access to address-level geocoded student data or high-resolution parcel data; precise coding of each municipality’s eligibility rules and use of network (walking/road) distances).

#2: Municipal Border Discontinuity in Skolskjuts Thresholds
- Score: 67/100
- Strengths: Uses geographic discontinuities at municipal borders — can be implemented at DeSO/neighborhood level (less dependence on restricted individual addresses) and provides a useful robustness/complement to the within-municipality RDD. Directly policy-relevant and allows heterogeneity analysis (low-SES vs high-SES neighborhoods).
- Concerns: Requires manual scraping/coding of 290 municipality rules to find border pairs with differing thresholds; useful border pairs may be limited. Border neighborhoods are a small subsample (local treatment) and neighboring municipalities may differ on other dimensions (school supply, demographic sorting) that complicate inference.
- Novelty Assessment: Moderate-to-high — cross-municipal border RD is a standard technique but applying it to skolskjuts thresholds in Sweden appears novel.
- Identification quality (notes): Credible where border pairs are numerous and balanced; must show covariate balance across the border, test for other discontinuous municipal policies at the same border, and ensure enough border pairs for inference.
- Recommendation: CONSIDER — pursue as a robustness strategy or as the main design if address-level data are unavailable, but only after an initial mapping exercise shows a sufficient number (ideally >>10) of informative border pairs.

#3: Transport Subsidy Generosity and Educational Equity: DiD with Municipal Policy Changes
- Score: 30/100
- Strengths: If credible exogenous changes can be found, a DiD could estimate dynamic effects on segregation and achievement and use panel variation to examine timing and heterogeneous effects.
- Concerns: Primary threat is endogenous policy change — municipalities likely adopt /contract skolskjuts for budgetary, political, or local-need reasons (selection on trends). There is no central registry of policy-change timing; documenting changes will require laborious archival work and may still leave identification weak or too few treated units for credible inference.
- Novelty Assessment: Moderate — studying policy changes over time is valuable, but many of the identification hurdles are common and difficult here.
- DiD Assessment (MANDATORY — eight criteria):
  - Pre-treatment periods: Strong — Kolada and other sources provide multi-year municipal time series (2010–2024 is available), satisfying the ">=5 years" test in many cases.
  - Selection into treatment: Weak — municipalities choose eligibility rules; changes are likely endogenous (responding to costs, political preferences, or local school outcomes), which is a potential dealbreaker unless you can find plausibly exogenous shocks (court decisions, budget shocks, or central mandates).
  - Comparison group: Marginal — you can define never-treated or later-treated municipalities, but they may differ systematically from adopters (observable differences likely).
  - Treatment clusters: Weak — unknown how many municipalities changed rules; preliminary expectation is that the number of clean, well-documented treatment events will be small (<10) unless a common shock exists.
  - Concurrent policies: Marginal — municipal-level school and welfare policies often co-occur; disentangling concurrent reforms will be challenging.
  - Outcome-Policy Alignment: Strong — outcomes proposed (school choice uptake, segregation, achievement gaps) align directly with the policy’s intended channels.
  - Data-Outcome Timing: Marginal — Kolada metrics are annual; many municipal policy changes may be enacted mid-year (July 1) or with complicated rollout, so many "post" observations may be only partially exposed unless you carefully align cohorts and measurement months.
  - Outcome Dilution: Marginal — some policy changes affect most students in a municipality (Strong), but many changes are grade-specific or conditional (e.g., only safety exemptions, only friskola students), meaning the treated share may be substantially <50% in practice.
- Recommendation: SKIP (unless you can identify an exogenous, plausibly random or quasi-random source of municipal variation — e.g., a court ruling or abrupt budget shock that changes skolskjuts eligibility across many municipalities simultaneously). Given current uncertainty about treatment timing and selection, DiD is not credible as the primary route.

### Summary
Idea 1 (spatial RDD at the eligibility cutoffs) is the clear first choice — it offers the best combination of novelty, clean causal leverage, and direct policy relevance, but it hinges on access to geocoded residential microdata and careful coding of municipal exceptions and distance definitions. Idea 2 (border RDD) is a useful second choice or robustness design, especially if address-level microdata are unavailable — but it requires a time-consuming mapping exercise and may yield fewer informative comparisons. Idea 3 (DiD) is tempting but currently the weakest: selection into treatment, uncertain treatment counts/timing, and possible concurrent municipal policies make credible DiD inference unlikely without a clear exogenous shock.

If you want next steps, I can:
- Outline the exact data request/variables and legal route (MONA / statistical agency) needed to implement Idea 1; or
- Draft a short plan and scraping checklist to map municipal skolskjuts rules across all 290 municipalities to assess feasibility for Idea 2.