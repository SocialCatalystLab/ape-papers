# Initial Research Plan: Anti-Cyberbullying Laws and Youth Mental Health

## Research Question

Do state anti-cyberbullying laws reduce youth mental health crises? Specifically, does the staggered adoption of laws requiring schools to address electronic harassment reduce adolescent suicide ideation, suicide attempts, and depressive symptoms?

## Identification Strategy

**Design:** Staggered difference-in-differences using Callaway and Sant'Anna (2021) estimator.

**Treatment:** Year a state first enacted a law that explicitly addresses cyberbullying or electronic harassment in its anti-bullying statute. Treatment is coded relative to YRBS survey fielding (spring of odd-numbered years): a state is treated in YRBS year Y if its law was effective before March of year Y.

**Comparison group:** Not-yet-treated and never-treated states. Alaska and Wisconsin (which never specifically included cyberbullying in their anti-bullying laws as of 2017) serve as pure never-treated units.

**Unit of analysis:** State × YRBS wave (biennial).

## Expected Effects and Mechanisms

**Primary hypothesis:** Anti-cyberbullying laws reduce youth suicide ideation and attempts.

**Mechanisms:**
1. **Deterrence:** Criminal penalties raise the expected cost of cyberbullying
2. **School environment:** Mandated anti-cyberbullying policies create reporting channels and awareness
3. **Norm signaling:** Legislative action signals that electronic harassment is unacceptable

**Expected effect sizes:** Nikolaou (2017) found cyberbullying laws reduce electronic bullying victimization by ~7%. Given baseline suicide ideation of ~17% and cyberbullying's estimated 14.5pp effect on ideation, a 7% reduction in cyberbullying could reduce ideation by ~1pp. We expect small but detectable effects on mental health outcomes, with larger effects for:
- Females (higher cyberbullying victimization and vulnerability)
- States with criminal penalties (stronger deterrence)
- Younger students (more vulnerable to peer effects)

**Null result interpretation:** A credible null would suggest that legislative approaches are insufficient to address technology-mediated harm — an important finding for the current policy debate about social media regulation.

## Primary Specification

$$Y_{st} = \alpha_s + \gamma_t + \beta \cdot \text{CyberbullyingLaw}_{st} + X_{st}'\delta + \varepsilon_{st}$$

Where:
- $Y_{st}$: Outcome (suicide ideation rate, attempt rate, etc.) in state $s$, wave $t$
- $\alpha_s$: State fixed effects
- $\gamma_t$: Wave fixed effects
- $\text{CyberbullyingLaw}_{st}$: Indicator for law in effect
- $X_{st}$: State-level controls (unemployment rate, median income, internet penetration)

**Estimator:** Callaway-Sant'Anna (2021) group-time ATT with not-yet-treated comparison.

## Exposure Alignment (DiD Requirements)

- **Who is treated:** High school students (grades 9–12) in states that adopted anti-cyberbullying laws
- **Primary estimand population:** All high school students surveyed by YRBS in treated states
- **Placebo/control population:** Students in not-yet-treated or never-treated states
- **Design:** Standard staggered DiD (not triple-diff)

## Power Assessment

- **Pre-treatment periods:** 5–8 biennial waves for suicide outcomes (depending on cohort)
- **Treated clusters:** ~48 states with varying adoption years; 20+ distinct treatment cohorts
- **Post-treatment periods:** 1–5 waves per cohort (depending on adoption year)
- **Sample size:** ~40 states × 14 waves × ~1,500 respondents per state-wave = ~840,000 individual-wave observations (though analysis uses state-level aggregates: ~560 state-wave cells)
- **MDE:** With 560 state-wave cells and R² of 0.7 for state/wave FE, MDE for suicide ideation (baseline 17%, SD ~5pp across states) is approximately 1.5pp — plausible given expected effect size

## Planned Robustness Checks

1. **Pre-trend tests:** Callaway-Sant'Anna event study with ≥5 pre-treatment leads
2. **Randomization inference:** Permute treatment assignments 1,000 times for exact p-values
3. **Alternative estimators:** Sun and Abraham (2021), Borusyak et al. (2024)
4. **Treatment timing sensitivity:** Shift law dates ±1 YRBS wave
5. **Law type heterogeneity:** Criminal penalties vs. school-policy-only
6. **Sex-specific estimates:** Female vs. male
7. **Outcome gradient:** Depression → ideation → plan → attempt (severity spectrum)
8. **Spillover to traditional bullying:** Test whether cyberbullying laws also reduced in-person bullying (H23)
9. **Dose-response:** Years since law adoption (dynamic effects)
10. **Bacon decomposition:** Examine which 2×2 DiD comparisons drive the TWFE estimate

## Data Sources

| Source | Variables | Coverage | Access |
|--------|-----------|----------|--------|
| YRBS (CDC Socrata API) | Cyberbullying, suicide, depression, bullying | State × wave, 1991–2017 | Public API |
| NCSL / Cyberbullying Research Center | Law adoption dates, provisions | All 50 states | Published tables |
| Census ACS (tidycensus) | State controls: income, employment, demographics | State × year, 2005–2017 | Public API |
| BLS LAUS | State unemployment rate | State × month | Public API |
