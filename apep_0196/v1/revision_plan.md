# Revision Plan

## Summary of Reviewer Feedback

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| GPT-5-mini | MAJOR REVISION | Power calculation unclear, need IPEDS data, wild bootstrap in main text |
| Grok-4.1-Fast | MINOR REVISION | Missing 3 refs, suggests IPEDS extension, methodology praised |
| Gemini-3-Flash | REJECT AND RESUBMIT | MDE too high, ACS data too noisy, need composition tests |

## Common Themes

1. **Power limitations** (all 3): MDE of 29% is too high given expected 5-15% effects
2. **Data limitations** (all 3): ACS total enrollment dilutes effect; IPEDS first-time enrollment preferred
3. **Missing references** (all 3): Various literature gaps identified
4. **Composition hypothesis** (2/3): Cannot test CC vs. 4-year directly with current data

## Addressable Issues (This Revision)

### Priority 1: Literature Gaps
Add missing references:
- Conley (1999) - cited but not in bibliography
- Lee & Lemieux (2010) - RDD reference
- Imbens & Lemieux (2008) - RDD reference
- Mountjoy (2022) - Diversion hypothesis
- Roth et al. (2023) - Staggered DiD toolkit

### Priority 2: MDE Calculation Clarity
- Add formula and inputs explicitly
- Explain the 1.065 SD value
- Acknowledge limitations more clearly

### Priority 3: Language Softening
- Remove "precisely estimated null" language
- Add more cautious interpretation throughout
- Emphasize "failure to detect" rather than "no effect"

### Priority 4: Wild Cluster Bootstrap in Main Table
- Add bootstrap CI to Table 2
- Report Webb weights bootstrap p-value

## Not Addressable (Would Require New Data)

1. **IPEDS data**: Would require completely new data fetch and analysis
2. **Institution-level decomposition**: Not available in ACS
3. **First-time enrollment**: ACS doesn't provide this breakdown
4. **Synthetic control**: Would require substantial new analysis

## Execution Plan

1. Add missing citations to references.bib
2. Update paper.tex with:
   - New references in literature review
   - Clarified MDE calculation
   - Softened language throughout
   - Bootstrap CI in main table
3. Recompile PDF
4. Proceed to publication (paper meets 25+ pages, advisor passed)

## Note on Scope

Given time and data constraints, this revision focuses on documentation and interpretation improvements rather than new empirical analyses. The paper honestly acknowledges its power limitations, which is a contribution in itself—demonstrating that state-level aggregate analysis is insufficient for evaluating Promise programs.
