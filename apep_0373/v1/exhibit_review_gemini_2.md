# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-19T14:39:02.514015
**Route:** Direct Google API + PDF
**Tokens:** 20477 in / 2082 out
**Response SHA256:** 9ef672cf1bfff328

---

This review evaluates the visual exhibits of the paper titled **"Does Raising the Floor Lift Graduates? Minimum Wage Spillovers and the College Earnings Distribution"** according to the standards of top-tier economics journals (e.g., AER, QJE).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by Degree Level"
**Page:** 12
- **Formatting:** Clean and professional. Uses booktabs-style horizontal lines. Numbers are generally well-aligned.
- **Clarity:** Excellent. Provides a clear bird's-eye view of the sample size and the proximity of graduate earnings to the minimum wage.
- **Storytelling:** Strong. The "P25/MW Ratio" row is the "hook" of the paper—it justifies why we should care about spillovers for these groups.
- **Labeling:** Comprehensive. The notes define the annualized MW calculation and the purpose of the graduate degree group.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of Minimum Wage on Bachelor’s Degree Graduate Earnings"
**Page:** 17
- **Formatting:** High quality. Proper grouping of P25, P50, and P75.
- **Clarity:** Good. The odd/even column structure (without/with controls) is standard for showing attenuation.
- **Storytelling:** This is the core result. It shows the monotone declining gradient (0.051 → 0.023 → -0.009).
- **Labeling:** Clear. Significance stars are defined, and clustering is noted.
- **Recommendation:** **REVISE**
  - **Specific changes:** Add a row for the "Mean of Dep. Var." at the bottom of the table. While the outcomes are logs, providing the level mean (from Table 1) helps the reader scale the elasticity in their head.

### Table 3: "MW Elasticity by Degree Level"
**Page:** 18
- **Formatting:** Professional.
- **Clarity:** Good, but the inclusion of "[N=X]" inside the cells is slightly unconventional for top journals.
- **Storytelling:** Excellent consolidation. It allows a direct comparison of the "treatment" intensity across different credential levels.
- **Labeling:** Standard.
- **Recommendation:** **REVISE**
  - **Specific changes:** Move the observation counts ($N$) and the number of states/clusters to the bottom panel of the table (below the Fixed Effects rows) rather than inside the coefficient cells. This reduces visual clutter.

### Table 4: "Robustness Checks: Bachelor’s Degree P25 Earnings"
**Page:** 20
- **Formatting:** Journal-ready.
- **Clarity:** High. Each column represents a distinct "threat to validity" addressed in the text.
- **Storytelling:** Very honest storytelling. Column (2) shows the "death" of the result with region-by-cohort FEs, which is a major part of the paper's nuance.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Persistence of MW Effects: Bachelor’s Degree Graduates"
**Page:** 21
- **Formatting:** Consistent with Table 3.
- **Clarity:** Good. Shows how the effect "fades" over time.
- **Storytelling:** Critical for the "entry-level" argument. 
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Specific changes:** Like Table 3, move the $[N=X]$ labels to a dedicated row at the bottom.

### Table 6: "MW Elasticity by Field of Study (Bachelor’s, P25)"
**Page:** 22
- **Formatting:** Slightly different from the other tables (uses SE and N columns).
- **Clarity:** Clear, though the results are "puzzling" (as admitted in the text).
- **Storytelling:** Necessary for completeness, but since the results are null/reversed, it feels less central.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reason:** The main text should focus on the credential-level and distributional results. The field-of-study results are weak and do not support the main hypothesis, making them better suited for a robustness/heterogeneity appendix.

## Appendix Exhibits

### Figure 1: "Minimum Wage Variation Across States and Cohorts"
**Page:** 31
- **Formatting:** Professional ggplot2 style. 
- **Clarity:** Panel A is slightly "spaghetti-like" due to 33 states, but the orange/blue distinction works well. Panel B is a very effective bar chart.
- **Storytelling:** Essential "Figure 1" for a policy paper. It shows the "bite" and the "variation."
- **Labeling:** Excellent.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - **Reason:** In a minimum wage paper, the reader *must* see the variation in the independent variable early on. This should appear in Section 3 (Institutional Background).

### Figure 2: "Bachelor’s P25 Earnings vs. Annualized Minimum Wage"
**Page:** 32
- **Formatting:** Good use of transparency (alpha) and size mapping.
- **Clarity:** High.
- **Storytelling:** Provides the raw correlation underlying the regressions.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (in Appendix)

### Figure 3: "MW Elasticity by Earnings Percentile and Time Horizon"
**Page:** 33
- **Formatting:** Excellent. Color-coded by horizon.
- **Clarity:** Very high. This is the "money shot" of the paper.
- **Storytelling:** This single figure summarizes Table 2 and Table 5 perfectly.
- **Labeling:** Clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - **Reason:** Top journals (especially AEJ: Policy) prefer visual summaries of coefficients. This figure tells the whole story: spillovers are at the bottom (P25) and they disappear over time (1yr vs 10yr).

### Figure 4: "MW Elasticity by Degree Level and Percentile"
**Page:** 34
- **Formatting:** Consistent with Figure 3.
- **Clarity:** High.
- **Storytelling:** Visualizes Table 3.
- **Labeling:** Good.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (or consolidate with Figure 3 as Panel B).

### Figure 5: "MW Elasticity by Field Wage Group (Bachelor’s, P25)"
**Page:** 35
- **Formatting:** Consistent.
- **Clarity:** Clear.
- **Storytelling:** Visualizes the null/reversed field-of-study results.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (in Appendix)

### Figure 6: "Jackknife Sensitivity: Dropping One State at a Time"
**Page:** 36
- **Formatting:** Standard jackknife plot.
- **Clarity:** Good.
- **Storytelling:** Shows the result isn't driven by California or New York alone.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (in Appendix)

### Figure 7: "First-Year Earnings Trends by Degree Level and Percentile"
**Page:** 37
- **Formatting:** Clean multi-panel time series.
- **Clarity:** High.
- **Storytelling:** Shows the raw trends in the dependent variables.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (in Appendix)

---

# Overall Assessment

- **Exhibit count:** 6 main tables, 0 main figures, 0 appendix tables, 7 appendix figures.
- **General quality:** The tables are exceptionally well-formatted and journal-ready. The figures are high-quality but are currently "hiding" in the appendix.
- **Strongest exhibits:** Table 1 (perfect context), Figure 3 (perfect results summary), Figure 1 (excellent policy variation plot).
- **Weakest exhibits:** Table 6 (results are puzzling and undermine the story; belongs in appendix).
- **Missing exhibits:** 
    - **Event Study Plot:** For any paper using staggered variation, a "leads and lags" figure is now a standard requirement in top journals to visually prove parallel trends. Table 4 Column 3 (Lead Test) is good, but a plot is better.
    - **Map:** A simple choropleth map of the US showing the total MW increase by state (visualizing Figure 1B) helps readers instantly grasp the geography of the treatment.

### Top 3 Improvements:
1. **Balance Figures and Tables:** Move Figure 1 and Figure 3 from the Appendix to the Main Text. Currently, the main text is "table-heavy," which can be fatiguing. Figure 3 is the most compelling evidence in the paper.
2. **Standardize Table Footers:** In Tables 3 and 5, remove the `[N=...]` from the middle of the table and place them in a dedicated row at the bottom. This makes the coefficients much easier to scan.
3. **Add an Event Study Figure:** Construct a figure that plots the coefficients of lead and lag minimum wages. This is the "gold standard" for identification in modern applied microeconomics.