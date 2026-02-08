# Research Ideas

Generated after exploration phase. These 4 ideas cover different policies and methods.
Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Universal Occupational License Recognition and Interstate Migration

**Policy:** Universal License Recognition (ULR) laws allow workers licensed in one state to practice in the adopting state without re-licensure. Arizona enacted the first ULR law (HB 2569) effective August 2019, followed by Montana, Pennsylvania, Missouri, Utah, Iowa, and Idaho.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Does universal occupational license recognition increase interstate migration and employment among workers in licensed occupations?

**Data:**
- Source: Census PUMS 2017-2022 (3 years pre, 3 years post Arizona's law)
- Key variables: ST (current state), MIGSP (state 1 year ago), OCCP (occupation), ESR (employment status), WAGP (wages), PWGTP (weights)
- Sample: Adults aged 25-60 in licensed occupations (nurses, teachers, cosmetologists, real estate agents, etc.)
- Sample size estimate: ~500,000 workers in licensed occupations per year across PUMS

**Hypotheses:**
- Primary: ULR states will experience increased in-migration from non-ULR states among licensed workers, with employment rates unchanged or slightly increased
- Mechanism: Reduced licensing barriers lower migration costs, making it easier for licensed workers to relocate for job opportunities
- Heterogeneity: Effects should be strongest for occupations with historically low interstate license portability (e.g., teachers, cosmetologists) vs. already-portable professions (e.g., nurses with Compact)

**Novelty:**
- Literature search: Found 2 causal studies - Deyo & Plemmons (2022) on migration using tax data, Bae & Timmons (2023) on employment ratios. Both use synthetic control or DiD but not PUMS microdata.
- Gap: No study uses PUMS to examine individual-level employment outcomes, wages, or occupational persistence. No study examines heterogeneity by specific occupation type.
- Contribution: First PUMS-based analysis of ULR effects on individual employment, wages, and migration, with occupation-level heterogeneity analysis.

---

## Idea 2: Cosmetology Training Hours Reduction and Labor Market Outcomes

**Policy:** Multiple states reduced required training hours for cosmetology licenses between 2013-2022. West Virginia reduced from 1800 to 1500 hours (2013), Wisconsin reduced from 1800 to 1550 hours (2013), and California reduced from 1600 to 1000 hours (2022).

**Method:** DiD (Difference-in-Differences with staggered adoption)

**Research Question:** Does reducing cosmetology licensing hour requirements affect employment and wages for cosmetologists?

**Data:**
- Source: Census PUMS 2010-2022
- Key variables: OCCP=4510/4521 (hairdressers/cosmetologists), ST, WAGP, ESR, WKHP (hours worked), AGEP, PWGTP
- Sample: Workers in cosmetology occupations, ages 18-65
- Sample size estimate: ~50,000 cosmetologists per year in PUMS

**Hypotheses:**
- Primary: Reduced hour requirements will increase employment in cosmetology (more new entrants) with no effect or slight decrease in average wages
- Mechanism: Lower barriers to entry increase labor supply; effect on wages depends on whether demand is elastic
- Heterogeneity: Effects strongest among younger workers (new entrants), minorities, and lower-income areas where training costs are more binding

**Novelty:**
- Literature search: NBER Working Paper 33936 (2025) studied student outcomes (completion, tuition) and found "no detectable effects on the earnings of cosmetologists." Institute for Justice reports document reforms but no causal labor market analysis.
- Gap: NBER paper focused on student/school outcomes, not labor market effects. The null finding on earnings deserves replication with PUMS data and extension to employment effects.
- Contribution: First comprehensive PUMS-based analysis of cosmetology hour reductions on employment, wages, and hours worked, with heterogeneity analysis.

---

## Idea 3: State EITC Supplements and Labor Force Participation

**Policy:** State Earned Income Tax Credits supplement the federal EITC. Currently 31 states have state EITCs, enacted at different times (e.g., Rhode Island 1986, New York 1994, California 2015, Montana 2019). State supplements range from 3% to 50% of federal credit.

**Method:** DiD (Difference-in-Differences with staggered adoption)

**Research Question:** Do state EITC supplements increase labor force participation among low-income parents?

**Data:**
- Source: Census PUMS 2005-2022
- Key variables: ST, ESR (employment), PINCP (income), PWGTP, AGEP, SEX, HUPAOC (children), WKHP
- Sample: Adults aged 25-55 with children and income below $60,000
- Sample size estimate: ~2 million low-income parents per year in PUMS

**Hypotheses:**
- Primary: State EITC adoption increases employment rates among low-income single mothers by 1-3 percentage points
- Mechanism: Higher after-tax earnings from work increase returns to employment; EITC phase-in creates strong work incentive
- Heterogeneity: Effects strongest for single mothers (highest take-up and largest benefit), larger for states with more generous supplements

**Novelty:**
- Literature search: Federal EITC heavily studied (Eissa & Liebman 1996, Meyer & Rosenbaum 2001). Kleven (2024) finds only 1993 expansion had robust effects. State supplements studied less - only a few papers (Neumark & Wascher 2011).
- Gap: Most research focuses on 1993 federal expansion. State supplements provide additional variation to test EITC labor supply effects in post-welfare-reform era.
- Contribution: Comprehensive analysis of state EITC supplements using staggered DiD with modern econometric methods (Callaway-Sant'Anna) to address heterogeneous treatment effects.

---

## Idea 4: ACA Young Adult Coverage and "Job Lock" at Age 26

**Policy:** The Affordable Care Act (2010) allowed young adults to remain on parents' health insurance until age 26. At 26, young adults "age out" and must obtain own coverage, creating a sharp discontinuity.

**Method:** RDD (Regression Discontinuity Design)

**Research Question:** Does aging out of parental health insurance at age 26 affect job mobility and entrepreneurship among young adults?

**Data:**
- Source: Census PUMS 2012-2022
- Key variables: AGEP (exact age), HICOV, HINS1 (employer coverage), HINS2 (direct purchase), ESR, COW (class of worker - identifies self-employed), OCCP, INDP, ST, PWGTP
- Sample: Young adults ages 24-28, employed or recently employed
- Sample size estimate: ~800,000 per year at ages 24-28

**Hypotheses:**
- Primary: Losing parental coverage at 26 increases job-to-job transitions toward employer-sponsored insurance jobs and decreases self-employment rates
- Mechanism: "Job lock" - workers stay in or move to jobs offering health benefits to maintain coverage. Loss of parental insurance forces trade-off between desired job and insurance.
- Heterogeneity: Effects stronger in non-Medicaid expansion states (worse outside options), for workers in small firms or gig economy, and for those with health conditions

**Novelty:**
- Literature search: ACA dependent coverage well-studied for health insurance effects (Sommers et al. 2013, Cantor et al. 2012, Akosa Antwi et al. 2013). Less research on labor market outcomes at age-26 discontinuity specifically.
- Gap: Most research examines gaining coverage pre-26, not losing it at 26. Job mobility and entrepreneurship effects understudied.
- Contribution: Novel analysis of age-26 "aging out" discontinuity on job mobility and self-employment, using sharp RDD design with large PUMS samples.

---

## Exploration Notes

### What I searched:
- NBER sample of 30 random papers for inspiration
- NCSL databases for state policy variation
- Web searches for: occupational licensing reforms, ban-the-box laws, automatic voter registration, state EITCs, cosmetology deregulation, universal license recognition, property tax exemptions
- Census PUMS documentation for variable availability

### Ideas considered and rejected:
- **Ban-the-box laws**: Cannot identify people with criminal records in PUMS
- **Property tax exemptions at age 65**: Confounded by Medicare eligibility at same age
- **Military spouse license recognition**: 2023 federal mandate too recent for PUMS data
- **Automatic voter registration**: Political science outcome (turnout), not economic outcome measurable in PUMS
- **Medicare at 65 RDD**: Extensively studied (100+ papers)

### Why these 4 rose to the top:
1. **Universal License Recognition**: Very novel (only 2 causal papers found), clean policy timing, PUMS can measure outcomes
2. **Cosmetology Hours**: Directly replicates/extends recent NBER null finding with better data
3. **State EITC**: Leverages understudied policy variation to test established labor supply theory
4. **ACA Age 26**: Sharp RDD with clean identification, understudied labor market effects
