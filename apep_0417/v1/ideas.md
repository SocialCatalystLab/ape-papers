# Research Ideas

## Idea 1: Where Medicaid Goes Dark — A Claims-Based Atlas of Provider Deserts and the Demand Shock of Enrollment Unwinding

**Policy:** Medicaid continuous enrollment unwinding (April 2023+). All 50 states began disenrolling beneficiaries on staggered timelines after the PHE ended March 31, 2023. Net enrollment declines ranged from 1.4% (Maine) to 30.2% (Colorado), with median 14.0%. Massive variation in speed, aggressiveness, and procedural vs. eligibility-based termination rates (procedural: 22% in Maine to 93% in Nevada/New Mexico).

**Outcome:** County × specialty × quarter panel of active Medicaid provider counts, constructed from T-MSIS claims data (227M rows, 2018-2024) joined to NPPES for provider specialty and location. Seven specialty groups: Primary Care, NP/PA, Psychiatry, Behavioral Health, Dental, OB-GYN, Surgery.

**Identification:** Staggered DiD using state-level variation in unwinding timing and intensity. Early unwinders (Arkansas, Idaho, April 2023) vs. late/cautious unwinders (Oregon delayed until Oct 2023; California, New York slow to terminate). Pre-period: 2018Q1-2023Q1 (~20 quarters). Post-period: 2023Q2-2024Q3. Callaway & Sant'Anna (2021) for heterogeneous treatment effects by cohort × time. Intensity measure: cumulative net disenrollment rate by state × quarter (from KFF/CMS unwinding data).

**Why it's novel:**
1. First claims-based county × specialty map of Medicaid provider deserts (vs. survey-based HRSA HPSA designations)
2. Documents an ongoing specialist exodus from Medicaid: psychiatry -35%, OB-GYN -32%, primary care -20% (2018-2023)
3. Shows NP/PA partial substitution (+28%) insufficient to fill gaps
4. Tests a major policy question: does losing beneficiaries cause providers to exit Medicaid, deepening deserts in a vicious cycle?
5. T-MSIS was released February 2026 — no published research exists using this data at this granularity

**Feasibility check:**
- T-MSIS: confirmed, 227M rows, parquet locally available
- NPPES: confirmed, 99.8% match rate to T-MSIS billing NPIs
- County mapping: confirmed, 98.8% of individual providers map via ZCTA-county crosswalk, 3,210 counties covered
- Specialty classification: confirmed, NUCC taxonomy codes cleanly separate 7 specialty groups
- Census ACS: confirmed API access for population denominators
- TIGER shapefiles: confirmed for mapping
- Unwinding timing: KFF tracker has state-by-state data; CMS publishes monthly enrollment reports

**Strengths:** Novel data, striking descriptive facts, staggered DiD with 50 states, extreme policy relevance (25M+ disenrolled), beautiful maps.

**Risks:** 2024 data has claim lag in Nov-Dec (cap at Q3). Unwinding timing clustering (most states started Apr-Jul 2023) may limit staggering. Provider exit from T-MSIS may reflect billing changes (e.g., MCO shifts) not actual departure. Need to distinguish "stopped billing Medicaid" from "left the market."


## Idea 2: The Substitution Gap — Do Nurse Practitioners Fill Physician Deserts in Medicaid?

**Policy:** NP Scope of Practice (SOP) reforms granting Full Practice Authority. ~5 states changed during 2018-2024 (Delaware 2021, Massachusetts 2021, Kansas 2022, New York 2022, Utah 2023).

**Outcome:** Same county × specialty × quarter panel, focusing on primary care and behavioral health where NP substitution is most relevant.

**Identification:** DiD comparing FPA-adopting states to restricted/reduced-practice states. Cross-sectional: compare NP-to-physician ratios in FPA vs. non-FPA states within desert vs. non-desert counties.

**Why it's novel:** First provider-level analysis of NP substitution in Medicaid using claims data. Direct evidence on whether NPs practice in areas physicians avoid.

**Feasibility check:** Data confirmed available (same pipeline as Idea 1). But only ~5 treated states in 2018-2024 window — falls far short of ≥20 requirement. Alternative: extend back to 2010 (pre-T-MSIS), but loses the claims-based measurement advantage.

**Verdict: SUPPLEMENT TO IDEA 1, NOT STANDALONE.** The NP substitution analysis is better framed as a mechanism within the desert atlas paper (Section 6) than as the primary identification.


## Idea 3: Rate Shock Therapy — Do HCBS Rate Increases Attract Providers to Medicaid Deserts?

**Policy:** ARPA Section 9817 HCBS rate increases (2021-2023). Nearly all states (48/48 responding) raised HCBS provider rates using enhanced FMAP funds. Increases ranged from 5% (Wisconsin) to 140% (Nevada personal care).

**Outcome:** County × HCBS-specialty × quarter panel of active HCBS providers from T-MSIS T/H/S codes.

**Identification:** Dose-response continuous treatment DiD using variation in rate increase MAGNITUDE across states. Not binary treatment (no clean control group since ~all states treated).

**Why it's novel:** First analysis of whether HCBS rate increases actually attracted providers to underserved areas.

**Feasibility check:** Data available for outcomes. But treatment variable (state-specific rate increase amounts) requires mining 51 individual CMS HCBS spending plans — labor-intensive and may not yield clean timing. Near-universal adoption eliminates clean control group for binary DiD. Continuous treatment DiD (Callaway et al. 2024) possible but methodologically demanding.

**Verdict: WEAKER THAN IDEA 1.** Universal treatment, bundled with other ARPA uses, and constructing the treatment variable is very labor-intensive.
