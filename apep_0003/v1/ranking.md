# Research Idea Ranking

**Generated:** 2026-01-17T02:09:14.663383
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5543

---

### Rankings

**#1: Indiana Ban-the-Box Preemption and Employment Outcomes**
- **Score:** 69/100
- **Strengths:** Very high novelty: “reverse” ban-the-box (state preempting local BTB) is rarely studied and Indiana is close to a single-policy case. Clear policy relevance given ongoing state fights over local labor standards and criminal-record screening.
- **Concerns:** The *effective treated population* may be much narrower than “Indiana workers” (Indianapolis city contractors/public hiring vs broad private-sector screening), so a state-level DiD using PUMS risks severe treatment dilution and weak signal-to-noise. Identification hinges on parallel trends for small subgroups (e.g., young Black men) and on cleanly isolating Indianapolis/affected employers using coarse PUMA geography.
- **Novelty Assessment:** Genuinely novel relative to the large BTB adoption literature; I’m not aware of multiple causal papers on *preemption/removal* of BTB protections.
- **Recommendation:** **PURSUE** (but only if you can credibly define exposure—e.g., Indianapolis metro vs other metros, or public/contractor-heavy employment—otherwise the estimand becomes too fuzzy)

---

**#2: Nebraska Occupational Board Reform Act and Licensed Employment**
- **Score:** 63/100
- **Strengths:** Policy is unusual (sunset review + “least restrictive” mandate + criminal-record barrier relief), and there are relatively few causal evaluations of comprehensive licensing *deregulation* packages. Strong policy relevance given bipartisan interest in licensing reform and labor supply constraints.
- **Concerns:** Identification is the main weakness: the reform is multi-part, potentially gradual, and occupational impacts depend on which boards actually changed requirements—hard to map in PUMS where “licensed” status is not observed. Without a well-documented list of occupations with meaningful requirement changes and timing, the DiD risks being close to a before/after with ambiguous treatment intensity.
- **Novelty Assessment:** Moderately high. Licensing effects are heavily studied, but state-specific deregulatory “least restrictive regulation” mandates are less common in causal micro work.
- **Recommendation:** **CONSIDER** (promising if you can build a credible “affected occupations” panel with reform timing and magnitude; otherwise likely too noisy)

---

**#3: South Carolina Teacher Minimum Salary Increase and Teacher Supply**
- **Score:** 57/100
- **Strengths:** High policy salience (teacher shortages, pay competitiveness) and the treated group is observable in PUMS via occupation codes; wage effects are directly measurable. A statewide schedule change is cleaner than many district-by-district reforms.
- **Concerns:** Novelty is limited (teacher pay is one of the most studied education labor topics), and FY2019–2020 timing collides with COVID-era shocks that differentially affected schooling labor markets across states—this threatens DiD credibility. PUMS is cross-sectional, so “retention” and workforce quality composition are hard to measure cleanly (you mostly get employment levels and wages, not exits/entries for the same individuals).
- **Novelty Assessment:** Medium-low: there’s extensive prior work on teacher compensation; statewide minimum schedule hikes are somewhat less studied, but not “new territory.”
- **Recommendation:** **CONSIDER** (worth doing only if you can convincingly address pandemic confounding—e.g., event-study showing pre-trends + robustness restricting to pre-2020 vs later periods, or supplement with administrative teacher workforce data)

---

**#4: Indiana Second Chance Law Employment Protections**
- **Score:** 54/100
- **Strengths:** The employer safe-harbor / liability-protection angle is a real conceptual contribution and could matter for why expungement reforms sometimes show small labor-market effects. Timing (2013) allows several pre/post years before COVID.
- **Concerns:** The key treated status—having an expunged/sealed record—is unobserved in PUMS, so you’re relying on demographic proxies with substantial misclassification; this typically biases effects toward zero and makes inference fragile. Also, “Second Chance” legal changes can coincide with other justice/labor market shifts, making clean attribution difficult without administrative expungement and employer behavior data.
- **Novelty Assessment:** Medium: expungement and record-clearing effects have an active recent literature (including multiple state evaluations); the Indiana-specific liability channel is less studied but the broader question is not new.
- **Recommendation:** **CONSIDER / borderline SKIP** unless you can link to administrative expungement records or a dataset closer to actual exposure (e.g., court records + earnings, or background-check data)

---

**#5: South Carolina Job Tax Credit County Tier System**
- **Score:** 46/100
- **Strengths:** In principle, a tier-based discontinuity could offer stronger quasi-experimental leverage than typical enterprise zone designs, and the policy is clearly relevant for economic development strategy.
- **Concerns:** The proposed RDD is not well matched to PUMS geography: PUMAs often don’t align to counties, and “near tier threshold boundaries” is not the right running variable unless tier assignment is a deterministic function with a known cutoff (and even then you need county-level outcomes). Tier classifications may be redefined periodically and could be manipulable/political, weakening “as-good-as-random” assignment near the cutoff.
- **Novelty Assessment:** Medium: place-based tax incentives are heavily studied; SC’s specific tier system is less studied, but it sits in a crowded literature.
- **Recommendation:** **SKIP (as currently designed with PUMS)**; reconsider using county-level administrative data (QCEW/CBP/NETS if available) with a clearly defined running variable and assignment rule

---

### Summary

This is a reasonably strong batch on novelty, but several ideas rely on PUMS for policies where *exposure is not directly observed* (expungement, licensing intensity, county-tier incentives), which weakens identification and statistical power. The best near-term bet is **Idea 1** if you can sharply define who was actually affected (likely Indianapolis-focused), with **Idea 4** as the next most novel but requiring substantial policy-to-occupation mapping work to be credible.