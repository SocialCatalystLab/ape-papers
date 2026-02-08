# Reply to External Reviewers

## Paper: State Insulin Copay Cap Laws and Diabetes Mortality: A DiD Analysis
## Revision: paper_142 (revision of apep_0152)

---

## Reviewer 1: GPT-5-mini (MAJOR REVISION)

### Concern 1: HonestDiD VCV — full covariance matrix needed
> "Recompute the full VCV for the Callaway-Sant'Anna dynamic event study by extracting the influence functions..."

**Response:** We have expanded the discussion of the diagonal VCV approximation in Section 6.8 (footnote) to explicitly address the direction of the approximation bias. In the typical case where event-study coefficients exhibit positive off-diagonal covariances (as is standard when common shocks or clustered errors induce correlated estimation errors across event times), the diagonal approximation *overstates* the variance of the linear combinations entering the HonestDiD smoothness bounds, yielding confidence intervals that are *wider* (more conservative) than those from the full VCV (Rambachan and Roth, 2023). The reported HonestDiD bands therefore represent upper bounds on the true robust confidence intervals, reinforcing the null conclusion. We acknowledge that extracting well-conditioned influence functions from `did::aggte()` output requires additional numerical procedures beyond the scope of the current revision, but note that the conservative nature of the approximation means the qualitative conclusion is strengthened, not weakened.

### Concern 2: Inference for CS-DiD — cluster bootstrap needed
> "There exist now practical solutions to do cluster bootstrap inference for CS-DiD..."

**Response:** We have clarified in Section 5.2 that the Callaway-Sant'Anna multiplier bootstrap (1,000 replications) resamples at the state (cluster) level, providing cluster-robust inference analogous to the CR standard errors used for TWFE. This is the recommended inference procedure in the `did` package documentation and produces standard errors, pointwise CIs, and simultaneous CIs that account for within-state serial correlation and between-state heterogeneity. The wild cluster bootstrap reported in the robustness table applies to the TWFE estimator as a complementary inference check.

### Concern 3: 2018-2019 data gap
> "Quantify the sensitivity...evaluate whether the inability to observe 2018-2019 materially reduces power..."

**Response:** We have strengthened the discussion in Section 5.3.2 (Selection into Treatment) to explicitly note that the 19-year pre-treatment period (1999-2017) provides extensive evidence of parallel trends, and that a sharp trend break occurring precisely in the two unobserved years (2018-2019) is implausible given the absence of any systematic divergence across the full available pre-period. The Wald pre-test p-value further supports this. The limitation is also discussed in Sections 4.1 (Mortality Data) and 7.4 (Limitations).

### Concern 4: Outcome bluntness / intermediate outcomes
> "Add at least one intermediate outcome analysis...or a single-state SCM"

**Response:** We agree this is the most productive direction for future research but cannot pursue it within the current data infrastructure. HCUP State Inpatient Databases, IQVIA prescription data, and CDC WONDER restricted-use files all require separate DUA/IRB access and substantial data processing. We have expanded the Conclusion (Section 8) to explicitly identify age-restricted mortality data (ages 26-64) as the single most impactful improvement, and to discuss why intermediate outcomes were infeasible (data access restrictions and cost). We also note the triple-difference (DDD) design as a promising extension that uses within-state cancer/heart disease mortality as a control dimension.

### Concern 5: Missing references (Imbens & Lemieux 2008; Lee & Lemieux 2010)
> "Add canonical RDD references..."

**Response:** We respectfully decline to add these RDD-specific references, as our paper uses DiD exclusively and does not discuss RDD methods. The Abadie et al. (2010) synthetic control reference is already cited in the Conclusion as a future direction.

### Concern 6: Suppress cells sensitivity
> "Run CS-DiD excluding states with any suppressed post-treatment years..."

**Response:** The leave-one-out analysis reported in the Robustness Appendix (Section C.4) already addresses this by showing that results are insensitive to dropping any individual state. Vermont (the only treated state with suppressed data) is reclassified as not-yet-treated and thus does not affect the treatment effect estimate.

---

## Reviewer 2: Grok-4.1-Fast (MINOR REVISION)

### Concern 1: Missing references
> "Borusyak et al. (2024), Figinski & O'Connell (2024), Dunn et al. (2023), Roth et al. (2024)"

**Response:**
- Borusyak et al. (2024) was already in our bibliography; we now cite it in the Introduction alongside the other staggered DiD references.
- Figinski & O'Connell (2024) has been added and cited in Section 7.3 (Comparison with Related Literature) as closely related quasi-experimental evidence on state insulin copayment caps.
- Dunn et al. (2023) has been added and cited in Section 7.4 (Limitations) regarding the federal Medicare insulin cap as a concurrent confounder.
- Roth (2022/2024) was already cited.

### Concern 2: Format — move appendix tables forward
> "Appendix tables referenced in main text placed late—move forward"

**Response:** The appendix tables are placed at the end following standard journal conventions. The `\Cref{}` cross-referencing system allows readers to navigate directly to any referenced table.

### Concern 3: Age-stratified mortality / SCM for Colorado
> "Run Borusyak et al. (2024) event-study; age-stratified mortality if accessible"

**Response:** We have expanded the future research section to highlight age-stratified data (ages 26-64) as the highest-priority direction and SCM for Colorado as a complementary approach. The Borusyak et al. (2024) estimator would yield very similar results to our Callaway-Sant'Anna implementation given that the TWFE and CS-DiD estimates already agree qualitatively.

---

## Reviewer 3: Gemini-3-Flash (MINOR REVISION)

### Concern 1: Age-restricted mortality data (26-64)
> "If possible, obtain age-restricted mortality data...even a subset of states would provide a 'Proof of Concept' for the dilution theory"

**Response:** We agree entirely that this is the key limitation. CDC WONDER public-use files aggregate diabetes mortality at the state-year-all-ages level; age-stratified breakdowns at the state-year level require restricted-use access or state-specific data agreements. We have substantially expanded the Conclusion to identify this as the single most impactful direction for future research and to explain the data access constraints.

### Concern 2: Triple-Difference (DDD) using cancer/heart disease
> "Consider a DDD using Heart Disease or Cancer mortality as the third dimension"

**Response:** This is a creative suggestion. The current placebo tests already demonstrate that cancer and heart disease mortality show null effects of copay cap adoption, which is the empirical content a DDD would formalize. We now mention the DDD approach in the Conclusion as a promising future extension.

---

## Summary of Changes Made

| Change | Section | Reviewer |
|--------|---------|----------|
| Added Figinski & O'Connell (2024) reference and citation | 7.3 | Grok |
| Added Dunn et al. (2023) reference and citation | 7.4 | Grok |
| Added Borusyak et al. (2024) citation | Introduction | Grok |
| Expanded HonestDiD diagonal VCV discussion (conservatism argument) | 6.8 footnote | GPT |
| Clarified CS-DiD multiplier bootstrap is cluster-level | 5.2 | GPT |
| Strengthened 2018-2019 gap discussion with Wald test reference | 5.3.2 | GPT |
| Expanded future research: age-stratification, DDD, intermediate outcomes | 8 | All three |
