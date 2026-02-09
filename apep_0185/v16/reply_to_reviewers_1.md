# Reply to Reviewers — v16 Code Integrity Restoration

**Paper:** Friends in High Places: Social Network Connections and Local Labor Market Outcomes
**Parent:** apep_0211 (v15)
**Revision scope:** Code decontamination + minor paper fixes

---

## Overview

This revision addresses a critical code integrity issue discovered in v15 (apep_0211): 9 of the code files were contaminated with code from an unrelated paper (Paper 188: "Moral Foundations Under Digital Pressure"). The v16 revision restores the clean v12 pipeline, ports 3 legitimate v15-only additions, and makes minor paper improvements.

**Substantive content is unchanged from v15.** The referee feedback below is acknowledged and will inform future revisions.

---

## Response to Referee 1 (GPT-5-mini) — Major Revision

**1. SCI timing and pre-determination**
> Noted. The paper discusses SCI stability in Section 6.3 and provides distance-restriction analysis as supporting evidence. Multiple SCI vintages are not publicly available for direct comparison. We note that Bailey et al. (2018) document high temporal stability of the index.

**2. Exclusion restriction breadth**
> Noted. The placebo shock analysis (Table 10, Section 8.5) tests GDP-weighted and employment-weighted placebo instruments — both null (p > 0.73). Horse race regressions confirm MW exposure dominates. Additional state-level controls are a natural extension for future work.

**3. Pre-treatment imbalances and parallel trends**
> The paper includes: (a) event study with pre-trend test (Figure 6, p = 0.82); (b) Rambachan-Roth sensitivity analysis (Section 8.4); (c) county-specific linear trends robustness (Table B4, 98.6% attenuation consistent with slow-moving variation). Balance test imbalances (Table 3, p = 0.004) are in levels, absorbed by county FE.

---

## Response to Referee 2 (Grok-4.1-Fast) — Minor Revision

**1. Pre-trend level imbalances**
> Addressed via county FE absorption and pre-trend tests. See response to Referee 1, point 3.

**2. SCI 2018 vintage**
> See response to Referee 1, point 1.

**3. Richer complier characterization**
> Current Table A4 provides complier characterization by IV sensitivity quartile. Additional visualizations noted for future revision.

---

## Response to Referee 3 (Gemini-3-Flash) — Minor Revision

**1. 9% employment effect magnitude**
> The paper discusses this in Section 7.3, framing the coefficient as a market-level multiplier (cf. Moretti 2011) incorporating information diffusion, employer responses, and general equilibrium effects. The 2SLS estimate reflects LATE for complier counties.

**2. Reservation wage mechanism**
> Acknowledged. The theoretical framework (Appendix A) provides a stylized model. Empirical proxies for local reservation wages are limited in county-level administrative data. This is noted as a limitation.

**3. Heterogeneity by skill**
> QWI data are available by age group but not education. Industry-level analysis (Table 9) shows stronger effects in high-bite industries (Retail + Accommodation) vs low-bite (Finance + Professional), consistent with the prediction that low-wage workers respond most.

---

## Changes Made in This Revision

1. **Code integrity restored:** 9 contaminated files replaced with clean v12 versions; 3 clean v15-only scripts preserved
2. **Census API fix:** Updated 01_fetch_data.R for per-industry QWI requests (Census API no longer supports multi-industry queries)
3. **dplyr fix:** Updated 02_clean_data.R industry panel aggregation for dplyr 1.1+ compatibility
4. **Revision footnote:** Updated to reference apep_0211 (correct parent)
5. **Cross-reference fix:** Corrected balance table reference
6. **Figure 4 note:** Clarified first-stage discrepancy between figure (parsimonious spec) and table (full spec)
7. **New citations:** Andrews et al. (2019), de Chaisemartin & D'Haultfoeuille (2024)
