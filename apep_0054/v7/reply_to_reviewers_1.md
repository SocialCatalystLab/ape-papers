# Reply to Reviewers: apep_0163 → apep_0164

We thank the reviewers for their thoughtful feedback. This revision addresses the key interpretive concern about the border design by adding a "Border Event Study" that decomposes the +11.5% effect into pre-existing spatial differences and treatment-induced changes.

---

## Summary of Changes

The main addition is **Section 7.5: Border Event Study (RDD Meets Event Study)**, which:

1. Shows the border gap (treated - control) at each event time
2. Reveals pre-treatment gaps of ~10% (spatial differences between high-wage treated states and control states)
3. Shows post-treatment gaps of ~13.5%
4. Computes the DiD as the *change* in gap: +3.3 percentage points

This decomposition clarifies that most of the +11.5% border effect reflects pre-existing level differences, not the causal treatment effect.

---

## Response to Specific Concerns

### Border Design Interpretation (All Reviewers)

> "Using a level-difference from a border design and calling it an ATT is misleading."

**Response:** We fully agree. The new Section 7.5 now explicitly decomposes the border effect:
- Pre-treatment border gap: ~10% (expected, since CA/CO/WA are high-wage states)
- Post-treatment border gap: ~13.5%
- Treatment-induced change (the DiD): ~3.3 percentage points

The +11.5% from Table 2 is the average gap, not the treatment effect. The event study clarifies this.

### Sorting and Spillovers

> "If high-wage firms move to Colorado because of the law, the estimate is not a treatment effect but a relocation effect."

**Response:** Acknowledged in Section 8.2 (Limitations). We note this as a key limitation. The border event study helps by showing the pre/post decomposition, but cannot rule out sorting.

### Reproducibility (Codex-Mini)

> "No `set.seed()` before bootstrap calls."

**Response:** Fixed. Added `set.seed(20240203)` before all Callaway-Sant'Anna bootstrap calls in `03_main_analysis.R`.

---

## What Remains Unchanged

- Core identification strategy (Callaway-Sant'Anna DiD + border design)
- Main statewide results (+1.0%, not significant)
- Gender gap results (men +2.0%, women +1.3%)
- All robustness checks

The revision adds interpretive clarity without changing the fundamental results.
