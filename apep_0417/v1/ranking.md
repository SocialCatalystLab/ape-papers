# Research Idea Ranking

**Generated:** 2026-02-19T13:55:45.866178
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6265

---

### Rankings

**#1: Where Medicaid Goes Dark — A Claims-Based Atlas of Provider Deserts and the Demand Shock of Enrollment Unwinding**
- **Score: 74/100**
- **Strengths:** Extremely novel measurement (county × specialty Medicaid “active provider” network from T‑MSIS) with very high policy salience and enough pre-period to credibly test pre-trends. The staggered timing/intensity of unwinding plus 50-state coverage gives real scope for heterogeneity and mechanism work (procedural terminations, specialty differences).
- **Concerns:** The key identification threat is **outcome interpretation**: “active provider = billed at least once” can fall mechanically when enrollment falls (fewer Medicaid patients/claims) even if providers haven’t truly exited Medicaid; additionally, unwinding intensity is plausibly correlated with state admin capacity/politics and other contemporaneous Medicaid changes. Staggering is somewhat clustered (many states start Apr–Jul 2023), making event-time separation and inference harder.
- **Novelty Assessment:** High. There is a growing unwinding literature, but **claims-based, county-specialty Medicaid network measurement** at this scale is largely unstudied; if T‑MSIS at this granularity is newly usable, this is plausibly first-mover.
- **DiD Assessment (staggered DiD / intensity):**
  - **Pre-treatment periods:** **Strong** (2018Q1–2023Q1 ≈ 20 quarters pre)
  - **Selection into treatment:** **Marginal** (all must unwind, but *timing/intensity* may respond to state admin capacity, political choices, prior backlogs, or enrollment composition correlated with provider trends)
  - **Comparison group:** **Marginal** (not-yet-unwound states are reasonable controls early on, but eventually-treated design + clustered start dates reduces clean counterfactual support)
  - **Treatment clusters:** **Strong** (≈50 states; good for inference)
  - **Concurrent policies:** **Marginal** (PHE-related changes, Medicaid redetermination operations, MCO contracting/billing shifts, and other state Medicaid initiatives could co-move with unwinding intensity)
  - **Outcome-Policy Alignment:** **Marginal** — The policy reduces Medicaid enrollment (demand). “Active Medicaid providers from claims” captures **realized network capacity** but conflates (i) true Medicaid participation/exit with (ii) fewer Medicaid patients per provider and (iii) billing/encounter submission changes (especially in MCOs).
  - **Data-Outcome Timing:** **Marginal** — Unwinding starts April 2023; using **quarters** means 2023Q2 is partially treated (and actual disenrollments may ramp within-quarter). Using **service month** (claims dates) or redefining exposure windows would strengthen this.
  - **Outcome Dilution:** **Strong** — Outcome is defined *within Medicaid claims*, so the affected population is essentially the whole measurement universe (though “exit” vs “no Medicaid patients” is an interpretation issue, not dilution).
- **Recommendation:** **PURSUE (conditional on: (1) tightening the outcome to distinguish “stopped billing” from “no patients/billing artifacts” (e.g., persistence, minimum-claims thresholds, or enrollment/roster validation if available); (2) explicit timing alignment using month-of-service and state-specific first-dis-enrollment dates; (3) robustness to MCO/encounter-data shifts and other contemporaneous Medicaid operational changes).**

---

**#2: Rate Shock Therapy — Do HCBS Rate Increases Attract Providers to Medicaid Deserts?**
- **Score: 46/100**
- **Strengths:** Very policy-relevant question (HCBS workforce shortages are central to Medicaid operations), and ARPA 9817 created large, policy-driven rate variation that could matter economically. T‑MSIS could, in principle, measure HCBS provider participation at scale.
- **Concerns:** Identification is the core problem: near-universal “treatment” eliminates clean controls, and **rate increase magnitude is likely endogenous** (states/services with worse shortages raise rates more). Implementation timing is messy (multi-service, phased, sometimes retroactive), and ARPA dollars often came bundled with other workforce interventions—high risk of confounding.
- **Novelty Assessment:** Moderate. HCBS provider supply and reimbursement has been studied, but ARPA 9817 is newer; novelty hinges on whether you can credibly isolate *rate* effects rather than “ARPA HCBS package” effects.
- **DiD Assessment (continuous dose-response DiD):**
  - **Pre-treatment periods:** **Strong** (can likely assemble ≥5 years pre with 2018–2020+)
  - **Selection into treatment:** **Weak** (magnitude/service targeting plausibly responds to shortages and pre-trends—classic policy endogeneity)
  - **Comparison group:** **Weak** (no untreated states; “low-dose” as control is not a credible counterfactual without strong assumptions)
  - **Treatment clusters:** **Strong** (≈48 states)
  - **Concurrent policies:** **Weak** (ARPA HCBS plans often include recruitment/retention bonuses, training, admin reforms, payments tied to quality, etc., moving alongside rates)
  - **Outcome-Policy Alignment:** **Strong/Marginal** — If you truly observe **HCBS provider participation** and the rate increase applies to the same services, alignment is good; but service-specific mapping is nontrivial and can slip to marginal if the rate variable is noisy/aggregated.
  - **Data-Outcome Timing:** **Marginal** (implementation/approval dates vary; retroactive rate changes can break clean pre/post timing unless reconstructed precisely)
  - **Outcome Dilution:** **Strong** (outcome restricted to HCBS providers; not diluted by unaffected populations)
- **Recommendation:** **SKIP (unless redesigned)**. A viable path would be a **within-state, across-service** design (services with large vs small rate changes inside the same state, with service-specific timing) and very careful construction of the rate series; as currently framed, it violates multiple “Weak” checklist items.

---

**#3: The Substitution Gap — Do Nurse Practitioners Fill Physician Deserts in Medicaid?**
- **Score: 34/100**
- **Strengths:** Clear policy question and intuitive mechanism; the claims-based provider network measure is attractive and could yield useful descriptive evidence (especially stratified by desert status).
- **Concerns:** As a DiD, it is not viable in the proposed window: **~5 treated states** is a dealbreaker for credible DiD inference (fragile standard errors; results hinge on idiosyncratic states). There is also substantial prior literature on NP scope-of-practice using other data, so the marginal novelty is mainly the Medicaid-claims angle.
- **Novelty Assessment:** Low-to-moderate. NP SOP/FPA reforms are heavily studied; this would be incremental unless the Medicaid-specific provider-network angle produces substantially new evidence.
- **DiD Assessment (state SOP reforms):**
  - **Pre-treatment periods:** **Strong** (2018–2020+ gives ≥5 years pre for 2023 adopter; somewhat less for 2021 adopters but still workable with quarterly data)
  - **Selection into treatment:** **Marginal/Weak** (often adopted amid access shortages and political conditions that may correlate with provider trends)
  - **Comparison group:** **Marginal** (restricted states differ systematically from reform states; may be partially addressable with covariates/synthetic control ideas, but not in the current design)
  - **Treatment clusters:** **Weak** (<10 treated states)
  - **Concurrent policies:** **Marginal** (other workforce initiatives and telehealth/payment changes could coincide; varies by state)
  - **Outcome-Policy Alignment:** **Strong** (FPA plausibly affects NP entry/location and Medicaid billing participation)
  - **Data-Outcome Timing:** **Marginal** (effective dates often mid-year; quarterly aggregation creates partial exposure unless aligned to month-of-service and legal effective dates)
  - **Outcome Dilution:** **Strong** (if outcome is NP/physician participation within Medicaid claims, the measured population is directly affected)
- **Recommendation:** **SKIP as a standalone DiD.** **CONSIDER only as a descriptive/mechanism appendix** within Idea #1 (e.g., post-unwinding substitution patterns), or redesign around a longer time horizon / more reform events (which may forfeit the T‑MSIS advantage).

---

### Summary

This is a top-heavy batch: **Idea #1 is the only proposal that clears the basic identification and feasibility bar**, largely because of the long pre-period, broad coverage, and unusually policy-relevant shock. **Ideas #2 and #3 fail the DiD checklist on “Weak” criteria** (universal/no-control + endogenous dose for HCBS; too few treated clusters for NP SOP), so I would not fund them as primary causal projects without major redesign.