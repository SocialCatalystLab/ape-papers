# Internal Review (Round 2) — Claude Code

**Paper:** The €6,000 Question: Do Apprenticeship Subsidies Create Jobs or Relabel Hiring?

## PART 1: POST-REVISION CHECK

Checked all items from Round 1:

1. **Exposure scaling:** Now consistent throughout. Exposure in percentage points (1-18), coefficients per pp. Table 1 SD (4.6) matches text. Table 5 coefficients match Table 2.

2. **adjustbox package:** Added to preamble. All wide tables now render fully.

3. **WCB implementation:** Correctly uses restricted null hypothesis with Rademacher weights. P-values (0.029 main, 0.007 level, 0.026 total, 0.391 cross-country) are sensible.

4. **RI implementation:** Fixed to permute at sector level. P-value = 0.13, consistent with clustered SE p = 0.07.

5. **SCM analysis:** Pre-treatment RMSPE = 2.0, weights dominated by Spain (72%) and Netherlands (19%). Fisher p = 0.625, correctly interpreted as "no statistically significant effect."

6. **Pre-2025 robustness:** Table 6 confirms results are robust to excluding the February 2025 reform. Coefficients are similar across sample windows.

7. **Total employment red flag:** Clearly flagged in text as identification concern.

8. **Framing:** Abstract and conclusion use appropriately cautious language ("provisional answer," "suggestive").

## PART 2: REMAINING MINOR ISSUES

1. Table 1 notes still say "Bartik DiD analysis" — should say "exposure DiD analysis" for consistency.
2. Consider adding N for each column in Table 5 (inference comparison).

## DECISION

DECISION: CONDITIONALLY ACCEPT
