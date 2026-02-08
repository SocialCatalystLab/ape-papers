# Research Ideas

Generated after extensive web search and novelty assessment. These ideas exploit understudied policy variation.

---

## Idea 1: Adolescent Exposure to Legalized Gambling: Long-Run Effects of State Lottery Adoption on Financial Behavior

**Policy:** State lottery legalization (1964-2019). States adopted lotteries in staggered fashion: New Hampshire (1964), New York (1967), New Jersey (1970), 17 states in the 1980s, Texas (1992), etc. Five states still have no lottery (AL, AK, HI, NV, UT).

**Method:** DiD using birth cohort × birth state design

**Research Question:** Does adolescent exposure to legal gambling (state lottery legalization during ages 13-19) affect long-run financial outcomes and risk-taking behavior in adulthood?

**Data:**
- Source: Census PUMS 2019-2023 (pooled for power)
- Key variables: POBP (birth state), AGEP (age), PINCP (income), SEMP (self-employment income), COW (class of worker), WAGP (wages), SCHL (education)
- Sample: Adults 35-70 born in U.S. states (excludes territories)
- Sample size estimate: ~15M observations pooled across years

**Identification Strategy:**
- Treatment: Born in state S, age 13-19 when state S legalized lottery
- Control: Born in state S', same birth cohort, but state S' legalized earlier or later (or never)
- Key insight: Variation comes from *when* states legalized, not *whether* they did
- Compare outcomes across cohorts within states, and across states within cohorts

**Hypotheses:**
- Primary: Adolescent exposure to legal gambling increases later-life risk tolerance, potentially increasing self-employment and entrepreneurship but also financial fragility
- Mechanism: Normalization of risk-taking and probabilistic thinking during formative years
- Heterogeneity: Effects may be stronger for lower-income families (more exposure to lottery marketing) and males

**Novelty:**
- Literature search: NBER lottery papers focus on (1) lottery WINNERS' behavior, (2) consumer DEMAND for lotteries, (3) household crowding-out of consumption. ZERO papers found using staggered lottery adoption to study population-level effects on adolescent-exposed cohorts.
- Gap: No research on long-run effects of *availability* of legal gambling during adolescence
- Contribution: First paper to use state lottery legalization as a shock to adolescent gambling exposure, studying long-run effects on financial risk-taking and labor market outcomes

---

## Idea 2: E-Verify Mandates and Labor Market Outcomes for Hispanic Workers

**Policy:** State E-Verify mandates requiring employers to verify work authorization. Staggered adoption: Arizona (2008), Mississippi (2011), Alabama (2012), Georgia (2012+), North Carolina (2013), South Carolina (2021). California and Illinois explicitly restrict E-Verify use.

**Method:** DiD using state rollout timing

**Research Question:** Do state E-Verify mandates affect employment, wages, and self-employment among Hispanic workers (both authorized and unauthorized)?

**Data:**
- Source: Census PUMS 2005-2023
- Key variables: ST (state), HISP (Hispanic origin), CIT (citizenship), ESR (employment status), WAGP (wages), SEMP (self-employment), COW (class of worker), WKHP (hours worked)
- Sample: Hispanic adults 18-64 in all 50 states
- Sample size estimate: ~3M Hispanic observations across years

**Identification Strategy:**
- Treatment: Hispanic workers in states that adopt E-Verify mandates
- Control: Hispanic workers in non-mandate states, same time period
- Event study: Examine effects -3 to +5 years around mandate adoption
- Robustness: Compare border counties across state lines (e.g., AZ vs. CA)

**Hypotheses:**
- Primary: E-Verify mandates reduce formal employment among Hispanic non-citizens but increase self-employment (workers shift to informal sector)
- Mechanism: Unauthorized workers become undetectable via self-employment; authorized workers may face discrimination due to employer confusion
- Heterogeneity: Effects strongest for non-citizens, but may spill over to naturalized citizens due to statistical discrimination

**Novelty:**
- Literature search: Some papers on Arizona's mandate (2008), but limited analysis of the full staggered rollout across states. Most focus on unauthorized population estimates, not labor market outcomes in PUMS.
- Gap: No comprehensive DiD using the 2011-2021 wave of E-Verify mandates
- Contribution: First paper to leverage the full set of state E-Verify mandates (2008-2021) to study labor market adjustments among Hispanic workers, distinguishing citizen from non-citizen effects

---

## Idea 3: Graduated Driver Licensing Laws and Teen Labor Force Participation

**Policy:** Graduated Driver Licensing (GDL) laws restricting teen driving (nighttime curfews, passenger limits, minimum holding periods). Adopted by states from 1996-2011 with varying stringency. Major variation in when restrictions begin (age 15 vs 16) and how long intermediate period lasts.

**Method:** DiD using state GDL adoption timing and stringency

**Research Question:** Do Graduated Driver Licensing restrictions reduce teen labor force participation by limiting mobility, and do these effects persist into early adulthood?

**Data:**
- Source: Census PUMS 2000-2023
- Key variables: AGEP (age), ESR (employment status), WKHP (hours worked), JWMNP (commute time), JWTR (transportation mode), SCHG (school enrollment), ST (state)
- Sample: Youth ages 16-24
- Sample size estimate: ~5M observations across years

**Identification Strategy:**
- Treatment: Teens in states with stricter GDL laws (nighttime driving bans, passenger restrictions)
- Control: Teens in states with weaker or no GDL laws
- Timing: Pre-2000 most states had no GDL; by 2011 nearly all had some form
- GDL stringency index: Code strength based on IIHS ratings

**Hypotheses:**
- Primary: Stricter GDL laws reduce teen employment rates, particularly in jobs requiring evening/night work or long commutes
- Mechanism: Restricted mobility makes work less accessible; parents may not be available to drive teens to work
- Heterogeneity: Effects larger in rural areas (no public transit alternative), for low-income families (fewer cars to share), and for service-sector jobs (evening hours)

**Novelty:**
- Literature search: GDL literature focuses almost exclusively on traffic safety outcomes (crashes, fatalities). IIHS shows 20-40% reduction in teen crash rates.
- Gap: Almost no research on unintended labor market consequences of GDL restrictions
- Contribution: First paper to study GDL's effect on teen employment and early career trajectories, revealing potential unintended costs of safety-focused policy

---

## Idea 4: State Lottery Legalization and Adult Educational Attainment

**Policy:** Same as Idea 1 - state lottery legalization 1964-2019

**Method:** DiD using birth cohort × birth state design

**Research Question:** Does adolescent exposure to legal gambling reduce educational investment by normalizing "get rich quick" thinking versus long-term human capital investment?

**Data:**
- Source: Census PUMS 2019-2023
- Key variables: POBP (birth state), AGEP (age), SCHL (educational attainment), FOD1P (field of degree), SCHG (school enrollment for younger cohorts)
- Sample: Adults 25-65 born in U.S. states
- Sample size estimate: ~20M observations

**Identification Strategy:**
- Same as Idea 1: Treatment = exposed to lottery during ages 13-19 based on birth state and birth year
- Focus on education outcome rather than financial outcomes
- Can also examine field of study choices (gambling exposure → more interest in finance/speculation?)

**Hypotheses:**
- Primary: Adolescent lottery exposure reduces educational attainment (especially college completion) as teens internalize "luck vs. effort" narrative
- Alternative hypothesis: Exposure to probability/statistics concepts in lottery marketing could *increase* mathematical thinking
- Mechanism: Lottery advertising emphasizes instant wealth rather than gradual skill accumulation
- Heterogeneity: Effects may be stronger for males, lower-income households, and in states with more aggressive lottery marketing

**Novelty:**
- Literature search: No papers found linking state lottery *availability* to educational outcomes
- Gap: Complete void in literature on lottery legalization → education channel
- Contribution: Tests whether legal gambling during formative years crowds out human capital investment, with implications for state fiscal policy (lottery revenue vs. education outcomes)

---

## Exploration Notes

**Searches conducted:**
1. State lottery legalization timing and staggered adoption history
2. Right-to-work law variation and timing
3. E-Verify mandate state rollout
4. Compulsory schooling age changes by state
5. Graduated driver licensing adoption
6. Pre-Roe abortion legalization (too well-studied)
7. Keg registration laws (too narrow)

**Rejected ideas:**
- Medicare at 65 RDD: Exhaustively studied (100+ papers)
- Medicaid expansion DiD: Heavily studied
- Minimum wage increases: Very well-studied
- Pre-Roe abortion: Gruber/Donohue-Levitt and many others
- Compulsory schooling age: Angrist-Acemoglu and extensive follow-ups

**Why these 4 rose to the top:**
1. **Lottery legalization** (Ideas 1 & 4): Genuinely unexploited natural experiment. Clear staggered timing. Can study long-run effects via birth cohort design. Two different outcome families (financial vs. educational).
2. **E-Verify** (Idea 2): Recent policy wave (2011-2021) not fully analyzed. Clean DiD setup. Important immigration policy question.
3. **GDL laws** (Idea 3): Obvious safety policy with completely unstudied labor market angle. Rich variation in timing and stringency.

**Recommended focus:** Idea 1 (Lottery → Financial Behavior) is the most novel and counterintuitive. It's a policy that generates state revenue but may have long-run costs on populations exposed during adolescence. This is the kind of provocative finding that could generate attention.
