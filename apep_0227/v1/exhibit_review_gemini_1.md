# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-11T17:03:45.784254
**Route:** Direct Google API + PDF
**Tokens:** 19437 in / 1998 out
**Response SHA256:** 6f11140f28470886

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Generally professional. Uses standard booktabs-style horizontal lines. Decimal alignment is good.
- **Clarity:** Clear logical flow (Outcomes $\rightarrow$ Controls $\rightarrow$ Sample). Using SDs in parentheses is standard.
- **Storytelling:** Effective. It clearly shows the "sicker states treat first" selection pattern mentioned in the text (5.87 vs 8.12 baseline).
- **Labeling:** Good. Defines units (per 100,000) and includes a thorough note explaining the "Never-Treated" composition.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "TWFE Estimates: Effect of FTS Legalization on Overdose Deaths"
**Page:** 13
- **Formatting:** Professional. Use of "—" for excluded controls is standard.
- **Clarity:** The comparison between levels (1-2) and logs (3) is the key takeaway.
- **Storytelling:** Essential "benchmark" table. It sets up the "false positive" that the rest of the paper deconstructs.
- **Labeling:** Clear. Significance stars are defined. Note explains the $log(rate + 0.1)$ adjustment.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Callaway-Sant’Anna Estimates: FTS Legalization and Synthetic Opioid Deaths"
**Page:** 14
- **Formatting:** Clean.
- **Clarity:** High. Aggregates the complex CS-DiD results into a digestible summary.
- **Storytelling:** This is the "Main Result" table. It highlights the discrepancy between different comparison groups and the RI $p$-value.
- **Labeling:** Good. Explicitly mentions bootstrap iterations and RI permutations.
- **Recommendation:** **REVISE**
  - **Change:** Add a column for "N (Observations)" or "States" to match the detail in Table 1, reinforcing the small size of the comparison group.

### Figure 1: "Dynamic Event Study: Effect of FTS Legalization on Synthetic Opioid Deaths"
**Page:** 15
- **Formatting:** Excellent. Professional ggplot2/stata style with clean background and clear point/range markers.
- **Clarity:** The message is clear—the "effect" is driven by the late periods (DC outlier).
- **Storytelling:** Crucial. It visually proves the violation of parallel trends at $e = -2$ and the $e=5$ explosion.
- **Labeling:** Y-axis and X-axis labels are perfect. Title is descriptive.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Sun-Abraham Interaction-Weighted Estimates"
**Page:** 16
- **Formatting:** Standard.
- **Clarity:** Good, but less impactful as a table than it would be as a figure.
- **Storytelling:** Provides the "robustness" counterpart to Figure 1.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Change:** Convert this to a figure (Event Study Plot) and overlay it with the CS-DiD results from Figure 1 (using different colors/shapes). Top journals prefer visual comparisons of different estimators over raw tables of event-time coefficients.

### Table 5: "Cohort-Specific Average Treatment Effects"
**Page:** 17
- **Formatting:** Clean.
- **Clarity:** High. Grouping by cohort and listing states helps identify outliers (DC, 2018 cohort).
- **Storytelling:** This is arguably the most important table for the "heterogeneity" argument.
- **Labeling:** Sufficient.
- **Recommendation:** **KEEP AS-IS** (Or consider promoting to Figure 1's position as a "Heterogeneity by Cohort" bar chart if space allows).

### Figure 2: "Randomization Inference: Permutation Distribution of ATT Estimates"
**Page:** 18
- **Formatting:** Journal-ready. Use of the orange vertical line for the actual estimate is standard.
- **Clarity:** Very high. Immediately shows the estimate is not an outlier.
- **Storytelling:** Solidifies the "null" interpretation.
- **Labeling:** $p$-value and permutation count in the subtitle is good.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "HonestDiD Sensitivity Analysis: Relative Magnitudes"
**Page:** 19
- **Formatting:** Clean.
- **Clarity:** Requires technical knowledge of Rambachan & Roth (2023), but standard for the field.
- **Storytelling:** Effectively shows that the result is not robust to even small trend violations.
- **Labeling:** Defines $\bar{M}$ clearly.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Comparison of DiD Estimators: Point Estimates and 95% CI"
**Page:** 20
- **Formatting:** Clean.
- **Clarity:** Excellent "summary" visualization.
- **Storytelling:** This belongs near the beginning of the results section or as a summary figure in the conclusion. It tells the "fragility" story in one glance.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (But consider moving earlier in the text).

### Table 7: "Robustness: Alternative Specifications"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** The "Placebo" results are fascinating and support the author's nuanced interpretation of the data.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 8: "Variable Definitions"
**Page:** 31
- **Formatting:** Simple list.
- **Clarity:** Essential for replication.
- **Storytelling:** Informational.
- **Labeling:** High.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Staggered Adoption of FTS Legalization by Year"
**Page:** 32
- **Formatting:** Professional bar chart.
- **Clarity:** Very high.
- **Storytelling:** Explains the "wave" of 2022-2023.
- **Labeling:** Includes N on top of bars—very helpful.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (This is a standard "Figure 1" for DiD papers to show treatment variation).

### Figure 5: "Synthetic Opioid Overdose Death Rates: Treated vs. Never-Treated States"
**Page:** 33
- **Formatting:** Clean line plot.
- **Clarity:** Shows the "Parallel Trends" visual check.
- **Storytelling:** This is the most basic check in a DiD paper.
- **Labeling:** Good.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Usually follows the adoption timing figure).

### Table 9: "FTS Legalization Timeline"
**Page:** 35
- **Formatting:** Clean list.
- **Clarity:** Excellent reference for which states are in which cohort.
- **Storytelling:** Supports the cohort-level analysis.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 6 main tables, 3 main figures, 2 appendix tables, 2 appendix figures.
- **General quality:** Extremely high. The paper follows modern "Best Practices" for DiD (HonestDiD, RI, CS-DiD, SA). The visual style is consistent and professional.
- **Strongest exhibits:** Figure 1 (Event Study), Table 5 (Cohort Heterogeneity).
- **Weakest exhibits:** Table 4 (Event-time coefficients are better as a figure).
- **Missing exhibits:** 
    - **A Map:** A US map showing legalization years (shaded by cohort) would be very helpful for visualizing the "Northeastern 2018" vs "Southern 2023" geographic clustering mentioned in the text.
    - **Balance Table:** A more formal check of whether baseline characteristics (Poverty, Unemployment) predict treatment timing.

### Top 3 Improvements:
1.  **Reorganize Flow:** Move Figure 4 (Adoption) and Figure 5 (Raw Trends) to the main text (Section 3 or 4) to establish the "Experiment" before showing the results.
2.  **Visualize Estimator Comparison:** Merge Table 4 (Sun-Abraham) into a visual plot that overlays SA estimates with the CS estimates in Figure 1 to show how robust the event study is across estimators.
3.  **Add a Geographic Map:** Create a "Map of FTS Legalization" (Main Text Figure 1 or 2) to show the spatial diffusion of the policy. This grounds the "DC as outlier" and "Northeast 2018 cohort" arguments.