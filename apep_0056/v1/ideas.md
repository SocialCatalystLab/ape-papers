# Research Ideas — Paper 72

**Generated:** 2026-01-23
**Domain:** Surprise me (agent-selected)
**Method:** Surprise me (match to policy variation)

---

## Idea 1: Do Prescription Drug Monitoring Program (PDMP) Mandates Reduce Opioid Prescribing? Evidence from Staggered State Adoption

### Policy Background

Prescription Drug Monitoring Programs (PDMPs) are state-run electronic databases that track controlled substance prescriptions. While PDMPs have existed since the 1990s, the key policy variation comes from **mandatory provider enrollment/query requirements**, which states adopted in staggered fashion between 2012-2019. These mandates require prescribers to check the PDMP before writing opioid prescriptions and pharmacists to report dispensing data.

**Key Policy Dates (Mandatory Enrollment/Query):**
- Kentucky: 2012 (first mandatory query law)
- New York: 2013
- Tennessee: 2013
- Ohio: 2015
- Massachusetts: 2016
- Pennsylvania: 2017
- Virginia: 2018
- ...and 30+ additional states by 2019

This represents **staggered adoption across 35+ states** over 7 years, providing excellent DiD variation.

### Research Question

Do state PDMP mandatory use requirements reduce opioid prescribing volume and opioid-related overdose deaths?

### Data Sources

1. **Primary Outcome — Opioid Prescriptions:** DEA ARCOS database (pill-level dispensing data 2006-2019, available via Washington Post release) at state-year level
2. **Secondary Outcome — Overdose Deaths:** CDC WONDER mortality data (ICD-10 codes T40.2-T40.4) at state-year level, 2000-2023
3. **Policy Dates:** PDAPS.org comprehensive database of PDMP implementation and mandate dates

### Identification Strategy

**Method:** Difference-in-Differences with staggered adoption

**Treatment:** State-year in which mandatory PDMP query requirement became effective

**Comparison group:** States without mandates (or not-yet-treated states under Callaway-Sant'Anna)

**Specification:** Modern staggered DiD using `did` package (Callaway & Sant'Anna 2021) with group-time ATT estimates and Sun-Abraham event studies

### DiD Early Feasibility Screen

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | ARCOS data 2006-2019; mandates start 2012 → 6+ pre-periods for early adopters | **Strong** |
| Selection into treatment | States with worse opioid crises may adopt earlier → address with pre-trends test | **Moderate** |
| Comparison group quality | ~15 never-treated or late-adopter states available | **Strong** |
| Cluster count | 35+ treated states over study period | **Strong** |
| Concurrent policies | Naloxone access laws, Good Samaritan laws overlap → include as controls | **Moderate** |
| Data-outcome timing alignment | ARCOS annual data, policy effective dates known to month | **Strong** |
| Outcome dilution | Prescriptions directly measured; deaths are aggregate but mechanism clear | **Strong** |
| Outcome-policy alignment | PDMP mandates directly affect prescribing behavior → prescription volume is exact margin | **Strong** |

**Overall Assessment:** 6 Strong, 2 Moderate → **PROCEED**

### Novelty Assessment

Extensive literature on PDMPs (Patrick et al. 2016, Buchmueller & Carey 2018, Meinhofer 2018), BUT:
1. Most prior work uses any-PDMP or operational-PDMP dates, not mandatory query requirements
2. Few papers use the complete ARCOS data (only available since 2019 litigation)
3. No papers apply modern staggered DiD corrections (Callaway-Sant'Anna) to this setting
4. Opportunity to decompose effects by opioid type (hydrocodone vs. oxycodone vs. fentanyl)

**Contribution:** First paper using mandatory query variation + complete ARCOS data + modern staggered DiD methods.

### Expected Findings

- Mandates reduce prescriptions by 10-20% (per prior literature using cruder variation)
- Heterogeneity by mandate stringency (query-before-every-prescription vs. query-after-threshold)
- Possible mortality effects lagged by 1-2 years (time to behavior change)
- Potential substitution to illicit opioids (testable with heroin/fentanyl death trends)

---

## Idea 2: Do State Dental Therapy Laws Improve Oral Health Care Access? Evidence from Staggered Adoption

### Policy Background

Dental therapists are mid-level dental providers who can perform routine procedures (fillings, extractions) under dentist supervision, expanding workforce capacity particularly in underserved areas. Minnesota became the first state to authorize dental therapists in 2009, followed by:

- Maine: 2014
- Vermont: 2016
- Arizona: 2018
- Michigan: 2018
- New Mexico: 2019
- Nevada: 2019
- Connecticut: 2019
- Colorado: 2020
- Oregon: 2021

**Staggered adoption across 14 states** (including tribal-only authorizations) provides DiD variation.

### Research Question

Do state dental therapy authorization laws increase dental care utilization and reduce emergency department visits for dental conditions?

### Data Sources

1. **Primary Outcome — Dental Visits:** BRFSS (Behavioral Risk Factor Surveillance System) — "How long since last dental visit?" annual state-level data
2. **Secondary Outcome — ED Visits for Dental Conditions:** HCUP State Emergency Department Databases (requires state-specific access) or NHAMCS (National Hospital Ambulatory Medical Care Survey)
3. **Mechanism — Workforce Supply:** BLS Occupational Employment Statistics (dental hygienist and dentist employment by state)
4. **Policy Dates:** National Partnership for Dental Therapy legislative comparison database

### Identification Strategy

**Method:** Difference-in-Differences with staggered adoption

**Treatment:** State-year in which dental therapy authorization law became effective

**Specification:** Callaway-Sant'Anna (2021) with event study and group-time ATTs

### DiD Early Feasibility Screen

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | BRFSS dental visit data available since 1999 → 10+ years pre-treatment for MN (2009) | **Strong** |
| Selection into treatment | States with dentist shortages may adopt → control for baseline dentist/population ratio | **Moderate** |
| Comparison group quality | 36+ states never adopted → large comparison group | **Strong** |
| Cluster count | 14 treated states (small but sufficient with proper inference) | **Moderate** |
| Concurrent policies | Medicaid dental expansion overlaps → include as control | **Moderate** |
| Data-outcome timing alignment | BRFSS annual; laws effective mid-year but outcome asks about past 12 months | **Moderate** |
| Outcome dilution | Dental visits aggregate; dental therapist margin small initially → may be underpowered | **Weak** |
| Outcome-policy alignment | Dental therapists enable more visits directly; outcome measures visits | **Strong** |

**Overall Assessment:** 3 Strong, 4 Moderate, 1 Weak → **PURSUE with caution (power concerns)**

### Novelty Assessment

Limited causal evidence on dental therapy laws:
- Koppelman et al. (2016) descriptive only
- No DiD studies on state-level authorization
- Opportunity to be first causal paper on this growing policy area

**Concern:** Laws authorize therapists, but actual therapist employment lags by years (training pipeline). Effect may take 3-5 years to materialize. MN adopted in 2009, first therapists graduated ~2011. Check for sufficient post-treatment observations.

### Expected Findings

- Small positive effects on dental visits (1-3 percentage point increase in "past year" visits)
- Larger effects in rural/underserved areas (heterogeneity analysis)
- Possible reduction in dental ED visits (cost savings to Medicaid)

---

## Idea 3: Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid Coverage? A Regression Discontinuity Design

### Policy Background

The ACA's dependent coverage provision allows young adults to remain on parents' health insurance until age 26. At the 26th birthday, coverage terminates, creating a sharp discontinuity in insurance type. Young adults losing parental coverage may:
1. Obtain employer-sponsored insurance
2. Purchase marketplace coverage
3. Become uninsured
4. Qualify for Medicaid (especially if pregnant)

### Research Question

Does the age-26 health insurance discontinuity affect the payer of delivery for births to mothers near the threshold?

### Data Sources

1. **Primary Data:** CDC Natality Microdata (birth certificates, 1990-2022, public-use files)
   - Contains: Mother's age, payment source (private insurance, Medicaid, self-pay, other)
   - N > 3 million births per year
   - **Critical limitation:** Mother's age is in completed years, not exact date → discrete/fuzzy RD

2. **Alternative:** NVSS restricted-use natality files (contain month of birth → better running variable)

### Identification Strategy

**Method:** Regression Discontinuity Design at age 26

**Running Variable:** Mother's age at delivery (in months if restricted data; integer years if public data)

**Outcome:** Share of births covered by Medicaid (vs. private insurance, vs. self-pay)

**Specification:**
- With restricted data: Sharp RD using `rdrobust` with optimal bandwidth selection
- With public data: Discrete RD following Kolesár & Rothe (2018) → local randomization inference given few mass points

### RD Feasibility Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Running variable continuity | Age in completed years → discrete; need K&R methods | **Moderate** |
| Manipulation | Cannot manipulate exact birthday; pregnancy duration somewhat malleable → check density | **Strong** |
| Threshold salience | Age 26 cutoff highly publicized, directly tied to coverage loss | **Strong** |
| Bandwidth | ~3-4 integer years on each side if discrete; or ±6 months if continuous | **Moderate** |
| Sample size at threshold | ~150,000 births annually to mothers age 25-26 → extremely large N | **Strong** |
| Covariate balance | Must check: parity, marital status, education, race, state | **Testable** |
| Outcome timing | Payment source determined at delivery, same time as age measured | **Strong** |

**Overall Assessment:** 4 Strong, 2 Moderate, 1 Testable → **PROCEED**

### Novelty Assessment

ACA dependent coverage at age 26 is heavily studied (Sommers et al. 2013, Antwi et al. 2013, Barbaresco et al. 2015), BUT:
- Most papers use DiD comparing under-26 vs. 26+ or pre/post ACA
- Few papers use birthday-based RD design on natality microdata
- Payment source at delivery is an understudied outcome
- Novel contribution: First RD on insurance payer at birth near the age-26 cliff

### Expected Findings

- Discontinuous ~5-10 percentage point decrease in private coverage at 26
- Corresponding increase in Medicaid coverage (for low-income mothers)
- Possible increase in self-pay/uninsured (for above-Medicaid-threshold mothers)
- Heterogeneity by state Medicaid expansion status

### Concerns

1. **Discrete running variable:** Requires Kolesár & Rothe (2018) inference, not standard RD
2. **Marriage as outcome confusion:** Paper 64 was rejected for treating marriage at 26 as a balance test when it could be a mechanism (marry for spousal coverage). Here, marriage status at delivery is a covariate, not a balance test—but note the issue.
3. **Selection into pregnancy:** If insurance status affects pregnancy timing/decisions, sample composition may shift discontinuously → testable with density/bunching analysis

---

## Idea 4: Do State Data Breach Notification Laws Affect Corporate Cybersecurity Investment? Evidence from Staggered Adoption (2002-2018)

### Policy Background

Data breach notification laws require organizations to notify affected individuals when personal data is compromised. California passed the first law in 2002, with all 50 states adopting by 2018 (Alabama and South Dakota last). The laws create financial and reputational incentives for firms to invest in cybersecurity to avoid breaches.

**Key Adoption Dates:**
- California: 2003 (effective)
- New York: 2005
- Texas: 2005
- Florida: 2005
- ...
- Alabama: 2018
- South Dakota: 2018

**Clean staggered adoption over 16 years across all 50 states.**

### Research Question

Do state data breach notification laws increase corporate cybersecurity investment and reduce breach frequency?

### Data Sources

1. **Primary Outcome — Reported Breaches:** Privacy Rights Clearinghouse database (breach incidents by organization, date, state, records affected)
2. **Secondary Outcome — Cybersecurity Employment:** BLS OES data on "Information Security Analysts" (SOC 15-1212) employment by state-year
3. **Alternative Outcome:** Compustat firms' IT/cybersecurity spending (limited coverage)
4. **Policy Dates:** NCSL compilation of state data breach notification laws

### Identification Strategy

**Method:** Difference-in-Differences with staggered adoption

**Treatment:** State-year in which data breach notification law became effective

**Specification:** Sun-Abraham (2021) event study with heterogeneity-robust weights

### DiD Early Feasibility Screen

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | BLS employment data available since 1997; CA adopts 2003 → 6+ pre-periods | **Strong** |
| Selection into treatment | States with more tech industry may adopt earlier → control for baseline tech employment | **Moderate** |
| Comparison group quality | Adoption spans 2003-2018 → early adopters serve as comparison for late adopters | **Strong** |
| Cluster count | All 50 states eventually treated; staggered timing creates variation | **Strong** |
| Concurrent policies | Federal breach notification proposals never passed; state laws are the binding regulation | **Strong** |
| Data-outcome timing alignment | Employment annual; laws effective dates known precisely | **Strong** |
| Outcome dilution | Cybersecurity employment directly affected; breach reporting mechanically changed by law | **Moderate** |
| Outcome-policy alignment | Laws mandate disclosure, which incentivizes prevention → employment is proxy for investment | **Moderate** |

**Overall Assessment:** 5 Strong, 3 Moderate → **PROCEED**

### Novelty Assessment

Some papers exist (Romanosky et al. 2011, 2014), BUT:
- Prior work focuses on breach outcomes, not cybersecurity investment
- No papers use modern staggered DiD methods
- Opportunity to study labor market effects (cybersecurity employment)
- Novel: First paper on workforce response to data breach notification laws

### Expected Findings

- Increase in Information Security Analyst employment by 3-5% following law adoption
- Possible reduction in breach incidents (though mechanical reporting effect confounds)
- Larger effects in states with stronger penalty provisions
- Heterogeneity by firm size/industry concentration

### Concerns

1. **Breach reporting is mechanical:** Laws require reporting breaches, so "breaches" increase mechanically even if actual security improves
2. **Outcome proxy:** Employment is proxy for investment; firms may substitute technology for labor
3. **Federal preemption threats:** Ongoing federal legislation creates uncertainty about state law permanence

---

## Summary Ranking

| Idea | Policy | Method | Feasibility | Novelty | Recommendation |
|------|--------|--------|-------------|---------|----------------|
| 1 | PDMP Mandates | DiD | High | Medium-High | **PURSUE** |
| 2 | Dental Therapy | DiD | Medium | High | **CONSIDER** (power concerns) |
| 3 | Age-26 Insurance Cliff | RDD | Medium-High | Medium-High | **PURSUE** |
| 4 | Data Breach Laws | DiD | Medium-High | Medium | **CONSIDER** (outcome proxy issues) |

**Recommended:** Idea 1 (PDMP Mandates) offers the strongest combination of clean identification, data availability, and policy relevance. Idea 3 (Age-26 RDD) is a close second with a sharp design but requires careful handling of discrete running variable.
