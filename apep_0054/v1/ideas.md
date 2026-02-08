# Research Ideas: Salary Transparency Laws and Wage Outcomes

## Executive Summary

This document evaluates the feasibility of studying state salary transparency laws—requiring employers to disclose salary ranges in job postings—and their effects on wage levels and gender wage gaps. The policy wave from 2021-2025 provides a natural experiment with staggered adoption across 15+ states.

---

## Policy Background

### What Are Salary Transparency Laws?

State laws requiring employers to disclose salary ranges in job postings. Key requirements typically include:
- Posting salary ranges (minimum and maximum) in job advertisements
- Applicable to positions performed in the state (including remote work)
- Employer size thresholds vary (1-50+ employees)
- Penalties for non-compliance ($1,000-$10,000 per violation)

### Staggered Adoption Timeline (2021-2025)

| State | Effective Date | Employer Threshold | Notes |
|-------|----------------|-------------------|-------|
| Colorado | Jan 1, 2021 | All employers | First mover; amended Jan 2024 |
| Connecticut | Oct 1, 2021 | 1+ employees | Upon request initially, posting 2022 |
| Nevada | Oct 1, 2021 | All employers | After interview disclosure |
| Rhode Island | Jan 1, 2023 | 1+ employees | Upon request |
| California | Jan 1, 2023 | 15+ employees | Major labor market |
| Washington | Jan 1, 2023 | 15+ employees | Pacific Northwest |
| New York | Sep 17, 2023 | 4+ employees | Largest labor market |
| Hawaii | Jan 1, 2024 | 50+ employees | Higher threshold |
| Maryland | Oct 1, 2024 | All employers | Updated law |
| Illinois | Jan 1, 2025 | 15+ employees | Midwest adoption |
| Minnesota | Jan 1, 2025 | 30+ employees | Higher threshold |
| New Jersey | Jun 1, 2025 | 10+ employees | Northeast expansion |
| Massachusetts | Jul 31, 2025 | 25+ employees | Major labor market |
| Vermont | Jul 1, 2025 | 5+ employees | Small state |

**Never-treated states (as of 2025):** Texas, Florida, Georgia, North Carolina, Ohio, Pennsylvania, Arizona, Indiana, Tennessee, Missouri, Wisconsin, Virginia, and most Southern/Midwestern states.

---

## Idea 1: Effect of Salary Transparency Laws on Wage Levels and Gender Wage Gaps

**Research Question:** Do state salary transparency laws requiring salary range disclosure in job postings affect (a) overall wage levels and (b) the gender wage gap?

### Policy
- **Treatment:** State salary transparency laws requiring salary range disclosure in job postings
- **Treated units:** 14+ states with effective dates between 2021-2025
- **Treatment timing:** Staggered adoption from January 2021 (Colorado) through July 2025 (Massachusetts)
- **Never-treated:** ~35 states without transparency requirements as of 2025

### Outcome Data
- **Source:** IPUMS CPS ASEC (Annual Social and Economic Supplement)
- **Variables:**
  - INCWAGE (annual wage/salary income)
  - SEX (gender)
  - OCC (detailed occupation)
  - IND (industry)
  - STATEFIP (state)
  - AGE, EDUC (demographics)
  - UHRSWORKLY (usual hours worked)
- **Time coverage:** 2018-2024 (7 years: 3 pre-treatment for early adopters, sufficient post-period)
- **Sample:** Working-age adults (25-64), wage/salary workers

### Identification Strategy: Staggered DiD

**Design:** Compare wage outcomes in treated vs. untreated states before and after law adoption, using modern heterogeneity-robust estimators.

**Estimator:** Callaway-Sant'Anna (2021) group-time ATT, aggregated to dynamic event-study coefficients. Sun-Abraham (2021) as robustness.

**Key specifications:**
1. Overall wage levels (log hourly wages)
2. Gender wage gap (female coefficient in pooled regression, or male-female wage differential)
3. Heterogeneity by occupation (high vs. low bargaining power)
4. Heterogeneity by industry (high vs. low unionization)

### DiD Early Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| **Pre-treatment periods** | 3-4 years before 2021 (earliest treatment); 2018-2020 data available | **Strong** (≥3 years) |
| **Selection into treatment** | Blue states adopted first; may correlate with labor market trends. However, timing within 2021-2025 window is plausibly exogenous given political/legislative timing | **Marginal** |
| **Comparison group** | 35+ never-treated states provide large control group; some are demographically similar (e.g., Pennsylvania vs New York) | **Strong** |
| **Treatment clusters** | 14+ treated states, 35+ control states = 50+ clusters | **Strong** (≥20) |
| **Concurrent policies** | Minimum wage increases, COVID recovery policies. Can control for state minimum wage; COVID affects all states | **Marginal** |
| **Outcome-Policy Alignment** | CPS ASEC INCWAGE directly measures wage/salary income; transparency laws directly affect wages through bargaining/posting | **Strong** |

**Overall assessment:** PROCEED with attention to selection and concurrent policy controls.

### Conceptual Framework

Building on Cullen & Pakzad-Hurson (2023), transparency affects wages through multiple channels:

1. **Information disclosure:** Workers learn market rates, improving outside options
2. **Bargaining power:** Employers can credibly commit to posted ranges, potentially reducing worker bargaining power
3. **Wage posting vs. bargaining:** Laws shift firms from negotiated to posted wages
4. **Sorting:** High-wage seekers may sort to transparent markets
5. **Employer competition:** Cross-firm transparency may intensify wage competition
6. **Gender-specific effects:** Women may benefit more if they previously had less salary information

**Predictions:**
- Overall wages: Ambiguous (↓ from reduced bargaining, ↑ from information)
- Gender gap: Likely narrows (women gain more from information)
- High-bargaining occupations: Larger wage decline
- Unionized sectors: Muted effects (already have collective bargaining)

### Why Novel

- **Timing:** 2021-2025 policy wave is recent; few empirical evaluations exist
- **Scope:** First comprehensive DiD using all states with modern robust estimators
- **Mechanisms:** Tests Cullen's theoretical predictions with U.S. data
- **Gender focus:** Direct test of pay equity claims motivating these laws

### Feasibility Confirmation

✓ **Policy dates verified:** Multiple sources confirm state adoption timeline
✓ **Data accessible:** IPUMS CPS ASEC available via API; API key confirmed
✓ **Variation exists:** 14+ treated states with staggered timing, 35+ controls
✓ **Sample size:** CPS ASEC has ~95,000 working-age adults per year × 7 years = 650,000+ observations
✓ **Not overstudied:** No APEP papers on this topic; Google Scholar shows few causal evaluations

---

## Idea 2: Salary Transparency and Occupational Wage Compression

**Research Question:** Do salary transparency laws compress wages within occupations (reduce dispersion)?

**Rationale:** Posted salary ranges may reduce within-occupation wage variance as firms standardize offers.

**Additional outcome:** Coefficient of variation of wages within state×occupation×year cells.

**Assessment:** This is a secondary analysis that can be done with the same data. Include as robustness/mechanism.

---

## Idea 3: Effect on Job Posting Behavior (Alternative Data)

**Research Question:** Do transparency laws change how employers post wages?

**Data alternative:** Indeed, Glassdoor, or LinkedIn job posting data (would require commercial access).

**Assessment:** SKIP for now—CPS wage data is more accessible and directly measures worker outcomes. Job posting data would be valuable complement but not primary.

---

## Recommended Approach

**Primary focus:** Idea 1 (wage levels and gender wage gap)
- Use IPUMS CPS ASEC 2018-2024
- Staggered DiD with Callaway-Sant'Anna estimator
- Event study for parallel trends validation
- Heterogeneity by gender, occupation, industry
- Build on Cullen's theoretical framework

**Secondary analyses:**
- Wage compression within occupations
- Heterogeneity by state characteristics (unionization, minimum wage)
- Sensitivity to employer size thresholds
