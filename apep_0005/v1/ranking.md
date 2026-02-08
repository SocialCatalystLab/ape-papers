# Research Idea Ranking

**Generated:** 2026-01-17T02:08:14.676484
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5591

---

### Rankings

**#1: Arkansas Minimum Wage Stair-Step Increases (2019-2021)**
- **Score: 70/100**
- **Strengths:** Clear, well-timed statewide shocks with large magnitude, and good policy salience. Data are broadly adequate to detect wage distribution changes and (coarser) employment/hours effects, especially with an event-study DiD.
- **Concerns:** Novelty is limited given the enormous minimum-wage literature; reviewers may see this as “yet another state DiD” unless you add something distinctive (e.g., border-county design, distributional methods à la Cengiz et al., or the unusually high MW/median ratio). Using ACS/PUMS for employment effects is noisy (annual income, hours/weeks measurement error), and control states may have contemporaneous policy/economic shocks that strain parallel trends.
- **Novelty Assessment:** **Moderately studied topic overall; Arkansas-specific episode less studied**, but “minimum wage DiD” is heavily saturated.
- **Recommendation:** **PURSUE** (but strengthen design: event-study with modern staggered estimators, border-county robustness, explicit checks for other state policy changes, and consider CPS MORG as a complementary wage/hourly measure).

---

**#2: Universal License Recognition and Interstate Migration**
- **Score: 62/100**
- **Strengths:** Good policy relevance and multi-state variation; PUMS migration questions can directly measure interstate inflows. Design heterogeneity (“universal” vs “substantially similar”) gives a credible angle beyond the first-wave papers.
- **Concerns:** This has **already been studied** (including published work showing sizable migration effects), so incremental contribution hinges on a sharper design or new mechanism (e.g., design-stringency gradient, occupation-specific exposure, or distinguishing licensing-heavy vs licensing-light states). Identification is threatened by endogenous adoption (states adopting ULR may simultaneously pursue broader pro-migration/pro-growth agendas); you’ll need strong pre-trend/event-study evidence and possibly controls for concurrent reforms.
- **Novelty Assessment:** **Moderately studied and rapidly growing**; not “novel,” but still room if you credibly exploit cross-state design differences and report transparent sensitivity.
- **Recommendation:** **CONSIDER** (promising if you can convincingly address endogenous adoption and measurement of “licensed” occupations).

---

**#3: Nebraska Occupational Board Reform Act (LB299, 2018)**
- **Score: 58/100**
- **Strengths:** Higher novelty than the first two—state-specific, comprehensive “meta-reform” of licensing is less commonly evaluated, and the policy question is relevant to current licensing-reform debates.
- **Concerns:** The treatment is **diffuse and slow-moving** (a review cycle, “least restrictive” standard, petitions), so the timing is not sharp and first-stage effects may be weak—bad for DiD power and interpretability. With ACS/PUMS, you also can’t easily observe which licenses actually changed and when, so the empirical “dose” of reform is hard to measure (risking null results that are uninterpretable).
- **Novelty Assessment:** **Relatively understudied**, especially for Nebraska; but novelty may not translate into publishable inference if the policy doesn’t generate a measurable labor-market shock.
- **Recommendation:** **CONSIDER** only if you can assemble supplementary administrative/legislative data on which occupations/licenses were modified and construct an exposure measure (otherwise the identification is likely too weak).

---

**#4: Arkansas Fair Chance Licensing Reform (Act 990, 2019)**
- **Score: 48/100**
- **Strengths:** The policy design is interesting (limits on considering felonies; pre-application petition), and fair-chance licensing is salient for workforce reentry and shortages.
- **Concerns:** The core problem is **fundamental data mismatch**: ACS/PUMS does not identify criminal records, so “licensed vs unlicensed occupations” is an extremely indirect proxy for the treated population, making parallel trends implausible and expected effects heavily diluted. Without linking to criminal-history or licensing-application data, it will be hard to make a credible causal claim about the intended channel.
- **Novelty Assessment:** **Somewhat understudied for Arkansas specifically**, but fair-chance licensing reforms are increasingly analyzed; the key limitation is not novelty but identification.
- **Recommendation:** **SKIP** unless you can obtain/merge administrative data (licensing applications/approvals by board, or corrections-to-workforce linkages) that directly measure exposure for people with records.

---

**#5: New Hampshire Day of Rest Requirement (Historical RDD)**
- **Score: 25/100**
- **Strengths:** High novelty; almost certainly understudied, and the policy itself is distinctive.
- **Concerns:** The proposed RDD is not credible: there is no clean assignment variable/threshold, border PUMAs are too coarse for a meaningful discontinuity, and the policy is longstanding (no clear pre/post). Small samples near borders further undermine power and precision.
- **Novelty Assessment:** **Very understudied**, but essentially not identifiable with the proposed approach/data.
- **Recommendation:** **SKIP**.

---

### Summary

This is a mixed batch: the best ideas are the ones with either (i) a clear, strong policy shock and feasible data (Arkansas minimum wage) or (ii) lots of variation to exploit (ULR and migration). I would start with **Idea 1** (tighten identification and complement ACS with CPS MORG if possible) and keep **Idea 4** as a secondary option if you can credibly handle endogenous adoption and licensed-occupation measurement; the two licensing-reform-in-one-state DiDs are substantially weaker unless you can add administrative exposure data.