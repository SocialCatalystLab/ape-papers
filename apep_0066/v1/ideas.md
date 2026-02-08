# Research Ideas

## Idea 1: Paid Family Leave and Female Entrepreneurship

**Policy:** State Paid Family Leave (PFL) programs with staggered adoption:
- California: Benefits began 2004
- New Jersey: Benefits began 2009
- Rhode Island: Benefits began 2014
- New York: Benefits began 2018
- Washington: Benefits began 2020
- DC: Benefits began 2020
- Massachusetts: Benefits began 2021
- Connecticut: Benefits began 2022
- Oregon: Benefits began 2023
- Colorado: Benefits began 2024

**Outcome:** Female self-employment rates from Census ACS (Table B24080: Sex by Class of Worker)

**Identification:** Staggered Difference-in-Differences comparing self-employment rates in PFL states vs. never-treated states before and after policy adoption. Can use Callaway-Sant'Anna estimator to handle heterogeneous treatment timing.

**Why it's novel:**
- Bailey et al. (2019, NBER) examined CA's PFL effect on self-employment *income* and found no effect, but they:
  1. Only studied California (limited statistical power)
  2. Used self-employment income, not employment status
  3. Had limited post-treatment periods
- New angle: Study *transitions into self-employment* as a measure of entrepreneurship, leveraging 10+ states with PFL and 15+ years of post-treatment data for CA
- Recent paper in Journal of Human Resources (2024) found positive effects of maternity leave on female entrepreneurship in Belgium - this would be the first US causal evidence
- Theory: PFL reduces "entrepreneurship lock" - people may avoid self-employment because it means losing employer-provided benefits; PFL provides a safety net

**Feasibility check:**
- ✓ Variation exists: Clear staggered adoption across 10+ states, 2004-2024
- ✓ Data accessible: Census ACS 1-year estimates available via API from 2005-present, tested successfully
- ✓ Not overstudied: Bailey et al. is the only US causal study, and they found null results with limited data; this is a genuine gap
- ✓ Pre-periods: California has no pre-period (2004 adoption, ACS starts 2005), but NJ has 4 years pre (2005-2008), RI has 9 years pre, NY has 13 years pre, etc.

**Potential concerns:**
- CA adoption (2004) predates ACS data start (2005), so no CA pre-treatment period
- Small state (RI) may have noisy estimates
- Need to control for other state-level policies affecting entrepreneurship

---

## Idea 2: Right-to-Work Laws and Workplace Fatalities (Backup)

**Policy:** Recent Right-to-Work (RTW) law adoptions:
- Indiana: 2012
- Michigan: 2013 (repealed 2024)
- Wisconsin: 2015
- West Virginia: 2016
- Kentucky: 2017

**Outcome:** BLS Census of Fatal Occupational Injuries (CFOI) state-level fatality counts/rates

**Identification:** Staggered DiD comparing workplace fatality rates in newly-RTW states vs. never-RTW or always-RTW states.

**Why it's novel:**
- Zoorob (2018) used IV approach (RTW as instrument for unionization) and found RTW increases fatalities
- Novel: Clean DiD with recent adoptions provides stronger causal identification
- Michigan's 2024 repeal offers potential for studying repeal effects

**Feasibility check:**
- ✓ Variation exists: 5 recent adoptions + 1 repeal
- ? Data accessible: BLS blocks automated API access; need to download Excel files manually or find alternative
- ✗ Already studied: Zoorob (2018) has addressed the causal question with IV

**Status: BACKUP** - Data access uncertain, less novel than Idea 1

---

## Idea 3: Certificate of Need Repeal and Rural Healthcare Access (Backup)

**Policy:** Recent CON law reforms:
- Florida: Immediate repeal of several CON types (2019), phased hospital CON repeal (2021)
- Montana: Full repeal (2021)
- South Carolina: Partial repeal (2023)
- North Carolina: Phased repeal (2023-2025)
- Tennessee: Phased repeal (2024-2027)

**Outcome:** Healthcare facility counts, rural hospital closures, healthcare employment from QCEW

**Identification:** Staggered DiD comparing healthcare infrastructure in states that reformed CON vs. those that retained CON.

**Why it's novel:**
- Prior research focuses on long-run CON effects comparing always-CON vs. never-CON states
- Novel: Exploit recent reforms as natural experiments
- Focus on rural healthcare access specifically

**Feasibility check:**
- ✓ Variation exists: Recent staggered reforms in 5+ states
- ? Data accessible: Healthcare facility data may require specialized sources
- △ Moderate novelty: CON effects are studied, but recent reforms provide fresh variation

**Status: BACKUP** - Potentially good variation, but data sources uncertain and recent reforms may have limited post-treatment periods
