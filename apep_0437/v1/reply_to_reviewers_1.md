# Reply to Reviewers (Round 1)

## GPT-5.2 (Major Revision)

> **Outcome timing**: VIIRS starting 2012 creates inconsistent post-election windows.
**Response:** We now (1) clarify the varying exposure in the Data section, (2) add a robustness specification restricting to elections with complete VIIRS windows (2012+), which yields τ = 0.171 (p = 0.30) — still null and actually larger in magnitude than the full sample, ruling out the concern that incomplete windows bias toward zero. Table 5 now includes this specification.

> **Double-alignment interaction is not causally identified.**
**Response:** Agreed. We now explicitly describe the interaction analysis as "suggestive" and "correlational rather than a clean RD estimand," acknowledging that center alignment is not quasi-randomly assigned at the state-alignment cutoff.

> **Covariate imbalance needs systematic response.**
**Response:** We now report covariate-adjusted RDD (controlling for population and SC share) in Table 5: τ = -0.091 (p = 0.46). This confirms the null is not driven by imbalances.

> **Randomization inference is not well-founded for RD.**
**Response:** We have reframed the exercise as a "permutation diagnostic" rather than formal inference, explicitly noting it does not follow standard RI frameworks for RD and that the local polynomial estimates provide primary inference.

> **Missing references: Lee & Lemieux (2010), Caughey & Sekhon (2011).**
**Response:** Added Lee & Lemieux (2010) to the citations in the Empirical Strategy section.

## Grok-4.1-Fast (Minor Revision)

> **Covariate-adjusted RDD.**
**Response:** Added (see above).

> **Missing references: Imbens & Lemieux (2008), Lee & Lemieux (2010).**
**Response:** Both now cited in the Empirical Strategy section.

> **RI-parametric gap underexplored.**
**Response:** Reframed as diagnostic; discrepancy now explained in terms of unconditional vs. conditional test statistics.

## Gemini-3-Flash (Minor Revision)

> **McCrary failure: show donut RDD as primary robustness.**
**Response:** Donut specifications (1% and 2% margins dropped) are already in Table 5 and discussed in text. The 1% donut produces the largest positive estimate (0.230, p = 0.12) while the 2% donut yields -0.037 (p = 0.86).

> **Control for imbalanced covariates.**
**Response:** Added covariate-adjusted specification: τ = -0.091, p = 0.46 (see Table 5).

> **Power analysis emphasis.**
**Response:** Revised the power discussion to emphasize that the analysis is well-powered to detect effects of the magnitude previously claimed (12-31% cumulative differences), even if it cannot detect subtler channels.
