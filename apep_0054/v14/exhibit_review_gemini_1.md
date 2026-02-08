# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (vertex)
**Paper:** paper.pdf
**Timestamp:** 2026-02-08T18:29:10.687219
**Route:** Direct Google API + PDF
**Tokens:** 22925 in / 2069 out
**Response SHA256:** 2615947cd6beb612

---

This review evaluates the exhibits of the paper "Shining Light on Nothing? Null Effects of Salary Transparency Laws on New Hire Wages" against the standards of top-tier economics journals (AER, QJE, PME).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Geographic Distribution of Salary Transparency Law Adoption"
**Page:** 6
- **Formatting:** Professional. Uses a standard projected US map. Legend is clear.
- **Clarity:** Excellent. Distinguishes between cohorts and explains exclusions.
- **Storytelling:** Vital for a DiD paper. It visually establishes the treatment variation and identifies the "border control" strategy mentioned later.
- **Labeling:** Clear. Note includes specific exclusion criteria (NY/HI).
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Testable Predictions from the Model"
**Page:** 10
- **Formatting:** Clean, uses horizontal booktabs-style lines.
- **Clarity:** High. Connects theoretical parameters to empirical tests.
- **Storytelling:** Good "roadmap" exhibit. It sets the stakes for the null results.
- **Labeling:** Clear headers.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "New Hire Earnings Trends: Treated vs. Control Counties"
**Page:** 18
- **Formatting:** Needs improvement. The gridlines are a bit heavy. The color palette (blues and reds) is standard, but the "Control Female" and "Treated Female" lines are very close in space, creating clutter.
- **Clarity:** Harder to parse in 10 seconds due to 4 overlapping series. 
- **Storytelling:** Crucial for showing raw parallel trends. 
- **Labeling:** Axis labels are clear. Legend is at the bottom.
- **Recommendation:** **REVISE**
  - Use a "Panel" approach. **Panel A: Male Earnings, Panel B: Female Earnings**. This would separate the red/blue series and make the parallel trends between treated/control within-sex much more obvious.

### Figure 3: "Event Study: Effect on Log New Hire Earnings"
**Page:** 19
- **Formatting:** Professional "fan chart" style.
- **Clarity:** Good. The null effect is immediately visible.
- **Storytelling:** This is the "Money Plot" of the paper.
- **Labeling:** X-axis (Quarters Relative to Treatment) is standard.
- **Recommendation:** **KEEP AS-IS** (Though consider adding a horizontal 0-line that is thicker/darker).

### Table 2: "Effect of Salary Transparency Laws on Log New Hire Earnings"
**Page:** 20
- **Formatting:** Excellent. Decimal-aligned, significance stars, and standard errors in parentheses.
- **Clarity:** Logical progression from main estimator (C-S) to TWFE and then Border designs.
- **Storytelling:** Consolidates the "No Effect" message across multiple identification strategies.
- **Labeling:** Comprehensive notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Treatment Effect by Sex: Both Estimates Are Null"
**Page:** 21
- **Formatting:** Bar chart with error bars. 
- **Clarity:** High, but somewhat redundant with Table 3.
- **Storytelling:** Visualizes the gender differential.
- **Labeling:** Units on Y-axis (Percentage points) are clear.
- **Recommendation:** **MOVE TO APPENDIX** 
  - For top journals, a simple bar chart of two coefficients is "low-density" information. Table 3 handles this more precisely.

### Table 3: "Treatment Effect by Sex: No Significant Effects"
**Page:** 22
- **Formatting:** Standard.
- **Clarity:** Very clean.
- **Storytelling:** Directly tests the "Information Equalization" hypothesis.
- **Labeling:** Includes the "Difference (F-M)" column which is essential.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Border County-Pair Design"
**Page:** 23
- **Formatting:** Professional GIS mapping.
- **Clarity:** Clearly shows the "Treated Border" vs "Control Border" distinction.
- **Storytelling:** Explains why the naïve border estimate in Table 2 Col 3 is so high (geographic clustering).
- **Labeling:** Good legend.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Border Event Study: Pre-Existing Gap vs. Treatment Effect"
**Page:** 24
- **Formatting:** Professional.
- **Clarity:** The Y-axis starts at 0, showing the level shift of ~10% clearly.
- **Storytelling:** Essential "de-biasing" figure. It shows the level difference is static and does not change at $t=0$.
- **Labeling:** Notes are helpful.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Border Design Decomposition"
**Page:** 24
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** This is the numerical companion to Figure 6. It could be merged into Table 2 as a footnote or additional row, but stands well here.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Robustness of Main Results"
**Page:** 25
- **Formatting:** Coefficient plot (forest plot).
- **Clarity:** Very high.
- **Storytelling:** Shows the "Stability" of the null.
- **Labeling:** The Y-axis labels (Specification names) are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness: The Null Is Robust"
**Page:** 26
- **Formatting:** Good use of an "Interpretation" column.
- **Clarity:** High.
- **Storytelling:** Summarizes several different checks (Placebo, Exclusions).
- **Labeling:** Notes are exhaustive.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Summary of All Specifications: No Detectable Effects"
**Page:** 27
- **Formatting:** High information density.
- **Clarity:** Logical grouping.
- **Storytelling:** Redundant. This is essentially Table 5 and Table 2 combined.
- **Recommendation:** **REMOVE** 
  - The paper already has enough "Summary" exhibits. By page 27, the reader is convinced of the null. Use the space for more discussion.

---

## Appendix Exhibits

### Table 7: "Variable Definitions"
**Page:** 35
- **Recommendation:** **KEEP AS-IS** (Standard for AEJ/AER).

### Table 8: "Salary Transparency Law Adoption"
**Page:** 36
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This is a high-value reference table for the institutional background section. Readers often want to see the "Size Thresholds" without flipping to the appendix.

### Table 9: "Summary Statistics: QWI County-Quarter-Sex Data"
**Page:** 37
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - A summary statistics table is mandatory in the main text of any top-5 journal paper. It establishes the scale of the data.

### Table 10: "Event Study Coefficients (Selected Quarters)"
**Page:** 38
- **Recommendation:** **KEEP AS-IS** (Good for the appendix).

### Table 11: "Border County-Pair Sample"
**Page:** 39
- **Recommendation:** **KEEP AS-IS**.

### Table 12: "Cohort-Specific ATTs (Callaway-Sant'Anna)"
**Page:** 40
- **Recommendation:** **KEEP AS-IS**.

### Table 13: "Industry Heterogeneity: High vs. Low Bargaining Sectors"
**Page:** 41
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This addresses one of the primary theoretical "Mechanisms" (Bargaining power). Moving this to the main text strengthens the "Why Theory Failed" section.

---

## Overall Assessment

- **Exhibit count:** 4 Main Tables, 7 Main Figures, 7 Appendix Tables, 0 Appendix Figures.
- **General quality:** Extremely high. The paper follows the "Modern DiD" template (C-S estimates, event studies, robustness plots) perfectly. 
- **Strongest exhibits:** Figure 1 (Map) and Figure 6 (Border Decomposition).
- **Weakest exhibits:** Figure 2 (cluttered line chart) and Table 6 (redundant).
- **Missing exhibits:** A **"Minimum Detectable Effect" (MDE) Power Plot** or a distribution plot of wage changes would be a strong addition to bolster the "Informative Null" argument.

**Top 3 Improvements:**
1.  **Promote Summary Statistics (Table 9) and Adoption Timeline (Table 8) to the main text.** Top journals expect these in Section 2/5.
2.  **Split Figure 2 into Panel A (Male) and Panel B (Female).** This makes the pre-trend visual inspection much more "honest" and less cluttered.
3.  **Delete Table 6.** It repeats results from Tables 2, 3, and 5. Use the saved page count to move the Industry Heterogeneity (Table 13) into the main results.