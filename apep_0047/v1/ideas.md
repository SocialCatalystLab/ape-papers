# Paper 64: Research Ideas

**Topic:** MeToo-Era Policy Responses and Gender Outcomes
**Method:** Difference-in-Differences
**Created:** 2026-01-21

---

## Executive Summary

The #MeToo movement (October 2017) triggered a wave of state-level policy responses aimed at reducing workplace sexual harassment. However, emerging evidence suggests these policies may have **unintended consequences**: men report increased discomfort working with women, and some research finds harassment training actually makes men more defensive and accepting of harassment behavior.

This paper asks: **Do well-intentioned anti-harassment policies backfire, harming the women they're designed to protect?**

---

## Idea 1: Sexual Harassment Training Mandates and Female Labor Market Outcomes

### Research Question
Do state mandates requiring sexual harassment prevention training reduce female employment, hiring, or management representation through backlash effects?

### Conceptual Framework
Training mandates may backfire through several channels:
1. **Defensive backlash**: Research shows training makes men who score high on "likely harasser" scales *more* accepting of harassment (Patel & Wolfe, PNAS 2019)
2. **Avoidance behavior**: 60% of male managers report discomfort working alone with women post-#MeToo (Lean In Survey)
3. **Liability concerns**: Firms may reduce female hiring to minimize perceived legal exposure
4. **Mentorship withdrawal**: 27% of men avoid one-on-one meetings with women; 21% hesitate to hire women for jobs requiring close interaction (Atwater, U Houston)

### Policy Details

| State | Effective Date | Coverage | Requirements |
|-------|---------------|----------|--------------|
| New York | Oct 9, 2018 | All employers (1+ employees) | Annual interactive training |
| Delaware | Jan 1, 2019 | 50+ employees | Training within 1 year of hire |
| Illinois | Jan 1, 2019 | All employers | Annual training |
| Maine | Oct 15, 2019 | 15+ employees | Training within 1 year |
| Connecticut | Oct 1, 2019 | All employers | Supervisors + employees |
| California | Jan 1, 2020 | 5+ employees | 2hr supervisors, 1hr all |

**Control group:** 44 states without mandates as of 2020

### DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | **Strong** | 12+ quarters (2014-2017) |
| Selection into treatment | **Moderate** | Blue states adopted first; control for political lean |
| Comparison group quality | **Strong** | 44 never-treated states |
| Cluster count | **Moderate** | 6 treated + 44 control = 50 clusters |
| Concurrent policies | **Moderate** | Control for state minimum wage, paid leave |
| Outcome-policy alignment | **Strong** | QWI directly measures hiring/employment by gender |

---

## Idea 2: #MeToo Movement and Female Labor Market Outcomes — A Triple-Difference Approach (RECOMMENDED)

### Research Question
Did the #MeToo movement (October 2017) differentially affect female employment in industries with historically high harassment rates?

### Conceptual Framework
The "Pence Rule" hypothesis: After #MeToo, men in high-harassment-risk industries may avoid women to minimize personal liability risk. This should show up as:
- Reduced female hiring in historically high-harassment industries
- Decreased female management representation
- Potentially increased female exits

### Identification Strategy
**Triple-difference:**
- High vs. low harassment industries (from EEOC charge data or ILO surveys)
- Pre vs. post October 2017
- Female vs. male employment/hiring

This avoids state-cluster concerns entirely by exploiting industry variation.

### Data
- **Employment:** QWI by state × industry × quarter × gender
- **Harassment rates:** EEOC sexual harassment charges by industry (2010-2016 baseline)
- **Alternative:** ILO survey data on harassment prevalence by industry

### Pre-classified High-Harassment Industries (EEOC data)
- Accommodation & Food Services (NAICS 72)
- Retail Trade (NAICS 44-45)
- Health Care (NAICS 62)
- Manufacturing (NAICS 31-33)

### DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | **Strong** | Q1 2014 - Q3 2017 (15 quarters) |
| Selection into treatment | **Strong** | MeToo timing exogenous to industry employment trends |
| Comparison group quality | **Strong** | Low-harassment industries as control |
| Cluster count | **Strong** | Industry × state clusters = hundreds |
| Concurrent policies | **Moderate** | MeToo coincided with strong economy |
| Outcome-policy alignment | **Strong** | QWI measures employment/hiring by industry-gender |

---

## Idea 3: NDA Limitation Laws and Sexual Harassment Reporting

### Research Question
Do state laws limiting non-disclosure agreements for harassment settlements increase EEOC complaint filings or female employment?

### DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | **Strong** | 20+ years of EEOC data |
| Selection into treatment | **Moderate** | Blue states first |
| Comparison group quality | **Strong** | 45 never-treated states |
| Cluster count | **Weak** | Only 5 treated states |
| Concurrent policies | **Weak** | Coincides with training mandates |
| Outcome-policy alignment | **Strong** | EEOC data is direct measure |

**Recommendation:** SKIP (cluster concerns)

---

## Idea 4: State Pay Transparency Laws and Gender Wage Gap

### Research Question
Do state laws requiring salary range disclosure in job postings reduce the gender wage gap?

### DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | **Strong** | 2015-2020 |
| Cluster count | **Weak** | 5 treated states |
| Outcome-policy alignment | **Marginal** | Effects may take years |

**Recommendation:** DEFER (limited post-period)

---

## Idea 5: #MeToo and Women's Occupational Sorting

### Research Question
Did #MeToo cause women to sort away from male-dominated occupations?

**Recommendation:** SKIP (slow-moving, weak identification)

---

## Ranking Summary

| Idea | Novelty | Feasibility | Recommendation |
|------|---------|-------------|----------------|
| 2. MeToo Triple-Diff | **High** | **High** | **PURSUE** |
| 1. Training Mandates | High | Moderate | CONSIDER |
| 4. Pay Transparency | Medium | Low | DEFER |
| 3. NDA Laws | Medium | Low | SKIP |
| 5. Occupational Sorting | Medium | Low | SKIP |

**Primary recommendation:** Idea 2 (MeToo Triple-Diff) — strongest identification, avoids cluster concerns.
