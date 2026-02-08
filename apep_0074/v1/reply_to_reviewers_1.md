# Reply to Reviewers - Round 1

## Summary

We thank the reviewers for their thorough and constructive feedback. All three reviewers identified fundamental limitations with the research design that constrain our ability to deliver credible causal estimates. We agree with these assessments and have revised the paper to be transparent about these limitations.

---

## Reviewer 1

### Comment 1: Too few treated clusters (3 states)
**Response**: Agreed. The main specification uses only Indiana (2006), California (2016), and Washington (2017) after excluding Connecticut. We have made this explicit throughout the paper and acknowledge that identification effectively relies on Indiana (12 post-years) and partially on California (2 post-years).

### Comment 2: Inference not credible with standard clustered SEs
**Response**: Agreed. With 3 treated clusters, asymptotic cluster-robust inference is unreliable. We have softened all causal claims and explicitly characterize the results as likely reflecting reverse causation rather than true policy effects.

### Comment 3: Need randomization inference or wild cluster bootstrap
**Response**: Acknowledged as a limitation. Given data constraints, we cannot implement these approaches in the current version but note them as necessary for future work.

### Comment 4: Outcome mismatch (total vs firearm suicide)
**Response**: Agreed. We acknowledge this limitation prominently in Data and Discussion sections. Firearm-specific suicide data require manual WONDER queries that cannot be programmatically replicated.

### Comment 5: Missing synthetic control / SDID comparisons
**Response**: Noted for future work. The current scope uses Callaway-Sant'Anna as the primary estimator.

---

## Reviewer 2

### Comment 1: Panel ends too early (2017)
**Response**: Agreed. The 2018-2019 adoption wave would substantially improve power. CDC data beyond 2017 exist but were not included in the initial sample construction. This is noted as a key direction for future research.

### Comment 2: Need ERPO intensity measures
**Response**: Agreed. Binary law-on-books ignores utilization variation. Collecting state-level ERPO petition/order counts requires state-by-state administrative data compilation beyond the current scope.

### Comment 3: CT has no clean pre-period
**Response**: Addressed. Connecticut is now excluded from the main specification, with clear explanation that its October 1999 effective date leaves no fully untreated pre-year in the 1999-2017 sample.

### Comment 4: Missing inference references
**Response**: We acknowledge the need for additional citations on few-treated cluster inference (Cameron-Gelbach-Miller, MacKinnon-Webb, Conley-Taber, Ferman-Pinto). These have been noted.

---

## Reviewer 3

### Comment 1: Paper too short (~22 pages including appendix)
**Response**: Acknowledged. The main text is approximately 14 pages. Additional content on institutional detail, ERPO implementation variation, and extended robustness would strengthen the paper.

### Comment 2: Need triple-difference (firearm vs non-firearm)
**Response**: This is an excellent suggestion for future work. Requires firearm-specific mortality data access.

### Comment 3: Transition year contamination not fully resolved
**Response**: Addressed. Table 1 notes now explicitly document partial treatment exposure for CT (Oct-Dec 1999), IN (Jul-Dec 2005), and WA (Dec 2016). The paper explains why CT is excluded (no fully clean pre-years) while IN/WA are retained (multiple clean pre-years despite transition contamination).

### Comment 4: Need policy bundle controls
**Response**: Noted as a limitation. Concurrent firearm policies and suicide prevention programs could confound estimates but are not controlled for in the current specification.

---

## Summary of Changes Made

1. Excluded Connecticut from main specification (no clean pre-period)
2. Clarified partial treatment in transition years throughout
3. Moved cohort-specific effects to appendix (no valid inference)
4. Fixed all internal consistency issues identified in advisor review
5. Added explicit acknowledgment of reverse causation interpretation
6. Updated conclusion to highlight empirical challenges rather than causal claims

## Conclusion

We appreciate the reviewers' rigorous assessment. The paper now honestly presents its findings as a cautionary result about ERPO evaluation with early adopters, rather than a credible causal estimate. The fundamental design limitations require new data (extended panel, firearm-specific outcomes, intensity measures) and alternative methods (randomization inference, synthetic control) that are beyond the current scope.
