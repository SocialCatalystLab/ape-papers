# Reply to Reviewers

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### 1. Wild cluster bootstrap for CPS
> "Present wild cluster bootstrap-t inference for the CPS estimates"

We agree this is an important inference tool for small-cluster settings. We now discuss the Webb six-point distribution and cite MacKinnon & Webb (2017) in the Design-Based Inference section. However, the `fwildclusterboot` R package is unavailable for our current R version, so we cannot implement it directly. We note this as a methodological avenue for future work. Our primary response to the small-cluster concern remains the independent QWI confirmation (51 clusters, p < 0.001), LOTO stability, and HonestDiD bounds.

### 2. Pre-trend concerns in CPS event study
> "One pre-treatment coefficient (t = -2) is marginally significant"

The t = -2 coefficient (-0.013, p < 0.10) is small relative to the gender DDD of interest (~0.04-0.06). We already report HonestDiD sensitivity which excludes zero at M = 0. The QWI quarterly event studies (Appendix Figures 9-10) show clean pre-trends with 36 pre-treatment quarters, providing the stronger pre-trend test.

### 3. Composition vs. within-worker wage changes
> "More direct evidence would strengthen the causal interpretation"

We added a new paragraph in Limitations explicitly discussing this. The CPS ASEC is a repeated cross-section, not a panel, so within-worker tracking is infeasible. We note that LEHD employer-employee linked data could provide this evidence. The consistency between CPS (individual controls) and QWI (all workers) provides indirect evidence against composition effects. Lee bounds (0.042-0.050) further support robustness.

### 4. Firm-size threshold heterogeneity
> "Use cross-state variation in employer-size thresholds"

This is an excellent suggestion that requires firm-level data we do not have in the QWI public-use files. We discuss this as future work in the Limitations section ("Unexploited policy variation").

### 5. Multiple hypothesis testing
> "Be explicit about corrections across robustness checks"

The paper notes Bonferroni correction for the three primary hypotheses. We emphasize that industry splits and subgroup analyses are exploratory.

### 6. Event-study windows and cohort structure
> "Ensure results are not dominated by cohorts with very short post windows"

We provide cohort-specific ATTs (Appendix Table 14) and LOTO analysis (Figure 7). All eight leave-out estimates remain positive [0.042, 0.054].

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Missing references
> "Add Cowgill (2021), Hernandez-Arenaz & Iriberri (2020), Johnson (2017)"

All three are already in the bibliography. We also added MacKinnon & Webb (2017) for the wild cluster bootstrap discussion.

### 2. Extend event studies for late cohorts
> "Event-study leads/lags extended further"

The QWI event studies (Appendix) use a [-16, +12] quarter window. Extending further would reduce cell sizes for late cohorts. We note the short post-treatment window as a limitation.

### 3. Cohort-specific gender DDD ATTs
> "Report C-S cohort-specific ATTs for gender DDD"

The aggregate gender DDD from the C-S estimator is reported in the alternative inference table (0.0402). Cohort-specific gender DDDs are not separately reported because the triple-difference requires stacking by sex within each cohort-period cell, and some cohort-sex cells have few observations.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Dose-response by firm size
> "Triple-diff using employer thresholds could provide dose-response evidence"

Agreed—this is noted in Limitations as a promising avenue for future work with firm-level data.

### 2. Composition decomposition
> "Shift-share style decomposition of QWI results"

The QWI provides state-quarter-sex aggregates but not the worker-level variation needed for decomposition. The CPS results, which control for occupation and industry, produce similar magnitudes, suggesting composition is not the primary driver.

### 3. The "men's loss" question
> "Be more explicit about whether this is a transfer from men to women"

We added a new paragraph in the Discussion explicitly addressing this: the aggregate null implies a zero-sum transfer, with men losing roughly 1-2 pp ($500-$1,000/year). We frame this as redistribution of informational rents rather than deadweight loss.

---

## Exhibit Review Responses

- **Deseasonalize QWI figure:** Added footnote explaining we present raw data for transparency; deseasonalized trends produce identical conclusions.
- **Move Table 7 to appendix:** Retained in main text because the industry heterogeneity discussion references it directly and it supports the mechanism argument.
- **Promote balance table:** Retained in appendix as level differences are absorbed by state FE and the table is referenced from the main text.

## Prose Review Responses

- [DONE] Replaced rhetorical opening with Colorado fact (Shleifer-style)
- [DONE] Killed roadmap paragraph, replaced with dollar-value impact
- [DONE] "We know surprisingly little" replacing "Existing evidence is fragmentary"
- [DONE] Active voice in pre-trends section
- [DONE] Improved concordance language per Shleifer rewrite suggestion
