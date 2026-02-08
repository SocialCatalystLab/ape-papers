# Research Ideas: Policy Effects on Loneliness

Generated for states: West Virginia, Massachusetts, Wisconsin
User preference: Estimate policy effect on loneliness
Data constraint: Census PUMS (proxy outcomes for loneliness: living alone, employment, group quarters, migration)

---

## Idea 1: Does Social Security Eligibility at Age 62 Reduce Living Alone Among Older Adults?

**Policy:** Federal Social Security early retirement eligibility at age 62. Before this age, workers without substantial savings or employer pensions may be forced to continue working regardless of preference. At exactly 62, individuals can begin claiming reduced benefits (70% of full retirement amount), providing guaranteed income that could facilitate household formation decisions.

**Method:** RDD

**Research Question:** Does reaching Social Security early eligibility at age 62 reduce the probability of living alone among older adults, as income security enables co-residence with partners, adult children, or other family members?

**Loneliness Mechanism:** Living alone is the strongest demographic predictor of loneliness among older adults (Hawkley & Cacioppo, 2010). Social Security income could reduce living alone through multiple channels: (1) enabling co-residence with a partner who was previously "locked out" by housing costs, (2) allowing geographic relocation to be near family, (3) reducing the need to maintain independent housing near former workplace.

**Data:**
- Source: Census PUMS 2015-2023 (pooled for power)
- Running variable: AGEP (age)
- Primary outcome: NP=1 (lives in 1-person household)
- Secondary outcomes: PARTNER (has unmarried partner), MIG (moved in past year), MIGSP (migration PUMA)
- Sample: Ages 58-66, non-institutionalized
- Controls: SEX, RAC1P, SCHL, DIS, MAR (marital status at baseline by cohort)
- Sample size estimate: ~2.5 million person-year observations

**Hypotheses:**
- Primary: Probability of living alone decreases discontinuously at age 62 as income security enables household consolidation
- Heterogeneity: Effect strongest for (1) previously unmarried individuals who gain ability to form partnerships, (2) lower-income individuals for whom SS represents larger share of income, (3) those in high cost-of-living areas where housing costs drove solo living
- Placebo test: No discontinuity at 62 for high-wealth individuals who already had income security

**Novelty:**
- Literature search: Extensive work on SS and labor supply, almost none on living arrangements
- Gap: Complete absence of RDD estimates of SS eligibility on household composition
- Contribution: First causal estimate of whether income security programs reduce social isolation (as measured by living alone)

**Why This Could Work:** The 62 threshold is federally uniform and sharp. Census PUMS has excellent age data and household composition variables. Living alone is a well-validated loneliness proxy that's measurable in survey data.

---

## Idea 2: Does Medicare Eligibility Reduce Employment-Based Social Connection?

**Policy:** Universal Medicare eligibility at age 65. Before this age, many workers remain employed specifically to maintain health insurance coverage ("job lock"). At 65, Medicare provides guaranteed coverage, potentially enabling retirement—but retirement itself is associated with reduced social contact through workplace relationships.

**Method:** RDD

**Research Question:** Does Medicare eligibility at age 65 cause a discontinuous increase in workforce exit, and does this transition to non-employment increase social isolation as measured by living alone?

**Loneliness Mechanism:** The workplace is a primary site of social interaction for adults. Retirement can sever these connections without necessarily replacing them. This creates a potential "retirement loneliness trap" where health insurance freedom enables retirement, but retirement reduces daily social contact.

**Data:**
- Source: Census PUMS 2015-2023
- Running variable: AGEP (age)
- Primary outcomes: (1) ESR (employment status), (2) WKHP (hours worked), (3) NP=1 (living alone)
- Mediation analysis: Does the effect of age-65 on living alone operate through employment exit?
- Sample: Ages 61-69, non-institutionalized
- Controls: SEX, RAC1P, SCHL, DIS, HINS1-HINS7 (pre-65 insurance status by cohort)
- Sample size estimate: ~3 million person-year observations

**Hypotheses:**
- First stage: Employment and hours worked decline discontinuously at 65
- Second stage: Living alone increases discontinuously at 65, mediated by employment exit
- Heterogeneity: Effect strongest for (1) those with employer-sponsored insurance pre-65, (2) single individuals without partner-based social support, (3) those in occupations with high social interaction (retail, teaching, healthcare)
- Alternative: If Medicare enables workers to STAY employed without fear of insurance loss, we might see increased employment and reduced living alone

**Novelty:**
- Literature search: Many papers on Medicare and employment, none linking to loneliness outcomes
- Gap: No research on whether health insurance transitions affect social connectedness
- Contribution: First evidence on the social isolation consequences of retirement enabled by Medicare

**Why This Could Work:** The age-65 Medicare threshold is sharp and universal. The employment effects are well-documented, so we're extending to a novel outcome (loneliness proxy).

---

## Idea 3: Do Medicaid Expansion States See Reduced Institutionalization and Living Alone Among Low-Income Elderly?

**Policy:** Affordable Care Act Medicaid expansion (2014+). States that expanded Medicaid increased health coverage for low-income adults, potentially reducing the need for institutionalization (nursing homes) and enabling community-based living with family support.

**Method:** DiD

**Research Question:** Did Medicaid expansion states experience differential reductions in institutionalization and living alone among low-income adults aged 55-64, compared to non-expansion states?

**Loneliness Mechanism:** Nursing home residence is associated with profound loneliness despite being surrounded by other residents. Community-based living (especially with family) is associated with lower loneliness. Medicaid expansion could reduce nursing home admissions by: (1) improving preventive care that delays disability onset, (2) covering home health services that enable aging in place, (3) reducing financial catastrophe that forces institutionalization.

**Data:**
- Source: Census PUMS 2010-2019 (pre/post expansion)
- Treatment: State Medicaid expansion status and timing
- Primary outcomes: (1) GQ (group quarters type - institutional vs household), (2) NP=1 (living alone among non-institutionalized)
- Sample: Ages 55-64, income below 138% FPL (expansion population)
- Treatment states in our assignment: Massachusetts (already expanded pre-ACA), Wisconsin (partial expansion), West Virginia (expanded 2014)
- Controls: Age, sex, race, education, disability status, year FE, state FE

**Hypotheses:**
- Primary: Expansion states see reduced institutionalization rates among low-income 55-64 population
- Secondary: Among non-institutionalized, expansion states see reduced living alone (family can provide support without losing coverage)
- Event study: Effects emerge 1-2 years post-expansion as health improvements accumulate
- Heterogeneity: Effects strongest for disabled individuals at highest institutionalization risk

**Novelty:**
- Literature search: Medicaid expansion studies focus on coverage, utilization, mortality—not living arrangements
- Gap: No causal evidence on expansion effects on social isolation proxies
- Contribution: First DiD estimate linking Medicaid expansion to loneliness-related outcomes

**Challenges:** Massachusetts already had near-universal coverage pre-ACA, so limited treatment variation. West Virginia is our cleanest expansion case.

---

## Idea 4: Does Reaching Age 60 Senior Services Eligibility Reduce Living Alone?

**Policy:** The Older Americans Act (OAA) designates age 60 as the threshold for senior services eligibility, including congregate meals, home-delivered meals (Meals on Wheels), senior center access, transportation assistance, and caregiver support. These services are administered by state Area Agencies on Aging.

**Method:** RDD

**Research Question:** Does becoming eligible for OAA senior services at age 60 cause a discontinuous reduction in living alone, as access to congregate meals, senior centers, and support services enables social connection and aging in place with others?

**Loneliness Mechanism:** OAA services directly target social isolation through: (1) congregate meals that require leaving home and dining with others, (2) senior center programming that provides structured social activities, (3) transportation assistance that enables visiting family and friends. These services could facilitate household formation by reducing the isolation costs of co-residence in areas with limited services.

**Data:**
- Source: Census PUMS 2015-2023
- Running variable: AGEP (age)
- Primary outcome: NP=1 (living alone)
- Secondary outcomes: JWTRNS (transportation mode), MIG (moved past year), ESR (employment)
- Sample: Ages 56-64, non-institutionalized
- Focus states: West Virginia (high OAA utilization, rural isolation), Massachusetts (robust senior services), Wisconsin (AAA network)
- Sample size estimate: ~4 million person-year observations

**Hypotheses:**
- Primary: Living alone decreases discontinuously at age 60 as senior services enable social connection
- Heterogeneity: Effect strongest in (1) rural areas with limited services for under-60, (2) lower-income individuals who couldn't afford similar services, (3) those without cars who benefit from transportation assistance
- Mechanism test: If effect operates through OAA, should see larger effects in states with higher per-capita OAA spending

**Novelty:**
- Literature search: Very limited causal research on OAA effects; focus has been on nutrition outcomes
- Gap: No RDD on OAA eligibility and social outcomes
- Contribution: First sharp RDD estimate of senior services on living arrangements

**Challenge:** OAA eligibility is not perfectly enforced—some programs serve under-60 populations. Need to verify sharpness of cutoff in utilization data.

---

## Idea 5: Does Wisconsin's IRIS Self-Directed Care Program Reduce Institutionalization?

**Policy:** Wisconsin's Include, Respect, I Self-Direct (IRIS) program began July 2008 as a 1915(c) Medicaid waiver allowing frail seniors and adults with disabilities to self-direct their long-term care services with an individualized budget. Unlike traditional Medicaid HCBS, IRIS gives participants choice over who provides their care (including family members).

**Method:** DiD (comparing Wisconsin to similar Midwest states without self-directed programs)

**Research Question:** Did Wisconsin's adoption of the IRIS self-directed care model reduce institutionalization rates among elderly Medicaid beneficiaries compared to neighboring states?

**Loneliness Mechanism:** Self-directed care enables participants to (1) hire family members as paid caregivers, strengthening family bonds, (2) remain in their own homes and communities, (3) choose care that maintains social connections (e.g., transportation to family events). Traditional institutional care severs community ties and is associated with severe loneliness.

**Data:**
- Source: Census PUMS 2006-2015 (pre/post IRIS)
- Treatment: Wisconsin vs. control states (Minnesota, Iowa, Illinois, Michigan—states without similar self-directed programs in this period)
- Primary outcome: GQ = institutional group quarters (nursing home)
- Secondary outcomes: NP=1 (living alone), MULTG (multigenerational household)
- Sample: Ages 65+, low-income (likely Medicaid eligible), with disability
- Controls: Age, sex, race, education, disability type, year FE, state FE

**Hypotheses:**
- Primary: Wisconsin sees relative decline in institutionalization among disabled elderly after 2008
- Secondary: Corresponding increase in multigenerational household residence
- Event study: Effects build gradually as IRIS enrollment expands
- Heterogeneity: Strongest for physically disabled (vs. cognitively impaired who may be unable to self-direct)

**Novelty:**
- Literature search: IRIS has been evaluated for costs and satisfaction, not population-level living arrangement outcomes
- Gap: No DiD comparing Wisconsin's self-directed model to traditional HCBS states
- Contribution: First causal estimate of self-directed care on community vs. institutional living

**Note:** Wisconsin is one of our assigned states, making this particularly relevant.

---

## Summary Table

| Idea | Policy | Method | Primary Outcome | Novelty Level |
|------|--------|--------|-----------------|---------------|
| 1 | SS Early Eligibility (62) | RDD | Living alone | Very High - no prior work |
| 2 | Medicare (65) | RDD | Employment → Living alone | High - novel outcome |
| 3 | Medicaid Expansion | DiD | Institutionalization, living alone | Medium-High |
| 4 | OAA Senior Services (60) | RDD | Living alone | Very High - understudied |
| 5 | Wisconsin IRIS | DiD | Institutionalization | High - state-specific |

## Recommendation

**Idea 1 (Social Security at 62 → Living Alone)** offers the best combination of:
- Sharp, federally uniform threshold with clear timing
- Novel research question (no prior RDD on SS and living arrangements)
- Clean measurement (age in months if available, living alone is binary)
- Large sample size for power
- Clear policy relevance to loneliness epidemic

**Idea 4 (OAA at 60)** is the backup if Idea 1 faces identification challenges, as it directly targets senior services designed to reduce isolation.
