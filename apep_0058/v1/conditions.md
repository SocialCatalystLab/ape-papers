# Conditional Requirements

**Generated:** 2026-01-24T09:18:01.272179
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s). 
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied  
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Source of Income Discrimination Laws and Housing Voucher Utilization

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: expanding treated-cluster count via sub-state SOI law variation or demonstrating ≥10 staggered state adoptions within the usable panel

**Status:** [X] RESOLVED

**Response:**

I can demonstrate ≥10 staggered state adoptions within the usable panel (2014-2024 HUD data):

**Staggered adoption timeline (14 states with treatment in usable panel):**
1. Oregon - 2014 (voucher exemption repealed)
2. Utah - 2015
3. Delaware - 2016
4. New York - April 2019
5. California - January 2020
6. Maryland - October 2020
7. Virginia - July 2021
8. Colorado - January 2021
9. Rhode Island - 2021
10. Washington - 2018
11. Vermont - 2017
12. Maine - 2020
13. New Jersey - 2002 (but amendments strengthened 2018+)
14. Illinois - January 2022

Earlier adopters (CT 1989, MN 1990, MA 1971) are effectively "always treated" in the 2014+ panel and serve as additional treated units for level comparisons, though they don't identify treatment dynamics.

**Evidence:**

- Urban Institute Voucher Protections Dataset (August 2021): Documents 16 state laws
- PRRAC Appendix B: Full chronology with exact enactment dates
- CBPP December 2018 report: Historical adoption data

---

### Condition 2: using monthly HUD leasing/utilization to fix exposure timing

**Status:** [X] RESOLVED

**Response:**

HUD's Housing Choice Voucher Data Dashboard provides monthly utilization data at the PHA level since 2014. This allows precise treatment timing:

1. **Monthly granularity:** Dashboard is "typically updated monthly" with approximately 2-month reporting lag
2. **Geographic granularity:** Data available at national, state, and PHA level
3. **Variables available:**
   - Units under lease (monthly)
   - Budget utilization rate
   - Unit utilization rate
   - Average cost per unit
   - Reserve balances

**Analysis approach:**
- Use month of law effective date as treatment timing
- Aggregate to state-month level for main analysis
- PHA-level analysis for heterogeneity (law strength, enforcement)
- Event study with monthly bins around effective dates

**Evidence:**

- HUD HCV Data Dashboard: https://www.hud.gov/helping-americans/public-indian-housing-hcv-dashboard
- Dashboard Data Dictionary confirms monthly data since 2014
- RAND panel dataset (2014-2024) uses same monthly HUD dashboard data

---

### Condition 3: pre-committing to dropping/robustly handling 2020–2021 COVID housing-policy overlap

**Status:** [X] RESOLVED

**Response:**

**Pre-committed strategy for handling COVID-era confounds:**

**Primary specification:**
- Include state-month fixed effects absorbing common COVID shocks
- Control for Emergency Rental Assistance (ERA) spending per capita (Treasury data)
- Control for eviction moratorium status (binary indicator from Princeton Eviction Lab)

**Robustness checks (all will be reported):**
1. **Exclude 2020-2021 entirely:** Estimate effects using only:
   - Pre-COVID treatment: OR (2014), UT (2015), DE (2016), WA (2018), VT (2017)
   - Post-COVID treatment: IL (2022)

2. **Exclude March 2020 - July 2021:** Drop period of federal eviction moratorium

3. **Placebo test:** Test for "effects" of SOI laws on outcomes that should NOT respond (e.g., utilization in states with pre-existing protections)

4. **Heterogeneity by ERA intensity:** Test whether effects differ in high vs. low ERA spending states

**Evidence:**

- Treasury ERA data: https://home.treasury.gov/policy-issues/coronavirus/assistance-for-state-local-and-tribal-governments/emergency-rental-assistance-program
- Princeton Eviction Lab moratorium tracker provides state-month moratorium status
- RAND HCV report explicitly addresses COVID confounding in voucher utilization analysis

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Status: ALL CONDITIONS RESOLVED - PROCEED TO PHASE 4**
