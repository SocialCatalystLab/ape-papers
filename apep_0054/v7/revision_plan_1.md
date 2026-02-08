# Revision Plan: apep_0163 → apep_0164

## Summary of Core Changes

This revision adds the "Border Event Study" analysis showing the border gap at each event time (RDD meets Event Study design), addressing the key interpretive concern about the +11.5% border effect.

### Key Addition: Border Event Study (Section 7.5)

**Concern addressed:** The +11.5% border effect in Table 2 could be misread as a pure treatment effect when it actually combines (1) pre-existing spatial differences (~10%) and (2) treatment-induced changes (~3.3%).

**Solution:** Added Section 7.5 "Border Event Study: RDD Meets Event Study" that:
- Shows the border gap at each event time from t-12 to t+8
- Decomposes the +11.5% into pre-treatment level (~10%) and treatment-induced change (~3.3%)
- Explains why pre-treatment gaps are expected (treated states are high-wage states)
- Clarifies that the DiD effect is the *change* in gap, not the level

### Code Changes

| File | Change |
|------|--------|
| `04_robustness.R` | Added border event study estimation |
| `05_figures.R` | Added Figure 7: Border Event Study |
| `03_main_analysis.R` | Added `set.seed()` for reproducibility |

### Paper Changes

| Section | Change |
|---------|--------|
| 7.5 (new) | Full subsection on border event study interpretation |
| Figure 7 | New figure showing border gap at each event time |

## Reviewer Comments (for future reference)

All 3 reviewers recommend MAJOR REVISION with concerns about:
1. Border design interpretation (addressed by this revision)
2. Sorting/spillovers at borders (acknowledged in Discussion)
3. Small number of state clusters (acknowledged limitation)
4. Concurrent salary history bans (robustness check excludes CA/WA)

The border event study directly addresses concern #1 by showing the decomposition of the border effect into pre-existing differences and treatment-induced changes.
