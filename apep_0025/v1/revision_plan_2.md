# Revision Plan - Round 2

**Based on:** Internal Review (review_cc_2.md)

**Date:** 2026-01-18

---

## Planned Revisions

### 1. Fix Character Encoding (CRITICAL)

**Problem:** Less-than symbols "<" render as "¡" in PDF

**Solution:** Add font encoding package to preamble:
```latex
\usepackage[T1]{fontenc}
```

### 2. Fix Figure 1 Rendering

**Problem:** First stage figure not appearing

**Actions:**
- Verify `figures/fig1_first_stage.png` exists
- If missing, the figure may not have been generated properly
- Check file path spelling

### 3. Fix Figure 3 (TV/Exercise)

**Problem:** Only annotation text visible, figure panels not rendering

**Actions:**
- Check that both `fig_rd_tv.png` and `fig_rd_exercise.png` exist
- Verify file paths match LaTeX references

### 4. Add Simulated Data Note to Table 1

**Change:** Update Table 1 notes from:
```
Sample includes ATUS respondents ages 55-70 from 2003-2023.
```
to:
```
Sample includes ATUS respondents ages 55-70 from 2003-2023. Simulated data.
```

---

## Implementation Order

1. Add fontenc package to fix "<" symbols
2. Check all figure files exist
3. Update Table 1 notes
4. Recompile and verify

---

*End of Revision Plan Round 2*
