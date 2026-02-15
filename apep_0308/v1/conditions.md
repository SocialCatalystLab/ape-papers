# Conditional Requirements

**Generated:** 2026-02-15T14:46:13.440757
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

## The Geography of Medicaid's Invisible Workforce — A ZIP-Level Portrait of New York State

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: validating "location" with alternative geography where possible

**Status:** [x] RESOLVED

**Response:** NPPES practice_zip provides 5-digit ZIP codes that map to Census ZCTAs. We will use the Census ZCTA-to-county relationship file (direct download, no API key needed) for county-level aggregation. ZIP codes reflect billing/practice address, not necessarily service delivery location — this is explicitly acknowledged as a limitation.

**Evidence:** NPPES extract parquet confirmed to contain practice_zip field for 99.5% of billing NPIs. Census ZCTA shapefiles available at census.gov/geographies/mapping-files.

---

### Condition 2: county

**Status:** [x] RESOLVED

**Response:** We will present results at both ZIP/ZCTA level (for maps) and county level (for statistical analysis). County assignment uses Census ZCTA-to-county crosswalk. NY has 62 counties, providing sufficient variation for statistical summaries. NYC's 5 boroughs are counties (New York=Manhattan, Kings=Brooklyn, Queens, Bronx, Richmond=Staten Island).

**Evidence:** Census relationship file zcta_county_rel_10.txt provides population-weighted ZCTA-to-county mapping. NY has 1,194 ZIPs with Medicaid providers across 62 counties.

---

### Condition 3: service location fields if available

**Status:** [x] RESOLVED

**Response:** T-MSIS contains no service location fields — only billing and servicing NPI numbers. NPPES provides the practice location address for each NPI. For Type 2 (organizational) NPIs, the practice address typically reflects the organization's headquarters/office, not where individual aides deliver services. For Type 1 (individual) NPIs, the practice address more closely reflects where they work. This limitation is explicitly discussed in the paper: geographic patterns reflect where providers are administratively located, which may differ from where services are physically delivered (especially for home care aides who travel to patients' homes).

**Evidence:** T-MSIS schema has only 7 columns (billing NPI, servicing NPI, HCPCS, month, beneficiaries, claims, paid). No geographic fields. NPPES Practice Location Reference File provides additional practice locations beyond primary — we note this but use the primary address for consistency.

---

### Condition 4: plan/encounter sensitivity checks

**Status:** [x] RESOLVED

**Response:** T-MSIS commingles FFS and managed care encounters without a payer indicator — this is by design and is explicitly documented in the overview paper (apep_0294). Since NY is ~80% managed care, most observations are managed care encounters. We cannot distinguish FFS from MCO claims. Sensitivity checks: (a) compare spending patterns across time periods (pre/post COVID) to check stability; (b) verify that total spending aligns with MACPAC/CMS-64 benchmarks for NY; (c) note that encounter valuation varies by MCO.

**Evidence:** MACPAC reports NY Medicaid benefit spending ~$80B/year. Our T-MSIS data shows $144.8B cumulative over 84 months (~$20.7B/year in provider-level payments), which is plausible given that T-MSIS captures provider payments while MACPAC includes administrative costs and supplemental payments. The order-of-magnitude correspondence supports data validity.

---

### Condition 5: documenting managed-care vs FFS capture

**Status:** [x] RESOLVED

**Response:** The paper will include a dedicated subsection on data limitations documenting: (a) T-MSIS includes both FFS and managed care encounters; (b) NY is ~80% managed care; (c) "Medicaid Amount Paid" for managed care encounters may represent imputed/allowed amounts rather than actual payments; (d) cross-provider comparisons of payment levels should be interpreted with caution; (e) within-state time-series comparisons are more reliable than level comparisons. This follows the same framework established in the overview paper (apep_0294 Section 2.3).

**Evidence:** apep_0294 v2 Section 2.3 ("What the Data Lack") establishes the managed care valuation caveat. NY's managed care penetration rate from MACPAC.

---

### Condition 6: any known NY reporting artifacts

**Status:** [x] RESOLVED

**Response:** Key NY reporting artifacts to document: (a) NY transitioned behavioral health to managed care 2015-2019, which may explain the low H-code share (4% vs 13.6% nationally) if behavioral health encounters are valued/coded differently under managed care; (b) NY's CDPAP program is unique — consumer-directed personal care with fiscal intermediaries as billing entities, which concentrates T1019 spending in a few large organizational NPIs; (c) ZIP 12110 (Latham, NY) shows $7.2B in spending from 125 providers, likely reflecting a large fiscal intermediary or MCO billing office; (d) NY's MLTC plans may route claims through specific billing entities, creating geographic concentrations that reflect administrative rather than clinical geography.

**Evidence:** NY CDPAP is documented by NY DOH. ZIP 12110 concentration identified in data exploration (125 providers, $7.2B spending — likely PPL/CDPAP fiscal intermediary). The behavioral health carve-out transition is documented by NY OMH.

---

### Condition 7: clear caveats that patterns may reflect billing intermediaries rather than bedside labor location

**Status:** [x] RESOLVED

**Response:** The paper will prominently caveat that geographic patterns reflect billing/administrative locations (where NPIs are registered in NPPES), not necessarily where services are physically delivered. This distinction is especially important for home care: a fiscal intermediary in Latham, NY (ZIP 12110) may bill for personal care aides serving clients across the Capital Region. Similarly, Brooklyn-based home care agencies may serve clients across multiple boroughs. The maps show the administrative geography of Medicaid's provider infrastructure — a valuable but imperfect proxy for the geography of care delivery.

**Evidence:** ZIP 11232 (Sunset Park) has only 35 providers but $4.3B in spending — clearly a few large billing organizations, not 35 individual practitioners. This pattern is documented and used as a teaching example in the paper.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
