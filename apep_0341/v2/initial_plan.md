# Initial Research Plan: apep_0328

## Research Question

When states raise Medicaid reimbursement rates for home and community-based services (HCBS), what is the causal effect on provider participation, capacity, and service volume?

## Policy Context

The American Rescue Plan Act (ARPA) Section 9817, enacted March 2021, provided states with a 10 percentage point increase in the Federal Medical Assistance Percentage (FMAP) for HCBS expenditures from April 2021 through March 2022. States invested the resulting savings (~$37 billion nationally) in HCBS improvements, with provider rate increases being the most common use. Implementation was staggered across states due to variation in CMS approval timing, state legislative cycles, and administrative capacity. Rate increases ranged from modest (5-10%) to dramatic (40-140% for specific services).

## Identification Strategy

**Design:** Staggered difference-in-differences exploiting cross-state variation in the timing of HCBS reimbursement rate increases during 2018-2024.

**Treatment identification:** Data-driven detection of discrete rate changes from T-MSIS. For each state, compute the average paid per claim for personal care HCPCS codes (T1019, S5125) by month. Identify treatment timing as the first month with a ≥15% increase in average payment per claim sustained for ≥3 consecutive months. Validate against documented ARPA spending plan timelines.

**Control group:** States without significant personal care rate increases during the sample period (never-treated). Expected: 10-15 never-treated states (those that used ARPA funds for bonuses, new services, or infrastructure rather than rate increases).

**Estimator:** Callaway and Sant'Anna (2021) heterogeneity-robust staggered DiD. Group-time ATT estimates with never-treated as comparison. Aggregation to overall ATT, dynamic event-study, and group-specific effects.

## Exposure Alignment

**Who is actually treated:** Medicaid personal care providers (billing NPIs) in states that implement sustained reimbursement rate increases of 15% or more. Treatment operates at the state level because Medicaid rate schedules are set by state agencies.

**Primary estimand population:** All personal care billing providers (NPIs) within treated states, measured at the state-month level.

**Placebo/control population:** Personal care billing providers in states without significant rate increases (never-treated); E/M office visit providers in all states (unrelated service placebo).

**Design:** Staggered DiD (not triple-diff). Treatment is a state-level policy change affecting all personal care providers within the state simultaneously.

## Expected Effects and Mechanisms

**Primary mechanism:** Higher reimbursement rates increase provider revenue per service unit, making Medicaid HCBS billing more attractive relative to outside options (Medicare, private pay, non-healthcare employment).

**Expected effects:**
1. Provider participation (extensive margin): Positive — new NPIs enter HCBS billing after rate increases
2. Beneficiaries per provider (intensive margin): Positive — existing providers expand caseloads
3. Service volume: Positive — more claims and more beneficiaries served
4. Provider exit: Negative — fewer NPIs stop billing

**Heterogeneity predictions:**
- Larger effects for individual/sole-proprietor providers (more elastic supply) vs. organizations
- Larger effects in states with larger rate increases (dose-response)
- Larger effects for personal care (T1019) vs. attendant care (S5125) if rates differ

## Primary Specification

$$Y_{st} = \alpha_s + \gamma_t + \beta \cdot \text{RateIncrease}_{st} + X_{st}'\delta + \varepsilon_{st}$$

Where $Y_{st}$ is log provider count (or log beneficiaries, log claims) in state $s$ month $t$. CS-DiD replaces the simple TWFE with group-time ATTs.

**Controls ($X_{st}$):** State population, unemployment rate, Medicaid enrollment (from CMS), log state GDP.

## Planned Robustness Checks

1. **Pre-trend testing:** Event-study plot with ≥12 pre-treatment months showing flat pre-trends
2. **Placebo test on non-HCBS services:** Run identical DiD on CPT E/M codes (99213, 99214) — expect null effect since personal care rate increases shouldn't affect physician office visits
3. **Alternative treatment thresholds:** Vary the rate-jump detection threshold (10%, 20%, 25%)
4. **Dose-response:** Use rate change magnitude as continuous treatment intensity
5. **Heterogeneity:** Individual vs. organizational providers; large vs. small rate increases
6. **Randomization inference:** Fisher permutation test for CS-DiD
7. **Alternative estimator:** Sun and Abraham (2021) interaction-weighted estimator as sensitivity check
8. **Excluding early COVID months:** Drop March 2020-June 2020 to check pandemic onset isn't driving results

## Power Assessment

- Pre-treatment periods: 36 months (Jan 2018 - Dec 2020)
- Treated states: Expected 35-40 states with rate increases
- Never-treated controls: Expected 10-15 states
- Post-treatment per cohort: 12-36 months depending on treatment timing
- Clusters: 50 states + DC
- Expected MDE: ~5-8% change in provider counts (based on similar HCBS DiD designs)

## Data Sources

| Source | Role | Access |
|--------|------|--------|
| T-MSIS (local Parquet) | Outcomes: provider counts, claims, beneficiaries, payments | Local file |
| NPPES (local Parquet) | Geography: state assignment via billing NPI | Local file |
| T-MSIS payment data | Treatment: rate change detection | Derived from T-MSIS |
| Census ACS | Controls: population, demographics | API (key available) |
| FRED | Controls: state unemployment, GDP | API (key available) |
| BLS QCEW | Validation: healthcare employment | Direct CSV download |
