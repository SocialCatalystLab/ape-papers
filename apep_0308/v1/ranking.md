# Research Idea Ranking

**Generated:** 2026-02-15T14:46:13.408636
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 3844

---

### Rankings

**#1: The Geography of Medicaid's Invisible Workforce — A ZIP-Level Portrait of New York State**
- **Score: 76/100**
- **Strengths:** Extremely high novelty given the very recent T‑MSIS releases and the lack of prior ZIP/ZCTA-scale mapping of Medicaid provider spending; high immediate policy salience in NY because HCBS/CDPAP is a dominant and controversial spending category. Strong feasibility: you already have the core files, large N, and clear descriptive deliverables (maps, concentration curves, decompositions).
- **Concerns:** Interpretability risk is nontrivial: NPPES “practice address” may not reflect where services are delivered (especially for multi-site agencies, fiscal intermediaries, or billing entities), and ZIP-level concentration could reflect billing/reporting structure rather than real service supply or fraud. Also, T‑MSIS completeness/encounter quality varies—if NY’s managed care encounters are uneven by plan/region/time, geographic comparisons can be distorted without careful validation checks.
- **Novelty Assessment:** **Very high.** Medicaid geography papers exist, and some HCBS/state Medicaid analyses exist, but ZIP-level provider-spending cartography using newly released T‑MSIS + NPPES at this scale is largely uncharted.
- **Recommendation:** **PURSUE (conditional on: validating “location” with alternative geography where possible—e.g., county, service location fields if available, plan/encounter sensitivity checks; documenting managed-care vs FFS capture and any known NY reporting artifacts; clear caveats that patterns may reflect billing intermediaries rather than bedside labor location).**

---

**#2: Market Concentration in Medicaid Home Care — Evidence from New York's T-MSIS Data**
- **Score: 64/100**
- **Strengths:** Policy-relevant framing (market power, entry/exit, concentration) and still fairly novel in this specific setting (Medicaid home care/CDPAP) at fine geography. Technically feasible with the same data pipeline, and HHI/share metrics are interpretable to policymakers.
- **Concerns:** This risks being a “subset” of Idea 1 rather than a standalone contribution unless you add a sharper angle (e.g., concentration trends over time, concentration by MLTC plan penetration areas, or linking concentration to price proxies/utilization mix). Biggest technical threat is **firm definition**: NPIs may represent billing shells/fiscal intermediaries, and “market” boundaries (ZIP vs county vs commuting zone) can swing HHI mechanically; without strong justification, results look arbitrary.
- **Novelty Assessment:** **Moderate.** Concentration/HHI is heavily studied across healthcare, including Medicaid managed care and provider markets; what’s new here is the *home care + CDPAP + T‑MSIS micro-geography* combination, but the core method is standard.
- **Recommendation:** **CONSIDER (best as a major section within Idea 1, unless you can add a distinct contribution—e.g., credible entry/exit measurement, ownership consolidation, or linking concentration to plan contracting/beneficiary access measures).**

---

**#3: The Behavioral Health Gap — Why New York Routes Mental Health Outside T-MSIS**
- **Score: 52/100**
- **Strengths:** Substantively important and potentially high-impact if it cleanly distinguishes “true spending differences” from “measurement/routing differences” (carve-outs, managed care encounter capture, alternative coding systems). Policymakers care about behavioral health financing, integration, and parity—and NY’s institutional complexity makes the question real.
- **Concerns:** High risk of a **data artifact paper** without the missing pieces: NY behavioral health carve-out/transition means T‑MSIS may understate spending if services are paid via capitation with incomplete encounters, carved-out state systems, or non-HCPCS coding. Cross-state comparisons of “H-code shares” are especially fragile because states differ in billing conventions and encounter completeness; without OMH/OASAS (or plan encounter quality audits, or other administrative corroboration), you may not be able to adjudicate the mechanism behind the gap.
- **Novelty Assessment:** **Moderate.** Behavioral health carve-outs and managed care transitions have been studied, including NY’s phased integration, but the specific T‑MSIS “why is NY missing H-codes” angle is somewhat new—still, it hinges on proving it’s not just reporting.
- **Recommendation:** **SKIP (unless you can secure corroborating NY behavioral health administrative/payment data or a strong validation strategy—e.g., triangulation with state budget/expenditure reports, encounter completeness documentation, or external utilization datasets—to separate real spending differences from reporting/coding/routing).**

---

### Summary

This is a strong batch for **high-novelty descriptive policy measurement** using newly available T‑MSIS data; the best path is to lead with the ZIP-level NY portrait (Idea 1) and embed the concentration work (Idea 2) as a structured component. The behavioral health carve-out idea (Idea 3) is substantively important but is currently at high risk of being driven by **encounter/reporting and coding heterogeneity**, so I would not prioritize it without additional administrative data or a rigorous triangulation plan.