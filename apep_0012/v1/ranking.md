# Research Idea Ranking

**Generated:** 2026-01-17T10:08:21.391073
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4785
**OpenAI Response ID:** resp_0b370fce52d9ccae00696b5156a27c8196af11d95c22677068

---

### Rankings

**#1: Universal Occupational Licensing Recognition and Employment**
- **Score: 76/100**
- **Strengths:** The policy is recent and plausibly understudied, with a clear mechanism (reduced relicensing barriers) and an outcome/margin where effects should concentrate (recent interstate movers in licensed occupations). ACS can identify occupation and recent migration, enabling a credible mover-focused design.
- **Concerns:** “Licensed occupation” is an imperfect proxy for being subject to licensing, and universal recognition laws differ substantially across states (exceptions, implementation lags, scope), creating treatment-measurement error. Staggered adoption raises standard DiD pitfalls (heterogeneous treatment effects, non-random adoption); you’ll need modern estimators and strong pre-trend diagnostics.
- **Novelty Assessment:** **Moderately high.** Occupational licensing is heavily studied, but *universal recognition* as a distinct, recent policy has much thinner causal evidence, especially with worker-level mover outcomes.
- **Recommendation:** **PURSUE**

**#2: Michigan Right-to-Work Repeal and Union Membership**
- **Score: 64/100**
- **Strengths:** Extremely novel and highly policy-relevant—this is the kind of “first-of-its-kind” policy change institutes like. If you can measure unionization and labor-market outcomes well, it can speak directly to RTW debates and reversibility of prior findings.
- **Concerns:** **ACS PUMS does not measure union membership**, so the headline outcome is not feasible as written (you’d need CPS MORG or administrative/union data). Identification is also intrinsically fragile with one treated state and a 2024 effective date (partial-year exposure in 2024, contract renegotiation lags, and contemporaneous shocks); a synthetic control/event-study approach may be more credible than a basic DiD.
- **Novelty Assessment:** **Very high.** RTW *adoption* is widely studied; RTW *repeal* is close to uncharted territory.
- **Recommendation:** **CONSIDER** (but redesign around feasible data and a stronger comparative strategy)

**#3: Colorado State EITC Expansion and Labor Force Participation**
- **Score: 58/100**
- **Strengths:** Colorado’s expansion is large enough to plausibly generate detectable labor-supply responses, and there’s real policy appetite for updated evidence given skepticism raised in recent reappraisals. Colorado provides clean policy timing in 2022 and again in 2024 (potentially an event-study setting).
- **Concerns:** EITC outcomes are hard to study with ACS because eligibility/credit size aren’t observed; constructing “treated” groups from income thresholds is endogenous to work, and you must model eligibility using household structure (children) and simulated credits. Parallel trends are also questionable in the 2020–2024 window (pandemic recovery, other contemporaneous transfers/policies), making clean attribution difficult.
- **Novelty Assessment:** **Low-to-moderate.** The EITC is one of the most studied policies in labor economics; state expansions are less saturated, but far from empty.
- **Recommendation:** **CONSIDER** (only if you can implement a strong eligibility simulation + robust control strategy)

**#4: Illinois State EITC Expansion from 18% to 20% (2023)**
- **Score: 45/100**
- **Strengths:** Large state means good sample sizes, and estimating “small policy changes” can be useful for cost-effectiveness discussions (including credible null effects).
- **Concerns:** The policy change is modest, so effects are likely small relative to noise—making null results hard to interpret (low power vs true zero). Identification/data issues mirror Colorado’s, but with weaker signal: ACS doesn’t observe credits, eligibility is hard to assign cleanly, and a single small step-up makes event-study evidence less compelling.
- **Novelty Assessment:** **Low.** Incremental EITC changes sit inside a very large existing literature, and many states have made similar tweaks.
- **Recommendation:** **SKIP** (unless paired with a broader multi-state design pooling many small expansions)

**#5: Oregon Automatic Voter Registration and Civic Engagement**
- **Score: 22/100**
- **Strengths:** The “spillovers beyond turnout” question is conceptually interesting and potentially policy-relevant if measurable.
- **Concerns:** As noted, **ACS PUMS does not measure voting, volunteering, or most civic engagement outcomes**, so the proposed data cannot answer the question. Even with alternative data (e.g., CPS Voting/Registration, CPS Volunteering/Civic Engagement supplements), Oregon’s early adoption plus diffusion across states complicates DiD choice of controls and timing.
- **Novelty Assessment:** **Moderate.** AVR effects on turnout/registration are studied; broader civic engagement spillovers are less studied, but the binding constraint here is measurement.
- **Recommendation:** **SKIP** (unless you pivot to CPS civic engagement supplements and a redesigned identification strategy)

---

### Summary

This is a mixed batch: the best idea (universal licensing recognition) is both timely and plausibly understudied with feasible ACS-based measurement, while two proposals (Michigan RTW repeal; Oregon AVR) have major feasibility gaps as currently specified (key outcomes not in ACS). If you start work immediately, pursue **universal licensing recognition** first; treat **Michigan RTW repeal** as a high-upside project only after securing appropriate unionization data and a design beyond a basic one-state DiD.