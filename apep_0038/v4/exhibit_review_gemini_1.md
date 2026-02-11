# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-11T19:39:10.028047
**Route:** Direct Google API + PDF
**Tokens:** 17357 in / 2307 out
**Response SHA256:** 830b2e92af5068c2

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Sports Betting Legalization Timeline"
**Page:** 6
- **Formatting:** Clean, logical color ramp. The use of a map is standard for state-level policy papers.
- **Clarity:** High. The legend clearly distinguishes between years of adoption. The "Gray" note in the caption helps avoid confusion regarding non-legalized states.
- **Storytelling:** Essential. It establishes the staggered treatment timing necessary for the DiD identification strategy.
- **Labeling:** Clear. Axis labels are not needed for a map, but the legend is well-placed.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics: Gambling Industry Employment (NAICS 7132)"
**Page:** 8
- **Formatting:** Good use of panels (A, B, C). However, numbers are not decimal-aligned (e.g., mean employment vs. SD).
- **Clarity:** The comparison between Treated and Control states is clear. The inclusion of p-values for balance is helpful.
- **Storytelling:** Establishes that treated and control states are comparable in size and wage levels before the policy change.
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **REVISE**
  - Decimal-align all numerical values in the columns to improve readability.
  - Ensure the standard deviation parentheses are aligned directly under the means.

### Table 2: "Effect of Sports Betting Legalization on Gambling Industry Employment"
**Page:** 12
- **Formatting:** Professional "Booktabs" style. Standard errors in parentheses and CIs in brackets is excellent.
- **Clarity:** High. Comparing CS to TWFE is a standard "top-journal" requirement to show robustness to heterogeneous timing.
- **Storytelling:** This is the "money" table. It shows the precisely estimated null.
- **Labeling:** Significance stars defined. Notes explain the estimator clearly.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Event Study: Employment Effects of Sports Betting Legalization"
**Page:** 13
- **Formatting:** Modern ggplot2 style. The shaded confidence bands are clean.
- **Clarity:** High. The dashed vertical line at $t=-1$ (omitted period) is correctly placed.
- **Storytelling:** Critical. It proves the parallel trends assumption (flat pre-period) and the null result (flat post-period).
- **Labeling:** Y-axis label "Effect on Gambling Industry Employment" is clear. 
- **Recommendation:** **REVISE**
  - The x-axis "Years Since Sports Betting Legalization" is good, but the tick labels (-8, -6, etc.) are a bit sparse. Consider labeling every year or every two years more clearly.
  - Increase the font size of the axis titles for better legibility in print.

### Table 3: "Event Study Estimates: Dynamic Treatment Effects"
**Page:** 14
- **Formatting:** Standard coefficient table.
- **Clarity:** Good, though it replicates Figure 2.
- **Storytelling:** Usually, the figure is enough for the main text. Journals like AER often prefer this in the appendix unless the specific coefficients are discussed individually at length.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - The figure (Figure 2) tells the story more effectively. Having the raw coefficients in the main text is slightly redundant.

### Table 4: "Heterogeneity in Treatment Effects"
**Page:** 15
- **Formatting:** Simple and clean.
- **Clarity:** High.
- **Storytelling:** Important for the "technology" channel argument (mobile vs. retail).
- **Labeling:** Notes are sufficient.
- **Recommendation:** **REVISE**
  - Group these results as Panel A/B/C within a larger robustness table, or keep as is but add the "Mean of Dependent Variable" for each subgroup to the bottom of the table to allow for elasticity interpretations.

### Table 5: "Robustness Checks"
**Page:** 16
- **Formatting:** Logical grouping of "Sensitivity," "Restrictions," and "Specifications."
- **Clarity:** Very high. A reader can see the null is invariant to model choice in seconds.
- **Storytelling:** Essential for a null result paper to prove the result isn't a fluke of the sample.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Robustness of Main Result"
**Page:** 17
- **Formatting:** Excellent "whisker plot" summary of Table 5.
- **Clarity:** Outstanding.
- **Storytelling:** This is a "QJE-style" figure that summarizes a lot of regression work into one visual proof.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "HonestDiD Sensitivity Analysis (Rambachan-Roth)"
**Page:** 17
- **Formatting:** Standard.
- **Clarity:** Requires technical knowledge, but that is expected for the target journals.
- **Storytelling:** Modern requirement for DiD papers.
- **Labeling:** $M$ is defined in the notes.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Placebo Tests: Unrelated Industries"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Critical "sanity check."
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - This table is very small. Consider merging it as a panel into the main Results table (Table 2) or the Robustness table (Table 5) to save space.

### Figure 4: "Leave-One-Out Sensitivity"
**Page:** 19
- **Formatting:** High quality. Sorting by effect size is helpful.
- **Clarity:** Clear.
- **Storytelling:** Shows no single state (like NJ) is driving the result.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - While good, Figure 3 already establishes robustness. This is a secondary check more suited for an online supplement.

### Table 8: "Effect of Sports Betting Legalization on Gambling Industry Wages"
**Page:** 20
- **Formatting:** Same as Table 2.
- **Clarity:** High.
- **Storytelling:** Adds to the "substitution" argument.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Combine this with Table 2. Use "Panel A: Employment" and "Panel B: Wages." This would create a more powerful "Main Results" exhibit.

### Figure 5: "Wage Event Study"
**Page:** 21
- **Formatting:** Consistent with Figure 2.
- **Clarity:** High.
- **Storytelling:** Visual proof of the null on wages.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - The paper is getting "figure-heavy." Since the wage result is also a null and secondary to employment, the figure belongs in the appendix while the coefficient can stay in the (merged) Table 2.

### Table 9: "Spillover Effects: Neighbor Legalization and Employment"
**Page:** 21
- **Formatting:** Standard.
- **Clarity:** High.
- **Storytelling:** Very interesting finding (the "race to legalize").
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 10: "Sports Betting Legalization Timeline"
**Page:** 29
- **Formatting:** High quality, lists every state.
- **Clarity:** Excellent.
- **Storytelling:** Essential documentation for replicability.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Pre-Treatment Trends by Cohort"
**Page:** 29
- **Formatting:** A bit cluttered due to many lines.
- **Clarity:** Low. It’s hard to follow specific cohorts.
- **Storytelling:** Important for showing raw data trends.
- **Recommendation:** **REVISE**
  - Use a "spaghetti plot" with lighter lines for individual states and thicker, colored lines for the cohort means. This will make the "trends" part of the story more visible.

### Figure 7: "Employment Effects by Betting Type"
**Page:** 30
- **Formatting:** Good use of colors and shading.
- **Clarity:** Clear.
- **Storytelling:** Visualizes the heterogeneity from Table 4.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 8 main tables, 5 main figures, 1 appendix table, 2 appendix figures.
- **General quality:** Extremely high. The exhibits follow the "modern DiD" template (Callaway-Sant'Anna, Event Studies, HonestDiD, Robustness whisker plots) perfectly.
- **Strongest exhibits:** Figure 3 (Robustness Whisker) and Table 2 (Main Results).
- **Weakest exhibits:** Table 7 (too small/standalone) and Figure 6 (visual clutter).
- **Missing exhibits:** A table or figure showing **Market Size (Handle) over time** vs. Employment. The abstract mentions a "$100 billion industry," but we never see a chart of the "Handle" growth alongside the "Employment" flatline. This "scissors plot" would be the most powerful visual in the paper.

### Top 3 Improvements:
1.  **Consolidate for Impact:** Merge Table 8 (Wages) into Table 2 (Employment) as Panel A and Panel B. This creates a one-stop-shop for the paper's primary findings.
2.  **Add a "Handle vs. Jobs" Figure:** Create a new Figure 2 that plots Total Industry Handle (Revenue) on the left Y-axis and Total Gambling Employment on the right Y-axis from 2014–2024. This visually demonstrates the "disconnect" mentioned in the text.
3.  **Streamline the Main Text:** Move Figure 5 (Wage Event Study), Figure 4 (Leave-one-out), and Table 3 (Event Study Coeffs) to the Appendix. This reduces visual fatigue and keeps the reader focused on the most robust evidence.