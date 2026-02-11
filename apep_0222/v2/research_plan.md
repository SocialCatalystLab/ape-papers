# Initial Research Plan: apep_0221

## Research Question

Do state laws restricting instruction on race, gender, and "divisive concepts" in K-12 schools affect teacher labor market outcomes? Specifically, do these laws increase teacher separations, reduce hiring, lower earnings growth, or alter workforce composition in the education sector?

## Identification Strategy

**Design:** Staggered difference-in-differences (DiD) exploiting variation in the timing of educational content restriction law adoption across 20+ US states from 2021-2023.

**Primary Estimator:** Callaway and Sant'Anna (2021) group-time ATT, which avoids bias from heterogeneous treatment effects and "forbidden comparisons" inherent in TWFE.

**Treatment Definition:** Binary indicator for whether a state has enacted a law restricting classroom instruction on race, gender, or "divisive concepts" in K-12 public schools. Treatment turns on in the quarter the law becomes effective.

**Triple-Difference Extension:** Compare education sector (NAICS 61, treated by laws) vs. healthcare sector (NAICS 62, not directly affected) within the same state-quarter. This differences out state-level confounds including:
- COVID-19 recovery trajectories
- State-level inflation and labor market tightness
- Political lean (conservative states may differ on many dimensions)

**Control Group:** Never-treated states (states that have not enacted divisive concepts legislation through 2024).

## Expected Effects and Mechanisms

**Primary hypothesis:** Content restriction laws increase teacher separations and reduce hiring in treated states by:
1. **Regulatory chill:** Teachers feel constrained and leave for states without restrictions
2. **Deterrent effect:** Prospective teachers choose not to enter the profession or relocate to untreated states
3. **Wage pressure:** States experiencing teacher shortages must raise wages to retain/attract staff

**Alternative hypothesis (null):** Laws have no effect because:
1. Most teachers were not teaching "divisive" content anyway
2. Laws are weakly enforced or vaguely written
3. Other factors (pay, COVID burnout) dominate teacher labor decisions

**Heterogeneity predictions:**
- Larger effects in states with more stringent laws (penalties vs. reporting requirements)
- Larger effects for social studies/humanities teachers than STEM (but QWI doesn't separate by subject)
- Potentially larger effects for younger/newer teachers (less embedded, more mobile)

## Primary Specification

$$Y_{s,t} = \alpha_s + \gamma_t + \sum_g \sum_t \text{ATT}(g,t) \cdot \mathbb{1}[G_s = g] + X_{s,t}\beta + \varepsilon_{s,t}$$

Where:
- $Y_{s,t}$ = outcome (log employment, log earnings, separation rate, hire rate, turnover) for state $s$ in quarter $t$
- $\alpha_s$ = state fixed effects
- $\gamma_t$ = quarter fixed effects
- $G_s$ = treatment cohort (quarter of law enactment)
- $X_{s,t}$ = time-varying state controls (unemployment rate, population)

**Outcomes (from Census QWI, NAICS 61):**
1. Log employment (Emp) — extensive margin
2. Log average monthly earnings (EarnS) — wage effects
3. Separation rate (Sep/Emp) — departures
4. Hire rate (HirA/Emp) — recruitment
5. Turnover rate (TurnOvrS) — overall churn

**Triple-diff outcome:** Education-Healthcare gap in each outcome

## Exposure Alignment (DiD Requirements)

**Who is actually treated?** K-12 teachers and education sector workers in states that enacted divisive concepts laws.

**Primary estimand population:** All education sector workers (NAICS 61) in treated states, post-law-enactment.

**Placebo/control population:** Healthcare workers (NAICS 62) in the same states — affected by same state-level shocks but not by education content laws.

**Design:** Triple-diff (state × time × industry sector)

## Power Assessment

- **Pre-treatment periods:** 24 quarters (2015Q1-2020Q4) = well above 5 threshold
- **Treated clusters:** 20+ states = above 20 threshold
- **Post-treatment periods:** 8-16 quarters per cohort (2021-2024)
- **Unit of observation:** State × quarter × industry
- **Total observations:** ~51 states × 40 quarters × 3 industries ≈ 6,120

## Planned Robustness Checks

1. **Goodman-Bacon (2021) decomposition** of TWFE estimate
2. **Sun and Abraham (2021)** interaction-weighted estimator
3. **Synthetic DiD** (Arkhangelsky et al. 2021) as alternative estimator
4. **Rambachan and Roth (2023)** honest confidence intervals for parallel trends sensitivity
5. **Placebo tests:** Effect on non-education sectors (manufacturing NAICS 31-33, retail NAICS 44-45)
6. **Heterogeneity:** By law stringency (penalty provisions vs. reporting only), by region, by pre-treatment education employment share
7. **Pre-trends test:** Event study with leads and lags (8+ quarters before/after treatment)
8. **Randomization inference:** Fisher permutation test shuffling treatment assignment
