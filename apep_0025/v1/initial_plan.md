# Initial Research Plan — Paper 32

**Created:** 2026-01-18
**Status:** LOCKED (do not modify after commit)

---

## Title

**Early Retirement and the Reallocation of Time: Evidence from Social Security Eligibility at Age 62**

---

## Research Question

How do Americans reallocate their daily time across activities—including work, caregiving, household production, leisure, and sleep—when they become eligible for Social Security early retirement benefits at age 62?

---

## Motivation

At age 62, Americans become eligible to claim Social Security retirement benefits for the first time. Approximately 31% of all Americans begin claiming in their first month of eligibility, and the age-62 threshold marks the single largest discontinuity in labor force exit across the lifecycle. This behavioral response is well-documented in terms of labor supply and earnings.

However, we know remarkably little about *what people do* with their time after leaving work. The 8+ hours per day previously spent on market work must go somewhere—but where? Does it flow to:
- Active leisure (exercise, social activities) that may improve health?
- Passive leisure (television, relaxation) that may harm health?
- Caregiving for grandchildren or elderly parents?
- Household production (cooking, home maintenance)?
- Extended sleep?

These questions matter for several policy-relevant reasons:
1. **Health:** Prior RDD research finds that mortality *increases* at age 62, suggesting retirement may have negative health effects. Understanding time reallocation could illuminate the mechanism.
2. **Caregiving:** Newly retired individuals may take on intergenerational care roles, substituting for formal childcare or eldercare.
3. **Well-being:** The subjective experience of retirement depends not just on income, but on how time is spent.

---

## Identification Strategy

### Running Variable
Age at interview (measured in years; will approximate age in months using interview timing)

### Cutoff
Age 62 (first month of Social Security early retirement eligibility)

### Design
**Fuzzy Regression Discontinuity Design**

The age 62 threshold creates a discontinuous *increase* in the probability of:
- Claiming Social Security benefits
- Exiting the labor force
- Reducing work hours

This is a fuzzy RD because not all 62-year-olds claim/retire, and some 61-year-olds may already have reduced work. The cutoff serves as an instrumental variable for retirement status.

### Validity of the Design

**As-good-as-random assignment:** People cannot choose their birthdate. Age is determined before any policy decisions are made. Conditional on reaching near-62, whether someone has just turned 62 vs. will turn 62 next month is as-good-as-random.

**No manipulation:** Unlike income thresholds or test score cutoffs, birthdates cannot be manipulated. The McCrary density test for bunching is irrelevant.

**Balance tests:** I will verify that pre-determined characteristics (education, race, marital status) do not jump discontinuously at age 62.

### Data Limitation & Mitigation

**Limitation:** ATUS public data provides age in years only, not months.

**Mitigation strategies:**
1. Use interview month to bound birth month (e.g., if interviewed in March at age 62, birthday is April-March of prior year)
2. Conduct coarse RD comparing age 61 vs. 62 or 61 vs. 63
3. Report robustness to bandwidth selection (ages 60-64, 59-65, etc.)
4. Acknowledge limitation transparently; interpret as average effect across the year of turning 62

---

## Data Sources

### Primary Data
**American Time Use Survey (ATUS), 2003-2023**
- Universe: ~26,000 respondents/year, nationally representative
- Age range for study: 55-70 (allowing RD bandwidth flexibility)
- Key variables: 24-hour time diary with 400+ activity codes, interview month

### Secondary Data
1. **ATUS-CPS Linked Files** — Demographics, labor force status, earnings, education
2. **ATUS Well-being Module (2010, 2012, 2013, 2021)** — Experiential well-being during activities
3. **SSA Annual Statistical Supplement** — Aggregate claiming patterns by age (for first-stage validation)

### Novel Regulatory Data
**CMS Medicare Current Beneficiary Survey (MCBS) Summary Tables** — To characterize health insurance transitions around age 62 as a potential mechanism

---

## Outcome Variables

### Primary Outcomes (minutes per day)
1. Paid work and work-related activities
2. Household activities (cooking, cleaning, maintenance, shopping)
3. Caring for household members (childcare, eldercare)
4. Caring for non-household members (grandchildren, aging parents)
5. Leisure and sports (total)
   - Active leisure (exercise, sports, outdoor recreation)
   - Passive leisure (television, relaxation)
   - Social leisure (socializing, attending events)
6. Sleep
7. Personal care
8. Travel

### Secondary Outcomes
- Number of different activity types per day (variety)
- Time alone vs. with others
- Time at home vs. away from home

### Well-being Outcomes (subset with WB module)
- Happiness during activities
- Stress during activities
- Fatigue/tiredness during activities

---

## Empirical Specification

### First Stage (Retirement)
```
Retired_i = α + β₁(Age ≥ 62)_i + f(Age_i) + X_i'γ + ε_i
```

### Reduced Form (Time Use)
```
Minutes_ij = δ + θ₁(Age ≥ 62)_i + g(Age_i) + X_i'λ + η_ij
```

where:
- `i` indexes individuals
- `j` indexes activity categories
- `f(·)` and `g(·)` are polynomials in age (or local linear)
- `X_i` includes pre-determined controls (education, race, sex, marital status, calendar year, interview month)

### Fuzzy RD (2SLS)
```
Minutes_ij = π + ψRetired̂_i + h(Age_i) + X_i'φ + ν_ij
```

---

## Expected Results

Based on literature on retirement and time use (mostly non-causal), I expect:

1. **Work time** decreases sharply (mechanical—this is the treatment)
2. **Passive leisure** increases substantially (prior research suggests TV is major absorber of freed time)
3. **Sleep** increases modestly (0.5-1 hour)
4. **Household production** increases moderately
5. **Caregiving** may increase, especially for grandparents
6. **Active leisure** uncertain—could increase (more free time) or decrease (less income/structure)

**Heterogeneity to explore:**
- By education (high vs. low)
- By gender
- By marital status
- By prior occupation type

---

## Timeline

| Phase | Description |
|-------|-------------|
| Data acquisition | Download ATUS 2003-2023 from IPUMS |
| Sample construction | Restrict to ages 55-70, merge with CPS |
| Descriptive analysis | Time use by age, plotting discontinuities |
| First stage estimation | Retirement/claiming at 62 |
| Main RDD estimation | Time use outcomes |
| Robustness checks | Bandwidth, polynomials, placebo cutoffs |
| Well-being analysis | Subset with WB module |
| Paper writing | Full manuscript |

---

## Risks and Contingencies

| Risk | Mitigation |
|------|------------|
| Age-in-years too coarse | Use interview month, wide bandwidths, interpret as year-average |
| Weak first stage | Document retirement/claiming jump from SSA data; proceed with reduced-form ITT |
| Small sample at specific ages | Pool multiple years (20 years × ~2,000 per age = ~40,000 per year of age) |
| Pre-trends/imbalance | Balance tests on demographics; placebo tests at ages 60, 61, 63, 64 |

---

## Contribution

This paper will provide the first causally-identified estimates of how newly eligible retirees reallocate their daily time. While prior work documents labor supply effects, no study systematically examines the full 24-hour time budget using RDD. Understanding time reallocation:
1. Illuminates mechanisms behind retirement-mortality findings
2. Informs policy on retirement timing incentives
3. Quantifies informal care supply from new retirees
4. Adds experiential well-being dimension to retirement research

---

## Pre-registration Statement

This plan is committed to git before any data analysis. The commit hash serves as the pre-registration timestamp. Deviations from this plan will be documented in `research_plan.md` and justified in the final paper.
