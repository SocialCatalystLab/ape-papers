# Research Ideas: Broadband Effects via RDD

**Assigned States:** Utah, South Dakota, Massachusetts
**Method Preference:** Regression Discontinuity Design (RDD)
**Topic Focus:** Broadband effects on important outcomes (novel angles)

---

## Idea 1: Lifeline Broadband Subsidy Eligibility and Self-Employment

**Research Question:** Does eligibility for the FCC Lifeline broadband subsidy (at the 135% FPL income threshold) increase self-employment and entrepreneurship?

**RDD Design:**
- **Running variable:** Household income as percentage of Federal Poverty Level
- **Cutoff:** 135% FPL (Lifeline eligibility threshold)
- **First stage:** Subsidy eligibility → Broadband adoption (HISPEED=1)
- **Second stage:** Broadband access → Self-employment outcomes

**Data:**
- Census PUMS 2018-2023
- Variables: HINCP (household income), HISPEED (broadband), COW (class of worker: self-employed=6,7), SEMP (self-employment income), PWGTP (weights)
- Construct FPL ratio using household income and household size (NP variable)

**Outcomes:**
- Self-employment indicator (COW=6 or 7)
- Self-employment income (SEMP > 0)
- Any business income

**Novelty:**
- Entrepreneurship/self-employment is an understudied outcome in broadband literature
- Most studies focus on wage employment, not business creation
- Gig economy and online marketplaces make broadband increasingly essential for self-employment
- Directly relevant to current policy debates on rural broadband and economic development

**Potential Challenges:**
- Fuzzy RDD (eligibility ≠ enrollment)
- Income measurement error in PUMS
- Need to verify Lifeline actual take-up rates

---

## Idea 2: Broadband Subsidy Eligibility and Geographic Mobility

**Research Question:** Does broadband subsidy eligibility enable geographic mobility by reducing location-specific employment constraints?

**RDD Design:**
- **Running variable:** Household income as percentage of FPL
- **Cutoff:** 135% FPL (Lifeline) or 200% FPL (historical ACP)
- **Treatment:** Subsidy eligibility → Broadband access
- **Outcome:** Interstate migration in past year

**Data:**
- Census PUMS 2019-2023
- Variables: HINCP, HISPEED, MIGSP (state of residence 1 year ago), ST (current state), PWGTP

**Outcomes:**
- Moved across state lines (MIGSP ≠ ST)
- Moved at all (MIG indicator)
- Direction of moves (rural→urban, high-cost→low-cost)

**Novelty:**
- The "Zoom town" phenomenon during COVID raised questions about broadband enabling location flexibility
- Understudied causal relationship between broadband access and residential mobility
- Could inform housing policy and rural development strategies
- Especially relevant for South Dakota (rural) vs Massachusetts (urban) comparison

**Potential Challenges:**
- Migration is a rare event (1-year window)
- Many confounders affect migration decisions
- May need large sample sizes

---

## Idea 3: Broadband Access and Work-From-Home Resilience During COVID-19

**Research Question:** Did households with broadband access experience better employment outcomes during the COVID-19 pandemic due to work-from-home capability?

**RDD Design:**
- **Running variable:** Household income as % FPL
- **Cutoff:** 135% FPL (Lifeline eligibility)
- **Treatment period:** 2020-2021 (pandemic peak)
- **Comparison period:** 2018-2019 (pre-pandemic)

**Data:**
- Census PUMS 2018-2021
- Variables: HINCP, HISPEED, ESR (employment status), JWTRNS (means of transportation to work, includes "worked from home"), WKHP (hours worked), PWGTP

**Outcomes:**
- Employment status (ESR=1,2 vs unemployed)
- Work from home indicator (JWTRNS=11 or remote work codes)
- Hours worked (WKHP)
- Difference-in-discontinuities: Pre vs post pandemic at the 135% FPL threshold

**Novelty:**
- Exploits the COVID-19 natural experiment where WFH suddenly became essential
- Tests whether broadband subsidies provided labor market resilience
- "Difference-in-discontinuities" design combining RDD with temporal variation
- Policy-relevant: Justifies broadband subsidies as employment insurance

**Potential Challenges:**
- COVID had many confounding effects
- WFH variable coding changed in some years
- Need to carefully construct the DiRD estimator

---

## Idea 4: E-Rate School Broadband and Student Achievement

**Research Question:** Does increased school broadband investment (via E-Rate discounts at the 40% poverty threshold) improve educational outcomes for students in those schools?

**RDD Design:**
- **Running variable:** School/district poverty rate (% students eligible for free/reduced lunch)
- **Cutoff:** 40% (Community Eligibility Provision threshold for universal free meals + maximum E-Rate discounts)
- **Treatment:** Higher E-Rate discount → More school broadband investment

**Data:**
- Would need to merge: E-Rate funding data (USAC), NCES school poverty rates, state education outcome data
- NOT directly available in PUMS (school-level)

**Outcomes:**
- Student test scores (from state education data)
- Graduation rates
- College enrollment

**Novelty:**
- The 40% CEP threshold is a sharp cutoff rarely exploited in research
- School broadband investment → student outcomes is policy-relevant
- Could inform debates about E-Rate program effectiveness

**Potential Challenges:**
- Requires non-PUMS data (school-level administrative records)
- Multiple treatments at 40% threshold (free meals + E-Rate + Title I)
- May need to focus on specific states (Utah, SD, MA have different data availability)

---

## Idea 5: Broadband × Medicare Interaction: Telehealth Access at Age 65

**Research Question:** Does the discontinuous jump in health insurance coverage at age 65 (Medicare eligibility) differentially benefit those with broadband access via telehealth utilization?

**RDD Design:**
- **Running variable:** Age
- **Cutoff:** 65 (Medicare eligibility)
- **Interaction:** Broadband access (HISPEED=1 vs 2)
- **Design:** Compare Medicare discontinuity for broadband vs non-broadband households

**Data:**
- Census PUMS 2019-2023
- Variables: AGEP (age), HINS3 (Medicare), HISPEED, health outcomes (DIS for disability, HICOV for any coverage), PWGTP

**Outcomes:**
- Health insurance coverage jump at 65 (confirm standard Medicare RDD)
- Health service access measures
- Employment/retirement decisions
- Interaction: Does broadband amplify health access gains from Medicare?

**Novelty:**
- Telehealth access has expanded dramatically post-COVID
- 22 million seniors lack broadband (Aging Connected report)
- Tests whether broadband is a "multiplier" for Medicare benefits
- Highly policy-relevant: Broadband subsidies for seniors could enhance Medicare effectiveness

**Potential Challenges:**
- PUMS lacks detailed health utilization data
- The interaction effect may be subtle
- Need careful specification of triple-differences design

---

## Recommendation

**Pursue Ideas 1 or 3 first:**

- **Idea 1 (Self-Employment)** is most novel—entrepreneurship outcomes are rarely studied in broadband literature and PUMS has excellent self-employment data (COW, SEMP variables).

- **Idea 3 (COVID WFH Resilience)** has the strongest policy narrative and the COVID period provides a clean shock to the value of broadband access.

Both use the clean 135% FPL Lifeline threshold and are fully executable with PUMS data alone.

**Idea 5 (Medicare × Broadband)** is intellectually interesting but may require health utilization data beyond PUMS.

**Idea 4 (E-Rate)** requires school-level data—worth pursuing if state education data is accessible.

**Idea 2 (Geographic Mobility)** is novel but migration is rare, requiring very large samples for statistical power.
