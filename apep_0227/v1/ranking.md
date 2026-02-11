# Research Idea Ranking

**Generated:** 2026-02-11T15:24:40.209210
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8488

---

### Rankings

**#1: Fentanyl Test Strip Legalization and Synthetic Opioid Overdose Deaths**
- Score: **76/100**
- Strengths: Very strong outcome measurement (CDC death certificate data) and large staggered rollout with many treated states; outcome-policy linkage is direct and policy-relevant. Modern staggered-adoption methods + placebo mortality outcomes are well-suited here.
- Concerns: **Selection into treatment** is the central threat—states may legalize FTS in response to worsening fentanyl deaths (or broader harm-reduction policy packages), creating differential trends. Also, with only ~5 never-treated states, identification leans heavily on late adopters and functional-form assumptions.
- Novelty Assessment: **Moderately novel**—I’m aware of little causal work; the cited 2025 health-services TWFE paper suggests the topic is emerging, not saturated (and an econ-focused CS-DiD execution would still be valuable).
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Strong** (many years pre-2018 available; you can credibly assess pre-trends)
  - Selection into treatment: **Marginal** (likely policy responds to overdose environment; need strong pre-trends + sensitivity + maybe IV-like arguments or “stacked” DiD robustness)
  - Comparison group: **Marginal** (few never-treated; controls increasingly composed of “not-yet-treated” states close to adoption)
  - Treatment clusters: **Strong** (~40 treated states)
  - Concurrent policies: **Marginal** (naloxone, SSPs, PDMP changes, opioid settlement spending, etc.; must carefully date/control and test robustness)
  - Outcome-Policy Alignment: **Strong** (synthetic-opioid overdose deaths directly capture the harm the policy targets)
  - Data-Outcome Timing: **Marginal** (WONDER is calendar-year deaths; many laws likely effective mid-year—need exposure fractions, effective-date coding, or treat first year as partial/lagged)
  - Outcome Dilution: **Strong** (outcome is deaths among the affected population; not a “whole-population mean” problem)
- Recommendation: **PURSUE (conditional on: (i) tight effective-date coding + partial-year exposure handling; (ii) explicit robustness to differential pre-trends/selection, e.g., HonestDiD + alternative donor pools; (iii) careful concurrent-policy timing controls and sensitivity analyses)**

---

**#2: State IVF Insurance Mandates and Fertility Patterns**
- Score: **64/100**
- Strengths: Excellent, high-quality, long-run administrative outcomes (natality) with clear measurement; strong policy relevance given ongoing mandate expansions. Scope for meaningful heterogeneity (age, parity, multiples) and dynamic (lagged) responses.
- Concerns: The big risk is **outcome dilution** if you study overall birth rates—IVF/ART births are a small share of all births, so effects on aggregate fertility are mechanically tiny and easy to miss. Also, adoption is plausibly correlated with demographics/politics (selection), and timing needs careful lag structure (births respond with ~9–18 month delay).
- Novelty Assessment: **Moderately studied but not exhausted**—classic papers exist on early mandates, but a modern staggered-adoption design incorporating the post-2015/2020 wave and focusing on mechanism-consistent outcomes would still add.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Strong** (ample pre-period for most adopters)
  - Selection into treatment: **Marginal** (likely correlated with income, education, delayed childbearing trends, and political preferences)
  - Comparison group: **Marginal** (mandate states differ systematically; may need reweighting, synthetic controls, or region/income stratification)
  - Treatment clusters: **Marginal** (~16 comprehensive mandate states; borderline for cluster-robust inference)
  - Concurrent policies: **Marginal** (family leave, abortion restrictions, ACA-era coverage changes; not always coincident but must be checked)
  - Outcome-Policy Alignment: **Strong for ART-related outcomes; Marginal for total fertility** (mandates directly affect ART utilization; total birth rates are an indirect target)
  - Data-Outcome Timing: **Marginal** (natality is by birth date; mandates affect conceptions after effective date—requires explicit lags and/or dropping “implementation year” births that are mostly conceived pre-treatment)
  - Outcome Dilution: **Marginal-to-Weak depending on outcome** (IVF births often ~1–3% of births; use outcomes like multiple births, births at 40+, or—best—birth-certificate ART indicators if available in your extract to avoid near-total dilution)
- Recommendation: **CONSIDER (upgrade to PURSUE if you: (i) focus on ART-proximal outcomes—ART indicator, multiples, age 40+ first births; (ii) implement lagged exposure carefully; (iii) use design features to address mandate-state compositional differences, e.g., reweighting/synthetic/event-study diagnostics)**

---

**#3: State Surprise Medical Billing Protections and Emergency Care Utilization**
- Score: **57/100**
- Strengths: Strong policy importance and a compelling institutional endpoint (federal No Surprises Act in 2022) that can be used for “effect disappearance” tests. Multi-state variation pre-2022 is potentially informative.
- Concerns: Data feasibility is the main bottleneck (MEPS too small by state; Medicare claims restricted; HCUP access/coverage varies). Identification is also challenged by **COVID-era shocks to ED utilization** (2020–2021) overlapping with key adoption years and by heterogeneity in state law scope/enforcement.
- Novelty Assessment: **Somewhat novel**—there are papers on specific states/markets; multi-state causal work exists in health-policy circles, but a clean multi-state design is not overdone. Still, it’s not “blank slate” novel.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Marginal** (depends on outcome source; claims/HCUP panels often effectively give ~3–6 clean pre-years once you harmonize)
  - Selection into treatment: **Marginal** (laws may respond to high balance-billing problems; less clearly tied to ED use trends but tied to health market structure)
  - Comparison group: **Marginal** (non-adopting states may differ in insurer/provider market concentration and politics)
  - Treatment clusters: **Marginal** (~18–22 states; borderline)
  - Concurrent policies: **Weak (potential dealbreaker)** if using ED utilization through 2020–2022 without a very explicit COVID strategy (COVID is a massive coincident “policy/environmental shock” directly affecting the outcome; simple DiD will struggle)
  - Outcome-Policy Alignment: **Marginal** (the most aligned outcomes are out-of-pocket payments/surprise bill incidence; ED utilization and premiums are more distal)
  - Data-Outcome Timing: **Strong** if using claims by service date; **Marginal** if using annual aggregates
  - Outcome Dilution: **Marginal-to-Weak** for utilization (only a minority of ED visits generate surprise bills; utilization response likely small); **Stronger** for out-of-pocket/surprise billing incidence outcomes
- Recommendation: **SKIP unless redesigned** (To move to CONSIDER: use outcomes tightly aligned to the policy—surprise-bill incidence/OOP for ED episodes; rely on claims/HCUP with consistent coverage; and pre-register a COVID-handling plan such as excluding 2020–2021, or using differential timing that doesn’t lean on pandemic years.)

---

**#4: The CROWN Act and Black Labor Market Outcomes**
- Score: **55/100**
- Strengths: Extremely high novelty and an important discrimination-policy question; ACS allows rich heterogeneity (occupation/industry/gender) and long pre-period testing.
- Concerns: The likely treatment effect on **state-level employment/earnings** is small and filtered through weak enforcement/low complaint rates—so statistical power and “first-stage intensity” are major issues. Comparison states differ politically and economically, raising differential-trend risk; and ACS timing (surveyed throughout the year) complicates mapping to effective dates.
- Novelty Assessment: **Very high**—I’m not aware of credible causal estimates using policy variation for CROWN laws; most work is legal/descriptive.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Strong** (2005–2018 gives ample pre-period)
  - Selection into treatment: **Marginal** (likely driven by politics/advocacy; could correlate with evolving state-level racial climate and labor-market trends)
  - Comparison group: **Marginal-to-Weak** (never-treated states are often structurally different; you likely need reweighting, border-county designs, or within-occupation comparisons)
  - Treatment clusters: **Strong** (27 states + DC)
  - Concurrent policies: **Marginal** (minimum wage, Ban-the-Box, broader anti-discrimination expansions could coincide)
  - Outcome-Policy Alignment: **Marginal** (employment/earnings are downstream; the most aligned outcomes would be discrimination complaints, hiring audit outcomes, or occupational sorting in appearance-sensitive jobs)
  - Data-Outcome Timing: **Marginal** (ACS outcomes reflect survey timing across the calendar year; laws effective mid-year create partial exposure unless you harmonize by effective date or use 2-year windows)
  - Outcome Dilution: **Marginal-to-Weak** (policy targets a subset of Black workers and a subset of employers/contexts; focusing on “appearance-sensitive occupations” helps, but the affected share is still plausibly well below 50% of the analysis sample)
- Recommendation: **CONSIDER (conditional on: (i) making the primary outcome more mechanism-proximate—occupational sorting in appearance-sensitive jobs rather than overall employment; (ii) strengthening the comparison strategy via reweighting/synthetic/border-county or within-state occupation-based designs; (iii) careful effective-date exposure coding)**

---

**#5: State E-Verify Mandates and Agricultural Labor Markets**
- Score: **45/100**
- Strengths: Clear mechanism (verification increases cost of hiring unauthorized workers), and agricultural focus is sensible given exposure. Some decent data options (QWI/QCEW/USDA) and potential sectoral placebo tests.
- Concerns: The main identification problem is **comparability and clustering**: broad E-Verify mandates are concentrated in specific regions/political regimes, making untreated states a questionable counterfactual. With ~10–15 treated states, inference is fragile and highly sensitive to specification; concurrent immigration enforcement changes are a major confounder.
- Novelty Assessment: **Low-to-moderate**—there is an established literature on E-Verify/immigration enforcement and labor markets; a CS-DiD update is incremental rather than novel.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Strong** (pre-2008 years available)
  - Selection into treatment: **Weak (potential dealbreaker)** (adoption is strongly politically selected and plausibly correlated with anti-immigrant enforcement intensity and labor-market trajectories)
  - Comparison group: **Weak (potential dealbreaker)** (treated states are not close substitutes for typical controls; regional economic structure differs sharply)
  - Treatment clusters: **Marginal** (10–15 treated states)
  - Concurrent policies: **Weak (potential dealbreaker)** (287(g), state immigration laws, enforcement surges, recession-era shocks—often coincident and directly relevant)
  - Outcome-Policy Alignment: **Strong** (ag employment/wages are plausibly directly affected)
  - Data-Outcome Timing: **Strong** if using quarterly/monthly labor market data around effective dates
  - Outcome Dilution: **Strong** if restricting to agriculture (high exposure relative to whole economy)
- Recommendation: **SKIP** (Absent a stronger design—e.g., credible border discontinuity at state lines with county-level outcomes and tight bandwidths—this is very likely to fail the counterfactual/differential-trends test.)

---

### Summary

This is a stronger-than-average batch on policy relevance, but only **Idea 1** looks immediately “fundable” on identification + feasibility. **Idea 5** is promising if you pivot to ART-proximal outcomes and handle timing/lags rigorously. **Ideas 3 and 4** are interesting but currently hinge on redesign (3: COVID/confounding + data; 4: dilution/comparison strategy), while **Idea 4** has the weakest identification environment and is least promising as written.