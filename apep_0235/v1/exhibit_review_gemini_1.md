# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T11:34:18.271801
**Route:** Direct Google API + PDF
**Tokens:** 30357 in / 2922 out
**Response SHA256:** 71710ac16f269f26

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Jarocinski-Karadi Monetary Policy Shock Series, 1990–2024"
**Page:** 8
- **Formatting:** Clean, professional line weights. NBER shaded regions are standard for top journals.
- **Clarity:** Excellent. Spikes are clearly visible.
- **Storytelling:** Essential context for the independent variable.
- **Labeling:** Units are clearly defined (pp).
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Good use of panels. Numbers are clearly legible.
- **Clarity:** Layout is logical.
- **Storytelling:** Provides necessary overview of the data scales.
- **Labeling:** Clear. Note explains the data source and variable definitions well.
- **Recommendation:** **REVISE**
  - Change the number of decimals for "MP Shock (JK)" in Panel A. Showing "0.0" for mean and SD when the min/max are "-0.4/0.1" hides the variation. Use three decimal places (e.g., 0.001).
  - Decimal-align all columns for professional consistency.

### Figure 2: "Aggregate Employment Response to a Contractionary Monetary Shock"
**Page:** 15
- **Formatting:** Standard IRF plot style. Shaded regions for CIs are professional.
- **Clarity:** The "overshoot" at month 36 is clear.
- **Storytelling:** Establishes the baseline aggregate result.
- **Labeling:** Y-axis clearly labeled.
- **Recommendation:** **REVISE**
  - Add a horizontal dashed line at 0 to make the "overshoot" and return to zero easier to identify visually.
  - The title inside the plot area ("Response of Total Nonfarm...") is redundant with the caption; remove it to save space and reduce clutter.

### Table 2: "Aggregate Employment Response to Monetary Tightening"
**Page:** 16
- **Formatting:** Horizontal rules are used correctly (top, mid, bottom).
- **Clarity:** Logical horizon (h) progression.
- **Storytelling:** Redundant with Figure 2. Top journals (AER/QJE) rarely show the exact same results in both a figure and a table unless the point estimates are crucial for a meta-analysis.
- **Labeling:** Standard errors in parentheses are noted.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 3: "Industry-Level Employment Impulse Responses"
**Page:** 18
- **Formatting:** High-density 4x3 grid.
- **Clarity:** Very cluttered. The individual y-axes vary significantly (e.g., Mining goes to 30, while Education only to 2), which is helpful for seeing individual shapes but misleading for comparing magnitudes across sectors.
- **Storytelling:** Crucial for showing heterogeneity.
- **Labeling:** Labels [G] and [S] for Goods and Services are helpful.
- **Recommendation:** **REVISE**
  - Standardize y-axis scales across all panels (or at least within rows) to allow the reader to see that Leisure/Hospitality's response is an order of magnitude larger than Retail Trade's.
  - Move the "Response (%)" label to the far left of each row rather than repeating it.

### Table 3: "Industry-Level Peak Employment Responses to Monetary Tightening"
**Page:** 19
- **Formatting:** Clean and professional.
- **Clarity:** Sorting by magnitude is excellent practice.
- **Storytelling:** This is a "star" exhibit. It distills the 12 plots of Figure 3 into a single, digestible list.
- **Labeling:** Clearly defined columns.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Goods versus Services Employment Responses"
**Page:** 20
- **Formatting:** Overlapping CI bands can become muddy.
- **Clarity:** The red (Goods) and blue (Services) distinction is clear, but the many shades of CI bands make it hard to distinguish the 68% vs 90% ranges for both simultaneously.
- **Storytelling:** Central to the paper's "Two-Sector" model theme.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Simplify to only 90% CI bands or use hatching for one of the sectors to distinguish the overlapping shaded areas.

### Table 4: "Goods vs. Services: Interaction Local Projections"
**Page:** 21
- **Formatting:** Professional and journal-ready.
- **Clarity:** High. Interaction term is clearly highlighted.
- **Storytelling:** Provides the statistical "meat" for the Figure 4 visual.
- **Labeling:** Proper significance stars and clustering notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Cyclicality Interaction Estimates"
**Page:** 22
- **Formatting:** Line styles (dashed, dotted) are distinct.
- **Clarity:** Good.
- **Storytelling:** This is the most important empirical result in the paper (cyclicality as the driver).
- **Labeling:** Axis labels are correct.
- **Recommendation:** **PROMOTE TO TOP OF RESULTS SECTION** (No formatting changes needed).

### Figure 6: "JOLTS Decomposition of Labor Market Response"
**Page:** 23
- **Formatting:** Multi-panel layout.
- **Clarity:** Y-axis for "Layoffs/Discharges" is extremely small (-2.0 to 1.0) compared to "Job Openings" (-1000 to 5000). This is the intended point, but it's easy to miss.
- **Storytelling:** Supports the "reduced hiring" vs "increased firing" mechanism.
- **Labeling:** Units (thousands) are clear.
- **Recommendation:** **REVISE**
  - Place "Job Openings" and "Layoffs" side-by-side to emphasize the scale difference.
  - Add a note in the caption explicitly pointing out the scale difference between the hiring flows and the layoff flows.

### Table 5: "JOLTS Flow Responses to Monetary Tightening"
**Page:** 24
- **Formatting:** Consistent with Table 2.
- **Clarity:** Good.
- **Storytelling:** Redundant with Figure 6.
- **Labeling:** Standard.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 7: "Robustness: Subsample and Specification Checks"
**Page:** 26
- **Formatting:** Good use of different line styles.
- **Clarity:** A bit "spaghetti-like" with four overlapping lines and a large CI band.
- **Storytelling:** Critical for convincing reviewers.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Remove the CI band from the "Baseline" in this specific plot. Since this is about comparing point estimates across specifications, the band adds too much visual noise.

### Table 6: "Robustness of Aggregate Employment Response"
**Page:** 27
- **Formatting:** Densely packed but readable.
- **Clarity:** Clear row-wise comparison.
- **Storytelling:** Summarizes the robustness checks well.
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Placebo Test: Pre-FOMC Employment Growth"
**Page:** 28
- **Formatting:** Simple dot-and-whisker plot.
- **Clarity:** High.
- **Storytelling:** Important "Threats to Validity" exhibit.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Goods-Sector Interaction: Base and Differential Effects"
**Page:** 29
- **Formatting:** Single line plot.
- **Clarity:** High.
- **Storytelling:** Quantifies the "Goods" effect found in Table 4.
- **Labeling:** Axis labels are correct.
- **Recommendation:** **REVISE**
  - The caption mentions a "Left panel" and "Right panel," but there is only one plot. Ensure the figure includes both the base effect and the interaction effect side-by-side or update the caption.

### Table 7: "Model Calibration"
**Page:** 35
- **Formatting:** Excellent use of a "Source" column.
- **Clarity:** Very high.
- **Storytelling:** Essential for the structural section.
- **Labeling:** Clear units.
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Model versus Data: Employment Impulse Responses"
**Page:** 37
- **Formatting:** 3-panel horizontal layout.
- **Clarity:** Dots (Data) vs Lines (Model) is an effective way to show fit.
- **Storytelling:** Validates the model.
- **Labeling:** Descriptive titles.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Model vs. Data: Employment Responses (% Deviation)"
**Page:** 37
- **Formatting:** Good use of grouped column headers.
- **Clarity:** Easy to compare Data vs Model.
- **Storytelling:** Numerical backing for Figure 10.
- **Labeling:** Notes explain the "noise" at longer horizons.
- **Recommendation:** **REVISE**
  - Bold the "Model" column if it is the primary contribution, or the "Data" if that is the benchmark.

### Figure 11: "Welfare Decomposition: Goods versus Services Workers"
**Page:** 40
- **Formatting:** Bar chart. Professional colors.
- **Clarity:** High.
- **Storytelling:** The "punchline" of the welfare section.
- **Labeling:** Legend includes "Transition," but it's not visible in the bars (likely zero).
- **Recommendation:** **REVISE**
  - If "Transition" costs are zero/negligible, remove them from the legend to avoid confusion.

### Table 9: "Welfare Costs of Monetary Tightening"
**Page:** 41
- **Formatting:** Multi-panel (A, B, C).
- **Clarity:** Logical grouping of losses and aggregates.
- **Storytelling:** Final summary of the paper's normative findings.
- **Labeling:** Excellent notes.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table: "C.2 CES Employment Data" (Mnemonic Table)
**Page:** 52
- **Formatting:** Simple two-column list.
- **Clarity:** High.
- **Recommendation:** **KEEP AS-IS**

### Table: "C.4 Cyclicality Classification"
**Page:** 53
- **Formatting:** Sorted by Beta.
- **Clarity:** Excellent.
- **Recommendation:** **KEEP AS-IS** (Consider moving this to the main text if space permits, as it defines the "High/Medium/Low" groups used in Figure 5).

### Table: "D.2 Placebo Test Details"
**Page:** 54
- **Formatting:** Simple regression results.
- **Clarity:** High.
- **Recommendation:** **KEEP AS-IS**

### Table: "D.4 Model Sensitivity Analysis"
**Page:** 56
- **Formatting:** Clear "Delta from Baseline" column.
- **Clarity:** High.
- **Storytelling:** Standard for structural papers to show parameter robustness.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 7 main tables, 11 main figures, 4 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The paper follows top-tier formatting conventions (Jordà-style IRFs, HAC errors, NBER shading).
- **Strongest exhibits:** Table 3 (Industry Peak Responses) and Figure 10 (Model vs Data).
- **Weakest exhibits:** Figure 3 (Cluttered IRF grid) and Figure 4 (Overlapping shaded regions).
- **Missing exhibits:** A **"Figure 0" or "Table 0" showing the Industry Cyclicality Betas** visually would be helpful in the main text, as "Cyclicality" is the paper's primary contribution. Currently, it's buried in Appendix C.4.

### Top 3 Improvements:
1.  **Standardize Y-Axes in Figure 3:** Currently, you cannot visually compare the magnitude of the response between Manufacturing and Construction. This is critical for the "heterogeneity" story.
2.  **Consolidate Tables/Figures:** Move Table 2 and Table 5 to the Appendix. They repeat information shown in Figures 2 and 6. Top journals prefer the visual IRF in the main text and the point estimates in the Appendix.
3.  **Refine overlapping CIs:** In Figures 4 and 7, the multiple overlapping shaded regions create "visual mud." Use line styles or different transparency levels to make the comparison cleaner.