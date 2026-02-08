# Research Ideas

## Idea 1: Do Renewable Portfolio Standards Create or Destroy Utility Sector Jobs? Evidence from Staggered State Adoption

**Policy:** Renewable Portfolio Standards (RPS) — state laws requiring electric utilities to generate a minimum percentage of electricity from renewable sources. 29 states plus DC have adopted RPS, with staggered adoption from 1983 (Iowa) through 2019. Major adoption waves occurred in 2004-2008 and 2015-2019.

**Outcome:** Employment in the electric power generation, transmission, and distribution sector (NAICS 0570 in ACS/PUMS). Secondary outcomes: wages in the electricity sector, total utility employment, and employment in manufacturing subsectors.

**Identification:** Staggered difference-in-differences using Callaway-Sant'Anna (2021) estimator. Treatment is the year a state enacts an RPS. Control states are never-treated states (those without RPS as of the end of the sample period) and not-yet-treated states. Individual-level ACS PUMS data aggregated to state-year cells or used directly with state and year fixed effects.

**Why it's novel:** The vast RPS literature focuses on energy outcomes (renewable capacity, generation, emissions, electricity prices). No published study uses modern heterogeneity-robust DiD methods to estimate the causal employment effects of RPS in the electricity sector. This is a policy-relevant gap: proponents claim RPS creates "green jobs" while opponents argue it destroys fossil fuel employment. Rigorous causal evidence is absent.

**Feasibility check:**
- **Variation:** 29 treated states with staggered adoption across 25+ years. ✓
- **Pre-treatment periods:** ACS 1-year data available 2005-2023; many states adopted pre-2005, providing clean never-treated controls. For states adopting 2010-2019, 5+ pre-periods. ✓
- **Data access:** Census ACS PUMS API confirmed working. INDP=0570 returns individual-level records with person weights (PWGTP), employment status (ESR), and state identifiers. ✓
- **Sample size:** ~9,000 records per year in electricity sector nationally. With 19 years (2005-2023), approximately 170,000 person-year observations. ✓
- **Not overstudied:** Web search confirms no DiD study on RPS employment effects exists. ✓
- **Treated clusters:** 29 states ≥ 20 threshold. ✓

**Counter-intuitive potential:** RPS may DECREASE total electricity sector employment if renewable generation requires fewer workers per MWh than fossil fuel plants (solar/wind are capital-intensive, not labor-intensive at scale). Alternatively, the transition period may create temporary employment gains from installation/construction. The net effect is theoretically ambiguous, making this an empirically important question.


## Idea 2: Does Medicaid Expansion Reduce Disability Insurance Applications? Evidence from the ACA's Staggered State Adoption

**Policy:** ACA Medicaid expansion — extending eligibility to adults with income up to 138% FPL. 38 states expanded between 2014 and 2024, with most expanding in 2014 and a staggered tail through 2024.

**Outcome:** SSI receipt (SSIP variable in ACS PUMS), disability status (DPHY, DREM, etc.), and public assistance income (PAP). The hypothesis is that some low-income adults apply for disability insurance primarily to access Medicaid healthcare benefits ("disability as health insurance").

**Identification:** Staggered DiD with Callaway-Sant'Anna, comparing expanding vs. non-expanding states. Treatment = year of Medicaid expansion. Pre-period: 2005-2013 (9 years). Focus on adults aged 19-64 below 138% FPL.

**Why it's novel:** While Medicaid expansion effects on insurance coverage, utilization, and mortality are extensively studied, the disability insurance channel is understudied. Burns & Dague (2017) examined Oregon's lottery-based expansion only. No study applies modern heterogeneity-robust DiD to the national staggered ACA expansion and disability/SSI outcomes using ACS microdata.

**Feasibility check:**
- **Variation:** 38 treated states. ✓
- **Pre-treatment:** 9 years (2005-2013). ✓
- **Data:** ACS PUMS via Census API. SSI receipt (SSIP), disability flags, all confirmed accessible. ✓
- **Treated clusters:** 38 states >> 20 threshold. ✓
- **Selection concern:** States expanded based on political ideology (Republican vs. Democrat), not disability trends. Supported by event study pre-trend analysis. ✓
- **Novelty risk:** Medicaid expansion is extremely well-studied. The novel angle (disability channel) must be executed exceptionally to stand out. Moderate risk.


## Idea 3: Do State Earned Income Tax Credits Reduce Food Insecurity? Evidence from SNAP Participation Among Families with Children

**Policy:** State-level Earned Income Tax Credits (EITC) — 31 states plus DC have adopted state EITCs supplementing the federal EITC, with staggered adoption from 1986 (Rhode Island) through 2024 (Montana full implementation). Credits range from 3% to 50% of the federal EITC.

**Outcome:** SNAP/food stamp receipt (FS variable in ACS PUMS) among households with children under 18. SNAP participation is a direct measure of food insecurity risk. The EITC-SNAP interaction is policy-relevant because EITC income can make families technically ineligible for SNAP even if they remain food insecure.

**Identification:** Staggered DiD using Callaway-Sant'Anna. Treatment = year state EITC enacted. Control = states without EITC. Individual-level ACS data with state and year fixed effects.

**Why it's novel:** The EITC literature focuses on labor supply (Eissa & Liebman 1996, Meyer & Rosenbaum 2001), infant health (Hoynes et al. 2015), and poverty (Hoynes & Patel 2018). The interaction between state EITCs and food security/SNAP participation is understudied. The novel angle: Does a state EITC reduce SNAP participation by lifting incomes above eligibility thresholds, potentially leaving near-poor families worse off (losing SNAP benefits > EITC gain)?

**Feasibility check:**
- **Variation:** 31 treated states, staggered adoption over 38 years. ✓
- **Pre-treatment:** ACS from 2005; many states adopted post-2010. ✓
- **Data:** ACS PUMS FS (food stamps/SNAP) variable. Binary indicator. Confirmed accessible via Census API. ✓
- **Treated clusters:** 31 states ≥ 20 threshold. ✓
- **Counter-intuitive potential:** State EITC might INCREASE food insecurity if the income gain pushes families just above SNAP eligibility cliffs. Or it might reduce food insecurity via higher total income. Ambiguous prediction makes this empirically valuable.
