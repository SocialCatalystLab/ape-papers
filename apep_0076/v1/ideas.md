# Research Ideas for Paper 105

**Initialization:** DiD methodology, Modern data, Novel angle (classic policy + classic data + new question/method/theory/mechanism)

---

## Idea 1: Salary History Bans and the Wage Penalty for Job Stayers

**Policy:** State salary history bans (SHBs) prohibit employers from asking about prior compensation. Massachusetts enacted the first state-level SHB in 2016 (effective 2018), followed by ~19 states by 2024 (CA, DE, CT, HI, IL, ME, MD, NV, NJ, NY, OR, VT, WA, CO, RI, etc.).

**Outcome:** Wage growth for job stayers vs. job changers, using CPS MORG data (2014-2024).

**Identification:** Callaway-Sant'Anna DiD with staggered adoption. Treatment: State enacts SHB. Unit: State-year-quarter. Compare wage dynamics in treated vs. never-treated states.

**Novel Angle:** Existing research (Hansen & McNichols 2020; Barach & Horton 2021) focuses on wage gains for job changers. We examine the **spillover effect on job stayers**: do SHBs compress wage distributions and reduce the "wage premium" for switching jobs? Theory predicts SHBs increase employer uncertainty about outside options, potentially raising wages for incumbent workers too. This is a testable mechanism that hasn't been directly examined.

**Feasibility Check:**
- CPS MORG: Available through 2024, includes state identifiers, earnings, job tenure, and matched observations 12 months apart (via MORG rotation)
- Policy dates: Well-documented at NCSL and in academic papers
- Sample size: ~60,000 households/month in CPS; MORG extracts ~15,000/month
- Not overstudied: Only a few papers on SHBs; none examining job stayer spillovers specifically

---

## Idea 2: State EITC Generosity and Property Crime by Type

**Policy:** State-level Earned Income Tax Credits supplement the federal EITC. Currently 31 states + DC have state EITCs, with staggered adoption from 1988 (WI) through 2024. Generosity varies from 3% to 85% of federal credit.

**Outcome:** Property crime rates disaggregated by type—burglary, larceny-theft, motor vehicle theft—using FBI Uniform Crime Reports (1999-2023).

**Identification:** TWFE DiD with state and year fixed effects. Treatment: Continuous measure of state EITC generosity (% of federal credit). Robustness: Binary treatment at EITC adoption.

**Novel Angle:** Existing research (Lenhart 2021) found state EITCs reduce violent crime but have **null effects on property crime overall**. We dig deeper: different property crime types have different decision processes. Burglary is planned, larceny often opportunistic, motor vehicle theft requires specific skills. Income effects from EITC disbursement may affect these differentially. We also examine **monthly timing** around EITC disbursement (Feb-Apr) vs. rest of year.

**Feasibility Check:**
- FBI UCR data: Available via Crime Data API (cde.ucr.cjis.gov), state-level annual data 1960-2023
- EITC adoption dates: Well-documented (Tax Policy Center, NCSL)
- Monthly crime data: Available in UCR for timing analysis
- Sample: ~50 states × 25 years = 1,250 state-years
- Not overstudied by APEP: Only apep_0049 on EITC (focused on employment, not crime)

---

## Idea 3: Paid Sick Leave Mandates and Worker Turnover

**Policy:** State and major city paid sick leave (PSL) mandates. Connecticut (2011) was first, followed by CA (2014), MA (2015), OR (2016), AZ (2017), WA (2018), NJ (2018), MD (2018), RI (2018), NV (2020), CO (2021), NM (2022), NY (expanded 2021). Currently 15+ states mandate PSL.

**Outcome:** Worker job tenure and turnover rates using CPS ASEC data (2010-2024), supplemented by JOLTS state-level data.

**Identification:** Callaway-Sant'Anna DiD with staggered adoption. Treatment: State enacts mandatory PSL. Compare job tenure distributions and separation rates in treated vs. control states.

**Novel Angle:** Existing PSL research focuses on **health outcomes** (reduced presenteeism, flu transmission) or **business outcomes** (productivity, profitability). We examine **labor market dynamics**: does PSL reduce voluntary turnover by increasing job quality? Or does it enable job switching by reducing health-related job lock? The direction is theoretically ambiguous and empirically understudied. We decompose separations into quits vs. layoffs.

**Feasibility Check:**
- CPS ASEC: Annual data with job tenure, state identifiers, industry codes
- JOLTS: State-level separations data (2000-present)
- Policy dates: Well-documented (A Better Balance, NCSL)
- Sample: 15+ treated states, staggered adoption 2011-2022
- Not overstudied: No APEP paper on PSL turnover; limited academic literature

---

## Idea 4: Predictive Scheduling Laws and Worker Well-Being

**Policy:** Oregon's Fair Workweek Act (2018) is the only statewide predictive scheduling law, requiring 14-day advance notice, rest between shifts, and compensation for schedule changes. Applies to retail, hospitality, and food service with 500+ employees.

**Outcome:** Worker-reported measures from CPS: hours worked, hours variability, multiple job holding, and (via ASEC supplement) health insurance coverage.

**Identification:** Synthetic control method for Oregon vs. donor pool of similar states. Event study around July 2018 implementation.

**Novel Angle:** Predictive scheduling has been debated extensively but **rarely evaluated empirically at scale**. Most evidence is qualitative or from single-city studies. Oregon provides the first statewide natural experiment. We focus on whether scheduling stability translates to measurable labor market improvements: stable hours → ability to take second jobs? → access to employer health insurance?

**Feasibility Check:**
- CPS: Hours worked, usual hours, multiple job holding available monthly by state
- Treatment: Single-state treatment limits power; synthetic control appropriate
- Timing: 2018 adoption provides 6 years of post-period
- Weakness: Oregon-only limits generalizability; may be underpowered

---

## Ranking Assessment

| Idea | Novelty | Identification | Feasibility | Overall |
|------|---------|---------------|-------------|---------|
| 1. SHB Job Stayers | High | Strong | High | **PURSUE** |
| 2. State EITC Property Crime | Medium-High | Strong | High | **PURSUE** |
| 3. PSL Turnover | Medium | Strong | High | **CONSIDER** |
| 4. Predictive Scheduling | High | Moderate (single state) | Medium | **CONSIDER** |

**Recommendation:** Ideas 1 and 2 are strongest candidates. Idea 1 offers cleaner identification with staggered adoption across 19 states and a novel mechanism (job stayer spillovers). Idea 2 builds on a puzzle in existing literature (why no property crime effect?) with better data and timing analysis.
