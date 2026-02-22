# Internal Review -- Round 2

**Paper:** "Smaller States, Bigger Growth? Two Decades of Evidence from India's State Bifurcations"
**Reviewer:** Reviewer 2 (harsh) + Editor (constructive)
**Date:** 2026-02-22
**Round 1 Verdict:** Minor Revision

## Verdict: Conditionally Accept

This paper has clearly been through multiple rounds of careful revision. The author's transparent handling of the pre-trends violation is exemplary -- it is rare in the applied literature to see a paper foreground its own identification failure this honestly, and the paper is stronger for it. The institutional background is among the best I have seen for a paper on Indian subnational policy. The heterogeneity analysis (Uttarakhand vs. Jharkhand) is the paper's genuine contribution and is well executed. I am prepared to recommend conditional acceptance, subject to the specific revisions detailed below.

---

## Major Concerns

1. **HonestDiD bounds remain the most important missing element.** Round 1 flagged this, and it remains the single revision most likely to elevate this paper. The pre-trend is well documented; what is needed now is a formal framework for asking "how large could the treatment effect be, given what we know about the pre-trend?" Rambachan and Roth (2023) provide exactly this. Implementing HonestDiD with a range of smoothness parameters (M) would allow the reader to see at what degree of trend extrapolation the confidence set includes zero. If the bounds are informative -- i.e., they exclude zero for reasonable M -- the paper's conclusions gain substantial credibility. If they include zero, the paper should say so clearly; the honesty of the paper's framing is already its strength, and this would reinforce it. **This is the binding condition for acceptance.**

2. **The TWFE vs. CS-DiD gap (0.80 vs. 0.29) still needs a clearer explanation.** The paper attributes the gap to heterogeneity-robust estimation, but with a single treatment cohort this is not the standard explanation. The most likely driver is that the CS estimator weights group-time ATTs differently from TWFE, and in particular may downweight or exclude the early post-treatment periods where the pre-trend continuation inflates the TWFE estimate. A decomposition -- showing the CS group-time ATTs by post-treatment year -- would clarify this. Alternatively, a simple comparison of the TWFE estimate restricted to, say, k >= 5 (where the CS simultaneous bands exclude zero) versus the full-sample TWFE would be informative.

---

## Minor Concerns

1. **The placebo coefficient (0.25) vs. the CS-DiD ATT (0.29) comparison should be flagged more prominently.** The paper discusses the placebo in Section 6.1 but does not draw the direct comparison with the headline CS-DiD estimate. Adding one sentence -- "The placebo estimate of 0.25 is comparable in magnitude to the CS-DiD ATT of 0.29, suggesting that pre-existing convergence alone could account for much of the estimated treatment effect" -- would sharpen the paper's honest framing.

2. **Table 4 (pair-specific heterogeneity) should drop significance stars or add a footnote.** With 2 clusters per pair regression, the standard errors and stars are unreliable. The numbers themselves are informative as descriptive decompositions, but the inference is not credible. A footnote stating "Standard errors with 2 clusters should be interpreted with extreme caution; significance stars are included for completeness but are not reliable" would suffice.

3. **The bibliography should be expanded.** The paper cites only 13 references, which is thin for a paper engaging with fiscal federalism, Indian political economy, nightlights methodology, and modern DiD econometrics. Key additions should include: Rambachan and Roth (2023) on HonestDiD; de Chaisemartin and D'Haultfoeuille (2020) on TWFE decomposition; Asher and Novosad (2020) on Indian development data; and at least 2-3 more references from the Indian state creation literature (e.g., Verma 2023 on Uttarakhand governance, or studies on Telangana's post-bifurcation trajectory).

4. **The Sun-Abraham section (6.6) could be shortened to a footnote.** The paper already explains why SA is unnecessary with a single cohort. Two sentences confirming the result is unchanged would suffice; the current half-page treatment overstates its importance.

5. **Consider adding an IHS transformation robustness check.** The log(NL+1) specification is standard but creates nonlinearity at low values that disproportionately affects the treatment group. A brief appendix table showing the main estimate under inverse hyperbolic sine would address this concern at minimal cost.

---

## Suggestions

1. **Reframe the paper's core contribution explicitly.** The paper's greatest strength is not the point estimate -- which is undermined by the pre-trend violation -- but rather the heterogeneity analysis and the institutional narrative connecting governance quality to development outcomes. The Uttarakhand-Jharkhand contrast, combined with the capital city effect, tells a richer story than any single ATT could. Consider restructuring the abstract and conclusion to emphasize this comparative institutional analysis as the primary contribution, with the aggregate DiD as supporting evidence.

2. **A border-district analysis would strengthen identification.** Comparing districts immediately adjacent to the new state boundary -- which share geography, climate, and pre-existing infrastructure but differ in post-2000 governance -- would provide a sharper test that is less vulnerable to the parallel trends concern. Even if the sample is small, the qualitative pattern would be informative.

3. **Engage with the "special category state" fiscal channel more directly.** Uttarakhand received "special category" status from the central government, entitling it to higher per capita central transfers and favorable tax treatment for industrial investment. Chhattisgarh did not receive special category status. This institutional difference could help explain the Uttarakhand-Chhattisgarh differential within the treated states and is worth a paragraph in the mechanisms section.

4. **The Naxalite insurgency is mentioned for both Jharkhand and Chhattisgarh but treated asymmetrically.** The paper notes Chhattisgarh's Maoist insurgency in passing but emphasizes Jharkhand's. Since both states faced similar security challenges, the difference in outcomes is more clearly attributable to governance quality than to insurgency per se. Making this comparison explicit would strengthen the institutional argument.

5. **The extended panel figure (Figure 6) could distinguish the three state pairs in the VIIRS era.** Currently the extended panel shows aggregate new-state vs. parent-state trends. Showing the three pairs separately through 2023 would reveal whether Jharkhand's stagnation persists, whether Uttarakhand's advantage holds, and whether any pair shows convergence -- all of which would enrich the long-run narrative.

---

## Summary Assessment

This is a well-written paper on an important question that takes an admirably honest approach to its own identification challenges. The pre-trend violation is real and acknowledged. The heterogeneity results are the paper's strongest contribution and are well presented. The institutional narrative is detailed and informative.

The binding condition for acceptance is implementing HonestDiD bounds to provide formal treatment effect bounds under varying assumptions about trend extrapolation. With this addition, plus the minor revisions above, the paper makes a credible contribution to the literature on fiscal decentralization and Indian political economy.

The paper's intellectual honesty about parallel trends failure is itself a contribution to methodological practice. Too many papers in the applied microeconomics literature present event studies with problematic pre-trends and wave them away. This paper demonstrates how to engage with the problem transparently, and it should be recognized for doing so.
