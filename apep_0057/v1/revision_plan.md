# Paper 73: Revision Plan

Based on three referee reviews, all recommending REJECT AND RESUBMIT.

## Key Critiques

### 1. Fundamental Design Problem (All 3 Reviewers)
**Issue:** Regressing y_i on Σ w_ij × y_j is NOT shift-share—it's a spatial autoregressive (SAR) model with reflection/simultaneity issues.

**Fix Required:** Either:
- Use exogenous "shifts" (plant closures, disasters) instead of contemporaneous outcomes
- Estimate proper SAR via ML/GMM (Kelejian-Prucha)
- Reframe as pure spatial correlation measurement

### 2. Inference Problems (All 3 Reviewers)
**Issue:** OLS with state-clustered SEs inadequate for spatial dependence. Need Conley spatial HAC.

**Fix Required:**
- Implement Conley (1999) SEs with distance cutoffs
- Add sensitivity to cutoff choice
- Consider wild cluster bootstrap

### 3. Outcome Measurement (All 3 Reviewers)
**Issue:** ACS 5-year windows overlap (2015-2019 vs 2017-2021), not a clean COVID shock.

**Fix Required:**
- Use BLS LAUS monthly county unemployment
- Or use QCEW employment data
- Define precise shock windows

### 4. Leave-Out-State Results (All 3 Reviewers)
**Issue:** Coefficient flips negative with out-of-state exposure only—strong evidence against network transmission interpretation.

**Response:** This is actually a feature, not a bug. It shows the correlation is spatial, not social. Paper should lean into this finding.

### 5. Missing Literature (All 3 Reviewers)
**Add citations:**
- Anselin (1988) - Spatial Econometrics
- Conley (1999) - Spatial HAC
- Manski (1993) - Reflection problem
- Adao-Kolesar-Morales (2019) - Shift-share inference
- Borusyak-Hull-Jaravel (2022) - Shift-share designs
- Topa (2001), Bayer-Ross-Topa (2008) - Networks and labor

### 6. Writing/Length (All 3 Reviewers)
**Issue:** Main text ~13 pages, too short. Bullet-heavy identification section.

**Fix Required:**
- Expand to 25+ pages of prose
- Rewrite mechanisms section as paragraphs
- Add distance decomposition analysis

## Strategic Decision

Given the fundamental design flaws, two paths forward:

**Path A: Redesign as Causal Paper**
- Find exogenous shocks (plant closures, disasters)
- Use shock × SCI exposure
- Estimate proper SAR or shift-share
- Major revision, essentially new paper

**Path B: Reframe as Measurement/Descriptive**
- Be explicit: this is spatial correlation measurement
- Remove all "transmission" language
- Focus on: SCI predicts co-movement, but so does distance
- Add: decomposition of SCI vs distance explanatory power
- Contribute: documentation of spatial structure

**Recommended:** Path B with immediate revisions to the descriptive framing. The paper's honest finding—that the correlation is geographic, not social—is still a contribution.

## Lessons Learned for top10_mistakes.md

1. **Shift-share requires exogenous shifts**: Using contemporaneous outcomes creates reflection problem
2. **SAR ≠ OLS**: Spatial lag models need proper estimation
3. **State clustering ≠ spatial inference**: Need Conley SEs
4. **ACS 5-year overlaps**: Don't use for shock analysis
5. **Leave-out tests can backfire**: If they flip sign, that's information
