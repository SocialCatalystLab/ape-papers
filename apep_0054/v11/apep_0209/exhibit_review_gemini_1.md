# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (vertex)
**Paper:** paper.pdf
**Timestamp:** 2026-02-07T03:50:50.478372
**Route:** Direct Google API + PDF
**Tokens:** 20280 in / 2376 out
**Response SHA256:** 4e3a6c1915968ab8

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Theoretical Predictions by Channel"
**Page:** 4
- **Formatting:** Clean, professional. Uses booktabs-style horizontal lines. Logic is clear.
- **Clarity:** Excellent. High signal-to-noise ratio.
- **Storytelling:** Essential. It sets the stage for the mechanism test that defines the paper's contribution to the transparency literature.
- **Labeling:** The note explaining "—" is helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Geographic Distribution of Salary Transparency Law Adoption"
**Page:** 6
- **Formatting:** Standard choropleth map. The color palette for treatment years is distinguishable.
- **Clarity:** Good. It immediately communicates the staggered nature of the policy.
- **Storytelling:** Useful for showing the "Pioneer" status of Colorado and the 2023/2024 clusters.
- **Labeling:** Legends are clear.
- **Recommendation:** **REVISE**
  - Change "2025+" to "Post-Sample Adoption" or similar to clarify why these aren't in the main regressions.

### Table 2: "Dataset Comparison"
**Page:** 8
- **Formatting:** Logical layout.
- **Clarity:** High. Readers see the trade-off between administrative precision (QWI) and individual-level richness (CPS).
- **Storytelling:** Strong. Justifies the use of two datasets.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "QWI Summary Statistics"
**Page:** 9
- **Formatting:** Panel structure (A and B) is excellent. Horizontal alignment is good.
- **Clarity:** High.
- **Storytelling:** Standard and necessary. The "Suppression accounting" note is a nice professional touch for those familiar with QWI.
- **Labeling:** Units (log points vs dollars) are clearly distinguished in the notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "QWI Trends: Treated vs. Control States"
**Page:** 12
- **Formatting:** The raw sawtooth pattern is distracting. While the author defends it in the notes, it makes it hard to see the "nearly identical trajectories" claimed in the text.
- **Clarity:** Moderate. The seasonality obscures the treatment effect in Panel (a).
- **Storytelling:** Central to the "Pre-trends" argument.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **REVISE**
  - **Deseasonalize.** Even if keeping raw data in the appendix, the main text figure should show seasonally adjusted series or 4-quarter moving averages to make the parallel trends visually undeniable to a QJE/AER reviewer.

### Figure 3: "CPS Trends: Treated vs. Control States"
**Page:** 13
- **Formatting:** Cleaner than Figure 2 because data is annual. Shaded 95% CIs are professional.
- **Clarity:** High.
- **Storytelling:** Very strong. Panel (b) shows the "break" at 2021 clearly.
- **Labeling:** Axis labels and legends are appropriate.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Effect of Salary Transparency Laws on Wages and Earnings"
**Page:** 14
- **Formatting:** Standard AER style. Decimal alignment is perfect.
- **Clarity:** Grouping QWI and CPS into Panel A and B allows for instant comparison of the "Null" effect.
- **Storytelling:** This is the first "Main Result" (Hypothesis 1).
- **Labeling:** Standard errors in parentheses, stars defined. Note explains why Column 3 is blank for Panel A.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Effect of Salary Transparency Laws on the Gender Wage Gap"
**Page:** 15
- **Formatting:** Professional.
- **Clarity:** The juxtaposition of the 0.0605 (QWI) and ~0.05 (CPS) estimates is the "smoking gun" of the paper.
- **Storytelling:** The most important table in the paper.
- **Labeling:** Note 4 clarifies the repeating of column (1) for QWI, which is good practice.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "CPS Event Study by Gender"
**Page:** 16
- **Formatting:** Standard event study plot. Colors (Blue/Pink) are standard for gender but perhaps slightly cliché; consider a high-contrast "Colorblind Friendly" palette.
- **Clarity:** Good.
- **Storytelling:** Shows the divergence happens *at* treatment.
- **Labeling:** $y$-axis title is correct.
- **Recommendation:** **REVISE**
  - Ensure the $x$-axis "0" is actually the first year of treatment. The note says "convergence... drives the narrowing," but actually, it's the *female* line rising while the *male* line stays flat. Make sure the text and figure are perfectly aligned.

### Table 6: "QWI Labor Market Dynamism Results"
**Page:** 17
- **Formatting:** Good use of "—" for suppressed C-S estimates with clear explanation.
- **Clarity:** This table is quite large for a series of null results.
- **Storytelling:** Proves the "Zero Efficiency Cost" claim.
- **Recommendation:** **MOVE TO APPENDIX** 
  - Since Figure 5 shows these results visually, the full table of nulls is better suited for the appendix to keep the main text focused on the gender gap and mechanism.

### Figure 5: "Labor Market Dynamism: DiD Coefficient Plot"
**Page:** 17
- **Formatting:** Clean coefficient plot. 
- **Clarity:** Excellent. Shows all nulls at once.
- **Storytelling:** This visual is enough for the main text to prove there's no disruption.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "QWI Industry Heterogeneity"
**Page:** 18
- **Formatting:** Logical.
- **Clarity:** High.
- **Storytelling:** Used to argue that the effect isn't just a "bargaining" story in high-end finance.
- **Recommendation:** **REVISE** 
  - **Consolidate with Figure 6.** Having both Table 7 and Figure 6 in the main text for the same 4 industries is redundant. Keep Figure 6 and move Table 7 to the appendix.

### Figure 6: "Industry Heterogeneity in QWI Earnings Effects"
**Page:** 19
- **Formatting:** Good use of color-coding for High/Low bargaining.
- **Clarity:** High.
- **Storytelling:** Visually proves the effect is pervasive.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "CPS Robustness of Main Results"
**Page:** 20
- **Formatting:** Standard robustness table.
- **Clarity:** Lists alternative estimators and samples clearly.
- **Storytelling:** Standard "defensive" exhibit.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Alternative Inference Methods"
**Page:** 21
- **Formatting:** Busy but necessary.
- **Clarity:** Direct comparison of p-values.
- **Storytelling:** Addresses the "small number of treated states" critique head-on.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Leave-One-Treated-State-Out: Gender DDD"
**Page:** 21
- **Formatting:** Professional.
- **Clarity:** Excellent.
- **Storytelling:** Proves no single state (like CA or CO) is driving the result.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 10: "Salary Transparency Law Adoption"
- **Recommendation:** **KEEP AS-IS** (Essential reference).

### Table 11: "Pre-Treatment Balance"
- **Recommendation:** **KEEP AS-IS** (Standard requirement).

### Table 12: "CPS Event Study Coefficients"
- **Recommendation:** **KEEP AS-IS** (Supports Figure 3).

### Table 13: "Heterogeneity by Occupation Bargaining Intensity"
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - The mechanism argument (Information vs. Bargaining) is the most "Economic" part of the paper. This table should follow Table 5 in the main text.

### Table 14: "CPS Treatment Effects by Cohort"
- **Recommendation:** **KEEP AS-IS** (Good for transparency).

### Figure 8, 9, 10: "QWI Trends/Event Studies"
- **Recommendation:** **REVISE**
  - These are where the raw sawtooth data belong. However, even in the appendix, the event study plots (9 & 10) are extremely hard to read because of the quarterly fluctuations. Consider presenting the coefficient plots on seasonally adjusted data.

---

## Overall Assessment

- **Exhibit count:** 8 main tables, 7 main figures, 6 appendix tables, 4 appendix figures.
- **General quality:** High. The paper follows the "gold standard" for DiD papers (Callaway-Sant’Anna, parallel trends plots, event studies, and permutation tests).
- **Strongest exhibits:** Table 4 & 5 (the side-by-side QWI/CPS comparison) and Figure 3 (CPS trends).
- **Weakest exhibits:** Figure 2 and Figure 9/10. The seasonal "sawtooth" in the quarterly QWI data is very distracting and makes it look like the pre-trends might be failing, even if the regressions say otherwise.

**Missing exhibits:**
- **A Policy Detail Table:** A table summarizing the *penalties* or *enforcement* of each law would be interesting for the mechanism (though Table 10 is a good start).

**Top 3 Improvements:**
1.  **Deseasonalize Figures 2, 9, and 10.** Use a 4-quarter moving average or regression-based seasonal adjustment. The raw sawtooth pattern in the main text is the biggest barrier to a reader's "10-second parse."
2.  **Consolidate Main Text.** Move Table 6 (Labor Market Flow Nulls) and Table 7 (Industry Heterogeneity) to the appendix, as their content is already better summarized by Figures 5 and 6 respectively.
3.  **Mechanism Promotion.** Move Table 13 (CPS Bargaining Intensity) to the main text. The distinction between "posted wage" industries and "negotiated" industries is the core of the theoretical contribution.