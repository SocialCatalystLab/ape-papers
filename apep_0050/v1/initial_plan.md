# Initial Research Plan: Salary Transparency Laws and Wage Outcomes

**Paper 66**
**Date:** 2026-01-22
**Method:** Difference-in-Differences

---

## Research Question

Do state salary transparency laws—requiring employers to disclose salary ranges in job postings—affect wage levels and gender wage gaps?

---

## Policy Background

Between 2021 and 2025, 13+ U.S. states enacted laws requiring employers to include salary ranges in job postings. This represents a dramatic shift in labor market information disclosure, potentially affecting wage-setting, bargaining, and pay equity.

### Treatment States and Timing

| State | Effective Date | Employer Threshold | Treatment Intensity |
|-------|---------------|-------------------|---------------------|
| Colorado | Jan 1, 2021 | All employers (1+) | High |
| California | Jan 1, 2023 | 15+ employees | High |
| Washington | Jan 1, 2023 | 15+ employees | High |
| New York | Sept 17, 2023 | 4+ employees | High |
| Hawaii | Jan 1, 2024 | 50+ employees | Medium |
| Washington D.C. | June 30, 2024 | All employers | High |
| Maryland | Oct 1, 2024 | All employers | High |
| Illinois | Jan 1, 2025 | 15+ employees | High |
| Minnesota | Jan 1, 2025 | 30+ employees | Medium |
| Vermont | July 1, 2025 | 5+ employees | High |
| Massachusetts | Oct 29, 2025 | 25+ employees | Medium |
| Maine | Jan 1, 2026 | 10+ employees | High |

### Treatment Cohorts for Staggered DiD

- **Cohort 2021:** Colorado
- **Cohort 2023:** California, Washington, New York
- **Cohort 2024:** Hawaii, D.C., Maryland
- **Cohort 2025:** Illinois, Minnesota, Vermont, Massachusetts
- **Cohort 2026+:** Maine, New Jersey, and future adopters

---

## Identification Strategy

### Primary Design: Staggered Difference-in-Differences

We exploit the staggered adoption of salary transparency laws across states using modern heterogeneity-robust DiD estimators.

**Estimator:** Callaway-Sant'Anna (2021) using the `did` R package
- Comparison groups: Not-yet-treated and never-treated states
- Group-time ATT(g,t) aggregated to event study and overall effects

**Alternative estimators for robustness:**
- Sun-Abraham (2021) via `fixest::sunab()`
- Gardner's two-stage (2022) via `did2s`

### Parallel Trends Assumption

The identifying assumption is that treated and control states would have followed parallel wage trends absent the policy. We assess this through:

1. Event study with pre-treatment coefficients
2. HonestDiD sensitivity analysis (Rambachan-Roth bounds)
3. Placebo tests using unaffected outcomes

### Selection Concerns and Mitigation

**Concern:** Progressive states with existing pay equity trends adopt transparency laws.

**Mitigation:**
1. Include time-varying state controls (unemployment rate, minimum wage, industry composition)
2. Conditional parallel trends specification
3. Regional fixed effects to compare within similar economic areas
4. Sensitivity to excluding early adopters (Colorado)

---

## Data Sources

### Primary: IPUMS CPS (Current Population Survey)

**Variables:**
- `EARNWEEK`: Weekly earnings (primary outcome)
- `HOURWAGE`: Hourly wage for hourly workers
- `STATEFIP`: State identifier
- `SEX`: Gender for wage gap analysis
- `AGE`, `EDUC`, `OCC`, `IND`: Controls
- `YEAR`, `MONTH`: Time identifiers
- `EARNWT`: Earnings weight

**Sample:**
- CPS MORG (Merged Outgoing Rotation Groups)
- Years: 2016-2025 (10-year panel)
- Universe: Employed wage/salary workers ages 18-64

### Secondary: ACS PUMS (for robustness)

- Larger sample for state-level precision
- Place of work available (vs. residence in CPS)
- Annual data 2016-2024

---

## Outcome Variables

### Primary Outcomes

1. **Log weekly earnings** (`log(EARNWEEK)`)
   - Standard earnings measure
   - Captures wage level effects

2. **Gender wage gap** (male-female log wage differential)
   - Key policy target
   - Computed as coefficient on female indicator within state-year

### Secondary Outcomes

3. **Wage dispersion** (within-state P90/P10 ratio)
4. **Wage compression** (coefficient of variation)
5. **Job mobility** (recent mover indicator, if available)

---

## Empirical Specification

### Main Specification: Event Study

$$Y_{ist} = \alpha_i + \lambda_t + \sum_{k \neq -1} \beta_k \cdot \mathbf{1}[K_{st} = k] + X_{ist}'\gamma + \varepsilon_{ist}$$

Where:
- $Y_{ist}$: Log earnings for individual $i$ in state $s$ at time $t$
- $\alpha_i$: State fixed effects
- $\lambda_t$: Year fixed effects
- $K_{st}$: Event time (years since treatment) for state $s$
- $X_{ist}$: Individual controls

### Callaway-Sant'Anna Implementation

```r
library(did)
att_gt <- att_gt(
  yname = "log_earn",
  tname = "year",
  idname = "statefip",
  gname = "treatment_year",
  xformla = ~ age + female + educ + occ,
  data = cps_data,
  control_group = "notyettreated",
  clustervars = "statefip"
)
```

### Gender Wage Gap Analysis

For each state-year cell:
$$\ln(W_{ist}) = \alpha_{st} + \beta_{st} \cdot Female_i + X_i'\gamma + \epsilon_{ist}$$

Then use $\beta_{st}$ (gender wage gap) as the outcome in DiD:
$$\beta_{st} = \mu_s + \tau_t + \delta \cdot Treat_{st} + \nu_{st}$$

---

## Robustness Checks

1. **Alternative control groups:** Never-treated only vs. not-yet-treated
2. **Alternative estimators:** Sun-Abraham, Gardner two-stage, de Chaisemartin-D'Haultfoeuille
3. **Pre-trend sensitivity:** HonestDiD bounds with varying smoothness parameters
4. **Sample restrictions:**
   - Exclude Colorado (first mover)
   - Exclude remote-friendly occupations
   - Large employers only (above threshold)
5. **Concurrent policy controls:** State minimum wage, equal pay laws
6. **Placebo outcomes:** Self-employment earnings (should not be affected)

---

## Expected Results

Based on existing Colorado studies and theoretical predictions:

1. **Wage levels:** Modest positive effect (2-5%) as employers compete on transparent wages
2. **Gender wage gap:** Reduction of 10-20% of the pre-treatment gap
3. **Wage compression:** Narrowing within-firm wage dispersion
4. **Heterogeneity:**
   - Larger effects for women, minorities
   - Larger effects in occupations with high wage variance
   - Larger effects in states with stricter enforcement

---

## Threats to Validity

### Internal Validity

1. **Selection into treatment:** Addressed via parallel trends testing
2. **Concurrent policies:** Control for minimum wage, equal pay laws
3. **Spillovers:** Remote workers in non-treated states may see treated job postings
4. **Anticipation:** Employers may adjust before effective dates

### External Validity

1. **Limited post-treatment:** Most states treated 2023-2025
2. **Threshold heterogeneity:** Different employer size cutoffs
3. **Enforcement variation:** Compliance varies by state

---

## Exposure Alignment (Required for DiD)

**Who is actually treated?**
- Workers in states with salary transparency laws
- Job seekers viewing job postings in treated states
- **Limitation:** CPS measures state of residence, not employment location

**Primary estimand population:**
- Employed wage/salary workers ages 18-64
- All industries (laws apply broadly)

**Placebo/control population:**
- Self-employed workers (not affected by posting requirements)
- Workers in never-treated states

**Design:** Standard DiD (not triple-diff)
- Treatment: State passed transparency law
- Control: State has not (yet) passed transparency law

---

## Power Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | 5+ years (2016-2020 for CO; 2016-2022 for 2023 cohort) | **Strong** |
| Treated clusters | 13+ states by end-2025 | **Strong** |
| Post-treatment periods | 4 years for CO (2021-2024); 2 years for 2023 cohort | **Adequate** |
| MDE given sample size | CPS: ~500K workers/year; state-year cells ~10K; MDE ~1% | **Strong** |

---

## Timeline

1. **Data acquisition:** Fetch CPS MORG via IPUMS (1-2 hours)
2. **Data cleaning:** Construct analysis sample, treatment indicators (2 hours)
3. **Main analysis:** Run DiD specifications, event studies (3 hours)
4. **Robustness:** Alternative estimators, placebo tests (3 hours)
5. **Figures and tables:** Publication-quality exhibits (4 hours)
6. **Paper writing:** Full draft with literature review (6 hours)

---

## Key References

- Arnold, D. (2023). "The Impact of Pay Transparency in Job Postings on the Labor Market." Working paper.
- Baker, M., et al. (2019). "Pay Transparency and the Gender Gap." NBER WP 25834.
- Bennedsen, M., et al. (2022). "Do Firms Respond to Gender Pay Gap Transparency?" Journal of Finance.
- Callaway, B. & Sant'Anna, P. (2021). "Difference-in-Differences with Multiple Time Periods." JoE.
- Sun, L. & Abraham, S. (2021). "Estimating Dynamic Treatment Effects." JoE.
- Rambachan, A. & Roth, J. (2023). "A More Credible Approach to Parallel Trends." ReStud.
