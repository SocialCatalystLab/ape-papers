# Research Idea Ranking

**Generated:** 2026-01-18T22:15:13.883503
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4976
**OpenAI Response ID:** resp_0f055bb615db916c00696d4d326e148194978910f17e3a3a7c

---

### Rankings

**#1: Decriminalize, Then Recriminalize — Colorado's Fentanyl Policy Reversal (Idea 2)**
- **Score: 73/100**
- **Strengths:** The policy “reversal” (decriminalize → partial recriminalize) is unusually informative and highly salient for current drug policy. Overdose mortality data are readily available and can support transparent event-study / synthetic control diagnostics.
- **Concerns:** Identification is fragile because the major outcome trend break (2020–2022) coincides with COVID-era shocks and a national fentanyl supply surge; Colorado may simply not have a credible counterfactual. Two treatment dates also complicate interpretation (anticipation, slow enforcement, heterogeneous compliance).
- **Novelty Assessment:** Fairly novel *in this exact configuration* (reversal within one state). However, “drug decriminalization and overdoses” is heavily studied (especially around Oregon Measure 110), so the paper must clearly distinguish what Colorado uniquely identifies.
- **Recommendation:** **PURSUE** (but only with a design that convincingly separates state policy from national fentanyl market shocks—e.g., outcomes by drug type, border-county comparisons, enforcement intensity, and placebo tests).

---

**#2: The 48-Hour Rule — Colorado's Bond Hearing Mandate (Idea 3)**
- **Score: 62/100**
- **Strengths:** Directly policy-relevant to pretrial justice and jail overcrowding, and the mandate is a concrete institutional change that plausibly affects detention length mechanically. If case-level administrative data can be accessed, outcomes (time to hearing, pretrial days detained, FTA) are well-defined.
- **Concerns:** A state-vs-neighbors DiD with ~6–7 units is weak (few clusters, sensitivity to comparison choice), and COVID-era criminal justice operations changed everywhere—parallel trends are a serious concern. Quarterly jail-population aggregates are likely too blunt to detect the mechanism (48-hour hearings) versus broader booking/charging changes.
- **Novelty Assessment:** Moderate. Bail/pretrial reform is extensively studied, but a *statutory 48-hour bond-hearing requirement* is less commonly evaluated as a standalone intervention.
- **Recommendation:** **CONSIDER** (upgrade to PURSUE if you can obtain case-level court/jail data and exploit within-Colorado variation in compliance, judge practices, or implementation timing).

---

**#3: The Price of the Franchise — Florida's Fines and Fees Barrier to Re-enfranchisement (Idea 1)**
- **Score: 58/100**
- **Strengths:** High policy importance and strong equity angle; Florida is a marquee case in voting rights and legal financial obligations. If individual linkage is feasible, the setting supports sharp tests of disparities in effective enfranchisement.
- **Concerns:** The proposed RDD at “fully paid vs. not” is not a clean threshold: payment is highly endogenous (income, motivation, legal assistance, ability to navigate bureaucracy), so “just above/below” is unlikely as-good-as-random. Data linkage (voter file ↔ court LFO balances) is the make-or-break, and eligibility definitions/record-matching error could dominate results.
- **Novelty Assessment:** Medium-low. Amendment 4 and SB7066 have substantial legal, descriptive, and some academic attention; the specific “payment-threshold RDD” angle is less common, but the underlying question is well-trodden.
- **Recommendation:** **CONSIDER** (only if you can secure high-quality person-level LFO balance data and build a design that addresses endogeneity—otherwise it likely becomes an unconvincing correlational exercise).

---

**#4: Iowa's Last Stand — The Final State to End Permanent Disenfranchisement (Idea 5)**
- **Score: 45/100**
- **Strengths:** Clean, high-profile statewide policy change with obvious relevance; election outcomes are easy to measure and the timing is clear. Pre-period elections (2016/2018) provide some baseline.
- **Concerns:** Novelty is poor and the most policy-relevant margin (turnout among newly re-enfranchised individuals) is hard to measure with county aggregates—effects will be diluted and likely underpowered. Existing work (including experimental/outreach evaluations) has already reported null or small effects, making it difficult to contribute without uniquely granular administrative linkage.
- **Novelty Assessment:** Low. Voting rights restoration and turnout has a sizable literature, and Iowa’s 2020 change has already been analyzed in policy research circles.
- **Recommendation:** **SKIP** (unless you can obtain individual-level administrative linkage for the affected population and add something clearly new relative to prior null findings).

---

**#5: Automatic Expungement — Colorado's Clean Slate Law (Idea 4)**
- **Score: 34/100**
- **Strengths:** The question is important and timely; automatic sealing is a major policy trend and Colorado’s rollout creates theoretically nice eligibility cutoffs (time-since-conviction) with low manipulation risk.
- **Concerns:** As written, the design is not feasible: ACS/PUMS cannot identify who actually received sealing, and without treated identifiers you cannot implement the RDD or measure individual employment changes. The policy is also very recent, leaving limited post-treatment labor market observation even with the right data.
- **Novelty Assessment:** Medium-high. Expungement effects are studied, but *automatic* clean-slate regimes remain comparatively new and less saturated—Colorado could be valuable with the right administrative microdata.
- **Recommendation:** **SKIP** (for now). This only becomes fundable if you can secure person-level sealing records linked to UI wage/employment data (or another credible earnings source).

---

### Summary
This batch has one clear front-runner: **Colorado’s fentanyl decriminalization/recriminalization reversal (Idea 2)**, because it is both timely and unusually structured—though identification will be contested unless the counterfactual is exceptionally well defended. **The bond-hearing mandate (Idea 3)** is the best “institutional reform” project but needs microdata to avoid weak state-level DiD inference; **Florida LFO-based re-enfranchisement (Idea 1)** is policy-relevant but the proposed RDD is not inherently credible without a smarter strategy and strong linkage data.