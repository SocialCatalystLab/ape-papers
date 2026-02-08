# Paper 73: Initialization

**Created:** 2026-01-23
**Hash:** [computed below]

---

## Phase 1: Setup Q&A

### Q1: Policy Domain
**Answer:** Surprise me (Recommended)
**Note:** User specifically requested exploring Facebook Social Connectedness Index (SCI) data for a novel angle — causal if possible, otherwise strong descriptive/correlational work.

### Q2: Causal Inference Method
**Answer:** Surprise me + Modern data
**Note:** Method will be determined by what identification strategy is feasible with cross-sectional SCI data. Possibilities include border RDD, shift-share/Bartik instruments using SCI as exposure weights, or descriptive analysis.

### Q3: Historical MLP Focus
**Answer:** No — Modern data

### Q4: API Keys Configured
**Answer:** Yes (partial)
- IPUMS: Configured
- FRED: Key present but returning errors
- Primary data source: Facebook SCI (public download)

### Q5: External Review
**Answer:** Yes — GPT 5.2 external review enabled

### Q6: Other Preferences
**Answer:** Custom
- **User request:** Write a paper using Facebook Social Connectedness Index data
- **Data source:** https://data.humdata.org/dataset/social-connectedness-index
- **Specific file:** GADM1/NUTS3/Counties level global data (October 2021)
- **Flexibility:** Causal identification preferred, but descriptive/correlational acceptable
- **Goal:** Novel take on SCI data — something not heavily studied

---

## System Information

**Claude Model:** claude-opus-4-5
**Working Directory:** /Users/dyanag/auto-policy-evals
**Git Branch:** main (clean)

---

## Data Sources

### Primary
- **Facebook Social Connectedness Index (SCI)**
  - URL: https://data.humdata.org/dataset/social-connectedness-index
  - Level: GADM1/NUTS3/Counties (sub-national)
  - Coverage: Global
  - Date: October 2021
  - Format: ZIP containing TSV

### Supplementary (to be determined)
- Economic outcomes (BEA, Census)
- Policy adoption dates (varies)
- Demographic data (Census/ACS)
- Other outcome data as needed

---

## Research Direction

The SCI measures social connectedness between geographic regions based on Facebook friendship links. Cross-sectional nature limits traditional panel methods, but several identification strategies remain viable:

1. **Border RDD** — Compare areas just across state/country borders with different policies but similar SCI profiles
2. **Shift-share / Bartik** — Use SCI as exposure weights to exogenous shocks elsewhere
3. **Spatial discontinuity** — Exploit geographic features that create SCI discontinuities
4. **Strong descriptive** — Novel correlations between SCI and understudied outcomes

Discovery phase will explore all options.
