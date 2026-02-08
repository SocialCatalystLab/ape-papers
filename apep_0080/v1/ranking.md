# Research Idea Ranking

**Generated:** 2026-01-29T02:49:24.724494
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5677
**OpenAI Response ID:** resp_0647c366f11f2bc000697abc64f4808192b511bb629f40fb56

---

### Rankings

**#1: Click It or Ticket at the Border: A Spatial Regression Discontinuity Analysis of Primary Seatbelt Enforcement Laws**
- **Score: 74/100**
- **Strengths:** Spatial border-RDD is a genuinely strong upgrade over the well-worn state-year DiD on seatbelt laws, and the long panel plus many “turning on” borders creates excellent placebo/validation opportunities. FARS geocoding enables tight local comparisons and rich mechanism tests (ejection, rollover, occupant outcomes).
- **Concerns:** The proposal’s *preferred estimand* (“fatality rate conditional on crash”) is **not identified with FARS alone** because FARS only contains fatal crashes—without a near-border measure of total crashes (fatal + nonfatal) you cannot cleanly separate crash incidence from survivability. Border designs also face **cross-border traffic composition** (who is driving where) and enforcement/policing discontinuities that may not be “about seatbelts” but still change fatal outcomes.
- **Novelty Assessment:** **High for design, moderate for topic.** Seatbelt laws are heavily studied, but I do not know of many (or any) clean *geocoded border-RDD* implementations for primary vs. secondary enforcement; that’s a real contribution if executed well.
- **Recommendation:** **PURSUE (conditional on: obtaining a credible denominator/exposure measure near borders—e.g., harmonized police-reported crash data or segment-level VMT; and a pre-analysis plan for spillovers/composition, e.g., donut RD, restricting to residents if feasible, and clustering at border-segment level).**

---

**#2: Slower Neighbors, Safer Roads? Speed Limit Differentials and Border Crashes**
- **Score: 66/100**
- **Strengths:** The treatment is plausibly *sharper* than most behavior regulations because speed limits change literally at the state line on the same road, making the border-RDD conceptually tight. Outcome-policy alignment is strong: higher limits should raise speeds and crash severity via physics, and restricting to specific interstate segments reduces heterogeneity.
- **Concerns:** **Few treated borders/episodes** (especially for 80 mph) makes inference fragile and sensitive to a handful of corridors; you’ll need corridor-by-corridor estimates and careful aggregation. Data feasibility hinges on getting **credible segment-level exposure (VMT/AADT) at the border-interstate level**; otherwise “fatal crashes near the border” confounds risk with traffic volume shifts and rerouting.
- **Novelty Assessment:** **Moderate-high.** Speed limits are a classic topic with many papers, but a well-executed *border/interstate-segment RDD* is less common and could add value by focusing on the most comparable road environments.
- **Recommendation:** **CONSIDER (upgrade to PURSUE if you can secure high-quality traffic counts/VMT by segment and show adequate sample size within tight bandwidths on multiple corridors).**

---

**#3: Texting While Dying: A Spatial RDD of Distracted Driving Laws**
- **Score: 58/100**
- **Strengths:** Border-RDD usefully avoids many state-level confounds that plague DiD in this area, and the mechanism predictions (single-vehicle, run-off-road, daytime) are well-motivated. Policy relevance remains high given ongoing enforcement debates and heterogeneous statute strength.
- **Concerns:** The *measurement environment* is much worse here: (i) texting-ban “primary vs secondary” enforcement in practice may not generate a sharp deterrence discontinuity, and (ii) the outcome mechanisms are noisy because **FARS distraction coding is notoriously incomplete/nonclassical** and smartphone adoption changes rapidly over the same window. Also, the adoption window is compressed and most states eventually treat, leaving **fewer clean border contrasts** and shorter credible pre-periods for placebo RD-by-year checks.
- **Novelty Assessment:** **Moderate.** There’s a substantial texting-ban DiD literature already; the border-RDD angle is less studied, but the underlying policy question is not new.
- **Recommendation:** **CONSIDER (only if you pre-commit to outcomes that don’t rely on “distraction” indicators—e.g., total fatalities and strongly theory-tied crash types—and demonstrate many usable borders with stable pre-period RD placebos).**

---

**#4: High Times at the Border: Recreational Marijuana and Traffic Safety**
- **Score: 44/100**
- **Strengths:** Policy relevance is high and geocoded borders are an intuitive way to study access and spillovers. The ambiguity (impairment vs alcohol substitution) is a real policy question.
- **Concerns:** This is the most vulnerable to border-RDD violations: **cross-border purchasing/consumption spillovers are first-order**, so “treatment” is not geographically localized to the legalized side. FARS drug involvement is also compromised by **heterogeneous testing/reporting across states and over time**, making both levels and discontinuities hard to interpret; plus the topic has a large existing literature, including some spatial/border approaches in adjacent settings.
- **Novelty Assessment:** **Low-moderate.** Marijuana legalization and traffic safety has been studied extensively; incremental novelty from an RDD border framing is limited unless you have unusually good data on usage/testing or can isolate a particularly clean policy discontinuity.
- **Recommendation:** **SKIP (unless you can obtain harmonized toxicology/testing regimes or a design that directly addresses spillovers—e.g., distance-to-dispensary openings with credible quasi-random timing, plus validated exposure measures).**

---

### Summary

This is a strong batch in the sense that **spatial border designs** can, in principle, beat standard state-year DiD for these policies. The clear first choice is **Idea 1**, but only if you fix the core feasibility/estimand problem (FARS-only cannot identify “fatality conditional on crash” without additional crash/exposure data). **Idea 3** has the cleanest conceptual border on the same roadway but may be underpowered; **Idea 2** is promising but empirically noisy; **Idea 4** is least promising due to spillovers, measurement, and heavy prior literature.