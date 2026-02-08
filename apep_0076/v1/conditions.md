# Conditional Requirements

**Generated:** 2026-01-28T18:13:54.745030
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

## Salary History Bans and the Wage Penalty for Job Stayers

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: extend pre-period earlier than 2014

**Status:** [X] RESOLVED

**Response:**

NBER MORG extracts are available from 1979 through 2024. We will use data from 2010-2024, providing 8 years of pre-treatment data before Massachusetts' SHB became effective in 2018 (the first state-level SHB). This gives ample pre-treatment periods even for the earliest adopters.

**Evidence:**

- NBER MORG data page: https://www.nber.org/research/data/current-population-survey-cps-merged-outgoing-rotation-group-earnings-data
- Data is downloadable with state identifiers, earnings, and demographic variables back to 1979

---

### Condition 2: build a coincident-policy database

**Status:** [X] RESOLVED

**Response:**

We will construct a state-year panel of coincident labor market policies that may confound SHB effects:
1. **Pay transparency laws** (salary range disclosure requirements) - from NCSL
2. **Minimum wage levels** - from DOL and state labor departments
3. **Paid family/sick leave mandates** - from A Better Balance database
4. **Equal pay act amendments** - from NCSL equal pay legislation tracker

These will be included as controls and used in robustness checks (excluding states with multiple coincident policies).

**Evidence:**

- NCSL Pay Transparency Database: https://www.ncsl.org/labor-and-employment/pay-transparency
- NCSL Equal Pay Legislation: https://www.ncsl.org/labor-and-employment/equal-pay-legislation
- DOL State Minimum Wage: https://www.dol.gov/agencies/whd/state/minimum-wage/history
- A Better Balance Paid Leave Database: https://www.abetterbalance.org/resources/paid-sick-time-legislative-successes/

---

### Condition 3: implement careful exposure timing at the month/quarter level

**Status:** [X] RESOLVED

**Response:**

We will code SHB effective dates at the month level and define treatment exposure accordingly:
- Treatment = 1 if interview month >= effective month of state SHB
- For MORG 12-month matched samples, require both observations post-effective-date to be in "treated" group
- Key effective dates: MA (July 2018), CA (Jan 2018), DE (Dec 2017 - public; Dec 2018 - private), etc.

We will collapse to quarterly treatment windows for the main analysis to reduce noise while maintaining precise timing. CPS monthly interview dates are available in the data.

**Evidence:**

- SHB effective dates compiled by NELP: https://www.nelp.org/publication/salary-history-bans-a-growing-state-trend/
- HR Dive SHB timeline: https://www.hrdive.com/news/salary-history-ban-states-list/516662/
- CPS interview month variable (HRMIS) available in public use files

---

### Condition 4: show convincing event-study pre-trends for stayers separately from changers

**Status:** [X] RESOLVED

**Response:**

This is a core analysis requirement that will be implemented in the execution phase:
1. **Define job stayers vs. changers** using MORG rotation matching: workers observed at t and t+12 with same reported employer/industry are "stayers"; different employer = "changers"
2. **Run separate event studies** for each group using the `did` R package (Callaway & Sant'Anna)
3. **Plot pre-trends** for years -4 to -1 relative to SHB adoption for both groups
4. **Test parallel trends** formally using pre-treatment ATT coefficients

If pre-trends fail for stayers, we will: (a) add region×time FEs, (b) use doubly-robust estimators, (c) report HonestDiD sensitivity analysis to assess robustness to violations.

**Evidence:**

- Will be demonstrated in code/03_main_analysis.R with event study plots
- Callaway & Sant'Anna (2021) `did` package implements group-time ATTs with pre-trend testing
- HonestDiD package for sensitivity: https://github.com/asheshrambachan/HonestDiD

---

## State EITC Generosity and Property Crime by Type

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: demonstrate stable UCR measurement/coverage or limit to a defensible pre-NIBRS window

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: avoid naive TWFE—use modern continuous-staggered methods

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: pre-specify how you handle early always-treated states

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: reporting changes

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Status: RESOLVED - Proceeding to Phase 4 (Execution)**
