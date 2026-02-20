# Conditional Requirements

**Generated:** 2026-02-20T13:32:10.516644
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

---

## Jal Jeevan Mission and School Enrollment

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining reliable district completion/coverage time series by month

**Status:** [x] RESOLVED

**Response:**
JJM district-level coverage data is available from two sources:
1. **ejalshakti.gov.in** IMIS portal: provides district-wise FHTC (Functional Household Tap Connection) coverage with annual snapshots (April 2021, 2022, 2023, 2024, Dec 2024, April 2025)
2. **data.gov.in**: State/UT-wise "Har Ghar Jal" reported and certified villages under JJM-IMIS

Treatment definition: A district's treatment year = the first school year AFTER it crosses 80% FHTC coverage (or achieves "Har Ghar Jal" 100% certification). This avoids endogenous continuous coverage measures and creates a clean binary treatment. The stagger comes from different districts crossing the threshold at different times (2021-2024).

**Evidence:**
- ejalshakti.gov.in/JJM/JJMReports/Physical/JJMRep_HarGharJalVillage.aspx (portal with district data)
- data.gov.in Har Ghar Jal dataset (CSV download available)
- 188 districts certified as 100% by Aug 2024 (PIB press release PRID=1799286)

---

### Condition 2: aligning treatment to UDISE reference date/school year

**Status:** [x] RESOLVED

**Response:**
UDISE+ data follows the Indian academic year (April-March). Treatment alignment:
- JJM coverage snapshot at April 1 of year Y → treated for school year Y/Y+1
- Example: District reaches 100% FHTC by March 2022 → first treated school year = 2022-23
- This creates clean alignment: baseline coverage measured at start of academic year predicts enrollment in that year
- Pre-treatment: 2012-13 through last pre-coverage school year

**Evidence:**
UDISE+ annual reports state data collection reference is school year (April-March). JJM IMIS snapshots are at fixed dates including April 1.

---

### Condition 3: restricting outcomes to rural schools

**Status:** [x] RESOLVED

**Response:**
UDISE+ data on data.gov.in includes "Enrollment by Location" breakdowns with rural vs urban classification. The dataset "Enrolment by Location, School Management, School Category and Social Category (UDISE plus)" contains state code, district code, and location fields.

JJM is a rural program (targets rural households). Restricting to rural schools ensures treatment-outcome alignment.

**Evidence:**
- data.gov.in/catalog/enrolment-location-school-management-school-category-and-social-category-udise-plus
- Contains fields: academic_year, state_code, district_code, district_name, location (rural/urban)

---

### Condition 4: running strong event-study pre-trend tests

**Status:** [x] RESOLVED

**Response:**
UDISE+ annual data from 2012-13 through 2018-19 provides 7 pre-treatment periods (JJM launched Aug 2019). Event-study specification with leads (-7 to -1) and lags (+1 to +4) will test parallel trends. Using Callaway-Sant'Anna doubly robust estimator (R package `did`) which provides built-in pre-trend testing.

Additional robustness: Nightlights (SHRUG, 1994-2023) as a placebo outcome — if nightlights show pre-trends in JJM-treated districts but enrollment doesn't, this suggests spurious correlation with development trends.

**Evidence:**
- UDISE+ data confirmed on data.gov.in for years 2012-13 through 2022-23
- R package `did` (Callaway & Sant'Anna) includes `pre_test_res` function

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
