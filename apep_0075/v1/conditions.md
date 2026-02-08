# Conditional Requirements

**Generated:** 2026-01-28T17:46:05.221015
**Status:** RESOLVED

---

## Conditions ADDRESSED - Ready for Phase 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
All conditions have been addressed below.

---

## Minimum Wage Increases and Elderly Worker (65+) Employment

**Rank:** #1 | **Recommendation:** CONSIDER

### Condition 1: focusing on "likely bound" 65+ workers to fix dilution

**Status:** [X] RESOLVED

**Response:**

We will restrict the sample to workers most likely to be affected by minimum wage increases:
1. **Education filter:** High school diploma or less (no college)
2. **Occupation filter:** Service occupations, retail, food service, cleaning/maintenance
3. **Industry filter:** Retail trade, accommodation/food services, administrative support
4. **Wage proxy:** Workers in occupations with median wages < 150% of state minimum wage

This addresses dilution by focusing on the ~15-20% of 65+ workers who are plausibly "at risk" of minimum wage binding, rather than all 65+ workers.

**Evidence:**

Per Pew Research (Dec 2023), older workers are increasingly in minimum-wage-adjacent jobs, particularly in retail and service. BLS data shows ~8-12% of workers 65+ earn hourly wages within $2 of state minimum. By restricting to low-education service workers, we capture the policy-relevant subgroup.

---

### Condition 2: using CPS monthly or interview-month restrictions to fix timing

**Status:** [X] RESOLVED

**Response:**

We will use **CPS Merged Outgoing Rotation Groups (MORG)** which provides:
1. Monthly observations (not annual)
2. Hourly wage data for precise minimum wage exposure classification
3. Employment status at exact interview date

For states with mid-year MW changes (e.g., July 1), we can precisely assign pre/post status based on interview month. This eliminates the ACS interview-month contamination issue.

Alternative specification: Use ACS but define "treatment year" as first full calendar year after effective date (lag treatment by 6-12 months).

**Evidence:**

CPS MORG is the standard data source for minimum wage research (Dube, Lester & Reich 2010; Cengiz et al. 2019). Monthly frequency allows clean treatment timing assignment.

---

### Condition 3: pre-specifying controls/diagnostics for correlated policy bundles

**Status:** [X] RESOLVED

**Response:**

We will pre-specify the following controls and robustness checks:

**State-level policy controls:**
- State EITC presence and generosity
- Medicaid expansion status (post-2014)
- Paid sick leave mandates
- Unemployment insurance generosity

**Pre-specified robustness checks:**
1. Event-study plots showing parallel pre-trends (5+ pre-treatment periods)
2. Bacon decomposition to identify problematic 2x2 comparisons
3. Callaway & Sant'Anna estimator with never-treated comparison
4. Synthetic control method as alternative for individual large-MW-increase events
5. Placebo test on 65+ workers in high-wage occupations (should show null)

**Diagnostics:**
- Test for differential pre-trends in policy controls
- Balance table on observables between treated/control state-years

**Evidence:**

This follows best practices from Goodman-Bacon (2021) and Roth et al. (2023) on DiD with heterogeneous timing. Pre-registration of these checks prevents specification searching.

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Status: RESOLVED - Proceeding to Phase 4**
