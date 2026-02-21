# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T12:09:14.641351
**Route:** Direct Google API + PDF
**Tokens:** 18917 in / 2063 out
**Response SHA256:** 79b3e27426b4dd54

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Villages Near PMGSY Threshold"
**Page:** 10
- **Formatting:** Clean and professional. Follows standard three-line table format. Decimal alignment is generally good, though the "Villages" row at the bottom is center-aligned rather than right-aligned with the number columns above.
- **Clarity:** Excellent. High-level comparison between treatment and control is easy to digest.
- **Storytelling:** Strong. It establishes covariate balance (or similarity) which is the bedrock of a credible RDD.
- **Labeling:** Variable names are intuitive. Notes are comprehensive, citing the data source (SHRUG) and defining the sample window.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Village Population Near the PMGSY Threshold"
**Page:** 13
- **Formatting:** Modern and clean. The red dashed line for the threshold is standard and effective.
- **Clarity:** High. The bins are appropriate for a sample of this size.
- **Storytelling:** Essential for an RDD to rule out manipulation (sorting) at the threshold.
- **Labeling:** Axis labels are clear. The inclusion of the McCrary test statistic directly in the plot area is excellent practice for top journals.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Covariate Balance at PMGSY Threshold"
**Page:** 14
- **Formatting:** Standard professional format.
- **Clarity:** Clear, but somewhat redundant with Table 1 and Figure 2.
- **Storytelling:** It formalizes the visual balance shown in Table 1 with actual RDD estimates.
- **Labeling:** Well-labeled.
- **Recommendation:** **REVISE**
  - **Specific Changes:** This table can be consolidated with Table 3 as "Panel B: Covariate Balance" or moved to the appendix. In top journals, editors often prefer a single "Main RDD Results" table where Panel A is outcomes and Panel B is covariates to save space.

### Figure 2: "Covariate Balance at the PMGSY Threshold"
**Page:** 14
- **Formatting:** Clear "coefficient plot" style.
- **Clarity:** High. 
- **Storytelling:** Redundant with Table 2. Most top journals (AER/QJE) prefer the table in the main text and the coefficient plot in the appendix, or vice versa, but rarely both in the main text for simple baseline covariates.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 3: "Main RDD Estimates: Effect of PMGSY Eligibility on Structural Transformation"
**Page:** 15
- **Formatting:** Good. It includes essential RDD metadata (Bandwidth, Polynomial, Kernel).
- **Clarity:** The "Eff. N" column is helpful to show how the bandwidth affects sample size.
- **Storytelling:** This is the "Money Table." It clearly shows the null results across all specifications.
- **Labeling:** Notes are excellent; they define the p-value calculation and significance stars.
- **Recommendation:** **KEEP AS-IS** (Consider merging Table 2 into this as a second panel).

### Figure 3: "RDD Plots: Roads and Gendered Structural Transformation"
**Page:** 16
- **Formatting:** Professional multi-panel layout. Shaded CIs are helpful.
- **Clarity:** Very high. The collinearity of the regression lines across the threshold makes the null result undeniable.
- **Storytelling:** This is the most important figure in the paper.
- **Labeling:** Y-axis labels are descriptive.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Dynamic RDD: Year-by-Year Effect of PMGSY Eligibility on Nightlights"
**Page:** 18
- **Formatting:** Excellent. The color-coding for Pre- vs Post-period is effective.
- **Clarity:** The shaded area correctly illustrates why the design fails for this specific outcome (pre-existing trend).
- **Storytelling:** Important for honesty in research. It shows where the RDD works (Census) and where it doesn't (Nightlights).
- **Labeling:** Very clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Robustness: Bandwidth and Polynomial Sensitivity"
**Page:** 19
- **Formatting:** Good use of panels to group different types of robustness tests.
- **Clarity:** The transition from Panel A (Bandwidth) to B (Polynomial) to C (Donut) is logical.
- **Storytelling:** Essential for a "precisely estimated null" paper to prove the result isn't a fluke of specification.
- **Labeling:** Notes are thorough.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Bandwidth Sensitivity: Female Non-Agricultural Share"
**Page:** 20
- **Formatting:** Standard sensitivity plot.
- **Clarity:** High.
- **Storytelling:** Redundant with Table 4, Panel A. 
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX** (The table provides the exact p-values which are more important for the "marginal significance" discussion in the text).

### Figure 6: "Placebo Threshold Tests: Female Non-Agricultural Share"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Powerful way to show the 500-cutoff result is within the "noise" of the data distribution.
- **Labeling:** Clear distinction between the true threshold and placebos.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Regional Heterogeneity in Road Effects on Structural Transformation"
**Page:** 22
- **Formatting:** Good side-by-side comparison of genders.
- **Clarity:** Logical grouping.
- **Storytelling:** Important to show the null isn't driven by one region cancelling out another.
- **Labeling:** Footnotes defining the states in each region are crucial and present.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Regional Heterogeneity in Road Effects on Structural Transformation"
**Page:** 22
- **Formatting:** Professional.
- **Clarity:** Redundant with Table 5.
- **Storytelling:** Visualizes the regional nulls.
- **Labeling:** Clear.
- **Recommendation:** **REMOVE** (Figure 9 in the appendix is an exact duplicate of this; keep the table in the main text and one version of this figure in the appendix).

---

## Appendix Exhibits

### Table 6: "Sample Construction"
**Page:** 30
- **Formatting:** Simple and clean.
- **Clarity:** Very high.
- **Storytelling:** Standard for top journals to show how the N of 500k+ was reached.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Appendix: Bandwidth Sensitivity Detail"
**Page:** 33
- **Formatting:** Duplicate of Figure 5.
- **Recommendation:** **REMOVE** (Keep the version moved from main text).

### Figure 9: "Appendix: Regional Heterogeneity Detail"
**Page:** 34
- **Formatting:** Duplicate of Figure 7.
- **Recommendation:** **KEEP AS-IS** (After removing the version from the main text).

---

## Overall Assessment

- **Exhibit count:** 5 Main Tables, 7 Main Figures, 1 Appendix Table, 2 Appendix Figures.
- **General quality:** Extremely high. The paper uses the `rdrobust` and `ggplot2` ecosystems effectively to produce "journal-ready" exhibits that match the aesthetic of the AEA journals.
- **Strongest exhibits:** Figure 3 (RDD Plots) and Table 3 (Main Estimates).
- **Weakest exhibits:** Figure 2 and Figure 5/8 (due to redundancy with tables).
- **Missing exhibits:** 
    - **First Stage Figure:** While the author cites Asher and Novosad (2020) for the first stage, a paper in *Econometrica* or *AER* would typically expect a "Figure 0" or Figure 1 showing the probability of a road existing at the 500-person threshold in the author's own sample (if data permits) to prove the "Intent-to-Treat" isn't an "Effect of Zero Treatment."
    - **Map:** A simple map of India showing the density of villages near the 500-person threshold would add nice "color" and spatial context.

- **Top 3 improvements:**
  1. **Reduce Redundancy:** Move the coefficient plot (Figure 2) and Bandwidth plot (Figure 5) to the appendix. They repeat data already present in Tables 2 and 4.
  2. **Consolidate Results:** Merge Table 2 (Covariate Balance) into Table 3 as a separate panel. This creates a "One-Stop-Shop" table for the RDD's validity and main findings.
  3. **Visual First Stage:** Even if using secondary data, a figure showing the "jump" in road connectivity at the 500-person threshold is standard for this specific identification strategy to orient the reader.