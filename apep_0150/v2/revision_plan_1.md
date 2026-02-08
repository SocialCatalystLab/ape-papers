# Revision Plan (Stage C)

## Review Summary
- GPT-5-mini: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Grouped Concerns and Actions

### 1. Wild Cluster Bootstrap (GPT - critical)
**Status:** Cannot be computed — fwildclusterboot not available for R 4.5.2.
**Action:** Already documented limitation. Add stronger justification citing Cameron et al. (2008) and note that 51 clusters is well above the threshold where cluster-robust SEs perform poorly. Add explicit statement that CR2 provides analogous small-sample correction.

### 2. HonestDiD Diagonal VCV (GPT - critical)
**Status:** Software limitation — CS-DiD bootstrap does not return full VCV.
**Action:** Already documented. Strengthen text to note that diagonal approximation is likely conservative for confidence interval width (ignoring positive correlation between adjacent event-time estimates), and that the qualitative conclusion (null robust to M-bar=2) is unlikely to change with full VCV.

### 3. MDE Mapping / Dilution Algebra (GPT - important)
**Action:** Add explicit algebraic mapping in Discussion showing implied treated-group effects for different population shares (s = 3%, 5%, 10%, 15%).

### 4. Missing References (all reviewers)
**Action:** Add Cameron et al. (2008), Abadie et al. (2010), Athey & Imbens (2022). Already have Cameron 2015 cited.

### 5. Placebo Outcomes with Post-Treatment Variation (GPT)
**Status:** Cancer/heart placebos only cover 1999-2017. Would need to fetch post-2020 provisional data for these causes.
**Action:** Note as limitation; the pre-treatment-only placebo is still informative for selection on observables. Fetching post-treatment placebo data is out of scope for this revision cycle.

### 6. Writing Improvements (GPT)
**Action:** Minor reorganization of Discussion to foreground MDE mapping. Keep changes minimal.

## Items NOT Addressed (out of scope)
- Synthetic control analysis (suggested by GPT/Gemini)
- Age-stratified mortality (data not available at needed granularity)
- DKA hospitalization data (HCUP not accessible via API)
- Triple-diff with Medicare (individual-level data needed)
- 2024-2025 data update (not yet available)
