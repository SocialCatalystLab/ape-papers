# Research Idea Ranking

**Generated:** 2026-01-26T11:47:46.066668
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6415
**OpenAI Response ID:** resp_052e4e95b427f555006977461a85f88195bc9bf30d38e3cb1c

---

### Rankings

**#1: Remote Work and Housing Cost Burden**
- **Score: 68/100**
- **Strengths:** Big, timely policy-relevant phenomenon with excellent sample size and directly measured housing-cost-burden outcomes (GRPIP/OCPIP). DR is a reasonable choice given rich covariates and no obvious quasi-experiment.
- **Concerns:** Causal identification is the main weakness: remote work is highly selected on unobservables (preferences for location/amenities, wealth, dual-earner constraints, employer type), and cross-sectional ACS makes “geographic arbitrage” hard to separate from pre-existing sorting. JWTRNS (“worked from home”) is also a noisy measure of sustained remote work (potential misclassification).
- **Novelty Assessment:** **Moderately novel** as framed (micro/household-level *housing burden* vs. the much-studied aggregate housing-price effects of WFH), but remote work and location/housing outcomes are already a crowded area; the novelty comes from the *outcome* and decomposition.
- **Recommendation:** **PURSUE (conditional on: strong balance/overlap diagnostics + sensitivity analysis for unobservables; explicit tests for “arbitrage” via metro-to-nonmetro/location-cost proxies; careful sample definition to avoid mismeasurement of WFH)**

---

**#2: Immigrant Self-Employment as Economic Integration Pathway**
- **Score: 56/100**
- **Strengths:** Clear policy relevance (immigrant integration) and excellent ACS feasibility with immigrant-specific controls (year of entry, English proficiency, origin). Large sample supports heterogeneity (years-in-US, English ability).
- **Concerns:** Identification is fundamentally weak under selection-on-observables: immigrant self-employment is plausibly driven by unobserved ability, wealth, networks, legal status, and discrimination—all directly tied to income and homeownership. Interpretation risks devolving into a descriptive “who selects into self-employment” result unless you add a stronger design or bounding.
- **Novelty Assessment:** **Low-to-moderate novelty.** Immigrant entrepreneurship/self-employment and earnings assimilation have a large existing literature; the “integration pathway vs necessity” framing is common. The incremental contribution would need to be very crisp (e.g., new margins, modern period, well-executed heterogeneity).
- **Recommendation:** **CONSIDER (best as descriptive + mechanism/heterogeneity; or add stronger identification such as plausibly exogenous shocks, local network instruments, or panel data like SIPP)**

---

**#3: Involuntary Part-Time Work and Healthcare Coverage**
- **Score: 44/100**
- **Strengths:** Policymakers care about insurance gaps and the ACA’s hours incentives; the question is tightly connected to labor-market slack and benefit access. Conceptually clean comparison groups (involuntary PT vs voluntary PT vs FT).
- **Concerns:** **Data feasibility is a major problem as proposed:** ACS does not identify “involuntary/economic-reasons” part-time, so the core treatment is not measured. Even with CPS, health insurance is not cleanly measured in the monthly MORG (typically strongest in CPS ASEC/other supplements), creating a stitching/matching challenge; identification remains selection-heavy (hours and benefits jointly determined).
- **Novelty Assessment:** **Low novelty.** Part-time work, employer coverage, and ACA-related hours manipulation have been studied extensively; distinguishing involuntary vs voluntary is useful but not new enough to offset weak measurement.
- **Recommendation:** **SKIP unless you can (i) obtain CPS ASEC or another dataset that jointly measures involuntary PT and detailed insurance, and (ii) articulate a sharper design than selection-on-observables (e.g., local demand shocks, firm/industry-hour discontinuities, or quasi-exogenous scheduling changes).**

---

**#4: Gig/Self-Employment and Retirement Account Access**
- **Score: 41/100**
- **Strengths:** Retirement security for nontraditional workers is highly policy-relevant, and the self-employment treatment is measurable in ACS with big samples.
- **Concerns:** **Outcome-policy alignment is the dealbreaker in current form:** ACS does not measure retirement *account access/ownership*; retirement income receipt and interest income are poor proxies (age-confounded, extremely skewed, and not a direct measure of plan coverage). Any “coverage gap” result would be hard to interpret causally or even descriptively.
- **Novelty Assessment:** **Moderate novelty** (retirement access among gig/self-employed is a newer policy focus), but there is still substantial existing work using SIPP/SCF/administrative data on retirement coverage and participation; the novelty won’t survive weak measurement.
- **Recommendation:** **SKIP (unless pivoting to SIPP/SCF/administrative tax/plan data with direct measures of IRA/401(k) participation or contributions).**

---

**#5: Union Membership and Non-Wage Compensation**
- **Score: 33/100**
- **Strengths:** Total compensation (benefits + wages) is policy-relevant, and a well-executed benefits decomposition could be useful for current labor-market debates.
- **Concerns:** **Novelty is low and feasibility is shakier than it appears:** the union effects literature is enormous, including benefits, and CPS MORG is not the cleanest source for benefit measures (health insurance and pension/plan coverage are typically better in ASEC or specialized supplements; measurement consistency over time is tricky). Identification via DR is unlikely to be credible given strong selection into union jobs (firm/industry, worker preferences, job quality).
- **Novelty Assessment:** **Low novelty.** Many decades of research on union compensation packages; a DR re-estimate with standard controls is unlikely to move the literature unless paired with a stronger design (e.g., close union elections, bargaining shocks, RTW changes with credible DiD, or matched employer-employee data).
- **Recommendation:** **SKIP (unless redesigned around a quasi-experiment and a dataset with high-quality benefits measurement).**

---

### Summary

This is a coherent set of DR-style observational proposals, but most hinge on **strong unconfoundedness assumptions** and (in two cases) **key variable measurement gaps** that would make results hard to interpret. The only idea I’d put into active development first is **Remote Work & Housing Cost Burden**, because the outcome is well-measured in ACS at scale and the policy question is current—though it still needs serious robustness/sensitivity work to be credible. Ideas 2, 3, and 5 should be treated as redesign-or-drop due to treatment/outcome measurement and/or low novelty relative to an already-large literature.