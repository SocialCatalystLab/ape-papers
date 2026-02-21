# Revision Plan — apep_0435 v1

## Review Summary

| Reviewer | Model | Decision |
|----------|-------|----------|
| GPT-5.2 | External referee | MAJOR REVISION |
| Grok-4.1-Fast | External referee | MINOR REVISION |
| Gemini-3-Flash | External referee | MINOR REVISION |
| Gemini-3-Flash | Exhibit review | Constructive |
| Gemini-3-Flash | Prose review | Constructive |

## Key Concerns and Planned Responses

### 1. AIPW Causal Overreach (GPT — Critical)

**Concern:** AIPW framed as if it delivers causal estimates, but unconfoundedness is not credible with limited covariates (language/religion/suffrage year only).

**Response:** Reframe AIPW throughout as a *functional-form robustness check* and *covariate rebalancing exercise*, not a causal estimator. Explicitly state the persistence parameter is a predictive/conditional association. Soften all causal language ("show that" → "document", "confirm" → "is consistent with").

### 2. Construct Validity (GPT — Important)

**Concern:** σ-convergence computed across different referenda that may not measure the same latent attitude. Dispersion changes may reflect different issue salience, campaign structures, or ceiling/floor compression.

**Response:** Add a paragraph in the limitations section explicitly acknowledging this concern. Note that the strong cross-referendum correlations (falsification tests) are consistent with a common latent factor, but we cannot formally test this with only 6 referenda. Suggest IRT/PCA as valuable future work. Note that our focus on the 1999–2021 decline (all referenda with >35% support) mitigates floor/ceiling compression.

### 3. Multidimensional Ideology (GPT — Important)

**Concern:** Mixed signs in falsification table could reflect multidimensional ideology rather than domain-specific gender norms.

**Response:** Add a paragraph in the falsification discussion acknowledging this alternative interpretation. Note that the *mixed signs* are the key evidence: if 1981 gender attitudes merely captured a left-right spectrum, we would expect uniformly signed coefficients across all outcomes. The inconsistent direction across non-gender votes is more consistent with domain specificity than with multidimensional ideology mapping.

### 4. Missing References (GPT + Grok)

**Response:** Add ~8 new references:
- Giuliano & Nunn (2020) — cultural persistence speed
- Borella et al. (2023) — U.S. gender norm convergence
- Quah (1993) — σ-convergence measurement caveats
- Cameron & Miller (2015) — practitioner's guide to clustered inference
- Chernozhukov et al. (2018) — double/debiased ML
- Athey & Imbens (2017) — state of applied econometrics

### 5. Prose Quality (Prose Review)

**Response:**
- Convert Section 2.5 bullet list to flowing prose
- Reduce "Column X says..." table narration in results
- Add plain-English intuition before AIPW equations
- Humanize key findings with contextual magnitudes

### 6. Exhibit Reorganization (Exhibit Review)

**Response:**
- Move Table 4 (σ-convergence detail) to appendix — Figure 1 carries the story
- Move Table 5 (falsification detail) to appendix — Figure 3 carries the story
- Remove redundant Oster appendix table (Table 9) — already in Table 2

### 7. Estimand Clarity (GPT)

**Response:** Add explicit statement that the estimand is municipality-average behavior (each municipality weighted equally), not voter-average behavior. Note this as a design choice reflecting interest in community-level norms.

### 8. Post-2004 Timing (GPT)

**Response:** Reframe as "temporal coincidence" rather than causal mechanism. Soften the policy feedback language to acknowledge this is suggestive, not identified.

## Execution Order

1. Add new references to references.bib
2. Reframe AIPW section (Section 4.2) — robustness framing
3. Soften causal language throughout
4. Rewrite Section 2.5 as prose
5. Humanize results section
6. Add construct validity, multidimensionality, and estimand clarity paragraphs
7. Move Tables 4 and 5 to appendix
8. Remove redundant Oster appendix table
9. Recompile and verify
