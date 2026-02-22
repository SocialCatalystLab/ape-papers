# Research Idea Ranking

**Generated:** 2026-02-21T22:14:27.835935
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 5660

---

### Rankings

**#1: Where Cultural Borders Cross — Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy**
- Score: **76/100**
- Strengths: Exceptionally clean *institutional* source of spatial variation (centuries-old borders) with very high-quality, high-frequency outcome data (municipal referendum returns) and large N. The interaction (“language × religion”) and the *intersection* design is genuinely new and speaks to a big question in cultural economics (modular vs. intersectional culture).
- Concerns: Spatial RDD validity hinges on “as-good-as-random” sorting near borders; Swiss internal migration and commuting could still generate discontinuities in covariates. The “religion” measure (e.g., 2000 census majorities) risks being partly endogenous to modern mobility/selection unless you can anchor it in historically predetermined confessional status or pre-period religion shares.
- Novelty Assessment: **High-but-not-virgin**. There is a large Röstigraben literature (language border) and a smaller Swiss religion-border literature, but **their interaction + gender-referendum outcomes + multidimensional frontier design** is much less studied and plausibly publishable as a clear contribution.
- Recommendation: **PURSUE (conditional on: (i) strong covariate/balance and sorting tests—density tests, covariate continuity, “donut” RDs near towns/transport nodes; (ii) use historically fixed confessional affiliation where possible, not only 2000 religion shares; (iii) pre-register a small set of primary outcomes/referenda to avoid specification searching across many ballots).**

---

**#2: Childcare Mandates and the Maternal Employment Gap — Spatial Evidence from Swiss Canton Borders**
- Score: **48/100**
- Strengths: High policy relevance (childcare provision and maternal employment) and a potentially strong *spatial discontinuity* intuition if mandates truly change municipal childcare supply in a discrete way at canton borders. If STATENT provides consistent municipal-by-sex employment measures, the outcome is well-aligned with the mechanism.
- Concerns: As written, the **DiD component is close to a dealbreaker**: STATENT starts ~2011 while key mandates begin in 2010, leaving ~0–1 pre-years for early adopters; later adopters still likely have short pre-trends. Also, the number of treated clusters (cantons) is likely **<10**, and “mandate” may not be a sharp treatment (implementation intensity, financing, and slots may vary within canton), risking weak first-stage and attenuation.
- Novelty Assessment: **Moderate**. There is an enormous global literature on childcare and maternal labor supply; Switzerland-specific *mandate-at-borders* evidence is less common, but the core causal question is heavily studied elsewhere.
- DiD Assessment (if applicable):
  - **Pre-treatment periods:** **Weak** (STATENT 2011–2024 vs. Bern/Zurich mandate 2010 ⇒ essentially no credible pre-trends test for key early-treated cantons unless you add older data sources).
  - **Selection into treatment:** **Marginal/Weak** (cantons adopting mandates may do so responding to urbanization, female LFP trends, or political demand; not clearly external).
  - **Comparison group:** **Marginal** (neighboring non-mandate cantons can be plausible, but canton borders often separate systematically different labor markets/tax regimes; needs border-pair fixed effects and strong covariate checks).
  - **Treatment clusters:** **Weak** (likely 2 early treated; even with later adopters still plausibly <10 cantons ⇒ fragile inference).
  - **Concurrent policies:** **Marginal/Weak** (cantons changing childcare mandates often also change subsidies, parental leave complements, tax rules, or education spending—must document and control/argue).
  - **Outcome-Policy Alignment:** **Strong (if the mandate measurably increases childcare slots/cost reductions)**; employment/part-time/gender earnings are directly on the causal pathway. But you need a **first-stage** measure (slots, coverage, fees) to show the mandate actually moved childcare access.
  - **Data-Outcome Timing:** **Marginal** (STATENT is typically annual with a reference date/period; if measured end-of-year and the mandate begins mid-year, first “treated” year may be partial exposure—must verify exact effective dates and STATENT timing).
  - **Outcome Dilution:** **Marginal** (policy targets parents of young children; municipal female employment includes many women not directly affected. You’ll want age-of-child or “mothers of 0–4” outcomes if possible; otherwise effects are diluted).
- Recommendation: **SKIP (unless redesigned)**. Upgrade to **PURSUE** only if you can: (i) obtain **≥5 pre-years** of comparable municipal female employment (e.g., older administrative series, census/structural survey-based measures, or consistent cantonal panels); (ii) document a strong first stage on childcare supply/cost; (iii) expand treated clusters or shift emphasis to a **border-RDD/event-study within border-pairs** rather than canton-level staggered DiD.

---

**#3: The Long Shadow of Late Suffrage — How Women's Political Enfranchisement Shaped Economic Equality in Swiss Cantons**
- Score: **32/100**
- Strengths: Big, important question with obvious historical and policy relevance; Swiss canton-level suffrage timing is a well-defined institutional variation and could be valuable for political-economy outcomes closely tied to enfranchisement (e.g., female representation).
- Concerns: Identification is fundamentally hard here: adoption timing is likely **endogenous to canton culture and gender norms** (selection into treatment), and after 1971 everyone is treated (no long-run control group). Data feasibility is also problematic: many economic outcomes (pay gaps, detailed LFP) are unlikely to exist consistently back to the 1950s at canton level, and **N=26** makes inference fragile.
- Novelty Assessment: **Low-to-moderate**. The suffrage-and-policy literature is large; Switzerland is distinctive, but Swiss women’s suffrage has been studied in political economy contexts, and the proposed *economic equality* angle is not enough to overcome the identification/data constraints as currently framed.
- DiD Assessment (if applicable):
  - **Pre-treatment periods:** **Weak** (credible ≥5-year pre-periods for the *economic* outcomes are unlikely at canton level in the 1950s/60s; without them, pre-trends are largely untestable).
  - **Selection into treatment:** **Weak** (cantons adopting earlier almost surely differed systematically in gender attitudes and modernization trends).
  - **Comparison group:** **Weak** (early adopters vs. late adopters are not “similar controls”; and after 1971 there are no never-treated controls).
  - **Treatment clusters:** **Marginal/Weak** (26 cantons total; only a subset adopt pre-1971, and post-1971 there’s no untreated group).
  - **Concurrent policies:** **Weak** (1959–1971 coincides with major structural and legal changes; hard to isolate suffrage).
  - **Outcome-Policy Alignment:** **Marginal** (representation aligns well; long-run pay gaps/LFP are influenced by many forces beyond voting rights, making attribution hard).
  - **Data-Outcome Timing:** **Marginal/Weak** (annual timing may be workable, but historical series alignment and measurement changes are likely severe).
  - **Outcome Dilution:** **Strong** (enfranchisement affects a very large share of the electorate/population), but this does not rescue the design.
- Recommendation: **SKIP** (unless reframed to a narrower, more defensible design—e.g., focusing on outcomes very close to the political mechanism, or using alternative methods like synthetic control for the 1990 Appenzell court-imposed change with richer local outcomes).

---

### Summary

This is a mixed batch: **Idea 1** stands out as the only proposal that is simultaneously novel, well-identified, and data-feasible at scale—worth prioritizing. **Ideas 2 and 3** both run into major identification problems (especially **insufficient pre-periods and too few treatment clusters** for DiD, plus endogeneity of adoption timing), and should be deprioritized unless substantially redesigned around stronger data and/or sharper designs.