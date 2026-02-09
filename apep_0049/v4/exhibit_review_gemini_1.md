# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (vertex)
**Paper:** paper.pdf
**Timestamp:** 2026-02-09T16:52:48.908635
**Route:** Direct Google API + PDF
**Tokens:** 21867 in / 1787 out
**Response SHA256:** 3e08d636086e9043

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Sample Construction"
**Page:** 11
- **Formatting:** Generally clean. Uses horizontal lines correctly (top, bottom, and under headers).
- **Clarity:** High. The flow from 3,573 to 3,592 is easy to follow.
- **Storytelling:** Essential for transparency in RD papers involving geographic matching.
- **Labeling:** Clear notes. Abbreviations (UAs, UCs) are defined.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Summary Statistics"
**Page:** 13
- **Formatting:** Professional. Columns are well-spaced. Note: Ensure dollar signs and percentages are consistent.
- **Clarity:** Good. It highlights the vast differences in population means, justifying the local RD approach.
- **Storytelling:** Strong. It sets the baseline (low transit use) which helps explain the null results later.
- **Labeling:** Units are clearly marked in parentheses.
- **Recommendation:** **REVISE**
  - Use decimal alignment for the "Mean" and "SD" columns. Currently, the numbers are centered, making it harder to compare magnitudes (e.g., population vs. percentages).

### Figure 1: "First Stage: FTA Section 5307 Per-Capita Funding at the Population Threshold"
**Page:** 30
- **Formatting:** Modern and clean. The color coding (orange vs. blue) effectively distinguishes treatment status.
- **Clarity:** Very high. The "sharp" nature of the discontinuity is immediately obvious.
- **Storytelling:** Critical. This is the "First Stage" that validates the entire paper.
- **Labeling:** Y-axis clearly shows units ($). Title is descriptive.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Distribution of Urban Areas Near the 50,000 Population Threshold"
**Page:** 31
- **Formatting:** Standard density plot. The dashed red line for the threshold is clear.
- **Clarity:** The bin width looks appropriate for detecting manipulation.
- **Storytelling:** Necessary for RDD validity. Shows no "bunching."
- **Labeling:** Includes the McCrary test stats in the subtitle, which is helpful.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "RDD Estimates: Effect of Crossing the 50,000 Population Threshold"
**Page:** 16
- **Formatting:** Journal-ready. Use of brackets for 95% CI is standard.
- **Clarity:** High. Grouping by outcome variable is logical.
- **Storytelling:** This is the "money table." It delivers the core null findings.
- **Labeling:** Clear notes on `rdrobust` specifics (bias-correction).
- **Recommendation:** **REVISE**
  - Add significance stars notation in the notes, even if none are significant. 
  - The "Estimate" column should be converted to percentage points (e.g., -0.15 instead of -0.0015) to match the text and Figure 7. Mixing decimals and percentages is confusing.

### Figure 3: "RDD: Effect of Section 5307 Eligibility on Transit Share"
**Page:** 32
- **Formatting:** Professional. Shaded 95% CIs are well-rendered.
- **Clarity:** Good, though the y-axis scale is very narrow (0% to 3%), which correctly reflects the data.
- **Storytelling:** Visual proof of the null. 
- **Labeling:** Excellent. P-values and estimates are included on the plot area.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "RDD: Effect of Section 5307 Eligibility on Employment Rate"
**Page:** 33
- **Formatting:** Consistent with Figure 3. 
- **Clarity:** The "wiggle" in the local polynomial fit might suggest a higher-order polynomial; the author should ensure this is justified (already addressed in Table 8).
- **Storytelling:** Secondary outcome, supports the "no effect" story.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Covariate Balance: Median Household Income at Threshold"
**Page:** 34
- **Formatting:** Good use of green to distinguish it from "Outcome" figures.
- **Clarity:** Clearly shows the continuity of the covariate.
- **Storytelling:** Vital for RD validity.
- **Recommendation:** **KEEP AS-IS** (Consider moving to Appendix if space is tight, but usually stays in main text for top journals).

### Figure 6: "Bandwidth Sensitivity: Transit Share Estimates"
**Page:** 35
- **Formatting:** Clean line plot with CI.
- **Clarity:** Shows "stability" well.
- **Storytelling:** Robustness check.
- **Recommendation:** **MOVE TO APPENDIX**
  - While important, Figure 7 and 8 provide more "story." This is a technical check.

### Figure 7: "Summary: RDD Estimates Across All Outcomes"
**Page:** 36
- **Formatting:** Forest plot style. Very effective.
- **Clarity:** Excellent. This is the "10-second parse" exhibit.
- **Storytelling:** Best summary of the paper's findings.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Placebo Threshold Tests: Transit Share"
**Page:** 36
- **Formatting:** Clear differentiation of the "true" threshold in blue.
- **Clarity:** High.
- **Storytelling:** Strong evidence that the main result isn't a fluke.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 7: "Summary Statistics: Near Threshold Sample (25k-75k)"
**Page:** 37
- **Formatting:** Standard.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Alternative Polynomial Orders: Transit Share"
**Page:** 37
- **Formatting:** Standard.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Alternative Kernels: Transit Share"
**Page:** 38
- **Formatting:** Standard.
- **Recommendation:** **KEEP AS-IS**

### Table 10: "Distribution of Urban Areas by Census Region"
**Page:** 38
- **Formatting:** Standard.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 2 main tables, 8 main figures (including validation/sensitivity), 4 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The figures are modern (likely `ggplot2`) and follow the visual style of top-tier policy journals (AEJ: Policy, etc.). 
- **Strongest exhibits:** Figure 1 (First Stage), Figure 7 (Forest plot of outcomes).
- **Weakest exhibits:** Table 3 (Unit inconsistency with text), Figure 6 (redundant for main text).
- **Missing exhibits:** 
  1. **A Map:** A map showing the distribution of "Urban Clusters" vs "Urbanized Areas" would be highly impactful for a geography-based paper.
  2. **Mechanisms Table:** The text mentions "Intermediate Outcomes" in the conclusion (transit service hours). A table showing even a null effect on these would strengthen the "Why" section.
- **Top 3 improvements:**
  1. **Sync Units:** Ensure Table 3 and Figure 3 use the same units (Percentage Points vs. Decimals). Percentage points (e.g., -0.15) are much more readable for small effects.
  2. **Add a Map:** Include a figure showing the U.S. with dots for treated and control urban areas to ground the geographic scope.
  3. **Streamline Main Text Figures:** Move Figure 6 (Bandwidth Sensitivity) to the Appendix to reduce "Figure Fatigue." 8 figures in the main text is high for an AER/QJE paper; 5-6 is the "sweet spot."