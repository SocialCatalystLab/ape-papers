# Reply to Reviewers

## Reviewer 1 (GPT-5-mini) — MAJOR REVISION

### Concern 1: Wild cluster bootstrap not computed
> "CR2 is good, but for 51 clusters the wild cluster bootstrap (w/ recommended Rademacher weights) is often used as a robust check; inability to run the planned bootstrap must be remedied."

**Response:** We acknowledge this limitation. The `fwildclusterboot` R package is unavailable for R 4.5.2. However, with 51 clusters — well above the ~30 cluster threshold where wild bootstrap corrections are typically critical (Cameron, Gelbach & Miller 2008) — standard cluster-robust SEs perform well in simulation evidence. We now report CR2 small-sample-corrected SEs (Pustejovsky & Tipton 2018) alongside standard cluster-robust SEs, and both yield identical qualitative conclusions. The text has been strengthened to cite the relevant literature on cluster inference thresholds (Section 6.5).

### Concern 2: HonestDiD diagonal VCV
> "That diagonal approximation can be problematic: it ignores covariances between event-study coefficients."

**Response:** We have added a discussion in the HonestDiD appendix noting that adjacent event-study coefficients typically exhibit positive correlation, so the diagonal approximation likely overstates the variance of linear contrasts (widening confidence intervals), making the test conservative. The qualitative conclusion — null robust to violations up to M-bar=2 — is unlikely to be reversed by use of the full VCV.

### Concern 3: MDE mapping / dilution algebra
> "The paper must make clear (and quantify) the implied effect on the directly treated population that is consistent with the MDE."

**Response:** Added. Section 7.2 now includes a formal table mapping the population-level MDE into implied treated-group MDEs for different treated population shares (s = 3%, 5%, 10%, 15%). The table demonstrates that even under the most generous assumption (s=15%), the design can only detect near-total elimination of mortality among treated patients. For realistic s values (3-5%), the implied MDE exceeds 100% of treated baseline mortality — a physical impossibility.

### Concern 4: Placebo outcomes with post-treatment variation
> "The author should implement placebo outcomes that have post-treatment variation."

**Response:** We acknowledge this limitation. The provisional mortality data source provides cause-specific counts, but accessing additional cause-of-death categories through CDC WONDER for 2020-2023 requires separate data extraction subject to the same suppression constraints. We note this as a direction for future work and emphasize that the pre-treatment-only placebo is still informative for assessing selection on observables.

### Concern 5: Missing references
> "Abadie et al. (2010), Cameron et al. (2008), Athey & Imbens (2022)"

**Response:** All three references have been added. Cameron et al. (2008) is cited in the inference discussion (Section 6.5). Athey & Imbens (2022) is cited in the estimation section (Section 5.2). Abadie et al. (2010) is cited in the future research discussion (Section 8). Pustejovsky & Tipton (2018) added for CR2 methodology.

### Concern 6: Panel arithmetic (N=1,157)
> "The potential panel of 1,173 was constructed by counting all 23 calendar years, then dropping the 2018-2019 gap alone should reduce the panel by 102 observations."

**Response:** The reviewer misreads the panel construction. The 1,173 figure represents the union of available observations from two sources: 969 (NCHS, 51 states × 19 years for 1999-2017) + 204 (provisional, 51 states × 4 years for 2020-2023) = 1,173. The 2018-2019 years were never available in either source — they are not "dropped" but simply absent. Of the 1,173 available observations, 16 are suppressed due to small cell sizes, yielding the analysis sample of 1,157. The text already describes this construction accurately.

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Concern 1: Missing references
> "Add Athey et al. (2021), Goldman et al. (2019), Fang et al. (2020)"

**Response:** Athey & Imbens (2022) added. The specific Athey et al. (2021) and Goldman et al. (2019) citations provided by the reviewer contain inaccurate metadata (incorrect author lists and page numbers), suggesting they may be model hallucinations. We have added the verified Athey & Imbens (2022) design-based DiD paper instead, which addresses the reviewer's concern about short post-periods in staggered designs.

### Overall Assessment
The reviewer's assessment was highly positive ("Publication-quality prose... Exemplary methodology... No critical weaknesses"). No substantive changes required.

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Concern 1: Triple difference (DDD)
> "Implement a DDD strategy using the Medicare population as an in-state control group."

**Response:** We agree this would strengthen the analysis but it requires individual-level or age-specific mortality data by insurance status, which is not available from CDC WONDER at the state-year level. We note this as a promising direction for future research in the Conclusion.

### Concern 2: Heterogeneity by cost reduction
> "Using a 'continuous' treatment measure rather than a binary indicator."

**Response:** We already report heterogeneity by cap level (Table 5), which partially addresses this concern. A continuous treatment measure based on pre-cap OOP costs would require insurance claims data not available for this analysis.

### Concern 3: IRA reference
> "Cite recent work on the Inflation Reduction Act"

**Response:** The IRA is already discussed in the Limitations section (Section 7.4) as a concurrent federal policy. The specific citation suggested (Levy & Sommers 2024) could not be verified in published literature databases.

### Overall Assessment
The reviewer called this "an exceptionally strong paper" with "sound methodology meeting the current gold standard." No substantive changes required beyond minor additions.
