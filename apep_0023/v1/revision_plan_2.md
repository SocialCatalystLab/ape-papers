# Revision Plan - Round 2

## Overview

Address remaining issues from Round 2 internal review focusing on completeness and clarity.

---

## Changes to Implement

### 1. Remove Empty Column from Table 2

**File:** `paper.tex`
**Action:** Remove column (3) "Event Study" from Table 2 since it contains no data.

### 2. Add Formal Parallel Trends Test

**File:** `data/analyze_did.py`
**Action:** Compute joint test of pre-period coefficients equaling zero.

**File:** `paper.tex`
**Action:** Add the test result to Section 5.2 Event-Study Results.

### 3. Fix Figure 3 Category Labels

**File:** `data/create_figures.py`
**Action:** Reposition the group category labels in Figure 3 to be properly aligned using y-coordinates that match the actual bar positions.

### 4. Add Counterfactual Explanation to Section 5.5

**File:** `paper.tex`
**Action:** Add explanatory text about how the counterfactual line in Figure 4 is constructed.

### 5. Add HELP-Link Participation Discussion

**File:** `paper.tex`
**Action:** Add a paragraph discussing the low participation rate and its implications for interpreting the ITT estimate.

### 6. Improve Figure Captions

**File:** `paper.tex`
**Action:** Expand Figure 3 and Figure 4 captions to be self-contained.

### 7. Add State-Specific Economic Shocks to Limitations

**File:** `paper.tex`
**Action:** Add brief discussion of potential state-specific confounders.

### 8. Clarify Bootstrap vs Analytic SE

**File:** `paper.tex`
**Action:** Add footnote explaining SE methodology.

---

## Execution Order

1. Update analyze_did.py with parallel trends test
2. Update create_figures.py to fix Figure 3 labels
3. Re-run analysis and regenerate figures
4. Update paper.tex with all text changes
5. Recompile PDF
6. Visual QA
