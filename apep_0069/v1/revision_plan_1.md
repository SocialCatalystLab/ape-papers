# Revision Plan - Round 1

**Paper:** Does Local Policy Experience Build National Support? Evidence from Energy Policy in a Federal System
**Paper ID:** paper_90
**Date:** 2026-01-27
**Decision Received:** REJECT AND RESUBMIT (3/3 reviewers)

---

## Summary of Reviewer Concerns

All three reviewers identified the same fundamental issues:

### Critical (Blocking Publication)

1. **Identification weakness**: Only 5 treated cantons, all German-speaking. Cross-sectional design with canton-level treatment cannot credibly separate policy exposure from pre-existing regional differences.

2. **Inference not credible**: Canton-clustered SEs with 26 clusters and 5 treated clusters violate asymptotic assumptions. Need randomization inference or wild cluster bootstrap.

3. **RDD incomplete**:
   - Pooled across language borders (violates continuity)
   - No McCrary density test
   - No bandwidth sensitivity analysis
   - No covariate balance at cutoff
   - No donut specifications

### Major (Required for Field Journal)

4. **Paper too short**: ~20 pages vs. 25+ standard
5. **Thin literature**: 9 citations; missing foundational RDD (Imbens & Lemieux, Lee & Lemieux, Cattaneo), spatial RDD (Keele & Titiunik, Dell), DiD (Callaway & Sant'Anna), and few-cluster inference (Cameron & Miller)
6. **No confidence intervals** in main OLS table
7. **Mechanism speculation**: No testable evidence for satiation/cost salience hypotheses

---

## Revision Actions

### A. Statistical Inference Fixes (Priority 1)

1. **Add randomization inference**
   - Permutation test reassigning 5 treated cantons among 26
   - Report randomization p-values alongside conventional

2. **Add wild cluster bootstrap**
   - Use boottest / fwildclusterboot in R
   - Report bootstrap p-values and CIs

3. **Report 95% CIs for all OLS specifications**

### B. RDD Redesign (Priority 2)

1. **Restrict to same-language borders only**
   - Use only: AG-ZH, AG-SO, BL-SO, GR-SG (German-German)
   - Drop: BE-FR, BE-JU, BE-NE (language borders)

2. **Add full diagnostic suite**
   - McCrary density test (rddensity)
   - Bandwidth sensitivity: 0.5x, 1x, 1.5x, 2x MSE-optimal
   - Local linear vs local quadratic
   - Covariate balance at cutoff

3. **Add border-pair fixed effects** in robustness

### C. Literature Expansion (Priority 3)

Add 15+ citations:
- RDD: Imbens & Lemieux (2008), Lee & Lemieux (2010), McCrary (2008), Cattaneo et al. (2014, 2020), Gelman & Imbens (2019)
- Spatial RDD: Black (1999), Dell (2010), Keele & Titiunik (2015)
- DiD: Callaway & Sant'Anna (2021), Goodman-Bacon (2021), Sun & Abraham (2021)
- Few-cluster: Cameron & Miller (2015), MacKinnon & Webb (2017)
- Climate policy: Kallbekken & Saelen (2011), Drews & van den Bergh (2016)

### D. Paper Expansion (Priority 4)

Expand to 25+ pages:
- Deeper institutional background (2-3 pages)
- Extended literature review (2-3 pages)
- Power analysis section
- Expanded robustness section with new tests
- Mechanism tests with municipal covariates

---

## Limitations Acknowledged

The fundamental constraint (only 5 treated cantons) cannot be fixed without different data. The paper should:
- More explicitly frame findings as "descriptive evidence" rather than causal
- Present power calculations showing minimum detectable effects
- Emphasize the RDD is exploratory and identification-limited

---

## Target Outcome

After revisions: **Field journal (JEEM, EJPE)** rather than top general-interest. The core limitation (N=5 treated cantons) cannot deliver AER/QJE credibility without a panel design exploiting multiple referendums.
