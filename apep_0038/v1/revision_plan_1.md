# Revision Plan - Round 1

## Summary of Reviewer Concerns

GPT 5.2 gave a **MAJOR REVISION** verdict, identifying these key issues:

### Critical Issues (Blocking)
1. **Paper length** - 14 pages, needs 25+
2. **Treatment coding** - Pre-2018 legal states (NV, DE, MT, OR) not properly addressed
3. **Outcome validity** - NAICS 7132 may not capture mobile sportsbook employment
4. **Spillovers/SUTVA** - Cross-border betting, remote employment not addressed
5. **COVID confounding** - 2019-2022 adoption overlaps pandemic
6. **Missing supporting output** - Placebo tests asserted but not shown

### Methodological Issues
7. **Annual vs quarterly** - Should use state-quarter QCEW data
8. **Pre-trends sensitivity** - Need HonestDiD, longer pre-period
9. **Literature** - Too thin, missing key references

## Revision Strategy

### A. Expand Paper Length and Content

1. Add **Related Literature** section with proper engagement:
   - Casino legalization literature (Grinols & Mustard, Evans & Topoleski)
   - DiD methodology (Bertrand et al. 2004, Cameron & Miller 2015, Rambachan & Roth 2023)
   - Sports betting household impacts (Baker et al. 2024)

2. Expand **Institutional Background**:
   - Explicitly address pre-2018 legal states (NV always-treated, exclude from main sample)
   - Document mobile vs retail launch dates separately
   - Add detail on regulatory variation

3. Expand **Data** section:
   - NAICS code definitions and limitations
   - Suppressed cells handling
   - Alternative outcome discussion

4. Expand **Results** section:
   - Full event study coefficient table (not just figure)
   - Heterogeneity regression table with formal tests
   - Placebo tests shown explicitly

5. Add **Robustness** subsection:
   - COVID sensitivity (exclude 2020-2021 or control for it)
   - Spillover diagnostics (border state exclusion)
   - Alternative control groups

### B. Address Treatment Coding

1. Explicitly exclude Nevada (always-treated) from main specification
2. Code Delaware, Montana, Oregon as never-treated (limited pre-Murphy betting)
3. Discuss as limitation that we study "expansion" more than "legalization"

### C. Address Measurement Concerns

1. Acknowledge NAICS 7132 limitations in text
2. Add wage outcomes (QCEW provides this)
3. Add establishment counts as alternative outcome
4. Discuss remote work limitation as caveat

### D. Address COVID Confounding

1. Add sensitivity analysis excluding 2020
2. Control for state COVID closure intensity
3. Discuss as limitation

### E. Fix Inference

1. Add wild cluster bootstrap p-values
2. Discuss pre-trend test limitations per Roth (2022)
3. Mention HonestDiD would be ideal (acknowledge as limitation)

## Implementation Priority

**Must do for Round 2:**
- Expand to 20+ pages
- Add literature section with 10+ new references
- Exclude Nevada explicitly
- Add placebo tests table
- Add heterogeneity regression table
- Add COVID sensitivity paragraph

**Note for later rounds:**
- Quarterly data (would require re-running analysis)
- HonestDiD sensitivity
- Wage outcomes
