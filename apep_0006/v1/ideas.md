# Research Ideas

Generated after exploration phase. Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Universal License Recognition and Interstate Migration of Licensed Workers

**Policy:** Universal License Recognition (ULR) laws allow workers with valid out-of-state occupational licenses to receive a comparable license upon moving to the adopting state. Arizona enacted the first ULR law in August 2019, followed by Pennsylvania (2019), Montana (2019), Idaho (2020), and 18+ additional states by 2022.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Do Universal License Recognition laws increase interstate migration of workers in licensed occupations?

**Data:**
- Source: Census PUMS 2017-2022 (5-year pooled)
- Key variables: MIG (mobility status past year), MIGSP (migration state), MIGPUMA, OCCP (occupation), WAGP (wages), ESR (employment status), ST (state), PWGTP (person weight)
- Sample: Adults aged 25-64 in licensed occupations (nurses, teachers, cosmetologists, electricians, plumbers, real estate agents, etc.) who moved in the past year
- Sample size estimate: ~50,000-100,000 interstate migrants in licensed occupations per year

**Hypotheses:**
- Primary: ULR adoption increases interstate in-migration of licensed workers to adopting states by 5-15%
- Mechanism: Lower licensing barriers reduce search costs and increase labor market access for movers
- Heterogeneity: Effects should be strongest for occupations with historically difficult reciprocity (cosmetology, contractors) and among workers near state borders

**Novelty:**
- Literature search: Found 1 NBER paper (WP 34030, 2024) on ULR and healthcare utilization - found NO increase in physician interstate migration, instead increased telehealth. One working paper (Economics Letters 2022) found increased migration in border counties using IRS data.
- Gap: No study has examined ULR effects across ALL licensed occupations using individual-level PUMS data. Healthcare focus misses the majority of licensed workers.
- Contribution: First comprehensive analysis of ULR effects on migration across diverse licensed occupations, with heterogeneity by occupation type and geography.

---

## Idea 2: State Auto-IRA Mandates and Worker Job Mobility

**Policy:** Several states mandated automatic enrollment of workers into retirement savings accounts (auto-IRAs) for employers without existing retirement plans: Oregon (OregonSaves, phased 2017-2020), Illinois (Secure Choice, phased 2018-2020), California (CalSavers, phased 2019-2022). Workers are auto-enrolled at 5% contribution but can opt out.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Do state auto-IRA mandates affect worker job mobility and labor market outcomes?

**Data:**
- Source: Census PUMS 2016-2022
- Key variables: ESR (employment status), WAGP (wages), WKHP (hours worked), COW (class of worker), MIG (mobility status), OCCP (occupation), INDP (industry), RETIRP (retirement income), PWGTP
- Sample: Private sector workers aged 22-64 in mandate states vs. non-mandate control states
- Sample size estimate: ~500,000+ workers per year across Oregon, Illinois, California

**Hypotheses:**
- Primary: Auto-IRA mandates increase job tenure and reduce job switching by 2-5% as workers value the retirement benefit
- Mechanism: Portability of auto-IRA reduces "job lock" from losing employer-sponsored plans, but auto-enrollment creates a new form of benefit attachment
- Heterogeneity: Effects should be strongest for low-income workers and small-firm employees who previously lacked retirement access

**Novelty:**
- Literature search: Found 2 NBER papers - WP 28469 on OregonSaves savings behavior/opt-out, WP 31398 on firm responses (firms creating private plans). Both focus on savings outcomes, NOT labor market effects.
- Gap: No research on labor market consequences - job mobility, wages, employment - of auto-IRA mandates
- Contribution: First analysis of auto-IRA effects on labor market outcomes using individual-level PUMS data

---

## Idea 3: State Paid Family Leave and Father's Labor Supply

**Policy:** State Paid Family Leave (PFL) programs provide wage replacement during family leave: California (2004), New Jersey (2009), Rhode Island (2014), New York (2018), Washington (2020). Benefits typically 6-12 weeks at 50-90% wage replacement.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Does state paid family leave increase father's leave-taking and affect male labor supply outcomes?

**Data:**
- Source: Census PUMS 2003-2022
- Key variables: SEX, AGEP, ESR, WAGP, WKHP (hours worked), WKW (weeks worked), MARHT (marital history), FER (gave birth in past 12 months - for identifying households with new children), PWGTP
- Sample: Married men aged 22-45 in PFL states vs. control states
- Sample size estimate: ~100,000+ married men of childbearing age per year in PFL states

**Hypotheses:**
- Primary: PFL adoption increases male labor force participation among fathers of young children by 1-3 percentage points as leave flexibility reduces household strain
- Mechanism: Access to paid leave allows fathers to take time off without job loss, potentially increasing bonding and subsequent workplace productivity
- Heterogeneity: Effects should be strongest for low-income fathers who couldn't afford unpaid leave and for households where both parents work

**Novelty:**
- Literature search: Extensive research on maternal outcomes from PFL (Rossin-Slater, Baum, Byker). Found ~5 papers specifically on father outcomes, mostly using administrative data from single states.
- Gap: Limited multi-state analysis of father's labor supply using nationally representative PUMS data
- Contribution: Comprehensive cross-state DiD analysis of PFL effects on fathers' employment, wages, and hours using PUMS

---

## Idea 4: Pre-ACA State Dependent Coverage Laws and Young Adult Employment

**Policy:** Before the 2010 ACA mandated dependent coverage to age 26, 34 states enacted similar laws between 2005-2010. New Jersey (2006) extended coverage to age 31, others to age 26-30. These laws required insurers to offer continued dependent coverage for young adults.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did pre-ACA state dependent coverage laws affect young adult labor supply and job choice?

**Data:**
- Source: Census PUMS 2004-2010 (pre-ACA period)
- Key variables: AGEP (age), HINS1-5 (health insurance type), ESR (employment status), WAGP, WKHP, COW (class of worker - captures self-employment), SCHL (education), ST (state), PWGTP
- Sample: Young adults aged 19-30 in early-adopting states vs. control states
- Sample size estimate: ~200,000 young adults per year in treatment states

**Hypotheses:**
- Primary: State dependent coverage laws reduced young adult labor supply by 1-2 percentage points as health insurance was "de-linked" from employment
- Mechanism: Access to parental coverage reduces need for employer-sponsored insurance, enabling risk-taking (entrepreneurship, job search, education)
- Heterogeneity: Effects should be strongest for young adults in states with generous extensions (age 30+) and for those without college degrees

**Novelty:**
- Literature search: Found 1 main paper (Depew & Bailey 2015, Journal of Health Economics) examining insurance coverage effects. Some work on ACA age-26 provision (Antwi, Moriya, Simon 2013).
- Gap: Limited analysis of labor supply and job choice effects using PUMS microdata for the pre-ACA state variation
- Contribution: Clean pre-ACA analysis isolating state-level variation before federal policy confounded the picture, with focus on labor market rather than coverage outcomes

---

## Exploration Notes

**Searched and Considered:**
- NBER working papers database for recent policy evaluations
- NCSL state policy comparisons for occupational licensing, paid leave, retirement mandates
- Web search for implementation dates and policy details

**Rejected Ideas:**
- Ban-the-Box laws: Extensively studied (NBER WPs 32273, 22469, 24381) with mixed/null results
- Cannabis legalization: Already evaluated (NBER WP 30813) with null employment effects
- Medicaid work requirements: Limited implementation (only Arkansas actually disenrolled people)
- Minimum wage: Massively over-studied
- State EITC: Well-covered territory

**Why These 4:**
1. ULR (Idea 1): Most novel - only 1 narrow NBER paper on healthcare, broader occupation analysis is virgin territory
2. Auto-IRA (Idea 2): Novel angle - existing research ignores labor market outcomes entirely
3. PFL-Fathers (Idea 3): Less studied heterogeneity in otherwise well-covered policy
4. Pre-ACA Coverage (Idea 4): Clean historical identification, underexplored labor outcomes

**Recommendation:** Ideas 1 and 2 have strongest novelty case. Idea 1 (ULR) has cleanest identification with clear state-level policy variation and measurable migration outcome in PUMS.
