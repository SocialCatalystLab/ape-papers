# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T18:33:58.057427
**Route:** Direct Google API + PDF
**Tokens:** 22037 in / 1940 out
**Response SHA256:** cb8d65ca1265d925

---

This review evaluates the exhibits for "Guaranteed Work or Guaranteed Stagnation? MGNREGA and Structural Transformation in Rural India." The paper targets top-tier economics journals.

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Baseline District Characteristics (Census 2001)"
**Page:** 10
- **Formatting:** Generally professional. Uses booktabs-style horizontal rules. Decimal alignment is decent but could be tighter (e.g., standard deviations in parentheses are often preferred over separate columns for a cleaner look).
- **Clarity:** Logical grouping. Clearly distinguishes between treatment (Phase I) and control (Phase III).
- **Storytelling:** Essential. It immediately justifies the need for the parallel trends analysis by showing how different the districts are in levels.
- **Labeling:** Clear. Units (000s) and definitions (Non-farm share) are present.
- **Recommendation:** **REVISE**
  - Place standard deviations in parentheses below means to save horizontal space and follow AER/QJE conventions.
  - Add a "Phase I vs. Phase III" difference-in-means column with t-stats or p-values to quantify the baseline imbalance.

### Table 2: "Effect of MGNREGA on Worker Composition: Phase I vs Phase III Districts"
**Page:** 14
- **Formatting:** Clean. Uses significance stars correctly. Includes CI which is helpful but rare in main AER tables (usually just SE).
- **Clarity:** The juxtaposition of post-treatment estimates with pre-trend test results in the same table is excellent. 
- **Storytelling:** This is the "money table" of the paper. It shows the null on non-farm and the shift within agriculture.
- **Labeling:** Standard errors in parentheses noted. Stars defined.
- **Recommendation:** **KEEP AS-IS** (Consider removing the CI row if space becomes an issue; SEs are sufficient).

### Figure 1: "MGNREGA Rollout by Phase"
**Page:** 16
- **Formatting:** Modern "ggplot2" aesthetic. The colors are distinct.
- **Clarity:** It is a simple bar chart. The count is clear.
- **Storytelling:** **LOW VALUE.** A bar chart of sample sizes (N=200, 130, 300) is better communicated in text or a table. 
- **Recommendation:** **REMOVE / REPLACE**
  - Replace this bar chart with a **Map of India** showing the spatial distribution of Phase I, II, and III districts. For a paper on India, a map is the standard "Figure 1" to show the geographic variation of the rollout.

### Figure 2: "Worker Composition by Phase, 1991–2011"
**Page:** 17
- **Formatting:** Uses stacked bars. Colors are distinguishable.
- **Clarity:** Hard to see small changes in shares over time using stacked bars. The "Non-Farm" blue section looks almost identical across years.
- **Storytelling:** Redundant with Figure 3. Stacked bars are generally discouraged in top journals for showing precise DiD shifts.
- **Recommendation:** **REMOVE** (Figure 3 tells the story much more precisely).

### Figure 3: "Pre-Trend Analysis: Phase I vs. Phase III Districts"
**Page:** 18
- **Formatting:** Good use of paneling (A and B).
- **Clarity:** The diverging trends in Panel A are immediately obvious. The parallel trends in Panel B are also clear.
- **Storytelling:** High impact. This is the primary diagnostic for the paper's identification strategy.
- **Labeling:** Axis labels and legends are clear.
- **Recommendation:** **REVISE**
  - The y-axis scales are very wide (20-60%). Consider narrowing the range or using a "Change from 1991" relative scale to make the slopes more visible.

### Figure 4: "Nightlights Event Study: Sun-Abraham Interaction-Weighted Estimates"
**Page:** 19
- **Formatting:** Professional. Dashed lines for 0 and treatment year.
- **Clarity:** Clean. The 95% CI is clearly visible.
- **Storytelling:** Vital. It uses higher-frequency data to check the annual evolution.
- **Labeling:** Y-axis is log nightlights. X-axis is event time.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Effect of MGNREGA on Nightlights: Callaway-Sant’Anna and Sun-Abraham Estimates"
**Page:** 20
- **Formatting:** Simple and effective.
- **Clarity:** High. Compares three different estimators in one view.
- **Storytelling:** Important for the "Nightlights" section, but could be consolidated.
- **Recommendation:** **REVISE**
  - This table could be merged with Table 2 as a final column/panel or moved to the Appendix, as the visual Figure 4 is more compelling for the main text.

### Table 4: "Robustness Checks: Alternative Comparisons and Heterogeneity"
**Page:** 21
- **Formatting:** Uses a Panel structure (Panel A).
- **Clarity:** Logical grouping of checks.
- **Storytelling:** Supports the "null" on structural transformation by showing it doesn't appear in other specs.
- **Recommendation:** **REVISE**
  - Add "Mean of Dep Var" to the bottom of the table to help the reader interpret the magnitude of the coefficients.

### Figure 5: "Randomization Inference: Distribution of Permuted Estimates"
**Page:** 22
- **Formatting:** Standard histogram with "Observed" line.
- **Clarity:** High.
- **Storytelling:** Addresses the small-cluster (31 states) concern.
- **Recommendation:** **MOVE TO APPENDIX** (Standard procedure in AER/QJE: keep RI figures in the appendix unless they are the primary source of inference).

### Figure 6: "Heterogeneity by Baseline Non-Farm Share"
**Page:** 23
- **Formatting:** Coefficient plot. Clean.
- **Clarity:** Very high. Easy to see the "High Baseline" result is the only one with a signal.
- **Storytelling:** Good for mechanism discussion.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Nightlights Trends by Phase, 1994–2013"
**Page:** 26
- **Formatting:** Line plot with implementation markers.
- **Clarity:** A bit cluttered with three lines and multiple dashed vertical lines.
- **Storytelling:** Redundant with the Event Study (Fig 4). Raw trends are less informative than the estimated ATT.
- **Recommendation:** **REMOVE**

---

## Appendix Exhibits

### Table 5: "Effect of MGNREGA on Female Non-Farm Worker Share"
**Page:** 39
- **Formatting:** Sparse. Only one column.
- **Recommendation:** **REVISE**
  - Expand this into a full "Gender Heterogeneity" table with three columns: (1) Men, (2) Women, (3) Difference (or Pooled with Interaction). Showing just women makes the reader wonder about the men.

---

# Overall Assessment

- **Exhibit count:** 4 main tables, 7 main figures, 1 appendix table, 0 appendix figures.
- **General quality:** The tables are very strong and follow AER style guidelines closely. The figures are high-quality but there are too many (7) in the main text, several of which are redundant.
- **Strongest exhibits:** Table 2 (Main Results) and Figure 4 (Event Study).
- **Weakest exhibits:** Figure 1 (Bar chart of N) and Figure 2 (Stacked bars).
- **Missing exhibits:** 
    1. **A Map:** Essential for any district-level India paper. 
    2. **Event Study for Cultivators:** Since "Cultivator Share" is the cleanest result, an event study (even if only 3 points: 1991, 2001, 2011) or a coefficient plot showing the transition would be strong.

### Top 3 Improvements:
1.  **Consolidate Figures:** Remove Figure 1 (bar chart), Figure 2 (stacked bars), and Figure 7 (raw nightlight trends). Add a **Map of India** as Figure 1.
2.  **Table 1 Enhancement:** Add a "Difference (Phase I - Phase III)" column to the summary statistics to explicitly show the selection into treatment.
3.  **Gender Table Expansion:** Build out Table 5 to include both genders and a statistical test of the difference, then consider promoting it to the main text as it's a key mechanism.