# Research Ideas

Generated after exploration phase. Aim for 3-5 ideas covering different policies/methods.
Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: State Nurse Practitioner Full Practice Authority and Labor Supply

**Policy:** State laws granting nurse practitioners (NPs) full practice authority to practice independently without physician supervision. States have moved from restricted to reduced to full practice authority at different times (e.g., Nevada 2013, Nebraska 2015, North Dakota 2011, Maryland 2015, Minnesota 2015, Arizona 2001).

**Method:** DiD (Difference-in-Differences)

**Research Question:** Does granting nurse practitioners full practice authority increase their labor supply, self-employment rates, and wages?

**Data:**
- Source: Census PUMS 2010-2023
- Key variables: OCCP (occupation code for NPs ~3256), ESR (employment status), WKHP (hours worked), SEMP (self-employment income), WAGP (wages), PWGTP, ST
- Sample: Working-age adults (25-64) in healthcare occupations, particularly NPs
- Sample size estimate: ~15,000-25,000 NP observations per year across all states

**Hypotheses:**
- Primary: Full practice authority increases NP labor supply (hours, employment probability) and self-employment rates
- Mechanism: Reduced regulatory burden allows NPs to open independent practices, work in underserved areas, and expand scope of services
- Heterogeneity: Effects should be strongest in rural areas and states with physician shortages

**Novelty:**
- Literature search: Found NBER Working Paper 26896 (Markowitz & Adams) examining SOP laws on APRN labor supply, published in American Journal of Health Economics 2022. Also found NBER 28192 on classification of NP SOP laws. Literature exists but is recent and limited (5-10 papers).
- Gap: Existing studies use older data (pre-2020). The wave of states adopting full practice authority during COVID-19 (2020-2022) is largely unstudied. Also, wage effects and self-employment transitions less explored.
- Contribution: Updated analysis with post-COVID data, focus on self-employment and wage outcomes beyond hours worked

---

## Idea 2: State Compulsory Schooling Age Increases and Educational/Labor Market Outcomes

**Policy:** State laws raising the compulsory school attendance age from 16 to 17 or 18. Several states enacted these changes in different years: Indiana (2013, 16→18), Wisconsin (2017, 18), New Mexico (2019, 18), Maryland (2017, 18), Michigan (2010, 18).

**Method:** DiD (Difference-in-Differences)

**Research Question:** Do increases in the compulsory schooling age from 16 to 18 reduce dropout rates and improve long-term labor market outcomes (employment, wages)?

**Data:**
- Source: Census PUMS 2005-2023
- Key variables: SCHL (educational attainment), ESR (employment status), WAGP (wages), AGEP (age), ST (state), PWGTP, POBP (birth state for historical exposure)
- Sample: Young adults (18-30) who would have been subject to the law changes based on their birth cohort and state
- Sample size estimate: ~50,000+ per state-year for affected cohorts

**Hypotheses:**
- Primary: Raising compulsory age to 18 increases high school graduation rates by 2-5 percentage points and wages by 5-10%
- Mechanism: Requiring attendance until 18 keeps at-risk students in school past the critical 16-17 age when dropout risk peaks
- Heterogeneity: Effects strongest for low-income males and minorities who have higher baseline dropout rates

**Novelty:**
- Literature search: Classic papers by Angrist & Krueger (1991) use quarter of birth as IV. Recent research on Netherlands (Cabus & De Witte 2011). Most US literature focuses on historical compulsory schooling laws (early 20th century).
- Gap: Recent state-level increases (2010s) in US compulsory age have not been systematically evaluated using modern causal methods
- Contribution: First rigorous DiD evaluation of 2010s US compulsory schooling age reforms using contemporary PUMS data

---

## Idea 3: State Automatic Voter Registration (AVR) and Civic Participation

**Policy:** Automatic voter registration implemented at DMVs and other agencies. Oregon was first (2016), followed by California, Colorado, Vermont (2017), Washington, West Virginia (2018), Nevada, Illinois, Maine (2019), New Mexico, New Jersey (2020), etc.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Does automatic voter registration increase civic engagement and does this effect vary by demographic groups (age, race, education)?

**Data:**
- Source: Census PUMS 2010-2023 (limited civic variables, would need to rely on voting supplement data)
- Key variables: AGEP, SEX, RAC1P, SCHL, ST, PWGTP
- Sample: Voting-age adults (18+)
- Sample size estimate: Very large (~2-3M per year)

**Hypotheses:**
- Primary: AVR increases voter registration rates by 2-5 percentage points
- Mechanism: Opt-out design reduces transaction costs of registration; automatic updates improve roll accuracy
- Heterogeneity: Larger effects among young voters, minorities, and those with less education who face higher registration barriers

**Novelty:**
- Literature search: McGhee, Hill, and Romero studies on AVR effects; Brennan Center reports. MIT Election Lab research. Active research area (10-20 papers).
- Gap: PUMS doesn't directly measure voting behavior. This idea is weaker for PUMS analysis.
- Contribution: Limited - better suited for voter file data analysis

**Assessment:** This idea is less feasible with PUMS. Deprioritize.

---

## Idea 4: State Paid Family Leave and Maternal Labor Force Participation

**Policy:** State paid family leave (PFL) programs. California (benefits started 2004), New Jersey (2009), Rhode Island (2014), New York (2018), Washington (2020), Massachusetts (2021), Connecticut (2022).

**Method:** DiD (Difference-in-Differences)

**Research Question:** Does state paid family leave increase maternal labor force participation and reduce the "motherhood penalty" in wages?

**Data:**
- Source: Census PUMS 2005-2023
- Key variables: ESR (employment status), WAGP (wages), SEX, AGEP, MAR (marital status), FER (gave birth in past 12 months), WKHP (hours), ST, PWGTP
- Sample: Women of childbearing age (18-45), with focus on those with children
- Sample size estimate: ~500,000+ women per year, ~50,000+ with recent births

**Hypotheses:**
- Primary: PFL increases labor force participation among mothers by 3-8 percentage points
- Mechanism: PFL allows mothers to maintain employment attachment, reduces need to quit jobs around childbirth
- Heterogeneity: Strongest effects for low-income women and those without employer-provided leave

**Novelty:**
- Literature search: Extensive literature on California's program (Rossin-Slater, Ruhm, Waldfogel). Studies on NJ, RI, NY emerging. 50+ papers on PFL effects globally.
- Gap: Newer state programs (WA 2020, MA 2021, CT 2022) are less studied. Cross-state comparison using recent data is limited.
- Contribution: Updated multi-state DiD analysis including newest state programs with contemporary PUMS data

---

## Idea 5: State Hair Braider Licensing Deregulation and Entrepreneurship

**Policy:** State deregulation of hair braiding from cosmetology licensing requirements. Mississippi (no license required), Texas (exempted 2015), Iowa (2018), Nebraska (2018), Tennessee (no license), Arkansas (2019), etc. In 2005, 29 states required full cosmetology licenses; by 2020, only 7 did.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Does eliminating occupational licensing requirements for hair braiders increase self-employment and entrepreneurship among African American women?

**Data:**
- Source: Census PUMS 2010-2023
- Key variables: OCCP (occupation codes for personal appearance workers ~4510-4540), COW (class of worker - self-employed vs employee), SEMP (self-employment income), RAC1P, SEX, ST, PWGTP
- Sample: Personal appearance workers, with focus on African American women
- Sample size estimate: ~20,000-30,000 personal appearance workers per year; subset of African American women ~3,000-5,000

**Hypotheses:**
- Primary: Deregulation increases self-employment rates among personal appearance workers by 5-15 percentage points
- Mechanism: Removing 1000+ hours of cosmetology training requirements and $5,000-$20,000 costs enables entry into self-employment
- Heterogeneity: Effects concentrated among African American women (who dominate hair braiding culturally)

**Novelty:**
- Literature search: Kleiner & Krueger (2013) on occupational licensing generally. Institute for Justice litigation and reports. Academic research on hair braiding specifically is sparse (<5 papers).
- Gap: No rigorous causal evaluation of hair braiding deregulation on labor market outcomes using microdata
- Contribution: First DiD study of hair braider deregulation using Census PUMS, focusing on entrepreneurship and income effects for affected demographic groups

---

## Exploration Notes

**Sources consulted:**
- NBER working papers via search_papers.py random sample
- Web searches: NCSL, state policy databases, academic literature
- Census PUMS documentation for variable availability

**Ideas considered and rejected:**
1. Medicare at 65 RDD - extremely well-studied (500+ papers)
2. Medicaid expansion DiD - extensively studied (100+ papers)
3. Ban-the-Box employment effects - already 4+ NBER papers with mixed findings
4. State minimum wage - very heavily studied
5. Automatic voter registration - PUMS doesn't have voting behavior variables

**Why these 5 rose to the top:**
1. **NP Full Practice Authority**: Recent policy changes, limited literature, good PUMS occupation codes
2. **Compulsory Schooling Age**: Recent US reforms (2010s) understudied, classic identification strategy
3. **AVR**: Deprioritized - poor PUMS fit
4. **Paid Family Leave**: Recent state adoptions (2020-2022) provide new identification variation
5. **Hair Braider Licensing**: Novel, no rigorous causal research exists, interesting demographic angle

**Top recommendations for ranking:** Ideas 2, 5, and 1 appear most promising for novelty and identification quality.
