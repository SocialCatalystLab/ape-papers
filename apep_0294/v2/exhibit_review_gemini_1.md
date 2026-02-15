# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-15T08:55:46.014261
**Route:** Direct Google API + PDF
**Tokens:** 21517 in / 2696 out
**Response SHA256:** 65a92b5e63c39a7c

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "T-MSIS Medicaid Provider Spending Dataset Overview"
**Page:** 4
- **Formatting:** Generally professional, but the "Value" column contains mixed types (strings, dates, counts, and currency). The alignment is left-justified; it should be decimal-aligned or right-aligned for numeric values.
- **Clarity:** Excellent. It provides a high-level "fact sheet" for the data.
- **Storytelling:** Strong. It immediately establishes the massive scale of the dataset ($1.09 trillion).
- **Labeling:** Clear. The notes explain "Cell suppression" and "Active months," which are crucial for interpretation.
- **Recommendation:** **REVISE**
  - Right-align or decimal-align all numbers in the "Value" column.
  - Add a thousands separator to "10881" to match other counts.

### Table 2: "Medicaid Spending by Service Category"
**Page:** 7
- **Formatting:** Good use of horizontal rules. The "Codes" column should have a thousands separator.
- **Clarity:** Very clean. The categorical breakdown is logical.
- **Storytelling:** This is the "hook" of the paper. It proves that Medicaid is not just "Medicare for poor people" by showing the dominance of T, H, and S codes.
- **Labeling:** Good. The notes define the prefixes clearly.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Top 15 HCPCS Codes by Total Medicaid Spending, 2018–2024"
**Page:** 8
- **Formatting:** Professional. Multi-line descriptions (Rank 3, 5, 6) are handled well with hanging indents.
- **Clarity:** High. Readers can immediately see that Personal Care (T1019) is the dominant service.
- **Storytelling:** Essential. It supports the claim that the Medicaid workforce is distinct from the physician-heavy Medicare workforce.
- **Labeling:** Comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Medicaid Spending by Service Category, 2018–2024"
**Page:** 9
- **Formatting:** Modern "ggplot" style. The legend is at the bottom, which is standard. 
- **Clarity:** The stacked area chart is effective for showing total growth while maintaining relative shares. However, the color "Other" (grey) blends into the gridlines.
- **Storytelling:** Shows the stability of the program's composition over time.
- **Labeling:** Y-axis is clearly labeled in Billions. X-axis years are well-placed.
- **Recommendation:** **REVISE**
  - Increase the contrast between the "Other" (grey) and "Behavioral Health" (teal) categories.
  - Remove the internal chart title ("Medicaid Spending by Service Category...") as it is redundant with the figure caption below.

### Figure 2: "Monthly Medicaid Provider Spending, 2018–2024"
**Page:** 10
- **Formatting:** Clean line chart. The annotation of policy events is excellent for an AER/QJE style paper.
- **Clarity:** The "COVID-19" shaded region and "Medicaid Unwinding" dashed line make the shocks immediately visible.
- **Storytelling:** Documents the $10B to $18B growth trajectory.
- **Labeling:** Excellent. The note about December 2024 exclusion is critical.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Annual Growth in Medicaid Provider Spending"
**Page:** 11
- **Formatting:** Standard economic table.
- **Clarity:** The use of "% $\Delta$" columns helps the reader parse the growth story without doing mental math.
- **Storytelling:** Complements Figure 2 with exact numbers. 
- **Labeling:** The note regarding the 2024 understatement is very important for transparency.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "COVID-19 Claims Disruption and Recovery"
**Page:** 12
- **Formatting:** Professional. Use of an index (Jan 2020 = 100) is standard for identifying shocks.
- **Clarity:** The 45% drop is labeled directly on the chart—excellent for "10-second parsing."
- **Storytelling:** Tightens the focus on the most dramatic event in the sample.
- **Labeling:** X-axis labels (Feb 2019, etc.) are sparse but sufficient.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Distribution of Provider Tenure in T-MSIS Panel"
**Page:** 13
- **Formatting:** Histogram is clean. The annotation for the "Full panel" spike (84 months) is helpful.
- **Clarity:** The "bimodal" nature (lots of short-term, a small group of long-term) is clear.
- **Storytelling:** Supports the "extraordinary dynamism" fact mentioned in the abstract.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Provider Panel Properties: Tenure and Spending Concentration"
**Page:** 14
- **Formatting:** Clean. 
- **Clarity:** The juxtaposition of "% of Providers" vs. "% of Spending" is powerful. 
- **Storytelling:** It shows that while 38% of providers are short-term (from Figure 4), the 17.5% "permanent" providers account for 78% of the money. This is a vital nuance.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Provider Entry, Exit, and Active Count, 2018–2024"
**Page:** 15
- **Formatting:** Two-panel vertical stack. 
- **Clarity:** The bottom panel (Entry/Exit) is a bit "noisy." The red and green bars overlapping the zero-axis can be hard to read at the very end (2024).
- **Storytelling:** Shows that the workforce isn't just growing—it is churning.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - In the bottom panel, add a horizontal line at y=0 that is thicker/darker to clearly separate entry from exit.
  - The "2025" tick mark on the X-axis is slightly misleading since data ends in 2024; consider ending the axis at "2024".

### Figure 6: "Distribution of Cumulative Provider Payments (Log Scale)"
**Page:** 16
- **Formatting:** Log-scale histogram.
- **Clarity:** The X-axis labels ($100, $1,000, etc.) are well-placed. 
- **Storytelling:** Illustrates the extreme inequality/skewness in payments.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Billing Structure: Organizational Relationships in T-MSIS"
**Page:** 16
- **Formatting:** Professional.
- **Clarity:** Distinguishes between who does the work and who gets the check.
- **Storytelling:** Supports the argument that "Agencies" are the primary economic actors in Medicaid HCBS.
- **Labeling:** The definitions in the notes (Type 2 organizations) are helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Cumulative Medicaid Provider Spending per Capita by State, 2018–2024"
**Page:** 17
- **Formatting:** Choropleth map.
- **Clarity:** The Viridis color scale is excellent for accessibility. Legend is clear.
- **Storytelling:** Reveals geographic heterogeneity (e.g., high spending in the Northeast/Minnesota, low in the South).
- **Labeling:** Per capita units ($K) are clearly defined.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "The T-MSIS Linkage Universe"
**Page:** 19
- **Formatting:** Flowchart/Architecture diagram.
- **Clarity:** A bit busy, but use of color-coded arrows (teal, orange, purple) for different join types is a very clever way to simplify a complex concept.
- **Storytelling:** This is the "infrastructure" exhibit. It justifies the "New Frontier" part of the title.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 7: "T-MSIS Medicaid Provider Spending: Complete Field Definitions"
**Page:** 32
- **Formatting:** Standard data dictionary format.
- **Clarity:** High.
- **Storytelling:** Essential for researchers wanting to use the data.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "NPPES Fields Extracted for T-MSIS Enrichment"
**Page:** 33
- **Formatting:** Clean.
- **Clarity:** Explains *why* each field was kept (e.g., "Critical for provider-type stratification").
- **Storytelling:** Connects the raw data to the research potential described in Section 4.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "HCPCS Code Categories in T-MSIS Data"
**Page:** 34
- **Formatting:** Mapping table.
- **Clarity:** Very useful examples.
- **Recommendation:** **KEEP AS-IS**

### Table 10: "Confirmed Accessible Datasets for T-MSIS Linkage"
**Page:** 38
- **Formatting:** The table title is actually *below* the table in the PDF (p. 38), whereas other tables have titles above.
- **Clarity:** Good summary of file sizes and access methods.
- **Recommendation:** **REVISE**
  - Move the title "Table 10: Confirmed Accessible Datasets..." to the top of the table for consistency with Tables 1-9.

### Figure 9: "Growth in HCPCS Code Diversity, 2018–2024"
**Page:** 39
- **Formatting:** Line chart.
- **Clarity:** Shows the "expanding code universe."
- **Storytelling:** A bit marginal compared to other results, but good for an appendix.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 6 main tables, 8 main figures, 4 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. The exhibits are clearly influenced by the "Goldin/Chetty" style of descriptive evidence: clean, annotated, and focused on "The Facts."
- **Strongest exhibits:** Figure 2 (Policy annotations), Table 2 (The T/H/S code discovery), and Figure 8 (Linkage architecture).
- **Weakest exhibits:** Figure 5 (Bottom panel is a bit cluttered), Figure 1 (Grey color contrast).
- **Missing exhibits:** 
    1. **A "Summary Statistics" table** at the *provider level* (Mean/SD of annual revenue, number of unique HCPCS codes per provider, etc.) would be standard for a top journal.
    2. **A "Comparison Table"**: A side-by-side table comparing the T-MSIS top 10 codes vs. Medicare top 10 codes would be more "punchy" than the text-based comparison in Section 3.6.

- **Top 3 improvements:**
  1. **Decimal-align Table 1:** It’s the first exhibit; making it look "AER-perfect" with proper numeric alignment sets the tone.
  2. **Enhance Figure 1 contrast:** Ensure that the "Other" category doesn't disappear into the background so the reader can see the total volume clearly.
  3. **Fix Table 10 Header:** Ensure consistency in table titling across the appendix.