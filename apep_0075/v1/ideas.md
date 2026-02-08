# Research Ideas

## Idea 1: Right-to-Work Laws and Employer-Sponsored Health Insurance Coverage

**Policy:** Right-to-Work (RTW) laws adopted in Indiana (February 2012), Michigan (March 2013), and Wisconsin (March 2015). These laws prohibit mandatory union membership or fee payment as a condition of employment, weakening union organizing power.

**Outcome:** Employer-sponsored health insurance (ESI) coverage rates from the American Community Survey (ACS), 2008-2023. The ACS includes detailed health insurance source variables (HINSCARE, HINSCAID, HINSTRI, HINSEMP) and has sample sizes ~3 million per year, providing excellent statistical power for state-level analysis.

**Identification:** Staggered Difference-in-Differences comparing workers in Indiana, Michigan, and Wisconsin to workers in states that never adopted RTW laws during the study period. Will use Callaway & Sant'Anna (2021) estimator to address heterogeneous treatment timing and avoid negative weighting issues. Pre-treatment period: 2008-2011; post-treatment varies by state.

**Why it's novel:**
- Prior research notes "there has been surprisingly little examination of RTW laws' effect on employer-sponsored benefits" due to sample size constraints in CPS ASEC
- The ACS provides 5-10x larger samples than CPS ASEC, enabling precise industry-level heterogeneity analysis
- This is a classic policy (RTW laws are well-studied for wages and union density) with a novel outcome (ESI coverage specifically)
- Tests the "union benefit premium" mechanism: unions negotiate better health benefits; RTW weakens unions; therefore ESI should decline
- Timely: Recent Michigan RTW repeal (2024) renews policy relevance

**Feasibility check:**
- Variation exists: Three states adopted RTW 2012-2015, providing staggered treatment
- Data accessible: ACS microdata via IPUMS (API available, no paywall)
- Pre-treatment periods: 4+ years (2008-2011) for parallel trends testing
- Not overstudied: Google Scholar shows papers on RTW→wages and RTW→union density, but no DiD paper specifically on RTW→ESI using ACS
- Control states: 15+ states never adopted RTW through 2023

**DiD Feasibility Screen:**
| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | 4 years (2008-2011) | Strong |
| Selection into treatment | Republican political shifts 2010-2014, not responding to prior ESI trends | Moderate |
| Comparison group | Never-RTW states, similar Midwest neighbors available | Strong |
| Treatment clusters | 3 states | Marginal (but large states) |
| Concurrent policies | ACA implementation 2014 affects all states equally | Moderate |
| Outcome timing | ESI measured annually, captures treatment well | Strong |
| Outcome-policy alignment | ESI directly measures employer-provided coverage | Strong |

---

## Idea 2: State Paid Family Leave and Fathers' Leave-Taking

**Policy:** State paid family leave (PFL) programs: California (2004), New Jersey (2009), Rhode Island (2014), New York (2018), Washington (2020), Massachusetts (2021), Connecticut (2022), Colorado (2024), Oregon (2024).

**Outcome:** Father/male leave-taking around childbirth from the Current Population Survey (CPS) or American Time Use Survey (ATUS). Can also use ACS fertility timing data combined with employment disruption measures.

**Identification:** Staggered DiD using early vs. late adopting states. Focus on fathers specifically, examining whether PFL increases men's leave usage (breaking traditional gender norms in caregiving).

**Why it's novel:**
- PFL literature focuses heavily on maternal outcomes (employment, earnings, breastfeeding)
- Father leave-taking is understudied but increasingly policy-relevant
- California evidence suggests 46% increase in father leave, but national staggered adoption analysis is limited
- Tests gender norm mechanisms: Does policy make paternity leave socially acceptable?

**Feasibility check:**
- Variation exists: 9 states with staggered adoption 2004-2024
- Data accessible: CPS, ATUS publicly available
- Sample size concerns: Father leave-taking is relatively rare event; may need to focus on proxy outcomes
- Already partially studied: Some work on California PFL and father leave (Bartel et al.)

---

## Idea 3: Minimum Wage Increases and Elderly Worker (65+) Employment

**Policy:** State minimum wage increases 2010-2023. Significant variation across states, with many moving well above federal $7.25 floor.

**Outcome:** Employment and labor force participation among workers 65+ from ACS or CPS.

**Identification:** DiD exploiting variation in state minimum wage changes, focusing specifically on elderly workers.

**Why it's novel:**
- Vast minimum wage literature focuses on teens and young adults (canonical affected group)
- Elderly workers are growing share of minimum wage workforce (Pew Research)
- May have different labor supply elasticities (partial retirement decisions, Social Security interactions)
- Policy-relevant given aging workforce

**Feasibility check:**
- Variation exists: Abundant state-level minimum wage variation
- Data accessible: ACS, CPS with age identifiers
- Concern: Elderly workers are less concentrated in minimum wage jobs; effect may be diluted
- Some prior work: Not extensively studied but not entirely novel

---

## Recommendation

**Pursue Idea 1 (RTW → ESI)** as the primary candidate. It offers:
1. Clear identification (staggered adoption 2012-2015)
2. Novel outcome (ESI specifically, not just wages)
3. Excellent data (ACS provides massive sample sizes)
4. Clear mechanism (union benefit premium)
5. Policy relevance (Michigan RTW repeal debate 2024)

The main limitation is only 3 treated states, but they are large states (combined ~22 million working-age adults) and the ACS sample sizes allow for precise estimation within each state.
