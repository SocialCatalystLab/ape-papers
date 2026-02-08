# Revision Plan - Round 1

## Issues to Address

### Critical (must fix)
1. **Broken table reference** - Page 10 refers to "Table ??" for LFP results
2. **California missing from Figure 5** - State-specific effects chart shows only 4 of 5 states

### Major (should address)
3. **Add HonestDiD sensitivity analysis** - Report Rambachan-Roth bounds
4. **Explore conditional parallel trends** - Add covariates to see if conditional PT holds
5. **Include triple-diff in main text** - Currently only in robustness code

### Minor (if time permits)
6. Expand literature review with more recent studies
7. Add discussion of alternative identification strategies

## Implementation Steps

1. Fix LaTeX table reference for LFP results
2. Debug Figure 5 to include California
3. Run HonestDiD analysis and add to paper
4. Run DiD with covariates conditioning and report
5. Add triple-diff results table
6. Recompile and review PDF
