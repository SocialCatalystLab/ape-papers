# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T12:47:47.439576
**Route:** Direct Google API + PDF
**Tokens:** 19437 in / 2056 out
**Response SHA256:** 95eb05a09a1dfd61

---

This review evaluates the visual exhibits of "Licensing to Log In: The Interstate Medical Licensure Compact and Healthcare Employment" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "IMLC Adoption Timeline by State"
**Page:** 6
- **Formatting:** Professional. The bar chart is clean, and the grouping of "2022+" and "Never Adopted" is logical.
- **Clarity:** High. It immediately shows the "staggered" nature of the design and the large 2017 cohort.
- **Storytelling:** Strong. It justifies the use of a staggered DiD design.
- **Labeling:** Clear axis labels and n-values above bars.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Clean. Use of horizontal rules follows standard journal style (Booktabs). Numbers are easy to read.
- **Clarity:** High. Separating "Eventually Treated" from "Never Treated" pre-2017 is essential for assessing the "comparability" of the groups.
- **Storytelling:** Essential. It highlights the size difference between treated and never-treated states, which the author addresses in the text.
- **Labeling:** Units (000s, $) are clearly marked in the stub. 
- **Recommendation:** **REVISE**
  - Add a "Difference" column (Treated minus Never Treated) with p-values from a t-test of means. This is standard in top journals to formally show balance/imbalance in levels.

### Table 2: "Effect of IMLC Adoption on Healthcare Sector Outcomes"
**Page:** 13
- **Formatting:** Excellent. Panel A vs Panel B structure is clear. Numbers are decimal-aligned.
- **Clarity:** High. The 5-column layout covers the primary outcomes efficiently.
- **Storytelling:** The core of the paper. Comparing Callaway-Sant’Anna (CS) to TWFE is a modern requirement.
- **Labeling:** Proper significance stars and standard error notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Event Study: IMLC and Log Healthcare Employment"
**Page:** 14
- **Formatting:** Standard "ggplot" style. The shaded 95% CI is clean.
- **Clarity:** The message of a "precise null" is clear in the post-treatment period, though the pre-trend is visually obvious.
- **Storytelling:** Central. It honestly shows the pre-trend issue discussed in Section 5.2.
- **Labeling:** Good. "Years Since IMLC Adoption" is the correct x-axis.
- **Recommendation:** **REVISE**
  - The y-axis scale is slightly wider than necessary. Tightening it might make the post-treatment "zero" even more striking.
  - Consider adding a vertical line at $k=-1$ (the reference period) to clearly delineate the start of the treatment.

### Table 3: "Event Study Coefficients: IMLC and Healthcare Employment"
**Page:** 15
- **Formatting:** Vertical table of coefficients.
- **Clarity:** Redundant with Figure 2.
- **Storytelling:** While it provides exact p-values for the pre-trends, it takes up a lot of space for information already visualized.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - In top journals, if the figure is clear, the underlying coefficient table usually lives in the appendix unless the specific point estimates are crucial for a secondary calculation.

### Figure 3: "Event Study: IMLC and Log Ambulatory Care Employment"
**Page:** 16
- **Formatting:** Consistent with Figure 2.
- **Clarity:** High.
- **Storytelling:** Important sub-sector analysis.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (or consider consolidating into a 2x2 panel figure with Figures 2, 4, and 6).

### Figure 4: "Event Study: IMLC and Log Healthcare Establishments"
**Page:** 17
- **Formatting:** Consistent.
- **Clarity:** High.
- **Storytelling:** Supports the "no new supply" argument.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Cohort-Specific ATTs: Healthcare Employment"
**Page:** 18
- **Formatting:** Clean "dot-and-whisker" plot.
- **Clarity:** Effectively shows the 2018 outlier and the general null across other cohorts.
- **Storytelling:** Crucial for defending against the idea that the effect is "just hidden" by averaging.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Placebo Test: IMLC and Log Accommodation Employment"
**Page:** 19
- **Formatting:** Consistent.
- **Clarity:** High.
- **Storytelling:** Vital "sanity check" for the DiD estimator.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Sub-Industry Comparison: ATT Estimates Across Healthcare Sectors"
**Page:** 20
- **Formatting:** Multi-line plot with shaded regions.
- **Clarity:** **Low.** Overlapping shaded regions for two different sub-industries (Ambulatory vs. Hospitals) make it difficult to distinguish the CIs for each.
- **Storytelling:** Useful to see them side-by-side, but the visual execution is "muddy."
- **Recommendation:** **REVISE**
  - Instead of overlapping lines, use a "Coefficient Plot" (like Figure 5) that shows the *overall ATT* for each sector side-by-side. If the goal is to show the *path* of the event study, use two separate panels (Panel A: Ambulatory, Panel B: Hospitals) in the same figure.

### Table 4: "Robustness Checks"
**Page:** 21
- **Formatting:** One-row-per-specification.
- **Clarity:** High.
- **Storytelling:** Efficient summary of many regressions.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 5: "Variable Definitions"
**Page:** 30
- **Recommendation:** **KEEP AS-IS** — Highly helpful for transparency.

### Figure 8: "Pre-Treatment Trends in Healthcare Employment"
**Page:** 31
- **Formatting:** Raw data trends.
- **Clarity:** High.
- **Storytelling:** This is actually a very strong figure. It shows that treated and never-treated states were on different *levels* but roughly similar *slopes* (until the 2017 cohort began to diverge slightly).
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Place this in the Data section. It is the most intuitive way to show the reader the raw data before the DiD transformation.

### Table 6: "IMLC Adoption by State"
**Page:** 32
- **Recommendation:** **KEEP AS-IS**

### Figure 9 & Figure 10: "Placebo..." and "ATT Comparison..."
**Page:** 34-35
- **Observation:** These are identical duplicates of Figure 6 and Figure 7.
- **Recommendation:** **REMOVE** — Do not duplicate main text figures in the appendix. If the reader is in the appendix, they can refer back to the main text, or the appendix should contain *different* versions (e.g., different estimators).

---

# Overall Assessment

- **Exhibit count:** 3 main tables, 7 main figures, 2 appendix tables, 1 appendix figure (after removing duplicates).
- **General quality:** High. The paper uses modern "best practices" for DiD papers (CS estimator, event studies, placebo tests).
- **Strongest exhibits:** Table 2 (Main Results) and Figure 5 (Cohort Heterogeneity).
- **Weakest exhibits:** Figure 7 (Overlapping shaded regions) and Table 3 (Redundant with Figure 2).
- **Missing exhibits:** 
  1. **Map of Adoption:** A US map shaded by adoption year is standard and more intuitive than the Figure 1 bar chart for visualizing geographic clusters (e.g., rural vs. coastal states).
  2. **Sun-Abraham Figure:** The text mentions Sun-Abraham results; a figure showing these side-by-side with Callaway-Sant'Anna in the appendix would be a strong robustness addition.

### Top 3 Improvements:
1. **Consolidate Event Studies:** Merge Figures 2, 3, 4, and 6 into a single 2x2 "Grid" figure. This saves 3 pages of space and allows the reader to compare the primary outcome, the sub-sector, the establishment count, and the placebo simultaneously.
2. **Fix Figure 7:** Stop using overlapping shaded CIs. Use two panels (A/B) or a simplified coefficient plot of the aggregate ATTs.
3. **Promote Figure 8:** Move the raw trend lines to the main text. It builds trust in the data before the "black box" of the CS estimator is introduced.