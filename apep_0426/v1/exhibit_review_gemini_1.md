# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T14:16:21.332440
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 1715 out
**Response SHA256:** 0cf24e820040e034

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by MGNREGA Phase"
**Page:** 10
- **Formatting:** Clean and professional. Proper use of horizontal rules (booktabs style). Number alignment is good.
- **Clarity:** Excellent. The comparison across the three rollout phases clearly shows the "backwardness" selection gradient.
- **Storytelling:** Essential. It justifies the need for the empirical strategies (like Callaway-Sant’Anna or controls) by showing how different the treatment groups are at baseline.
- **Labeling:** Clear. The notes explain the N and the logic of the index.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of MGNREGA on District Nightlights"
**Page:** 13
- **Formatting:** Generally strong. However, the "Callaway-Sant’Anna ATT" row is floating between the coefficients and the FE indicators, which is slightly unconventional.
- **Clarity:** The juxtaposition of four different estimators in one table is very effective for the "fragility" argument. 
- **Storytelling:** This is the central "punchline" table of the paper.
- **Labeling:** Good. Significance stars are defined. Clustering is noted.
- **Recommendation:** **REVISE**
  - Move the "Callaway-Sant'Anna ATT" to its own panel or clearly separate it from the TWFE coefficients. Currently, it looks like a row that only applies to a specific column, but it spans the width.
  - Decimal-align the numbers in Column 4 (Sun-Abraham) to ensure the minus sign doesn't disrupt vertical alignment.

### Figure 1: "Dynamic Treatment Effects of MGNREGA on Nightlights (Callaway-Sant’Anna)"
**Page:** 15
- **Formatting:** Standard "clean" ggplot style. The shaded confidence interval is readable.
- **Clarity:** High. The 10-year pre-period and 15-year post-period are clearly demarcated.
- **Storytelling:** Crucial for showing the lack of pre-trends and the persistent null effect in the long run.
- **Labeling:** Y-axis and X-axis are clearly labeled.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Treatment Effects by MGNREGA Cohort"
**Page:** 16
- **Formatting:** Slightly sparse. The red dots/lines are very thin.
- **Clarity:** It only shows Phase I and II. The text explains that Phase III is the comparison, but the figure feels "empty" with only two points.
- **Storytelling:** Redundant with Figure 1 and Table 2. The variation by cohort is already discussed.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 3: "District Nightlight Trends by MGNREGA Phase"
**Page:** 17
- **Formatting:** Good use of colors and shaded CIs. 
- **Clarity:** The raw data "spaghetti" nature is controlled well by showing means and CIs.
- **Storytelling:** Very important for "visual DiD." It shows that while levels differ, the slopes are remarkably similar across the entire 30-year window.
- **Labeling:** Vertical dashed lines for treatment years are helpful.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "MGNREGA and Structural Transformation (Census 2001–2011)"
**Page:** 18
- **Formatting:** Professional.
- **Clarity:** Simple 3-column OLS.
- **Storytelling:** Provides the secondary outcome (Census data) to support the nightlight null. 
- **Labeling:** Delta ($\Delta$) notation is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Heterogeneous Effects by Baseline Development"
**Page:** 18
- **Formatting:** Standard.
- **Clarity:** Clear, but would be more impactful as a coefficient plot.
- **Storytelling:** Supports the "no systematic pattern" argument.
- **Labeling:** Quartiles are clearly defined in the notes.
- **Recommendation:** **REMOVE** (Redundant with Figure 4, which is more effective).

### Figure 4: "MGNREGA Effects by Baseline Development Level"
**Page:** 19
- **Formatting:** Clean.
- **Clarity:** High. Shows the wide CIs for the poorest districts (Q1).
- **Storytelling:** Better than Table 4 for showing that even though some point estimates are larger, the lack of precision and lack of trend are the main stories.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "MGNREGA Phase Assignment by District Backwardness"
**Page:** 21
- **Formatting:** Very professional bar chart.
- **Clarity:** Immediately shows how the 200/130/310 split was applied to the index.
- **Storytelling:** Visual proof of the "mechanical" assignment process described in the text.
- **Labeling:** Excellent.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 6: "Structural Transformation by MGNREGA Phase"
**Page:** 31
- **Formatting:** Standard boxplot.
- **Clarity:** High.
- **Storytelling:** Good supporting evidence for the Census results in Table 3.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Additional Robustness Checks"
**Page:** 32
- **Formatting:** Uses Panels A, B, and C effectively.
- **Clarity:** Combines three very different things (Placebo, IHS, Bacon).
- **Storytelling:** Necessary for the "staggered DiD" robustness checklist (especially the Bacon decomposition).
- **Labeling:** Good notes.
- **Recommendation:** **KEEP AS-IS** (Consider promoting Panel A's Placebo result to the main text if space allows, as it's a major part of the identification discussion).

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 5 main figures, 1 appendix table, 1 appendix figure.
- **General quality:** Extremely high. The exhibits look ready for a top-tier journal (AER/QJE style). The use of the `Callaway-Sant'Anna` and `Sun-Abraham` estimators is visualized exactly as reviewers currently expect.
- **Strongest exhibits:** Figure 1 (Event Study), Figure 3 (Raw Trends), and Figure 5 (Phase Assignment).
- **Weakest exhibits:** Figure 2 (too sparse) and Table 4 (redundant with Figure 4).
- **Missing exhibits:** 
    1. **A Map:** A paper on India's district-level rollout almost requires a map showing Phase I, II, and III districts to check for spatial clustering/spillovers.
    2. **State-level Heterogeneity:** The paper mentions that some states (Andhra Pradesh, Rajasthan) had much higher take-up. A figure showing the ATT for "High-Implementation States" vs. others would be a very strong addition.
- **Top 3 improvements:**
  1. **Add a Map:** Visualize the geographic distribution of the phases.
  2. **Consolidate Heterogeneity:** Use Figure 4 in the main text and move Table 4 to the appendix.
  3. **Clarify Table 2:** Fix the layout of the "Callaway-Sant'Anna ATT" row so it doesn't look like it belongs to the TWFE specification. Add a horizontal line to separate the estimators into distinct panels.