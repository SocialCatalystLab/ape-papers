# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-11T18:53:09.422658
**Route:** Direct Google API + PDF
**Tokens:** 24117 in / 2355 out
**Response SHA256:** 0364c5d1e8cc5a8b

---

This review evaluates the visual exhibits of the paper "The Dog That Didn’t Bark: Educational Content Restriction Laws and Teacher Labor Markets" against the standards of top-tier economics journals (AER, QJE, JPE).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: K–12 Schools (NAICS 6111) by Treatment Status"
**Page:** 9
- **Formatting:** High quality. Clean "booktabs" style with no vertical lines. Numbers are logically grouped. 
- **Clarity:** Excellent. Stratification by Pre/Post and Treated/Control allows for quick mental DiD comparison.
- **Storytelling:** Essential. It immediately addresses the "Southern/Low-cost" geographic bias in treatment assignment via the earnings row.
- **Labeling:** Clear. Table notes define the sample period, data source, and suppression issues.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Treatment Rollout: Adoption of Educational Content Restriction Laws, 2021–2023"
**Page:** 14
- **Formatting:** Professional. The use of a "lollipop" or timeline chart is superior to a standard map for showing staggered timing.
- **Clarity:** Good. Color coding by stringency is intuitive.
- **Storytelling:** Strong. It visualizes the "waves" of adoption mentioned in the text (mid-2021 vs. mid-2022).
- **Labeling:** Axis labels are clear. Source notes are present.
- **Recommendation:** **REVISE**
  - Change the legend title from "Law Stringency" to "Enforcement Stringency" to match the text.
  - The "Dark shading indicates earlier adoption" note in the caption seems to refer to a different version of the figure (perhaps a map); in this version, time is on the X-axis. Remove or update this note.

### Figure 2: "Raw Trends in Log K–12 School Employment: Treated vs. Never-Treated States"
**Page:** 16
- **Formatting:** Clean. Standard GGPlot2 aesthetics but refined for publication.
- **Clarity:** High. Panel A (Levels) and Panel B (Rates) are clearly separated.
- **Storytelling:** Critical. This is the "parallel trends" visual proof. It clearly shows the shared COVID shock, which justifies the DiD approach.
- **Labeling:** The vertical dashed line for 2021Q3 is helpful. 
- **Recommendation:** **REVISE**
  - **Decimal Alignment:** In Panel B, ensure the Y-axis labels have consistent decimal places (e.g., 0.10, 0.14, 0.18, 0.22).
  - **Legend:** Move the legend inside the plot area (e.g., top right of Panel B) to save vertical whitespace.

### Table 2: "Effect of Educational Content Restriction Laws on K–12 School Labor Markets"
**Page:** 18
- **Formatting:** Journal-ready. Proper use of panels (A through D) to organize different estimators and outcomes.
- **Clarity:** Good, but dense. 
- **Storytelling:** This is the "money table." It puts the null result (CS) right next to the spurious result (TWFE), which is the paper's core methodological contribution.
- **Labeling:** Significance stars are defined. Standard errors are in parentheses. 
- **Recommendation:** **REVISE**
  - **Units:** Add a row or a note specifying the units for each column (e.g., "Log points" for Col 1 and 3, "Rate" or "Percentage points" for Col 2 and 4).
  - **Panel D:** Panel D only has one value. For symmetry, consider adding the TWFE/CS estimates for the other columns in Panel D if available, or move "Female Share" to its own smaller table if it's considered a secondary outcome.

### Figure 3: "Event Study: Callaway-Sant’Anna Dynamic ATT Estimates"
**Page:** 20
- **Formatting:** High quality. Consistent color palette (blues/pinks/greens).
- **Clarity:** Four panels are a bit small.
- **Storytelling:** Essential. Confirms no pre-trends and no delayed effects.
- **Labeling:** Y-axis "ATT" is a bit generic; better to use "ATT (Log Employment)" etc.
- **Recommendation:** **REVISE**
  - **Y-Axis Consistency:** In Panel B and D, the 0.00 line is dashed; ensure this is consistent across all four panels to help the reader's eye find the null.
  - **Confidence Intervals:** Explicitly state in the notes that these are 95% CIs.

### Figure 4: "Event Study: Female Share of K–12 School Employment"
**Page:** 22
- **Formatting:** Professional.
- **Clarity:** Clean.
- **Storytelling:** Supports the argument that sectoral precision (NAICS 6111) removes previous spurious findings.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (or consolidate—see Overall Assessment).

### Table 3: "Robustness: Alternative Specifications for Log Employment"
**Page:** 23
- **Formatting:** Standard.
- **Clarity:** Excellent. This is a very "honest" table by showing TWFE and Triple-Diff next to the preferred estimates.
- **Storytelling:** Strong. Shows the "concordance" of modern estimators.
- **Labeling:** Clear definition of MDE and Fisher p-value.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Heterogeneity by Law Stringency: Event Study Estimates for Log Employment"
**Page:** 24
- **Formatting:** Good use of overlapping CIs.
- **Clarity:** A bit cluttered due to the wide CIs for "Strong Laws."
- **Storytelling:** Important for the "Dose-Response" argument.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Placebo Tests: Effect of Education Content Laws on Non-Education Sectors"
**Page:** 25
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Standard robustness check for DiD.
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **MOVE TO APPENDIX**
  - The results are almost entirely null and are summarized effectively in the text. This would free up space in the main body.

### Figure 6: "Placebo Event Study: K–12 Schools vs. Non-Education Sectors"
**Page:** 26
- **Formatting:** Visually busy.
- **Clarity:** Low. Too many overlapping lines and CIs make it hard to distinguish the placebo sectors.
- **Storytelling:** Reaffirms Table 4.
- **Labeling:** Legend is clear but the plot is "spaghetti-like."
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 7: "Randomization Inference: Permutation Distribution of TWFE Coefficient"
**Page:** 27
- **Formatting:** Standard.
- **Clarity:** High.
- **Storytelling:** Very effective. It visually explains why the TWFE result in Table 2 is "statistically significant" but "causally biased."
- **Labeling:** "Observed = 0.1089" annotation is helpful.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Minimum Detectable Effects at 80% Power"
**Page:** 28
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Crucial for a "null result" paper to prove it isn't just "underpowered."
- **Labeling:** The |ATT|/MDE ratio column is an excellent addition for clarity.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Comparison of Event-Study Estimates: NAICS 6111 (K–12 Schools) vs. NAICS 61 (All Education)"
**Page:** 29
- **Formatting:** Professional.
- **Clarity:** High. The contrast in CI widths and point estimates is clear.
- **Storytelling:** This illustrates the "Sectoral Precision" argument perfectly.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

## Appendix Exhibits

### Table 6: "Educational Content Restriction Laws: Treatment Coding"
**Page:** 40
- **Formatting:** Excellent.
- **Clarity:** High.
- **Storytelling:** Critical for transparency and replicability.
- **Labeling:** Clear column headers.
- **Recommendation:** **KEEP AS-IS**

---

# Overall Assessment

- **Exhibit count:** 5 main tables, 8 main figures, 1 appendix table, 0 appendix figures.
- **General quality:** Extremely high. The paper follows modern "Best Practices" for DiD papers (Callaway-Sant’Anna, event studies, MDE analysis, and permutation tests).
- **Strongest exhibits:** Table 2 (the main results) and Figure 7 (the randomization inference).
- **Weakest exhibits:** Figure 6 (spaghetti plot) and Figure 2 (could be more compact).
- **Missing exhibits:** 
  1. **A Coefficient Plot for Robustness:** While Table 3 is good, a "Coefficient Plot" (Forest Plot) visualizing the estimates in Table 3 would be more impactful for a quick read.
  2. **Turnover Event Study:** Turnover is the only significant finding (0.48pp). While mentioned in Table 5, it deserves its own event-study figure in the main text to show when the "churn" began.

### Top 3 Improvements:
1.  **Consolidate Main Text Figures:** The paper has 8 figures in the main text, which is high for the AER/QJE. I recommend moving Figure 6 (Placebos) to the appendix and consolidating Figure 3 and Figure 4 into a single multi-panel "Main Outcomes" figure.
2.  **Add Turnover Event Study:** Since turnover is the paper's only "positive" finding, a figure showing its dynamic response is essential to rule out pre-trends for this specific margin.
3.  **Refine Table 2 Units:** Ensure every column in the main results table has explicit units in the header (e.g., "$\Delta$ Log Points" or "Percent"). This prevents "coefficient confusion" for readers.