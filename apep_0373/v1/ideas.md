# Research Ideas

## Idea 1: Does Raising the Floor Lift Graduates? Minimum Wage Effects on the College Earnings Distribution

**Policy:** State minimum wage increases above the federal floor. 11 states had effective MW above federal in 2001; 31 by 2019. Staggered adoption with extensive cross-state and over-time variation. Well-documented dates from DOL.

**Outcome:** Census PSEO Time Series — Earnings at the 25th, 50th, and 75th percentiles, measured 1, 5, and 10 years after graduation. Available by degree level, CIP code, and institution. ~500 institutions across 33 states, 7 cohorts (2001-2019), each spanning 3-year graduation windows.

**Identification:** Two-way fixed effects with institution and cohort FEs. Treatment = log state effective minimum wage averaged over the 3-year cohort graduation window. Identification comes from within-institution, across-cohort variation in state MW. Robustness with Callaway-Sant'Anna using a binary "above-median MW increase" treatment. Pre-trends tests using lagged cohort earnings. Heterogeneity by degree level (certificate/associate/bachelor's) and field (CIP 2-digit).

**Why it's novel:** (1) First use of PSEO Time Series for minimum wage research — existing studies use CPS/ACS individual data, not institution-level graduate earnings. (2) Distributional analysis: P25/P50/P75 reveals where in the graduate earnings distribution MW bites. (3) Field-of-study heterogeneity: education and social work graduates (P25 near MW) should respond differently than engineering graduates. (4) Bridges labor econ (MW) and education econ (returns to degrees) literatures.

**Feasibility check:** Confirmed: MW data available 1968-2020 from DOL via Lislejoem dataset. PSEO API returns institution-level panel with P25/P50/P75 earnings across 7 cohorts and 33 states. ~3,500 institution × cohort observations for bachelor's alone; ~27,000 institution × cohort × CIP observations. Minimum wage variation is extensive (11→31 states above federal). Not studied with PSEO data.


## Idea 2: Graduating into the Storm: Recession Scarring by Field of Study

**Policy:** Not a discrete policy but a policy-relevant shock — the Great Recession (2007-2009) hit labor markets differentially across states and fields. State unemployment rates at graduation serve as the "treatment intensity."

**Outcome:** PSEO median earnings at 1, 5, and 10 years by institution × CIP code × cohort.

**Identification:** Cross-cohort comparison: the 2007 cohort (graduated 2007-2009, into the recession) vs. 2004 (pre-recession) and 2010 (early recovery). Within-institution variation by field controls for institution quality. Two-way FE (institution × CIP, cohort).

**Why it's novel:** While recession scarring is well-studied (Oreopoulos et al. 2012, Schwandt & von Wachter 2019), nobody has used PSEO to show field-specific heterogeneity at the institution level. Do STEM graduates scar less than humanities graduates from the same university?

**Feasibility check:** Confirmed: PSEO cohorts 2004, 2007, 2010 bracket the Great Recession. 364 CIP codes at institution level. State unemployment rates from FRED/BLS. Not a clean policy evaluation — more descriptive/reduced-form labor economics.


## Idea 3: State EITC Supplements and Returns to Sub-Baccalaureate Education

**Policy:** 31 states (plus DC) offer state-level EITC supplements on top of the federal credit. Staggered adoption from 1986 (Rhode Island) through 2023 (multiple states). EITC supplements range from 3% to 85% of the federal credit.

**Outcome:** PSEO certificate and associate degree earnings at P25/P50/P75, 1 and 5 years post-graduation.

**Identification:** Staggered DiD with state and cohort FEs. Treatment = state adopts EITC supplement. Control = states without supplements. CS estimator for heterogeneous treatment effects.

**Why it's novel:** (1) EITC literature focuses on labor supply, not on returns to education. (2) State EITCs change the effective post-tax earnings premium to sub-baccalaureate degrees. (3) PSEO uniquely measures pre-tax earnings at percentiles, allowing us to test whether EITC supplements affect gross earnings (through labor supply) differently at P25 vs P50.

**Feasibility check:** Partially confirmed: EITC adoption dates well-documented (Tax Policy Center, CBPP). PSEO has associate/certificate data for 29 states across 4 cohorts (2001, 2006, 2011, 2016). Concern: only 4 cohorts may limit DiD power. Need to verify overlap between PSEO-covered states and EITC-adopting states.


## Idea 4: The Gainful Employment Threat: Did Accountability Pressure Improve For-Profit Outcomes?

**Policy:** The Obama administration's 2014 Gainful Employment (GE) rule established earnings thresholds for federal financial aid eligibility. Programs failing debt-to-earnings tests risked losing Title IV access. Rescinded 2019 under Trump, reinstated 2023 under Biden.

**Outcome:** PSEO earnings for certificate and associate degree programs, comparing institutions near vs. far from GE thresholds.

**Identification:** Regression kink/threshold design: compare programs just above vs. just below the earnings threshold. Also, interrupted time series around the 2014 adoption and 2019 repeal.

**Why it's novel:** PSEO allows tracking earnings trajectories for specific programs at specific institutions, which is exactly what the GE rule targets. Can directly measure whether "threatened" programs improved outcomes.

**Feasibility check:** Partially confirmed: PSEO has institution-level earnings by degree and CIP. Challenge: identifying which institutions are for-profit in the PSEO data (institution codes map to IPEDS UNITID, which has sector classification). Also, GE thresholds apply to program-level debt, which PSEO doesn't have — we'd need to merge with College Scorecard. Only 2 PSEO cohorts post-2014 (2016, 2019). Limited statistical power.


## Idea 5: State Higher Education Appropriations and Graduate Earnings

**Policy:** State appropriations per student to public higher education declined sharply after the Great Recession, with large cross-state variation. SHEEO's State Higher Education Finance (SHEF) data tracks these annually.

**Outcome:** PSEO bachelor's degree earnings at P25/P50/P75 by institution and cohort.

**Identification:** Two-way FE (institution, cohort) with continuous treatment = log state appropriations per FTE. Instrument: state fiscal shocks (revenue declines) that predict appropriation cuts but don't directly affect graduate earnings.

**Why it's novel:** Most research on higher ed funding focuses on enrollment and completion. PSEO allows testing whether funding cuts affect the earnings quality of graduates — through mechanisms like larger class sizes, fewer course offerings, or reduced career services.

**Feasibility check:** Confirmed: SHEF data publicly available from SHEEO. PSEO institution-level data matches well. ~500 public institutions across 7 cohorts. Concern: state fiscal shocks may correlate with labor market conditions that independently affect earnings. Need strong instrument.
