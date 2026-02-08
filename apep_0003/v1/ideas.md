# Research Ideas

Generated after exploration phase for assigned states: **Nebraska (NE), Indiana (IN), South Carolina (SC)**.

Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Indiana Ban-the-Box Preemption and Employment Outcomes

**Policy:** Indiana Senate Bill 312 (2017) made Indiana the first state in the US to preempt local ban-the-box ordinances. Effective July 1, 2017, the law prohibited local governments from restricting employers' ability to inquire about criminal history during hiring. This nullified Indianapolis's 2014 ban-the-box ordinance that had applied to city contractors and public employees.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did Indiana's preemption of local ban-the-box laws affect employment outcomes for demographic groups with higher criminal record rates, and did it increase statistical discrimination in hiring?

**Data:**
- Source: Census PUMS 2014-2020 (pre/post July 2017)
- Key variables: ESR (employment status), WAGP (wages), WKHP (hours), AGEP (age), SEX, RAC1P (race), SCHL (education), ST (state), PWGTP (weight)
- Sample: Working-age adults (18-64) in Indiana vs. comparison Midwest states (Ohio, Michigan, Illinois) without similar preemption
- Sample size estimate: ~500,000 person-years across treatment/control states

**Hypotheses:**
- Primary: Employment rates for young Black males (group with highest criminal record rates) decreased in Indiana relative to comparison states after the preemption, due to reduced protection from statistical discrimination
- Mechanism: When employers can ask about criminal history early, they may use demographic proxies less; when preemption removes BTB protections, employers can screen earlier and groups with higher criminal record rates lose interview opportunities
- Heterogeneity: Effect should be strongest for young (<35), male, Black, low-education workers in Indianapolis metro area

**Novelty:**
- Literature search: Doleac & Hansen (2020 JLE) studied effects of BTB adoption on employment, finding unintended discrimination effects. However, NO studies have examined the reverse: the effect of PREEMPTING BTB laws.
- Gap: The policy direction (removing worker protections) is unstudied. Indiana is the only state with this preemption.
- Contribution: First causal estimate of what happens when ban-the-box protections are removed, providing policy-relevant evidence for states considering similar preemption

---

## Idea 2: South Carolina Teacher Minimum Salary Increase and Teacher Supply

**Policy:** In Fiscal Year 2019-2020, South Carolina permanently increased each step of the state minimum teacher salary schedule by 5% above the FY2018-2019 levels. This affected approximately 50,000 public school teachers across the state.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did South Carolina's 5% teacher salary increase affect teacher labor supply, retention, and the quality composition of the teaching workforce compared to neighboring states?

**Data:**
- Source: Census PUMS 2017-2022 (pre/post FY2019-2020)
- Key variables: OCCP (occupation - identify teachers via codes 2310-2340), ESR (employment status), WAGP (wages), SCHL (education), AGEP (age), INDP (industry - education sector), ST (state), PWGTP (weight)
- Sample: Workers in education occupations (teachers, instructional coordinators) aged 22-65 in SC vs. neighboring states (NC, GA) without similar salary increases
- Sample size estimate: ~50,000 education workers across treatment/control states

**Hypotheses:**
- Primary: Teacher employment and wages in SC increased relative to NC/GA after the salary increase, with improved retention (fewer leaving teaching)
- Mechanism: Higher base salaries increase teacher labor supply by making teaching more competitive with private sector alternatives
- Heterogeneity: Effect should be strongest for early-career teachers (where base salary matters most) and in rural districts (where supplemental pay is lower)

**Novelty:**
- Literature search: Teacher salary research is extensive, but most studies focus on performance pay or local salary policies. State-wide minimum salary floor increases are understudied.
- Gap: Recent state-level teacher salary reforms (post-2018) have not been causally evaluated with individual-level data
- Contribution: First DiD estimate of a state minimum teacher salary increase using PUMS microdata, relevant for ongoing teacher shortage debates

---

## Idea 3: Indiana Second Chance Law Employment Protections

**Policy:** Indiana's Second Chance Law (Indiana Code 35-38-9), revised and expanded in 2013, prohibits employers from discriminating against job applicants based on expunged or sealed criminal records. Effective July 1, 2013, employers cannot ask about expunged convictions and applicants can legally answer "No" to criminal history questions for expunged records.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did Indiana's 2013 Second Chance Law improve employment outcomes for demographic groups most likely to benefit from criminal record expungement?

**Data:**
- Source: Census PUMS 2010-2017 (pre/post July 2013)
- Key variables: ESR (employment status), WAGP (wages), COW (class of worker), AGEP (age), SEX, RAC1P (race), SCHL (education), ST (state), PWGTP (weight)
- Sample: Working-age adults (25-54) in Indiana vs. comparison states (Ohio, Kentucky, Illinois) without similar comprehensive expungement protection
- Sample size estimate: ~400,000 person-years

**Hypotheses:**
- Primary: Employment rates for groups with high criminal record prevalence (low-education, young males, Black males) increased in Indiana relative to comparison states after 2013
- Mechanism: Employer protections from negligent hiring liability + applicant ability to answer "No" to criminal history questions increases hiring of those with expungeable records
- Heterogeneity: Effect should be strongest for those 5+ years post-conviction (eligible for misdemeanor expungement) and those in high-turnover occupations

**Novelty:**
- Literature search: NBER Working Paper 32394 (2024) studied expungement in MD, NJ, PA, TX - found limited employment effects. However, Indiana's unique employer liability protections haven't been studied.
- Gap: Indiana's law includes strong employer safe harbors not present in other states; this mechanism is unstudied
- Contribution: Tests whether employer liability protection is a necessary complement to record-clearing for employment effects

---

## Idea 4: Nebraska Occupational Board Reform Act and Licensed Employment

**Policy:** Nebraska's Occupational Board Reform Act (LB 299) created a "sunset" review process requiring state regulators to analyze one-fifth of occupational regulations annually on a five-year cycle. The law mandates that regulations be the "least restrictive" and "necessary to protect the public." The Act also eased licensing barriers for people with criminal records.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did Nebraska's occupational licensing reform reduce barriers to entry in licensed occupations and increase employment in affected fields?

**Data:**
- Source: Census PUMS 2015-2022
- Key variables: OCCP (occupation), ESR (employment status), WAGP (wages), SCHL (education), AGEP (age), ST (state), PWGTP (weight)
- Sample: Workers in occupations subject to state licensing (personal appearance services, healthcare aides, construction trades) in NE vs. comparison states (IA, KS, SD) without similar reforms
- Sample size estimate: ~100,000 licensed workers across comparison

**Hypotheses:**
- Primary: Employment in licensed occupations increased in Nebraska relative to comparison states, particularly in occupations where requirements were deemed unnecessarily restrictive
- Mechanism: Lower barriers to entry (fewer training hours, lower fees) increase labor supply in licensed occupations
- Heterogeneity: Effect should be strongest for lower-barrier licensed occupations (cosmetology, personal care) rather than highly-regulated professions (nursing)

**Novelty:**
- Literature search: Institute for Justice has documented Nebraska's reforms descriptively. Kleiner & Krueger (2013 JOLE) study licensing broadly. State-specific comprehensive reform effects understudied.
- Gap: Most licensing research is cross-sectional; few studies exploit state-level comprehensive reform
- Contribution: First causal evaluation of a state-wide "least restrictive regulation" mandate on licensed employment

---

## Idea 5: South Carolina Job Tax Credit County Tier System

**Policy:** South Carolina's Job Tax Credit program provides tax credits of $1,500-$8,000 per new job created, with amounts varying by county "tier" classification. Counties are tiered (I-IV) based on unemployment rates and per capita income, with Tier IV (most economically distressed) counties receiving the highest credits.

**Method:** RDD (Regression Discontinuity Design)

**Research Question:** Do higher job tax credits in economically distressed counties (at the tier threshold boundary) lead to increased employment growth?

**Data:**
- Source: Census PUMS 2015-2022 + county tier classification data
- Key variables: ESR (employment status), WAGP (wages), INDP (industry), PUMA (geography proxy), ST (state), PWGTP (weight)
- Sample: Working-age adults in South Carolina counties near tier threshold boundaries
- Sample size estimate: ~200,000 person-years in SC; subset near tier boundaries smaller

**Hypotheses:**
- Primary: Employment rates are higher in counties just above the threshold qualifying for higher tax credits compared to counties just below
- Mechanism: Higher tax credits reduce effective labor costs for employers, increasing labor demand
- Heterogeneity: Effect should be strongest in manufacturing/warehousing sectors (eligible industries) and for full-time positions (credit requires full-time)

**Novelty:**
- Literature search: Enterprise zone literature is large but results are mixed. SC's specific tier system with sharp cutoffs based on unemployment/income has not been evaluated.
- Gap: County-level RDD on state job tax credits with PUMS microdata is novel
- Contribution: Clean RDD estimate of intensive margin effects of job creation tax credits

---

## Exploration Notes

**Assigned states:** Nebraska (NE), Indiana (IN), South Carolina (SC)

**Search strategy:**
1. Started with broad web searches for unique policies in each state (2017-2021 time period)
2. Focused on labor/employment policies measurable with PUMS
3. Checked novelty via NBER + Google Scholar searches
4. Verified policy timing and specific provisions via government sources

**Rejected ideas:**
- Nebraska voter registration reforms: No clear employment outcome
- Nebraska property tax credit (2020): Not directly measurable in PUMS, outcome is tax burden not employment
- Indiana unemployment insurance: No work-sharing program (Indiana doesn't have one)
- South Carolina Medicaid: State has not expanded, no clean reform to study
- South Carolina broadband expansion (GREAT program): Too recent, outcome is infrastructure not individual employment

**Top picks rationale:**
1. **Indiana BTB Preemption (Idea 1)**: Highest novelty - only state with this policy direction, direct employment outcome, clear comparison states
2. **SC Teacher Salary (Idea 2)**: Clean timing, identifiable occupation, relevant policy debate
3. **Indiana Second Chance (Idea 3)**: Unique employer protections component, understudied Indiana-specific effects
4. **NE Licensing Reform (Idea 4)**: Comprehensive reform, clear mechanism, but may be harder to identify affected occupations
5. **SC Job Tax Credit RDD (Idea 5)**: Clean design but geography limitation (PUMA may not align with county tier boundaries)
