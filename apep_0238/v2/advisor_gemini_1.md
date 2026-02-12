# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T14:36:23.656676
**Route:** Direct Google API + PDF
**Tokens:** 32878 in / 919 out
**Response SHA256:** 4488d4eaa001ccc8

---

I have reviewed the draft paper "Demand Recessions Scar, Supply Recessions Don’t: Evidence from State Labor Markets" for fatal errors.

### FATAL ERROR 1: Internal Consistency
- **Location:** Table 1 (Summary Statistics), Page 14.
- **Error:** The reported sample size (N) for "Labor force participation rate (%)" is 5,880. In the notes, the author explains this is because data is "available for 20 states." However, the abstract and Section 4.1 claim the study covers "all 50 states." Furthermore, Figure 2 (Page 24) displays a Labor Force Participation IRF that appears to be estimated using the same sample as the unemployment rate.
- **Fix:** Clarify if the participation analysis is restricted to a 20-state sub-sample. If it is, the claims in the Abstract and Intro regarding the scope (50 states) must be qualified to reflect that participation data is missing for 60% of the sample.

### FATAL ERROR 2: Internal Consistency
- **Location:** Table 3 (Local Projection Estimates), Page 20 vs. Figure 1 (IRF), Page 23.
- **Error:** In Table 3, Panel B (COVID Recession), the coefficient at $h=3$ is **positive** ($0.5586^{**}$). However, Figure 1 (Panel B) shows the COVID IRF (red dashed line) spiking **sharply downward** (negative) at short horizons. Similarly, Table 3, Panel A shows negative coefficients for the Great Recession, but Figure 1, Panel A shows a blue line that is very close to zero and then dips, which does not visually match the magnitude of the $-0.07$ coefficients reported in the table.
- **Fix:** Ensure the sign convention in the tables matches the visualization. The text on Page 16 explains that for COVID, a positive coefficient indicates a larger employment drop (due to the negative instrument), but the Figure plots "Employment response," which should logically show a decline for a recession. The visual and tabular results are currently contradictory.

### FATAL ERROR 3: Data-Design Alignment
- **Location:** Table 3, Panel B, Page 20.
- **Error:** The table reports results for $h=48$ for the COVID recession. Given that the COVID peak is defined as February 2020 (Page 13), $h=48$ corresponds to February 2024. While the data covers through June 2024, the note for Table 3 states: "COVID horizons beyond $h=48$ are not reported because the post-peak observation window extends only 52 months." However, looking at the IRF in Figure 1, Panel B, the data points continue to $h=50+$. This is a minor alignment issue, but the **internal inconsistency** between the Table (ending at 48) and the Figure (continuing past 48) suggests a lack of clarity on the final data boundary for the COVID sample.
- **Fix:** Standardize the maximum horizon reported for the COVID sample across all tables and figures.

### FATAL ERROR 4: Regression Sanity
- **Location:** Table 8, Panel B (Unemployment Rate Response), Page 56.
- **Error:** The coefficient for $h=3$ is $-0.3824^{**}$ with a standard error of $0.1614$. In Section 6.2 (Page 21), the author states the Bartik instrument has a standard deviation of $0.029$. This implies a 1-SD shock increases the unemployment rate by approximately $0.38 \times 0.029 = 0.011$ percentage points. However, Figure 2 (Page 24, Panel B) shows a "1-SD effect" on the unemployment rate of approximately **-1.5 percentage points**. There is a massive order-of-magnitude discrepancy between the regression table and the IRF visualization.
- **Fix:** Re-check the scaling of coefficients in the regression tables versus the scaling used to produce the IRF plots.

**ADVISOR VERDICT: FAIL**