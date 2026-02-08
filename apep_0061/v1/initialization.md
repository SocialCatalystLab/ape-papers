# Initialization: Paper 78

## Revision Information

This paper is a **revision** of `apep_0069` (Paper 71).

**Parent Paper:**
- ID: apep_0069
- Title: "Do State Dyslexia Laws Improve Reading Achievement? Evidence from Staggered Adoption"
- Decision: REJECT AND RESUBMIT (Conservative score: 14.7, rank 42)
- Method: Staggered DiD (Callaway-Sant'Anna)
- Data: NAEP Grade 4 Reading + State dyslexia law effective dates

## Summary of Reviewer Concerns

All three reviewers identified consistent issues:

1. **Treatment timing misalignment:** Laws effective July 1 cannot affect that year's NAEP (tested Jan-Mar). This mechanically attenuates estimates toward zero.

2. **Policy bundling confounds:** MS, FL, TN, AL bundled dyslexia screening with comprehensive Science of Reading reforms. Cannot separate dyslexia laws from SoR effects.

3. **State mean dilutes targeted effects:** Dyslexia policy targets bottom 5-10% of readers. State mean outcome dilutes any effects on struggling readers.

4. **Inference gaps:** Singular covariance matrix in some event-study bins, missing pretrend joint tests, insufficient bootstrap documentation.

## Revision Strategy

1. **Correct treatment timing:** Map mandate_year to first_naep_exposure based on exact effective dates vs. NAEP administration (Jan-Mar).

2. **Use distributional outcomes:** Fetch 10th and 25th percentile NAEP scores, % Below Basic. Primary outcome: 10th percentile.

3. **Separate bundled vs. dyslexia-only estimation:** Run Callaway-Sant'Anna separately for states with pure dyslexia laws vs. comprehensive reform bundles.

4. **Improve inference:** Binned event study, 1000 bootstrap iterations, pretrend omnibus test, wild cluster bootstrap.

5. **Expand paper:** More institutional detail, statute citations, treatment classification table, ≥25 pages main text.

## Human Inputs

- **Research question:** Effect of state dyslexia screening mandates on reading achievement
- **Method:** Staggered DiD (Callaway-Sant'Anna)
- **Outcome:** NAEP Grade 4 Reading (percentiles, not just mean)
- **Treatment:** State dyslexia law adoption with corrected timing
- **Parent paper:** apep_0069

## Date

2026-01-25
