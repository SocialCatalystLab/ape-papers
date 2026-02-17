# Research Ideas

## Idea 1: ARPA-Funded HCBS Reimbursement Rate Increases → Provider Supply and Service Volume (PREFERRED)

**Policy:** ARPA Section 9817 (March 2021) provided states a 10 percentage point FMAP increase for HCBS expenditures, generating ~$37 billion in new HCBS investment. Most states used a significant share of these funds to raise provider reimbursement rates for personal care, attendant care, and habilitation services. Implementation was staggered: states submitted spending plans to CMS on rolling timelines (mid-2021 through 2023), with rate increases taking effect at different dates. Examples: North Carolina raised personal care rates 40% in March 2022; Colorado raised HCBS rates 6-10% in January 2022; Virginia raised personal care rates 12% in July 2021; New Mexico raised rates 8.5% in April 2022; Indiana raised rates 23-42% for HCBS waiver services; Nevada raised personal care rates 140%.

**Outcome:** Provider participation (unique billing NPIs for T/S-coded HCBS services), capacity (beneficiaries per provider), and service volume (total claims, total paid) from T-MSIS. Monthly state-level panel, 2018-2024.

**Identification:** Staggered DiD using Callaway-Sant'Anna estimator. Treatment identification via data-driven approach: detect discrete rate jumps (≥10% in a single month) in state-level average payment per claim for personal care codes (T1019, S5125). States without significant rate changes serve as never-treated controls. Event-study plots to verify flat pre-trends. Placebo tests on non-HCBS services (E/M codes, J-codes). Heterogeneity by provider type (individual sole proprietors vs. organizations). Dose-response analysis using rate change magnitude.

**Why it's novel:** (1) First paper to estimate the supply elasticity of HCBS providers to reimbursement rates using provider-level claims data. Existing literature relies on enrollment counts or survey data, not actual billing records. (2) T-MSIS was released Feb 2026 — no published paper has used this dataset for causal inference on reimbursement. (3) The ARPA HCBS investment was the largest single federal investment in home care, yet no causal evaluation of its rate increase component exists. (4) Complements apep_0327 (minimum wage → provider supply) and apep_0307 (unwinding → provider supply) by studying the PRICE mechanism directly.

**Feasibility check:** Confirmed: T-MSIS Parquet (2.74 GB) and NPPES extract are on disk. Rate changes detectable endogenously from payment per claim. ≥30 states implemented ARPA-funded rate increases (treatment), providing well-powered design. Pre-treatment period: 2018-2020 (24+ months). Post-treatment: varies by state but 12-36 months. Census ACS and FRED keys available for demographic controls.

---

## Idea 2: State Fee Schedule Changes → Provider Entry and Exit (ALTERNATIVE)

**Policy:** State Medicaid fee schedule updates that adjust rates for specific HCPCS codes. States update fee schedules on different cycles — some annually, some multi-year. During 2018-2024, many states made both ARPA-funded and independent rate adjustments.

**Outcome:** Same as Idea 1 (T-MSIS provider-level outcomes) but with additional focus on extensive margin: NPI entry (first billing date) and exit (last billing date).

**Identification:** Event study design centered on detected fee schedule changes in T-MSIS data. Within-state, across-service variation: compare personal care (treated by rate change) vs. behavioral health (untreated) in same state. Triple-difference: state × service-type × time.

**Why it's novel:** Triple-diff design provides cleaner identification than simple DiD by using within-state control services.

**Feasibility check:** Depends on cross-service rate changes being asynchronous. Needs verification that behavioral health rates didn't change at same time as personal care rates. More complex design with additional assumptions.

---

## Idea 3: Reimbursement Rate Levels and Cross-State Provider Sorting (ALTERNATIVE)

**Policy:** Cross-state variation in Medicaid reimbursement rate LEVELS (not changes). Some states pay $3/unit for personal care, others pay $8/unit.

**Outcome:** Provider density (NPIs per Medicaid beneficiary), average caseload (beneficiaries per NPI), border-county provider supply differences.

**Identification:** Spatial RDD at state borders — compare provider density in border counties on high-rate vs. low-rate side. Alternatively, panel analysis exploiting within-state rate changes over time.

**Why it's novel:** Would be first to use T-MSIS to map the provider supply surface across states at the NPI level.

**Feasibility check:** Spatial RDD requires border county identification and sufficient provider density at county level. May be underpowered for rare services. Cross-state rate level data harder to compile than rate changes. Lower feasibility than Idea 1.
