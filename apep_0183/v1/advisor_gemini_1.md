# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview
**Paper:** paper.pdf
**Timestamp:** 2026-02-04T03:04:12.284551
**Route:** Direct Google API + PDF
**Tokens:** 21438 in / 1028 out
**Response SHA256:** bdad7c279cee1d75

---

I have reviewed the draft paper "High on Employment? A Spatial Difference-in-Discontinuities Analysis of Marijuana Legalization and Industry-Specific Labor Market Effects" for fatal errors.

**FATAL ERROR 1: Data-Design Alignment**
- **Location:** Section 4.1 (page 9) and Section 6.1 (page 13).
- **Error:** The paper claims to use "6 years of post-treatment data (Q1 2014–Q4 2019)" to estimate the effects of retail openings in Colorado (January 2014) and Washington (July 2014). However, the DiDisc model (Equation 8, page 11) utilizes a single "Post-treatment" dummy ($P_t$). For the Washington cohort, Q1 2014 and Q2 2014 are *pre-treatment* periods (retail opened July 2014), but the data description and the Main DiDisc Estimates (Table 2) treat 2014–2019 as a monolithic post-period.
- **Fix:** Redefine the $P_t$ dummy to be cohort-specific (relative to actual retail opening dates) or explicitly exclude the 2014 quarters that are pre-treatment for Washington from the "Post" definition to avoid treatment contamination.

**FATAL ERROR 2: Internal Consistency**
- **Location:** Figure 2 (page 28) and Figure 3 (page 29).
- **Error:** Figure 2 shows raw trends where "Treated Border Counties" (red line) have significantly **higher** earnings than "Control Border Counties" (blue line) throughout the entire sample (approx. $200–$300 difference). However, Figure 3 (Event Study) shows a point estimate at $e = -12$ of approximately **-0.12 (negative 12%)**. If the treated counties have higher earnings, the baseline difference (relative to the reference period $e=-1$) should not be a deep negative value unless there was a massive convergence/divergence not visible in the raw trends. Furthermore, Figure 3 shows a "Pre-Treatment" average clearly below zero, which contradicts the text on page 14 stating "pre-treatment coefficients oscillate around zero."
- **Fix:** Re-run the event study specification. Ensure the reference period normalization ($e=-1$) is applied correctly and that the plot reflects the level differences shown in the raw data.

**FATAL ERROR 3: Regression Sanity / Internal Consistency**
- **Location:** Table 4 (page 35) and Abstract (page 1).
- **Error:** The Abstract reports an aggregate effect of $\hat{\tau} = -3.1\%$ with $SE = 6.2\%$. Table 4 reports industry-specific results. For "Information (51)", the table shows $\hat{\tau} = -0.130$ (which is -13%) with $SE = 0.030$. However, the $q_{FDR}$ for this result is listed as 0.03. In a sample of 9 tests, a p-value of 0.001 (as listed) should yield a much smaller FDR-adjusted q-value if it is the only significant result. More critically, the text in Section 6.4 (page 14) and the Abstract claim the result is significant, but the provided Standard Error ($0.030$) and Coefficient ($-0.130$) in Table 4 would imply a t-stat of 4.33, while the figure (Figure 5, page 31) shows the confidence interval for Information nearly touching zero.
- **Fix:** Re-calculate and harmonize coefficients, SEs, and p-values across Table 4, Figure 5, and the Abstract.

**FATAL ERROR 4: Internal Consistency**
- **Location:** Figure 2 Caption (page 28) and Section 2.1 (page 4).
- **Error:** Section 2.1 correctly identifies Washington's retail opening as July 2014 (Q3). However, the caption for Figure 2 states "Vertical dashed lines indicate retail opening dates for Colorado (2014 Q1) and Washington (2014 Q3)", but the graph itself only shows two dashed lines very close together near the start of 2015, and the data points for 2014 do not show the break-out consistent with the Q1/Q3 split mentioned.
- **Fix:** Align the vertical indicators in Figure 2 with the dates stated in the text.

**ADVISOR VERDICT: FAIL**