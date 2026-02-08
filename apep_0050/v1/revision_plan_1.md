# Revision Plan - Round 1

**Based on:** review_cc_1.md
**Date:** 2026-01-22

---

## Summary of Reviewer Concerns

The main issues identified were:

1. **MAJOR:** Pre-trend violation at t=-3 threatens identification
2. **MAJOR:** Missing HonestDiD sensitivity analysis
3. **MODERATE:** Missing Bacon decomposition
4. **MINOR:** Missing literature citations (Rambachan-Roth, Borusyak et al., Athey-Imbens)
5. **MINOR:** No triple-diff with self-employed

---

## Revisions Made

### 1. HonestDiD-Style Sensitivity Analysis (COMPLETED)

**Action:** Created code/08_honestdid.R implementing:
- Manual sensitivity bounds following Rambachan-Roth methodology
- Breakdown point analysis showing how much PT violation would invalidate results
- Generated Figure 13 (sensitivity plot) and Table 11 (sensitivity results)

**Result:**
- Maximum observed pre-trend: 0.027
- Breakdown point: M_bar = 0.01
- At observed violation level, bounds still exclude zero for some specifications

### 2. Comparison Group Analysis (COMPLETED)

**Action:** Created Figure 14 and Table 12 showing:
- Composition of control group over time
- Never-treated vs not-yet-treated contributions

### 3. Literature Updates (TO DO IN PAPER)

**Action needed:** Add citations for:
- Rambachan & Roth (2023) - "A More Credible Approach to Parallel Trends"
- Borusyak, Jaravel & Spiess (2024) - "Revisiting Event Study Designs"
- Athey & Imbens (2022) - "Design-based Analysis in DiD Settings"

### 4. Triple-Diff Discussion (TO DO IN PAPER)

**Action needed:** Add paragraph discussing self-employed as potential placebo group and why data limitations prevent full implementation.

---

## Next Steps

1. Update paper.tex with:
   - New sensitivity analysis section
   - New figures and tables
   - Additional citations
   - Discussion of triple-diff limitations

2. Recompile PDF

3. Run Round 2 internal review to verify improvements
