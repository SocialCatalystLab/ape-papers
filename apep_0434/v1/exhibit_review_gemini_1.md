# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T15:32:46.984024
**Route:** Direct Google API + PDF
**Tokens:** 20477 in / 2127 out
**Response SHA256:** 8e1de43c695f5f31

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by MGNREGA Phase"
**Page:** 11
- **Formatting:** Clean and professional. Use of horizontal rules is appropriate (Booktabs style). Numbers are readable.
- **Clarity:** Excellent. The grouping by Phase I, II, and III allows for immediate comparison of the "backwardness" selection criteria.
- **Storytelling:** Strong. Panel A establishes the selection challenge (Phase I is clearly different), while Panel B provides the raw "delta" motivating the more complex regressions.
- **Labeling:** Clear. The note explains the phase timing and the unit of analysis (unweighted village-level).
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Callaway-Sant’Anna Event Study: Effect of MGNREGA on Log Nightlight Intensity"
**Page:** 15
- **Formatting:** Modern and clean. The contrast between pre-treatment and post-treatment areas (shaded vs. white background) is effective. 
- **Clarity:** High. The 10-second takeaway is clear: there is a jump at $t=0$, but also a visible downward pre-trend.
- **Storytelling:** Vital to the paper. It addresses the "paradox" mentioned in the abstract.
- **Labeling:** The y-axis "ATT (Log Nightlights)" is standard. The note is thorough regarding standard errors and the comparison group.
- **Recommendation:** **REVISE**
  - The pre-trend is the most controversial part of this figure. Add a linear fit line to the pre-treatment points to visually highlight the slope mentioned in the text (Section 6.1).
  - Explicitly label the $n$ (number of districts) in the figure note to give a sense of the power behind the CIs.

### Figure 2: "Pre-Treatment Nightlight Trends by MGNREGA Phase"
**Page:** 16
- **Formatting:** Clear line weights and distinguishable colors.
- **Clarity:** A bit cluttered due to the overlapping lines.
- **Storytelling:** This figure is somewhat redundant with Figure 1. While it shows the raw levels, the pre-trend issue is already captured more rigorously by the CS estimator in Figure 1.
- **Labeling:** Labels are correct.
- **Recommendation:** **MOVE TO APPENDIX**
  - Main text should focus on the causal/event-study estimates. The raw trends are supporting evidence for why the pre-trend in Fig 1 exists (convergence), but they don't need to be in the main flow.

### Table 2: "Effect of Early MGNREGA on Worker Composition (Census 2001–2011)"
**Page:** 17
- **Formatting:** **Issues found.** Variable names like `d_nonfarm_share` and `pc11_state_id` are raw code names. These must be replaced with "Clean Labels" (e.g., "$\Delta$ Non-Farm Share"). 
- **Clarity:** Logical layout. Columns 1 and 2 show the effect of adding controls, which is standard.
- **Storytelling:** This is the "Main Result" table. It anchors the paper’s argument.
- **Labeling:** Significance stars are present. Standard errors are clustered appropriately.
- **Recommendation:** **REVISE**
  - **CRITICAL:** Replace all LaTeX/Stata variable stubs (`d_nonfarm_share`, `d_aglabor_share`, etc.) with descriptive English labels.
  - The "Dependent variable mean" row should specify if it refers to the mean *change* or the mean *baseline level*. Given the values (0.008), it seems to be the mean change; clarify this in the label.

### Figure 3: "Worker Composition Changes by MGNREGA Phase"
**Page:** 19
- **Formatting:** Standard bar chart. 
- **Clarity:** Clear, though the "Non-Farm" and "HH Industry" bars are very small, making the 10-second parse difficult for those specific outcomes.
- **Storytelling:** Good for visualizing the raw differences across phases before the regression controls.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Consider a "Small Multiples" approach or changing the scale. The "Cultivators" and "Ag Labor" bars dwarf the others, hiding the variation in the "Non-Farm" results which is the paper's primary focus.

### Table 3: "Gender Heterogeneity in MGNREGA Effects"
**Page:** 20
- **Formatting:** Same issues as Table 2 regarding raw variable names (`d_f_nonfarm_share`).
- **Clarity:** Good. It isolates the most striking finding of the paper.
- **Storytelling:** Essential. It explains *who* is trapped in the "comfortable trap."
- **Labeling:** Descriptive.
- **Recommendation:** **REVISE**
  - Clean the variable names (e.g., "$\Delta$ Female Non-Farm Share").
  - Add a "Male" counterpart column or a "Difference (Female - Male)" column to statistically confirm the "starkly gendered" claim in the abstract.

### Figure 4: "Gender Decomposition of MGNREGA Effects on Worker Composition"
**Page:** 21
- **Formatting:** Professional side-by-side bar comparison.
- **Clarity:** Excellent. The 95% CI bars make the comparison between male and female impacts immediate.
- **Storytelling:** Strongest visual evidence in the paper for the gendered impact.
- **Labeling:** Title and notes are thorough.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Caste Heterogeneity: SC/ST Interaction"
**Page:** 22
- **Formatting:** Clean, but again uses raw code stubs (`Early x High SC/ST`).
- **Clarity:** Logical triple-difference structure.
- **Storytelling:** Important nuance to the "trap" hypothesis—showing that for some, it's a "stepping stone."
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Rename `High SC/ST` to "Above Median SC/ST Share."
  - Explicitly state in the note what the "net effect" for SC/ST villages is (calculated as sum of coefficients).

### Figure 5: "Caste Heterogeneity: MGNREGA Effects by SC/ST Population Share"
**Page:** 23
- **Formatting:** Consistent with earlier figures.
- **Clarity:** High.
- **Storytelling:** Redundant with Table 4. Table 4 provides the significance and coefficients; Figure 5 visualizes the raw changes.
- **Recommendation:** **REMOVE** (or move to Appendix). Figure 3 already shows raw changes by phase. Having both Table 4 and Figure 5 in the main text is repetitive.

### Figure 6: "Dose-Response: MGNREGA Effects on Non-Farm Worker Share by Phase"
**Page:** 24
- **Formatting:** Point-and-whisker plot.
- **Clarity:** Clear, but the Phase II CI crosses zero, which the author should emphasize.
- **Storytelling:** Supports the causal claim by showing effects grow with exposure.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness Checks"
**Page:** 25
- **Formatting:** Consistent with other tables.
- **Clarity:** Good use of columns to show different specifications.
- **Storytelling:** Necessary for top journals to show stability across clustering levels and placebo tests.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits
*Note: The author states in Section E (Page 37) that "No additional figures or tables beyond those presented in the main text" are included. This is a missed opportunity for a top-tier journal submission.*

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 6 main figures, 0 appendix tables, 0 appendix figures.
- **General quality:** The visual exhibits are technically proficient (likely R/ggplot2) but suffer from "code-speak" in the tables (e.g., `d_nonfarm_share`).
- **Strongest exhibits:** Figure 4 (Gender Decomposition) and Table 1 (Summary Stats).
- **Weakest exhibits:** Figure 2 (Redundant) and Figure 5 (Redundant with Table 4).
- **Missing exhibits:** 
    1. **District Map:** A map showing Phase I, II, and III districts is standard for Indian development papers (AER/QJE style) to show geographic clustering/identification.
    2. **Balance Plot:** A visual representation of Table 1's balance across phases.
    3. **Robustness Appendix:** Most papers in this tier have 10+ appendix tables (different lags, alternate controls, excluding specific states).

- **Top 3 improvements:**
  1. **Clean Table Labels:** Immediately replace all `d_variable_name` and `pc11_` stubs with publication-quality English labels. Top journals will reject based on "raw output" aesthetics.
  2. **Consolidate/Reduce Redundancy:** Move Figure 2 and Figure 5 to the Appendix. They repeat information already contained in Figures 1 and Table 4.
  3. **Add a Geographic Map:** A figure showing the spatial rollout of MGNREGA is essential for the reader to understand the "backwardness" geography described in the text.