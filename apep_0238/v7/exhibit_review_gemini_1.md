# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-15T09:32:26.079473
**Route:** Direct Google API + PDF
**Tokens:** 34517 in / 3009 out
**Response SHA256:** 36b070577535f4d2

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 12
- **Formatting:** Clean and professional. Uses standard booktabs-style horizontal lines. Number alignment is generally good, though "18,010.0" creates a wide Max column.
- **Clarity:** Very high. The separation between Panel A (Outcomes) and Panel B (Exposure) is logical.
- **Storytelling:** Essential. It establishes the scale of the shocks (COVID being 2.6x more severe at trough) which sets up the "puzzle" of the rapid recovery.
- **Labeling:** Good. Units are specified in the variable column. Notes are comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Bartik Decomposition: Rotemberg Weights by Industry"
**Page:** 15
- **Formatting:** Good. The inclusion of a sub-table ("Leave-one-out robustness") within the same exhibit is efficient but slightly unconventional for a main text table.
- **Clarity:** The top panel is very clear. The bottom panel (robustness) is a bit cramped.
- **Storytelling:** Critical for modern "Top 5" papers using Bartik instruments. It proves the result isn't driven solely by the Leisure & Hospitality sector.
- **Labeling:** Clear. Significance stars are defined.
- **Recommendation:** **REVISE**
  - Increase the whitespace between the Rotemberg Weights panel and the "Leave-one-out" panel to clarify they are distinct results.

### Table 3: "Local Projection Estimates: Employment Response to Recession Exposure"
**Page:** 18
- **Formatting:** Professional. Correctly uses parentheses for SEs, brackets for permutation p-values, and curly braces for wild bootstrap. This is "Econometrica-level" detail.
- **Clarity:** High, but very dense. The table contains four different types of inference indicators for every coefficient.
- **Storytelling:** The "Money Table" of the paper. It shows the diverging paths of GR (persistent) vs. COVID (transient).
- **Labeling:** Excellent. Notes explain the sign conventions and the different p-value types.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "First Stage: Saiz Housing Supply Elasticity vs. Housing Price Boom"
**Page:** 20
- **Formatting:** Standard scatter plot. The state abbreviations are a nice touch for readability.
- **Clarity:** Very clear. The "Slope" and "r" callout box is professional.
- **Storytelling:** Standard IV diagnostic. Validates the instrument.
- **Labeling:** Axis labels are clear and include units.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Instrumental Variable Estimates: Saiz Housing Supply Elasticity"
**Page:** 20
- **Formatting:** Standard. Decimal alignment is correct.
- **Clarity:** Clear, though it makes the text a bit redundant as it repeats the OLS row from Table 3.
- **Storytelling:** Important for exogeneity. It shows that even when instrumented with geography (Saiz), the scarring effect persists through 48 months.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Within–Great Recession Horse Race: Housing Demand vs. Industry Composition"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** Very high. It clearly shows the HPI coefficient "winning" over the Bartik coefficient.
- **Storytelling:** Crucial for identification. It rules out the idea that the GR was just a different "flavor" of industry shock.
- **Labeling:** Notes are excellent, specifically explaining why the GR Bartik coefficients are large but insignificant.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Employment Persistence: Half-Lives and Recovery Measures"
**Page:** 22
- **Formatting:** Simple and clean.
- **Clarity:** Excellent. This is a "Reader's Digest" version of the paper's main finding.
- **Storytelling:** Extremely effective. It quantifies the asymmetry in simple terms (60-month half-life vs. 9-month).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Consider promoting to the very start of the Results section).

### Figure 2: "Local Projection Impulse Response Functions: Employment"
**Page:** 23
- **Formatting:** Excellent use of colors (Blue/Red) to distinguish shocks. Shaded CIs are transparent enough.
- **Clarity:** The juxtaposition of the two panels makes the "ギターの弦" (guitar string) analogy from the intro immediately visible.
- **Storytelling:** The most important figure in the paper.
- **Labeling:** Y-axis needs more descriptive labeling.
- **Recommendation:** **REVISE**
  - The Y-axis label "$\beta$ (log employment response)" should be changed to "Effect on Log Employment (relative to peak)" to be more intuitive for a general reader.

### Figure 3: "Peak-to-Trough Employment Declines by State"
**Page:** 24
- **Formatting:** Uses a hex-bin/tile map style which is superior to standard choropleths because it gives equal visual weight to small NE states.
- **Clarity:** High. The contrast between the Sun Belt (GR) and Leisure-heavy states (COVID) is obvious.
- **Storytelling:** Establishes the geographic variation used for identification.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "JOLTS Labor Market Flows: Great Recession vs. COVID"
**Page:** 26
- **Formatting:** Standard time-series plots. The shading of recession windows is standard and helpful.
- **Clarity:** Four panels are a bit small.
- **Storytelling:** Vital for the "Mechanism" section. It shows the massive "Quits" surge in COVID that was absent in the GR.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Mechanism Test: Unemployment Rate Persistence by Recession Type"
**Page:** 27
- **Formatting:** Consistent with Table 3.
- **Clarity:** Clear.
- **Storytelling:** Essential evidence for the "Prolonged Unemployment" channel.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Mechanism Flow: Demand vs. Supply Recession Pathways"
**Page:** 28
- **Formatting:** Simple flowchart.
- **Clarity:** Very high.
- **Storytelling:** This is more of a "theory diagram" than a data exhibit. It helps summarize the model.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Though potentially better placed in the Model section than the Results section).

### Table 8: "Model Calibration"
**Page:** 29
- **Formatting:** Standard calibration table.
- **Clarity:** Panel A (Parameters) and Panel B (Moments) are the standard way to present this.
- **Storytelling:** Shows the model is "grounded" in US data (JOLTS, Shimer 2005).
- **Labeling:** Source column is very helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Model vs. Data: Employment Paths After Demand and Supply Shocks"
**Page:** 30
- **Formatting:** Good overlay of "Data" (markers) and "Model" (solid lines).
- **Clarity:** The CIs on the data points in Panel A are a bit wide and distract from the model fit.
- **Storytelling:** The "validation" figure. It shows the model captures the *asymmetry*, even if it over-predicts GR persistence.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - For Panel A, use a lighter shade for the data CI or use a "fan chart" style to make the model line more prominent.

### Figure 7: "Counterfactual Employment Paths"
**Page:** 31
- **Formatting:** Five lines on one plot. Colors and line styles (dashed, dotted) are used well.
- **Clarity:** A bit busy, but the "Blue Solid" vs "Blue Dashed" comparison is the key.
- **Storytelling:** This is the "So What?" of the model. It proves skill depreciation is the 58% driver.
- **Labeling:** Legend is descriptive.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Welfare Losses from Demand vs. Supply Shocks: Model Counterfactuals"
**Page:** 32
- **Formatting:** Simple.
- **Clarity:** Very high.
- **Storytelling:** Provides the "Headline" number (442:1 welfare cost).
- **Labeling:** CE Welfare Loss is defined in notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Permutation Inference: p-Values Across Horizons"
**Page:** 33
- **Formatting:** Bar chart of p-values.
- **Clarity:** Excellent. The horizontal lines for 0.05 and 0.01 make the "loss of significance" in the GR very clear.
- **Storytelling:** Robustness check for the small N=50 sample.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - While good, this is a technical robustness check. Table 3 already provides the p-values. This figure takes up a lot of space for a secondary point.

---

## Appendix Exhibits

### Table 10: "FRED Data Series"
- **Recommendation:** **KEEP AS-IS** (Standard documentation).

### Table 11: "Most and Least Affected States by Recession"
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Readers always want to know "Which states are driving this?" Putting the top 5 / bottom 5 in the main text (perhaps as a small table near Figure 3) adds "color" to the data.

### Figure 9: "Pre-Trend Event Study"
- **Recommendation:** **KEEP AS-IS** (Standard placement for pre-trends in the appendix).

### Figure 10: "Aggregate Employment Paths"
- **Recommendation:** **KEEP AS-IS** (Contextual, but not the main identification).

### Figure 11 & Table 12/13: "Unemployment and LFPR IRFs/Tables"
- **Recommendation:** **KEEP AS-IS** (The paper's main focus is employment; these are the necessary "deep dives" for mechanisms).

### Figure 12: "Recession Exposure vs. Long-Run Employment Change"
- **Recommendation:** **KEEP AS-IS** (Visual version of the Table 3 coefficients).

### Figure 13: "Recovery Speed Maps"
- **Recommendation:** **KEEP AS-IS** (Nice, but redundant with Figure 3).

### Figure 14: "Cross-Recession Comparison and Placebo Tests"
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This figure is very strong. It overlays the two recessions on a single scale. It is more impactful than Figure 2 because it accounts for the difference in shock size.

### Table 14: "Migration Decomposition"
- **Recommendation:** **KEEP AS-IS** (Standard robustness).

### Table 15: "Subsample Robustness"
- **Recommendation:** **KEEP AS-IS**.

### Table 16 / Figure 15: "Model Sensitivity"
- **Recommendation:** **REVISE/REMOVE**
  - Table 16 and Figure 15 contain the exact same information (Heatmap vs Grid). Figure 15 is visually unhelpful because all cells say ">120". Keep Table 16, remove Figure 15.

---

## Overall Assessment

- **Exhibit count:** 9 main tables, 8 main figures, 9 appendix tables, 7 appendix figures.
- **General quality:** Extremely high. The paper follows the "Mian & Sufi" style of clean, reduced-form evidence paired with a focused structural model. The tables are exceptionally detailed regarding inference.
- **Strongest exhibits:** Table 3 (Inference detail), Table 6 (Clarity of message), Figure 2 (Visual impact).
- **Weakest exhibits:** Figure 15 (Redundant and uninformative), Figure 8 (Too large for its contribution).
- **Missing exhibits:** A **"Model Schematic"** (Figure 5 is a flow chart of results, but a diagram showing the $E, U, O$ states and the $\lambda$ transition would help readers parse the math in Section 3).

**Top 3 improvements:**
1. **Consolidate and Promote:** Move Figure 14 (Cross-recession comparison) to the main text, replacing Figure 2 or placing it immediately after. It is the most "honest" comparison because it scales the shocks.
2. **Rationalize Robustness:** Move Figure 8 to the appendix. It is a visualization of numbers already in Table 3 and disrupts the flow of the Mechanisms section.
3. **Clarify Y-Axes:** Across all IRF figures (Fig 2, Fig 9, Fig 11), ensure Y-axis labels are consistent and use "natural language" (e.g., "Percentage Point Change") rather than Greek letters ($\beta$).