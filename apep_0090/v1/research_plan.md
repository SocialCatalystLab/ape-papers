# Initial Research Plan

## Paper 112: State Data Privacy Laws and Technology Sector Business Formation

**Date:** 2026-01-30
**Status:** Pre-data commitment

---

## Research Question

Do comprehensive state consumer data privacy laws (CCPA-style) reduce or stimulate business formation in data-intensive sectors?

---

## Theoretical Framework

State comprehensive privacy laws impose two countervailing forces on business formation:

**Negative effects (compliance costs):**
- Direct compliance costs: privacy officers, data mapping, consent management
- Legal uncertainty and liability exposure
- Reduced data availability for startups dependent on consumer data

**Positive effects (market expansion):**
- Consumer trust may increase, expanding addressable market
- Privacy-conscious firms may relocate to privacy-law states
- Reputation benefits from operating under strong privacy regime

**Ex ante prediction:** Ambiguous. Compliance costs likely dominate for small startups below coverage thresholds, but larger data-intensive firms may benefit from consumer trust and regulatory clarity.

---

## Identification Strategy

### Primary Design: Staggered DiD (2023+ Wave)

**Treatment:** Effective date of comprehensive state privacy law
- Virginia: January 1, 2023
- Colorado: July 1, 2023
- Connecticut: July 1, 2023
- Utah: December 31, 2023
- Texas: July 1, 2024
- Oregon: July 1, 2024
- Montana: October 1, 2024
- Iowa: January 1, 2025
- Indiana: January 1, 2026 (future)
- Tennessee: July 1, 2025 (future)

**Estimator:** Callaway-Sant'Anna (2021) difference-in-differences
- Handles staggered adoption without "forbidden comparisons"
- Produces group-time ATTs for event-study diagnostics
- Uses never-treated states as comparison group

**Unit of observation:** State × month

**Pre-treatment period:** 2018-2022 (60 months)

**Post-treatment period:** 2023-2025 (as available, ~24 months for early adopters)

### Secondary Design: Synthetic Control Method (California)

California's CCPA (effective January 1, 2020) is confounded by COVID. We use SCM to:
- Construct synthetic California from weighted combination of never-treated states
- Pre-treatment: 2015-2019
- Post-treatment: 2020-2024
- Report gap estimates and placebo tests

---

## Primary Outcome

**High-propensity business applications in Information sector (NAICS 51)**

Source: Census Business Formation Statistics via FRED
Series: `BAHBANAICS51SAXX` (Seasonally adjusted, by state)

This captures new business filings with characteristics predictive of becoming employers:
- Corporate entity applications
- Applications indicating hiring plans
- Applications with planned wages date
- Applications in sectors with high employer transition rates

**Rationale:** Information sector (NAICS 51) includes:
- Publishing industries (511)
- Software publishers (5112)
- Data processing, hosting (518)
- Internet publishing (519)

These are directly affected by data privacy compliance requirements.

---

## Secondary Outcomes

1. **Total business applications in NAICS 51** (less filtered)
2. **QCEW establishment counts in NAICS 51** (actual operating businesses)
3. **QCEW employment in NAICS 51** (intensive margin)

---

## Placebo Tests

1. **Manufacturing (NAICS 31-33):** Should NOT be affected by data privacy laws
2. **Pre-trend coefficients:** Should be zero before treatment
3. **Leave-one-out:** Drop each treated state and re-estimate

---

## Robustness Checks

1. **Alternative pre-period:** Use only 2022 as pre-period (post-COVID)
2. **Alternative estimator:** Sun-Abraham (2021)
3. **Wild cluster bootstrap:** For inference with ~10 treated clusters
4. **Randomization inference:** Exact p-values for few-cluster setting
5. **Covariate adjustment:** Control for state GDP growth, tech employment share

---

## Heterogeneity Analysis

1. **Coverage threshold:** Low (≤25k consumers) vs high (≥100k consumers)
2. **Law strength:** Enforcement provisions, private right of action
3. **Sector:** Software (5112) vs broader Information (51)
4. **Application type:** High-propensity vs all applications

---

## Expected Effects

Based on theory and preliminary evidence from California:
- **Primary outcome:** 5-15% reduction in high-propensity applications in NAICS 51
- **Mechanism:** Compliance cost channel dominates for new entrants
- **Heterogeneity:** Larger effects in states with lower thresholds and stricter enforcement

**Minimum detectable effect (power):**
- With 50 states × 60 months = 3,000 observations
- 10 treated states, average 18 months post-treatment
- MDE ≈ 8-10% with α=0.05, β=0.80

---

## Data Sources

| Variable | Source | Granularity | Years |
|----------|--------|-------------|-------|
| Business applications | FRED/Census BFS | State-month | 2004-2025 |
| QCEW establishments | BLS QCEW | State-quarter | 2005-2024 |
| QCEW employment | BLS QCEW | State-quarter | 2005-2024 |
| State GDP | BEA | State-annual | 2010-2023 |
| Unemployment rate | BLS LAUS | State-month | 2010-2025 |
| Privacy law dates | Bloomberg Law, IAPP | State | 2018-2025 |

---

## Analysis Plan

1. **Descriptive statistics:** Sample means, trends by treatment status
2. **Event study:** Pre-trend visualization
3. **Primary DiD:** Callaway-Sant'Anna ATT(g,t) aggregated to overall ATT
4. **Placebo tests:** Manufacturing sector, pre-treatment coefficients
5. **Robustness:** Alternative estimators, inference methods
6. **Heterogeneity:** By threshold, law strength, sector
7. **California SCM:** Separate analysis for early adopter

---

## Commitment Statement

This plan is committed to git before any data is fetched or analyzed. The primary specification is Callaway-Sant'Anna DiD on high-propensity business applications in NAICS 51. Deviations from this plan will be documented in research_plan.md with justification.
