# Research Idea Ranking

**Generated:** 2026-01-24T09:37:10.438602
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 9684
**OpenAI Response ID:** resp_075d2cbaffa45f010069748439d3148193981efe0552d927ff

---

### Rankings

**#1: Dental Therapy Authorization and Oral Health Access (Idea 1)**
- **Score:** 78/100  
- **Strengths:** High novelty with a policy actively under consideration in many states; outcomes (dental visit, tooth loss) are directly policy-relevant and available in large, free datasets with long pre-periods. Treated vs. never-treated variation is substantial, making modern staggered-adoption DiD feasible.  
- **Concerns:** Authorization is not the same as meaningful deployment—effects may be small early on and concentrated in a subset of counties/populations (dilution). Key threat is policy endogeneity (adoption in response to access problems) and confounding from Medicaid adult dental benefit changes or other oral-health initiatives.  
- **Novelty Assessment:** **High.** Mostly descriptive/qualitative evidence exists; I’m not aware of a large quasi-experimental DiD literature directly estimating population access effects of dental therapist authorization across states.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (BRFSS available well before 2009; many pre-years)
  - **Selection into treatment:** **Marginal** (likely responds to shortages/advocacy; must probe pre-trends and political/instrumental predictors)
  - **Comparison group:** **Strong** (many never-treated and not-yet-treated states)
  - **Treatment clusters:** **Marginal** (≈14 treated states → inference OK but not ideal)
  - **Concurrent policies:** **Marginal** (Medicaid dental benefit changes, ACA-era shifts, scope changes for hygienists; must control/stratify)
  - **Outcome-Policy Alignment:** **Strong** (BRFSS “dental visit in past 12 months” is a direct utilization/access measure plausibly affected by provider supply)
  - **Data-Outcome Timing:** **Marginal** (BRFSS is fielded throughout the year; “past 12 months” recall window straddles pre/post if the law is mid-year—need exposure definitions using effective dates + interview month, or treat first “full exposure” year as \(t+1\))
  - **Outcome Dilution:** **Marginal** (initially, dental therapists likely serve a small share of total adults; mitigate by focusing on Medicaid/low-income, rural, HPSA counties, or outcomes more sensitive to underserved groups)
- **Recommendation:** **PURSUE (conditional on: (i) coding exact effective/implementation dates and aligning BRFSS interview month to exposure windows; (ii) explicit controls/strata for Medicaid adult dental benefits and major oral-health initiatives; (iii) heterogeneity analyses where dilution is minimized—low-income/rural/HPSA).**

---

**#2: Optometrist Laser Authority Expansion and Eye Care Access (Idea 3)**
- **Score:** 66/100  
- **Strengths:** Conceptually tight mechanism-to-outcome link if using claims-based laser procedure measures, and Medicare claims provide high-frequency, behaviorally precise outcomes (not self-report). This is plausibly more novel than many generic scope-of-practice papers because the procedures (YAG/SLT/LPI) are specific and measurable.  
- **Concerns:** Treated-state count is only ~11, and adoption is plausibly driven by lobbying and local access constraints. Biggest risk is **detecting “access” using total procedure rates**: expansion may mainly reallocate procedures from ophthalmologists to optometrists (composition) rather than increase total volume (so the “access” interpretation can fail).  
- **Novelty Assessment:** **Moderate-High.** There is a literature on optometrist scope expansions and provider licensing/competition, but laser-procedure-specific utilization effects using claims are less saturated.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (depends on claims availability window; for KY-2011 you need several pre-years—if only post-2012 public files are used, pre-trends become a dealbreaker)
  - **Selection into treatment:** **Marginal** (endogenous policy timing; must show flat pre-trends in procedure rates)
  - **Comparison group:** **Strong** (many non-expansion states)
  - **Treatment clusters:** **Marginal** (≈11 treated → OK but inference fragile; requires careful SEs and sensitivity)
  - **Concurrent policies:** **Marginal** (other eye-care scope expansions/telehealth/payment changes; less obviously coincident than ACA-type shocks)
  - **Outcome-Policy Alignment:** **Strong** *if measured correctly* (claims-based YAG/SLT/LPI volumes and—critically—share performed by optometrists is tightly linked to the permission change)
  - **Data-Outcome Timing:** **Strong** (service dates in claims; can define post precisely around effective dates)
  - **Outcome Dilution:** **Marginal** (if outcome is *total* state procedure rate, effects may be small; mitigate by using optometrist-performed counts/share, rural beneficiaries, and “access margin” outcomes like travel distance if feasible)
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: you can access multi-year pre-2011 claims and you pivot the main outcome to optometrist-performed procedure share/availability rather than only total rates).**

---

**#3: Dental Therapist Authorization and Dental Practice Entry (Idea 5)**
- **Score:** 61/100  
- **Strengths:** Data are clean, long-run, and objective (BDS/CBP), with many pre-periods and transparent measurement. This is an appealing complementary/supply-side lens to Idea 1 and could strengthen a broader dental therapy paper.  
- **Concerns:** **Outcome-policy alignment is not tight**: dental therapists typically work within dental practices and under supervision; authorization may expand capacity without creating new “Offices of Dentists” establishments. County-level measurement is also vulnerable to suppression/noise in CBP, and state-level aggregation risks dilution if effects occur only in shortage areas.  
- **Novelty Assessment:** **Moderate.** Dental therapy itself is novel, but “policy → establishment entry” using CBP/BDS is a common empirical template; this is best as part of a multi-outcome package rather than a standalone claim about access.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (BDS/CBP long panels pre-2009)
  - **Selection into treatment:** **Marginal** (same endogeneity as Idea 1)
  - **Comparison group:** **Strong** (many never-treated states)
  - **Treatment clusters:** **Marginal** (≈14 treated)
  - **Concurrent policies:** **Marginal** (Medicaid dental changes; workforce rules for hygienists; provider pipeline initiatives)
  - **Outcome-Policy Alignment:** **Marginal** (authorization expands *labor mix* more than it directly incentivizes *new dentist establishments*)
  - **Data-Outcome Timing:** **Strong** (annual business counts; can align to effective dates reasonably)
  - **Outcome Dilution:** **Marginal** (effects likely concentrated in underserved counties; state totals dilute—prefer county/HPSA strata where feasible)
- **Recommendation:** **CONSIDER (best as a secondary/robustness outcome bundled with Idea 1, not as the flagship question).**

---

**#4: Interstate Medical Licensure Compact and Physician Supply (Idea 2)**
- **Score:** 48/100  
- **Strengths:** Very high policy salience and many treated states, with rich county-level physician supply data (AHRF) and potential to study underserved areas.  
- **Concerns:** The central identification/problem is conceptual: the IMLC primarily reduces licensing friction for multi-state practice; it may not change **headcount physician supply per capita** in a measurable way (strong risk of dilution and outcome mismatch). Also, the staggered timing overlaps with COVID-era telehealth shocks and licensure waivers, complicating attribution.  
- **Novelty Assessment:** **Low-Moderate.** Not identical to “universal license recognition,” but the broader “licensing portability/compacts → workforce” space is fairly studied, and the IMLC has been discussed extensively in policy and some empirical work.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (long pre-period available)
  - **Selection into treatment:** **Marginal** (politics + workforce needs; must show no differential pre-trends)
  - **Comparison group:** **Marginal** (few never-treated states, but many not-yet-treated exist early; requires careful cohort/time trimming)
  - **Treatment clusters:** **Strong** (>>20 treated)
  - **Concurrent policies:** **Marginal-to-Weak** (COVID telehealth/payment/licensure waivers coincide with key adoption years; excluding 2020–2021 may be necessary)
  - **Outcome-Policy Alignment:** **Marginal** (compact affects licensing friction, not physician production/relocation; better outcomes would be IMLC license counts, cross-state practice, or telehealth visit flows)
  - **Data-Outcome Timing:** **Strong** (annual supply measures)
  - **Outcome Dilution:** **Weak** (IMLC users are a small fraction of physicians; expected effect on total physicians per capita likely <10% of the measured outcome variation)
- **Recommendation:** **SKIP (unless redesigned around aligned outcomes—e.g., IMLC license issuance, cross-state telemedicine claims, or border-county service patterns—and with a plan to handle COVID-era confounding explicitly).**

---

**#5: Direct Primary Care “Not Insurance” Laws and Healthcare Access (Idea 4)**
- **Score:** 35/100  
- **Strengths:** Interesting and politically relevant institutional change; many adopting states provide nominal policy variation.  
- **Concerns:** This fails on core DiD validity in practice: heavy confounding with ACA Medicaid expansions/market reforms, and **extreme dilution** because DPC enrollment is typically far below 10% of the population. The law enables a business model but does not mechanically expand access at the population level, making nulls hard to interpret.  
- **Novelty Assessment:** **Moderate.** DPC is discussed in health policy, but credible causal population-level evaluations using state laws are scarce—largely because the design is weak, not because the question is untouched.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (early adopters around 2010)
  - **Selection into treatment:** **Marginal** (ideology-driven; correlated with other health policy choices)
  - **Comparison group:** **Marginal** (non-adopters exist but differ systematically)
  - **Treatment clusters:** **Strong** (≈26 treated)
  - **Concurrent policies:** **Weak** (ACA-era Medicaid/Marketplace changes coincide with much adoption and directly affect access/ED use)
  - **Outcome-Policy Alignment:** **Marginal-to-Weak** (a regulatory carve-out does not directly translate to statewide access; effects operate through small uptake)
  - **Data-Outcome Timing:** **Marginal** (BRFSS “past 12 months” and HCUP annualization can blur partial exposure)
  - **Outcome Dilution:** **Weak** (DPC patients likely <1–2% of population in most states)
- **Recommendation:** **SKIP.**

---

### Summary
This is a better-than-average batch: **Idea 1** is the clear first project because it combines unusually high novelty with feasible data and a plausible DiD setup, though it must solve **BRFSS exposure timing** and **dilution** via subgroup/event-time design. **Ideas 3 and 5** are plausible extensions (3 as a procedure-specific scope-of-practice study; 5 as a complementary supply-side outcome), while **Ideas 2 and 4** have major interpretability problems driven by **outcome mismatch/dilution** and (for DPC) **severe concurrent-policy confounding**.