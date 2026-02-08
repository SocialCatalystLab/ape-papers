# Research Ideas

## Idea 1: State Occupational Heat Protection Standards and Worker Safety Outcomes

**Policy:** State-level occupational heat illness prevention standards requiring employers to provide shade, water, rest breaks, and acclimatization protocols when temperatures exceed specified thresholds.

- California: First standard adopted 2005, effective 2006 (outdoor workers)
- Washington: Original rule 2008, major revision effective July 17, 2023 (outdoor, year-round)
- Oregon: Permanent rule effective June 15, 2022 (indoor and outdoor, 80°F threshold)
- Colorado: Rule adopted 2021 (agricultural workers, 80°F threshold)
- Maryland: Standard effective September 2024 (indoor/outdoor, 80°F threshold)
- Minnesota: Older indoor standard (WAC 5205.0110, subpart 2a)

**Outcome:** Worker heat-related injuries, illnesses, and fatalities
- BLS Survey of Occupational Injuries and Illnesses (SOII): State-level nonfatal injury/illness counts by industry
- BLS Census of Fatal Occupational Injuries (CFOI): State-level fatal work injuries, including "exposure to environmental heat"
- Workers' compensation claims data (state-specific)

**Identification:** Difference-in-differences exploiting staggered adoption of heat standards across states from 2006-2024. Compare heat-related injury/illness rates in states adopting standards vs. states without standards, before and after adoption.

**Why it's novel:** While one California-specific study (Health Affairs, 2025) found a 33% reduction in heat-related deaths post-2010, NO causal research exists on the other state standards (WA, OR, CO, MD). The recent wave of adoptions (2021-2024) provides fresh variation for DiD analysis.

**Feasibility check:**
- ✓ Clear effective dates for 5+ states
- ✓ State × time variation exists
- ✓ BLS CFOI data available by state (publicly downloadable tables)
- ✓ BLS SOII data available for participating states
- ⚠️ Heat-related injuries may be underreported
- ⚠️ Limited post-treatment periods for recent adopters (OR: 2 years, WA: 1.5 years)
- ⚠️ Need to distinguish treated industries (outdoor workers) from untreated

**DiD Early Feasibility Screen:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | Moderate: 10+ years for CA, 2-5 years for recent adopters |
| Selection into treatment | Moderate: States with more outdoor workers may adopt first |
| Comparison group | States without heat standards (majority of US) |
| Treatment clusters | 5-6 states with standards |
| Concurrent policies | Federal OSHA rule still proposed (not enacted) |
| Outcome timing | CFOI available through 2023; SOII varies by state |

---

## Idea 2: State Eviction Record Sealing Laws and Housing Stability

**Policy:** State laws that seal or expunge eviction records from public view, limiting access by tenant screening companies and landlords.

- California: AB 2819 (2016) - seals at filing, 60-day limit
- Oregon: SB 873 (2019) expungement; HB 2001 (2023) sealing - 47,000+ records sealed
- Arizona, Maryland, Minnesota, DC: Seal at dismissal/judgment (various years)
- Utah: Automatic sealing after 3 years (2019)
- Massachusetts: Sealing law effective May 5, 2025
- Virginia, West Virginia, Idaho, Wisconsin: Laws passed 2024
- Colorado, Delaware, North Dakota: Laws adopted 2025

**Outcome:** Housing stability, rental market outcomes
- ACS: Housing cost burden (B25070), residential mobility, homelessness
- HUD Point-in-Time Counts: Homeless population by state
- Eviction Lab: Eviction filing rates (though sealed records affect this)
- CPS: Housing security supplement

**Identification:** DiD exploiting staggered adoption across 21+ states from 2016-2025. Compare housing outcomes in sealing states vs. non-sealing states, before and after adoption.

**Why it's novel:** Despite 3.6 million eviction filings annually and growing policy interest, NO causal research exists on the effects of sealing laws on tenant outcomes. Existing research focuses on describing the policies, not evaluating their effects.

**Feasibility check:**
- ✓ Clear effective dates for 20+ jurisdictions
- ✓ Rich state × time variation
- ✓ ACS data readily available via Census API
- ⚠️ Outcome measurement challenge: can't directly observe who benefits from sealed records
- ⚠️ Selection: states with housing crises may adopt sealing laws
- ⚠️ Different sealing mechanisms (at filing vs. after judgment vs. time-based) may have different effects

**DiD Early Feasibility Screen:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | Strong: CA has 8+ years, many states 3-5 years |
| Selection into treatment | Concern: High-eviction states may adopt first |
| Comparison group | States without sealing laws (~29 states) |
| Treatment clusters | 21+ states |
| Concurrent policies | Some overlap with eviction moratoria (COVID) |
| Outcome measurement | Indirect: use housing stability, not sealed record counts |

---

## Idea 3: State Child Labor Law Weakening and Youth Employment Outcomes

**Policy:** Recent state laws that eliminated work permit requirements, extended allowable work hours, or reduced protections for workers under 18.

- Arkansas: Youth Hiring Act (Act 195), eliminated work permits, effective August 1, 2023
- Iowa: Extended hours for 14-15 year olds, driving permits for 14 year olds (2023-2024)
- Florida: HB 49 signed March 2023, allows 30+ hours/week for 16-17 year olds
- Indiana: SB 146 signed March 2023, removed time restrictions
- New Jersey: 2022 law extended summer hours for teens

**Outcome:** Youth employment, school enrollment, workplace injuries
- CPS: Employment status by age, hours worked, school enrollment
- ACS: Employment and school enrollment for teens
- BLS SOII: Injuries by age group (limited granularity)
- State education data: High school dropout rates

**Identification:** DiD comparing youth labor market outcomes in states that weakened protections vs. states that maintained or strengthened protections, before and after law changes.

**Why it's novel:** While one undergraduate thesis examined Arkansas wages, NO peer-reviewed causal research exists on the recent wave of child labor law weakening. EPI research is descriptive. Recent U Maryland study found work permits reduce violations, but didn't study recent law changes.

**Feasibility check:**
- ✓ Clear effective dates for 5+ states
- ✓ State × time variation exists
- ✓ CPS microdata available via IPUMS
- ⚠️ Very recent policies (2022-2024) limit post-treatment data
- ⚠️ Small affected population (14-17 year olds)
- ⚠️ Federal child labor laws still apply (state laws can only be MORE restrictive, so "weakening" means allowing federal minimums)

**DiD Early Feasibility Screen:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | Strong: 5+ years before 2022 |
| Selection into treatment | Concern: Republican states adopting, may differ on other dimensions |
| Comparison group | States that didn't weaken laws |
| Treatment clusters | 5-6 states |
| Concurrent policies | Federal DOL enforcement efforts |
| Outcome timing | Limited: only 1-2 years post-treatment |

---

## Idea 4: State Junk Fee / Drip Pricing Laws and Consumer Outcomes

**Policy:** State laws prohibiting businesses from advertising prices that exclude mandatory fees, requiring "all-in" pricing disclosure.

- California: SB 478 effective July 1, 2024
- Minnesota: HF 3438 effective January 1, 2025
- Virginia: Law in effect (2024)
- Colorado: Law effective 2026
- Connecticut: Law effective 2026
- Massachusetts: AG regulations (2024)

**Outcome:** Consumer prices, price dispersion, consumer complaints
- BLS Consumer Price Index components (limited geographic granularity)
- CFPB complaint database (for financial services)
- State AG complaint data (if available)
- Hotel/rental pricing data (if accessible)

**Identification:** DiD comparing advertised vs. actual prices, consumer complaints, or price levels in states with junk fee laws vs. states without, before and after adoption.

**Why it's novel:** These laws are brand new (2024-2026). NO research exists on their effects. FTC rule for hotels just took effect in 2025.

**Feasibility check:**
- ✓ Clear effective dates
- ⚠️ Very recent (California effective July 2024)
- ⚠️ Limited outcome data: no good source for advertised vs. actual prices
- ⚠️ Only 1-2 states with post-treatment data
- ❌ Insufficient post-treatment periods for credible DiD

**DiD Early Feasibility Screen:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | Strong: Many years before 2024 |
| Selection into treatment | Unknown: Too new to assess |
| Comparison group | Most states without laws |
| Treatment clusters | Only 2-3 states with data |
| Post-treatment periods | ❌ <1 year for most states |

---

## Idea 5: State Universal Free School Meals and Child Food Security

**Policy:** State laws providing free breakfast and lunch to ALL public school students regardless of income, going beyond federal Community Eligibility Provision (CEP).

- California, Maine: 2022-23 school year (first adopters)
- Colorado, Minnesota, New Mexico, Vermont: 2023-24 school year
- Michigan, Massachusetts: 2023-24 school year
- New York: 2024-25 school year

**Outcome:** Child food security, meal participation, student outcomes
- CPS Food Security Supplement: Household and child food security
- School meal participation data (USDA)
- State education data: Attendance, test scores

**Identification:** DiD exploiting staggered state adoption from 2022-2024. Compare child food security in universal meal states vs. non-universal states, before and after adoption.

**Why it's novel:** While CEP (federal program) has been studied extensively, STATE-LEVEL universal meal policies (which cover ALL students, not just high-poverty schools) are understudied. One 2024 DiD study exists using Household Pulse Survey, but more research needed.

**Feasibility check:**
- ✓ Clear effective dates for 9 states
- ✓ Excellent state × time variation (staggered 2022-2024)
- ✓ CPS Food Security Supplement available
- ⚠️ Some existing research on CEP (need to differentiate)
- ⚠️ Limited post-treatment periods (2 years max)
- ⚠️ COVID-era universal meals (2020-2022) may contaminate comparison

**DiD Early Feasibility Screen:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | Weak: COVID waivers 2020-2022 complicate baseline |
| Selection into treatment | Moderate: Democratic states adopted first |
| Comparison group | States without universal policies |
| Treatment clusters | 9 states |
| Concurrent policies | COVID meal waivers ended June 2022 (affects baseline) |

---

## Ranking Summary

| Idea | Novelty | Identification | Data Access | Post-Treatment | Overall |
|------|---------|----------------|-------------|----------------|---------|
| 1. Heat Protection | High | Moderate | Good | Moderate | **Strong** |
| 2. Eviction Sealing | Very High | Moderate | Good | Good | **Strong** |
| 3. Child Labor | High | Moderate | Good | Weak | Moderate |
| 4. Junk Fees | Very High | Unknown | Poor | Very Weak | Weak |
| 5. Universal Meals | Moderate | Weak | Good | Weak | Moderate |

**Recommendation:** Pursue **Idea 1 (Heat Protection)** or **Idea 2 (Eviction Sealing)**. Both have high novelty and feasible identification. Heat protection has cleaner outcome measurement; eviction sealing has more treatment variation.
