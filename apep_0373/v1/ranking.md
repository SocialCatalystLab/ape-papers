# Research Idea Ranking

**Generated:** 2026-02-19T13:43:05.786763
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 9522

---

### Rankings

**#1: The Gainful Employment Threat: Did Accountability Pressure Improve For-Profit Outcomes?**
- **Score: 74/100**
- **Strengths:** Clear policy lever with sharp incentives and high policy salience (Title IV eligibility). A threshold/RD-style design is, in principle, much cleaner than state-policy DiD if the running variable and cutoff are well-defined and not manipulable.
- **Concerns:** **Feasibility is the main risk**: PSEO coverage of for-profits/programs may be thin, and GE is fundamentally **program-level debt-to-earnings**, while PSEO is earnings-only—so you’ll likely need Scorecard/GE administrative files and careful crosswalks. Also, because GE metrics are partly built from earnings, you must avoid “mechanical” relationships (use *pre-policy* GE scores as the running variable and *post-policy cohorts* as outcomes).
- **Novelty Assessment:** Moderately novel. GE has been studied, but not extensively with **UI-based earnings panels like PSEO** at detailed program×credential levels, and the “threat effect” framing around thresholds is still valuable.
- **Recommendation:** **PURSUE (conditional on: (i) verifying sufficient near-threshold program counts in PSEO-covered states; (ii) obtaining pre-2014 GE program metrics and mapping to PSEO program cells; (iii) defining outcomes as earnings for cohorts graduating *after* treatment exposure, not the same earnings used to compute the running variable).**

---

**#2: Does Raising the Floor Lift Graduates? Minimum Wage Effects on the College Earnings Distribution**
- **Score: 65/100**
- **Strengths:** Uses a genuinely new outcome source for this literature (PSEO distributional earnings by institution/field), and minimum wage variation is rich. The “where in the graduate distribution does MW bind?” question is conceptually interesting, especially for certificates/associate degrees and low-wage fields.
- **Concerns:** Identification is vulnerable to **state-level confounding** (MW changes correlate with politics/cost-of-living and broader labor-market trends), and the core risk is **dilution**: for BA graduates (and at 5–10 years), minimum wage is unlikely to bind for most of the distribution, so estimated effects may be mechanically near zero even if true effects exist for a small subgroup.
- **Novelty Assessment:** Medium. Minimum wage is one of the most-studied policies in labor economics; what’s novel here is **PSEO + graduate-earnings distribution + field/institution cells**, not the policy itself.
- **DiD Assessment (MW as staggered/intensity DiD):**
  - **Pre-treatment periods:** **Marginal** (PSEO has ~7 cohort points; many states already above federal by the first cohort, limiting clean pre-trend testing for early “treated” states)
  - **Selection into treatment:** **Marginal** (state MW policy is political/endogenous; can partly mitigate with controls and region-specific trends, but it’s not externally assigned)
  - **Comparison group:** **Marginal** (states with/without increases differ systematically; institutional FE helps, but state-level shocks remain)
  - **Treatment clusters:** **Strong** (many states with variation; cluster inference feasible)
  - **Concurrent policies:** **Marginal** (MW changes often coincide with other worker/tax policies; must control/annotate major overlaps)
  - **Outcome-Policy Alignment:** **Marginal** (earnings is the right object, but MW should mainly affect the lower tail/early career; effects at P75 and 10-years are a stretch)
  - **Data-Outcome Timing:** **Marginal** (MW effective dates vary—often Jan 1/Jul 1—while PSEO earnings are typically annual UI-based measures; “1 year after graduation” can include partial exposure depending on graduation month/year definition—must verify PSEO timing conventions)
  - **Outcome Dilution:** **Marginal** overall (**could be Strong if you focus on certificate/AA + low-wage fields + 1-year outcomes**, but **likely weak for BA and 10-year outcomes**)
- **Recommendation:** **CONSIDER (conditional on: restricting primary analysis to cells where MW plausibly binds—certificate/associate, low-wage CIPs, and bottom-tail outcomes; and doing aggressive state labor-market controls/sensitivity).**

---

**#3: Graduating into the Storm: Recession Scarring by Field of Study**
- **Score: 60/100**
- **Strengths:** The recession shock is plausibly exogenous, and PSEO can add a useful, policy-relevant layer: **field-of-study heterogeneity within the same institution** using UI-based earnings at 1/5/10 years.
- **Concerns:** Novelty is limited because recession scarring is already a large literature; the key risk is that a “treated cohort vs untreated cohort” setup can be underpowered and sensitive to **timing definitions** (your “2007 cohort” spans multiple graduation years with different exposure) and to **state-by-cohort shocks** beyond unemployment (budget cuts, sectoral composition, migration).
- **Novelty Assessment:** Low-to-medium. The scarring question is heavily studied; PSEO-based field×institution evidence is a meaningful but incremental contribution.
- **DiD Assessment (interpreting as intensity DiD/event-study around unemployment-at-graduation):**
  - **Pre-treatment periods:** **Marginal** (you can use multiple pre-recession cohorts in PSEO, but the “clean” pre window is limited depending on how cohorts are defined)
  - **Selection into treatment:** **Strong** (the Great Recession timing is external; cross-state severity is plausibly quasi-exogenous conditional on pre-trends/industry mix)
  - **Comparison group:** **Marginal** (high- vs low-unemployment states differ; you’ll need controls for pre-trends and state industrial structure)
  - **Treatment clusters:** **Strong** (many states, many institutions/fields)
  - **Concurrent policies:** **Marginal** (ARRA, state budget cuts, tuition changes, sector-specific shocks)
  - **Outcome-Policy Alignment:** **Strong** (unemployment at entry is directly linked to early-career earnings trajectories)
  - **Data-Outcome Timing:** **Marginal** (must map “graduation cohort” precisely to unemployment at graduation month/quarter; a 3-year graduation window blurs exposure)
  - **Outcome Dilution:** **Strong** (shock affects essentially the whole graduating cohort, not a tiny subgroup)
- **Recommendation:** **CONSIDER** (best framed as: “What new measurement does PSEO add?”—e.g., within-institution major comparisons, distributional scarring, persistence to 10 years).

---

**#4: State Higher Education Appropriations and Graduate Earnings**
- **Score: 52/100**
- **Strengths:** High policy relevance (funding cuts are central to state higher-ed debates) and PSEO is well-suited to measuring downstream earnings outcomes.
- **Concerns:** Identification is the problem: appropriations are **highly endogenous** to state economic conditions that also directly affect graduate earnings. The proposed IV (“state fiscal shocks”) is very likely to violate exclusion unless exceptionally well-argued (most fiscal shocks move labor demand, migration, and wages directly). Also, treatment timing is nontrivial: appropriations during *years of enrollment* matter, not just the graduation window.
- **Novelty Assessment:** Medium. Funding effects on enrollment/completion are well-studied; funding effects on **earnings/quality** are less saturated, but not untouched.
- **DiD Assessment (panel TWFE/IV is DiD-adjacent; key risks mirror DiD):**
  - **Pre-treatment periods:** **Marginal** (some pre-cut cohorts exist, but only a handful of cohort points)
  - **Selection into treatment:** **Weak** (appropriations respond to economic conditions/politics; IV validity is the entire paper and is currently not convincing as stated)
  - **Comparison group:** **Marginal** (states differ systematically; you’d need strong design/controls)
  - **Treatment clusters:** **Strong** (many states/institutions)
  - **Concurrent policies:** **Weak** (tuition hikes, financial aid changes, performance funding, and macro shocks often coincide with appropriation changes)
  - **Outcome-Policy Alignment:** **Marginal** (appropriations plausibly affect instructional quality/services, but mapping to earnings is indirect)
  - **Data-Outcome Timing:** **Weak** (appropriations should be assigned to students’ enrollment years; using graduation-window averages risks serious mis-timing)
  - **Outcome Dilution:** **Strong** (appropriations affect a large share of public-institution students)
- **Recommendation:** **SKIP (unless you can: (i) credibly re-time treatment to enrollment years; and (ii) produce an instrument with a compelling exclusion argument—e.g., plausibly exogenous formula shocks that do not shift labor demand).**

---

**#5: State EITC Supplements and Returns to Sub-Baccalaureate Education**
- **Score: 45/100**
- **Strengths:** Policy-relevant and potentially interesting to connect tax credits to postsecondary payoff for sub-BA pathways; the staggered adoption is real.
- **Concerns:** As proposed, this fails core DiD requirements: **too few PSEO cohort periods** to test pre-trends credibly, and the outcome is **pre-tax earnings** while the EITC is an **after-tax credit**—so the outcome-policy link relies on second-order labor supply responses rather than directly measuring the policy’s “return.” Power is also a concern with only 4 cohorts and partial state coverage.
- **Novelty Assessment:** Medium. State EITCs are studied a lot for labor supply/poverty; “returns to education via PSEO” is less studied, but the identification/data limits dominate.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (only ~4 cohorts; many states adopt long before the first cohort → minimal/no pre-period for many treated states)
  - **Selection into treatment:** **Marginal** (political adoption correlated with underlying trends; not externally imposed)
  - **Comparison group:** **Marginal** (remaining never-treated/late-treated states may be systematically different; and may be few in the PSEO-covered subset)
  - **Treatment clusters:** **Marginal** (in principle many states, but effective clusters depend on PSEO state coverage and remaining controls)
  - **Concurrent policies:** **Marginal** (state tax/welfare packages often move together)
  - **Outcome-Policy Alignment:** **Marginal** (EITC directly changes after-tax income; PSEO measures pre-tax earnings—interpretation hinges on labor supply/hours responses)
  - **Data-Outcome Timing:** **Marginal** (EITC applies to tax year; PSEO annual earnings are compatible, but cohort timing still coarse)
  - **Outcome Dilution:** **Marginal** (only EITC-eligible grads are affected; likely well below 50% even among certificate/AA holders)
- **Recommendation:** **SKIP** (the pre-trends/power limitations are close to fatal with current cohort structure; you’d need a different dataset with annual cohorts or microdata on after-tax income/credits).

---

### Summary

This is a solid batch in terms of **creative use of PSEO**, but several ideas run into predictable credibility problems: limited cohort-time granularity for DiD pre-trends, and **dilution/misalignment** when the policy plausibly affects only a small slice of graduates or affects after-tax outcomes while you observe pre-tax earnings. The most promising to pursue first is **Gainful Employment (Idea 4)** because it can plausibly deliver cleaner quasi-experimental identification—*if* program-level data coverage near thresholds is adequate and timing/mechanical-outcome issues are handled carefully. Among the DiD proposals, **minimum wage with a tightly targeted design (Idea 1, restricted to where MW binds)** is the best bet; **EITC (Idea 3)** is the clearest “SKIP” under the DiD checklist due to weak pre-periods and dilution/alignment concerns.