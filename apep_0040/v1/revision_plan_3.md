# Revision Plan - Round 3

## Response to GPT 5.2 External Review Round 2 (REJECT AND RESUBMIT)

### Issue 1: Novelty vs. Levine & Rubinstein (2017)

**Problem:** Reviewer notes L&R 2017 already shows incorporated ("smart") self-employment earns more.

**Fix:** Add explicit paragraph differentiating this paper:
- L&R uses NLSY79 (cohort data); we use ACS 2022 (nationally representative cross-section)
- L&R focuses on entrepreneurial ability and selection mechanism; we focus on sensitivity analysis and transparent quantification of confounding
- L&R uses panel data and ability measures; we provide a methodological demonstration with modern sensitivity tools

### Issue 2: Outcome is Total Personal Income (PINCP)

**Problem:** PINCP includes non-business income (interest, dividends, transfers). Not a clean measure of business performance.

**Fix:** Add footnote acknowledging this limitation. Note that:
- ACS does not separate self-employment income for incorporated workers (who report wages from their corporation)
- The limitation biases interpretation but is unavoidable with ACS data
- Future work with administrative data (IRS SOI, linked Census-IRS) could address this

### Issue 3: Missing State FE, Occupation FE

**Problem:** Main table only goes up to industry FE. State FE important because incorporation costs/tax climates vary by state.

**Fix:**
- Add column (5) with state FE to main table
- Note that we cannot add occupation FE because occupation and self-employment are conceptually intertwined for many workers

### Issue 4: Missing Distributional Analysis

**Problem:** Only shows means. Income is highly skewed.

**Fix:** Add subsection showing:
- Median premium (less sensitive to outliers)
- Note about log income (but we have zero/negative income concerns)

### Issue 5: ACS Replicate Weights

**Problem:** We use robust SEs, not replicate weights.

**Fix:** Add acknowledgment in Data section that:
- ACS has replicate weights (PWGTP1-80)
- We use robust SEs as approximation
- For descriptive work on large samples, this typically does not materially affect inference
- Full replicate weight implementation is beyond scope

### Issue 6: Missing References

**Fix:** Add suggested references:
- Gordon & MacKie-Mason (1994) on tax distortions and organizational form
- Goolsbee (2004) on corporate tax and organizational form
- Solon, Haider & Wooldridge (2015) on weighting

### Issue 7: Paper Still Too Short

**Fix:** Expand with:
- More detail in Related Literature on how this paper differs from L&R
- Additional robustness with state FE
- Brief distributional analysis

## Implementation

1. Add paragraph in Related Literature distinguishing from L&R 2017
2. Add footnote about PINCP limitation
3. Add specification (5) with state FE to Table 2 and text
4. Add brief median/distributional note
5. Add replicate weights acknowledgment
6. Expand bibliography
