# Research Ideas — Paper 36

**Method:** Regression Discontinuity Design (RDD)
**Data Focus:** Historical IPUMS Full-Count Census (1850-1940)
**Geographic Focus:** Arizona, Iowa, New York (randomized), expandable if compelling policy found

Generated after policy discovery phase. Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Mothers' Pension Benefit Loss at Child Age 14 → Maternal Labor Supply

**Policy:** Between 1911-1935, 46 states enacted mothers' pension programs providing cash transfers to widows with dependent children. Critically, eligibility terminated when the youngest child reached age 14 (some states: 16). This creates a sharp income discontinuity at the child's 14th birthday — the mother abruptly loses her pension income.

**Discontinuity:** Sharp age threshold at child's 14th birthday. Mother loses pension eligibility when youngest child turns 14.

**Research Question:** Did the loss of mothers' pension benefits at child age 14 increase maternal labor force participation?

**Data:**
- Source: IPUMS Full-Count Census 1920, 1930
- Sample: Widows/single mothers with youngest child aged 12-16 (2-year bandwidth around cutoff)
- Running variable: Age of youngest child (in months if available, otherwise years)
- Treatment: Youngest child ≥14 years old (mother no longer eligible for pension)
- Outcome: Maternal labor force participation, occupation status, earnings (if available)
- Sample size estimate: ~500,000+ widow-headed households with children 12-16 in full-count data

**Identification Strategy:**
- RDD comparing widows whose youngest child is just under vs. just over age 14
- Key assumption: No other policies or behaviors change discontinuously at child age 14
- Validity check: Test for manipulation of running variable (McCrary test on child age distribution)
- Robustness: Vary bandwidth (1 year, 2 years, 3 years), test polynomial specifications

**Hypotheses:**
- Primary: Loss of pension income forces mothers into the labor force
- Magnitude: Pension of ~$25/month was substantial (~25% of median male earnings); expect 5-15 pp increase in LFP
- Heterogeneity: Stronger effects for poorer widows, younger mothers, those in states with lower benefits

**Novelty:**
- Existing research (Aizer et al. 2016; Cambridge study) focuses on CHILD outcomes and cross-state generosity variation
- NO published study exploits the age-14 discontinuity as RDD for MATERNAL labor supply
- Novel contribution: First causal estimate of how losing welfare benefits affects maternal employment in historical context
- Policy relevance: Informs modern debates about welfare benefit cutoffs (e.g., TANF time limits)

**Feasibility:** HIGH
- Clear sharp discontinuity
- Large sample in full-count data
- Well-documented policy mechanism
- Can identify widow-headed households in census

---

## Idea 2: Old Age Assistance Age-65 Threshold → Elderly Living Arrangements

**Policy:** The Social Security Act of 1935 created Old Age Assistance (OAA), a means-tested pension for those 65+. Unlike federal Social Security (which required work history), OAA was available immediately to all low-income elderly. Benefits averaged $232/year in 1940 (~$3,600 in 2010 dollars). 22% of Americans 65+ received OAA by 1940.

**Discontinuity:** Sharp age threshold at 65th birthday. Below 65: no OAA eligibility. At/above 65: eligible if income-qualified.

**Research Question:** Did OAA eligibility at age 65 change elderly living arrangements (moving in with children, institutionalization)?

**Data:**
- Source: IPUMS Full-Count Census 1940
- Sample: Individuals aged 60-70 (5-year bandwidth around cutoff)
- Running variable: Age in years (and months if available)
- Treatment: Age ≥65 (OAA eligible)
- Outcomes: Living alone, living with adult children, in institution, head of household
- Sample size estimate: ~8 million individuals aged 60-70 in 1940 full-count

**Identification Strategy:**
- RDD at age 65 cutoff
- Note: Fetter & Lockwood (2016) used cross-state variation + age discontinuity for LABOR SUPPLY
- This study: Focus on LIVING ARRANGEMENTS (different outcome, complements existing work)
- Control for state-level OAA generosity as moderator

**Hypotheses:**
- Primary: OAA income allows elderly to maintain independent households rather than moving in with children
- Mechanism: Income support reduces economic dependence on family
- Heterogeneity: Stronger effects in states with more generous OAA, for low-income elderly

**Novelty:**
- Fetter & Lockwood (2016) studied labor supply effects
- NO published RDD study on living arrangements at age-65 OAA threshold
- Novel contribution: First RDD estimate of welfare effects on elderly household composition

**Feasibility:** MEDIUM-HIGH
- Sharp discontinuity well-documented
- Massive sample in 1940 full-count
- Concern: Age heaping in census data (need to test)
- Concern: Age 65 also marked by other policies (some pensions, retirement norms)

---

## Idea 3: WWI Draft Eligibility Birth Cohort → Marriage and Family Formation

**Policy:** The Selective Service Act of 1917 required registration of men ages 21-30 for WWI draft. Three registrations occurred: June 5, 1917 (men 21-30); June 5, 1918 (men turning 21); September 12, 1918 (men 18-45). Men born on or before June 5, 1896 (turned 21 by first registration) faced draft eligibility.

**Discontinuity:** Birth date cutoff for draft eligibility. Men born just before vs. just after cutoff dates faced different draft exposure.

**Research Question:** Did WWI draft eligibility affect men's subsequent marriage timing and family formation?

**Data:**
- Source: IPUMS Full-Count Census 1920, 1930, 1940
- Sample: Men born 1893-1899 (around draft cutoff dates)
- Running variable: Birth month/year relative to registration cutoff
- Treatment: Born before cutoff (draft eligible) vs. after (draft exempt)
- Outcomes: Marital status, age at first marriage, number of children, spouse characteristics
- Sample size estimate: ~15 million men in relevant birth cohorts in full-count data

**Identification Strategy:**
- Fuzzy RDD: Birth date determines draft ELIGIBILITY, not actual service
- First stage: Effect of cutoff on military service
- Reduced form: Effect of cutoff on marriage/family outcomes
- Following methodology of Tan (2017) who studied occupational outcomes

**Hypotheses:**
- Primary: Draft-eligible men delayed marriage during war, may have "caught up" later or had persistent delays
- Alternative: Draft eligibility increased marriage (men married before leaving)
- Heterogeneity: Effects may differ by whether men actually served

**Novelty:**
- Tan (2017) found null effects on occupational prestige using similar design
- NO published study examines marriage/family formation using WWI draft RDD
- Novel contribution: First estimates of draft effects on family formation

**Feasibility:** MEDIUM
- Clear birth date discontinuity
- Large sample in full-count data
- Concern: 1940 census has poor veteran status reporting (Tan notes this)
- Concern: Multiple registration dates complicate analysis

---

## Idea 4: Women's Suffrage State Border Geographic RDD

**Policy:** Women gained voting rights at different times across states: Wyoming (1869), Colorado (1893), Idaho (1896), Washington (1910), California (1911), Arizona (1912), etc. Before the 19th Amendment (1920), neighboring states often had different suffrage laws, creating geographic discontinuities at state borders.

**Discontinuity:** State border between early-adopter (suffrage) and non-adopter (no suffrage) states.

**Research Question:** Did women's suffrage affect women's labor force participation, education, or fertility near state borders?

**Data:**
- Source: IPUMS Full-Count Census 1910, 1920
- Sample: Women living in counties bordering states with different suffrage laws
- Running variable: Distance to state border
- Treatment: Living in suffrage state vs. non-suffrage state
- Outcomes: LFP, school enrollment, occupation, fertility (children ever born)
- Focus borders: Arizona-New Mexico (1912), Colorado-Kansas (1893-1912), Washington-Oregon (1910-1912)

**Identification Strategy:**
- Geographic RDD at state borders (Keele & Titiunik 2015 methodology)
- Compare women living just across the border in suffrage vs. non-suffrage states
- Key assumption: Border counties are similar except for suffrage laws
- Control for county-level characteristics

**Hypotheses:**
- Primary: Suffrage empowered women, increasing LFP and educational investment
- Alternative: Symbolic only, no immediate economic effects
- Mechanism: Political voice → policy changes favorable to women → economic opportunities

**Novelty:**
- Existing suffrage research uses state-level DiD (Miller 2008, Lott & Kenny 1999)
- NO published geographic RDD at state borders for suffrage effects
- Novel contribution: Sharper identification using border discontinuity

**Feasibility:** MEDIUM-LOW
- Need to geocode census records to county level (available in IPUMS)
- Border counties may be rural with small samples
- Concern: Selection of women who choose to live in suffrage states
- Concern: Other policy differences at state borders confound

---

## Idea 5: Child Labor Law Age-14 Work Permit Threshold → Child Schooling and Labor

**Policy:** By 1930, most states required work permits for children under 14-16 to work outside agriculture. The Fair Labor Standards Act (1938) federalized the age-14 minimum for non-agricultural work. This created a sharp discontinuity at age 14 where children could legally enter the labor force.

**Discontinuity:** Age 14 threshold for legal non-agricultural employment.

**Research Question:** Did the age-14 work permit threshold affect child labor force participation and school enrollment?

**Data:**
- Source: IPUMS Full-Count Census 1920, 1930, 1940
- Sample: Children aged 12-16 in non-agricultural households
- Running variable: Child age in years
- Treatment: Age ≥14 (legally permitted to work)
- Outcomes: Employment status, school enrollment, occupation if employed
- Sample size estimate: ~20 million children aged 12-16 in full-count data

**Identification Strategy:**
- Sharp RDD at age 14
- Compare children just under vs. just over age 14
- Validity check: No discontinuity in predetermined characteristics (parental education, family size)
- Exploit state variation in exact age thresholds

**Hypotheses:**
- Primary: Employment jumps sharply at age 14 when work becomes legal
- School enrollment may drop correspondingly
- Heterogeneity: Stronger effects for poorer families, agricultural vs. non-agricultural areas

**Novelty:**
- Child labor laws well-studied using DiD approaches (Acemoglu & Angrist, Lleras-Muney)
- Sharp age discontinuity approach less common
- Potential concern: This discontinuity may be too well-known (extensive prior literature)

**Feasibility:** HIGH
- Clear age discontinuity
- Massive sample
- Concern: Already well-studied topic (lower novelty)

---

## Recommendation

**Pursue first:** Idea 1 (Mothers' Pension Age-14 Threshold)
- Highest novelty: No published RDD on maternal outcomes
- Clear mechanism and policy relevance
- Large sample, sharp discontinuity
- Feasible with IPUMS full-count data

**Second choice:** Idea 2 (OAA Age-65 → Living Arrangements)
- Complements existing Fetter & Lockwood work
- Different outcome (living arrangements vs. labor supply)
- Massive 1940 sample

**Needs more exploration:** Idea 4 (Suffrage Geographic RDD)
- Innovative methodology but feasibility concerns
- Would need to verify sufficient sample at border counties
