# Research Idea Ranking

**Generated:** 2026-02-12T10:34:22.008230
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 3660

---

### Rankings

**#1: Who Bears the Burden of Monetary Tightening? Heterogeneous Labor Market Responses and Aggregate Implications**
- **Score: 74/100**
- **Strengths:** Clean identification using high-frequency monetary shocks plus long, high-powered monthly labor-market series (CES; JOLTS post-2001) makes this empirically credible. Linking reduced-form heterogeneity to a search-frictions (DMP) mechanism is a coherent way to translate “who loses jobs” into welfare-relevant objects.
- **Concerns:** Sectoral heterogeneity in monetary transmission is not a blank slate—there is an existing literature on sectoral/industry employment responses, so the incremental novelty must come from (i) the JK identification, (ii) careful heterogeneity measurement (job flows, not just levels), and (iii) disciplined mechanism tests. Also, JK “information effects” and sample instability across regimes (e.g., ZLB/QE era) can complicate interpretation unless explicitly addressed (e.g., using the Jarocinski (2022)-style decomposition / sign restrictions).
- **Novelty Assessment:** **Moderate.** Monetary-policy-to-labor-market is heavily studied; “cross-industry effects” exists, but using JK shocks + rich job flows + a clear DMP-based welfare framing could still be a meaningful contribution if executed tightly.
- **Recommendation:** **PURSUE (conditional on: explicitly handling information effects and regime changes; pre-specifying heterogeneity dimensions to avoid data-mining; using JOLTS/job flows as primary evidence for mechanisms rather than only CES employment levels).**

---

**#2: Monetary Policy and the Skills Premium**
- **Score: 60/100**
- **Strengths:** Important and policy-relevant distributional question (inequality channel of monetary policy) with plausibly strong identification via high-frequency shocks. If done with the right wage data and careful composition adjustments, it could produce interpretable impulse responses of wage inequality.
- **Concerns:** As written, the **data description is shaky**: CPS **ASEC is annual (March supplement)**, not monthly; monthly CPS wage measures are typically from the **MORG/Outgoing Rotation Groups**, and even then wages have measurement error and strong composition/selection issues (employment effects of tightening mechanically change who is observed with wages). The topic—monetary policy and inequality/skill premium—has a substantial prior literature, so novelty depends on very clean measurement + a clear contribution beyond “update with JK shocks.”
- **Novelty Assessment:** **Low-to-moderate.** “Monetary policy and inequality / wage distribution / skill premium” has many papers; the marginal value hinges on improved identification + improved wage construction (and transparent handling of selection).
- **Recommendation:** **CONSIDER (conditional on: switching to CPS MORG for wages or another consistent high-frequency wage source; implementing composition/selection corrections—e.g., reweighting, bounds, or modeling employment selection; clearly distinguishing wage-rate effects from workforce-composition effects).**

---

**#3: The Gig Economy Channel of Monetary Policy**
- **Score: 45/100**
- **Strengths:** The question is genuinely interesting and comparatively novel: monetary policy could affect firms’ reliance on contingent labor and workers’ fallback options, a margin not well captured in standard macro-labor work.
- **Concerns:** The key outcome is **not measured at the needed frequency**: the CPS Contingent Worker Supplement occurs only in **2005, 2017, 2023**, which is essentially unusable for local projections/impulse responses. Proxying with self-employment or multiple jobholding creates major **outcome-policy mismatch** (those are not “gig work” cleanly) and introduces severe confounding from long-run secular trends (platform growth, labor regulation, tax changes).
- **Novelty Assessment:** **High (question), but low feasibility.** Novel channel, but the measurement problem is fundamental with the proposed data.
- **Recommendation:** **SKIP (unless you can secure better, high-frequency administrative/platform data—e.g., IRS 1099 aggregates, payroll processor data, platform-provided series, or large private panels—so the outcome actually tracks gig work over time).**

---

### Summary

This batch has one clearly fundable idea: **Idea 1** combines credible identification and strong data power, with a plausible path to a real contribution if it carefully addresses information effects/regime shifts and uses job-flow evidence to pin down mechanisms. **Idea 2** is policy-relevant but currently underspecified on data (ASEC vs MORG) and faces heavier prior literature. **Idea 3** asks a novel question but is not empirically viable with the proposed outcome measures and should be deprioritized absent substantially better gig-work data.