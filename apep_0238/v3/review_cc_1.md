# Internal Review - Claude Code (Round 1)

**Paper:** Demand Recessions Scar, Supply Recessions Don't
**Version:** v3 (revision of v2)
**Date:** 2026-02-12

---

## FORMAT CHECK

- **Length:** 64 pages total, main text ~35 pages before appendix. Exceeds 25-page minimum.
- **References:** Comprehensive bibliography (~40 references) covering hysteresis, search models, LP methodology, Great Recession, COVID literature.
- **Prose:** All sections written in full paragraphs. No bullet points in main text.
- **Figures:** 13 figures with visible data, proper axes, and detailed captions.
- **Tables:** 16 tables with real data, no placeholders.

## STATISTICAL METHODOLOGY

- HC1 robust standard errors reported for all coefficients. PASS.
- Permutation p-values (1,000 reassignments) reported in brackets alongside HC1 SEs. PASS.
- Sample sizes reported (N = 50 for GR, N = 48 for COVID). PASS.
- Cross-sectional LP design — not staggered DiD, so TWFE concerns do not apply.
- R² reported for all regressions.

## IDENTIFICATION STRATEGY

- Housing price boom instrument for Great Recession: well-established in literature (Mian & Sufi 2014, Charles et al. 2016).
- Leave-one-out Bartik instrument for COVID: addresses Goldsmith-Pinkham et al. (2020) concerns.
- Pre-trend event study (Figure 2) shows null pre-period coefficients for both instruments.
- Robustness checks: subsample analysis by region and state size, leave-one-out, excluding Sand States, census division clustering, alternative Bartik base years.
- Permutation inference addresses small-sample concerns.

## KEY STRENGTHS

1. Novel comparative design: same states, two recessions, same identification framework.
2. Rich empirical specification with multiple robustness checks.
3. Structural DMP model provides microfoundations for the empirical asymmetry.
4. Clear, well-written prose in the Shleifer tradition.
5. Pre-trend validation and permutation inference strengthen inference.

## AREAS FOR IMPROVEMENT

1. Midwest subsample shows positive β (0.39) — discuss this anomaly. Small housing booms in Midwest means HPI instrument has low power there.
2. LFPR analysis limited to 20 states — note this more prominently in the main text, not just Table 1.
3. Model sensitivity heatmap shows all half-lives >120 months — the half-life metric is uninformative. Employment at h=48 is the better metric (as used in Table 11).

## DECISION: MINOR REVISION
