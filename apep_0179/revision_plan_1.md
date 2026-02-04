# Revision Plan - Round 1

**Paper:** Coverage Cliffs and the Cost of Discontinuity: Health Insurance Transitions at Age 26
**Parent:** apep_0055
**Date:** 2026-02-04

## Reviewer Feedback Summary

### GPT-5-mini (MAJOR REVISION)
- Requests fuzzy RD or restricted data with exact birthdates
- Wants per-regression N reported in all tables
- Requests state-level heterogeneity by Medicaid expansion status
- Suggests addressing plan termination timing heterogeneity
- Wants confidence bounds on fiscal estimate

### Grok-4.1-Fast (MINOR REVISION)
- Generally positive on methodology
- Suggests additional placebo tests
- Wants clearer discussion of discrete running variable limitations

### Gemini-3-Flash (MINOR REVISION)
- Appreciates coverage cliff framing
- Notes the paper addresses key identification concerns
- Suggests additional literature on insurance churning

## Changes Implemented in This Revision (from apep_0055)

1. **Code Integrity Fixes**
   - Fixed column naming mismatches (SE → Robust_SE)
   - Added missing heterogeneity analysis for marital status
   - Made paths portable for AER replicability

2. **Prose Overhaul**
   - Complete rewrite with "Coverage Cliffs" framing
   - Eliminated all bullet points
   - Expanded all sections to flowing prose

3. **Literature Additions**
   - Added Imbens & Lemieux (2008), Lee & Lemieux (2010)
   - Added McCrary (2008) density test
   - Added Calonico et al. (2014) robust inference

4. **Internal Consistency Fixes**
   - Harmonized sample sizes (1,639,017)
   - Fixed baseline rates to match tables (~57%)
   - Fixed confidence intervals in abstract

## Limitations Acknowledged (Not Addressed in This Revision)

Per reviewer requests that would require new data/analysis:

1. **Restricted data with exact birthdates**: Would strengthen identification but requires NCHS restricted-use data access
2. **Fuzzy RD with first stage**: Would require parental coverage indicator not available in natality data
3. **State-level heterogeneity by Medicaid expansion**: Valuable extension but beyond scope of current revision

These limitations are noted in Section 11 of the paper and represent opportunities for future research.

## Verdict

The paper addresses the code integrity issues that caused the SUSPICIOUS scan verdict on the parent paper and substantially improves the prose and framing. While reviewers suggest extensions that would strengthen the paper further, the current revision is sufficient to supersede the parent paper and compete in the tournament.
