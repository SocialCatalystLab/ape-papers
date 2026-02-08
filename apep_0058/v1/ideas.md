# Paper 74: Research Ideas

**Phase:** 2 - Discovery
**Created:** 2026-01-24

---

## Idea 1: Dental Therapy Authorization and Oral Health Access (RECOMMENDED)

### Policy Background

Dental therapists are mid-level providers who perform preventive and restorative dental procedures. Since 2009, 14 U.S. states have authorized dental therapy practice:

| State | Year Authorized |
|-------|-----------------|
| Minnesota | 2009 |
| Maine | 2014 |
| Vermont | 2016 |
| Arizona | 2018 |
| Michigan | 2018 |
| New Mexico | 2018 |
| Nevada | 2019 |
| Idaho | 2019 |
| Washington | 2020 |
| Oregon | 2020 |
| Connecticut | 2021 |
| Colorado | 2022 |
| Wisconsin | 2024 |
| (1 more) | 2024 |

### Research Question

Does state authorization of dental therapy increase dental care access and utilization, particularly among underserved populations?

### Identification Strategy

**Method:** Difference-in-Differences with staggered adoption

Event study comparing states that authorized dental therapy to never-adopters and not-yet-adopters.

### Data Sources

1. **BRFSS (Behavioral Risk Factor Surveillance System)** - State-year level
   - Dental visit in past 12 months
   - Teeth removed due to decay
   - Self-rated oral health
   - Available: 2000-present, free access via CDC

2. **Census Business Dynamics Statistics** - State-NAICS-year level
   - Establishment counts in NAICS 6212 (Offices of Dentists)
   - New establishment formation
   - Available: 1978-2023, free API access

3. **HRSA Area Health Resources Files**
   - Dentist supply per capita by county/state
   - Dental HPSA designations

### DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | STRONG | MN 2009 allows 9+ years pre-treatment with BRFSS |
| Selection into treatment | MODERATE | Policy adoption driven by advocacy coalitions, dental shortages; need to test for pre-trends |
| Comparison group quality | STRONG | 36+ never-treated states available |
| Cluster count | MODERATE | 14 treated, 36 control = 50 total clusters |
| Concurrent policies | MODERATE | Need to control for Medicaid dental expansion |
| Data-outcome timing | STRONG | BRFSS annual surveys, dental visits measured yearly |
| Outcome dilution | MODERATE | Population-level outcomes; dental therapists may be small share of total visits initially |
| Outcome-policy alignment | STRONG | Dental visits directly measure access |

**Overall:** PURSUE - Strong candidate with clear identification and accessible data

### Contribution

**Literature Gap:** No existing difference-in-differences or quasi-experimental studies of dental therapy. Current evidence is descriptive (surveys, qualitative studies). A rigorous causal inference paper would fill a significant gap.

**Policy Relevance:** 30+ additional states considering dental therapy legislation. Evidence on access effects would inform policy decisions.

---

## Idea 2: Interstate Medical Licensure Compact and Physician Supply

### Policy Background

The Interstate Medical Licensure Compact (IMLC), established in 2015, streamlines physician licensing across member states. As of 2024, 42 states have joined:

- Early adopters (2015-2016): AL, AZ, CO, ID, IL, IA, KS, MN, MS, MT, NV, NH, SD, UT, WV, WI, WY
- Mid adopters (2017-2020): Many additional states
- Late adopters (2021-2024): FL, NY, and others

### Research Question

Does joining the Interstate Medical Licensure Compact increase physician supply, particularly in underserved areas?

### Identification Strategy

**Method:** Difference-in-Differences with staggered adoption

Compare physician supply growth in compact-joining states vs. non-members.

### Data Sources

1. **HRSA Area Health Resources Files** - County-year level
   - Physicians per capita by specialty
   - HPSA designations

2. **AMA Masterfile** - May require data purchase
   - Individual physician practice locations

3. **CMS Provider Enrollment Data**
   - Medicare participating physician counts by state

### DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | STRONG | 2015 start allows good pre-period with AHRF |
| Selection into treatment | MODERATE | State-level political factors drive adoption |
| Comparison group quality | WEAK | Only 8 states not in compact; shrinking control group |
| Cluster count | WEAK | 42 treated, 8 control = imbalanced |
| Concurrent policies | MODERATE | Telemedicine expansion overlaps |
| Data-outcome timing | STRONG | Annual physician counts |
| Outcome dilution | MODERATE | Compact physicians small share of total |
| Outcome-policy alignment | STRONG | Physician supply directly relevant |

**Overall:** CONSIDER with caution - Control group too small for standard DiD. May need synthetic control or other method.

### Concerns

- **Similar to existing APEP papers:** Papers 0012, 0013, 0014, 0019 studied universal license recognition. IMLC is physician-specific but conceptually similar.
- **Control group problem:** Only 8 non-member states limits comparison.

---

## Idea 3: Optometrist Laser Authority Expansion and Eye Care Access

### Policy Background

States have expanded optometrist scope of practice to include laser procedures (YAG capsulotomy, SLT, LPI):

| State | Year |
|-------|------|
| Oklahoma | 1998 |
| Kentucky | 2011 |
| Louisiana | 2014 |
| Alaska | 2017 |
| Arkansas | 2019 |
| Virginia | 2020 |
| Mississippi | 2021 |
| Wyoming | 2021 |
| Colorado | 2022 |
| South Dakota | 2024 |
| West Virginia | 2024 |

### Research Question

Does allowing optometrists to perform laser procedures increase access to cataract follow-up care (YAG capsulotomy) and glaucoma treatment (SLT)?

### Identification Strategy

**Method:** Difference-in-Differences with staggered adoption

Compare laser procedure rates in expanding vs. non-expanding states.

### Data Sources

1. **Medicare Claims Data (Limited Data Set or Public Use Files)**
   - YAG capsulotomy (CPT 66821) procedure counts by state
   - SLT (CPT 65855) procedure counts
   - Wait times (if derivable)

2. **Medicare Provider Utilization Data**
   - Procedures by provider type (optometrist vs. ophthalmologist)

### DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | MODERATE | Kentucky 2011 limits early pre-period |
| Selection into treatment | MODERATE | Policy driven by optometry lobbying |
| Comparison group quality | STRONG | ~38 non-adopter states |
| Cluster count | WEAK | Only 11-12 treated states |
| Concurrent policies | MODERATE | General scope expansion trends |
| Data-outcome timing | STRONG | Medicare claims available annually |
| Outcome dilution | WEAK | Optometrist procedures may be small share initially |
| Outcome-policy alignment | STRONG | Laser procedure rates directly relevant |

**Overall:** CONSIDER - Interesting but limited treated states and potential power concerns

---

## Idea 4: Direct Primary Care "Not Insurance" Laws and Healthcare Access

### Policy Background

26+ states have passed laws exempting Direct Primary Care (DPC) arrangements from insurance regulation, enabling doctors to offer subscription-based primary care:

- Early adopters: WA, OR, UT (2010-2012)
- Wave 2: Many states 2015-2017
- Recent: FL 2018, GA 2019+

### Research Question

Do state DPC laws increase primary care access and reduce ED utilization?

### Identification Strategy

**Method:** Difference-in-Differences with staggered adoption

### Data Sources

1. **BRFSS** - Primary care access, usual source of care
2. **HCUP State Emergency Department Databases** - ED visit rates for primary care-treatable conditions
3. **ACS/CPS** - Insurance coverage rates

### DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | STRONG | 2010 adopters allow good pre-period |
| Selection into treatment | MODERATE | Political/ideological factors |
| Comparison group quality | MODERATE | ~24 non-adopter states |
| Cluster count | MODERATE | 26 treated, 24 control |
| Concurrent policies | WEAK | ACA expansion overlaps significantly |
| Data-outcome timing | STRONG | Annual data available |
| Outcome dilution | WEAK | DPC patients very small share of population |
| Outcome-policy alignment | MODERATE | Laws enable but don't directly cause access |

**Overall:** SKIP - Treatment effect likely too small to detect at population level. DPC patients are <1% of population.

---

## Idea 5: Dental Therapist Authorization and Dental Practice Entry (Alternative Angle)

### Policy Background

Same as Idea 1, but focusing on supply-side outcomes.

### Research Question

Does dental therapy authorization increase new dental practice formation, particularly in underserved areas?

### Identification Strategy

**Method:** Difference-in-Differences with staggered adoption

Use Census Business Dynamics Statistics to track establishment entry in dental services (NAICS 6212).

### Data Sources

1. **Census Business Dynamics Statistics** - State-NAICS-year
   - Establishment births in NAICS 6212
   - Firm entry rates
   - Available 1978-2023

2. **County Business Patterns** - County-NAICS-year
   - Establishment counts
   - Payroll, employees

### DiD Feasibility Assessment

Same as Idea 1, with outcome changed to establishment entry rather than dental visits.

**Overall:** CONSIDER as robustness check for Idea 1, or combined paper

---

## Summary Ranking

| Idea | Feasibility | Novelty | Data Access | Recommendation |
|------|-------------|---------|-------------|----------------|
| 1. Dental Therapy → Access | HIGH | HIGH | FREE | **PURSUE** |
| 2. IMLC → Physician Supply | MODERATE | LOW | FREE/PAID | CONSIDER |
| 3. Optometrist Laser → Access | MODERATE | HIGH | MODERATE | CONSIDER |
| 4. DPC Laws → Access | LOW | MODERATE | FREE | SKIP |
| 5. Dental Therapy → Entry | HIGH | MODERATE | FREE | ROBUSTNESS |

---

## Recommended Approach

**Primary Research Question:** Does state authorization of dental therapy increase dental care access?

**Method:** Difference-in-Differences with staggered adoption (Callaway & Sant'Anna 2021)

**Outcomes:**
1. Primary: Dental visit in past 12 months (BRFSS)
2. Secondary: Teeth removed due to decay (BRFSS)
3. Heterogeneity: Effects by income, rural/urban, race/ethnicity

**Key Tests:**
- Event study for parallel trends
- Sensitivity to never-treated vs. not-yet-treated comparison
- HonestDiD bounds for violations of parallel trends

This paper would be the first rigorous causal inference study of dental therapy's effects on population-level oral health access.
