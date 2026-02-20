# Stage C Revision Plan — apep_0427 v2

## Based on External Reviews (Stage B)

### Reviewer 1 (GPT-5.2): MAJOR REVISION
### Reviewer 2 (Grok-4.1-Fast): MINOR REVISION
### Reviewer 3 (Gemini-3-Flash): MINOR REVISION

---

## Critical Issue: Sectoral Demand Confound (All 3 Reviewers)

**Problem:** Total employment responds positively in high-exposure sectors, suggesting correlated demand shocks rather than causal effect of subsidy change.

**Fix:** Add sector-specific linear time trends to baseline specification (Table 7). This absorbs differential growth trajectories. Result: youth share coefficient remains significant (0.061, p=0.045), total employment collapses to insignificance (1.05, p=0.78). The red flag was driven by sector trends, not the subsidy.

## Fix 2: Missing adjustbox Package (Gemini Exhibit Review)

Tables 3 and 4 were truncated because `\usepackage{adjustbox}` was missing from preamble. Added.

## Fix 3: Strengthen Shift-Share Literature (GPT)

Added citation of Adao, Kolesár, and Morales (2019) on shift-share inference. Added Rambachan & Roth discussion for pre-trend sensitivity.

## Fix 4: Improve Conclusion Prose (Prose Review)

Stronger ending: "France bought a label, not an opportunity." Added per-job cost framing (€176,000).

## Fix 5: Exposure SD Inconsistency (GPT Advisor)

Table 1 shows SD=4.6, text said 4.1. Fixed text to match table (4.6).

## Fix 6: Table 1 Notes

Changed "Bartik DiD" to "exposure DiD" for consistency.

---

## Changes Made

1. Added `\usepackage{adjustbox}` to preamble
2. Added `adjustbox=TRUE` to Tables 3, 4, 6, 7
3. Added sector-specific linear trends robustness (Section 7, Table 7)
4. Updated exposure SD in text from 4.1 to 4.6
5. Added Adao et al. (2019) citation in identification section
6. Added Rambachan & Roth discussion in pre-trend analysis
7. Improved conclusion prose
8. Fixed Table 1 notes ("exposure DiD")
9. Updated Table 5 coefficient precision for consistency
