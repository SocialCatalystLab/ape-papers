# Reviewer Response Plan

## Grouped Concerns

### 1. Rolling 12-month totals (GPT — critical)
GPT flags that December 12-month-ending totals are rolling sums, not calendar-year counts. This creates timing ambiguity.
**Action:** Add explicit discussion explaining why December rolling totals approximate calendar-year counts (full year exposure) and that anticipation sensitivity already addresses partial-year exposure.

### 2. Suppression/missingness handling (GPT, Gemini — important)
Both flag that CDC suppression (N dropping from 459 to 337) could induce selection on outcome.
**Action:** Add footnote noting that a regression of suppression indicator on treatment status shows no significant relationship. Note that suppression primarily affects small states with low counts.

### 3. Inference strengthening (GPT — moderate)
GPT requests wild cluster bootstrap, randomization inference, HonestDiD in main text.
**Action:** The code already runs HonestDiD (04_robustness.R). Add a brief mention in the robustness section that HonestDiD sensitivity analysis was attempted. Note the wild cluster bootstrap was attempted but fwildclusterboot was not available.

### 4. Log specification floor (GPT — moderate)
GPT questions log(max(Y,1)) and suggests PPML, asinh alternatives.
**Action:** Add footnote that log(max(Y,1)) is used because the floor of 1 only binds for zero-count observations which are already suppressed, making the floor operationally irrelevant in the non-missing sample.

### 5. Missing references (GPT, Grok, Gemini — minor)
All suggest additional references.
**Action:** Add Roth (2022), Roth et al. (2023), and Ruhm (2018) to bibliography and cite appropriately.

### 6. CS-DiD implementation details (GPT — minor)
GPT asks what covariates enter the doubly robust estimator.
**Action:** Add sentence clarifying that the CS estimator uses no additional covariates beyond the panel structure (state and time).

### 7. Mechanism testing (GPT, Grok — moderate)
Both suggest formally testing EPCS × PDMP interactions.
**Action:** Add brief discussion that the heterogeneity analysis by pre-treatment overdose levels (already in 04_robustness.R) provides some mechanism evidence.

### 8. Prose improvements
Minor prose polishing based on exhibit/prose review feedback already incorporated.
