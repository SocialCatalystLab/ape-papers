# Revision Plan - Round 1

**Date:** 2026-01-21
**Responding to:** Internal Review (review_cc_1.md)

---

## Major Issues to Address

### 1. Pre-trends Sensitivity Analysis
**Issue:** No HonestDiD or other sensitivity analysis for pre-trends violations
**Action:**
- Add discussion of what the pre-trends pattern implies
- Note that HonestDiD requires the `did` package which failed to install
- Add explicit bounds discussion: if pre-trends were to continue, what would we expect?
- Reframe findings as descriptive rather than causal

### 2. Unemployment Puzzle
**Issue:** Positive unemployment effect is counterintuitive and unexplained
**Action:**
- Add paragraph exploring the labor force entry hypothesis more carefully
- Note that this pattern is consistent with discouraged worker re-entry
- Acknowledge this could also indicate fundamental identification failure

### 3. Fix Broken Citations
**Issue:** Citations showing as "(??)" and tables as "Table ??"
**Action:**
- Check .bib file and natbib settings
- Ensure \cite commands match bibliography entries
- Fix \ref commands for tables and figures

### 4. Fix Table/Figure References
**Issue:** Cross-references broken
**Action:**
- Verify \label commands are placed after \caption
- Recompile twice to resolve references

### 5. Robustness Check - Exclude COVID Years
**Issue:** No robustness checks presented
**Action:**
- Run analysis excluding 2020-2021
- Report if results change substantively

### 6. Expand Literature Review
**Issue:** Only 4 citations
**Action:**
- Add Agan & Starr (2018) on Ban the Box
- Add Doleac & Hansen (2020) on statistical discrimination
- Add Prescott & Starr (2020) on expungement effects
- Cite Clean Slate Initiative reports for policy background

### 7. Reframe Abstract
**Issue:** Abstract doesn't lead with identification concerns
**Action:**
- Restructure to present findings as descriptive patterns
- Move limitation to more prominent position

---

## Implementation Order

1. Fix LaTeX citations/references (quick)
2. Rewrite abstract (quick)
3. Add literature citations (medium)
4. Add discussion of pre-trends implications (medium)
5. Expand unemployment discussion (medium)
6. Run robustness check excluding COVID (requires R)
7. Recompile and verify

---

## Expected Outcome

Paper will be more honest about its limitations while still contributing descriptive evidence. Target: Conditional Accept or Minor Revision on round 2.
