# Research Idea Ranking

**Generated:** 2026-01-22T16:23:57.511628
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6928
**OpenAI Response ID:** resp_085a6683bd50701f00697240b8bd1c8195a3949b677f33addf

---

### Rankings

**#1: Effect of Salary Transparency Laws on Wage Levels and Gender Wage Gaps (Idea 1)**  
- **Score: 66/100**  
- **Strengths:** Timely policy wave with meaningful cross-state variation and clear policy relevance (pay equity, wage setting). CPS gives large samples and rich covariates; modern staggered-adoption DiD estimators are appropriate in principle.  
- **Concerns:** The proposed **pre-period is too short** for early adopters (and COVID-era shocks make pre-trends especially fragile). Treatment is politically selected (blue states) and several **coincident labor-market policies** (min wage, paid leave, pay-equity enforcement) plausibly move wages/gaps at the same time. Also, **spillovers/SUTVA violations** are plausible (firms posting ranges nationally or changing multi-state pay policies because of one-state laws), which can contaminate “never-treated” controls.  
- **Novelty Assessment:** **Moderately novel.** There is growing work on pay transparency (especially Colorado and online postings), but a comprehensive multi-state wage/gender-gap evaluation is still not saturated—yet it’s no longer a blank slate.  
- **DiD Assessment (mandatory):**
  - **Pre-treatment periods:** **Marginal** — 2018–2020 gives only 3 pre years for Colorado (and in ASEC, “income year” timing can further shorten usable pre/post windows unless handled carefully).  
  - **Selection into treatment:** **Marginal** — adoption is highly correlated with political ideology and broader equity agendas; timing may respond to underlying wage-gap concerns.  
  - **Comparison group:** **Marginal** — large pool of never-treated states, but many are structurally different (South vs coastal labor markets). You’ll need careful weighting/matching and explicit diagnostics.  
  - **Treatment clusters:** **Marginal** — ~14 treated states is below the “strong” threshold; effective treated clusters with usable post-period in CPS ASEC through 2024 may be fewer.  
  - **Concurrent policies:** **Marginal** — minimum wage hikes, post-COVID sectoral shifts, remote-work changes, and other pay-equity policies coincide and are not obviously separable.  
  - **Outcome-Policy Alignment:** **Strong (with caveats)** — wages and wage gaps are the right outcomes, but **CPS ASEC annual earnings** may dilute effects (laws primarily hit *offers/new hires* and posted ranges, not incumbent wages immediately). Consider CPS-ORG hourly wages or administrative UI wage records if possible.  
- **Recommendation:** **PURSUE (conditional on: extend pre-period to ≥10 years if using CPS/ACS; align timing to “income year” vs law effective dates; explicitly address spillovers/SUTVA with sensitivity checks; pre-register a credible set of concurrent-policy controls and/or triple-diff designs)**

---

**#2: Salary Transparency and Occupational Wage Compression (Idea 2)**  
- **Score: 57/100**  
- **Strengths:** Mechanism-focused and potentially more diagnostic than mean wages (compression is a concrete implication of posted ranges and standardized offers). If identified, it can distinguish bargaining-power vs information channels.  
- **Concerns:** **Data feasibility is the binding constraint**: estimating within-occupation wage dispersion in **state×occupation×year** cells using CPS is often noisy (small cell counts, top-coding, composition changes). Compression results can be driven by changing worker mix rather than firm wage-setting; you’d need strong composition controls or a design focused on new hires.  
- **Novelty Assessment:** **Fairly novel as a U.S. policy evaluation angle**, though wage-compression effects of transparency have been studied in other settings and via firm/internal pay transparency.  
- **DiD Assessment (mandatory):**
  - **Pre-treatment periods:** **Marginal** — same limitation as Idea 1, and dispersion outcomes typically need longer stable pre-trends.  
  - **Selection into treatment:** **Marginal** — same political selection concerns.  
  - **Comparison group:** **Marginal** — same comparability issues, plus dispersion differs structurally across states/industries.  
  - **Treatment clusters:** **Marginal** — same treated-cluster limitation; power is worse because outcome is cell-level.  
  - **Concurrent policies:** **Marginal** — many contemporaneous policies (and COVID) also affect inequality/dispersion.  
  - **Outcome-Policy Alignment:** **Strong (conceptually), Marginal (empirically)** — compression is directly connected to wage posting, but CPS-measured dispersion may not reflect firm offer compression (measurement error/top-coding).  
- **Recommendation:** **CONSIDER (best as an add-on after Idea 1, and preferably with stronger data—ACS with careful handling, CPS-ORG, or administrative wage records; require minimum cell-size rules and composition-robust methods)**

---

**#3: Effect on Job Posting Behavior (Alternative Data) (Idea 3)**  
- **Score: 46/100**  
- **Strengths:** Best outcome-policy match: the laws directly target **job ads** (posting of ranges, width of ranges, stated pay). High-frequency postings data can support sharp event studies around effective dates and immediate compliance dynamics.  
- **Concerns:** **Data access is the likely dealbreaker** (Indeed/LinkedIn/Lightcast/Glassdoor are expensive, often restricted, and reproducibility can be weak). This topic is also **already the most-studied margin** (Colorado postings responses and remote-job adjustments are well-known), so novelty is lower than it first appears. Platform policy changes and multi-state posting practices create serious confounding and spillovers.  
- **Novelty Assessment:** **Lower novelty.** The Colorado-era literature on postings behavior/compliance is emerging but real; multi-state extensions help, but you’d be pushing on a margin others are actively mining.  
- **DiD Assessment (if implemented as DiD/event study):**
  - **Pre-treatment periods:** **Strong** (postings data usually provide many months/years pre).  
  - **Selection into treatment:** **Marginal** (same political selection).  
  - **Comparison group:** **Marginal** (posting composition differs sharply by state/industry; remote postings blur geography).  
  - **Treatment clusters:** **Marginal** (still limited number of adopting states, though many posting-level observations).  
  - **Concurrent policies:** **Marginal** (platform rule changes; remote work normalization; sector shocks).  
  - **Outcome-Policy Alignment:** **Strong** (direct measure of what the law requires).  
- **Recommendation:** **SKIP (unless the institute already has contracted access to a stable postings database with clear documentation and you can pre-specify a design addressing remote/multi-state spillovers and platform changes)**

---

### Summary

This is a coherent batch centered on an important, recent policy area. The top priority is **Idea 1**, but it is not “clean” DiD as written: the **short pre-period (especially through COVID), political selection, spillovers, and concurrent policy bundles** are real threats that must be front-and-center. **Idea 2** is a reasonable mechanism extension but likely underpowered/noisy in CPS without better wage data. **Idea 3** has excellent conceptual alignment but is least promising given **data access risk** and lower novelty due to existing Colorado/postings work.