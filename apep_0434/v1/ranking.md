# Research Idea Ranking

**Generated:** 2026-02-21T15:00:00.614763
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7308

---

### Rankings

**#1: MGNREGA and the Geography of Structural Transformation: Village-Level Evidence from 600,000 Indian Villages**
- **Score:** 74/100
- **Strengths:** Very large-scale, policy-salient question with unusually rich geography (near-universe of villages) and a rollout that provides credible timing variation. Combining worker-composition shifts with annual nightlights lets you study both “real-side” structural change and a higher-frequency proxy for activity.
- **Concerns:** Phase assignment targets “backward” districts, so differential convergence trends remain a core threat (even with CS-DiD). Census worker composition is only observed in 2001 and 2011, so the *primary* structural-transformation outcome cannot be pre-trend-tested directly (you’ll be leaning on nightlights for diagnostics, which is not the same outcome).
- **Novelty Assessment:** **Moderately novel.** MGNREGA is heavily studied (wages, migration, consumption, labor supply, leakage), but *village-level, near-universe structural transformation decompositions* using modern staggered-adoption estimators is much less saturated.
- **DiD Assessment (staggered DiD):**
  - **Pre-treatment periods:** **Strong** for nightlights (>=5 years pre), **Weak-ish for worker composition** (only one pre point). Overall: **Marginal** because your key “structural transformation” outcome has limited pre-trend testability.
  - **Selection into treatment:** **Marginal** (assignment by backwardness index is policy-driven and predetermined, but plausibly correlated with differential growth/convergence trends).
  - **Comparison group:** **Marginal** (Phase III districts are systematically less “backward”; CS-DiD helps, but common-trend plausibility is not automatic).
  - **Treatment clusters:** **Strong** (hundreds of districts; inference at district level is credible).
  - **Concurrent policies:** **Marginal** (mid-2000s India has overlapping rural programs—PMGSY, NRHM/health expansions, electrification—often also targeted to poorer districts).
  - **Outcome-Policy Alignment:** **Strong** for worker shares (direct structural transformation concept); **Marginal** for nightlights (plausible proxy but not uniquely tied to labor reallocation).
  - **Data-Outcome Timing:** **Marginal** (MGNREGA starts Feb/Apr; annual DMSP composites create partial-exposure “first treated year” for Phase II/III unless you re-index treatment to first full-exposure year; Census 2011 is safely post).
  - **Outcome Dilution:** **Strong** (program plausibly affects broad village labor allocation and equilibrium outcomes, not a tiny subpopulation).
- **Recommendation:** **PURSUE (conditional on: (i) define “first treated” as first full-exposure nightlights year by cohort; (ii) show strong placebo/event-study diagnostics on *pre-period nightlights* and—if possible—bring in any intermediate labor-market data to support the worker-composition interpretation; (iii) explicitly address other contemporaneous district-targeted programs).**

---

**#2: PMGSY Rural Roads and Non-Farm Employment: Extending the Asher-Novosad RDD**
- **Score:** 66/100
- **Strengths:** Identification is comparatively clean: eligibility thresholds are a strong source of quasi-random variation, and the policy is first-order for structural change (market access, commuting, firm entry). The outcomes (worker composition + lights) are tightly aligned with the mechanism.
- **Concerns:** This is an *incremental* extension of a very prominent AER paper; novelty is therefore limited and reviewers may see it as “one more outcome.” Also, implementation is typically **fuzzy** (not perfectly sharp at 500/250), and population heaping/measurement error around thresholds needs careful handling.
- **Novelty Assessment:** **Low-to-moderate.** PMGSY at the population cutoff is extremely well-trodden; the worker-composition decomposition is a sensible add-on but not a fundamentally new design or setting.
- **Recommendation:** **CONSIDER (best if you can add a genuinely new angle: e.g., distributional labor outcomes, migration linkages, firm formation, or dynamic lights with careful exposure timing; and explicitly treat this as fuzzy RDD/IV with strong first stage and manipulation tests).**

---

**#3: India’s Demonetization and Rural Economic Activity: A Village-Level Intensity Design**
- **Score:** 52/100
- **Strengths:** Demonetization is a major, unexpected macro shock, and village-level heterogeneity in pre-period banking access is an intuitive exposure gradient. If executed well (especially with higher-frequency lights), the design can speak to short-run disruption vs. medium-run adaptation.
- **Concerns:** The intensity variable (bank/ATM access in 2011) is strongly correlated with development and likely with *differential* pre-trends in electrification, structural change, and growth—this is the central identification risk. Using **annual** VIIRS is also a serious timing/alignment problem for a November 2016 shock (2016 is mostly pre), and post-2017 confounding (GST rollout, other reforms) could differentially affect banked vs unbanked areas.
- **Novelty Assessment:** **Moderate.** Demonetization has many papers, but village-level lights with a banking-penetration gradient is less common; still, “lights + demonetization” is not wholly new.
- **DiD Assessment (intensity DiD):**
  - **Pre-treatment periods:** **Marginal** (2012–2016 gives ~4–5 pre years depending on how you code 2016).
  - **Selection into treatment:** **Weak** (bank access is not externally assigned; it is a development outcome itself and can proxy for underlying growth trajectories).
  - **Comparison group:** **Marginal** (within-state high- vs low-access villages are more comparable than across states, but still systematically different).
  - **Treatment clusters:** **Strong** if inference is below state (village/district) with appropriate spatial clustering; **Weak** if relying on 28 states for inference.
  - **Concurrent policies:** **Marginal** (GST and other changes around 2017 may load differently by formalization/banking access).
  - **Outcome-Policy Alignment:** **Marginal** (nightlights proxy activity; demonetization primarily hits transactions/liquidity—plausible but noisy mapping).
  - **Data-Outcome Timing:** **Weak (with annual VIIRS)** because “post” is not well-timed to the shock; first clean full-exposure year is 2017 and even that bundles recovery/adaptation.
  - **Outcome Dilution:** **Marginal** (cash-dependence differences exist, but lights also reflect non-affected sectors/households; the treated “margin” may be modest in many places).
- **Recommendation:** **SKIP unless redesigned.** **CONSIDER only if** you switch to **monthly VIIRS (or other high-frequency outcomes)**, pre-register stringent pre-trend diagnostics, and keep inference credible with appropriate clustering (and/or within-district comparisons).

---

**#4: MGNREGA and Female Human Capital Formation: Did Employment Guarantees Promote Girls’ Education?**
- **Score:** 45/100
- **Strengths:** High policy relevance (human capital and gender) and excellent geographic coverage. The staggered rollout is attractive in principle.
- **Concerns:** With **only 2001 and 2011 Census literacy**, you cannot credibly test parallel trends for the key outcome, and you cannot map dynamics to treatment timing (2006–2008) in a way that distinguishes mechanisms; this is a classic DiD failure mode. Literacy in 2011 also reflects cumulative schooling decisions over many years, so attribution to a mid-2000s employment program is intrinsically muddled without intermediate schooling measures.
- **Novelty Assessment:** **Low-to-moderate.** The “MGNREGA → schooling/girls” question has an existing literature and mixed findings; your contribution would mostly be scale, not design strength.
- **DiD Assessment (staggered DiD):**
  - **Pre-treatment periods:** **Weak** (effectively one pre point for literacy; cannot test pre-trends).
  - **Selection into treatment:** **Marginal** (same backwardness-index targeting concern as Idea 1).
  - **Comparison group:** **Marginal** (late-treated districts differ systematically).
  - **Treatment clusters:** **Strong** (many districts).
  - **Concurrent policies:** **Marginal** (other education and social programs over the decade plausibly correlated with backwardness).
  - **Outcome-Policy Alignment:** **Marginal** (literacy is a slow-moving stock; plausible but not tightly linked to a short-run employment guarantee shock).
  - **Data-Outcome Timing:** **Strong** in the narrow sense (2011 is after treatment), but **not informative dynamically**.
  - **Outcome Dilution:** **Marginal** (effects likely concentrated among school-age girls during rollout years; village-wide literacy aggregates many cohorts).
- **Recommendation:** **SKIP** (unless you can add **annual schooling outcomes**—e.g., DISE/UDISE enrollment/attendance/test metrics by cohort/age, or NSS education modules—so that pre-trends and timing are defensible).

---

### Summary

This is a decent batch: one genuinely promising large-scale DiD (Idea 1) and one clean-design-but-incremental RDD extension (Idea 4). The two education/demonetization DiDs run into the two most common dealbreakers: **insufficient outcome timing/frequency for credible DiD (Idea 3)** and **timing + endogenous intensity (Idea 2)**. If prioritizing institute resources, I’d start with **Idea 1** (with careful exposure timing and confound checks), and keep **Idea 4** as a solid second project if you can add a distinctly new contribution beyond Asher–Novosad.