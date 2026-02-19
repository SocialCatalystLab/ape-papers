# Revision Plan — APEP-0372

## Overview

Address feedback from three external referees focusing on:
1. Identification robustness (placebo failure, region sensitivity)
2. Small-cluster inference
3. Internal consistency

## Changes

### High Priority
1. **Division × cohort FE**: Add intermediate geographic specification (9 Census divisions) — diagnoses the region sensitivity
2. **Pairs cluster bootstrap**: Add bootstrap inference for key specifications (bachelor P25, associate P25)
3. **95% CIs**: Add to Table 2 (main results)
4. **Reframe results**: Abstract and introduction now honestly acknowledge placebo failure and region sensitivity

### Medium Priority
5. **Graduate summary stats**: Add to Table 1
6. **CIP analysis documentation**: Clarify 164,802 raw vs 90,094 analysis sample
7. **Text-table consistency**: All numerical cross-references verified

### Not Addressed (Design Limitations)
- CS-DiD estimator: Not applicable with continuous treatment
- Event study: Not feasible with 3-year cohort windows
- Extended MW data beyond 2020: Requires future data release
