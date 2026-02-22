# Research Idea Ranking

**Generated:** 2026-02-22T16:06:27.480418
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6268

---

### Rankings

**#1: Smaller States, Bigger Growth? Two Decades of Evidence from India's State Bifurcations**
- **Score:** 68/100  
- **Strengths:** Clear, salient “treatment” events (2000 and 2014 state creations) with long post periods and rich spatial outcomes; adding a near-border design is a real opportunity to strengthen credibility beyond a vanilla DiD. Policy relevance is high given ongoing statehood demands in India.  
- **Concerns:** The biggest threat is **inference/identification at the policy cluster level** (only a few treated state-creation episodes), plus potential non-random political economy selection (regions demanding statehood may have different trends). Also, nightlights require careful handling of **partial exposure in the treatment year** (Nov 2000; June 2014).  
- **Novelty Assessment:** **Moderately high.** Some work exists (working papers, synthetic control/state-level analyses), but district/village-level long-run evidence with modern staggered methods + boundary comparisons is still relatively underdeveloped.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (1994–1999 gives 6 pre years for the 2000 cohort; VIIRS gives 5 pre years for 2014 cohort).
  - **Selection into treatment:** **Marginal** (statehood is political; could correlate with latent economic trajectories, grievance, mineral endowments, or governance differences).
  - **Comparison group:** **Marginal/Strong** (remaining districts in the same parent states are a natural comparator, but treated regions may be structurally distinct; border-based comparisons help).
  - **Treatment clusters:** **Weak** (effectively ~3–4 major “policy shocks”; district-level N does not solve the small number of independent clusters problem).
  - **Concurrent policies:** **Marginal** (national trends are differenced out, but state creation may coincide with targeted public investment, new capitals, mining policy attention—arguably part of “treatment,” but still complicates interpretation).
  - **Outcome-Policy Alignment:** **Strong** (nightlights are a plausible proxy for local economic activity that could respond to governance/admin changes from new state capacity and spending).
  - **Data-Outcome Timing:** **Marginal** (DMSP annual composites: “year 2000” includes mostly pre-treatment exposure since bifurcation is in Nov; VIIRS monthly can fix Telangana timing if aligned to post-July 2014 months).
  - **Outcome Dilution:** **Strong** (statehood plausibly affects a large share of economic activity in treated districts; not a tiny targeted subgroup).
- **Recommendation:** **CONSIDER (conditional on: (i) making 2001/2015 the first full-exposure post years; (ii) prioritizing the border/near-boundary design as a primary or co-primary strategy; (iii) a credible small-cluster inference plan—randomization inference and/or carefully justified aggregation to a small number of comparable border segments).**

---

**#2: Does District Proliferation Accelerate Development? Evidence from India's Administrative Fragmentation**
- **Score:** 48/100  
- **Strengths:** Very high potential novelty and large-scale relevance—district proliferation is ubiquitous and politically salient, and sub-district nightlights offer large samples and heterogeneity (e.g., distance to HQ) that maps to a plausible mechanism.  
- **Concerns:** Core identification risk is **endogenous treatment timing** (districts are often split because of growth, neglect, ethnic politics, or administrative overload—factors that also affect outcomes). Data construction is nontrivial (exact split dates, consistent boundary harmonization), and mismeasurement of “treatment” can easily swamp results.  
- **Novelty Assessment:** **High.** Compared with state creation, rigorous causal work on district splitting at scale is relatively sparse; the main reason it’s sparse is identification/data difficulty rather than lack of interest.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (nightlights allow long pre histories in principle).
  - **Selection into treatment:** **Weak** (likely responds to unobserved trends/pressures; without a quasi-exogenous rule or instrument, parallel trends is not credible).
  - **Comparison group:** **Marginal** (controls within the same state/parent districts can help, but treated sub-districts may differ systematically; “never split” areas may be fundamentally different).
  - **Treatment clusters:** **Strong** (100+ splits gives many clusters—good for inference *if* selection were credible).
  - **Concurrent policies:** **Marginal** (splits often bundled with new HQ spending, staffing, infrastructure—arguably the mechanism, but it makes “administrative proximity” vs “targeted investment” hard to separate).
  - **Outcome-Policy Alignment:** **Strong** (if district creation improves access to services/administration, local economic activity could plausibly move; nightlights is a reasonable proxy).
  - **Data-Outcome Timing:** **Marginal** (needs exact effective dates; year-of-split outcomes may have partial exposure; must define first full post year consistently).
  - **Outcome Dilution:** **Strong** (the administrative change plausibly affects most residents in treated sub-districts, not a tiny subgroup).
- **Recommendation:** **SKIP (unless you can credibly mitigate selection).** To upgrade: find an plausibly exogenous assignment mechanism (e.g., population/area thresholds applied discontinuously; court orders; centrally mandated reorganization; close-election political shocks), or implement a compelling border-based design with pre-trend validation and tight geography.

---

**#3: The GST Dividend — Did Tax Unification Boost Economic Activity?**
- **Score:** 42/100  
- **Strengths:** Very high policy relevance; good-quality, high-frequency VIIRS data could support a tight event-study window and rich heterogeneity by baseline informality.  
- **Concerns:** Identification is the problem: GST is a **nationwide** reform, so everything hinges on **intensity-based parallel trends**, which is hard to defend. There are also major coincident shocks (notably **demonetization in late 2016**, plus later implementation waves and **COVID**) that differentially affect “high-tax/informal” places, making intensity designs especially fragile.  
- **Novelty Assessment:** **Moderate-to-low.** There is already a large empirical literature on GST/formalization and on India’s 2016–2019 policy shocks; district-level nightlights is a twist, but not a fundamentally new identification strategy.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (VIIRS 2012–2016 gives 5 pre years; still not generous, but meets the bar).
  - **Selection into treatment:** **Marginal** (policy is exogenous nationally, but “treatment intensity” (pre-GST tax burden) is not; it may proxy for state capacity, development, or sector mix with different trends).
  - **Comparison group:** **Marginal** (high- vs low-intensity states are structurally different; comparability is questionable).
  - **Treatment clusters:** **Strong** (~30 states; inference feasible at state level).
  - **Concurrent policies:** **Weak** (demonetization timing is immediately pre-GST and plausibly interacts with informality; later GST rollout changes and COVID further contaminate post periods).
  - **Outcome-Policy Alignment:** **Marginal** (GST’s key channel is formalization/compliance and supply-chain reorganization; nightlights captures overall activity, not formalization per se, and could move ambiguously).
  - **Data-Outcome Timing:** **Marginal/Strong** (can be **Strong** if using monthly VIIRS and defining post as Aug 2017+; **Marginal** if relying on annual composites that include partial 2017 exposure).
  - **Outcome Dilution:** **Strong** (GST is economy-wide; not a tiny targeted group).
- **Recommendation:** **SKIP** (unless you can (i) isolate a short window avoiding demonetization and later shocks, and (ii) provide unusually convincing evidence that intensity groups had parallel pre-trends and no differential confounders—hard in practice).

---

### Summary

This is a decent batch on India with strong data potential, but only **Idea 1** has a path to credible causal inference *if* you confront the small-number-of-policy-clusters problem head-on and fix treatment-year exposure timing. **Idea 2** is the most novel but currently fails on **selection into treatment** (a likely dealbreaker without a quasi-exogenous trigger). **Idea 3** is highly policy-relevant but is undermined by intensity-based identification plus major concurrent shocks (especially demonetization and COVID), making clean interpretation unlikely.