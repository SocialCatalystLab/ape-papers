# Research Idea Ranking

**Generated:** 2026-01-28T15:03:31.061141
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 9460
**OpenAI Response ID:** resp_02939faf061c2ecb00697a168b73d88193ab916264e25ad0db

---

### Rankings

**#1: Telehealth Parity Laws and Mental Health Service Utilization (Pre-COVID)**
- **Score: 67/100**
- **Strengths:** Many adopting states (good treatment variation) and a highly policy-relevant margin (mental health access) where telehealth plausibly matters even pre-COVID. A modern staggered DiD (Callaway–Sant’Anna) is well-suited if timing and coding are handled carefully.
- **Concerns:** Biggest risks are (i) **policy heterogeneity** (coverage vs payment parity; fully-insured vs ERISA self-insured) and (ii) **measurement**—NSDUH/BRFSS outcomes are broad and may not move much if pre-COVID tele-mental-health was still a small share of care. Also serious confounding from contemporaneous changes (ACA/Medicaid expansion; other mental-health initiatives).
- **Novelty Assessment:** **Medium.** Telehealth parity laws and utilization have been studied, but **pre-COVID, mental-health-specific** impacts are less saturated than post-2020 telehealth papers; still, you’ll need to clearly differentiate from existing parity-law and tele-mental-health access work.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (as written, 2010–2019 may leave <5 clean pre-years for early adopters). *Mitigation:* extend outcomes earlier (still pre-COVID) and/or restrict to states adopting ≥2015 to guarantee ≥5 pre-years.
  - **Selection into treatment:** **Marginal** (states may adopt in response to access problems/provider shortages or broader progressive health agendas—plausibly related to trends in mental health treatment).
  - **Comparison group:** **Strong** (many never-treated/late-treated states; can choose regionally comparable controls and test balance/trends).
  - **Treatment clusters:** **Strong** (likely 20+ adopting states in-window, depending on definition).
  - **Concurrent policies:** **Marginal** (Medicaid expansion timing, behavioral health parity enforcement, opioid-related initiatives; requires explicit controls/sensitivity and possibly triple-diff by insurance type or market).
  - **Outcome-Policy Alignment:** **Strong** (laws aim to reduce financial barriers to telehealth; “any mental health treatment” is an appropriate downstream utilization measure, even if not telehealth-specific).
  - **Data-Outcome Timing:** **Marginal** (NSDUH asks about **past-year** treatment; if law is effective mid-year, “treated year” includes pre-policy months). *Mitigation:* define treatment as the first full calendar year after the effective date; do event-time with exposure alignment.
  - **Outcome Dilution:** **Marginal** (policy mainly affects **state-regulated private insurance** and only the telehealth margin; untreated groups in BRFSS/NSDUH dilute effects). *Mitigation:* stratify by insurance where possible; ideally move to claims data with telehealth modifiers to tighten the estimand.
- **Recommendation:** **PURSUE (conditional on: (1) re-defining treatment timing to ensure full-year exposure; (2) careful legal coding separating coverage vs payment parity and accounting for ERISA/self-insured limits; (3) a plan to address ACA/Medicaid expansion and other contemporaneous policies—preferably with subgroup/triple-diff or robustness designs; (4) considering claims-based tele-mental-health outcomes if accessible).**

---

**#2: Right-to-Work Laws and Workplace Safety**
- **Score: 46/100**
- **Strengths:** Outcomes are tightly linked to the mechanism (union strength → safety enforcement/voice), and CFOI fatality data are high quality and conceptually clean. The 2012–2017 wave plus Michigan’s later repeal creates a coherent event-study narrative.
- **Concerns:** This is **fundamentally underpowered for state-policy DiD**: only ~5 treated states in the key window, and adoption is bundled with broader political shifts and labor-market policy packages that threaten identification. Inference with <10 treated clusters is fragile even with “modern DiD.”
- **Novelty Assessment:** **Medium-High.** Unionization and safety is a large literature; RTW specifically on injuries/fatalities is less crowded, but it is not “untouched,” and the main contribution would be design/estimator + updated period rather than a wholly new question.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (2003–2011 provides ample pre-trends for the 2012 adopters).
  - **Selection into treatment:** **Marginal** (likely driven by political control/ideology and union decline; not random and plausibly correlated with other pro-business shifts).
  - **Comparison group:** **Marginal** (treated states are regionally/politically clustered; “never-treated” RTW vs non-RTW differ structurally).
  - **Treatment clusters:** **Weak** (<10 treated states) **→ dealbreaker for credible DiD inference** at the state level.
  - **Concurrent policies:** **Marginal** (other labor regs, enforcement intensity, industry composition shifts; hard to rule out coincident changes).
  - **Outcome-Policy Alignment:** **Strong** (injury/fatality rates are directly relevant).
  - **Data-Outcome Timing:** **Marginal** (laws effective Feb/March; calendar-year outcomes imply partial exposure in first year). *Mitigation:* code first treated year as the first full year post-effective date.
  - **Outcome Dilution:** **Strong** (policy affects broad workforce institutions; not a tiny targeted subgroup).
- **Recommendation:** **SKIP** (unless you abandon statewide DiD and pivot to a design that can credibly work with few treated units—e.g., border-county designs, synthetic control per treated state with randomization inference, or adding earlier RTW adoptions using longer CFOI series to raise treated-cluster count).

---

**#3: Paid Family Leave and Infant Immunization Rates (Expanded States)**
- **Score: 35/100**
- **Strengths:** Clear policy relevance (immunization timeliness) and a plausible time-constraint mechanism for parents. Data availability is good, and multi-state adoption is attractive in principle.
- **Concerns:** As proposed (state-year immunization rates), this is a **timing/exposure mismatch**: NIS immunization coverage for children 19–35 months aggregates multiple birth cohorts and interview months, so “treated year” is not cleanly exposed to PFL at birth/infancy. Also only ~7 treated states total—still weak for state-policy DiD.
- **Novelty Assessment:** **Medium.** PFL effects on child/family outcomes are widely studied; immunizations specifically is less common, but the space is not empty and the identification challenges here dominate.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (earliest treatment CA 2004; with 2003–2022 state estimates you have at most ~1 pre-year for CA in this setup).
  - **Selection into treatment:** **Marginal** (progressive states adopting PFL may already be improving child health access/utilization).
  - **Comparison group:** **Marginal** (treated states differ in health systems, baseline immunization infrastructure).
  - **Treatment clusters:** **Weak** (<10 treated states).
  - **Concurrent policies:** **Marginal** (vaccination policy changes, Medicaid/CHIP administration changes, public health campaigns).
  - **Outcome-Policy Alignment:** **Marginal** (immunizations occur via pediatric care access + parental time; plausible but indirect).
  - **Data-Outcome Timing:** **Weak** (NIS annual estimates reflect children born over ~3 years; policy effective date does not map cleanly to the cohort’s vaccination window).
  - **Outcome Dilution:** **Weak** (even within a treated state-year, only a fraction of the measured 19–35 month cohort had parents eligible for/using PFL at the relevant infant months).
- **Recommendation:** **SKIP** *in its current state-level DiD form.* This becomes **CONSIDER** only if redesigned around **child birth cohort exposure** (using NIS microdata with birth month/year + interview timing) and focusing on later-adopting states to secure long pre-trends—still with the cluster-count problem.

---

**#4: Certificate of Need (CON) Repeal and Rural Hospital Viability**
- **Score: 28/100**
- **Strengths:** High policy salience (rural hospital closures) and a genuinely interesting ambiguity in predicted effects. Hospital-level data sources exist and are rich.
- **Concerns:** Only **3 treated states** with messy phase-outs/effective dates—this is not a credible staggered DiD setting for inference. CON reforms are also deeply entangled with broader state healthcare policy regimes (Medicaid expansion decisions, uncompensated care dynamics, rural subsidies).
- **Novelty Assessment:** **Medium.** CON is heavily studied (entry, prices, competition). “Rural closures” is a more novel outcome within that literature, but the design is too thin to deliver persuasive causal claims.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (closures/cost reports allow many pre-years).
  - **Selection into treatment:** **Marginal** (political/industry-driven; plausibly correlated with hospital market trajectories).
  - **Comparison group:** **Marginal** (states that repeal may differ systematically from those that retain).
  - **Treatment clusters:** **Weak** (3 states) **→ dealbreaker**.
  - **Concurrent policies:** **Marginal** (Medicaid expansion and other reforms contemporaneous with hospital financial stress).
  - **Outcome-Policy Alignment:** **Strong** (closures/margins directly reflect “viability”).
  - **Data-Outcome Timing:** **Marginal** (phase-outs and partial repeals complicate defining first full exposure year).
  - **Outcome Dilution:** **Marginal** (if analyzed at the hospital level for rural hospitals, dilution is less of an issue; at state aggregates it worsens).
- **Recommendation:** **SKIP** (unless reframed as **case-study synthetic controls** with transparent uncertainty/randomization inference, and even then the policy package confounding remains severe).

---

### Summary

Only the **telehealth parity → mental health utilization** idea has a plausible path to a credible multi-state DiD because it can reach adequate treated-cluster count; it still needs major work on **timing, heterogeneity coding, and dilution/measurement**. The other three proposals are dominated by **fatal DiD weaknesses** (especially **<10 treated clusters** and, for PFL→immunizations, severe **data-outcome timing/dilution**), making them poor bets unless redesigned around different identification strategies.