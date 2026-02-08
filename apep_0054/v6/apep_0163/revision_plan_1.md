# Revision Plan: apep_0158 → apep_0159

## Summary of Core Changes

This revision addresses the fundamental limitation identified by all three reviewers of apep_0158: the inability to separate new hire wages from incumbent wages when using CPS survey data.

### Key Methodological Change: CPS → QWI

**Problem (all reviewers):** CPS ASEC cannot distinguish new hires from incumbents, making it impossible to directly test the commitment mechanism that operates through initial wage offers.

**Solution:** Replace CPS with Census Quarterly Workforce Indicators (QWI), which provides:
- `EarnHirAS`: Average monthly earnings of **new hires** specifically
- County × quarter × sex granularity (vs state × year in CPS)
- Administrative records from unemployment insurance (vs survey data)
- Coverage: 17 states (6 treated + 11 never-treated border controls)

### Additional Design Improvements

1. **Border Discontinuity Design:** Following Dube, Lester & Reich (2010), comparing 129 adjacent county pairs across state borders provides tighter identification than statewide comparisons.

2. **Exclusion of NY:** New York adopted a law in September 2023, violating the never-treated control assumption. It is now explicitly excluded from all specifications.

3. **Corrected Gender Gap Interpretation:** Fixed the sign interpretation—since men's ATT (2.0%) exceeds women's (1.3%), the gap modestly widens rather than narrows.

## Changes Made

| Section | Change |
|---------|--------|
| Abstract | Updated data source, estimates, and interpretation |
| Data (Section 5) | Complete rewrite for QWI methodology |
| Empirical Strategy (Section 6) | Added border discontinuity design |
| Results (Section 7) | All new QWI-based results |
| All Tables/Figures | Regenerated with QWI data |
| Appendix | Updated with QWI summary statistics |

## Remaining Limitations

- Post-treatment window limited to 1-3 years
- Border design may capture sorting effects
- Gender gap effects imprecisely estimated
