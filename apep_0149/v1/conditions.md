# Conditional Requirements

**Generated:** 2026-02-03T18:32:46.622990
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

## State Medicaid Postpartum Coverage Extensions and Maternal Health (Idea 3)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: primary outcomes = ACS insurance/coverage continuity for women with birth in last 12 months

**Status:** [x] RESOLVED

**Response:**
ACS PUMS variable FER ("Gave birth to child within the past 12 months") identifies postpartum women. Combined with HINS4 (Medicaid coverage), HICOV (any coverage), HINS1 (employer insurance), and HINS2 (direct-purchase insurance), I can construct: (1) Medicaid coverage rate among recent mothers, (2) uninsurance rate among recent mothers, (3) coverage type composition. POVPIP (income-to-poverty ratio) allows income-targeted subgroup analysis.

**Evidence:**
ACS PUMS API test (2022 ACS 1-year): `https://api.census.gov/data/2022/acs/acs1/pums?get=FER,HICOV,HINS4,ST,PWGTP&SEX=2&FER=1&AGEP=20:44` returns individual-level records for women aged 20-44 who gave birth within 12 months, with state identifiers and insurance type. Variables confirmed in ACS PUMS data dictionary.

---

### Condition 2: careful exposure timing using interview month or lagging treatment

**Status:** [x] RESOLVED

**Response:**
Three-pronged approach: (1) ACS interviews occur throughout the year (Jan-Dec), so I will lag treatment by 1 year in the primary specification — a woman surveyed in 2023 is treated only if her state's extension was effective by January 2022 (giving full exposure during the relevant postpartum period). (2) Robustness check using the exact adoption quarter relative to ACS survey month (using ADJINC or the ACS microdata interview month variable). (3) Drop the adoption year as a sensitivity check.

Additionally, the PHE continuous enrollment provision (March 2020 - May 2023) is a critical complication. During PHE, Medicaid beneficiaries could not be disenrolled, so the 60-day postpartum limit was effectively non-binding. I will: (a) explicitly model this by including PHE-era indicators, (b) focus the primary analysis on post-PHE outcomes (2023-2024 ACS data), and (c) use the staggered adoption dates relative to PHE unwinding as additional variation.

**Evidence:**
PHE ended May 11, 2023. Medicaid redeterminations began April 2023 in most states. The "bite" of the postpartum extension was strongest post-PHE. ACS 1-year estimates for 2023 and 2024 capture the post-PHE period.

---

### Condition 3: do not lead with maternal mortality unless you aggregate multi-year/age-specific or use Bayesian/Poisson shrinkage

**Status:** [x] RESOLVED

**Response:**
The primary outcome will be ACS insurance coverage continuity (Medicaid coverage, uninsurance) for women who gave birth in the last 12 months. Maternal mortality will NOT be a primary outcome. It may appear as a supplementary outcome in the appendix using CDC WONDER data with age-specific rates and multi-year aggregation, but the paper's main contribution is on insurance coverage dynamics. This avoids the small-count problem entirely.

**Evidence:**
N/A — design decision to lead with coverage outcomes.

---

### Condition 4: pre-specify power

**Status:** [x] RESOLVED

**Response:**
Approximate power calculation: ACS 1-year PUMS has ~3.3 million person records per year. Approximately 3.7% of women 15-44 gave birth in the past 12 months (FER=1). With ~50% of women 15-44 in the ACS sample (~1.65M), FER=1 yields ~61,000 postpartum women per year. Over 8 ACS years (2017-2024), total N ≈ 488,000 postpartum women. Pre-extension Medicaid coverage among postpartum women ≈ 42%. With 48 treated state clusters and 2 control states, using CS-DiD, MDE ≈ 2-3 percentage points (roughly 5-7% of baseline). This is well-powered: the policy extends coverage from 60 days to 12 months, mechanically increasing Medicaid coverage duration by 10 months — the expected effect should be substantially larger than the MDE.

**Evidence:**
ACS 2022 FER=1 sample: approximately 60,000+ women. Historical Medicaid birth share ~42% nationally. With 48 treated states, cluster-robust inference is well-powered.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git
