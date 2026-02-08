# Research Idea Ranking

**Generated:** 2026-01-17T01:32:06.066025
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4987

---

### Rankings

**#1: Universal Occupational License Recognition and Interstate Migration**
- **Score: 71/100**
- **Strengths:** ULR is a relatively new policy with limited existing causal evidence, and the question (migration + labor-market outcomes for licensed workers) is directly tied to the policy’s stated goal. PUMS can measure interstate migration (1-year ago state) and employment/wages at the individual level, enabling occupation heterogeneity.
- **Concerns:** Identification is threatened by (i) few early adopter states, (ii) strong confounding around 2019–2021 (pandemic-era migration/labor shocks), and (iii) treatment misclassification because PUMS observes occupation, not whether someone actually holds a license/reciprocity-eligible credential. Parallel trends for “licensed occupations” in adopter vs non-adopter states is not guaranteed.
- **Novelty Assessment:** **Moderately high novelty**—there are some recent papers, but not a large canon, and occupation-level heterogeneity using large microdata is still thin.
- **Recommendation:** **PURSUE** (with a design that explicitly stress-tests pandemic confounding and uses modern staggered-adoption DiD/event-study methods; consider focusing on post-2020 adopters cautiously or excluding 2020 in robustness).

---

**#2: Cosmetology Training Hours Reduction and Labor Market Outcomes**
- **Score: 62/100**
- **Strengths:** A clear, interpretable policy lever (training-hour requirements) with plausible labor-supply mechanisms and meaningful distributional angles (youth/minority entry). If you can assemble a comprehensive state-by-year hours database (not just a few reforms), it becomes a useful policy evaluation in a heavily regulated occupation.
- **Concerns:** As described, the reform count looks thin (two changes in 2013 + CA in 2022, which is too late for reliable post outcomes), making DiD fragile and sensitive to idiosyncratic state shocks. PUMS measures outcomes among people currently working as cosmetologists—not licensing attainment or entry margins—so effects on entry may be partially missed or diluted; wage effects may be hard to interpret due to selection/composition.
- **Novelty Assessment:** **Moderate novelty**—occupational licensing burdens are widely studied, and cosmetology is a common case study; however, credible causal work tied specifically to hours changes and labor-market outcomes is still not saturated.
- **Recommendation:** **CONSIDER** (conditional on expanding the policy dataset to many reforms and validating that the reforms plausibly shift entry/stock in ways PUMS can detect).

---

**#3: State EITC Supplements and Labor Force Participation**
- **Score: 54/100**
- **Strengths:** Very high policy relevance and abundant variation (many states, multiple enactments/expansions) with huge sample sizes in PUMS. If executed carefully, it can contribute to the “do EITCs still raise participation post-1990s?” debate.
- **Concerns:** Novelty is low and identification is challenging: state EITC adoption/expansion is politically endogenous and bundled with other safety-net or labor-market policies, making parallel trends questionable. PUMS is not ideal for EITC targeting because you can’t reliably construct tax units/eligibility/credit size (filing status, earnings of spouse, number/age of qualifying children), so treatment assignment will be noisy and effects attenuated.
- **Novelty Assessment:** **Low novelty**—there is a large federal EITC literature and a non-trivial state EITC literature (including studies using ACS/CPS); incremental contribution needs to be very clearly differentiated.
- **Recommendation:** **CONSIDER** (only if you can (i) credibly isolate policy changes in generosity, (ii) use strong robustness/controls, and ideally (iii) link to better tax-simulation/eligibility constructs than raw PUMS).

---

**#4: ACA Young Adult Coverage and “Job Lock” at Age 26**
- **Score: 43/100**
- **Strengths:** The conceptual identification idea (age threshold) is attractive, and the broader dependent-coverage policy has clear labor-market implications policymakers recognize.
- **Concerns:** In PUMS, the design is much weaker than it looks: age is measured in **integer years**, so the “RDD at 26” is a coarse, discrete running variable (and not a tight month-of-age discontinuity). More importantly, PUMS does not measure **job-to-job mobility/transitions** well, so “job lock” via mobility is hard to test; you’re largely limited to levels (employment, self-employment) that are influenced by many age-related factors and insurance alternatives (Medicaid, marketplace), blurring the discontinuity.
- **Novelty Assessment:** **Low-to-moderate novelty**—ACA dependent coverage effects have been studied extensively, including labor-market outcomes in multiple datasets; the “aging out” angle is somewhat less common, but not enough to overcome feasibility/measurement issues here.
- **Recommendation:** **SKIP (with PUMS)**. If you want this question, switch to data with month-of-age and mobility measures (e.g., SIPP, CPS matched panels, or administrative claims/employer data).

---

### Summary
This is a decent batch: one genuinely promising, policy-timely idea (ULR), one plausible but currently underpowered/under-specified DiD (cosmetology hours), one highly relevant but heavily mined and hard-to-identify topic (state EITC), and one that is conceptually nice but poorly matched to PUMS (ACA age-26 job lock). I would start with **ULR** and, in parallel, only move cosmetology forward if you can expand the reforms dataset enough to support a credible staggered-adoption/event-study design.