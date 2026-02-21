# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T19:51:02.303095
**Route:** Direct Google API + PDF
**Tokens:** 18917 in / 1768 out
**Response SHA256:** 4a4037311b8e56cd

---

# Exhibit-by-Exhibit Review

This review evaluates the exhibits for "Secret Ballots and Women’s Political Voice" according to the standards of top-tier economics journals (AER, QJE, etc.).

---

## Main Text Exhibits

### Figure 1: "Landsgemeinde Cantons in Switzerland"
**Page:** 6
- **Formatting:** Clean map. However, the use of two distinct shades of blue/orange for status and then "Other cantons" in light gray is standard.
- **Clarity:** Good. It quickly identifies the "treated" vs "control" regions.
- **Storytelling:** Essential. It establishes the geography of the spatial design.
- **Labeling:** Legend is clear. 
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics: AR–AI Border Sample"
**Page:** 11
- **Formatting:** Generally professional. No vertical lines (good). 
- **Clarity:** The split between Panel A (Full) and Panel B (Pre/Post) is logical. However, the number of "Gemeinden" (20 vs 4) highlights a significant power issue that should be addressed in the text.
- **Storytelling:** Crucial for showing the "raw" version of the null result before moving to regressions.
- **Labeling:** Well-labeled. Significance stars are not needed here as it is descriptive.
- **Recommendation:** **REVISE**
  - Change "Gemeinden" to "Municipalities" to match the English text.
  - Decimal-align the numbers in the "Mean" and "SD" rows.

### Figure 2: "Spatial RDD: Yes-Share vs. Distance to AR–AI Border"
**Page:** 14
- **Formatting:** Modern ggplot style. The confidence intervals are visible.
- **Clarity:** High. The 10-second takeaway (a visible level shift but no sharp jump at 0) is clear.
- **Storytelling:** Directly supports the cross-sectional finding.
- **Labeling:** Axis labels are clear. The "Post-1997" subtitle is important.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Difference-in-Discontinuities: Landsgemeinde Abolition and Referendum Voting"
**Page:** 15
- **Formatting:** Top-journal standard. Clear grouping of DiDisc vs Level effects.
- **Clarity:** Excellent. It presents the "well-identified null" (Columns 1-2) alongside the "cultural gap" (Columns 3-4).
- **Storytelling:** This is the "money table" of the paper.
- **Labeling:** $p$-values in brackets are a bit unconventional for AER (which usually prefers SEs in parentheses and stars), but they are clearly defined.
- **Recommendation:** **REVISE**
  - Most top journals prefer standard errors in parentheses and stars only. Including $p$-values in brackets makes the table cluttered. Move $p$-values to the text or leave them out if stars are used.
  - Add a row for "Outcome Mean" to provide context for the coefficient magnitudes.

### Figure 3: "Event Study: AR–AI Border Continuity by Year"
**Page:** 16
- **Formatting:** Professional. The dashed vertical line for treatment is standard.
- **Clarity:** Very high. The "flatness" of the result is immediately apparent.
- **Storytelling:** This is the strongest visual evidence for the null hypothesis.
- **Labeling:** The y-axis "pp" (percentage points) is a good detail. 
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Gender vs. Non-Gender Referendums: AR–AI Border Gap"
**Page:** 17
- **Formatting:** Two-panel structure is good for comparison.
- **Clarity:** The message—that the gap is larger for gender—is clear.
- **Storytelling:** Important for the mechanism discussion (cultural conservatism regarding gender).
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Gender Referendum Yes-Share: AR vs. AI Municipalities"
**Page:** 18
- **Formatting:** Clean line plot.
- **Clarity:** Shows the parallel trends visually.
- **Storytelling:** Supports the DiDisc assumption.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is essentially a raw-data version of the event study (Figure 3). While helpful, Figure 3 is the more rigorous version. This could be moved to the appendix to save main-text space.

### Figure 6: "Permutation Distribution: AR–AI Cross-Sectional Border Gap"
**Page:** 19
- **Formatting:** Standard histogram for permutation tests.
- **Clarity:** Clear "Actual" line.
- **Storytelling:** Necessary given the small number of clusters (24 municipalities).
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Cross-Sectional Border Gap by Border Pair (Post-1997)"
**Page:** 20
- **Formatting:** Minimalist.
- **Clarity:** Good comparison across different borders.
- **Storytelling:** Shows the "Landsgemeinde effect" (or cultural correlate) isn't unique to just one border.
- **Recommendation:** **REVISE**
  - Order the rows by the "Estimate" magnitude or by "Abolished" vs "Active" status rather than what appears to be a random order. This helps the reader see the pattern (Active > Abolished) faster.

---

## Appendix Exhibits

### Table 4: "Variable Definitions"
**Page:** 30
- **Formatting:** Simple list.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "AR-Side Level Effect by Referendum Topic"
**Page:** 33
- **Formatting:** Clean. 
- **Storytelling:** This is interesting enough that it could actually be **PROMOTED TO MAIN TEXT** or merged into Table 2 as a new panel/sub-section. It explains *where* the cultural gap is coming from.
- **Recommendation:** **KEEP AS-IS** (or promote).

### Table 6: "Gender-Related Federal Referendums, 1981–2024"
**Page:** 34
- **Formatting:** Long list.
- **Clarity:** Essential for transparency on how "Gender Votes" were classified.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 3 main tables, 6 main figures, 3 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The paper follows modern "clean" aesthetic standards (no gridlines, serif fonts, clear legends).
- **Strongest exhibits:** Figure 3 (Event Study) and Table 2 (DiDisc). They tell the entire story of the paper on their own.
- **Weakest exhibits:** Figure 5 (Redundant with Fig 3) and Table 1 (Minor formatting/translation issues).
- **Missing exhibits:** 
    - **A Balance Table on Covariates:** Even if the author notes that `rdrobust` fails to converge, a simple comparison of means for 1990 census variables (religion, language, age, sector) for these 24 municipalities would be standard for a spatial RDD.
    - **A Placebo Map:** A map showing the "permuted" borders could visually explain the permutation test.

**Top 3 Improvements:**
1. **Clean up Table 2:** Remove $p$-values from the cells. Use standard parentheses for SEs and stars for significance. Add a "Mean of Dependent Variable" row.
2. **Improve Table 1:** Translate "Gemeinden" to "Municipalities" and decimal-align the columns.
3. **Consolidate/Move:** Move Figure 5 to the Appendix to reduce the total figure count in the main text, making the remaining 5 figures more impactful.