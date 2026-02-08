# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (vertex)
**Paper:** paper.pdf
**Timestamp:** 2026-02-07T02:58:46.229632
**Route:** Direct Google API + PDF
**Tokens:** 20280 in / 2427 out
**Response SHA256:** 1446b60f5165a58b

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Geographic Distribution of Salary Transparency Law Adoption"
**Page:** 6
- **Formatting:** Good. Standard choropleth map. Legend is clear but occupies a lot of vertical space.
- **Clarity:** High. Quickly identifies the staggered nature of the policy and the geographic clusters (West Coast/Northeast).
- **Storytelling:** Essential. Establishes the "staggered" nature of the DiD design visually.
- **Labeling:** Legend labels "2021 (Pioneer)" and "2025+" are clear. 
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Theoretical Predictions by Channel"
**Page:** 4
- **Formatting:** Clean, uses standard `booktabs` style. 
- **Clarity:** High. The use of "0", "+", and "—" is intuitive.
- **Storytelling:** Crucial for a top-tier journal. It sets the "horse race" between theories that the empirical section will later adjudicate.
- **Labeling:** The note explaining "—" for the gender gap is vital and well-placed.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Dataset Comparison"
**Page:** 8
- **Formatting:** Professional. Good use of whitespace.
- **Clarity:** Excellent. Summarizes the trade-offs between CPS (rich controls) and QWI (administrative precision/flows).
- **Storytelling:** Justifies the use of two datasets. Helps the reader understand why the paper doesn't just use one.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "QWI Summary Statistics"
**Page:** 8
- **Formatting:** Standard. Panel A and B are well-separated. Numbers are properly aligned.
- **Clarity:** High.
- **Storytelling:** Essential for showing the scale of the data and pre-treatment differences between treated and control states.
- **Labeling:** Notes clearly define the rates (Hiring, Separation, etc.).
- **Recommendation:** **REVISE**
  - Add a "Difference" column (Treated - Control) with t-stats or p-values to make "balance" testing explicit in the table, rather than just in the text.

### Figure 2: "CPS Trends: Treated vs. Control States"
**Page:** 11
- **Formatting:** Multi-panel (a and b) is good. The legend is redundant across panels; it could be placed once at the bottom.
- **Clarity:** Good. The raw trends show parallel movement clearly.
- **Storytelling:** Visual proof of parallel trends.
- **Labeling:** Y-axis in Panel (b) is "Gender Wage Gap (%)". Ensure this is consistent with the "log points" used in the text.
- **Recommendation:** **REVISE**
  - Remove the legend from inside Panel (a) and (b) and place a single legend between the panels or at the bottom to reduce clutter.

### Figure 3: "QWI Trends: Treated vs. Control States"
**Page:** 12
- **Formatting:** The "sawtooth" seasonal pattern makes the trend hard to read.
- **Clarity:** Low-Medium. The seasonality obscures the treatment effect.
- **Storytelling:** Intended to show quarterly precision, but visually messy compared to Figure 2.
- **Labeling:** Clear labels.
- **Recommendation:** **REVISE**
  - Add a **seasonally adjusted** version of these plots (or use a 4-quarter moving average) to show the underlying trend more clearly. The raw sawtooth is distracting for a main-text figure.

### Table 4: "CPS: Effect of Salary Transparency Laws on Log Wages"
**Page:** 13
- **Formatting:** Publication-ready.
- **Clarity:** High. Shows the null result across increasing levels of control.
- **Storytelling:** Proves the "Aggregate Wage" null.
- **Labeling:** Significance stars and SE notes are present.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "QWI Main Results: Earnings and Gender Gap"
**Page:** 14
- **Formatting:** Use of Panel A, B, and C is logical.
- **Clarity:** Good, though Panel C's note is quite long.
- **Storytelling:** This is the "Money Table." It reconciles the aggregate null with the gender-specific gain.
- **Labeling:** Excellent.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "CPS Triple-Difference: Effect on Gender Wage Gap"
**Page:** 15
- **Formatting:** Professional.
- **Clarity:** Clear distinction between the main effect (Treated x Post) and the DDD (Treated x Post x Female).
- **Storytelling:** Provides the individual-level micro-foundation for the QWI results.
- **Labeling:** Good. 
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "CPS Event Study by Gender"
**Page:** 16
- **Formatting:** Good use of colors (pink/blue). Confidence intervals are visible.
- **Clarity:** High. The divergence at $t=0$ is the key finding.
- **Storytelling:** Strongest visual evidence in the paper.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "QWI Labor Market Dynamism Results"
**Page:** 17
- **Formatting:** Column headers are a bit crowded.
- **Clarity:** High. All coefficients are near-zero.
- **Storytelling:** Adjudicates the "Costly Adjustment" theory.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Labor Market Dynamism: DiD Coefficient Plot"
**Page:** 18
- **Formatting:** Clean horizontal forest plot.
- **Clarity:** Excellent. Shows "precisely estimated zeros" at a glance.
- **Storytelling:** Visual summary of Table 7.
- **Labeling:** Axis label is descriptive.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "QWI Industry Heterogeneity: Earnings and Gender Gap Effects"
**Page:** 19
- **Formatting:** Compact.
- **Clarity:** Good. 
- **Storytelling:** Tests the "Bargaining" mechanism.
- **Labeling:** Notes explain why these specific industries were chosen.
- **Recommendation:** **MOVE TO APPENDIX**
  - Figure 6 does a better job of showing this. This table is essentially a repeat of the figure's data.

### Figure 6: "Industry Heterogeneity in QWI Earnings Effects"
**Page:** 19
- **Formatting:** Colors are helpful.
- **Clarity:** High.
- **Storytelling:** Shows the lack of aggregate wage effects even in high-bargaining sectors.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Cross-Dataset Comparison: CPS vs. QWI Estimates"
**Page:** 20
- **Formatting:** Excellent comparison layout.
- **Clarity:** High.
- **Storytelling:** Synthesizes the whole paper into one exhibit.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 10: "CPS Robustness of Main Results"
**Page:** 21
- **Recommendation:** **KEEP AS-IS**

### Table 11: "Alternative Inference Methods"
**Page:** 22
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - For a paper with only 8 treated states, the Permutation $p$ and LOTO range are not just "robustness"—they are central to the credibility of the main result.

### Figure 7: "Leave-One-Treated-State-Out: Gender DDD"
**Page:** 22
- **Recommendation:** **KEEP AS-IS**

### Table 12: "Salary Transparency Law Adoption"
**Page:** 30
- **Recommendation:** **KEEP AS-IS** (Essential reference)

### Table 13: "Pre-Treatment Balance: Treated vs. Control States (CPS, 2015-2020)"
**Page:** 30
- **Recommendation:** **KEEP AS-IS**

### Table 14: "CPS Event Study Coefficients"
**Page:** 31
- **Recommendation:** **KEEP AS-IS**

### Table 15: "Heterogeneity by Occupation Bargaining Intensity (CPS)"
**Page:** 31
- **Recommendation:** **KEEP AS-IS**

### Table 16: "CPS Treatment Effects by Cohort"
**Page:** 32
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "QWI Gender Earnings Gap: Treated vs. Control States"
**Page:** 32
- **Recommendation:** **REMOVE**
  - This is redundant with Figure 3(b).

### Figure 9 & 10: "QWI Quarterly Event Studies"
**Page:** 33-34
- **Formatting:** The seasonality in the event study is very strange. Usually, event study coefficients are plotted after partialling out period fixed effects.
- **Recommendation:** **REVISE**
  - Re-estimate the C-S event study including quarter-of-year fixed effects to remove the sawtooth from the coefficients. The current plot looks like a programming error rather than a result.

---

## Overall Assessment

- **Exhibit count:** 9 main tables, 6 main figures, 8 appendix tables, 4 appendix figures.
- **General quality:** High. The paper follows the "AER/QJE style" closely (booktabs tables, clean DiD plots).
- **Strongest exhibits:** Figure 4 (Event study by gender) and Table 9 (Cross-dataset comparison).
- **Weakest exhibits:** Figure 3 and Figure 9/10 due to distracting seasonality.
- **Missing exhibits:** A **Summary Statistics** table for the **CPS** data should be in the main text, not just the appendix. It is standard to show the reader who these 614,000 people are.

### Top 3 Improvements:
1.  **Deseasonalize QWI Figures:** Figure 3, 9, and 10 need to be smoothed or seasonally adjusted. The current "sawtooth" pattern makes the paper look unpolished and obscures the parallel trends.
2.  **Explicit Balance Testing:** In Table 3 (QWI) and Table 13 (CPS), add a "Difference" column with stars/p-values to satisfy the "Parallel Levels" check often requested by reviewers.
3.  **Consolidate Heterogeneity:** Use Figure 6 as the primary heterogeneity exhibit and move the corresponding Table 8 to the appendix to reduce main-text clutter.