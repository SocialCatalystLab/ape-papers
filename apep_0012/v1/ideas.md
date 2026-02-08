# Research Ideas

Generated after exploration phase for DiD analysis. Assigned states: Michigan, Colorado, Illinois, Oregon.
Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Michigan Right-to-Work Repeal and Union Membership

**Policy:** On March 30, 2024, Michigan became the first state in 58 years to repeal a right-to-work (RTW) law. The original RTW law, enacted in 2012, prohibited requiring union membership or dues as a condition of employment. The repeal restores the ability of unions to negotiate contracts requiring all workers in a bargaining unit to pay dues.

**Method:** DiD

**Research Question:** Did Michigan's repeal of right-to-work law affect union membership rates, wages, and employment among private sector workers?

**Data:**
- Source: Census ACS PUMS 2022-2025 (1-year)
- Key variables: ST (state), COW (class of worker), WAGP (wages), ESR (employment), INDP (industry), PWGTP (weights)
- Sample: Working-age adults (18-64) in private sector employment
- Sample size estimate: ~100,000 MI observations per year, ~500,000 control state observations

**Hypotheses:**
- Primary: Union membership should increase following the repeal as unions can now negotiate mandatory dues provisions
- Mechanism: Reduced free-rider problem increases union resources; stronger unions may negotiate higher wages
- Heterogeneity: Effects should be strongest in construction, manufacturing, and public administration (historically high union industries)

**Novelty:**
- Literature search: Extensive research on RTW adoption effects (Bono-Lunn 2024, Austin & Lilley Harvard WP, NBER digest 2022), but NO research on RTW repeal effects since Michigan is the first state in 58 years to do so.
- Gap: Zero causal evidence on effects of repealing RTW laws; all existing research studies adoption, not repeal
- Contribution: First-ever empirical analysis of RTW repeal; tests whether RTW adoption effects are symmetric/reversible

---

## Idea 2: Colorado State EITC Expansion and Labor Force Participation

**Policy:** Colorado significantly expanded its state EITC from 15% to 20% of the federal credit in 2022, then further to 25% in 2024. This represents one of the largest recent state EITC expansions, substantially increasing take-home pay for low-income working families.

**Method:** DiD

**Research Question:** Did Colorado's substantial state EITC expansion affect labor force participation and employment among low-income workers?

**Data:**
- Source: Census ACS PUMS 2020-2024 (1-year)
- Key variables: ST (state), PINCP (total income), ESR (employment), WKHP (hours worked), SEX, MAR, AGEP, PWGTP
- Sample: Working-age adults (18-64) with income below 200% FPL, focus on unmarried mothers
- Sample size estimate: ~50,000 CO low-income observations, ~300,000 control state observations

**Hypotheses:**
- Primary: The EITC expansion should increase employment among unmarried mothers through the extensive margin incentive
- Mechanism: Higher EITC increases the return to work at the extensive margin, especially for those with low earnings potential
- Heterogeneity: Effects should be strongest among single mothers with children; weaker effects expected post-Kleven 2024

**Novelty:**
- Literature search: EITC literature is extensive, but Kleven (2024 J Pub Econ) reappraises evidence and finds only the 1993 reform had clear effects. Most existing research uses federal expansions.
- Gap: Limited causal evidence on recent state EITC expansions; post-2020 expansions are understudied
- Contribution: Tests whether state EITC expansions have employment effects in the post-Kleven era; clean identification from large CO expansion

---

## Idea 3: Universal Occupational Licensing Recognition and Employment

**Policy:** Between 2019-2024, many states adopted universal licensing recognition laws, allowing licensed professionals from other states to practice without full re-licensure. As of May 2024, 26 states have such laws. This is a major labor market reform affecting occupations like nurses, cosmetologists, electricians, and teachers.

**Method:** DiD (staggered adoption)

**Research Question:** Did state adoption of universal licensing recognition laws increase employment in licensed occupations, particularly among recent interstate migrants?

**Data:**
- Source: Census ACS PUMS 2018-2023 (1-year)
- Key variables: ST (state), MIG (migration status), MIGSP (migration state), OCCP (occupation), ESR (employment), WAGP (wages), PWGTP
- Sample: Working-age adults (25-64) in licensed occupations (nurses, teachers, cosmetologists, electricians)
- Sample size estimate: ~30,000 licensed occupation workers per state-year, ~200,000 movers in licensed occupations

**Hypotheses:**
- Primary: Universal licensing recognition should increase employment among interstate migrants in licensed occupations by reducing barriers
- Mechanism: Lower re-licensing costs enable faster employment; reduces time out of workforce during moves
- Heterogeneity: Effects strongest among occupations with lowest baseline portability (cosmetologists, electricians); effects should be concentrated among recent movers

**Novelty:**
- Literature search: Nature 2025 study on licensing restrictions; CGO research on firm entry; IZA work on job mobility. Policy is recent (most adoptions 2019-2024).
- Gap: No causal analysis specifically examining employment outcomes of universal recognition laws (as distinct from general licensing reform)
- Contribution: First DiD analysis of universal licensing recognition effects on worker-level employment outcomes

---

## Idea 4: Oregon Automatic Voter Registration and Civic Engagement

**Policy:** Oregon implemented automatic voter registration (AVR) in 2016, becoming the first state to do so. The policy automatically registers eligible citizens when they interact with the DMV, with an opt-out option. By 2024, 24 states and DC have adopted AVR.

**Method:** DiD

**Research Question:** Did Oregon's automatic voter registration policy affect civic engagement beyond voting, specifically volunteer work and political participation captured in census data?

**Data:**
- Source: Census ACS PUMS 2014-2019 (1-year) - spans pre and post-AVR
- Key variables: ST (state), CIT (citizenship), AGEP (age), SCHL (education), PWGTP
- Sample: Citizen adults 18+
- Sample size estimate: ~40,000 OR citizen observations per year, ~200,000 control state observations

**Hypotheses:**
- Primary: AVR should increase civic engagement through a "gateway" effect - easier registration leads to more engagement
- Mechanism: Registration is a "gateway" behavior; once registered, individuals may become more politically engaged generally
- Heterogeneity: Effects should be strongest among young adults (18-30) and recent registrants

**Novelty:**
- Literature search: APSR 2022 study on automatic RE-registration; CIRCLE/Tufts 2024 on registration effects; Berkeley 2024 on youth turnout. Most focus on turnout as outcome.
- Gap: No research examining AVR effects on broader civic engagement (volunteer work, community participation) using individual-level data
- Contribution: First analysis of AVR spillover effects on non-electoral civic engagement

**Feasibility Concern:** ACS PUMS does not directly measure voting or volunteer work. This idea may not be feasible with PUMS data.

---

## Idea 5: Illinois State EITC Expansion from 18% to 20% (2023)

**Policy:** Illinois expanded its state EITC from 18% to 20% of the federal credit effective tax year 2023. This is a smaller expansion than Colorado's but affects a larger population given Illinois' size.

**Method:** DiD

**Research Question:** Did Illinois' modest state EITC expansion affect employment and labor force participation among low-income workers?

**Data:**
- Source: Census ACS PUMS 2021-2024 (1-year)
- Key variables: ST (state), PINCP (total income), ESR (employment), WKHP (hours worked), SEX, MAR, AGEP, SCHL, PWGTP
- Sample: Working-age adults (18-64) with income below 200% FPL
- Sample size estimate: ~150,000 IL low-income observations, ~400,000 control state observations

**Hypotheses:**
- Primary: Modest EITC expansion may have minimal employment effects, consistent with Kleven 2024 reappraisal
- Mechanism: Small marginal increase in work incentive may not be sufficient to change labor supply decisions
- Heterogeneity: Any effects should be concentrated among single mothers with 2+ children (highest EITC phase-in)

**Novelty:**
- Literature search: Same as Idea 2 (Kleven 2024 reappraisal challenges employment effects literature)
- Gap: Limited evidence on small/marginal EITC expansions; most studies examine large federal expansions
- Contribution: Tests whether small state EITC expansions have any detectable employment effects; useful null finding

---

## Exploration Notes

**States assigned:** Michigan (MI), Colorado (CO), Illinois (IL), Oregon (OR)
**Method assigned:** DiD

**Search process:**
1. Searched for unique state policies in each assigned state (2019-2024)
2. Focused on labor/employment policies with clean implementation dates
3. Checked NBER, Google Scholar, and specialized sources for existing research
4. Prioritized policies with minimal existing causal analysis

**Policies considered but rejected:**
- Colorado cannabis legalization (2012): Already extensively studied (NBER w30813)
- Michigan Medicaid expansion (2014): Well-studied ACA expansion
- Oregon paid family leave (2023): Too recent for PUMS data
- Illinois minimum wage increases: Studied extensively, gradual phase-in complicates identification
- Oregon automatic voter registration for voting outcomes: Cannot measure voting with PUMS data

**Top candidates ranked by promise:**
1. **Michigan RTW Repeal** - Extremely novel (first repeal in 58 years), clean timing (March 2024), addresses major gap
2. **Universal Licensing Recognition** - Novel policy, staggered adoption enables modern DiD, directly testable with PUMS
3. **Colorado EITC Expansion** - Tests post-Kleven hypothesis, large expansion provides power
4. **Oregon AVR** - Creative idea but likely infeasible with PUMS (cannot measure outcomes)
5. **Illinois EITC** - Less promising (small expansion, large literature)

**Recommendation:** Idea 1 (Michigan RTW Repeal) is most novel and timely. However, March 2024 timing means 2024 ACS 1-year data (available late 2025) needed. Idea 3 (Universal Licensing Recognition) is more immediately feasible with current data.

---

## Selection Rationale

**GPT Ranking Result:**
1. Universal Occupational Licensing Recognition (76/100, PURSUE)
2. Michigan Right-to-Work Repeal (64/100, CONSIDER)
3. Colorado State EITC Expansion (58/100, CONSIDER)
4. Illinois State EITC Expansion (45/100, SKIP)
5. Oregon Automatic Voter Registration (22/100, SKIP)

**Selected Idea:** Universal Occupational Licensing Recognition (Idea 3)

**Rationale for selection:**
GPT recommends pursuing this idea because:
1. The policy is recent and understudied with clear mechanism (reduced relicensing barriers)
2. ACS can identify occupation and recent migration, enabling mover-focused design
3. Modern DiD methods can address staggered adoption

**Key design decisions informed by GPT review:**
- Use modern staggered DiD estimators (Callaway & Sant'Anna) rather than TWFE
- Focus on recent interstate movers in licensed occupations
- Implement strong pre-trend diagnostics
- Acknowledge treatment heterogeneity across states

**Why not Michigan RTW?**
Despite very high novelty, ACS PUMS does not measure union membership (the headline outcome). Would need CPS MORG data and a more complex research design beyond basic DiD.

---
