# Internal Claude Code Review — Round 1

**Paper:** The Long Arc of Rural Roads: A Dynamic Regression Discontinuity Analysis of India's PMGSY
**Reviewer:** Claude Code (internal)
**Date:** 2026-02-20

## Summary

This paper evaluates the long-run economic effects of India's PMGSY rural roads program using a dynamic RDD at the 500-population eligibility threshold, with 30 years of nighttime lights data. The central finding is a precisely estimated null: PMGSY eligibility does not generate detectable increases in local luminosity at any horizon from 1994 to 2023.

## Assessment

### Strengths
1. **Identification:** The RDD design is clean. McCrary test passes (p=0.24), covariate balance is excellent (Table 3), and the dynamic structure provides built-in placebo tests for the pre-treatment period.
2. **Scale:** 552,788 villages with MSE-optimal effective samples of ~76,000 provide exceptional statistical power.
3. **Robustness:** Comprehensive sensitivity analysis across bandwidths, polynomial orders, donut specifications, and cross-sensor validation (DMSP/VIIRS overlap).
4. **Writing:** Clear, well-structured prose with appropriate quantification of the null (MDE = 6% luminosity / 20% GDP).
5. **Contribution:** Fills a genuine gap — long-run dynamic evaluation of the world's largest rural roads program.

### Weaknesses
1. **ITT only:** Without first-stage data, we cannot scale to TOT. The ~25pp first-stage from Asher & Novosad (2020) is cited but not replicated.
2. **Nightlights limitation:** The MDE of 6% luminosity may miss welfare-relevant effects below the detection threshold. The paper acknowledges this well.
3. **No heterogeneity analysis:** Effects could differ by distance to towns, baseline electrification, or state-level implementation quality.

### Minor Issues
- Some pre-treatment estimates (1994-96) are marginally significant; now discussed as sensor artifacts.
- Balance table previously used variable names instead of formal labels; now fixed.

## Verdict

The paper is methodologically sound, well-written, and makes a genuine contribution. The null result is credible and important. The limitations (ITT, nightlights sensitivity) are inherent to the available data and are honestly discussed.

**DECISION: MINOR REVISION**

Revisions needed:
1. Add missing references (Lee & Lemieux, Ghani et al., McCrary) — DONE
2. Fix balance table labels — DONE
3. Improve prose per exhibit and prose reviews — DONE
4. Write reply to reviewers — DONE
