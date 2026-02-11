# Revision Plan: apep_0219 v4

## Parent Paper
- **Paper ID:** apep_0219 (v3)
- **Title:** The Limits of Marginal Aid: A Regression Discontinuity Estimate of Place-Based Policy in Appalachia

## Changes Made

### 1. Table 3 Overflow Fix (CRITICAL)
- Added `\small` font and `@{}` column padding to Table 3 (Main RDD Results)
- Reformatted column headers (split "Log PCMI" across two rows)
- Abbreviated "Total observations" → "Total obs." and "Eff. observations" → "Eff. obs."
- Full 95% CI `[-0.73, 0.93]` now visible without truncation
- Applied same fix to Table 6 (Year-by-Year, appendix)

### 2. Introduction Subsection Removal (AER Style)
- Removed `\subsection*{Contribution and Related Literature}` header
- Introduction now flows as continuous prose without internal subsections
- Added natural transition: "These findings contribute to..."

### 3. Contribution List Woven into Prose
- Replaced mechanical "This paper makes four contributions. First, ... Second, ... Third, ... Fourth, ..." with flowing narrative
- Contributions now integrated naturally: "Despite a substantial literature...", "This paper fills that sixty-year gap...", "The precisely estimated null resolves...", "The results carry direct implications...", "Finally, the paper speaks to..."

### 4. Map Promoted to Main Text
- Moved Appalachian counties map from Appendix D to Section 2 (Institutional Background)
- Now appears as Figure 1 (first figure in paper)
- Updated intro reference from "see Appendix Figure" to inline "(Figure 1)"
- Removed duplicate from appendix

### 5. Year-by-Year Figure Moved to Appendix
- Removed Figure 5 (Year-by-Year RDD Estimates) from main text Section 5.3
- Kept appendix version only (now Appendix Figure 6)
- Updated text reference: "Appendix Figure 6 plots the year-by-year RDD estimates"
- Tightened main text flow: Figure 5 (Main RD plots) → Table 3 → Table 4 → Table 5

### 6. Prose Polish
- Deleted roadmap filler: "Before presenting the main results, I verify the design's validity."
- Tightened data section opening: "To build the analysis sample, I start with..."
- Simplified "mitigate" → "address" (two instances in Threats to Validity)

### 7. Spatial Spillover Discussion Added
- Added new threat to validity (third concern): spatial spillovers
- Acknowledges SUTVA violation if ARC-funded infrastructure serves neighboring counties
- Notes geographic clustering of Distressed counties makes spillovers plausible
- Renumbered subsequent threats (anticipatory effects → fourth, outcome-assignment → fifth)

### 8. Figure 3 Panel Titles Updated
- Changed from generic labels to descriptive: "Balance: Lagged Unemployment Rate (%)", "Balance: Lagged Per Capita Market Income ($)", "Balance: Lagged Poverty Rate (%)"
- Re-ran 05_figures.R to regenerate

## Files Modified
- `paper.tex` — All LaTeX changes
- `code/05_figures.R` — Covariate balance panel titles

## Verification
- Table 3: Full 95% CI visible in rightmost column ✓
- Introduction: No subsection headers within Section 1 ✓
- Map appears as Figure 1 in Section 2 ✓
- Figure numbering sequential (1-5 main, 6-9 appendix) ✓
- 40 pages total, main text ≥ 25 pages ✓
- Zero undefined references ✓
