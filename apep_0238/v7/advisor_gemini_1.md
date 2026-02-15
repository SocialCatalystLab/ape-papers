# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-15T10:10:18.352768
**Route:** Direct Google API + PDF
**Tokens:** 34958 in / 791 out
**Response SHA256:** 31f7bbd77151e00e

---

I have reviewed the draft paper "Demand Recessions Scar, Supply Recessions Don’t: Evidence from State Labor Markets" for fatal errors.

**FATAL ERROR 1: Regression Sanity**
- **Location:** Table 14, Panel B (page 58)
- **Error:** The coefficient for the COVID "log(emp)" specification at horizon $h=6$ is $-0.5286$ with a standard error of $0.2637$. This is a log outcome. A coefficient of $-0.52$ implies a 52 log point (approximately 40%) decline in employment *due to a one-standard-deviation change in the instrument* at 6 months. This contradicts the summary statistics in Table 1 (page 12), where the average peak-to-trough decline for COVID is reported as $15.5\%$ ($-0.1547$ log points). A regression coefficient cannot be three times larger than the raw maximum average peak-to-trough decline of the entire shock.
- **Fix:** Re-examine the scaling of the COVID Bartik instrument in the Table 14 regressions. It appears the "raw" instrument was used without the standardization ($SD=1$) applied in the main results (Table 3), leading to implausible magnitudes.

**FATAL ERROR 2: Internal Consistency**
- **Location:** Table 3, Panel B (page 18) vs. Table 14, Panel B (page 58)
- **Error:** The results for the baseline COVID employment specification are inconsistent between tables. Table 3, Panel B reports $\hat{\beta}_6 = -0.0123$ (Standardized $SD=1$). Table 14, Panel B reports $\log(emp)$ at $h=6$ as $-0.5286$. Even accounting for standardization, the standard errors are wildly different: $(0.0061)$ in Table 3 vs $(0.2637)$ in Table 14. These are ostensibly the same regression model.
- **Fix:** Ensure the baseline specification is identical across both tables or clarify why the sample/scaling differs so drastically for the "baseline" row in the Appendix.

**FATAL ERROR 3: Regression Sanity**
- **Location:** Table 13, Panel B (page 54)
- **Error:** Coefficients for Labor Force Participation Rate (LFPR) are mathematically impossible. At $h=3$, the coefficient is $31.6275$. Since the outcome is "change in labor force participation rate (percentage points)," this implies a 1-unit change in the raw Bartik instrument leads to a 31 percentage point change in LFPR. Given the Bartik SD is $\approx 0.023$, the "Effect per 1-SD" is reported as $0.7369$, but the underlying regression coefficient of $31.6$ suggests a model that is extremely unstable or poorly identified.
- **Fix:** Check for collinearity or insufficient variation in the state-level participation data.

**FATAL ERROR 4: Completeness**
- **Location:** Table 12, Panel B (page 53)
- **Error:** Placeholder/Missing Value. Column $h=60$ for $N(COVID)$ contains a placeholder footnote "—a". The footnote text indicates the horizon exceeds the window, but the cell is effectively empty/TBD.
- **Fix:** Remove the empty column for COVID in this table if the data does not exist, rather than leaving a placeholder "—a".

**ADVISOR VERDICT: FAIL**