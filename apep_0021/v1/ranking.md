# Research Idea Ranking

**Generated:** 2026-01-17T17:44:49.560728
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6046
**OpenAI Response ID:** resp_0e49260a8000bfa100696bbc2d81948193b396ea173a857ea8

---

### Rankings

**#1: Kansas’s 3.2% Beer Shock—When Deregulation Kills Small Business**
- **Score:** 71/100  
- **Strengths:** Very high novelty with a crisp, policy-relevant deregulation date and a clear incumbent-protection mechanism (liquor stores losing a quasi-monopoly). The treatment is geographically well-defined (Kansas) and politically salient (deregulation vs. small business).  
- **Concerns:** With **Census/ACS PUMS**, liquor-store sample sizes in Kansas may be too small to detect meaningful changes, and industry codes can be noisy; DiD credibility hinges on convincing pre-trends vs. neighbors and ruling out contemporaneous retail shocks. This is much stronger if you pivot from PUMS to **QCEW/CBP** (establishment counts, employment, payroll) at county/industry level.  
- **Novelty Assessment:** **High**—“3.2 beer” laws are discussed in policy circles, but there’s relatively little tight causal work on Kansas 2019 specifically (especially on small liquor-store labor market impacts).  
- **Recommendation:** **PURSUE** (but redesign data toward QCEW/CBP; use PUMS only for worker reallocation/micro outcomes as a secondary layer)

---

**#2: Does Subsidized Internet Create Gig Workers Instead of Employees? (FCC Lifeline)**
- **Score:** 60/100  
- **Strengths:** The question is genuinely provocative and policy-relevant post-ACP, and the “good policy → precarious work” mechanism is a fresh angle. If you could cleanly identify exposure, the narrative would be memorable and useful.  
- **Concerns:** The proposed “sharp RDD at 135% FPL” is unlikely to be sharp in practice: **Lifeline eligibility is not purely income-based** (categorical eligibility via SNAP/Medicaid, etc.), take-up is incomplete, and income measurement error plus bunching near multiple program thresholds (SNAP ~130%, Medicaid ~138%) will confound interpretation. PUMS does not observe Lifeline participation or gig-platform work specifically; “unincorporated self-employment” is an imperfect proxy.  
- **Novelty Assessment:** **Medium-high**—Lifeline take-up/connectivity has literature; downstream labor-market effects, especially “gig vs employee,” are much less studied, but the RD-at-income-threshold approach is a known (often fragile) template.  
- **Recommendation:** **CONSIDER** (becomes **PURSUE** only if you can link to credible Lifeline enrollment/exposure data—e.g., granular USAC/FCC subscriber counts by area—and treat PUMS outcomes as downstream)

---

**#3: North Dakota’s Oil Boom Reversal—The End of the Bakken**
- **Score:** 54/100  
- **Strengths:** Important and still policy-relevant for commodity-dependent regions; focusing on the **bust** and adjustment margins (self-employment, labor-force exit, out-migration) is a sensible contribution. Within-state exposed vs. less-exposed comparisons are intuitive.  
- **Concerns:** This space is **well-mined** in regional/energy economics; novelty depends on doing something distinctly new (e.g., credible migration/accounting decomposition). With ND’s small population, PUMS at the PUMA level may be underpowered and vulnerable to compositional change (who remains in the region post-bust) that biases DiD.  
- **Novelty Assessment:** **Medium-low**—many papers study oil shocks (boom and bust) using Bartik-style exposure; “Bakken bust” itself is not untouched. The self-employment angle is somewhat less common but not fully novel.  
- **Recommendation:** **CONSIDER** (stronger if paired with administrative data: QCEW, IRS migration, UI wage records, or at least county-level panels)

---

**#4: The Age 40 Threshold—When Discrimination Protection Enables Risk-Taking (ADEA)**
- **Score:** 48/100  
- **Strengths:** Conceptually clever: flipping ADEA from “employment protection” to “risk-taking margin” is a real mechanism contribution if it can be shown. The cutoff is clean in theory.  
- **Concerns:** In **public PUMS**, age is typically measured in **integer years**, not exact birthdate, making an “RDD at 40” extremely coarse (39 vs. 40) and heavily confounded by smooth life-cycle trends. Treatment is also heterogeneous (firm-size coverage, enforcement intensity, state laws), so the first stage (“protection meaningfully changes at 40 for this person”) is weak.  
- **Novelty Assessment:** **Medium**—ADEA threshold designs and age-based discontinuities are well-known; applying it to entrepreneurship is less common, but the data/measurement problem is the binding constraint.  
- **Recommendation:** **SKIP** (unless you can access restricted microdata with finer age timing or a dataset with exact birthdate / month and credible entrepreneurship entry measurement)

---

**#5: The Entrepreneurship Lock at 138% FPL—Does Medicaid Free the Founders?**
- **Score:** 47/100  
- **Strengths:** Policymakers care about entrepreneurship lock; the mechanism is direct and the hypothesis is intuitive. Placebo tests in non-expansion states are a nice design element.  
- **Concerns:** Novelty is limited: Medicaid expansion and labor-market/entrepreneurship effects have a **large literature**. The RD at 138% FPL is also not “clean”: eligibility is based on MAGI and other rules; income measurement error is severe; and coverage doesn’t jump from “none” to “some” at 138% in expansion states (it often shifts from Medicaid to subsidized marketplace coverage), so the discontinuity in *insurance risk* may be small—implying weak first stage and tiny reduced form.  
- **Novelty Assessment:** **Low**—even if the exact RD implementation is less common, the core question has been studied extensively with multiple designs.  
- **Recommendation:** **SKIP** (unless you can add a genuinely new angle/data source—e.g., verified health shocks, administrative enrollment, or a subgroup where the coverage discontinuity is demonstrably large)

---

### Summary

This batch has one standout on **novel policy + credible timing** (Kansas 3.2% deregulation), but several proposals rely on **income-threshold RDs in survey data**, which are often fragile due to fuzziness, measurement error, and overlapping program cliffs. If you fund one, fund **Idea 3**—and insist on **QCEW/CBP** as the backbone. **Idea 1** is the best “maximum originality” bet, but only if you can replace the pseudo-sharp RD with a design that actually measures Lifeline exposure/uptake.