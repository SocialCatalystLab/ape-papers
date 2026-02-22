# Research Idea Ranking

**Generated:** 2026-02-22T10:22:46.818568
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6045

---

### Rankings

**#1: Combined Design — Social Insurance Thresholds and the Quality of Late-Career Employment (RECOMMENDED)**
- **Score:** 76/100  
- **Strengths:** Most original *framing* in the set: using two age-based eligibility shocks in one unified design to separate insurance vs. income constraints is a genuinely compelling contribution. Very large sample and clear, policy-salient mechanisms (job lock vs. income floor).  
- **Concerns:** The public-use ACS age-in-years running variable creates a *coarse/discrete RD* with few effective support points near each cutoff, making inference and bandwidth sensitivity a first-order risk (you’re not getting “as-good-as-continuous” RD). Also, at least one proposed component (involuntary vs voluntary part-time) may not be measurable in ACS as stated, so the “index” could collapse unless outcomes are redefined.  
- **Novelty Assessment:** Medicare-at-65 and SS-at-62 RDs are heavily studied, but “employment *quality/mismatch*” and especially a *dual-cutoff mechanism decomposition* is much less saturated. Net: **moderately high novelty conditional on sharpening outcomes**.  
- **Recommendation:** **PURSUE (conditional on: (i) verifying each outcome is truly observed in ACS PUMS; (ii) pre-registering a small set of primary outcomes to avoid an index that looks like specification-mining; (iii) adopting discrete-RD-appropriate inference/robustness—e.g., Lee-Card grouped approach, randomization inference over age cells, and sensitivity to bandwidth/functional form).**

---

**#2: Unlocking Better Jobs? Medicare Eligibility at 65 and Late-Career Underemployment**
- **Score:** 66/100  
- **Strengths:** Clear policy shock with high relevance; Medicare eligibility at 65 plausibly changes outside options and job lock, and ACS has strong coverage and huge N. The “employment quality” angle is a nice departure from the retirement/extensive-margin Medicare RD literature.  
- **Concerns:** Two measurement problems are potentially fatal *as written*: (i) **involuntary part-time** (“wants full-time”) is typically not available in ACS the way it is in CPS; (ii) “occupational downgrading relative to prior career trajectory” is hard in a repeated cross-section without prior occupation/long panel structure. Identification is also limited by integer-age RD (few local support points; inference sensitive to age-cell functional form).  
- **Novelty Assessment:** Medicare-at-65 RD = very well-trodden, but **this specific outcome set (mismatch/overqualification) is not** widely studied using that design. Net: **moderate novelty**.  
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: involuntary PT is replaced with an ACS-measurable proxy; “downgrading” is redefined using feasible constructs—e.g., occupation/education predicted earnings residuals, or crosswalk-based “required education” mismatch—without pretending to observe individual trajectories).**

---

**#3: From Constraint to Choice: Social Security Early Eligibility at 62 and the Voluntary Part-Time Transition**
- **Score:** 54/100  
- **Strengths:** Good question and mechanism (income floor enabling a shift from “bad part-time” to “chosen part-time” or exit). The SS age-62 threshold is policy-relevant and, in principle, offers a clean eligibility discontinuity.  
- **Concerns:** Data feasibility is the binding constraint: **ACS likely cannot cleanly distinguish voluntary vs involuntary part-time** in the way the proposal assumes; if you move to CPS to get that variable, sample size near the cutoff (and precision for subgroup analysis) becomes a real concern. Identification is also likely **fuzzy RD** (eligibility ≠ receipt), requiring a strong first stage using SS income receipt—feasible, but it changes the design and interpretation.  
- **Novelty Assessment:** Retirement/claiming around 62 is extensively studied; “involuntary→voluntary part-time” is **less studied**, but the core threshold is not novel. Net: **moderate**.  
- **Recommendation:** **CONSIDER (conditional on: (i) confirming the involuntary/voluntary PT measure in the chosen dataset; (ii) planning explicitly for fuzzy RD using SS receipt as first stage; (iii) demonstrating power near the cutoff if CPS is required).**

---

**#4: The Gainful Employment Cliff: Do Accountability Thresholds Reduce Credential Waste at For-Profit Colleges?**
- **Score:** 43/100  
- **Strengths:** High policy relevance (federal aid eligibility, for-profit sector accountability) and the idea of threshold-based accountability *could* support quasi-experimental work. The reinstated GE rule creates timely interest.  
- **Concerns:** The proposed “sharp RDD” is not clean in practice. The running variable (debt-to-earnings) **mechanically contains the outcome (earnings)**, raising severe endogeneity/mechanical bias issues even if you lag it. More importantly, the 2023 reinstatement + first metrics in 2025 means **post-treatment outcome windows may not exist yet** (or will be short and confounded by anticipatory responses, program closures, reporting changes, and compositional shifts). Treatment is also not a single threshold in practice (multiple metrics, enforcement lags, potential discretion), so “sharpness” is doubtful.  
- **Novelty Assessment:** Using the *new* GE iteration is new-ish, but GE/accountability in for-profits has a sizable literature (on enrollment, closures, aid, compliance). An RD at the cutoff may be less common, but the big issue is feasibility/validity, not novelty.  
- **Recommendation:** **SKIP for now** (revisit once there are multiple post-metric cohorts and a design that avoids “outcome in the running variable”—e.g., exploiting discrete enforcement events, audits, or eligibility-loss timing with cleaner assignment).

---

### Summary

This is a stronger batch than typical because three ideas lean on plausibly exogenous age-based eligibility thresholds rather than weak DiD. The best next step is **Idea #1 (the combined dual-threshold paper)**, but only if the team **tightens outcome measurement to what the ACS truly contains** and treats the design as **discrete/fuzzy RD** with appropriate inference rather than assuming a textbook “sharp RD.” The Gainful Employment idea is policy-relevant but currently too early and too mechanically entangled with the outcome to be credible.