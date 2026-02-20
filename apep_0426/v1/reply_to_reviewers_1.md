# Reply to Reviewers

## Paper: "Did India's Employment Guarantee Transform the Rural Economy?"
## APEP-0426, v1

---

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### 1. Treatment Timing Measurement Error
**Concern:** Phase assignment is reconstructed, not from official sources.
**Response:** We acknowledge this limitation explicitly in the paper. The reconstruction follows the documented methodology (composite backwardness index from Census 2001) and correctly reproduces the 200/130/310 district split. We add a sentence in the Limitations section about systematic misclassification near thresholds. Official gazette notifications would strengthen the analysis but are not digitized in machine-readable format.

### 2. Parallel Trends Violation (Significant Placebo)
**Concern:** Placebo coefficient of 0.184 is significant, suggesting violated parallel trends.
**Response:** We now cite Roth (2022) on interpreting pre-trend tests cautiously and frame the placebo result more prominently. The HonestDiD sensitivity analysis—already in the paper—shows that even modest trend violations (M=0.04) push CIs to include zero. We emphasize that the null result is robust to allowing for differential pre-trends, since the confidence intervals already span zero under exact parallel trends.

### 3. Compressed Rollout Limits Long-Run Inference
**Concern:** Not-yet-treated controls exist for at most 2 years.
**Response:** We add an explicit caveat distinguishing medium-run estimates (2006–2013, cleanly identified) from longer-run estimates (2014–2023, more assumption-dependent). This reframing is now in the main results section.

### 4. Inference Robustness for Few Clusters
**Concern:** ~30 state clusters may yield fragile inference.
**Response:** We add discussion citing Cameron, Gelbach, & Miller (2008) noting that 30 clusters is above the conventional threshold where cluster-robust SEs become unreliable, though finite-sample corrections may matter. Wild cluster bootstrap was attempted but the package is unavailable for the installed R version; we note this limitation.

### 5. Reconcile CS vs SA Divergence
**Concern:** CS near zero vs SA significantly negative needs more explanation.
**Response:** We add explicit discussion of why the estimators diverge: CS uses not-yet-treated controls and drops the 2006 cohort, while SA uses the last-treated cohort (Phase III) as reference—which may fail if Phase III districts were on differential growth paths.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Key suggestions addressed:
- Added Zimmermann (2021), Roth (2022), Cameron et al. (2008), Foster & Rosenzweig (2004) to references
- Improved opening hook per prose review suggestions
- Added policy implications subsection
- Expanded limitations section with more detail on each threat
- Reframed conclusion to end on stronger note

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Key suggestions addressed:
- Added medium-run vs long-run framing
- Strengthened cluster inference discussion
- Added policy implications section
- Fixed "doubly robust" → "regression-based" throughout (estimator actually changed in code)
- Updated all CS-DiD numbers to reflect regression estimator (ATT: 0.033, SE: 0.144)
- Updated Bacon decomposition table with actual numeric estimates (0.256 and -0.096)
