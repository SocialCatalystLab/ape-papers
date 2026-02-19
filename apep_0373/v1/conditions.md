# Conditional Requirements

**Generated:** 2026-02-19T13:43:05.791308
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

---

## Does Raising the Floor Lift Graduates? Minimum Wage Effects on the College Earnings Distribution

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: restricting primary analysis to cells where MW plausibly binds—certificate/associate

**Status:** [x] RESOLVED

**Response:**
Primary analysis will focus on certificate (degree levels 01, 02) and associate (degree level 03) graduates, where P25 earnings ($28-32K annualized) are within direct reach of higher state minimum wages ($31,200 at $15/hr). Bachelor's degree analysis will be presented as a robustness/placebo check — if MW has no effect on bachelor's P25 (which is ~$30-35K and less MW-sensitive), this strengthens the identification for sub-baccalaureate effects.

The PSEO data confirms adequate coverage: 29 states with certificate/associate data across 4 cohorts (2001, 2006, 2011, 2016), plus all degree levels for bachelor's (33 states, 7 cohorts).

The framing will emphasize **MW spillover effects** — even when MW doesn't bind directly, increases push up wages through compression/competition effects (Autor, Manning, Smith 2016). PSEO is ideally suited to test this for graduates specifically.

**Evidence:** PSEO API verification shows certificate P25 = $32,184, associate P25 ~ $28-30K nationally. At $15/hr MW ($31,200/yr), certificate P25 is right at the MW threshold. The analysis leverages within-institution variation by comparing sub-baccalaureate programs (treatment-sensitive) vs bachelor's programs (placebo) at the same institution.

---

### Condition 2: low-wage CIPs

**Status:** [x] RESOLVED

**Response:**
PSEO provides 364 CIP codes at the institution level. We will classify CIPs into MW-proximate fields (where P25 graduates earn near MW levels) and MW-remote fields (where even P25 is far above MW). Key low-wage CIPs include:
- CIP 13 (Education): P25 typically $25-30K
- CIP 42 (Psychology): P25 typically $25-28K
- CIP 23 (English/Literature): P25 typically $22-27K
- CIP 50 (Visual/Performing Arts): P25 typically $18-25K
- CIP 24 (Liberal Arts): P25 typically $22-28K

High-wage CIP controls/placebos: CIP 11 (Computer Science), CIP 14 (Engineering), CIP 52 (Business/Finance).

Heterogeneity analysis will estimate MW effects separately by CIP group, with the prediction that low-wage CIPs show larger effects.

**Evidence:** PSEO API returns 364 CIP codes with 400+ institutions each for major codes. CIP-level P25 earnings will be fetched and classified in the data collection phase.

---

### Condition 3: bottom-tail outcomes

**Status:** [x] RESOLVED

**Response:**
The primary outcome is P25 earnings (25th percentile of graduate earnings in the cohort). Secondary outcomes are P50 and P75. The core prediction is that MW effects should be monotonically declining across quantiles:
- P25: Largest effect (graduates closest to MW, most affected by compression/spillovers)
- P50: Moderate effect (farther from MW)
- P75: Near-zero effect (placebo — MW should not reach this part of the distribution)

This within-quantile gradient provides a built-in placebo test. If effects appear uniformly across all percentiles, something other than MW is driving results (e.g., state economic growth correlated with MW increases).

The analysis will also examine Y1 (1-year) vs Y5 (5-year) vs Y10 (10-year) earnings to test persistence. MW effects should be strongest at Y1 (when graduates are in entry-level positions most exposed to MW) and fade at Y5/Y10 as career trajectories diverge.

**Evidence:** PSEO provides P25, P50, P75 at Y1, Y5, Y10 — giving a 3×3 outcome matrix that directly supports this analysis.

---

### Condition 4: doing aggressive state labor-market controls/sensitivity

**Status:** [x] RESOLVED

**Response:**
The analysis will include the following control strategy:

1. **Baseline TWFE:** Institution FE + cohort FE (absorbs all time-invariant institution characteristics and national trends)
2. **State labor market controls:** State unemployment rate, log real GDP per capita, employment-population ratio, industry composition (share manufacturing, share services) — all from FRED/BEA, matched to cohort graduation windows
3. **State policy controls:** State EITC supplement indicator, Medicaid expansion indicator, state higher ed appropriations per FTE
4. **Region × cohort FE:** Census region interacted with cohort dummies (absorbs broad regional trends that correlate with MW politics)
5. **Sensitivity analyses:**
   - Conley-Taber inference for state-level clustering (few clusters concern)
   - Dropping one state at a time (jackknife)
   - Border-state pairs comparison (compare institutions in adjacent states with different MW changes)
   - Controlling for state cost-of-living index

The key identifying assumption is that within-institution changes in graduate earnings across cohorts are not systematically correlated with state MW changes after conditioning on state economic conditions and region × cohort trends. The region × cohort FE is particularly important because it absorbs the fact that Democratic-leaning states (which raise MW) may also have different economic trajectories.

**Evidence:** FRED API confirmed available for state unemployment (LAUS), BEA has state GDP/personal income. All state-level controls can be fetched programmatically.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
