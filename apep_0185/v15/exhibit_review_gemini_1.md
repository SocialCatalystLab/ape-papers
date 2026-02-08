# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (vertex)
**Paper:** paper.pdf
**Timestamp:** 2026-02-07T04:21:16.285179
**Route:** Direct Google API + PDF
**Tokens:** 29802 in / 1566 out
**Response SHA256:** 5e554f326333a2aa

---

This review evaluates the exhibits of "Friends in High Places" against the standards of top-tier economics journals (AER, QJE, JPE).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Population-Weighted Network Minimum Wage Exposure by County"
**Page:** 14
- **Formatting:** High quality. The "magma" color scale is appropriate for visibility and black-and-white printing.
- **Clarity:** Clear. The 10-second takeaway—geographic variation exists within states—is evident.
- **Storytelling:** Essential. It establishes the "share" vs. "scale" variation that is the paper’s primary contribution.
- **Labeling:** Legend is clear. 
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Population-Weighted Minus Probability-Weighted Exposure Gap"
**Page:** 15
- **Formatting:** Good use of a diverging (red-blue) color palette to show positive/negative differences.
- **Clarity:** The map is a bit "noisy" due to county-level granularity, but the message of spatial clusters of divergence is clear.
- **Storytelling:** High value. It visually justifies why the authors' new weighting scheme matters.
- **Labeling:** Units ($) are present.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Within-State Residual Variation in the Instrumental Variable"
**Page:** 17
- **Formatting:** Professional panel structure.
- **Clarity:** Panel B is significantly more sparse than Panel A. This is a crucial "credibility" plot.
- **Storytelling:** Excellent. It proves that the IV isn't just picking up state-level trends by showing the "leftover" variation.
- **Labeling:** Legend needs larger font for "Residual IV".
- **Recommendation:** **REVISE**
  - Increase the font size of the color bar labels and the "Panel A/B" titles. They currently disappear relative to the maps.

### Figure 4: "First Stage: Out-of-State vs. Full Network Exposure"
**Page:** 21
- **Formatting:** Classic binscatter.
- **Clarity:** Extremely high. Shows a tight, linear relationship.
- **Storytelling:** Standard for IV papers. Establishes the relevance condition.
- **Labeling:** Y-axis and X-axis include "log MW" which is vital for interpretation.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Distance-Credibility Tradeoff"
**Page:** 23
- **Formatting:** A bit cluttered. Dual y-axes (F-stat vs. p-value) are often discouraged by AER unless necessary.
- **Clarity:** The 100-250km "sweet spot" is mentioned in text but not visually highlighted on the plot.
- **Storytelling:** This is the most complex figure. It tries to show three different metrics (F, Balance p, RF p).
- **Recommendation:** **REVISE**
  - Shaded area: Add a light gray vertical rectangle behind the 100km to 250km range to visually define the "Sweet Spot" mentioned in the text.
  - Simplify: Consider removing "RF Pre-Trend p" and keeping it in a table; the balance p-value is the more standard diagnostic here.

### Figure 6: "Event Study: Employment Response to Network Exposure"
**Page:** 40
- **Formatting:** Standard "clean" event study plot. 
- **Clarity:** High. Pre-trends look flat; post-trends show a clear break.
- **Storytelling:** The core dynamic evidence.
- **Labeling:** "Fight for $15 begins" annotation is helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Heterogeneity by Census Division"
**Page:** 45
- **Formatting:** Coefficient plot (whisker plot) is professional. 
- **Clarity:** Excellent. One glance shows the South is the driver.
- **Storytelling:** Supports the "information" mechanism (it matters most where it's novel).
- **Labeling:** The red dashed line for the "Overall OLS" is a great touch for comparison.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Network Minimum Wage Exposure and Local Labor Market Outcomes"
**Page:** 38
- **Formatting:** Booktabs style (clean horizontal lines, no vertical lines). Numbers are decimal-aligned.
- **Clarity:** Very dense. Six columns with two outcome panels.
- **Storytelling:** This is the "Money Table." It successfully compares OLS, IV, Distance-Restricted IV, and the Probability-weighted test.
- **Labeling:** Extensive notes. Stars defined.
- **Recommendation:** **KEEP AS-IS** (This is a QJE-quality table).

### Table 2: "USD-Denominated Specifications: 2SLS Estimates"
**Page:** 39
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Essential for the "9% employment effect" headline.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 7: "Distance-Credibility Analysis..."
**Page:** 48
- **Storytelling:** Redundant with Figure 5, but necessary for the "exact numbers" crowd.
- **Recommendation:** **KEEP AS-IS**

### Table 12: "Placebo Instrument Tests"
**Page:** 52
- **Storytelling:** Crucial for ruling out generic spillovers.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Placebo tests for shift-share designs are now "required" for AER/Econometrica. This should not be buried in the appendix.

---

## Overall Assessment

- **Exhibit count:** 3 Main Tables, 7 Main Figures, 10 Appendix Tables, 1 Appendix Figure.
- **General quality:** The exhibits are exceptionally strong. They follow the "Stata-to-LaTeX" aesthetic common in top journals (clean lines, extensive notes).
- **Strongest exhibits:** Table 1 (Main Results), Figure 6 (Event Study).
- **Weakest exhibits:** Figure 5 (Tradeoff plot is too "busy"), Table 3 (Balance table—p-values are good but doesn't show normalized differences).

- **Missing exhibits:**
  - **Summary Statistics Table:** The paper needs a Table 0 or Table 1 showing Means and SDs of the primary variables (Earnings, Employment, SCI, Pop-Weighted MW). Readers need to see the raw data scale before the logs.

- **Top 3 improvements:**
  1. **Add a Summary Statistics table** to the main text (Section 4).
  2. **Promote Table 12 (Placebo Tests)** from the Appendix to the Main Text to satisfy recent shift-share econometric requirements.
  3. **Simplify Figure 5** by focusing on the F-stat and Balance p-value, and use a background shade to highlight the "Sweet Spot" (100-250km).