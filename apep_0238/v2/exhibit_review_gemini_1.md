# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T14:35:40.040594
**Route:** Direct Google API + PDF
**Tokens:** 32957 in / 2105 out
**Response SHA256:** 54e314a2e50e22b5

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 14
- **Formatting:** Clean and professional. Use of horizontal rules is appropriate.
- **Clarity:** Logically grouped into Panel A (Panel data) and Panel B (Cross-sectional).
- **Storytelling:** Essential for establishing the scale of the shocks (e.g., COVID trough is ~2.6x deeper than GR).
- **Labeling:** Units are well-defined (thousands, %, log).
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Most and Least Affected States by Recession"
**Page:** 15
- **Formatting:** Standard journal format.
- **Clarity:** High. Provides necessary context for the geographic variation.
- **Storytelling:** Effectively illustrates the "Sun Belt" vs. "Leisure/Hospitality" exposure contrast.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Local Projection Estimates: Employment Response to Recession Exposure"
**Page:** 20
- **Formatting:** Professional. Standard errors in parentheses. Significance stars used correctly.
- **Clarity:** Logical progression across horizons ($h$).
- **Storytelling:** This is the "money table." It confirms the central thesis (persistent GR effects vs. transient COVID effects). 
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **REVISE**
  - Change "N 46 (GR) / 48 (COVID)" to its own row at the bottom.
  - Decimal-align the coefficients; currently, the minus signs for GR and positive values for COVID cause slight misalignment.

### Table 4: "Employment Persistence: Half-Lives and Recovery Measures"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** Excellent summary of complex IRF dynamics into digestible scalars.
- **Storytelling:** Crucial for the 10-second takeaway (45-month half-life vs 9-month half-life).
- **Labeling:** Notes define "Persistence ratio" clearly.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Local Projection Impulse Response Functions: Employment"
**Page:** 23
- **Formatting:** Professional coloring and shading.
- **Clarity:** Clear contrast between the blue (GR) and red (COVID) paths.
- **Storytelling:** The most impactful visual in the paper.
- **Labeling:** Y-axis clearly labeled as "$\beta$ (log employment response)". 
- **Recommendation:** **REVISE**
  - In Panel A, the green line "Bartik (robustness)" is distracting. This figure should focus on the *comparison* between the primary instruments. Move the GR Bartik comparison to the Appendix to keep the main story focused on "Demand vs. Supply."

### Figure 2: "Local Projection IRFs: Unemployment Rate and Labor Force Participation Rate"
**Page:** 24
- **Formatting:** Multi-panel layout is good.
- **Clarity:** Panels are a bit small; the "1-SD effect" text on the Y-axis is somewhat cramped.
- **Storytelling:** Supports the mechanism (scarring via participation).
- **Labeling:** Clear distinction between pp (percentage points) and log.
- **Recommendation:** **REVISE**
  - Increase the font size for axis labels.
  - Use a consistent Y-axis scale across Panel C and D if possible to show the relative magnitude of the participation drop more clearly.

### Figure 3: "Peak-to-Trough Employment Declines by State"
**Page:** 25
- **Formatting:** Tile maps (square bins) are cleaner than geographic maps for US states as they don't over-emphasize large, empty western states.
- **Clarity:** Excellent.
- **Storytelling:** Shows the "Sun Belt" vs "Tourism" geographic shock origin.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Recession Exposure vs. Long-Run Employment Change"
**Page:** 25
- **Formatting:** Professional scatter plots.
- **Clarity:** High.
- **Storytelling:** Provides "raw data" transparency for the $h=48$ result in Table 3.
- **Labeling:** State abbreviations on points (or at least outliers) would be helpful.
- **Recommendation:** **REVISE**
  - Add state labels to the most extreme outliers (NV, AZ, HI, MI) to bridge the gap with Table 2.

### Figure 5: "Aggregate Employment Paths: Great Recession vs. COVID"
**Page:** 26
- **Formatting:** Standard macro time-series plots.
- **Clarity:** High.
- **Storytelling:** Sets the stage for why the state-level variation is needed.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is standard descriptive data. The paper's contribution is the *cross-state* identification. Moving this to the appendix would allow the more innovative Figure 1 and 3 to appear earlier.

### Figure 6: "JOLTS Labor Market Flows: Great Recession vs. COVID"
**Page:** 29
- **Formatting:** 2x2 grid is standard.
- **Clarity:** Legend is needed within the plots (Blue/Red shading is explained in notes, but in-plot labels are better).
- **Storytelling:** Vital for the "Mechanism" section.
- **Recommendation:** **REVISE**
  - Add a small legend or annotation "GR" and "COVID" directly over the shaded regions.

### Table 5: "Model Calibration"
**Page:** 32
- **Formatting:** Standard.
- **Clarity:** Good separation of parameters and outcomes.
- **Storytelling:** Shows the model is "disciplined" by data.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Model vs. Data: Employment Paths After Demand and Supply Shocks"
**Page:** 34
- **Formatting:** Solid vs. dashed lines work well.
- **Clarity:** Very high.
- **Storytelling:** The "validation" exhibit.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Counterfactual Employment Paths"
**Page:** 35
- **Formatting:** Line styles are distinct.
- **Clarity:** The legend is a bit busy.
- **Storytelling:** Key for the "Skill Depreciation" claim.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Welfare Losses from Demand vs. Supply Shocks: Model Counterfactuals"
**Page:** 36
- **Formatting:** Professional.
- **Clarity:** High.
- **Storytelling:** Quantifies the "Staggering" asymmetry mentioned in the text.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Welfare Decomposition: Demand Shock"
**Page:** 37
- **Formatting:** Bar chart is clean.
- **Clarity:** High.
- **Storytelling:** Redundant with Table 6. 
- **Recommendation:** **REMOVE**
  - Table 6 already provides these numbers. The bar chart doesn't add a new dimension of understanding.

---

## Appendix Exhibits

### Table 7: "FRED Data Series"
**Page:** 53
- **Recommendation:** **KEEP AS-IS** (Essential for replication).

### Table 8/9: "Unemployment/LFPR Response"
**Page:** 56-57
- **Recommendation:** **KEEP AS-IS** (Supports Figure 2).

### Figure 10: "Cross-Recession Comparison and Placebo Tests"
**Page:** 39 (Main text location but Appendix style)
- **Recommendation:** **MOVE TO APPENDIX**
  - It’s a robustness check. Keep the main text focused on results.

### Figure 11: "Recovery Speed Maps"
**Page:** 40
- **Recommendation:** **KEEP AS-IS**

### Tables 10-14: "Robustness and Sensitivity"
**Pages:** 58-60
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 5 Main Tables, 9 Main Figures, 8 Appendix Tables, 1 Appendix Figure.
- **General quality:** Extremely high. The exhibits look like they belong in a top-5 journal. The use of tile maps and standardized IRFs is modern and effective.
- **Strongest exhibits:** Figure 1 (IRF comparison) and Table 4 (Persistence measures).
- **Weakest exhibits:** Figure 9 (Redundant) and Figure 5 (Descriptive).
- **Missing exhibits:** A **theoretical schematic** or "Flow Diagram" of the DMP model with the new "Scarring" and "Participation" boxes would help readers visualize the math on pages 8–10.

### Top 3 Improvements:
1. **Consolidate Figure 1:** Remove the "Robustness" line from the main result figure to maximize the visual impact of the GR vs. COVID contrast.
2. **Streamline Main Text:** Move Figure 5 (Aggregate Paths) and Figure 10 (Placebo) to the Appendix to reduce clutter and speed up the arrival at the identification strategy.
3. **Enhance Labeling:** Add state-level annotations to the scatter plots in Figure 4 to help readers connect the regression results to specific famous examples (e.g., Nevada).