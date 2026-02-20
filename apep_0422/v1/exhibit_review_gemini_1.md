# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T11:35:23.867263
**Route:** Direct Google API + PDF
**Tokens:** 18917 in / 2065 out
**Response SHA256:** a02bfb110bd3d6f7

---

This review evaluates the visual exhibits of the paper "Can Clean Cooking Save Lives? Evidence from India’s Ujjwala Yojana" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Generally clean. However, the horizontal lines at the very top and bottom are double lines; top journals typically prefer single heavy lines (Booktabs style). Panel labels are clear.
- **Clarity:** Excellent. Grouping by Clean Fuel, Health, Education, and Treatment makes the data highly digestible.
- **Storytelling:** Essential. It clearly shows the massive jump in clean fuel (29.8% to 54.0%) which is the "first stage" story.
- **Labeling:** Variable names are intuitive. Note includes survey years and the definition of the main treatment variable.
- **Recommendation:** **KEEP AS-IS** (with minor line-style adjustment).

### Table 2: "First Stage: Ujjwala Exposure and Clean Fuel Adoption"
**Page:** 12
- **Formatting:** Standard regression format. Numbers are decimal-aligned.
- **Clarity:** Logical progression from raw correlation (1) to controls (2) to state FE (3).
- **Storytelling:** This is the core validation of the instrument. The drop in the coefficient from 44 to 14 when adding state FE is a crucial piece of the identification story.
- **Labeling:** "delta_clean_fuel" is a programming variable name; it should be renamed "$\Delta$ Clean Fuel Adoption (pp)" for publication.
- **Recommendation:** **REVISE**
  - Rename "delta_clean_fuel" to "$\Delta$ Clean Fuel Usage (pp)".
  - Replace "state_code" with "State Fixed Effects".
  - Remove "delta_" from variable names in the header.

### Figure 1: "First Stage: Baseline Solid Fuel Dependence Predicts Clean Fuel Adoption"
**Page:** 13
- **Formatting:** Modern ggplot style. The use of transparency (alpha) for the scatter points prevents overplotting.
- **Clarity:** The message is clear in 5 seconds: "higher baseline gap = more adoption."
- **Storytelling:** Strong visual evidence for Table 2.
- **Labeling:** Clear axis labels with units. Source and N are included.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Clean Fuel Adoption by Ujjwala Exposure Tercile"
**Page:** 13
- **Formatting:** Clean. Line weights are good.
- **Clarity:** Very high. It clearly shows the "convergence" mentioned in the text.
- **Storytelling:** Potentially redundant with Figure 1. Figure 1 shows the continuous relationship; this shows the categorical mean. In a top journal, these are often combined into one multi-panel figure.
- **Recommendation:** **REVISE**
  - Consolidate Figure 1 and Figure 2 into a single "Figure 1: First Stage Evidence" with Panel A (Scatter) and Panel B (Tercile Means).

### Table 3: "Reduced Form: Ujjwala Exposure and Child Health Outcomes"
**Page:** 14
- **Formatting:** Consistent with Table 2.
- **Clarity:** The juxtaposition of Diarrhea (null) vs. Stunting/Underweight (significant) is clear.
- **Storytelling:** The core of the "Clean cooking saves lives" argument.
- **Labeling:** Same issue as Table 2: "delta_diarrhea" should be "$\Delta$ Diarrhea Prevalence".
- **Recommendation:** **REVISE**
  - Clean up variable labels (remove underscores and "delta_").

### Figure 3: "Child Health Outcomes by Ujjwala Exposure Tercile"
**Page:** 15
- **Formatting:** Three-panel layout. Color coding is consistent with Figure 2.
- **Clarity:** Excellent visual representation of the convergence in stunting and underweight.
- **Storytelling:** Crucial. It shows that the "improvement" in stunting in high-exposure districts is actually a catch-up to the low-exposure districts.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "IV Estimates: Clean Fuel Adoption and Child Health"
**Page:** 16
- **Formatting:** Standard IV table. Reports the first-stage F-stat, which is mandatory.
- **Clarity:** Good.
- **Storytelling:** This provides the LATE (0.59 reduction in stunting per 1pp adoption). This is the "headline number" of the paper.
- **Labeling:** Variable names need cleaning.
- **Recommendation:** **KEEP AS-IS** (subject to variable name cleaning).

### Table 5: "Controlling for Concurrent Infrastructure Changes"
**Page:** 17
- **Formatting:** Standard.
- **Clarity:** The "Horse Race" is clear.
- **Storytelling:** This is the most honest table in the paper. It shows the Ujjwala effect disappearing when controlling for water. In top journals, this often moves from "Robustness" to a "Main Result" because it highlights the identification challenge.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Placebo Test: Real vs. Placebo Treatment Effect on Diarrhea"
**Page:** 18
- **Formatting:** Coefficient plot style.
- **Clarity:** Clear contrast.
- **Storytelling:** Good, but this information is already in Table 6. Coefficient plots are often preferred over tables in QJE/AER for placebo tests.
- **Recommendation:** **REVISE**
  - Combine this with a similar plot for Stunting/Underweight. The text mentions that electricity *does* predict stunting changes; a visual of that "failure" of the placebo is just as important as the success for diarrhea.

### Figure 5: "Leave-One-State-Out Sensitivity: Diarrhea Coefficient"
**Page:** 19
- **Formatting:** "Caterpillar" plot.
- **Clarity:** Shows stability well.
- **Storytelling:** Standard robustness.
- **Recommendation:** **MOVE TO APPENDIX** (This is a standard robustness check that rarely stays in the main text of a 40-page AER paper unless a single state is particularly controversial).

### Table 6: "Placebo Tests"
**Page:** 19
- **Formatting:** Simple list.
- **Clarity:** High.
- **Storytelling:** Essential to the paper's cautious tone.
- **Recommendation:** **REVISE**
  - Convert this into a Coefficient Plot (like Figure 4) and include all outcomes. Tables of four rows are better represented as a single clear figure.

---

## Appendix Exhibits

### Table 7: "Covariate Balance by Ujjwala Exposure Tercile"
**Page:** 31
- **Recommendation:** **PROMOTE TO MAIN TEXT**. A balance table is standard in the main text of any empirical paper using a "gap" or "intensity" design to show how different the "treated" units are at baseline.

### Figure 6: "Binned Scatter: Ujjwala Exposure vs. Outcome Changes"
**Page:** 32
- **Recommendation:** **KEEP AS-IS** in Appendix. Good for showing the linearity of the underlying data.

### Table 8: "Naïve Panel Difference-in-Differences"
**Page:** 33
- **Recommendation:** **KEEP AS-IS** in Appendix. Correctly identifies why the main spec uses state-level trends.

### Figure 7: "Distribution of Baseline Clean Fuel Usage Across Districts"
**Page:** 34
- **Recommendation:** **KEEP AS-IS** in Appendix.

---

# Overall Assessment

- **Exhibit count:** 5 Main Tables, 5 Main Figures, 2 Appendix Tables, 2 Appendix Figures.
- **General quality:** High. The paper uses modern visualization techniques (tercle-convergence plots, binned scatters). The "econometrics" of the tables are standard for top journals.
- **Strongest exhibits:** Table 5 (The "Horse Race"), Figure 3 (Health convergence).
- **Weakest exhibits:** Figure 5 (too much space for a simple check), Table 2 (messy variable names).
- **Missing exhibits:** 
    1. **Map of India:** A map showing the "Fuel Gap" by district would be standard for an India-focused paper to show geographic clustering (e.g., the "BIMARU" states).
    2. **Event Study Plot:** While the author notes they only have two periods, if they could find *any* intermediary survey data (like DLHS), an event study is almost mandatory for this design in *Econometrica* or *AER*.

### Top 3 Improvements:
1. **Clean variable labels:** Remove all "delta_", "state_code", and underscores from tables. Use LaTeX to make them look professional.
2. **Consolidate First-Stage visuals:** Merge Figures 1 and 2 into a single multi-panel "First Stage" exhibit.
3. **Strategic promotion:** Move the Balance Table (Table 7) to the main text to establish the "Concurrent Intervention" problem earlier in the reader's mind.