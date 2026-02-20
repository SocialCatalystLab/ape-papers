# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T20:19:59.413298
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1862 out
**Response SHA256:** 7081cb1ff462ee31

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "McCrary Density Test at PMGSY Population Threshold"
**Page:** 13
- **Formatting:** Professional. Standard RDD density plot using `rddensity` output. Clean white background.
- **Clarity:** High. The overlap of the confidence intervals for the density estimate on both sides of the zero-centered threshold is immediately apparent.
- **Storytelling:** Essential. This validates the RDD by showing no manipulation of the running variable.
- **Labeling:** Good. Includes $t$ and $p$ values in the notes. Y-axis is density; X-axis is centered population.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics: Villages Near PMGSY Threshold"
**Page:** 9
- **Formatting:** Needs minor refinement. The "Below 500" and "Above 500" headers should be clearly separated from the data. Number alignment is good (decimal-aligned).
- **Clarity:** Good, though "DMSP Nightlights, raw (2000)" and "VIIRS Nightlights, raw (2012)" are slightly clunky row names.
- **Storytelling:** Strong. It establishes the "near-balance" of the sample before formal testing.
- **Labeling:** Detailed notes. Suggest adding the standard deviation in parentheses below the means to provide a sense of scale for the outcome variables.
- **Recommendation:** **REVISE**
  - Add standard deviations in parentheses below means.
  - Group "Population (2001)" and "(1991)" under a sub-header or rename for better flow.

### Table 2: "Covariate Balance at PMGSY Population Threshold"
**Page:** 14
- **Formatting:** Standard three-line table (Booktabs style). Very clean.
- **Clarity:** High. It is easy to see that all $p$-values are $>0.1$.
- **Storytelling:** Critical for identification.
- **Labeling:** Row names like "lit rate 91" and "female share 01" should be more formal (e.g., "Literacy Rate (1991)").
- **Recommendation:** **REVISE**
  - Use more descriptive, formal labels for covariates (e.g., "SC Share (2001)" instead of "sc share 01").

### Table 3: "Main RDD Estimates: Effect of PMGSY Eligibility on Nightlights"
**Page:** 14
- **Formatting:** Professional. Logical progression by year and sensor.
- **Clarity:** Clear. $N_{eff}$ column is helpful for understanding the power of the local regressions.
- **Storytelling:** This is the core result table. It shows the persistence of the null.
- **Labeling:** Definition of stars and standard errors is present.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Dynamic RDD Estimates: Effect of PMGSY Eligibility on Nightlights"
**Page:** 16
- **Formatting:** Multi-panel structure is excellent. Shaded confidence bands are standard for AER/QJE.
- **Clarity:** Very high. The vertical dashed line for the launch year tells the story instantly.
- **Storytelling:** This is the "money plot" of the paper. It shows the "long arc" mentioned in the title.
- **Labeling:** Y-axis units (asinh) are clearly labeled. Legends are well-placed.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "RDD Estimates: Effect of PMGSY Eligibility on Census Outcomes (2001–2011)"
**Page:** 17
- **Formatting:** Clean and professional.
- **Clarity:** Good. Covers the non-satellite outcomes.
- **Storytelling:** Important for showing that the null isn't just a "measurement error" of satellite data.
- **Labeling:** Good notes explaining the calculation of "Lit Change," etc.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness: VIIRS 2020 RDD Estimates"
**Page:** 18
- **Formatting:** Excellent use of panels (A, B, C) to group different types of robustness checks.
- **Clarity:** High. Demonstrates stability across bandwidths and polynomial orders.
- **Storytelling:** Reassures the reader that the results aren't "cherry-picked" based on specification.
- **Labeling:** Clear headers.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Placebo Threshold Tests"
**Page:** 19
- **Formatting:** Clean coefficient plot. Use of color (orange for true threshold) is effective.
- **Clarity:** Good. The zero line (dashed) helps see that all intervals cross zero.
- **Storytelling:** Standard robustness check for RDD.
- **Labeling:** Y-axis "asinh VIIRS 2020" is specific.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 4 & 5: "RDD Scatter Plots..."
**Page:** 30
- **Formatting:** 2x2 grid is standard. Red polynomial fits against blue binned means.
- **Clarity:** High. Shows the raw "shape" of the data.
- **Storytelling:** Necessary for transparency in any RDD paper.
- **Labeling:** Sub-captions (a, b) are clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Bandwidth Sensitivity: VIIRS 2020 RDD Estimate"
**Page:** 31
- **Formatting:** Professional line plot with shaded CI.
- **Clarity:** Clear. Shows the estimate is flat across a wide range of $h$.
- **Storytelling:** Visually supplements Table 5 Panel A.
- **Recommendation:** **KEEP AS-IS** (Wait—could be consolidated with Table 5 if the journal has strict exhibit limits, but fine for an appendix).

### Figure 7: "Covariate Balance at PMGSY Population Threshold"
**Page:** 31
- **Formatting:** Horizontal coefficient plot.
- **Clarity:** Excellent. This is a much better way to "see" balance than Table 2.
- **Storytelling:** Effectively communicates the lack of discontinuities in pre-treatment variables.
- **Recommendation:** **PROMOTE TO MAIN TEXT**. Move Figure 7 to Section 5.1 and move Table 2 to the Appendix. Readers of top journals prefer visual balance checks.

### Table 7: "Full Dynamic RDD Estimates"
**Page:** 32–33
- **Formatting:** Standard list.
- **Clarity:** Logical but long.
- **Storytelling:** Provides the data behind Figure 2.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 3 main figures, 2 appendix tables, 4 appendix figures (Total: 13)
- **General quality:** Extremely high. The paper follows modern "Best Practices" for RDD (Cattaneo et al. style). Figures are clean and use appropriate confidence intervals.
- **Strongest exhibits:** Figure 2 (Dynamic RDD) and Table 5 (Robustness Panels).
- **Weakest exhibits:** Table 2 (Standard but boring compared to the visual version in Figure 7).
- **Missing exhibits:** A **Map** showing the distribution of villages near the 500-person threshold across India would be highly beneficial for a "Top 5" journal to show geographic coverage.

### Top 3 Improvements:
1.  **Swap Figure 7 and Table 2:** Move the visual covariate balance plot (Figure 7) to the main text. It is a much faster and more convincing "look" at the identification strategy's validity.
2.  **Add a Geographic Map:** Include a figure showing the treatment/control village locations (or a heat map of village density near the threshold) to ground the study in the actual geography of India.
3.  **Refine Table 1:** Add standard deviations to the summary stats and use more formal labels. For a AER/QJE audience, the raw scale of the dependent variable (not just the asinh mean) needs to be very clear.