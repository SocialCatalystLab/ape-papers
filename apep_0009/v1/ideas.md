# Research Ideas

Generated after exploration phase targeting RDD studies in Colorado (CO), Minnesota (MN), and New Hampshire (NH).
Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Colorado Old Age Pension Labor Supply Effects at Age 60

**Policy:** Colorado's Old Age Pension (OAP) program, established in the State Constitution in 1937, provides cash benefits to low-income residents aged 60 and older. This is uniquely generous compared to most states that set similar thresholds at age 65. The program guarantees a minimum income level (currently ~$1,032/month in 2026), reduced dollar-for-dollar by other income.

**Method:** RDD

**Research Question:** Does eligibility for Colorado's Old Age Pension at age 60 reduce labor force participation among low-income older adults?

**Data:**
- Source: Census PUMS 2015-2023 (ACS 1-year)
- Key variables: AGEP (age), ST (state=08 for CO), ESR (employment status), WKHP (hours worked), WAGP (wages), PINCP (total income), PWGTP (person weight), PAP (public assistance income)
- Sample: Colorado residents aged 55-65 with income near eligibility threshold
- Sample size estimate: ~50,000-100,000 person-observations pooled across years

**Hypotheses:**
- Primary: Labor force participation drops discontinuously at age 60 among eligible Coloradans
- Mechanism: Cash transfer substitutes for earned income; implicit 100% tax on earnings (dollar-for-dollar benefit reduction) discourages work
- Heterogeneity: Effect should be strongest among those with income just below eligibility threshold

**Novelty:**
- Literature search: Fetter & Lockwood (AER 2018) studied Old Age Assistance in 1940 using state variation; NBER w25468 studied property tax exemptions at 65 in Georgia. Found NO published studies specifically examining Colorado's OAP at age 60.
- Gap: No modern RDD studies exploit Colorado's unique age-60 threshold
- Contribution: First causal evidence on labor supply effects of a state-level pension program with an age threshold 5 years earlier than typical programs. Policy implications for early retirement incentives.

---

## Idea 2: Colorado Senior Homestead Property Tax Exemption at Age 65

**Policy:** Colorado's Senior Homestead Property Tax Exemption reduces taxable value by 50% of the first $200,000 for homeowners aged 65+ who have owned and occupied their home for 10+ consecutive years. The State pays the exempted property taxes.

**Method:** RDD

**Research Question:** Does Colorado's senior property tax exemption at age 65 affect labor supply, housing tenure, or retirement decisions?

**Data:**
- Source: Census PUMS 2015-2023
- Key variables: AGEP (age), ST (state=08 for CO), TEN (tenure), MV (property value proxy), ESR (employment status), WKHP (hours), RETP (retirement income), PWGTP
- Sample: Colorado homeowners aged 60-70 with 10+ years at residence
- Sample size estimate: ~30,000-50,000 pooled

**Hypotheses:**
- Primary: Labor force participation or hours worked may decrease at age 65 as reduced tax burden decreases need for income
- Mechanism: Reduced property tax liability (~$1,500-3,000/year savings) relaxes budget constraint
- Heterogeneity: Strongest for marginal retirees with moderate income and high property values

**Novelty:**
- Literature search: NBER w25468 (Agarwal et al. 2019) studied age-based property tax exemptions in Georgia, finding effects on homeownership and location. No Colorado-specific study found.
- Gap: Colorado has unique 10-year ownership requirement plus different benefit structure
- Contribution: Extend literature to different institutional setting; study long-tenure homeowners

---

## Idea 3: Minnesota Unemployment Insurance 32-Hour Threshold

**Policy:** Minnesota law specifies that workers are ineligible for unemployment benefits in any week they work 32 or more hours (Minn. Stat. 268.085). This creates a sharp threshold: working exactly 32 hours disqualifies UI benefits for that week.

**Method:** RDD

**Research Question:** Do Minnesota workers receiving unemployment insurance bunch just below 32 hours per week to maintain eligibility?

**Data:**
- Source: Census PUMS 2010-2023
- Key variables: AGEP, ST (state=27 for MN), ESR, WKHP (hours worked per week - the running variable), WAGP, PWGTP
- Sample: Minnesota adults aged 18-64 who report part-time work
- Sample size estimate: ~80,000-120,000 pooled

**Hypotheses:**
- Primary: Excess mass of workers at 30-31 hours with deficit at 32-33 hours (bunching pattern)
- Mechanism: UI recipients strategically limit hours to stay under threshold
- Heterogeneity: Effect strongest during recession years when UI replacement rates are higher

**Novelty:**
- Literature search: Johnston & Mas (2016) studied UI duration in Missouri using RDD. Bunching literature exists for tax kinks but not specifically for UI hours thresholds.
- Gap: No bunching analysis of the 32-hour UI threshold specific to Minnesota
- Contribution: First evidence on labor supply distortions from hours-based UI eligibility rules

---

## Idea 4: SNAP General Work Requirement Exemption at Age 60

**Policy:** SNAP (food stamps) general work requirements exempt individuals aged 60 and older. At 59, able-bodied adults must work or participate in work activities; at 60, this requirement disappears.

**Method:** RDD

**Research Question:** Does exemption from SNAP work requirements at age 60 reduce labor force participation among low-income adults?

**Data:**
- Source: Census PUMS 2015-2023
- Key variables: AGEP (running variable), ESR, WKHP, FS (food stamps receipt), PINCP, PWGTP, ST
- Sample: Adults aged 55-65 with income near SNAP eligibility in my assigned states (CO, MN, NH)
- Sample size estimate: ~100,000+ pooled across states

**Hypotheses:**
- Primary: Small decrease in employment at age 60 among SNAP-eligible population
- Mechanism: Removal of work requirement reduces labor supply incentive
- Heterogeneity: Effect concentrated among those actually receiving SNAP

**Novelty:**
- Literature search: Fetter et al. studied ABAWD exemption at age 50 (NBER w28877). Census working paper tested age 60 for GWR but limited evidence.
- Gap: Less focus on the age-60 GWR exemption vs. the age-50 ABAWD exemption
- Contribution: Multi-state analysis of GWR exemption effects, complementing ABAWD literature

---

## Exploration Notes

**States Assigned:** Colorado (CO), Minnesota (MN), New Hampshire (NH)

**Method Assigned:** RDD

**Search Strategy:**
1. Started with broad searches for eligibility thresholds and income cutoffs in each state
2. Found many well-studied programs (Medicaid, Medicare, EITC) - avoided these
3. Deep dive into age-based thresholds measurable in PUMS (AGEP variable 0-99)
4. Deep dive into hours-based thresholds (WKHP variable 1-99)

**Key Discovery:** Colorado's Old Age Pension at age 60 is uniquely generous (5 years earlier than typical) and appears unstudied with modern RDD methods. This is the strongest candidate.

**Ideas Rejected:**
- New Hampshire elderly property tax exemption: Age 65 threshold is the same as federal programs, harder to isolate state effect
- Colorado FAMLI: Too recent (2024) for sufficient PUMS data
- Minnesota child care assistance: Income thresholds are fuzzy and well-studied
- Occupational licensing: Hard to identify in PUMS data

**Recommendation:** Idea 1 (Colorado OAP at 60) should rank highest due to novel policy threshold and clear identification strategy.
