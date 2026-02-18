# Initial Research Plan: Medicaid Postpartum Coverage Extensions and Maternal Health Provider Supply

## Research Question

Do state Medicaid postpartum coverage extensions from 60 days to 12 months increase maternal health provider participation in Medicaid? Specifically, does the policy increase (1) the number of providers billing for postpartum services, (2) the volume of postpartum care claims, and (3) contraceptive service utilization in the extended postpartum window?

## Background

The American Rescue Plan Act (March 2021) gave states the option to extend Medicaid postpartum coverage from 60 days to 12 months. Between October 2021 and early 2025, 48 states + DC adopted this extension through SPAs or 1115 waivers, with only Arkansas and Wisconsin declining. Adoption was staggered: ~20 states on April 1, 2022 (first available date), with the remainder spread across 2022-2025.

Existing research focuses on enrollment and health outcomes (demand side). This paper examines the supply side: whether extending coverage induces more providers to serve Medicaid postpartum patients. The answer is not obvious — Medicaid reimbursement rates are typically below commercial rates, so longer coverage windows might not overcome existing barriers to provider participation.

## Identification Strategy

**Staggered Difference-in-Differences** using the Callaway & Sant'Anna (2021) estimator.

- **Treatment:** State s extends Medicaid postpartum coverage to 12 months at time t_s
- **Unit of analysis:** State × month panel
- **Control group:** Not-yet-treated states + never-treated (AR, WI)
- **Estimator:** CS-DiD with doubly robust estimation, aggregated to group-time ATTs

### Exposure Alignment

- **Who is treated:** Maternal health providers in states that extend postpartum coverage — specifically OB/GYNs, midwives, and contraceptive service providers who bill Medicaid
- **Primary estimand population:** OB/GYN providers (NPPES taxonomy 207V) billing Medicaid in the state
- **Placebo/control population:** (1) Antepartum care providers (same providers, prenatal codes unaffected by extension); (2) Non-OB/GYN Medicaid providers (unrelated specialty)
- **Design:** DiD with placebo outcome validation

### Power Assessment

- **Pre-treatment periods:** 48-51 months (Jan 2018 to adoption, earliest April 2022)
- **Treated clusters:** 48 states + DC (≫ 20 state minimum)
- **Post-treatment periods:** 6-33 months depending on adoption cohort (data through Dec 2024)
- **Sample size:** 50 states × 84 months = 4,200 state-month observations
- **MDE considerations:** With 48 treated states and large monthly claim volumes, power should be excellent for detecting even modest effects (5-10% changes)

## Key Confound: PHE Continuous Enrollment

The PHE (Jan 2020 – March 2023) effectively extended postpartum coverage in ALL states by preventing disenrollment. Mitigation:

1. PHE indicator × state FE as controls
2. Separate estimates for during-PHE adopters vs. post-PHE adopters
3. Triple-difference: postpartum vs. antepartum codes × extension × time
4. Preferred specification focuses on post-PHE period where extension becomes binding

## Primary Specification

```
Y_{st} = α + Σ_g Σ_t β_{g,t} × 1(G_i = g) × 1(T = t) + γ_s + δ_t + ε_{st}
```

Where Y is provider supply measure, G is treatment cohort, γ are state FE, δ are time FE. Aggregated via CS-DiD to ATT(g,t) and overall ATT.

## Expected Effects and Mechanisms

**Extensive margin (provider entry):** Moderate positive effect expected. Extending postpartum coverage increases per-patient Medicaid revenue for maternal health providers, potentially inducing new providers to accept Medicaid. However, low reimbursement rates may limit this effect.

**Intensive margin (claims volume):** Strong positive effect expected. Existing Medicaid OB/GYN providers should see more postpartum visits as coverage extends, mechanically increasing claims for 59430 and related codes.

**Contraceptive services:** Positive effect expected. Extended coverage enables LARC insertion (IUDs, implants) during the postpartum year, which was previously uncovered after 60 days.

**Possible null/negative:** If Medicaid rates are too low, providers may not respond to longer coverage windows. This would be an important null result documenting the limits of coverage expansion without accompanying rate increases.

## Planned Robustness Checks

1. **Honest DiD (Rambachan & Roth 2023):** Sensitivity to parallel trend violations
2. **Randomization inference:** Permute treatment across states
3. **Placebo outcomes:** Antepartum codes (59425, 59426), non-OB/GYN providers
4. **Balanced panel:** Restrict to states with consistent T-MSIS reporting
5. **State trends:** Add state-specific linear trends
6. **Post-PHE only:** Restrict to April 2023+ when extension becomes binding
7. **Dose-response:** Interact treatment with state Medicaid reimbursement rates (if available)
8. **Heterogeneity:** By state Medicaid expansion status, by urbanicity, by pre-treatment provider density

## Data Sources

1. **T-MSIS** (local Parquet): Claims by NPI × HCPCS × month. Primary outcome source.
2. **NPPES** (local extract): Provider taxonomy, state, ZIP. Links NPI to geography and specialty.
3. **Census ACS** (API): State-level demographics, poverty, insurance coverage.
4. **KFF/NCSL**: State adoption dates for postpartum extensions.
