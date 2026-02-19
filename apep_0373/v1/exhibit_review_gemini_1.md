# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-19T14:10:36.668960
**Route:** Direct Google API + PDF
**Tokens:** 19957 in / 2072 out
**Response SHA256:** 8d375fb9bfc6924a

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by Degree Level"
**Page:** 11
- **Formatting:** Clean and professional. Use of horizontal rules is appropriate for top journals. Number alignment is generally good, though the "Mean Earnings" values could be more strictly decimal-aligned.
- **Clarity:** Excellent. The grouping by degree level is logical and the descriptive statistics (N, Institutions, States) provide immediate context for the sample size.
- **Storytelling:** Strong. It establishes the "proximity to the floor" argument by showing the P25/MW Ratio, which is central to the paper’s spillover hypothesis.
- **Labeling:** Clear. Notes define the P25/MW Ratio and units ($2023) are explicitly stated.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of Minimum Wage on Bachelor’s Degree Graduate Earnings"
**Page:** 16
- **Formatting:** Standard AER style. Coefficients and standard errors are vertically stacked.
- **Clarity:** Logical progression from P25 to P75 across columns, allowing the reader to see the "distributional gradient" quickly. 
- **Storytelling:** This is the "Main Result" table. It clearly shows the attenuation when controls are added. 
- **Labeling:** Comprehensive. Significance stars are defined, and clustering is noted.
- **Recommendation:** **REVISE**
  - **Change:** Add the Mean of the Dependent Variable (in levels, not logs) at the bottom of the table for each outcome. This helps readers interpret the magnitude of the 0.0519 elasticity in dollar terms.

### Table 3: "MW Elasticity by Degree Level"
**Page:** 17
- **Formatting:** Unusual and slightly cluttered. Placing [N=X] in brackets inside the cells is non-standard for top-tier journals.
- **Clarity:** The 3x3 grid (Percentile vs. Degree) is efficient but the internal labeling makes it harder to read than a standard column-based table.
- **Storytelling:** Vital for the argument that Associate degrees (closer to the floor) show higher elasticity. 
- **Labeling:** Good notes on FE and controls.
- **Recommendation:** **REVISE**
  - **Change:** Restructure into a standard regression table. Use columns for the degree levels (Certificate, Associate, Bachelor's) and panels for the percentiles (Panel A: P25, Panel B: P50, Panel C: P75). Move N to a row at the bottom. This would look more "at home" in the QJE.

### Table 4: "Robustness Checks: Bachelor’s Degree P25 Earnings"
**Page:** 19
- **Formatting:** Professional.
- **Clarity:** High. Each column represents a distinct "threat to validity" test.
- **Storytelling:** Crucial. Column (2) is a "killer" result (effect disappears with region-by-cohort FE) and needs to be prominent.
- **Labeling:** Clear description of the binary treatment and lead tests in the notes.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Persistence of MW Effects: Bachelor’s Degree Graduates"
**Page:** 20
- **Formatting:** Similar to Table 3; suffers from non-standard cell formatting (N in brackets).
- **Clarity:** Good use of columns for time horizons (1, 5, 10 years).
- **Storytelling:** Supports the "entry-level" mechanism.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Change:** Consistent with the recommendation for Table 3, move [N=X] to the bottom rows and use panels for the P-levels to improve readability.

### Table 6: "MW Elasticity by Field of Study (Bachelor’s, P25)"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** High. Groups fields clearly.
- **Storytelling:** This is a "null" or "puzzling" result. It belongs in the main text but doesn't need to be as large as the others.
- **Labeling:** Good inclusion of the CIP codes in the legend/notes.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 1: "Minimum Wage Variation Across States and Cohorts"
**Page:** 30
- **Formatting:** "Boring but beautiful" ggplot2 style. Panel B (the bar chart) is quite long.
- **Clarity:** Panel A is great for showing the "staggered" nature of the treatment. 
- **Storytelling:** Essential background for the identification strategy.
- **Labeling:** Panel B x-axis label "Change in Effective MW ($/hr)" is clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This should be the first figure in the paper (Section 3) to show the reader the variation being exploited.

### Figure 2: "Bachelor’s P25 Earnings vs. Annualized Minimum Wage"
**Page:** 31
- **Formatting:** Excellent. Use of size for N-institutions and color for cohorts is very "AER: Insights."
- **Clarity:** High. It shows the raw correlation.
- **Storytelling:** Good "first look" at the data.
- **Labeling:** Clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Place this in the Results section before the regression tables to anchor the reader in the raw data.

### Figure 3: "MW Elasticity by Earnings Percentile and Time Horizon"
**Page:** 32
- **Formatting:** Professional coefficient plot.
- **Clarity:** Good use of color to distinguish horizons.
- **Storytelling:** This is the "money shot" figure. It summarizes Table 2 and Table 5 in one visual.
- **Labeling:** Axis labels are perfect.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This is much more impactful than the tables for a general reader.

### Figure 4: "MW Elasticity by Degree Level and Percentile"
**Page:** 33
- **Formatting:** Consistent with Figure 3.
- **Clarity:** High.
- **Storytelling:** Visualizes Table 3.
- **Labeling:** Clean.
- **Recommendation:** **PROMOTE TO MAIN TEXT**

### Figure 5: "MW Elasticity by Field Wage Group (Bachelor’s, P25)"
**Page:** 34
- **Formatting:** Consistent.
- **Clarity:** Clear.
- **Storytelling:** Shows the null result for the field-of-study analysis.
- **Recommendation:** **KEEP IN APPENDIX**

### Figure 6: "Jackknife Sensitivity: Dropping One State at a Time"
**Page:** 35
- **Formatting:** Standard robustness plot.
- **Clarity:** High.
- **Storytelling:** Proves the result isn't driven by New York or California.
- **Recommendation:** **KEEP IN APPENDIX**

### Figure 7: "First-Year Earnings Trends by Degree Level and Percentile"
**Page:** 36
- **Formatting:** Three-panel line chart. 
- **Clarity:** The scales are different on the y-axes (Bachelor's goes to 60, Certificate to 55).
- **Storytelling:** Shows the "Parallel Trends" (or lack thereof) in raw earnings.
- **Recommendation:** **REVISE**
  - **Change:** Force all three panels to use the same y-axis scale (e.g., $25k to $65k). This allows the reader to visually compare the levels across degrees instantly. Move to Main Text (Data section).

---

## Overall Assessment

- **Exhibit count:** 6 main tables, 0 main figures, 0 appendix tables, 7 appendix figures.
- **General quality:** The tables are standard and professional, but the paper relies too heavily on text/tables in the main body. The figures are high-quality but are "hidden" in the appendix.
- **Strongest exhibits:** Figure 2 (Scatterplot) and Figure 3 (Coefficient Plot).
- **Weakest exhibits:** Table 3 and Table 5 (due to the non-standard inclusion of N in the cells).
- **Missing exhibits:** A **Map** showing which 33 states are in the PSEO sample would be a standard and helpful addition to Section 3 or 5.

### Top 3 Improvements:
1. **Bring the visuals forward:** Promote Figures 1, 2, 3, and 4 to the main text. Top journals (AER/QJE) prefer seeing the variation (Fig 1), the raw correlation (Fig 2), and the main result summary (Fig 3) as figures before diving into dense tables.
2. **Restructure Tables 3 and 5:** Use a Panel A/B/C structure for different percentiles and move the observation counts to the footer. This eliminates clutter within the data cells.
3. **Harmonize Figure 7:** Use a common y-axis for the trend lines to allow for cross-panel comparison of earnings levels. Move this to the main "Data" section to satisfy the reader's curiosity about raw trends before seeing regression results.