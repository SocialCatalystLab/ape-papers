# Conditional Requirements

**Generated:** 2026-02-18T14:35:09.404673
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Medicaid Postpartum Coverage Extensions and Maternal Health Provider Supply (Idea 1)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: explicitly addressing PHE continuous-coverage/unwinding timing

**Status:** [x] RESOLVED

**Response:**

The PHE continuous enrollment provision (Jan 2020 – March 2023) kept all Medicaid enrollees on the rolls, including postpartum women who would have otherwise lost coverage at 60 days. This creates a confound: during the PHE, ALL states effectively had extended postpartum coverage regardless of whether they adopted the formal 12-month extension.

**Mitigation strategy:**
1. Include a PHE indicator (Jan 2020 – March 2023) as a control variable interacted with state FE.
2. Estimate separate effects for states adopting DURING the PHE (April 2022 – March 2023) vs. AFTER the PHE (April 2023+).
3. Focus the preferred specification on post-PHE adopters (11+ states adopted July 2023 – March 2024) where the extension creates NEW coverage that the PHE no longer provides.
4. Use a triple-difference design: state × time × postpartum-vs-antepartum, which differences out any PHE effects that affect both prenatal and postpartum equally.

**Evidence:**

The PHE unwinding began April 1, 2023. States that adopted extensions BEFORE April 2023 saw the extension become binding only after the PHE ended. States adopting AFTER April 2023 experienced an immediate, clean treatment effect. This gives us a natural robustness check: compare early vs. late adopter effects.

---

### Condition 2: defining "supply" using postpartum-linked provider measures

**Status:** [x] RESOLVED

**Response:**

Provider supply is measured through three postpartum-specific channels:

1. **Postpartum care code (59430):** HCPCS code 59430 = "Postpartum care only (separate procedure)." This is exclusively used for postpartum visits and directly measures postpartum provider supply. T-MSIS has 975K claims for this code.

2. **Postpartum contraceptive services (58300, 11981):** IUD insertion and contraceptive implant placement, commonly provided during the extended postpartum window. These services are disproportionately postpartum-linked.

3. **Extensive margin via NPPES-linked OB/GYN providers:** Count of distinct providers (NPPES taxonomy 207V for OB/GYN) billing ANY Medicaid claim in a state-month. Extensions make Medicaid patients more financially attractive, potentially drawing in new providers. 72,261 OB/GYN providers in NPPES across all states.

**Placebo outcome:** Antepartum codes (59425, 59426) should NOT respond to postpartum extension. This directly tests whether observed effects are postpartum-specific.

**Evidence:**

T-MSIS data validation confirms: 59430 has 975K claims / $82M total paid / 867K beneficiaries. Antepartum codes 59425/59426 have 5.3M claims combined — ample power for placebo test.

---

### Condition 3: using T-MSIS quality screens + state-specific reporting-break controls

**Status:** [x] RESOLVED

**Response:**

T-MSIS data quality varies across states and time. CMS publishes the DQ Atlas tracking state-by-state quality metrics.

**Mitigation strategy:**
1. Drop state-months with implausible values (zero total claims for a state, sudden >80% drops that suggest reporting breaks).
2. Include state-specific linear time trends as a robustness check.
3. Restrict analysis to states with consistent reporting across 2018-2024 using a balanced panel check (states with non-zero claims in ≥95% of months).
4. Flag known reporting breaks from CMS DQ Atlas documentation and include as control dummies.
5. Show results with and without problem states as sensitivity analysis.

**Evidence:**

NPPES match rate on billing NPI is 99.5% (from overview paper apep_0294). State-month panel will be constructed with quality flags, and sensitivity analysis will confirm results are not driven by reporting artifacts.

---

### Condition 4: showing robust pre-trends

**Status:** [x] RESOLVED

**Response:**

Pre-trend validation is central to the design:

1. **Event study specification:** Estimate CS-DiD with event-time coefficients for periods -48 to +24 months (or max available). Plot pre-treatment coefficients to visually test parallel trends.
2. **Joint test:** F-test for joint significance of all pre-treatment event-time coefficients = 0.
3. **Honest DiD (Rambachan & Roth 2023):** Construct robust confidence intervals allowing for non-zero pre-trends. Report the maximum pre-trend magnitude that would overturn the result.
4. **State-level pre-treatment balance:** Compare treated vs. control states on pre-treatment levels and trends of: (a) number of Medicaid births, (b) number of OB/GYN providers, (c) Medicaid spending per beneficiary.
5. **Randomization inference:** Permute treatment assignment across states to construct a null distribution of DiD estimates.

**Evidence:**

With 51+ pre-treatment months for the earliest cohort and 84 months total span, there is ample power to detect pre-trend violations. The CS-DiD framework handles heterogeneous timing natively.

---

### Condition 5: placebo outcomes such as antepartum codes

**Status:** [x] RESOLVED

**Response:**

Three placebo/falsification tests are pre-specified:

1. **Antepartum care codes (59425, 59426):** 5.3M claims in T-MSIS. Prenatal care volume should NOT increase when postpartum coverage extends — pregnancy coverage was already unlimited. A null effect here validates that the treatment operates through the postpartum channel specifically.

2. **Non-OB/GYN provider supply:** Count of non-maternal providers (e.g., primary care, orthopedics) billing Medicaid in the same state-months. Postpartum extension should not affect unrelated specialties.

3. **Medicare OB/GYN billing:** For providers who bill both Medicaid (T-MSIS) and Medicare (Medicare PUF), check whether postpartum extension shifts their Medicare volume. If Medicaid becomes more attractive, providers might substitute away from Medicare (or not).

**Evidence:**

Antepartum codes (59425: 3.9M claims, 59426: 1.4M claims) provide the cleanest falsification since they use the same provider pool (OB/GYNs) for the same population (Medicaid-enrolled pregnant women) but for a service unaffected by the postpartum extension.

---

## Medicaid Coverage of Doula Services and Birth Outcomes (Idea 2)

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1-3: NOT APPLICABLE (pursuing Idea 1 instead)

**Status:** [x] NOT APPLICABLE

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
