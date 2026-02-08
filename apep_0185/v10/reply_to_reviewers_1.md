# Reply to Reviewers

## Paper: Friends in High Places: How Social Networks Transmit Minimum Wage Shocks
## Revision of apep_0197

We thank both reviewers for their thorough and constructive feedback. Below we address each major concern.

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Pre-trends (Errors a, e — "most urgent")
**Concern:** Joint F-test rejects parallel trends (p=0.008). Causal claims not convincing without resolution.

**Response:** We agree this is the most serious identification concern and now report it transparently throughout the paper — in the abstract, introduction, event-study discussion, robustness section, and a new Identification Limitations subsection. We do not attempt to dismiss the pre-trend evidence. Instead, we are transparent that our causal interpretation rests on the complementary weight of: (1) distance-restricted instruments that improve balance (p=0.112 at 100km); (2) placebo shock tests showing null effects for GDP and employment shocks; (3) Anderson-Rubin inference robust to weak instruments; (4) 2,000-draw permutation tests; and (5) leave-one-origin-state-out stability. We acknowledge that these complements mitigate but do not fully resolve the concern, and we qualify our causal language accordingly.

**Not addressed in this revision:** County-specific linear/quadratic trends, Sun & Abraham interaction-weighted event-study tables, Rambachan & Roth sensitivity plots, and extended pre-period analysis. These are important suggestions for a subsequent revision.

### SCI vintage (Error b — "endogeneity of 2018 measurement")
**Concern:** SCI measured in 2018 within the 2012-2022 panel is potentially endogenous.

**Response:** We have added explicit discussion in the SCI description section noting that: (a) Facebook social connections evolve slowly relative to our sample period, reflecting decades of historical migration; (b) any endogenous response of SCI to minimum wages during 2012-2018 would be absorbed by county fixed effects since we use a single time-invariant snapshot; and (c) our shift-share framework treats SCI as pre-determined "shares" with minimum wage changes as exogenous "shocks." We also expanded the Methodological Considerations subsection to address this concern. No earlier SCI vintage is publicly available.

### Exclusion restriction (Error c)
**Concern:** Out-of-state minimum wages could proxy for other origin-state changes affecting destination counties.

**Response:** We present two placebo tests (GDP shocks, state employment shocks) showing null effects, and a Sargan-Hansen overidentification test that fails to reject (p>0.10). We acknowledge that additional placebo shocks (business tax changes, ACA Medicaid expansions) would further strengthen the case and note this as a direction for future work.

### Shock concentration (Error d)
**Concern:** CA and NY account for ~45% of instrument variance.

**Response:** We report leave-one-origin-state-out 2SLS coefficients showing stability (0.78-0.84 range) and an effective number of shocks ≈12 (HHI=0.08). We note the reviewer's suggestion to present a full table of leave-one-out coefficients and to construct instruments excluding the top 3-5 origin states.

### Missing robustness tables (Error h)
**Concern:** Sun & Abraham, Rambachan & Roth, and detailed LOSO tables are asserted but not shown.

**Response:** We acknowledge this shortcoming. These tables would strengthen the paper and are noted for a subsequent revision.

### Literature additions
**Response:** We note the suggested additions (Bandiera et al. 2010, Kline & Moretti 2014, Athey & Imbens 2018) and will incorporate them in a subsequent revision.

### Writing and narrative
**Response:** We have tightened the narrative, reduced repetition in magnitude claims, and placed identification caveats prominently in the introduction.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Pre-trends
**Concern:** Pre-trends rejection (p=0.008) is a "genuine threat despite complements."

**Response:** Same as Reviewer 1. We are transparent about this limitation and rely on complementary identification evidence. The reviewer notes that this is "not fatal (shift-share not pure DiD; placebos/distance mitigate), but top journal demands resolution."

### Constructive suggestions
**Response to specific suggestions:**

1. **Extend pre-period (QCEW/BLS 2005-2011):** Excellent suggestion. Not implemented in this revision but noted for future work.
2. **Industry heterogeneity (NAICS high-bite splits):** Noted for future revision. Our QWI data include industry-specific employment for NAICS 44-45 (Retail) and 72 (Accommodation/Food), which are natural high-bite sectors.
3. **LATE extrapolation:** Added to Discussion section — our compliers are counties whose exposure responds to out-of-state shocks, likely border counties and counties with historical migration ties.
4. **USD magnitudes in framing:** Done — USD specifications are now prominently featured in abstract, introduction, and results.

### Literature additions
**Response:** We note the suggested additions (de Chaisemartin & D'Haultfoeuille 2022, Autor-Dorn-Hanson 2013, Peri et al. 2020) and will incorporate them in a subsequent revision.

---

## Summary of Changes

| Issue | Status | Notes |
|-------|--------|-------|
| Pre-trend honesty | **Done** | Reported F(4,50)=3.90, p=0.008 throughout |
| Causal language | **Done** | Tempered to "IV evidence consistent with" |
| SCI vintage justification | **Done** | Added slow-moving nature discussion |
| Identification Limitations section | **Done** | New subsection in Discussion |
| Weight normalization bug | **Done** | 0% below log($7.25) floor |
| Earnings co-primary | **Done** | β=0.319, p<0.001 |
| USD specifications | **Done** | $1 → 9% emp, 3.5% earnings |
| Job flow analysis | **Done** | Churn interpretation (both hires and seps increase) |
| Empty tables populated | **Done** | Earnings and job flow tables filled |
| Sample size consistency | **Done** | 135,700 obs, 3,108 counties throughout |
| County-specific trends | Future | Suggested by both reviewers |
| Sun & Abraham tables | Future | Suggested by both reviewers |
| R&R sensitivity plots | Future | Suggested by both reviewers |
| Industry heterogeneity | Future | Suggested by both reviewers |
| Extended pre-period | Future | Suggested by Grok |
| Additional placebos | Future | Suggested by GPT |
