# Research Idea Ranking

**Generated:** 2026-01-21T14:30:09.105937
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 8914
**OpenAI Response ID:** resp_0574e0782f64db3d006970d47a68b88195aab0a35bcafa432b

---

### Rankings

**#1: State Automatic IRA Mandates and Retirement Savings Participation**
- Score: **72/100**
- Strengths: Policy is genuinely new and spreading, with enough staggered rollouts to support modern event-study DiD. CPS ASEC has a direct (if imperfect) retirement participation measure with long pre-periods for pre-trend diagnostics.
- Concerns: CPS may not cleanly measure *auto-IRA* participation (it’s not an employer plan), so estimated effects could be attenuated/mis-measured; phased mandates (by employer size) create fuzzy treatment timing and heterogeneous “dose.” Selection is plausibly related to baseline coverage gaps and progressive policy bundles.
- Novelty Assessment: **Moderate–high novelty.** There’s a growing but still small literature on state auto-IRA programs (often using OregonSaves/admin data), and much less on broad labor-market participation effects across multiple states.
- DiD Assessment:
  - Pre-treatment periods: **Strong**
  - Selection into treatment: **Marginal**
  - Comparison group: **Strong**
  - Treatment clusters: **Marginal** (≈10–11 treated states; still <20)
  - Concurrent policies: **Marginal** (federal SECURE/SECURE 2.0, state tax/benefit changes, other pro-worker policies)
- Recommendation: **PURSUE** (but redesign treatment to reflect phased coverage and validate the outcome measure—ideally triangulate with admin program stats or another survey that captures IRA payroll-deduction participation)

---

**#2: State Surprise Billing Laws and Personal Bankruptcy Filings**
- Score: **66/100**
- Strengths: Strong policy relevance and a relatively underexplored downstream welfare outcome (financial distress), with a clear “experiment end” when the federal No Surprises Act arrives in 2022. Bankruptcy filings are high-frequency admin data, enabling flexible event studies.
- Concerns: The biggest risk is **outcome validity**: court filings don’t identify “medical bankruptcies,” so you may only detect an effect on overall bankruptcies (likely small/noisy). “Comprehensive” laws are heterogeneous across states (scope, arbitration, enforcement), creating treatment misclassification and possible attenuation.
- Novelty Assessment: **Moderate novelty.** Surprise-billing laws are studied heavily for prices/billing; bankruptcy/financial distress impacts are much less studied.
- DiD Assessment:
  - Pre-treatment periods: **Strong**
  - Selection into treatment: **Marginal** (may respond to healthcare-market complaints/cost growth; not obviously to bankruptcy trends, but needs evidence)
  - Comparison group: **Strong** (pre-2022 never/late adopters exist)
  - Treatment clusters: **Marginal** *(could be Strong if you broaden beyond the small set of “comprehensive” statutes or build a policy-strength index; otherwise it may be <10 and fragile)*
  - Concurrent policies: **Marginal** (Medicaid expansion, exchange dynamics, local provider-market reforms)
- Recommendation: **CONSIDER** (upgrade if you (i) build a credible policy-intensity measure and (ii) add a more medical-debt-proximate outcome—e.g., medical collections/charge-offs via credit-bureau aggregates if obtainable)

---

**#3: State Paid Family Leave and Self-Employment Entry**
- Score: **48/100**
- Strengths: Interesting mechanism (social insurance as entrepreneurship “risk reduction”) and CPS can support transition rates with long pre-periods. Clear target subgroups (new parents / childbearing ages) for heterogeneity tests.
- Concerns: **Dealbreaker risk on inference**: only **9 treated states** through 2024, which makes state-clustered DiD fragile. Mechanism is also ambiguous because many PFL programs don’t automatically insure the newly self-employed (often opt-in), so effects could be zero or negative without careful institutional mapping.
- Novelty Assessment: **Moderate novelty.** PFL is extensively studied; entrepreneurship/self-employment outcomes are less common but adjacent to broader “social insurance and entrepreneurship” literatures.
- DiD Assessment:
  - Pre-treatment periods: **Strong**
  - Selection into treatment: **Strong**
  - Comparison group: **Strong**
  - Treatment clusters: **Weak** (<10 treated states)
  - Concurrent policies: **Marginal** (ACA, state minimum wages, UI reforms, childcare expansions)
- Recommendation: **SKIP** *(unless you substantially change the design—e.g., a border-county design with careful inference, or a different data source/outcome with many more policy shocks)*

---

**#4: Certificate of Need Repeal and Hospital Market Entry**
- Score: **42/100**
- Strengths: High policy relevance and clear theoretical predictions (entry, capacity, service mix). Administrative provider files can measure entry/exit without proprietary AHA data.
- Concerns: As proposed (focused on *recent* repeals), there are **too few treated clusters** with enough post-period to support credible DiD; partial/phased repeals further blur treatment timing. The CON literature is already large, so the incremental contribution hinges entirely on modern variation—yet that’s exactly where statistical power/inference is weakest.
- Novelty Assessment: **Low–moderate.** CON effects on entry/prices/quality have a deep literature; “modern-era” repeals are a narrower new angle but currently sparse.
- DiD Assessment:
  - Pre-treatment periods: **Strong**
  - Selection into treatment: **Marginal**
  - Comparison group: **Strong**
  - Treatment clusters: **Weak** (very few modern repeals with usable post data)
  - Concurrent policies: **Marginal** (Medicaid expansion, consolidation waves, rural closures)
- Recommendation: **SKIP** *(salvageable only if you expand to many historical repeals and convincingly address changing healthcare-market structure over decades—hard, but possible)*

---

**#5: State Data Privacy Laws and Tech Sector Employment**
- Score: **30/100**
- Strengths: Policy topic is timely and important; QCEW is excellent (near-universe) data with granular industry geography.
- Concerns: Two major identification failures: (i) **selection** (early adopters are systematically tech-heavy and politically distinctive) and (ii) **California’s 2020 timing collides with COVID/remote-work shocks**, which directly hit the same industries/outcomes. Even excluding CA, the number of treated states is small and the remaining adopters cluster in 2023–2024 when tech faced national layoffs and interest-rate shocks.
- Novelty Assessment: **Moderate novelty.** Economic impacts of state privacy laws are less studied than consumer/privacy outcomes, but not untouched—and novelty can’t compensate for confounding here.
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (for key early adopter CA, usable clean pre is short relative to the COVID shock)
  - Selection into treatment: **Weak**
  - Comparison group: **Marginal**
  - Treatment clusters: **Marginal**
  - Concurrent policies: **Weak** (COVID + tech-cycle shocks)
- Recommendation: **SKIP**

---

### Summary
This is a decent batch on policy-relevant topics, but only **Idea 1** is clearly in “move forward” territory under credible DiD. **Idea 4** is the best secondary option if you tighten treatment definitions and improve outcome measurement beyond raw bankruptcy counts. **Ideas 2, 3, and 5** each trigger at least one DiD checklist “Weak” item (clusters or confounding), making them poor bets without major redesign.