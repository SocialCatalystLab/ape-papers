# Revision Plan 1

## Overview

This revision of apep_0125 focuses on **structural improvements** to streamline the main text by relocating non-essential exhibits to the appendix. No analytical changes were made.

## Changes Made

### Exhibits Moved to Appendix

1. **Map 3 (Treatment Timing)** - Moved from Section 4 to Appendix A.1
2. **Map 4 (Vote Shares)** - Moved from Section 4 to Appendix A.1
3. **McCrary Density Test Figure** - Moved from Section 6.2 to Appendix B.1
4. **Covariate Balance Figure** - Moved from Section 6.2 to Appendix B.1
5. **Bandwidth Sensitivity Figure** - Moved from Section 6.2 to Appendix B.1
6. **Donut RDD Figure** - Moved from Section 6.2 to Appendix B.1
7. **Randomization Inference Figure** - Moved from Section 6.2 to Appendix B.1
8. **CS Event Study Figure** - Moved from Section 6.5 to Appendix B.2

### Text Clarifications

1. Added explicit cross-references from main text to appendix figures
2. Clarified Figure 5 caption re: pre-correction vs corrected sample
3. Added Grembi et al. (2016) citation for Difference-in-Discontinuities
4. Fixed undefined citation in Table 10 (mackinnon2017wild)
5. Changed "~12" to "13" for exact border-pair count
6. Added explicit notes about unweighted canton averages vs population-weighted national averages
7. Clarified SE vs bias-corrected CI in RDD results table

### Code Fixes

1. Added null guards in 06_tables.R for missing RDD specification objects
2. Made table generation robust to partially-populated RDS files

## What Did NOT Change

- All analysis and results remain identical
- Core figures in main text unchanged
- Conclusions and interpretation unchanged
- Effect size estimates unchanged

## Addressing Reviewer Feedback

This revision does not address the substantive concerns raised in external reviews (placebo tests, mechanisms, individual-level data). Those would require additional analysis beyond the scope of structural reorganization.
