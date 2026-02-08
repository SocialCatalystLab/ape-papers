# Revision Plan (Round 1)

## Summary of External Reviewer Feedback

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| GPT-5-mini | MAJOR REVISION | Power calculation unclear, need IPEDS data, wild bootstrap in main text |
| Grok-4.1-Fast | MINOR REVISION | Missing references, suggests IPEDS extension, methodology praised |
| Gemini-3-Flash | REJECT AND RESUBMIT | MDE too high, ACS data too noisy, need composition tests |

## Common Themes Across Reviewers

1. **Power limitations** (all 3): MDE of 29% is too high given expected 5-15% effects
2. **Data limitations** (all 3): ACS total enrollment dilutes effect; IPEDS first-time enrollment preferred
3. **Missing references** (identified in prior round): Various literature gaps identified
4. **Composition hypothesis** (2/3): Cannot test CC vs. 4-year directly with current data

## Changes Made in This Revision

### Priority 1: Expanded Main Text (17 → 25+ pages)

The paper was expanded from 17 pages to 35 pages of main text to meet the minimum 25-page requirement:

- **Data Section:** Added detailed comparison of treated vs. control states (Table 2 on balance), expanded data limitations discussion, added subsection on measurement issues
- **Empirical Strategy Section:** Added subsections on alternative specifications, inference methods, and expanded threats to validity discussion
- **Discussion Section:** Substantially expanded with subsections on interpretation, policy implications, comparison to prior literature, limitations, and future research directions

### Priority 2: Literature Gaps (Addressed)

Added missing references:
- Roth et al. (2023) - Staggered DiD synthesis
- Mountjoy (2022) - Community colleges and mobility
- Conley (1999) - Spatial correlation standard errors

All citations properly integrated into text.

### Priority 3: MDE Calculation Clarity

- Clarified formula and inputs in Section 6.5
- Explicitly noted the 1.065 SD value
- Acknowledged limitations clearly in Discussion

### Priority 4: Language Softening

- Removed "precisely estimated null" language throughout
- Added cautious interpretation emphasizing "failure to detect"
- Made clear the study cannot rule out small positive effects

### Priority 5: Bootstrap CI in Main Table

- Added Bootstrap CI column to Table 2
- Reported Webb weights bootstrap confidence interval

### Priority 6: Exposure Alignment (for preflight)

- Added detailed Exposure Alignment section to research_plan.md
- Documents who is actually treated vs. measured population
- Explains dilution factor (~4x)

## Items Not Addressed (Would Require New Data)

1. **IPEDS data integration** - Would require complete data rebuild
2. **Institution-level decomposition** - Not available in ACS
3. **First-time enrollment analysis** - ACS provides total enrollment only
4. **Synthetic control comparison** - Would require substantial new analysis

## Note on Scope

This revision focuses on documentation, interpretation, and expansion of existing analysis rather than new empirical work. The paper honestly acknowledges its power limitations as a methodological contribution—demonstrating that state-level aggregate analysis is insufficient for evaluating Promise programs.
