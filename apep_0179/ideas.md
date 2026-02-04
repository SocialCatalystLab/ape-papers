# Research Ideas - Paper 70
## Birth Control / Contraception Policy (RDD)

Date: 2026-01-23

---

## Idea 1: Aging Out at 26 and Birth Insurance Coverage (STRONG - PURSUE)

**Title:** Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid? A Regression Discontinuity Analysis

**Policy:** The Affordable Care Act (2010) requires private health insurers to cover dependents on parents' plans until age 26. At age 26, young adults "age out" and must obtain coverage through employment, Medicaid, marketplaces, or remain uninsured.

**Outcome:** Source of payment for delivery from CDC/NCHS Natality Public Use Files (2016-2024)
- Private insurance
- Medicaid
- Self-pay (uninsured)
- Other

**Identification Strategy:** Sharp Regression Discontinuity Design at age 26
- Running variable: Mother's single year of age (MAGER variable)
- Cutoff: Age 26 (birthday threshold)
- Window: Ages 23-29 (can test bandwidth sensitivity)

**Data:**
- NBER/CDC Natality Public Use Files (2016-2024): ~3.6 million births annually
- Contains MAGER (mother's single year of age) and PAY (source of payment)
- Available for download at NBER: https://www.nber.org/research/data/vital-statistics-natality-birth-data
- Individual birth records with exact age, allowing true RDD

**Why It's Novel:**
- Existing studies (Daw & Sommers 2018 JAMA, Simon et al. 2017) use **Difference-in-Differences** comparing age groups (24-25 vs. 27-28)
- No published study uses **true RDD** with single-year-of-age at the exact age 26 discontinuity
- This allows cleaner identification by comparing 25-year-old mothers to 26-year-old mothers
- Can also examine prenatal care utilization, birth outcomes (birth weight, preterm birth)

**Feasibility Check:**
- ✓ Variation: Sharp age discontinuity at 26 (policy-driven, exogenous)
- ✓ Data access: Natality public use files freely available from NBER
- ✓ Sample size: ~400,000 births to mothers age 25-26 annually (excellent power)
- ✓ Novelty: True RDD at 26 for birth outcomes not previously published
- ✓ Running variable: Age is impossible to manipulate (no bunching concerns)

**Expected Results:**
- Discontinuous drop in private insurance payment at age 26
- Compensating increase in Medicaid and self-pay
- Potential downstream effects on prenatal care and birth outcomes

**Mechanism:**
At age 26, women lose eligibility for parental insurance. Those who don't have employer coverage may:
1. Enroll in Medicaid (if income-eligible)
2. Purchase marketplace coverage (costly)
3. Remain uninsured (self-pay)

**RDD Validity:**
- Age is determined by birthdate, impossible to manipulate
- Women cannot time births to remain under 26 (pregnancy is 9 months)
- Smooth density test: Birth rates should not jump at age 26
- Balance tests: Mother's education, race, parity should be smooth across cutoff

---

## Idea 2: Plan B Age Restriction Removal (MODERATE - CONSIDER)

**Title:** Did Removing Age Restrictions on Emergency Contraception Reduce Teen Pregnancy? An RDD Analysis

**Policy:** FDA removed all age restrictions on Plan B One-Step emergency contraception on June 20, 2013. Before: Required prescription for women under 17. After: Available OTC for all ages without restrictions.

**Outcome:** Teen pregnancy rates and birth rates by single year of age

**Identification Strategy:** RDD in Time
- Running variable: Date (month-year relative to June 2013)
- Cutoff: June 2013 policy change
- Compare birth rates 9 months after policy change (March 2014 births)

**Data:**
- CDC WONDER Natality: Teen birth rates by single year of age (15, 16, 17, 18, 19)
- NSFG: Contraceptive use by age
- State-level variation may exist from prior age restrictions

**Why It's Novel:**
- Existing literature (Girma & Paton 2011, Durrance 2013) shows mixed effects
- Most studies use DiD comparing age groups or cross-state variation
- Sharp temporal RDD at June 2013 using monthly birth data

**Feasibility Check:**
- ✓ Policy: Clear date of policy change (June 20, 2013)
- ⚠ Data: Teen births available by single year, but not by exact month-of-conception
- ⚠ Confounders: Other factors affecting teen pregnancy were changing simultaneously
- ⚠ Prior studies: Literature already extensive (may be difficult to contribute)
- ⚠ Effect size: Population-level effects of EC availability have been historically small

**Concerns:**
- EC affects pregnancy rates only for subset who have unprotected sex AND access pharmacy quickly
- Prior studies find limited population-level effects despite individual effectiveness
- May be underpowered for small effects

---

## Idea 3: Pharmacist-Prescribed Contraception Age 18 Threshold (WEAK - SKIP)

**Title:** Does Age 18 Eligibility for Pharmacist-Prescribed Contraception Increase Use?

**Policy:** Oregon (2016) and several other states allow pharmacists to prescribe hormonal contraception directly, but 13 states restrict this to patients age 18+. Oregon requires minors under 18 to have a prior physician prescription.

**Outcome:** Contraceptive use rates, unintended pregnancy, birth rates

**Identification Strategy:** RDD at age 18 in states with age restrictions

**Data:**
- State-level birth rates by single year of age (CDC WONDER)
- NSFG for contraceptive use (limited sample size at state level)
- MEPS for prescription contraceptive claims

**Feasibility Check:**
- ⚠ Policy: Implementation dates vary by state, fuzzy rollout
- ⚠ Geographic restriction: Only ~13 states have age 18 restriction
- ⚠ Data: No direct measure of pharmacist prescribing by age in public data
- ⚠ Identification: Age 18 coincides with many other transitions (voting, adulthood)
- ✗ Multiple margins: Hard to isolate pharmacist prescribing from other age-18 effects

**Why Skip:**
- Too many confounders at age 18 (adulthood, college, leaving home)
- Cannot isolate pharmacist prescribing effect from other age-18 policy changes
- Data on pharmacist-prescribing utilization not publicly available by age

---

## Idea 4: Opill OTC Approval Effects (TOO EARLY - SKIP)

**Title:** Did OTC Birth Control (Opill) Approval Affect Fertility?

**Policy:** FDA approved Opill (norgestrel) as first OTC daily oral contraceptive in July 2023, became available in stores in early 2024.

**Outcome:** Birth rates, contraceptive use

**Identification Strategy:** RDD in time at January 2024 (retail availability)

**Feasibility Check:**
- ⚠ Timing: Too recent - births from 2024 conceptions just becoming available in late 2025
- ⚠ No age restriction: Opill has no age restriction, so no age-based RDD
- ⚠ Identification: Would need RD in time, but many confounders (Dobbs decision aftermath)
- ✗ Data lag: Cannot assess outcome for at least 12-18 more months

**Why Skip:**
- Insufficient post-treatment data available
- Better suited for DiD (pre/post 2024) once more data available
- No natural RDD threshold (no age restriction)

---

## Recommendation

**Pursue Idea 1** (Age 26 Dependent Coverage → Birth Insurance). This is the strongest candidate:

1. **Clear identification**: Sharp RDD at exogenous age threshold
2. **Excellent data**: Natality public use files with single-year age and payment source
3. **Novelty**: Existing literature uses DiD, not RDD
4. **Policy relevance**: ~30% of US births are to women affected by age 26 cutoff
5. **Multiple outcomes**: Insurance, prenatal care, birth weight, preterm birth

The age 26 discontinuity has been used for labor market outcomes (Akosa Antwi et al. 2015 J Health Econ) but NOT for birth/fertility outcomes with true RDD methodology.

---

## Data Sources

| Dataset | Years | Key Variables | Access |
|---------|-------|---------------|--------|
| Natality Public Use Files | 2016-2024 | MAGER (single year age), PAY (payment source), prenatal care, birth weight | NBER download |
| CDC WONDER Natality | 2016-2024 | Aggregated counts by age groups (not single year for 20+) | Online query |
| NSFG | 2015-2019, 2022+ | Contraceptive use, insurance, age | NCHS download |
| MEPS | 2016-2024 | Prescription contraceptives, insurance, out-of-pocket costs | AHRQ download |

**Primary data for Idea 1:** NBER Natality Public Use Files (https://www.nber.org/research/data/vital-statistics-natality-birth-data)
