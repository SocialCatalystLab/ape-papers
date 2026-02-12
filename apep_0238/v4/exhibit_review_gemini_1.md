# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T16:53:48.328787
**Route:** Direct Google API + PDF
**Tokens:** 28797 in / 2130 out
**Response SHA256:** 0059ebc1192252c0

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 12
- **Formatting:** Clean and professional. Good use of horizontal rules (booktabs style).
- **Clarity:** Logically grouped into Panel A (outcomes) and Panel B (exposure).
- **Storytelling:** Essential. It establishes the scale of the shocks (e.g., COVID shock was 2.6x larger than the Great Recession).
- **Labeling:** Clear. Units (thousands, %, log) are all present.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Local Projection Estimates: Employment Response to Recession Exposure"
**Page:** 16
- **Formatting:** Generally strong. Standard errors are correctly in parentheses.
- **Clarity:** The juxtaposition of Panel A (GR) and Panel B (COVID) is the core of the paper. However, the empty columns in Panel B for $h=60$ to $h=120$ make the table look unfinished.
- **Storytelling:** This is the "money table." It proves the scarring vs. recovery thesis.
- **Labeling:** Inclusion of permutation p-values in brackets is excellent for robustness. 
- **Recommendation:** **REVISE**
  - Add "N/A" or "—" to the empty cells in Panel B to indicate that the observation window for COVID has not yet reached those horizons, rather than leaving them blank.
  - Add a "Mean of Dep. Var" row to help readers interpret the magnitude of the coefficients.

### Table 3: "Employment Persistence: Half-Lives and Recovery Measures"
**Page:** 17
- **Formatting:** Good.
- **Clarity:** Very high. It distills complex IRFs into three or four key metrics.
- **Storytelling:** Excellent summary table that makes the 10-second "takeaway" very easy to find.
- **Labeling:** Notes clearly define how "Peak response" and "Half-life" were calculated.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Local Projection Impulse Response Functions: Employment"
**Page:** 18
- **Formatting:** Colors (Blue/Red) are standard and distinguishable. Shaded CIs are clean.
- **Clarity:** High. The contrasting slopes (flat/negative vs. sharp V) are immediate.
- **Storytelling:** This is the primary visual evidence. 
- **Labeling:** Y-axis needs a more descriptive label. "$\beta$ (log employment response)" is technical; "Effect on Log Employment" is better.
- **Recommendation:** **REVISE**
  - Increase the font size of the axis tick labels; they are currently a bit small compared to the main text.
  - Fix the Legend: Panel A mentions "Bartik (robustness)" in green—this line is discussed in the appendix but clutters the main result here.

### Figure 2: "Peak-to-Trough Employment Declines by State"
**Page:** 19
- **Formatting:** Tile maps (hex-style) are superior to geographic maps for US states as they don't overemphasize large, sparsely populated western states.
- **Clarity:** High. The contrast between the "Sun Belt" hit in GR and the "Tourism/Industrial" hit in COVID is clear.
- **Storytelling:** Essential for showing the cross-sectional variation used for identification.
- **Labeling:** Color scales are well-labeled with percentage units.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Recession Exposure vs. Long-Run Employment Change"
**Page:** 19
- **Formatting:** Standard scatter plots with fits.
- **Clarity:** Good. It visually validates the regression results in Table 2.
- **Storytelling:** Shows the "raw" data behind the $h=48$ coefficients. 
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Model Calibration"
**Page:** 22
- **Formatting:** Professional.
- **Clarity:** Dividing into "Calibrated" and "Steady-state" is helpful.
- **Storytelling:** Shows the model is "disciplined" by real data (e.g., JOLTS, Shimer 2005).
- **Labeling:** "Target/Source" column is very well-documented.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Model vs. Data: Employment Paths After Demand and Supply Shocks"
**Page:** 23
- **Formatting:** Good overlay of model (solid) and data (dashed/markers).
- **Clarity:** A bit cluttered in Panel A because of the confidence intervals.
- **Storytelling:** Crucial "bridge" between the reduced-form and structural sections.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Counterfactual Employment Paths"
**Page:** 24
- **Formatting:** Good use of line styles (solid, dashed, dotted).
- **Clarity:** High.
- **Storytelling:** Directly tests the mechanism. Shows that "No scarring" significantly flattens the demand shock curve.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Welfare Losses from Demand vs. Supply Shocks: Model Counterfactuals"
**Page:** 25
- **Formatting:** Standard.
- **Clarity:** High.
- **Storytelling:** Provides the headline "147:1" welfare cost ratio.
- **Labeling:** Notes define "Consumption-equivalent (CE)" clearly.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Recovery Speed Maps: Months to Full Employment Recovery"
**Page:** 26
- **Formatting:** Tile maps consistent with Figure 2.
- **Clarity:** High. 
- **Storytelling:** Reinforces the "uniformity" of COVID recovery vs. the "heterogeneity" of GR recovery.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX** (The paper already has two main-text maps; this is a secondary robustness visual).

---

## Appendix Exhibits

### Table 6: "FRED Data Series"
**Page:** 37
- **Recommendation:** **KEEP AS-IS** (Excellent for reproducibility).

### Table 7: "Most and Least Affected States by Recession"
**Page:** 38
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Readers always want to see which states are driving the results; move this to Section 4.4).

### Figure 7: "Pre-Trend Event Study"
**Page:** 40
- **Recommendation:** **PROMOTE TO MAIN TEXT** (In a top journal like AER/QJE, showing flat pre-trends is a requirement for the main results section, not an appendix afterthought).

### Figure 8: "Aggregate Employment Paths"
**Page:** 41
- **Recommendation:** **PROMOTE TO MAIN TEXT** (This provides the macro context for the state-level results).

### Figure 9 / Table 8 / Table 9: "UR and LFPR Results"
**Page:** 42-44
- **Recommendation:** **KEEP IN APPENDIX** (Results are noisy/imprecise due to sample size; they support the story but shouldn't be the focal point).

### Figure 10: "JOLTS Labor Market Flows"
**Page:** 45
- **Recommendation:** **KEEP IN APPENDIX** (Good supporting evidence for the mechanism).

### Figure 12: "Welfare Decomposition"
**Page:** 47
- **Recommendation:** **REVISE** (Change from a bar chart to a pie chart or a simple table; a bar chart with only 4 bars is inefficient use of space).

### Table 10 / 11 / 12 / 13 / 14: "Robustness Tables"
**Page:** 48-52
- **Recommendation:** **KEEP IN APPENDIX** (Standard robustness checks).

---

## Overall Assessment

- **Exhibit count:** 5 Main Tables, 6 Main Figures, 11 Appendix Tables, 7 Appendix Figures.
- **General quality:** Extremely high. The exhibits are clearly produced using a consistent aesthetic (likely R/ggplot2 or Stata with a custom scheme). They mirror the style of the "Top 5" journals.
- **Strongest exhibits:** Figure 1 (Main IRF) and Table 3 (Half-life summary).
- **Weakest exhibits:** Figure 6 (redundant map) and Table 2 (missing labels for empty COVID cells).
- **Missing exhibits:** A **"Figure 0" or Figure 1 Conceptual Diagram** showing the DMP model flow (U $\to$ E $\to$ O) would help readers visualize the "scarring" and "participation" margins before they see the equations.

### Top 3 Improvements:
1. **Rearrange for identification:** Promote **Figure 7 (Pre-trends)** and **Figure 8 (Aggregate paths)** to the main text. Top journals demand seeing the validity of the research design (pre-trends) up front.
2. **Consolidate Geography:** Keep Figure 2 in the main text but move Figure 6 to the appendix. One set of maps is enough to make the point about geographic variation.
3. **Refine Table 2:** Add "Mean of Dependent Variable" and better "N/A" indicators to the COVID panels to make the table look "full" and professionally finished.