# Reply to Reviewers

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

**Concern 1: Small-cluster inference for individual-level models.**
We agree this is an important limitation. The `fwildclusterboot` package could not bootstrap weighted individual-level models due to computational constraints. We have clearly noted this limitation in the paper and rely on asymptotic cluster-robust SEs for these specifications. The concordance between bootstrap and asymptotic inference for the state-year TWFE specification provides some reassurance. Future work with alternative methods (permutation inference) could address this.

**Concern 2: Pre-trend anomalies at t-3 and t-2.**
We have revised the text to honestly acknowledge these significant pre-treatment coefficients rather than claiming clean parallel trends. The HonestDiD sensitivity analysis directly accounts for these deviations. Leave-one-out cohort analysis is deferred to a future revision.

**Concern 3: Treatment intensity/compliance evidence.**
We acknowledge that our estimates are intent-to-treat (ITT) and have emphasized this throughout the paper. Compliance data from job postings would strengthen the paper but are not currently available for this analysis.

**Concern 4: Missing reference (Freyaldenhoven et al. 2019).**
Added to bibliography.

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

**Concern 1: Add 2024 CPS data.**
The March 2025 CPS ASEC (covering income year 2024) was not yet available in IPUMS at the time of analysis. This is the most impactful future extension.

**Concern 2: Triple-diff event study.**
This is a valuable suggestion for a future revision. Current computational constraints limit this analysis.

**Concern 3: Missing references (Miller et al. 2024, Dube et al. 2023).**
Added to bibliography where verifiable.

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**Concern 1: Occupational sorting.**
This is a valuable robustness check. We note that our use of occupation fixed effects absorbs time-invariant sorting, and the short post-treatment window (1-3 years) limits the scope for substantial occupation switching. A formal test is deferred.

**Concern 2: Exclude NY/HI entirely.**
NY and HI receive zero weight in the C-S ATT aggregation since they have no post-treatment data. Their exclusion would affect only the pre-treatment balance composition but not the estimated treatment effects. We have clarified this extensively in the revised paper.

**Concern 3: Firm size heterogeneity.**
Limited by CPS data availability. Acknowledged in Limitations section.
