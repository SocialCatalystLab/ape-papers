# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-09T15:15:40.729294
**Route:** Direct Google API + PDF
**Tokens:** 29317 in / 2607 out
**Response SHA256:** 20986cc9337c1fa7

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Population-Weighted Network Minimum Wage Exposure by County"
**Page:** 14
- **Formatting:** Clean and professional. The choice of the "Viridis" style color palette is standard for modern top-tier journals.
- **Clarity:** High. The contrast between the high-exposure coasts and the low-exposure interior is immediately apparent.
- **Storytelling:** Essential. It establishes the geographic variation that identifies the model.
- **Labeling:** Legend is clear. Units ($) are included.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Population-Weighted Minus Probability-Weighted Exposure Gap"
**Page:** 15
- **Formatting:** Excellent use of a diverging color scale (red-blue) to show differences from zero.
- **Clarity:** The message—that California-Texas and the Northeast corridor have the largest gaps—is clear.
- **Storytelling:** This is the most innovative part of the paper's "scale vs. share" argument. 
- **Labeling:** "Gap ($)" is clearly labeled.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Within-State Residual Variation in the Instrumental Variable"
**Page:** 17
- **Formatting:** Standard panel structure (Panel A and B).
- **Clarity:** Good, though the maps are getting a bit small. 
- **Storytelling:** Crucial for identification. It proves that there is variation left even after the state-by-time fixed effects absorb the "obvious" variation.
- **Labeling:** Subtitles and legend are clear.
- **Recommendation:** **REVISE**
  - Increase the size of the maps if possible; the county-level variation is the "hero" here, and it's currently a bit cramped.

### Table 1: "Network Minimum Wage Exposure and Local Labor Market Outcomes"
**Page:** 38
- **Formatting:** Professional AER/QJE style. No vertical lines, clear grouping. Standard errors in parentheses.
- **Clarity:** logical progression from OLS to 2SLS to distance restrictions. 
- **Storytelling:** This is the "Money Table." It puts all the primary findings (earnings and employment) in one place.
- **Labeling:** Stars are defined. First-stage $F$ and $\hat{\pi}$ are included.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "USD-Denominated Specifications: 2SLS Estimates"
**Page:** 39
- **Formatting:** Clean. Matches Table 1.
- **Clarity:** High. Provides the "headline" numbers ($1 increase = 3.4% earnings).
- **Storytelling:** Strong. Authors correctly identified that log-log coefficients can be hard to interpret, so this "translation" table is great for the "Discussion" section.
- **Labeling:** Units are explicit.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Balance Tests: Pre-Period Characteristics by IV Quartile"
**Page:** 39
- **Formatting:** Standard balance table. Decimal-aligned.
- **Clarity:** Clear evidence of the level-imbalance (p=0.004) that the authors discuss.
- **Storytelling:** Important for honesty in identification. It sets up the need for county fixed effects.
- **Labeling:** N per quartile is helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "First Stage: Out-of-State vs. Full Network Exposure"
**Page:** 21
- **Formatting:** Binned scatter is the "gold standard" for top journals to show instrument strength.
- **Clarity:** Shows a beautiful linear relationship.
- **Storytelling:** Defeats any concern about a "weak" first stage.
- **Labeling:** Slope and F-stat are right there on the plot.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Distance-Credibility Tradeoff"
**Page:** 23
- **Formatting:** Dual-axis plot.
- **Clarity:** A bit cluttered. The three lines (Balance p, First-stage F, Pre-trend p) use different scales. 
- **Storytelling:** Powerful. It visualizes the "sweet spot" (100–250km) mentioned in the text.
- **Labeling:** The F=10 and p=0.05 horizontal lines are very helpful.
- **Recommendation:** **REVISE**
  - Consider making the "First-Stage F" line a different style (e.g., thicker or dashed) to distinguish it more clearly from the two p-value lines, as they belong to different axes.

### Figure 6: "Event Study: Employment Response to Network Exposure"
**Page:** 40
- **Formatting:** Standard event-study plot.
- **Clarity:** Clear "null" before 2014 and clear take-off after.
- **Storytelling:** Fundamental for the DiD-style identification.
- **Labeling:** "Fight for $15 begins" annotation is excellent.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Structural vs. Reduced-Form Event Studies"
**Page:** 41
- **Formatting:** Two-panel vertical.
- **Clarity:** The 95% CI ribbons are a bit "spiky" but understandable.
- **Storytelling:** Robustness check to show the timing isn't driven by the IV construction.
- **Labeling:** Clear panel titles.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a technical robustness check. Figure 6 is enough for the main text's "timing" argument.

### Figure 8: "Pre-Treatment Employment Trends by IV Quartile"
**Page:** 42
- **Formatting:** Color-coded lines by quartile.
- **Clarity:** Clear "parallel-ish" trends despite level differences.
- **Storytelling:** Visual proof for the "Parallel Trends" assumption.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Shock-Robust Inference"
**Page:** 42
- **Formatting:** Comparisons of p-values across methods.
- **Clarity:** Easy to see the results are robust.
- **Storytelling:** Standard requirement for modern shift-share papers (Adao et al. 2019).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Job Flow Mechanism: Effects of Network Exposure on Labor Market Dynamics"
**Page:** 43
- **Formatting:** Row-by-outcome structure.
- **Clarity:** Allows comparison of OLS vs 2SLS across many outcomes.
- **Storytelling:** Essential for the "Information Channel" argument. It shows the *churn* (hires and separations).
- **Labeling:** Outcome names are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Migration Mechanism Tests: IRS County-to-County Flows"
**Page:** 43
- **Formatting:** Matches Table 5.
- **Clarity:** Shows the "Null" on migration.
- **Storytelling:** Critical for ruling out the "Migration Channel."
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Wait—Actually, considering the main text flow, this could be combined with Table 5 into a single "Mechanism" table to save space).
- **Revised Recommendation:** **REVISE** (Merge with Table 5 under separate panels: Panel A: Job Flows; Panel B: Migration).

### Figure 9: "Net Migration by Network Exposure Quartile, 2012–2019"
**Page:** 44
- **Formatting:** Time-series of quartiles.
- **Clarity:** A bit messy/noisy compared to Figure 8.
- **Storytelling:** Shows the Q4 "dip" at the end of the sample.
- **Labeling:** Legend and axes are clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - Table 6 already makes the point that migration is not the driver. This figure is noisy and adds little to the main narrative.

### Figure 10: "Heterogeneity by Census Division"
**Page:** 45
- **Formatting:** Dot-and-whisker plot (Forest plot style).
- **Clarity:** Very high. One glance tells the reader that the South is where the action is.
- **Storytelling:** Strong. Matches the theoretical prediction about the "wage gap."
- **Labeling:** "Overall OLS" red line is a great benchmark.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 7: "Distance-Credibility Analysis..."
**Page:** 48
- **Recommendation:** **KEEP AS-IS** (Provides the raw data for Figure 5).

### Table 8: "Shock Contribution Diagnostics"
**Page:** 48
- **Recommendation:** **KEEP AS-IS** (Standard Goldsmith-Pinkham transparency).

### Table 9: "LATE Complier Characterization..."
**Page:** 49
- **Recommendation:** **KEEP AS-IS** (Helpful for interpreting who the "compliers" are).

### Table 10: "Robustness: Sample Restrictions (2SLS)"
**Page:** 50
- **Recommendation:** **KEEP AS-IS** (Standard robustness).

### Table 11: "Robustness: Leave-One-State-Out (2SLS)"
**Page:** 51
- **Recommendation:** **KEEP AS-IS** (Essential for shift-share).

### Table 12: "Placebo Instrument Tests"
**Page:** 52
- **Recommendation:** **KEEP AS-IS**

### Table 13: "Robustness: Alternative Controls (2SLS)"
**Page:** 53
- **Recommendation:** **KEEP AS-IS**

### Figure 11: "Probability-Weighted Network Minimum Wage Exposure by County"
**Page:** 54
- **Recommendation:** **KEEP AS-IS** (Good contrast to Figure 1).

---

## Overall Assessment

- **Exhibit count:** 7 main tables, 9 main figures, 7 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. These exhibits look like they were pulled directly from an AER or QJE article. The use of binned scatters, forest plots, and clean regression tables is very professional.
- **Strongest exhibits:** Figure 2 (Innovation), Table 1 (Comprehensive primary results), Figure 10 (Clear heterogeneity storytelling).
- **Weakest exhibits:** Figure 5 (Dual-axis clutters the message), Figure 9 (Too noisy for the value it adds).
- **Missing exhibits:** A **Summary Statistics** table. While Table 3 gives pre-period means, a standard "Table 1" in most papers provides means and SDs for all variables (outcomes, exposures, and controls) for the full regression sample.
- **Top 3 improvements:**
  1. **Consolidate Mechanisms:** Merge Table 5 and Table 6 into one "Mechanism Analysis" table with Panels A and B. This streamlines the evidence for "Churn vs. Migration."
  2. **Move Robustness Figures:** Move Figure 7 and Figure 9 to the Appendix to reduce main-text clutter and focus the reader on the primary "Event Study" (Figure 6).
  3. **Add Summary Stats:** Create a new Table 1 for Summary Statistics and renumber the others. This is a baseline expectation for top-5 journals.