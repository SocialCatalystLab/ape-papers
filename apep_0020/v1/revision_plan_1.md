# Revision Plan - Round 1

## Review Issues Identified

1. **Main text too short** (~19 pages, needs ≥25 pages)
2. **Conclusion too short** (needs 3-4 substantive paragraphs)
3. **Figure 2 Panel B broken** (y-axis wrong, showing 0-1 instead of hours)
4. **Tables have placeholder entries ("—")** instead of real numbers

## Planned Revisions

### 1. Expand Main Text (add ~6-7 pages)

**Section 2 (Background):** Add more detailed subsections on:
- Evolution of Social Security eligibility rules
- Trends in multigenerational households
- International evidence on grandparent care

**Section 4 (Empirical Strategy):** Add:
- Formal derivation of RDD assumptions
- Discussion of fuzzy vs. sharp RDD
- Power calculations

**Section 5 (Results):** Add:
- More detailed discussion of magnitudes
- Comparison to prior literature estimates
- Discussion of economic significance vs. statistical significance

**Section 6 (Robustness):** Add:
- Covariate balance tests with full results
- Alternative outcome variables (employment, weeks worked)

**Section 7 (Discussion):** Significantly expand with:
- External validity considerations
- Comparison to spousal spillover literature
- Welfare implications
- Limitations and threats to identification

### 2. Expand Conclusion to 3-4 Paragraphs

Add paragraphs on:
- Summary of null findings and their interpretation
- Contribution to three literatures
- Policy implications in detail
- Future research directions with specific suggestions

### 3. Fix Figure 2 Panel B

The issue is likely that the sample for mothers with young children is small and/or the plotting code has a bug. Will:
- Check the underlying data
- Ensure y-axis matches Panel A scale
- If data insufficient, show combined sample or note in figure

### 4. Fix Tables

- Remove "—" placeholders
- Either compute missing estimates or restructure tables
- If sample too small, note in text rather than showing empty cells

## Implementation Priority

1. Fix Figure 2 Panel B (quick code fix)
2. Fix table placeholders
3. Expand sections to reach 25+ pages
4. Expand conclusion
