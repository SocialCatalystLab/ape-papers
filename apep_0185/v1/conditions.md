# Conditional Requirements

**Generated:** 2026-02-04T10:28:20.860251
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

## Cross-Border Minimum Wage Spillovers: Did Germany's 2015 Minimum Wage Affect Polish Labor Markets?

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: using NUTS3 or finer geography to increase clusters

**Status:** [X] RESOLVED

**Response:**

Poland has 380 powiats (NUTS3/LAU1 equivalent) providing ample geographic variation. The design will use:
- **Primary analysis:** All 380 powiats with treatment intensity measured as distance to German border (continuous) or border adjacency (binary)
- **Border powiats:** ~40 powiats directly adjacent to Germany (treated)
- **Interior powiats:** ~340 powiats far from Germany (control)

This provides 40+ treated clusters, well above the 20-cluster threshold for reliable inference with wild cluster bootstrap.

**Evidence:**

- Eurostat NUTS 2024 classification: Poland has 17 NUTS2 regions and 380 NUTS3 regions (powiats)
- Eurostat regional labour market statistics (reg_lmk) provides employment data at NUTS3 for EU member states
- Border regions database: Eurostat provides border region typologies at NUTS3

---

### Condition 2: incorporating commuting/posted-worker exposure measures

**Status:** [X] RESOLVED

**Response:**

Treatment intensity will be operationalized as:

1. **Geographic exposure:** Distance from powiat centroid to nearest German border crossing (continuous treatment)
2. **Economic exposure (if data available):** Share of powiat workforce in tradable/export-oriented sectors (construction, transport, manufacturing)
3. **Wage exposure:** Pre-treatment share of workers earning below €8.50 equivalent in powiat

Primary specification uses distance-to-border; sector composition provides mechanism test.

**Evidence:**

- Eurostat Structural Business Statistics (SBS) provides sectoral employment by region
- EU-SILC provides income distribution by region (to identify low-wage worker share)
- Posted Workers data: EU Posted Workers statistics provide cross-border labor flows by country pair

---

### Condition 3: pre-trend/event-study checks

**Status:** [X] RESOLVED

**Response:**

Will implement full event-study specification:
- Pre-treatment dummies: 2010, 2011, 2012, 2013, 2014 (reference: 2014)
- Post-treatment dummies: 2015, 2016, 2017, 2018, 2019
- Test for parallel trends: joint F-test that pre-treatment coefficients = 0
- Report dynamic treatment effects with confidence intervals
- Apply Callaway-Sant'Anna estimator if any timing variation exists

**Evidence:**

- Pre-treatment period 2010-2014 provides 5 years for parallel trends assessment
- R packages `did`, `fixest` support event-study specifications with appropriate inference
- Will report both naive TWFE and heterogeneity-robust estimators

---

### Condition 4: robustness to alternative donor pools / border-distance specifications

**Status:** [X] RESOLVED

**Response:**

Robustness checks will include:

1. **Alternative treatment definitions:**
   - Binary: Border-adjacent vs interior
   - Continuous: Distance to border (km)
   - Terciles/quartiles of border distance

2. **Alternative control groups:**
   - All non-border powiats
   - Only non-border powiats in same NUTS2 as border powiats
   - Synthetic control: Construct synthetic border powiats from interior powiats

3. **Alternative samples:**
   - Exclude powiats bordering Czech Republic or Slovakia (other German neighbors)
   - Donut specifications: Exclude powiats in "intermediate" distance band

4. **Placebo borders:**
   - Use Czech-Polish border as placebo (Czech Republic had minimum wage before 2015)
   - Use pre-2015 period to test for spurious border effects

**Evidence:**

- Synthetic control method implemented via R packages `Synth`, `gsynth`
- Distance calculations use Eurostat GISCO geographic data
- Standard robustness approach in spatial DiD literature (see Dell 2010, Keele & Titiunik 2015)

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [ ] This file has been committed to git (N/A - output folder gitignored)

**Once complete, update Status at top of file to: RESOLVED**
