# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-15T00:29:58.479847
**Route:** Direct Google API + PDF
**Tokens:** 33477 in / 2342 out
**Response SHA256:** 18a7d6c88f783b93

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 12
- **Formatting:** Clean and professional. Follows standard booktabs style. Numbers are decimal-aligned.
- **Clarity:** Excellent. Separating state-month panel from cross-sectional exposure measures in Panel A/B is logical.
- **Storytelling:** Provides necessary context on the magnitude of the shocks (COVID shock was 2.6x larger than GR).
- **Labeling:** Clear. Units (thousands, %, log) are specified.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Local Projection Estimates: Employment Response to Recession Exposure"
**Page:** 17
- **Formatting:** Standard journal format. Includes multiple p-value types (permutation, wild bootstrap) which signals high-quality inference.
- **Clarity:** High. Horizontal structure for time horizons ($h$) is standard for LP papers.
- **Storytelling:** This is the "hero" table of the paper. It clearly shows the persistence in Panel A vs. the snap-back in Panel B.
- **Labeling:** "negative $\beta_h$ indicates... larger employment declines" in the notes is helpful for interpretation.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "First Stage: Saiz Housing Supply Elasticity vs. Housing Price Boom"
**Page:** 19
- **Formatting:** Scatter plot is professional; labels for specific states (e.g., NV, FL) add useful context.
- **Clarity:** Clear message—strong negative relationship.
- **Storytelling:** Essential for validating the housing price instrument. 
- **Labeling:** The x-axis "Negated Saiz supply elasticity" is slightly confusing. It's better to use the raw elasticity and show a positive slope, or label it "Housing Supply Constraint (Inversed Elasticity)".
- **Recommendation:** **REVISE**
  - Clarify the x-axis label. If it is "Negated", explicitly state "Higher values = More Constrained".

### Table 3: "Instrumental Variable Estimates: Saiz Housing Supply Elasticity"
**Page:** 19
- **Formatting:** Consistent with Table 2.
- **Clarity:** Good use of OLS vs 2SLS comparison.
- **Storytelling:** Important for causal identification. However, it only shows the Great Recession.
- **Labeling:** AR 95% CI is correctly identified as being robust to weak instruments.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Employment Persistence: Half-Lives and Recovery Measures"
**Page:** 20
- **Formatting:** Concise summary table.
- **Clarity:** Quickly summarizes the complicated dynamics from Table 2.
- **Storytelling:** This is a "Value-Add" table that helps the reader digest the 10-column Table 2.
- **Labeling:** Definitions in notes are precise.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Local Projection Impulse Response Functions: Employment"
**Page:** 21
- **Formatting:** Beautiful side-by-side IRFs. Colors (Blue/Red) are standard and distinguishable.
- **Clarity:** The key finding (scarring vs. no scarring) is visible in 5 seconds.
- **Storytelling:** The most important visual in the paper.
- **Labeling:** Y-axis label "$\beta$ (log employment response)" is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Peak-to-Trough Employment Declines by State"
**Page:** 22
- **Formatting:** Tile-grid map (hex-style) is superior to a standard map because it gives equal visual weight to small Northeastern states.
- **Clarity:** Color scale is intuitive (Red = Loss).
- **Storytelling:** Shows the geographic variation used for identification.
- **Labeling:** Titles and legends are clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Recession Exposure vs. Long-Run Employment Change"
**Page:** 22
- **Formatting:** Clean scatter plots.
- **Clarity:** Shows the "reduced form" relationship at $h=48$.
- **Storytelling:** This is essentially a cross-sectional "slice" of Figure 2. It's a bit redundant but good for showing the raw data underlying the LPs.
- **Recommendation:** **MOVE TO APPENDIX**
  - The IRFs in Figure 2 already tell this story. This adds bulk to the main text without changing the takeaway.

### Figure 5: "JOLTS Labor Market Flows: Great Recession vs. COVID"
**Page:** 24
- **Formatting:** 4-panel time series.
- **Clarity:** Good use of shaded recession bars.
- **Storytelling:** Provides the "Demand" vs "Supply" evidence via quits/layoffs.
- **Labeling:** Y-axes are in "Thousands"; would be more standard in macro to show "Rate (% of employment)" to account for trend growth in the labor force over 20 years.
- **Recommendation:** **REVISE**
  - Convert y-axis from raw counts (thousands) to rates (percentage of total employment).

### Table 5: "Mechanism Test: Unemployment Rate Persistence by Recession Type"
**Page:** 26
- **Formatting:** Consistent with previous tables.
- **Clarity:** The "Per 1-SD Bartik shock" row is excellent for comparing magnitudes across instruments.
- **Storytelling:** Directly tests the duration/scarring mechanism.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Mechanism Flow: Demand vs. Supply Recession Pathways"
**Page:** 27
- **Formatting:** Flowchart style.
- **Clarity:** Very clear.
- **Storytelling:** Useful for a "theory" section, though top journals sometimes find these too "textbook-like."
- **Recommendation:** **KEEP AS-IS** (but consider moving to a presentation slide rather than the paper if space is tight).

### Table 6: "Model Calibration"
**Page:** 28
- **Formatting:** Standard macro-calibration table.
- **Clarity:** Separating parameters from steady-state targets is best practice.
- **Storytelling:** Documents the discipline of the structural model.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Model vs. Data: Employment Paths After Demand and Supply Shocks"
**Page:** 29
- **Formatting:** Overlays model on data.
- **Clarity:** Excellent. Shows the model captures the "overshooting" in GR.
- **Storytelling:** Validates the structural mechanism against the reduced-form results.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Counterfactual Employment Paths"
**Page:** 30
- **Formatting:** Multiple dashed/dotted lines.
- **Clarity:** Can become cluttered. The distinction between "No scarring" and "No OLF exit" is the key.
- **Storytelling:** Proves that skill depreciation (scarring) is the primary driver (58%).
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Welfare Losses from Demand vs. Supply Shocks: Model Counterfactuals"
**Page:** 31
- **Formatting:** Clean summary.
- **Clarity:** The 442.0 ratio is a "punchy" number for an abstract.
- **Storytelling:** The final "So What?" of the paper.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Recovery Speed Maps: Months to Full Employment Recovery"
**Page:** 32
- **Formatting:** Same hex-tile format as Figure 3.
- **Clarity:** Very clear.
- **Storytelling:** A different look at the data—focuses on "time to recovery" rather than "depth."
- **Recommendation:** **MOVE TO APPENDIX**
  - This is secondary to the LP results and the main text is getting exhibit-heavy (15+ exhibits).

---

## Appendix Exhibits

### Table 10: "Local Projection Estimates: Unemployment Rate Response"
**Page:** 51
- **Recommendation:** **KEEP AS-IS**

### Table 11: "Local Projection Estimates: Labor Force Participation Rate Response"
**Page:** 52
- **Recommendation:** **KEEP AS-IS**

### Figure 13: "Cross-Recession Comparison and Placebo Tests"
**Page:** 53
- **Storytelling:** This is a very strong figure. It shows the Great Recession effect is an "outlier" compared to random permutations.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This adds significant causal "heft" to the paper. It should replace Figure 4 or 9.

### Table 12: "Migration Decomposition: Employment vs. Employment-to-Population Ratio"
**Page:** 55
- **Storytelling:** Crucial robustness check for regional economics (ensures results aren't just people moving).
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 7 main tables, 9 main figures, 8 appendix tables, 2 appendix figures.
- **General quality:** Extremely high. The exhibits look like they belong in a top-5 journal. The use of hex-tile maps and multi-panel IRFs is modern and effective.
- **Strongest exhibits:** Figure 2 (IRFs), Table 2 (Main LPs), Figure 7 (Model fit).
- **Weakest exhibits:** Figure 5 (Raw counts vs. rates), Figure 1 (X-axis labeling).
- **Missing exhibits:** A **"Timeline of Shocks"** figure (e.g., house price peaks vs. COVID lockdown dates) could help readers who aren't experts on the specific timing of these two periods.

### Top 3 Improvements:
1. **Consolidate/Streamline Main Text:** Move Figure 4 (Scatter) and Figure 9 (Recovery Map) to the Appendix to reduce clutter. 
2. **Promote the Placebo Figure:** Move Figure 13 to the main text (perhaps as a third panel in Figure 2 or a standalone). It is your strongest evidence against "spurious" persistence.
3. **Normalize JOLTS (Figure 5):** Re-plot JOLTS as rates (percentage of total nonfarm payrolls) to make the Great Recession vs. COVID magnitudes more comparable over time.