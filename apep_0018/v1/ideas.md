# Research Ideas: RDD Designs for Intergenerational Mobility

**Method Preference:** Regression Discontinuity Design (RDD)
**Topic Focus:** Understudied historical policies affecting intergenerational mobility
**Data Source:** Opportunity Insights (county/commuting zone-level mobility outcomes for 1978-1992 birth cohorts)

---

## Idea 1: Head Start Grant-Writing Assistance and Intergenerational Mobility

**Policy:** In 1965, the Office of Economic Opportunity (OEO) provided technical assistance for Head Start grant-writing to the 300 poorest U.S. counties. This created a sharp discontinuity in Head Start funding and participation rates that persisted for decades.

**Method:** RDD (Sharp)

**Research Question:** Did children born in counties that received OEO grant-writing assistance (the 300 poorest counties in 1960) experience greater intergenerational mobility than children born in counties just below the poverty threshold?

**RDD Design:**
- **Running variable:** County 1960 poverty rate
- **Cutoff:** 59.1984 (threshold for being among the 300 poorest counties)
- **Treatment:** OEO technical assistance → Higher Head Start funding → Greater early childhood program participation
- **Bandwidth:** Counties within 18 percentage points of the cutoff (Ludwig-Miller specification)

**Data:**
- Source: Opportunity Insights county-level mobility data (1978-1983 birth cohorts)
- Merge: County 1960 poverty rates from Ludwig-Miller (2007) replication data
- Key variables: Mean household income rank at age 26-35, probability of reaching top quintile, college attendance rates
- Sample: ~2,783 U.S. counties (excluding Alaska)
- Outcomes measured at county level

**Hypotheses:**
- Primary: Counties above the OEO cutoff exhibit 2-5 percentile point higher mean income rank for children from low-income families
- Mechanism: Head Start improves cognitive skills, health, and parental engagement, leading to better adult outcomes
- Heterogeneity: Effects should be strongest for children from the bottom income quintile; may vary by race

**Novelty:**
- Literature search: Ludwig and Miller (2007) found 33-50% lower mortality at ages 5-9 using this design; Carneiro and Ginja (2014) found reduced crime. No study has linked this design to Opportunity Insights intergenerational mobility measures.
- Gap: The long-run mobility effects of the 1965 Head Start expansion have not been studied using the OEO discontinuity
- Contribution: First paper to connect the Ludwig-Miller Head Start RDD to explicit intergenerational mobility outcomes

---

## Idea 2: Clean Air Act 1970 Nonattainment and Intergenerational Mobility

**Policy:** The 1970 Clean Air Act Amendments designated counties as "nonattainment" if their Total Suspended Particulates (TSP) exceeded national standards. Nonattainment counties faced mandatory pollution reduction requirements.

**Method:** RDD (Sharp)

**Research Question:** Did children born in counties just above the TSP nonattainment threshold experience different intergenerational mobility than children born in counties just below the threshold?

**RDD Design:**
- **Running variable:** County 1970 TSP concentration (μg/m³)
- **Cutoff:** National Ambient Air Quality Standard (75 μg/m³ annual geometric mean)
- **Treatment:** Nonattainment status → Required pollution controls → Reduced air pollution
- **First stage:** ~10 μg/m³ greater TSP reduction in nonattainment counties

**Data:**
- Source: Opportunity Insights county-level mobility data (1978-1983 birth cohorts)
- Merge: EPA historical air quality data and official nonattainment designations
- Key variables: Mean household income rank, probability of reaching top quintile, college attendance
- Sample: Counties with TSP monitors in 1970 (approximately 1,000 counties)

**Hypotheses:**
- Primary: Nonattainment counties exhibit 1-3 percentile point higher mean income rank due to improved early-life health
- Mechanism: Reduced in-utero and early childhood pollution exposure improves cognitive development and adult human capital
- Heterogeneity: Effects may be stronger in heavily industrial counties; may vary by baseline pollution levels

**Novelty:**
- Literature search: Isen, Rossin-Slater, and Walker (2017) found 10% TSP reduction → 1% higher earnings at age 30. Chay and Greenstone (2003) found infant mortality effects.
- Gap: No study uses explicit intergenerational rank-rank mobility measures from Opportunity Insights with the CAA RDD
- Contribution: Tests whether pollution reduction in birth county affected children's relative position in the income distribution, not just earnings levels

---

## Idea 3: Community Development Block Grant Entitlement Threshold and Mobility

**Policy:** Since 1974, the Community Development Block Grant (CDBG) program provides federal funding for community development. Cities with populations over 50,000 automatically qualify as "entitlement communities" with guaranteed annual funding, while smaller cities must compete for limited state-administered funds.

**Method:** RDD (Fuzzy)

**Research Question:** Do children who grew up in CDBG entitlement cities (population just above 50,000) experience higher intergenerational mobility than children in non-entitlement cities (population just below 50,000)?

**RDD Design:**
- **Running variable:** City population (1970 or 1980 Census)
- **Cutoff:** 50,000 population
- **Treatment:** Entitlement status → Guaranteed CDBG funding → Investment in housing, infrastructure, services
- **Design type:** Fuzzy (some cities near cutoff may gain/lose status over time)

**Data:**
- Source: Opportunity Insights tract-level or county-level mobility data (1978-1983 birth cohorts)
- Merge: HUD CDBG entitlement community lists; Census city population data
- Key variables: Mean household income rank, upward mobility from bottom quintile, tract-level outcomes
- Sample: Cities within bandwidth of 50,000 threshold (approximately 200-400 cities)

**Hypotheses:**
- Primary: Entitlement cities exhibit 1-2 percentile point higher mobility for low-income children due to sustained community investment
- Mechanism: CDBG funds housing rehabilitation, infrastructure, and social services that improve neighborhood quality
- Heterogeneity: Effects should be concentrated in low-income census tracts within these cities

**Novelty:**
- Literature search: Studies of CDBG focus on housing and employment outcomes; no RDD at the 50,000 threshold for mobility outcomes
- Gap: The population threshold creates a clean RDD design that has not been exploited for intergenerational mobility
- Contribution: First study to use the CDBG entitlement threshold as an RDD for long-term mobility effects

---

## Idea 4: Medicaid Early Expansions and Intergenerational Mobility

**Policy:** The Omnibus Budget Reconciliation Acts of 1986, 1989, and 1990 expanded Medicaid eligibility to children in families above the poverty line. These expansions created sharp age-based eligibility cutoffs that varied by state and year.

**Method:** RDD (Sharp, using birth cohort cutoffs)

**Research Question:** Did children who gained Medicaid eligibility due to OBRA expansions (born just after eligibility cutoff dates) experience higher intergenerational mobility than children born just before the cutoffs?

**RDD Design:**
- **Running variable:** Birth date relative to state-specific eligibility expansion dates
- **Cutoff:** State-specific birth date thresholds (e.g., children born after September 30, 1983 eligible under OBRA 1990)
- **Treatment:** Medicaid eligibility → Health insurance coverage → Healthcare access during childhood
- **Variation:** Cross-state variation in expansion timing and generosity

**Data:**
- Source: Opportunity Insights county-level mobility data by birth cohort
- Merge: State Medicaid expansion dates from Thompson (2017) or Miller and Wherry (2019)
- Key variables: Mean household income rank by birth year, college attendance, health outcomes
- Sample: Birth cohorts 1980-1990 across states with varying expansion timing

**Hypotheses:**
- Primary: Cohorts with greater childhood Medicaid eligibility exhibit 1-2 percentile point higher mobility
- Mechanism: Improved childhood health → better school attendance → higher educational attainment → higher adult earnings
- Heterogeneity: Effects should be largest for children near the poverty line who gained coverage

**Novelty:**
- Literature search: Miller and Wherry (2019) found OBRA expansions reduced mortality at ages 15-18; Brown, Kowalski, and Lurie (2020) found effects on adult tax filing
- Gap: No study links OBRA Medicaid expansions to Opportunity Insights intergenerational mobility ranks specifically
- Contribution: Connects the Medicaid expansion literature to explicit intergenerational mobility outcomes using OI data

---

## Idea 5: Voting Rights Act Section 5 Coverage and Intergenerational Mobility

**Policy:** The Voting Rights Act of 1965 subjected certain jurisdictions to federal "preclearance" requirements under Section 5, based on a formula involving voter registration and turnout in 1964. Covered jurisdictions needed federal approval for any voting procedure changes, which indirectly affected political representation and public goods provision.

**Method:** RDD (Sharp, using the coverage formula threshold)

**Research Question:** Did children who grew up in counties covered by VRA Section 5 experience different intergenerational mobility than children in similar but uncovered counties?

**RDD Design:**
- **Running variable:** Voter registration rate in 1964 (or related coverage formula components)
- **Cutoff:** 50% voter registration/turnout threshold used in coverage formula
- **Treatment:** Section 5 coverage → Federal oversight → Changes in political representation → Different public goods provision
- **States:** Primarily Southern states with covered and uncovered counties

**Data:**
- Source: Opportunity Insights county-level mobility data for Southern states
- Merge: VRA Section 5 coverage data from Civil Rights Division; 1964 voter registration data
- Key variables: Mean household income rank, racial gaps in mobility, college attendance by race
- Sample: Southern counties near the coverage threshold

**Hypotheses:**
- Primary: Covered counties may exhibit 2-4 percentile point higher Black mobility due to improved political representation
- Mechanism: Section 5 coverage led to increased Black political representation → more equitable public goods (schools, infrastructure)
- Heterogeneity: Effects should be strongest for Black children; may differ by county racial composition

**Novelty:**
- Literature search: Cascio and Washington (2014) found VRA increased Black public employment and school spending. Aneja and Avenancio-León (2019) studied housing effects.
- Gap: No study links VRA Section 5 coverage to intergenerational mobility outcomes from Opportunity Insights
- Contribution: Tests whether federal civil rights intervention affected the long-run economic mobility of children in covered areas

---

## Exploration Notes

**Search Strategy:** Focused on historical policies (1960s-1990s) with sharp eligibility cutoffs that would allow RDD designs and can be merged with Opportunity Insights county-level mobility data for cohorts born 1978-1992.

**Policies Considered but Rejected:**
- **School Finance Equalization:** Court decisions varied by state and timing; no clean national cutoff for RDD
- **Enterprise Zones:** Geographic boundaries exist but require GIS data beyond PUMS/OI; studied heavily
- **EITC State Supplements:** Income cutoffs exist but require individual-level data matching; OI data is aggregated
- **Interstate Highway Construction:** Geographic discontinuities studied by Baum-Snow; complex spatial RDD needed

**Top Recommendations:**

1. **Idea 1 (Head Start OEO)** — Strongest design. The Ludwig-Miller cutoff is well-established, data is publicly available, and mobility outcomes have never been studied with this design.

2. **Idea 2 (Clean Air Act)** — Clean RDD with good first stage. Extends Isen et al. (2017) to explicit mobility measures.

3. **Idea 5 (VRA Section 5)** — High policy relevance and novelty, but coverage formula is complex; may require more careful specification.
