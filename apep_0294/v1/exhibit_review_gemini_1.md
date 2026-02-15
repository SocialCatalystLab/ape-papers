# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-15T01:15:02.623418
**Route:** Direct Google API + PDF
**Tokens:** 21517 in / 2388 out
**Response SHA256:** 96b077e313ab815c

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "T-MSIS Medicaid Provider Spending Dataset Overview"
**Page:** 4
- **Formatting:** Clean and professional. Adheres to top-journal standards (AER/QJE) with minimal horizontal lines and no vertical lines.
- **Clarity:** Excellent summary of dataset scale.
- **Storytelling:** Vital for an "introductory" or "data" paper. It establishes the "N" immediately.
- **Labeling:** Clear. Notes explain acronyms and the nuance of active vs. cumulative NPIs.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Medicaid Spending by Service Category"
**Page:** 7
- **Formatting:** Numbers are mostly right-aligned but could be better decimal-aligned (e.g., "367.6" vs "1093.6"). 
- **Clarity:** Logical sorting by spending amount.
- **Storytelling:** Directly supports the core claim that Medicaid is fundamentally different from Medicare by highlighting the prevalence of T, H, and S codes.
- **Labeling:** Good notes. Axis/Header labels are clear.
- **Recommendation:** **REVISE**
  - Decimal-align all numeric columns to improve readability of magnitudes.

### Table 3: "Top 15 HCPCS Codes by Total Medicaid Spending, 2018–2024"
**Page:** 8
- **Formatting:** Professional. The multi-line "Description" column is handled well.
- **Clarity:** Shows the dominance of T1019. 
- **Storytelling:** This is a crucial "fact-finding" table. However, it is slightly redundant with Figure 10 in the appendix.
- **Labeling:** Clear. 
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Medicaid Spending by Service Category, 2018–2024"
**Page:** 9
- **Formatting:** Professional "stacked area" style. Use of colors is distinct.
- **Clarity:** It is difficult to distinguish the smaller categories at the top. The legend is quite large and takes up significant space.
- **Storytelling:** Shows the stability of spending over time. 
- **Labeling:** The y-axis "Monthly Spending (Billions)" is clear. The source note is well-placed.
- **Recommendation:** **REVISE**
  - Group the bottom 5-6 categories into an "Other" category for this figure to reduce visual noise. The reader cannot distinguish "Orthotics" from "DME" in this format.

### Figure 2: "Monthly Medicaid Provider Spending, 2018–2024"
**Page:** 10
- **Formatting:** High quality. Annotated vertical lines for policy events are standard for AER/AEJ.
- **Clarity:** The trend is unmistakable.
- **Storytelling:** Central to the "Growth Trajectory" section.
- **Labeling:** Descriptive title and notes. 
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Annual Growth in Medicaid Provider Spending"
**Page:** 11
- **Formatting:** The use of "—" for 2018 and 2024 growth rates is appropriate given the data constraints mentioned in the notes.
- **Clarity:** Good use of percentage change columns next to raw values.
- **Storytelling:** Quantifies the "doubling" mentioned in the text.
- **Labeling:** Notes are comprehensive regarding the 2024 data truncation.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "COVID-19 Claims Disruption and Recovery"
**Page:** 12
- **Formatting:** Clean line plot with markers. The "45% drop" annotation is helpful.
- **Clarity:** High. 
- **Storytelling:** Provides the "Natural Experiment" hook for researchers.
- **Labeling:** X-axis labels (Feb 2019, May 2019, etc.) are a bit sparse; adding more tick marks might help pinpoint the recovery month more precisely.
- **Recommendation:** **KEEP AS-IS** (or minor tick adjustment)

### Figure 4: "Distribution of Provider Tenure in the T-MSIS Panel"
**Page:** 13
- **Formatting:** Professional histogram. Use of a different color/dashed line for the "Full Panel" (84 months) is excellent.
- **Clarity:** Very high. The "U-shape" (many short-term, many full-term) is clear.
- **Storytelling:** Supports the "Dynamic Workforce" argument.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Provider Panel Properties: Tenure and Spending Concentration"
**Page:** 13
- **Formatting:** Clean.
- **Clarity:** This table effectively "explains" Figure 4 by adding the "Percent of Spending" dimension.
- **Storytelling:** Crucial takeaway: 17.5% of providers (long-term) account for 78% of spending.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Provider Entry, Exit, and Active Count, 2018–2024"
**Page:** 14
- **Formatting:** Two-panel vertical layout.
- **Clarity:** The bottom panel (Entry/Exit) is slightly cluttered with many thin bars. 
- **Storytelling:** Essential for the churn argument.
- **Labeling:** Legend is embedded in the text note; would be better as a small floating legend or distinct labels.
- **Recommendation:** **REVISE**
  - In the bottom panel, use a slightly thicker bar width or group by quarter to reduce the "jittery" look of the monthly bars.

### Figure 6: "Distribution of Cumulative Provider Payments (Log Scale)"
**Page:** 15
- **Formatting:** Standard "bell curve" appearance for log-normal data.
- **Clarity:** Good. The x-axis labels with "$" signs are helpful.
- **Storytelling:** Illustrates the extreme skew/concentration.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Billing Structure: Organizational Relationships in T-MSIS"
**Page:** 16
- **Formatting:** Professional.
- **Clarity:** Clear categorization.
- **Storytelling:** This is one of the most original contributions of the paper (Type 1 vs Type 2 logic).
- **Labeling:** Notes define "Solo" and "Organization billing" well.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Cumulative Medicaid Provider Spending per Capita by State, 2018–2024"
**Page:** 17
- **Formatting:** Professional choropleth map. The color scale (viridis-style) is journal-ready.
- **Clarity:** Very high.
- **Storytelling:** Highlights the massive geographic heterogeneity (NY/DC/AK vs the South).
- **Labeling:** Legend is clear. 
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "The T-MSIS Linkage Universe"
**Page:** 19
- **Formatting:** Clean flow-chart style.
- **Clarity:** Could be overwhelming, but the color-coded arrows (NPI, ZIP, TIN/EIN) help organize the "channels."
- **Storytelling:** This is the "Money Shot" of the paper. It transforms the data from a single file to a research ecosystem.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 7: "T-MSIS Medicaid Provider Spending: Complete Field Definitions"
**Page:** 31
- **Recommendation:** **KEEP AS-IS** — Essential for a data paper.

### Table 8: "NPPES Fields Extracted for T-MSIS Enrichment"
**Page:** 32
- **Recommendation:** **KEEP AS-IS**

### Table 9: "HCPCS Code Categories in T-MSIS Data"
**Page:** 33
- **Recommendation:** **KEEP AS-IS**

### Table 10: "Confirmed Accessible Datasets for T-MSIS Linkage"
**Page:** 37
- **Recommendation:** **KEEP AS-IS** — High value for the "Research Agenda" section.

### Figure 9: "Growth in HCPCS Code Diversity, 2018–2024"
**Page:** 38
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Top 10 HCPCS Codes by Total Spending"
**Page:** 39
- **Formatting:** Horizontal bar chart.
- **Storytelling:** Redundant with Table 3.
- **Recommendation:** **REMOVE** or **MOVE TO MAIN TEXT** (If the author prefers visual over tabular, but having both is unnecessary).

### Figure 11: "Spending by Billing Structure"
**Page:** 39
- **Storytelling:** Redundant with Table 6.
- **Recommendation:** **REMOVE**

---

## Overall Assessment

- **Exhibit count:** 6 Main Tables, 8 Main Figures, 4 Appendix Tables, 3 Appendix Figures.
- **General quality:** Extremely high. The paper follows the visual style of a "Data & Methods" feature in the *AER* or a descriptive piece in *JEP*.
- **Strongest exhibits:** Figure 8 (Linkage Universe) and Figure 7 (State Map). They convey the paper's value proposition immediately.
- **Weakest exhibits:** Figure 5 (Bottom panel is visually "noisy") and the redundant Appendix Figures (10 and 11).
- **Missing exhibits:** A **"Summary Statistics" table** that includes characteristics of the matched NPPES data (e.g., % of providers that are Physicians vs. Home Health Agencies) would bridge the gap between Section 2 and Section 3.

### Top 3 Improvements:
1. **Reduce Redundancy:** Remove Appendix Figures 10 and 11 as they replicate Tables 3 and 6 exactly. Use the saved space for a new summary table on provider specialties.
2. **Visual Refinement of Figure 1:** Aggregate the "long tail" of service categories into "Other" to make the primary categories (CPT, T, H, S codes) more visually distinct.
3. **Alignment in Tables:** Ensure all numeric columns in Tables 2, 3, and 4 are decimal-aligned to maintain the professional "look and feel" of a top-tier journal.