# Revision Plan (Stage C)

## Reviewer Summary

- **GPT-5-mini:** MAJOR REVISION — concerns about permutation method clarity (already fixed in advisor round), table/figure completeness (false positive from LaTeX route), missing references
- **Grok-4.1-Fast:** MINOR REVISION — calls methodology "exemplary" and "fully publishable on inference alone"; suggests converting bullet lists to prose, adding 3 references, minor trimming
- **Gemini-3-Flash:** MINOR REVISION — calls paper "high-quality, technically sophisticated"; suggests Figure cross-reference check, synthetic control as robustness, marketplace insurance outcome

## Planned Changes

### 1. Convert enumerated lists to prose (Grok, GPT)
- Section 3.4 "Testable Predictions": convert `\begin{enumerate}` to prose paragraphs

### 2. Add missing references (Grok, Gemini)
- Sommers et al. (2024) on unwinding heterogeneity → cite in Section 2.3 and Discussion

### 3. Cross-reference check (Gemini)
- Verify all figure/table references are correct

### 4. Scale consistency note (Gemini advisor)
- Already added "All estimates on 0-1 scale; multiply by 100 for percentage points" to table notes

### Items NOT addressed (with justification)
- Synthetic control / augmented SCM: Would require substantial new code; SCM with 4 control states is methodologically questionable; cite Abadie et al. (2010) and explain why not used (already done)
- Admin data merge: Beyond scope of ACS-based analysis; discussed as future work
- Marketplace insurance outcome: ACS variable HINS2 exists but adds complexity without clear value; noted as extension
