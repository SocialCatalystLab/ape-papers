# Research Idea Ranking

**Generated:** 2026-01-18T23:47:01.123296
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4020
**OpenAI Response ID:** resp_0557321d1f51a51d00696d62c957dc81939cda3443d45ba2a4

---

### Rankings

**#1: State Auto-IRA Mandates and Worker Job Mobility**
- **Score: 76/100**
- **Strengths:** High policy salience and genuinely underexplored worker-side outcomes; multiple sources of variation (state timing + phased employer-size rollout) can support an event-study style design with modern staggered-DiD estimators.
- **Concerns:** Worker-level CPS/ACS data do not cleanly identify “eligible” workers (firm plan status and often firm size are unobserved), risking severe treatment misclassification and attenuation; COVID and other contemporaneous state labor policies could confound staggered timing unless carefully handled (e.g., restricting to early adopters, flexible time controls, border designs).
- **Novelty Assessment:** **High**—most existing work I’m aware of is on employer plan adoption/crowd-out; credible evidence on mobility/tenure/hours effects is scarce.
- **Recommendation:** **PURSUE** (but only if you can credibly define treated/eligible workers using SIPP/QWI by firm-size/industry, or another eligibility proxy, and pre-specify a COVID-robust design).

**#2: Universal License Recognition (ULR) and Occupational Entry**
- **Score: 64/100**
- **Strengths:** Many adopting states create reasonable variation; “occupational entry” and entrepreneurship channels (especially for movers, military spouses, immigrants) are more novel than the already-studied aggregate employment/migration effects.
- **Concerns:** Identification is threatened by simultaneous pro-migration/pro-business reforms in adopting states and by COVID-era shocks clustered in the same window; ACS occupation/self-employment measures are noisy proxies for “licensed occupational entry,” so it’s easy to get ambiguous interpretation without licensing-board microdata.
- **Novelty Assessment:** **Moderate**—ULR has an emerging literature; the specific margins you propose are less saturated but not untouched.
- **Recommendation:** **CONSIDER** (stronger if you can obtain administrative licensing records or build a licensed-vs-unlicensed triple-difference that is transparent and convincing).

**#3: Pay Transparency Laws and the Gender Wage Gap**
- **Score: 58/100**
- **Strengths:** Very high policy relevance and strong interest from states considering adoption; job-posting data (Lightcast/Burning Glass) can measure mechanisms (posted ranges, dispersion) rather than relying only on realized wages.
- **Concerns:** This topic is quickly becoming crowded, and clean identification is hard because adoption is recent (thin pre-trends) and enforcement/scope differ widely; state-level wage-gap outcomes are confounded by compositional shifts (industry, remote work, migration) unless you can credibly isolate affected workers/firms.
- **Novelty Assessment:** **Low-to-Moderate**—there is already a fast-growing set of working papers and early journal articles on pay transparency (often DiD/event studies); you’d need a distinctly better design/data angle to stand out.
- **Recommendation:** **CONSIDER** (worth doing only with a sharper design—e.g., border-county/event-study + postings/HR microdata + clear affected-occupation/firms definitions).

**#4: State Mini-WARN Act Expansions and Worker Outcomes**
- **Score: 44/100**
- **Strengths:** Conceptually clean policy lever with plausible welfare implications (advance notice, adjustment time) and comparatively little modern state-level causal work.
- **Concerns:** The binding, “new” variation is limited (often one-off reforms like NJ 2023), making causal inference fragile (single treated unit, coincident shocks); linking WARN notices to worker outcomes typically requires restricted UI wage records or high-quality matched data that may not be feasible for a policy institute timeline.
- **Novelty Assessment:** **High** relative to other labor policies, but mainly because the data/variation problems deter work.
- **Recommendation:** **SKIP** (unless you already have access to multi-state UI microdata and can credibly evaluate a specific recent reform with an a priori comparison group).

**#5: Non-Compete Ban Effects on Entrepreneurship**
- **Score: 32/100**
- **Strengths:** Policymakers care a lot; clear theoretical link to entrepreneurship and mobility.
- **Concerns:** The credible-treatment variation is extremely limited for modern designs (California too old; Minnesota too recent; Massachusetts is a single-state reform), and the non-compete literature is already large—so you risk both weak identification and low marginal contribution.
- **Novelty Assessment:** **Low**—non-competes have a substantial empirical literature, and the “new” bans don’t yet yield enough post-period for serious evaluation.
- **Recommendation:** **SKIP** (revisit once multiple post-2023 bans accumulate sufficient post data or if you can access proprietary contract-level/HR data).

---

### Summary

This is a solid batch with one standout: the **Auto-IRA mobility** idea is both policy-relevant and plausibly novel, but it lives or dies on whether you can **measure eligibility/treatment exposure** rather than relying on blunt state-by-time assignment. The next best fallback is **ULR and occupational entry** if you can bring in licensing administrative data or a convincing triple-diff; pay transparency is important but increasingly crowded and design-constrained by short panels.