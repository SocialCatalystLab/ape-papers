# Revision Plan: Stage C (Post-External Review)

## Reviews Received

| Reviewer | Model | Decision |
|----------|-------|----------|
| GPT-5-mini | openai/gpt-5-mini | MAJOR REVISION |
| Grok-4.1-Fast | x-ai/grok-4.1-fast | MINOR REVISION |
| Gemini-3-Flash | gemini-3-flash-preview | MINOR REVISION |

**Majority: MINOR REVISION (2/3). Exit criteria met.**

## Consolidated Reviewer Concerns

### Group 1: HonestDiD VCV (GPT — critical)
GPT requests recomputation using full VCV from influence functions. Paper already acknowledges diagonal approximation in Section 6.8 and Appendix. The `did::aggte()` output stores influence functions in `$inf.function$dynamic`, but extracting a well-conditioned VCV is nontrivial and risks numerical instability. Current paper already flags this limitation transparently.

**Action:** Strengthen the existing discussion of the diagonal VCV limitation. Add explicit language quantifying that HonestDiD bounds are *conservative* when off-diagonal covariances are positive (which is the typical case for event-study coefficients from the same estimator). Note that the diagonal assumption overstates SE for the smoothness bounds and thus the reported HonestDiD intervals are *wider* than those from the full VCV. This is a known property documented in Rambachan & Roth (2023). No code change required.

### Group 2: Inference for CS-DiD (GPT — moderate)
GPT wants cluster bootstrap for CS-DiD (not just TWFE). The `did` package already implements multiplier bootstrap with cluster-level resampling via the `bstrap` option. The reported SEs and CIs for CS-DiD use this multiplier bootstrap.

**Action:** Add explicit clarifying language in Section 5.2 and the inference table that the CS-DiD multiplier bootstrap is cluster-level (resampling at the state level with 1,000 replications). This addresses GPT's concern without new computation.

### Group 3: 2018-2019 Gap Sensitivity (GPT — moderate)
Already discussed in Data (Section 4.1), Limitations (Section 7.4), and in a paragraph added during advisor review in the parallel trends section.

**Action:** Add a brief placebo-in-time discussion noting that the 19-year pre-period (1999-2017) provides extensive evidence of parallel trends, and that the 2018-2019 gap would only matter if a sharp trend break occurred precisely in those two years. Reference the Wald pre-test p-value as evidence against pre-trend violations.

### Group 4: Missing References (Grok + GPT)
- Borusyak et al. (2024) — already in references.bib
- Figinski & O'Connell (2024) insulin caps — add and cite
- Dunn et al. (2023) Medicare insulin cap — add and cite
- Imbens & Lemieux (2008) and Lee & Lemieux (2010) — RDD references not relevant to this DiD paper; decline to add

**Action:** Add Figinski & O'Connell (2024) and Dunn et al. (2023) to references.bib. Cite Figinski in Literature Review (related quasi-experimental evidence on insulin caps). Cite Dunn in Discussion/Limitations (federal Medicare cap as confounder).

### Group 5: Intermediate Outcomes / Age Stratification (GPT + Gemini + Grok)
All three reviewers suggest age-restricted mortality or intermediate outcomes. This is infeasible within the current data infrastructure — CDC WONDER public-use data do not provide age-stratified diabetes mortality at the state-year level, and HCUP/claims data require separate IRB/DUA access.

**Action:** Expand the future research discussion to explicitly address why age-stratified data (26-64) would be transformative, cite the limitation as data-access-driven, and frame it as the single most productive direction for future work.

### Group 6: Triple-Difference (Gemini)
Gemini suggests DDD using heart/cancer mortality as third dimension.

**Action:** Mention this briefly in the future research section as a promising extension. Not implemented because the current placebo tests already show null effects on cancer/heart disease, which is the empirical content a DDD would formalize.

### Group 7: Format/Presentation (Grok — minor)
- Move appendix tables forward
- Inline external table inputs
- Check hyperlinks

**Action:** These are minor formatting issues. Add a sentence noting that all tables are generated from R code and included via `\input{}` for reproducibility.

## Changes to Make

1. **references.bib**: Add Figinski & O'Connell (2024), Dunn et al. (2023)
2. **paper.tex Section 6.8 (HonestDiD)**: Expand discussion of diagonal VCV conservatism
3. **paper.tex Section 5.2 (Estimation)**: Clarify CS-DiD multiplier bootstrap is cluster-level
4. **paper.tex Section 7.3 (Literature)**: Cite Figinski & O'Connell (2024)
5. **paper.tex Section 7.4 (Limitations)**: Cite Dunn et al. (2023) re: Medicare IRA cap
6. **paper.tex Section 8 (Conclusion)**: Expand future research with age-stratification, DDD, SCM
7. **paper.tex Section 6.5 (Parallel Trends)**: Strengthen 2018-2019 gap discussion
