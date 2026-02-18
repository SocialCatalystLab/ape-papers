# Research Ideas

## Idea 1: Medicaid Postpartum Coverage Extensions and Maternal Health Provider Supply

**Policy:** 12-month Medicaid postpartum coverage extensions (ARP Act Section 9812, state option effective April 2022). 47 states + DC adopted between October 2021 and January 2025, with excellent staggered timing: ~20 states on April 1, 2022; ~9 states mid-to-late 2022; ~11 states throughout 2023; ~5 states in 2024. Arkansas and Wisconsin remain non-adopters.

**Outcome:** Maternal health provider supply in Medicaid, measured via T-MSIS claims data. Primary outcomes: (1) number of distinct OB/GYN/midwife providers billing Medicaid per state-month, (2) total postpartum care claims (HCPCS 59430) per state-month, (3) total contraceptive service claims (58300, 11981) per state-month. Provider identification via NPPES taxonomy codes (207V for OB/GYN, 176B for midwife).

**Identification:** Staggered DiD using Callaway & Sant'Anna (2021). Treatment = state adoption of 12-month postpartum extension. Pre-treatment: Jan 2018 to state adoption date (51+ months for earliest adopters). Not-yet-treated and never-treated (AR, WI) as controls. Event study to visualize dynamics and test pre-trends.

**Why it's novel:** All existing research on postpartum extensions examines the demand side — maternal enrollment, health outcomes, coverage gaps (including APEP-0149). Nobody has studied the supply side: whether extending coverage actually brings more providers into the Medicaid maternal health market. This is the first study using T-MSIS provider-level claims data to measure this response.

**Feasibility check:**
- Variation: 47 states staggered across 3 years (far exceeds 20 treated states). ✓
- Data: T-MSIS has 975K claims for code 59430 (postpartum care only). 72K OB/GYN providers in NPPES across all states. ✓
- Pre-periods: 51 months for earliest adopters (Jan 2018 – March 2022). ✓
- Placebo: Antepartum codes (59425, 59426) should NOT respond to postpartum extension. ✓
- Not overstudied: No existing papers on supply-side response to postpartum extensions. ✓

**Mechanism:** Before extension, Medicaid covers 60 days postpartum → providers see Medicaid patients only briefly post-delivery. After extension, 12 months of coverage → providers can bill Medicaid for 10 additional months per birth. This increases per-patient Medicaid revenue, making Medicaid patients more financially attractive. Extensive margin: new providers start accepting Medicaid. Intensive margin: existing providers increase volume.

---

## Idea 2: Medicaid Coverage of Doula Services and Birth Outcomes

**Policy:** States authorizing Medicaid reimbursement for doula services, staggered 2018-2024. Oregon (2018), Minnesota (2019), Indiana (2020), New Jersey (2021), California (2022), Virginia (2022), Rhode Island (2022), Maryland (2022), Nevada (2023), Florida (2024), several others.

**Outcome:** Provider entry (new doula NPIs appearing in T-MSIS billing) and maternal care service intensity in Medicaid.

**Identification:** Staggered DiD — treatment is state authorization of Medicaid doula reimbursement.

**Why it's novel:** Doula coverage is a rapidly expanding policy with clear provider market implications. T-MSIS would show whether coverage translates to actual service provision.

**Feasibility check:**
- Variation: ~12-15 states adopted during window. ⚠️ Borderline (may fall short of 20).
- Data: Need to verify doula-specific HCPCS codes exist in T-MSIS.
- Pre-periods: Adequate for most states. ✓
- Novelty: Limited existing research on supply-side effects. ✓
- Risk: Fewer than 20 treated states possible. Cell suppression may remove small doula providers.

---

## Idea 3: State Behavioral Health Parity Enforcement and Medicaid Provider Supply

**Policy:** State-level behavioral health parity compliance mandates for Medicaid MCOs, staggered 2019-2024. Following the 2020 MHPAEA Compliance Requirements, states issued enforcement regulations at different times.

**Outcome:** Behavioral health provider supply in Medicaid using H-codes (behavioral health services) and T-MSIS claims data.

**Identification:** Staggered DiD on state enforcement action dates.

**Why it's novel:** Parity literature focuses on commercial insurance; nobody has studied Medicaid MCO behavioral health parity using provider-level claims.

**Feasibility check:**
- Variation: Difficult to pin down exact state enforcement dates. ⚠️
- Data: T-MSIS H-codes have strong coverage. ✓
- Pre-periods: Depends on enforcement timing. ⚠️
- Risk: Policy variation is diffuse and hard to code. Treatment is not binary or clearly dated.

---

## Idea 4: Medicaid Adult Dental Benefit Expansions and Dentist Participation

**Policy:** States adding or expanding comprehensive adult dental coverage in Medicaid. Virginia (2021), Maryland (2022), Maine (2023), several others.

**Outcome:** Number of dentists billing Medicaid (NPPES dental taxonomy codes), total dental claims and spending in T-MSIS.

**Identification:** Staggered DiD on adult dental benefit expansion dates.

**Why it's novel:** Medicaid dental access is a crisis — most dentists refuse Medicaid. T-MSIS allows measuring the actual provider supply response to benefit expansion for the first time.

**Feasibility check:**
- Variation: ~8-10 states expanded during window. ⚠️ Likely too few.
- Data: Need to verify dental D-codes in T-MSIS. ⚠️
- Pre-periods: Adequate. ✓
- Risk: Very few treated states. Identification relies on small sample.
