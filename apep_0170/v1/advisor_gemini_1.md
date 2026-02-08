# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview
**Paper:** paper.pdf
**Timestamp:** 2026-02-03T20:04:12.568899
**Route:** Direct Google API + PDF
**Tokens:** 17798 in / 1184 out
**Response SHA256:** 266bdac072445270

---

I have reviewed the draft paper "Do Salary History Bans Reduce Wage Inequality? Evidence from Staggered State Adoptions" for fatal errors. Below is my assessment.

### 1. DATA-DESIGN ALIGNMENT
*   **Treatment Timing vs. Data Coverage:** The paper claims to study the 2023 adoption in Rhode Island (Table 1, Table 10). However, Section 3.1 and the notes for Table 11 explicitly state that the ACS `INCWAGE` variable measures income from the "previous 12 months." This means 2023 survey data reflects 2022 wages. Consequently, there is **zero** post-treatment data for the Rhode Island 2023 cohort. While the author acknowledges this in Section 3.3 and excludes the cohort from specific sub-tables, including it in the primary "Adoption Timeline" (Table 1) and implying it is part of the "sixteen states" studied (Abstract) is a design misalignment.
*   **Post-treatment Observations:** As noted by the author in Table 11, the 2022 cohort (Nevada) has "effectively 0-1 true post-treatment observations" due to the income lag. This means the 2022 and 2023 cohorts cannot contribute to the estimation of treatment effects in a DiD framework with the current data.

### 2. REGRESSION SANITY
*   **Observations (N) Consistency:** In Table 3, Panel B (Job Changers Only), the number of observations is listed as **600**. In Table 2 (Summary Statistics), the author states there are 3,800,000 individual observations for job changers, but the unit of analysis is state-year cells. Since the sample of job changers is a subset of "All Workers," it is highly improbable that every single state-year cell (600 total) still contains enough job changers to meet the author's own "minimum 100 observations" inclusion threshold defined on page 14. If any state-year cell had fewer than 100 job changers, N should be < 600.
*   **Coefficient Magnitude:** Log outcome coefficients and standard errors appear within reasonable bounds (e.g., -0.050). No "NaN" or impossible R² values were detected.

### 3. COMPLETENESS
*   **Missing Analysis/Results:** Section 6.1 mentions a "**Figure 2**" that "plots raw trends in the 90-10 gap for treated versus control states." However, the provided Figure 2 (page 22) is a plot of "Pre-Treatment Trends" with a vertical line at 2017. While it shows the data, it does not clearly show the "raw trends" through the end of the sample period as described, nor does it visually distinguish between the different treatment cohorts effectively to validate the parallel trends across the staggered timeline.

### 4. INTERNAL CONSISTENCY
*   **Sample Sizes:** In Table 2, the number of "Individual observations" for "All Workers" is **24,500,000**. On page 14, the text refers to "**24.5 million** individual observations." This matches.
*   **State Inclusion:** Table 1 lists 18 rows. Notes state Alabama and Virginia are excluded. 18 - 2 = 16. This matches the Abstract's claim of "sixteen US states."
*   **Estimated Effects:** The Abstract claims a reduction of "**approximately 0.05 log points**." Table 3, Column 1 shows -0.045 (TWFE) and -0.050 (CS). This is consistent.

---

**FATAL ERROR 1: Data-Design Alignment**
*   **Location:** Table 1 (page 6), Table 10 (page 30), and Abstract.
*   **Error:** The design includes Rhode Island (treated Jan 2023). Because ACS 2023 data reflects 2022 wages (due to the 12-month lookback of `INCWAGE`), there is no post-treatment data for this cohort.
*   **Fix:** Remove the 2023 cohort (Rhode Island) from the primary treatment definition and adjust the count of treated states in the Abstract/Introduction from sixteen to fifteen.

**FATAL ERROR 2: Internal Consistency / Regression Sanity**
*   **Location:** Table 3, Panel B (page 16) vs. Section 3.5/4.2 (page 14).
*   **Error:** Table 3 Panel B reports exactly **600** state-year observations for the "Job Changers" sample. On page 14, the author states that state-year cells with fewer than 100 observations are excluded. It is statistically impossible for the "Job Changers" subset (which is ~15% of the total sample per Table 2) to maintain the exact same number of valid state-year cells as the "All Workers" sample across all 50 states and 12 years. 
*   **Fix:** Re-calculate the actual number of state-year cells that meet the N>100 threshold for the Job Changers sample and update the "Observations" row in Table 3, Panel B.

**ADVISOR VERDICT: FAIL**