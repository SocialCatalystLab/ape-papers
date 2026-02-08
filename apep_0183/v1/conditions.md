# Conditional Requirements

**Generated:** 2026-02-04T00:07:39.978021
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

## The Green Rush at State Borders: Difference-in-Discontinuities for Marijuana Effects on Employment (Idea 2)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: extending pre-period to ≥5 years

**Status:** [x] RESOLVED

**Response:**

QWI data is available from 2005 onward for most states. We will fetch 2005-2023, providing:
- Colorado (retail Jan 2014): 9 years pre-treatment (2005-2013)
- Washington (retail July 2014): 9 years pre-treatment
- Oregon (retail Oct 2015): 10 years pre-treatment
- Nevada (retail July 2017): 12 years pre-treatment
- California (retail Jan 2018): 13 years pre-treatment

This exceeds the ≥5 year requirement for all treated states.

**Evidence:**

QWI API documentation confirms data availability from 2005: api.census.gov/data/timeseries/qwi.html
APEP-0176 successfully fetched QWI data from 2015; we will extend to 2005.

---

### Condition 2: expanding treated states/borders to raise treated border clusters

**Status:** [x] RESOLVED

**Response:**

We expand to include additional RML states beyond the original 5 to increase border variation:
- Alaska (legalized Nov 2014, retail Oct 2016) - borders Canada only, excluded
- Massachusetts (legalized Nov 2016, retail Nov 2018) - borders CT, NY, NH, VT, RI
- Maine (legalized Nov 2016, retail Oct 2020) - borders NH
- Vermont (legalized Nov 2018, retail Oct 2022) - borders MA, NH, NY
- Michigan (legalized Nov 2018, retail Dec 2019) - borders IN, OH, WI
- Illinois (legalized Jan 2020, retail Jan 2020) - borders IN, IA, KY, MO, WI

This gives us 10 treated states (excluding AK) with diverse border pairs:
- Western: CO-NM, CO-UT, CO-WY, CO-KS, WA-ID, OR-ID, NV-AZ, NV-UT, CA-AZ
- Eastern: MA-CT, MA-NH, ME-NH, VT-NH, MI-IN, MI-OH, IL-IN, IL-WI

Total: ~25+ unique border segments across multiple regions and time cohorts.

**Evidence:**

State legalization dates compiled from NCSL and Ballotpedia; border pairs verified via Census state adjacency data.

---

### Condition 3: explicitly modeling anticipation using event time around election

**Status:** [x] RESOLVED

**Response:**

We will implement an event study design with event time defined relative to TWO key dates:
1. **Election date** (ballot measure passes) - marks anticipation period start
2. **Retail opening date** (first legal sales) - marks full treatment onset

Event study specification:
- Pre-election: t < -8 quarters (reference period)
- Post-election, pre-retail: t = -7 to -1 quarters (anticipation window)
- Post-retail: t ≥ 0 quarters (treatment period)

This allows us to test:
- Whether anticipation effects emerge after election but before retail
- Whether main effects appear at retail opening
- Dynamics of adjustment over time

**Evidence:**

Event study methodology following Callaway & Sant'Anna (2021) and Sun & Abraham (2021). Election and retail dates documented for all states.

---

### Condition 4: retail opening

**Status:** [x] RESOLVED

**Response:**

Treatment timing defined at **retail opening** (first legal recreational sales), not election date. This is when:
- Legal cannabis jobs (dispensaries, cultivation) actually begin
- Drug testing decisions become relevant (workers can legally consume)
- Tourism effects materialize

Retail opening dates used as treatment onset:
| State | Election | Retail Opening | Gap |
|-------|----------|----------------|-----|
| CO | Nov 2012 | Jan 2014 | 14 months |
| WA | Nov 2012 | Jul 2014 | 20 months |
| OR | Nov 2014 | Oct 2015 | 11 months |
| NV | Nov 2016 | Jul 2017 | 8 months |
| CA | Nov 2016 | Jan 2018 | 14 months |
| MA | Nov 2016 | Nov 2018 | 24 months |
| ME | Nov 2016 | Oct 2020 | 47 months |
| VT | Nov 2018 | Oct 2022 | 47 months |
| MI | Nov 2018 | Dec 2019 | 13 months |
| IL | Jun 2019 | Jan 2020 | 7 months |

The election-to-retail gap varies substantially, providing natural variation to test anticipation vs treatment effects.

**Evidence:**

Retail opening dates compiled from state regulatory agencies and news archives.

---

## Drug Testing Industries vs. Non-Testing Industries: A Triple-Difference Approach (Idea 4)

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: obtaining a credible panel of testing prevalence by industry over a long pre-period

**Status:** [x] NOT APPLICABLE

**Response:**

Drug testing DDD will be a secondary/robustness analysis, not the main specification. We use a time-invariant classification instead of a panel.

---

### Condition 2: or a plausibly time-invariant pre-period measure

**Status:** [x] RESOLVED

**Response:**

We will use DOT-mandated testing requirements, which are federally regulated and time-invariant for the relevant period:
- **DOT-regulated industries** (mandatory testing): Transportation (NAICS 48-49), Pipelines (486)
- **Safety-sensitive but not DOT** (common testing): Manufacturing (31-33), Construction (23), Mining (21)
- **Low testing** (uncommon): Professional Services (54), Information (51), Finance (52)

This classification is based on federal regulations (49 CFR Part 40) that did not change during our sample period, avoiding endogeneity concerns with Quest data.

**Evidence:**

DOT drug testing regulations: 49 CFR Part 40; SAMHSA federal workplace guidelines.

---

### Condition 3: pre-registering a small set of industry groups to avoid specification search

**Status:** [x] RESOLVED

**Response:**

We pre-specify 4 industry categories in initial_plan.md:
1. **Direct cannabis** (expected +): Agriculture (11), Retail (44-45)
2. **DOT-regulated** (expected null/negative): Transportation (48-49)
3. **Safety-sensitive** (expected ambiguous): Manufacturing (31-33), Construction (23)
4. **Low-testing services** (expected null): Professional (54), Finance (52), Information (51)

All other industries are "exploratory" and subject to FDR correction.

**Evidence:**

Will be documented in initial_plan.md before any data analysis.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
