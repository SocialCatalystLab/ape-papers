# Internal Review — Claude Code (Round 1)

## Summary
Comprehensive self-review of apep_0328 v1 covering methodology, data, results, and presentation.

## Key Findings

### Methodology
- Staggered DiD with CS-DiD and Sun-Abraham estimators is appropriate
- 23 treated states, 29 controls, 84 months of data
- Treatment detection from endogenous data is acknowledged with appropriate caveats

### Issues Found and Fixed
1. **Rate detection threshold inconsistency:** CO (4.4%), RI (14.3%), CT (NaN) were below 15% threshold — fixed by adding post-filter
2. **Summary statistics mismatch:** Text said "800 providers" but Table 1 showed mean 151 — fixed
3. **Duplicate median:** Text reported both "42%" and "35%" median — fixed to correct value (58%)
4. **Log coefficient interpretation:** 17.8% was incorrect exp(-0.178)-1 = 16.3% — fixed
5. **Table 2 identical columns:** FRED data unavailable, control columns were duplicates — removed columns 5-6
6. **Wyoming outlier:** 1,422% rate increase excluded from dose-response
7. **Cross-state billing concern:** Added explicit discussion of why personal care cross-state billing is rare
8. **Timing placeholder:** Removed N/A timing macros from author footnote

### Remaining Limitations
- No external validation of detected rate changes against state fee schedules
- NPI counts conflate workforce supply with organizational consolidation
- Wild cluster bootstrap not implemented (52 clusters may be sufficient for standard clustered SEs)

## Decision: PROCEED TO EXTERNAL REVIEW
