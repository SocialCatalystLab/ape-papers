# Research Idea Ranking

**Generated:** 2026-01-26T03:17:33.471974
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 9887
**OpenAI Response ID:** resp_09fb238c6fd461d1006976ce41c428819595ccea3ccbf6071c

---

### Rankings

**#1: State Occupational Heat Protection Standards and Worker Safety Outcomes**
- **Score: 68/100**
- **Strengths:** Outcome is tightly linked to the policy mechanism (heat exposure → heat illness/fatality), and the topic is timely with a recent wave of adoptions beyond California. Administrative outcomes (CFOI; some workers’ comp systems) are plausibly high signal relative to many social policy outcomes.
- **Concerns:** Treated-state count is very small, making standard DiD inference fragile; several effective dates are mid-year, so annual outcomes risk partial-exposure attenuation. Heat outcomes are rare and sometimes suppressed/underreported, risking power and measurement error.
- **Novelty Assessment:** **High.** California has been examined, but credible multi-state causal evidence on the newer rules (OR/CO/WA revision/MD) is thin to nonexistent.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (for CA and WA; many years available pre-rule; even for OR/CO you have multiple pre-years).
  - **Selection into treatment:** **Marginal** (adoption likely correlated with heat risk, outdoor workforce composition, and possibly rising trend in heat incidents).
  - **Comparison group:** **Strong** (large set of never-treated states; can also restrict to high-heat states as more credible controls).
  - **Treatment clusters:** **Weak** (<10 treated states; main statistical/inference vulnerability).
  - **Concurrent policies:** **Marginal** (changing OSHA emphasis, wildfire smoke rules in some states, and broader climate adaptation could co-move with outcomes).
  - **Outcome-Policy Alignment:** **Strong if** you use **heat-coded** injuries/fatalities (CFOI “environmental heat” events; workers’ comp heat ICD/event codes). **Weak if** you use all-cause injuries/fatalities (policy is too targeted).
  - **Data-Outcome Timing:** **Marginal.** Many rules start **mid-year** (e.g., OR **June 15, 2022**; WA revision **July 17, 2023**; MD **Sept 2024**), while CFOI/SOII are typically **annual**. “First treated year” has ~0.5 year exposure mechanically attenuating effects; you should define treatment as the **first full calendar year** after effective date or use higher-frequency admin claims where feasible.
  - **Outcome Dilution:** **Strong if** outcome is restricted to heat events (≈100% “affected” by definition). **Weak if** using broad injury rates (heat cases are <<10% of all injuries).
- **Recommendation:** **PURSUE (conditional on: (i) focusing on heat-coded outcomes only; (ii) using methods designed for few treated clusters—e.g., state-by-state synthetic control / augmented SCM with randomization inference, or stacked DiD with wild cluster bootstrap and transparent sensitivity; (iii) defining treatment to ensure full-year exposure).**

---

**#2: State Child Labor Law Weakening and Youth Employment Outcomes**
- **Score: 62/100**
- **Strengths:** Very current policy change with clear effective dates; CPS microdata enables directly relevant outcomes (teen employment, hours, school enrollment) and allows relatively precise timing (monthly). The question is policy-relevant amid rising enforcement actions and public concern.
- **Concerns:** Only ~5–6 treated states (inference fragility) and treatment is politically selected (states differ systematically), making parallel trends questionable. Post-treatment window is extremely short for most states, and state law changes may matter only at the margin because federal child labor standards bind in many dimensions.
- **Novelty Assessment:** **High.** There is descriptive work and limited narrow-case analysis, but little to no peer-reviewed causal evidence on this **recent wave** of weakening.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (CPS/ACS allow many pre-years before 2022–2024 changes).
  - **Selection into treatment:** **Marginal to Weak** (policy adoption is plausibly correlated with labor shortages, political shifts, enforcement posture, and teen work trends).
  - **Comparison group:** **Marginal** (never-treated states may be systematically different; border-state or matched comparisons likely needed).
  - **Treatment clusters:** **Weak** (<10 treated states).
  - **Concurrent policies:** **Marginal** (minimum wage changes, school attendance policies, EITC changes, and DOL enforcement intensity could move outcomes).
  - **Outcome-Policy Alignment:** **Strong** for CPS teen employment/hours and school enrollment (policy changes constraints on teen work/hours). **Weak/Marginal** for workplace injuries given limited age granularity and underreporting.
  - **Data-Outcome Timing:** **Strong** if using **monthly CPS** and coding treatment onset by month of legal effect (many laws are effective mid-year; monthly data can align exposure).
  - **Outcome Dilution:** **Strong** if the analysis sample is **teens (14–17)** (population directly eligible). For injuries, dilution arises because only working teens are exposed, but employment itself is a primary outcome.
- **Recommendation:** **CONSIDER (conditional on: (i) designing a credible comparison—border-state / matched controls, and/or triple-diff using adjacent age groups 18–19 as a placebo-type comparison; (ii) committing to inference robust to few clusters; (iii) focusing on outcomes with clean measurement in CPS).**

---

**#3: State Universal Free School Meals and Child Food Security**
- **Score: 58/100**
- **Strengths:** High policy relevance and clear mechanism; outcomes (child/household food security, attendance) are directly connected to free meals. Multiple adopting states (≈9) creates meaningful staggered variation relative to many single-state education policies.
- **Concerns:** The COVID-era federal universal meal waivers (roughly 2020–June 2022) severely complicate baselines and “pre-trends.” Key outcome (CPS Food Security Supplement) has **12-month recall**, creating partial-exposure timing problems for school-year policies unless treatment timing is handled carefully.
- **Novelty Assessment:** **Moderate.** CEP and pandemic-era meal expansions are heavily studied; statewide universal meal laws are newer and less studied, but not completely untouched (at least some recent DiD work exists).
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal to Weak** (you *have* pre-2020 years, but 2020–2022 is a major structural break; excluding those years reduces usable pre-periods close to adoption).
  - **Selection into treatment:** **Marginal** (early adopters are largely Democratic states with broader anti-poverty expansions).
  - **Comparison group:** **Marginal** (non-adopters differ politically and in school nutrition baselines; matching on pre-policy CEP coverage is important).
  - **Treatment clusters:** **Weak** (≈9 treated states; still <10).
  - **Concurrent policies:** **Weak** without careful design (end of federal waivers **June 2022** coincides with the first state adoptions; also other post-pandemic benefit changes, e.g., SNAP emergency allotments ending in many states in 2023).
  - **Outcome-Policy Alignment:** **Strong** for child food security and meal participation; **Marginal** for test scores (many channels; longer horizon).
  - **Data-Outcome Timing:** **Weak** if using CPS-FSS naively. CPS-FSS is typically fielded in **December** and asks about the **prior 12 months**; for a policy beginning with the **Aug/Sep school year**, the first “post” survey contains mostly pre-treatment months (mechanical attenuation). You’d need to define the first fully-exposed outcome window (e.g., use the **second** December after adoption, or alternative data with shorter recall such as Household Pulse-style measures / admin participation).
  - **Outcome Dilution:** **Marginal** (policy affects public-school students; CPS households with children include private/homeschooled and very young kids unless you restrict to enrolled K–12).
- **Recommendation:** **SKIP (as currently framed)** unless redesigned around timing/confounding: **PURSUE only if** you (i) restrict to outcomes with correct exposure windows (or use higher-frequency/administrative data), and (ii) explicitly handle the June 2022 waiver cliff (e.g., exclude/segment COVID years; use designs leveraging cross-district baseline CEP intensity within adopting states).

---

**#4: State Eviction Record Sealing Laws and Housing Stability**
- **Score: 45/100**
- **Strengths:** Big policy interest and many adopting jurisdictions (good staggered variation). If one could measure outcomes for the directly affected population (people with eviction records), this would be highly informative.
- **Concerns:** As proposed, outcomes are largely **too aggregated/indirect** relative to the mechanism; most measures (ACS mobility, PIT homelessness) will be heavily diluted and confounded by concurrent housing policies (especially around COVID). Also, eviction filing data can be mechanically affected by sealing (measurement changes), making it risky as an “outcome.”
- **Novelty Assessment:** **Very high** on credible causal evaluation (most existing work is descriptive/legal), though eviction and tenant screening broadly are well studied.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (early adopters from 2016 allow long pre-periods).
  - **Selection into treatment:** **Marginal to Weak** (likely adopted in response to housing stress/eviction conditions and political environment).
  - **Comparison group:** **Marginal** (non-adopting states may differ systematically; policy bundles likely).
  - **Treatment clusters:** **Strong** (≈20+).
  - **Concurrent policies:** **Weak** (eviction moratoria, emergency rental assistance, court backlogs, and tenant-rights expansions coincide in 2020–2022 and beyond).
  - **Outcome-Policy Alignment:** **Weak** with ACS/PIT outcomes. Sealing affects **screening visibility**; the clean outcome is something like rental application acceptance/lease-up rates for those with eviction histories, or screening report content—none are directly measured here.
  - **Data-Outcome Timing:** **Marginal** (ACS is annual; policy effective dates vary; timing can be managed, but not the main issue).
  - **Outcome Dilution:** **Weak** (share directly affected—people with eviction records— is a small fraction of the state population; state homelessness/mobility averages will dilute impacts far below detectability).
- **Recommendation:** **SKIP** unless you can secure **micro data** that observes affected individuals (court microdata linked to address/tenancy outcomes, tenant screening dataset, or a partner landlord/property-manager panel) and cleanly separate sealing from COVID-era shocks.

---

**#5: State Junk Fee / Drip Pricing Laws and Consumer Outcomes**
- **Score: 25/100**
- **Strengths:** Extremely new and salient; strong consumer-protection relevance; potentially large welfare implications if measurable.
- **Concerns:** As proposed, there is no clearly feasible dataset that observes the core mechanism (advertised vs. all-in prices) at scale, and there is essentially no post-treatment time for most states. With only 1–2 early treated states and short post windows, DiD is not credible.
- **Novelty Assessment:** **Very high**, but primarily because the policy is too new for standard evaluation with public data.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (years of pre exist).
  - **Selection into treatment:** **Marginal/Unknown** (too new; likely correlated with consumer-protection orientation).
  - **Comparison group:** **Strong** (many non-adopting states).
  - **Treatment clusters:** **Weak** (only a couple of states with meaningful post periods).
  - **Concurrent policies:** **Marginal to Weak** (FTC actions and sector-specific changes may coincide).
  - **Outcome-Policy Alignment:** **Weak** with CPI/complaints as primary outcomes; the policy targets *advertising and fee disclosure*, not necessarily overall price levels in CPI.
  - **Data-Outcome Timing:** **Weak** (CA effective **July 1, 2024**; minimal full-year exposure in most outcomes as of now; other states effective 2025–2026).
  - **Outcome Dilution:** **Marginal to Weak** (policy affects specific sectors; broad consumer indices/complaints dilute effects unless sector-specific transaction/scraped pricing data are obtained).
- **Recommendation:** **SKIP** for now; reconsider if you can assemble sector-specific price-scrape/transaction datasets and have ≥2 years post for multiple treated states.

---

### Summary

This is a high-novelty batch, but most ideas run into classic DiD failure modes: too few treated clusters (Ideas 1, 3, 5), major timing/exposure mismatches (Idea 5), or outcome-policy mismatch and dilution (Idea 2). The best near-term project is **Heat Protection Standards** if redesigned around heat-coded outcomes and few-cluster inference; **Child Labor Weakening** is next if the comparison design is strengthened. Ideas **2 and 4** are conceptually important but should be treated as **data-acquisition projects** first (micro outcomes for the affected population) rather than immediate DiD papers.