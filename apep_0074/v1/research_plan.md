# Research Plan (Updated)

## Research Question

Do Extreme Risk Protection Order (ERPO) laws, commonly known as "red flag" laws, reduce suicide rates?

## Status: Paper Complete

**Main Finding:** No statistically significant effect. Simple ATT = 0.030 (SE = 0.168), 95% CI: [-0.30, 0.36].

## Key Limitations Documented
1. Only 4 treated states contribute to identification (CT, IN, CA, WA)
2. Outcome is total suicide, not firearm-specific (attenuates true effect)
3. Data ends 2017, missing 2018-2019 adoption wave
4. Some concerning pre-trends (2 of 6 significant)

---

## Original Research Plan

## Policy Background

ERPOs allow courts to temporarily remove firearms from individuals deemed at risk of harming themselves or others. The mechanism for suicide prevention is clear: firearm suicide attempts are nearly always fatal (85-90% case fatality rate), and suicidal crises are often acute and short-lived (minutes to hours). Temporarily removing firearms during a crisis period can prevent impulsive suicide attempts.

### Adoption Timeline

| State | Effective Date | Treatment Year (conservative) |
|-------|---------------|-------------------------------|
| Connecticut | Oct 1999 | 2000 |
| Indiana | Jul 2005 | 2006 |
| California | Jan 2016 | 2016 |
| Washington | Dec 2016 | 2017 |
| Oregon | Jan 2018 | 2018 |
| Florida | Mar 2018 | 2019 |
| Vermont | Apr 2018 | 2019 |
| Maryland | Oct 2018 | 2019 |
| Rhode Island | Jun 2018 | 2019 |
| New Jersey | Sep 2018 | 2019 |
| Delaware | Dec 2018 | 2019 |
| Massachusetts | Jul 2018 | 2019 |
| Illinois | Jan 2019 | 2019 |
| New York | Aug 2019 | 2020 |
| Colorado | Jan 2020 | 2020 |
| Nevada | Jan 2020 | 2020 |
| Hawaii | Jan 2020 | 2020 |
| New Mexico | May 2020 | 2021 |

For states with mid-year effective dates after June 30, I conservatively code treatment as beginning the following year.

## Identification Strategy

### Design: Staggered Difference-in-Differences

I exploit variation in the timing of ERPO law adoption across states. The 2018-2019 wave (post-Parkland) provides substantial identifying variation, with approximately 10 states adopting within a narrow window.

### Estimator: Callaway-Sant'Anna (2021)

I use the heterogeneity-robust estimator of Callaway and Sant'Anna (2021) to avoid bias from negative weighting in staggered TWFE designs. The comparison group consists of not-yet-treated and never-treated states.

### Identifying Assumption

Parallel trends: absent ERPO adoption, firearm suicide rates in treatment and control states would have evolved similarly. I assess this with event study pre-trends.

### Exposure Alignment

**Who is actually treated by the policy?**
- **Primary target:** Individuals petitioned for ERPO orders (typically in suicidal or behavioral crisis)
- **Actually affected:** Individuals whose firearms are seized via ERPO

**Primary estimand population:**
- State population (all residents), because state-level suicide rates are the outcome
- This creates substantial dilution: ERPOs affect a small subset (individuals subject to orders) but outcome is measured for entire population

**Placebo/control population:**
- Never-treated states (38 jurisdictions that did not adopt ERPOs during 1999-2017)
- Post-sample adopters (9 states that adopted after 2017, coded as first_treat=0)
- Total: 47 comparison units

**Design consideration:**
- Treatment is state-level (law on books), but mechanism operates at individual level (firearm removal from specific persons)
- State-level outcome will capture only a fraction of any true effect due to population dilution
- This is a standard ITT design: all residents of treated states are "treated" regardless of ERPO exposure

## Data

### Outcome: Firearm Suicide Rate

- **Source:** CDC WONDER Multiple Cause of Death
- **ICD-10 Codes:** X72 (handgun), X73 (rifle/shotgun), X74 (other firearm)
- **Measure:** Deaths per 100,000 population, state-year
- **Period:** 2005-2019

### Treatment: ERPO Law Status

- **Source:** PDAPS (Policy Surveillance Program), Everytown, Giffords Law Center
- **Coding:** Binary indicator = 1 if ERPO law in effect for full calendar year

### Sample

- **Units:** 51 jurisdictions (50 states + DC)
- **Years:** 2005-2019 (15 years)
- **Observations:** ~765 state-years

## Expected Effects

### Mechanism

ERPOs allow family members, law enforcement, or (in some states) healthcare providers to petition a court for temporary firearm removal from individuals in crisis. The key mechanism for suicide prevention is means restriction during acute crisis periods.

### Prior Evidence

- Swanson et al. (2017): Connecticut's ERPO prevented 1 suicide per 10-20 guns seized
- Swanson et al. (2024): 1 suicide prevented per 17-23 ERPOs in 4-state study
- RAND review: "Moderate" evidence that ERPOs reduce firearm suicide

### Expected Magnitude

Prior research suggests 7-15% reduction in firearm suicide in adopting states. Given baseline rate of ~7 per 100,000, this implies effect of ~0.5-1.0 per 100,000.

## Primary Specification

```
Y_st = ATT(g,t) + state_FE + year_FE + epsilon_st
```

Where ATT(g,t) are group-time average treatment effects aggregated using Callaway-Sant'Anna.

## Robustness Checks

1. **TWFE comparison:** Standard two-way fixed effects for comparison
2. **Placebo outcome:** Non-firearm suicide (should show no effect if mechanism is means restriction)
3. **Exclude early adopters:** Exclude CT/IN (pre-Parkland adopters with different context)
4. **Exclude states with concurrent gun laws:** Exclude states that passed universal background checks, waiting periods, or other gun laws concurrently

## Power Considerations

- **Treated states (2005-2019):** ~15 states
- **Pre-treatment periods:** 13+ years for most states
- **Post-treatment periods:** 1-2 years for most 2018-2019 adopters
- **Short post-treatment window is a limitation**

## Limitations (to acknowledge in paper)

1. **Short post-treatment periods:** Most states adopted in 2018-2019, leaving only 1-2 post-treatment years before 2019 endpoint
2. **Concurrent policies:** Post-Parkland wave included multiple gun reforms; ERPO effect may be confounded
3. **Implementation heterogeneity:** Utilization varies widely across states; binary indicator captures intent-to-treat, not actual ERPO usage
4. **Endogenous adoption:** States adopting ERPOs may differ systematically; parallel trends assumption critical
