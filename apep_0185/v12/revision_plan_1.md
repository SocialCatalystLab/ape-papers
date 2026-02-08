# Revision Plan (Stage C - Post External Review)

## Summary of Reviews
- **GPT-5-mini:** MAJOR REVISION — SCI timing, event study, job flow reconciliation, exclusion evidence
- **Grok-4.1-Fast:** MINOR REVISION — Pre-trend figure, missing references
- **Gemini-3-Flash:** MAJOR REVISION — Magnitude concerns, commuting zone suggestion

## Changes Made

### 1. Strengthened SCI Timing Discussion (All reviewers)
Added dedicated paragraph in Section 11 (Limitations) addressing the 2018 SCI vintage concern:
- SCI correlation >0.99 across vintages (Facebook documentation)
- Bailey et al. (2020) validate against decennial census migration
- Population weights use pre-treatment 2012-2013 employment (not SCI-derived)
- Distance-restricted instruments show STRONGER effects, opposite of endogeneity prediction

### 2. Softened Causal Language (GPT)
Changed "plausibly excludable" to "plausible under maintained assumptions" in the introduction and identification sections.

### 3. Added Magnitude Discussion (Gemini)
Added paragraph in Section 11 addressing the 9% employment magnitude:
- This is the LATE for high-compliance counties
- Network average MW ≠ direct own-MW increase
- Comparable to Kline & Moretti (2014) spatial multipliers
- One-SD variation yields ~8.6% employment effect

### 4. Reconciled Job Flows vs Employment (GPT)
Added paragraph in Section 9 explaining:
- QWI job flow data has 25% suppression vs 1% for employment (different samples)
- Employment stock vs gross flow measurement distinction
- Hire rate (0.058) slightly exceeds separation rate (0.044), consistent with rising employment

### 5. Added Missing References (Grok, Gemini)
- Monras (2020) JPE — spatial labor market adjustment
- Dustmann et al. (2022) QJE — minimum wage reallocation effects

### 6. Fixed Advisor Issues (Pre-external review)
- Table 12: Fixed column overflow (earnings column was truncated)
- Figure 8 caption: Corrected to accurately describe Q1/Q4 ordering
- Table 9: Added footnote on firm job creation coefficient and measurement error

## Changes NOT Made (with rationale)
- **Event study**: User explicitly requested dropping event study analysis
- **Commuting zone analysis**: Would require new data construction and R analysis; noted as future work
- **Individual-level CPS/ACS analysis**: Outside scope of this county-level panel study
- **Alternative SCI vintages**: Only one vintage available; addressed via discussion
