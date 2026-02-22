# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-22T16:45:37.644163
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1777 out
**Response SHA256:** bcfe8a8b885b94d4

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: New State vs Parent State Districts"
**Page:** 9
- **Formatting:** Clean and professional. Good use of horizontal rules (booktabs style).
- **Clarity:** Highly clear. The comparison is intuitive, and the $p$-value column immediately highlights the baseline imbalance.
- **Storytelling:** Essential. It sets the stage for the identification challenge (pre-existing differences) mentioned in the text.
- **Labeling:** Good. "Ag. Worker Share" should be spelled out as "Agricultural Worker Share" for top journals. The note explains the $p$-value source correctly.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of State Creation on Nightlight Intensity"
**Page:** 12
- **Formatting:** Standard AER style. Numbers are well-aligned.
- **Clarity:** Good, but the "CS-DiD ATT" being tucked in the middle of the "New State × Post" row is slightly confusing visually. 
- **Storytelling:** This is the "money table." It correctly presents the primary TWFE and the heterogeneity-robust (CS) estimates side-by-side. 
- **Labeling:** Excellent notes. It defines the permutations, the bootstrap, and the clustering level clearly.
- **Recommendation:** **REVISE**
  - Move "CS-DiD ATT" and its SE to a separate row below the main "New State × Post" results to avoid the appearance of it belonging to Column (2) only.

### Figure 1: "Event Study: Effect of State Creation on Nightlight Intensity"
**Page:** 14
- **Formatting:** Professional ggplot2 style. Confidence intervals are clear.
- **Clarity:** Very high. The pre-trend violation is unmistakable.
- **Storytelling:** Central to the paper’s "honest" narrative about identification.
- **Labeling:** Clear axis labels. 
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Callaway-Sant’Anna Event Study"
**Page:** 15
- **Formatting:** Consistent with Figure 1.
- **Clarity:** Good. The simultaneous confidence bands are well-explained in the text.
- **Storytelling:** Important for showing that the pre-trend isn't just a TWFE artifact. However, it is very similar to Figure 1.
- **Recommendation:** **REVISE**
  - Consider combining Figure 1 and Figure 2 into a single figure with two panels (Panel A: TWFE; Panel B: CS-DiD). This is a common "top journal" practice to save space and allow direct comparison of the two estimators' dynamics.

### Table 3: "Robustness Checks"
**Page:** 16
- **Formatting:** Minimalist. Logic is easy to follow.
- **Clarity:** High. 
- **Storytelling:** Consolidates many necessary checks (leave-one-out, extended panel) efficiently.
- **Labeling:** Needs significance stars to match Tables 2 and 4.
- **Recommendation:** **REVISE**
  - Add significance stars (*, **, ***) to the coefficient column for consistency across the paper.

### Figure 3: "Randomization Inference: Distribution of Placebo Estimates"
**Page:** 16
- **Formatting:** Clean histogram. The blue vertical line for the actual estimate is a great visual cue.
- **Clarity:** Excellent. The $N=20$ limitation is visually obvious.
- **Storytelling:** Strong support for the $p=0.05$ claim in the abstract.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Heterogeneous Effects by State Pair"
**Page:** 18
- **Formatting:** Good.
- **Clarity:** The "New Capital" row is a bit odd—it's just a label of the city, not a variable.
- **Storytelling:** Crucial. This table proves the "Jharkhand exception" which is a core argument of the paper.
- **Labeling:** Ensure the note explains why state-level clustering was impossible here (too few clusters per pair).
- **Recommendation:** **REVISE**
  - Move the "New Capital" names (Dehradun, etc.) to the table note and replace that row with a "State-Pair FE" row (Yes/Yes/Yes).

### Figure 4: "Nightlight Trends by State Pair"
**Page:** 19
- **Formatting:** Multi-panel plot is excellent. Consistent y-axes would be better but the current version allows seeing the individual dynamics.
- **Clarity:** High. The color-coding (Blue/Orange) is intuitive.
- **Storytelling:** This is the most "human" figure in the paper; it shows the raw data behind the regressions.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Capital City Effect: New State Capitals vs. Other Districts"
**Page:** 20
- **Formatting:** Clean.
- **Clarity:** Three lines are easy to distinguish. 
- **Storytelling:** Strong. It supports the "administrative agglomeration" mechanism perfectly.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Long-Run Trajectories: Two Decades After State Creation"
**Page:** 21
- **Formatting:** Good use of different shapes for DMSP vs. VIIRS.
- **Clarity:** A bit cluttered with the transition line and shapes.
- **Storytelling:** Shows the persistence of the effect.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is very similar to Figure 7 (Raw Trends) but with the VIIRS extension. Figure 4 already shows the main heterogeneity. This is a "nice to have" but the main text is getting heavy with figures (6 main figures is a lot).

---

## Appendix Exhibits

### Figure 7: "Average Nightlight Intensity: New vs. Parent State Districts"
**Page:** 33
- **Formatting:** Standard.
- **Clarity:** High.
- **Storytelling:** This is the raw data version of Figure 1. 
- **Labeling:** Clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - In QJE/AER, editors often want to see the raw data (raw means by group) *before* the event study coefficients. Move this to Section 5.1 as the opening figure.

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 6 main figures, 0 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. The exhibits follow the "Less is More" philosophy of top journals. The visual language is consistent (colors, line styles).
- **Strongest exhibits:** Figure 1 (Event Study) and Figure 4 (State Pair Trends). They tell the whole story of the paper.
- **Weakest exhibits:** Table 3 (Robustness) is a bit sparse; Figure 6 is slightly redundant.
- **Missing exhibits:** 
  - **A Map:** A paper about Indian state bifurcations *must* have a map showing the parent states and the three new states. This is a major omission for an AER/QJE-targeted paper.
  - **Regression for Capital Effects:** Figure 5 is great, but a small table confirming the statistical significance of the capital vs. non-capital growth difference would be standard.

- **Top 3 improvements:**
  1. **ADD A MAP:** Create a high-quality GIS map of India highlighting the treatment/control districts. This is the 10-second "where are we?" check for readers.
  2. **Consolidate Event Studies:** Merge Figure 1 and Figure 2 into a two-panel figure. It demonstrates econometric sophistication and saves space.
  3. **Standardize Table 2:** Fix the layout of the CS-DiD row so it doesn't look like an annex to Column (2).