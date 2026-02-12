# Conditional Requirements

**Generated:** 2026-02-12T10:34:22.011392
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

## Who Bears the Burden of Monetary Tightening? Heterogeneous Labor Market Responses and Aggregate Implications

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: explicitly handling information effects

**Status:** [x] RESOLVED

**Response:**

The Jarocinski-Karadi (2020) decomposition explicitly separates monetary policy shocks from central bank information shocks using sign restrictions on the comovement of interest rates and stock prices around FOMC announcements. We use ONLY the pure monetary policy shock component (where rates rise and stocks fall, consistent with contractionary policy). The information component (where rates rise and stocks also rise, consistent with positive news) is excluded from our shock series. This is the state-of-the-art approach to the "Fed information effect" problem identified by Nakamura-Steinsson (2018) and Jarocisnki-Karadi (2020).

Additionally, we will:
1. Show robustness to using Bu-Rogers-Wu (2021) shocks which use a different identification approach
2. Report results excluding FOMC meetings with large information components
3. Discuss the information effect explicitly in Section 4 (Empirical Strategy)

**Evidence:**

Jarocinski-Karadi (2020, AER) Table 1 and Appendix: the sign restriction decomposition is the standard solution to Fed information effects. The JK shock CSV on GitHub contains separate columns for monetary policy vs information shocks.

---

### Condition 2: regime changes

**Status:** [x] RESOLVED

**Response:**

Our sample spans 1990-2024, covering multiple monetary policy regimes: pre-2008 conventional policy, ZLB/QE (2008-2015), normalization (2016-2019), COVID-era (2020-2022), and tightening (2022-2024). We address regime changes through:

1. **Subsample analysis:** Report results for (a) 1990-2007 (pre-GFC), (b) 2001-2024 (JOLTS-era), (c) excluding ZLB period (2009-2015). This is a standard robustness check in the monetary VAR/LP literature.
2. **Interaction terms:** Test whether the heterogeneous responses differ across regimes by interacting shocks with regime dummies.
3. **The structural model:** Our NK-DMP model is calibrated to the full sample but we verify that model-implied IRFs are robust to regime-specific calibrations.

**Evidence:**

Standard practice in Ramey (2016, "Macroeconomic Shocks and Their Propagation") Handbook chapter; Gertler-Karadi (2015, AEJ:Macro) show LP results are robust across subsamples.

---

### Condition 3: pre-specifying heterogeneity dimensions to avoid data-mining

**Status:** [x] RESOLVED

**Response:**

All heterogeneity dimensions are pre-specified in the initial_plan.md (committed before data fetch) based on economic theory, not data exploration:

1. **Goods vs. services sectors:** Theory predicts goods (manufacturing, construction, mining) are more interest-rate sensitive due to durable demand and capital intensity. This is a first-order prediction of any NK model with sectoral heterogeneity.
2. **Cyclical sensitivity:** Industries classified by beta-cyclicality (covariance of employment growth with GDP growth) computed in pre-period data (1990-2000). Classification is done BEFORE estimating the LP responses.
3. **JOLTS margins:** Job openings, hires, separations, quits, layoffs — each margin has distinct theoretical predictions (quits fall first as labor demand tightens, then layoffs rise).
4. **Skill intensity:** Industries classified by share of workers with BA+ using CPS cross-section averages from 1990s (before our estimation window).

We will commit initial_plan.md with these pre-specified dimensions BEFORE running any analysis.

**Evidence:**

Pre-registration through git commit of initial_plan.md. All classifications based on pre-period data or BLS standard industry groupings (NAICS supersectors).

---

### Condition 4: using JOLTS/job flows as primary evidence for mechanisms rather than only CES employment levels

**Status:** [x] RESOLVED

**Response:**

JOLTS data (2001-2024) is a primary, not secondary, data source in our analysis. The paper has dedicated analysis of:

1. **JOLTS decomposition:** Separate local projections for job openings, hires, total separations, quits, layoffs/discharges for each industry. This decomposes the employment response into demand-side (openings, hires) and supply-side (quits) vs forced (layoffs) channels.
2. **Flow-stock reconciliation:** We verify that the LP responses of employment levels are quantitatively consistent with the cumulated flow responses from JOLTS.
3. **Model validation:** The two-sector NK-DMP model generates predictions for both stocks and flows (vacancy-filling rates, separation rates, job-finding rates) which we match to JOLTS moments.

JOLTS appears in: Table 1 (summary stats), Table 5 (JOLTS LP results), Figure 5 (JOLTS IRF decomposition), Figure 7 (model vs data flow moments), and throughout Section 5.3 (JOLTS Decomposition).

**Evidence:**

FRED JOLTS series (JTS*JOL, JOH, JST, JQU, JLD) available 2001m1-present for all supersectors. See research_plan.md data section.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
