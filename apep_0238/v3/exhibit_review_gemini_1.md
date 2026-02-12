# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T15:45:14.699630
**Route:** Direct Google API + PDF
**Tokens:** 36597 in / 2689 out
**Response SHA256:** 5fa0555cc8540254

---

This review evaluates the exhibits of "Demand Recessions Scar, Supply Recessions Don’t" for submission to top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 14
- **Formatting:** Clean, standard LaTeX booktabs style.
- **Clarity:** Logical split between Panel A (Panel Data) and Panel B (Cross-section).
- **Storytelling:** Essential. Establishes the massive difference in shock intensity (COVID trough is 2.6x deeper than GR).
- **Labeling:** Good. Includes units (thousands, %).
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Most and Least Affected States by Recession"
**Page:** 16
- **Formatting:** Standard.
- **Clarity:** High. Instantly shows the geographic/industrial shift between the two recessions (Sun Belt/Housing vs. Tourism/Leisure).
- **Storytelling:** Excellent "hook" for the empirical strategy.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Pre-Trend Event Study: Employment Response to Recession Exposure"
**Page:** 23
- **Formatting:** Subfigures are well-aligned. Use of "Pre-period" text helps.
- **Clarity:** Good. The contrast between flat pre-trends and diverging post-trends is obvious.
- **Storytelling:** Vital for identification.
- **Labeling:** Y-axis labels are consistent.
- **Recommendation:** **REVISE**
  - Change the legend or titles to be more descriptive than "HPI instrument" and "Bartik instrument." Use "Demand (Housing Boom)" and "Supply (Bartik)."
  - The y-axis on Panel B is much wider than Panel A; consider standardizing the scale or adding a prominent note that the COVID shock magnitude is significantly larger.

### Table 3: "Local Projection Estimates: Employment Response to Recession Exposure"
**Page:** 24
- **Formatting:** AER-standard. Permutation p-values in brackets are a sophisticated addition for top journals.
- **Clarity:** Logical progression of horizons.
- **Storytelling:** This is the core result of the paper.
- **Labeling:** Stars and SEs correctly defined.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Employment Persistence: Half-Lives and Recovery Measures"
**Page:** 25
- **Formatting:** Professional.
- **Clarity:** Summarizes complex IRFs into a few key metrics.
- **Storytelling:** Helpful, but arguably this data could be integrated into Table 3 or Figure 2 to save space if needed.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (Optional: Move to Appendix if page count is tight).

### Figure 2: "Local Projection Impulse Response Functions: Employment"
**Page:** 26
- **Formatting:** Shaded 95% CIs are standard. 
- **Clarity:** The "Standardized" note is crucial for the 10-second parse.
- **Storytelling:** This is the "money shot." It visually proves the scarring vs. snapback.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Local Projection IRFs: Unemployment Rate and Labor Force Participation Rate"
**Page:** 27
- **Formatting:** Four-panel layout is clean.
- **Clarity:** Shows the mechanism: Demand shocks kill participation (Panel C), Supply shocks don't (Panel D).
- **Storytelling:** Crucial for the "scarring" argument.
- **Labeling:** Y-axis labels (pp change) are good.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Peak-to-Trough Employment Declines by State"
**Page:** 28
- **Formatting:** State-tile maps are cleaner than choropleths for US state data.
- **Clarity:** Immediate visual distinction between the two crises.
- **Storytelling:** Provides the spatial evidence for the instruments.
- **Labeling:** Color bar scale is clear.
- **Recommendation:** **REVISE**
  - Ensure the color scales are comparable or explicitly noted as different. The Great Recession scale goes to -0.14, COVID to -0.30.

### Figure 5: "Recession Exposure vs. Long-Run Employment Change"
**Page:** 28
- **Formatting:** Clean scatter plots.
- **Clarity:** Shows the "reduced form" relationship at a specific horizon (h=48).
- **Storytelling:** Slightly redundant with Figure 2, but provides the raw data transparency that QJE/AER reviewers love.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Aggregate Employment Paths: Great Recession vs. COVID"
**Page:** 29
- **Formatting:** Four panels.
- **Clarity:** High.
- **Storytelling:** Contextualizes the state-level results with the national experience.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX** (This is descriptive/contextual. The paper’s contribution is the state-level identification. This takes up a full page of valuable main-text real estate).

### Figure 7: "JOLTS Labor Market Flows: Great Recession vs. COVID"
**Page:** 32
- **Formatting:** Four panels.
- **Clarity:** A bit cluttered. The colors for GR and COVID windows are faint.
- **Storytelling:** Strong evidence for "Supply vs. Demand" (Layoffs vs. Quits).
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Darken the "Blue/Red" shaded windows; they are difficult to see in some light.
  - Consolidate: Consider showing only Layoffs and Quits in the main text; move Hires/Openings to the appendix.

### Table 5: "Model Calibration"
**Page:** 35
- **Formatting:** Professional.
- **Clarity:** High. The "Target/Source" column is essential for transparency.
- **Storytelling:** Standard for structural macro/labor papers.
- **Labeling:** Units are missing for some parameters (e.g., $\kappa$ is in what units?).
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Model vs. Data: Employment Paths After Demand and Supply Shocks"
**Page:** 37
- **Formatting:** Solid lines (model) vs. dots (data) is a good choice.
- **Clarity:** High.
- **Storytelling:** Validates the structural model.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Counterfactual Employment Paths"
**Page:** 39
- **Formatting:** Multiple line styles.
- **Clarity:** A bit busy.
- **Storytelling:** Shows "No skill depreciation" is the biggest driver of recovery.
- **Labeling:** Legend needs careful reading.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Welfare Losses from Demand vs. Supply Shocks: Model Counterfactuals"
**Page:** 40
- **Formatting:** Standard.
- **Clarity:** The 147:1 ratio is the key takeaway.
- **Storytelling:** Puts a "welfare" dollar/utility value on the findings.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Welfare Decomposition: Demand Shock"
**Page:** 41
- **Formatting:** Bar chart.
- **Clarity:** Instant communication of the mechanism's relative importance.
- **Storytelling:** Replaces a paragraph of text.
- **Labeling:** Data labels on top of bars are helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 11: "Cross-Recession Comparison and Placebo Tests"
**Page:** 44
- **Formatting:** Overlapping distributions.
- **Clarity:** High.
- **Storytelling:** Robustness check for p-values.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 12: "Recovery Speed Maps: Months to Full Employment Recovery"
**Page:** 45
- **Formatting:** State-tile maps.
- **Clarity:** High.
- **Storytelling:** Visualizes the "half-life" results geographically.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 7: "FRED Data Series"
**Page:** 58
- **Recommendation:** **KEEP AS-IS** (Excellent for replication).

### Table 8: "Local Projection Estimates: Unemployment Rate Response"
**Page:** 61
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Local Projection Estimates: Labor Force Participation Rate Response"
**Page:** 62
- **Recommendation:** **KEEP AS-IS**

### Table 10: "Subsample Robustness: Great Recession Employment Effects"
**Page:** 63
- **Recommendation:** **KEEP AS-IS**

### Table 11: "Model Sensitivity: Employment Impact at 48 Months..."
**Page:** 64
- **Recommendation:** **KEEP AS-IS**

### Figure 13: "Model Parameter Sensitivity: Employment Impact at 48 Months"
**Page:** 65
- **Recommendation:** **REMOVE** (This is a heatmap version of Table 11; it is redundant and adds no new info).

### Table 12: "COVID LP Coefficients Under Alternative Bartik Base Years"
**Page:** 66
- **Recommendation:** **KEEP AS-IS**

### Table 13: "Great Recession LP Coefficients: HC1 vs. Census Division Clustering"
**Page:** 66
- **Recommendation:** **KEEP AS-IS**

### Table 14: "Great Recession LP Coefficients: Excluding Sand States"
**Page:** 67
- **Recommendation:** **KEEP AS-IS**

### Table 15: "Pre-Trend Tests: Great Recession"
**Page:** 67
- **Recommendation:** **KEEP AS-IS**

### Table 16: "Model Sensitivity: Demand Shock Employment at h = 48"
**Page:** 68
- **Recommendation:** **KEEP AS-IS**

---

# Overall Assessment

- **Exhibit count:** 4 Tables Main, 12 Figures Main; 9 Tables Appendix, 1 Figure Appendix.
- **General quality:** Extremely high. The paper follows the "Mian and Sufi" style of data transparency and clear, panel-driven visualization.
- **Strongest exhibits:** Figure 2 (Core result), Figure 10 (Mechanism importance), Table 3 (Regression evidence).
- **Weakest exhibits:** Figure 6 (Descriptive and takes too much space), Figure 7 (Visual clutter in the shading).
- **Missing exhibits:** A **Correlation Matrix** of the instruments against other state-level controls (Demographics, Political leaning, etc.) would bolster the "Exogeneity" section.

**Top 3 Improvements:**
1. **Consolidate Figures:** The main text has 12 figures. This is too many for AER/QJE. Move Figure 6 (Aggregate Paths) and Figure 7 (JOLTS) to the Appendix to keep the reader focused on your unique state-level identification.
2. **Standardize Scales:** In Figure 4 (Maps) and Figure 1 (Pre-trends), ensure the y-axis or color-bar scales are either identical or that the difference is much more prominently noted in the caption. 
3. **Parameter Units:** In Table 5, add units/scales for the vacancy posting cost ($\kappa$) and the flow value of OLF ($b_{olf}$) to improve the "Economic Significance" interpretation of the structural model.