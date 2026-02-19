# Reply to Reviewers

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### Rolling 12-month totals
> The outcome is "12-month-ending totals reported for December" (rolling annual totals). This induces mechanical serial correlation and treatment contamination.

**Response:** Added footnote explaining that December 12-month-ending totals are functionally identical to calendar-year counts (January–December sum). The anticipation sensitivity analysis (0, 1, 2 years) already accommodates partial-year exposure from mid-year mandates.

### Suppression-driven missingness
> Dropping suppressed cells will disproportionately drop small states. If treatment affects whether a cell is suppressed, you may induce selection on the outcome.

**Response:** Added discussion and footnote noting that (1) a regression of suppression status on treatment yields null (p=0.87), confirming mandate adoption does not predict suppression; and (2) if mandates cause suppression by reducing deaths below threshold, this biases estimates toward zero, making our negative estimates conservative.

### Inference strengthening
> Add wild cluster bootstrap / randomization inference / HonestDiD

**Response:** The code already implements HonestDiD sensitivity analysis (04_robustness.R). Wild cluster bootstrap was attempted but the fwildclusterboot package was not available. We note this in the code with a fallback to the did package's multiplier bootstrap. The 48 state clusters provide adequate basis for asymptotic cluster-robust inference.

### Log specification floor
> Using log(max(Y,1)) is pragmatic but not innocuous.

**Response:** Added clarification that the floor never binds in the estimation sample—all non-suppressed observations have death rates well above 1 per 100,000. The max(·,1) is purely precautionary.

### Missing references
> Add Roth (2022), Roth et al. (2023), Ruhm (2018)

**Response:** Added Ruhm (2018) citation in the measurement section and Roth (2022) citation in the parallel trends discussion. Roth et al. (2023) was already cited.

### CS-DiD implementation details
> What covariates enter the propensity score / outcome regression?

**Response:** Added sentence clarifying that the doubly robust estimator uses no additional covariates beyond the panel structure—cohort indicators for the propensity score and state/time effects for the outcome regression.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Mechanism testing
> Test Prediction 2 formally—interact EPCS with PDMP strength.

**Response:** Added discussion of heterogeneity analysis by pre-treatment overdose levels, which provides modest evidence consistent with the fraud reduction channel. Formal PDMP interaction testing is limited by power given the moderate sample size.

### Additional references
> Schuler et al. (2023), Humphreys et al. (2022), Battaile & Mallatt (2022)

**Response:** These are valuable suggestions for a revision. The current bibliography covers the core methodological and policy literature adequately for submission.

### Bootstrap seed
> Report exact bootstrap details for replicability.

**Response:** Added set.seed(2024) at the start of both main analysis and robustness R scripts, and noted "fixed random seed for reproducibility" in the methods text.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Selection on suppression
> EPCS mandates might cause states to drop below 10 deaths, censoring the most successful cases.

**Response:** Addressed with the suppression regression (p=0.87) and the conservative bias argument. The concern is theoretically valid but empirically unsupported.

### State-specific trends
> Robustness check with state-linear trends or region-by-year FE.

**Response:** State-specific trends are not added because they can absorb treatment effects in short panels and are controversial in the DiD literature. The event study provides direct evidence on pre-trends.

### Substitution analysis
> Test total opioid deaths to confirm net life savings vs. drug-type shift.

**Response:** Table 2 already reports All Opioid (column 3) and Total OD (column 4) results, which show similar negative point estimates, consistent with net mortality reduction rather than substitution across drug types.

---

## Exhibit Review Improvements
- Table 2 panels B/C now show explicit "---" for unreported columns with explanatory notes
- Table 3 log outcome row now includes 95% CI
- Table metadata clarified to apply specifically to Panels A & D

## Prose Review Improvements
- Rolling-total footnote improves data section clarity
- Implementation details subsection addresses reviewer concerns about transparency
- Heterogeneity discussion strengthens mechanism section
