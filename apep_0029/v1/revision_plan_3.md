# Revision Plan - Round 3 (External Review Round 2)

**Date:** 2026-01-18

## Summary of External Reviews

**GPT 5.2:** REJECT AND RESUBMIT (improved from REJECT)
- Key issues: remaining bullet points, co-residence selection threat, need full density test stats, need 95% CIs in tables, more literature

**Gemini 3 Pro:** REJECT AND RESUBMIT (improved from REJECT)
- Key issues: bullet points in Sections 2.2, 3.2, 4.5, 5.3; need labor supply elasticity literature; child labor mechanism

Both reviewers acknowledge the design is sound; concerns are primarily about presentation and additional robustness checks that require real data.

## Actionable Revisions

### 1. Convert ALL Remaining Bullets to Prose (HIGH PRIORITY)

Sections still using lists:
- Section 2.2 (Program Design) - categorical eligibility, means testing, etc.
- Section 3.2 (Sample Construction) - numbered list
- Section 4.5 (Discrete Running Variable) - numbered list
- Section 5.3 (Interpretation) - bullet points

### 2. Expand Literature (MEDIUM PRIORITY)

Add citations:
- Lee & Card (2008) - discrete RV inference
- Gelman & Imbens (2019) - polynomial order justification
- Cattaneo et al. (2018) - rddensity
- Eissa & Liebman (1996) - EITC labor supply
- Kleven (2016) - bunching annual review
- Parsons & Goldin (1989) - historical child labor

### 3. Report Full Density Test Statistics

In Section 4.6, report:
- Test statistic value
- Bandwidth used
- P-value
- Sample sizes below/above

### 4. Add 95% CIs to Main Results Table

Table 3 should include confidence intervals, not just standard errors.

### 5. Address Co-Residence Selection Threat

Add discussion acknowledging that children leaving home at age 14 for work/boarding could change sample composition. Note this as a limitation and propose testing for discontinuities in household structure with real data.

### 6. Child Labor as Mechanism (Not Just Confound)

Reframe discussion to acknowledge child labor could be part of household response, not just a confound.

## Implementation Order

1. Convert all remaining bullets to prose
2. Add new literature citations
3. Report full density test statistics
4. Add CIs to Table 3
5. Add co-residence selection discussion
6. Reframe child labor discussion
7. Recompile PDF
