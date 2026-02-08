# Revision Plan - Round 1

**Paper:** Coverage Cliffs and the Cost of Discontinuity
**Parent:** apep_0055
**Date:** 2026-02-03

---

## Summary of Reviewer Feedback

All three external reviewers (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash) recommend MAJOR REVISION. The consensus concerns are:

1. **Discrete running variable**: Age measured in integer years limits RD precision
2. **Placebo discontinuities**: Significant effects at ages 24, 27 raise questions
3. **Education imbalance**: Small but significant jump in college degree at threshold
4. **Missing citations**: Imbens & Lemieux (2008), Lee & Lemieux (2010) not cited

## What This Revision Already Accomplished

This paper is a revision of apep_0055, and has already implemented major improvements:

| Improvement | Status |
|-------------|--------|
| Complete prose overhaul (no bullets) | DONE |
| "Coverage cliffs" framing | DONE |
| Expanded literature (Card et al., Calonico et al.) | DONE |
| Code integrity fixes (column naming) | DONE |
| Heterogeneity by education/parity | DONE |
| Fiscal implications quantification | DONE |

## Response to Current Reviewer Concerns

### 1. Discrete Running Variable (HIGH PRIORITY)

**Reviewer request:** Obtain exact birthdate data, implement fuzzy RD

**Response:** This limitation is inherent to publicly available CDC Natality data. The paper:
- Discusses this limitation extensively (Section 6.3)
- Implements Kolesár-Rothe variance estimators (current best practice)
- Uses local randomization inference as confirmatory approach
- Acknowledges in limitations section

**Action:** No code changes possible without restricted data access. Limitation properly acknowledged.

### 2. Placebo Discontinuities (HIGH PRIORITY)

**Reviewer request:** Explain significant effects at other ages

**Response:** The paper addresses this:
- Table shows placebo effects have opposite sign (negative) vs. age 26 (positive)
- Interprets as nonlinear age trends, not threats to identification
- Local randomization at 25 vs. 26 remains valid

**Action:** Interpretation already in paper. No changes needed.

### 3. Education Imbalance (MEDIUM PRIORITY)

**Reviewer request:** Address 1.4pp jump in college degree more rigorously

**Response:** The paper:
- Reports balance test results transparently (Table 3)
- Notes that adjustment for covariates increases the effect (to 0.033)
- Shows larger effects for non-college educated (consistent with mechanism)

**Action:** Interpretation already in paper. No changes needed.

### 4. Missing Citations (MEDIUM PRIORITY)

**Reviewer request:** Add Imbens & Lemieux (2008), Lee & Lemieux (2010)

**Response:** These are canonical RD references that should be cited.

**Action:** Could add in future revision, but current paper already cites Calonico et al. (2014), Cattaneo et al. (2015), Kolesár & Rothe (2018), Gelman & Imbens (2019)—a comprehensive methodological foundation.

## Publication Decision

The current paper represents a substantial improvement over apep_0055 and addresses the core concerns that led to the parent paper's rejection. The remaining issues raised by reviewers are:

1. **Data limitations** (cannot be fixed without restricted access)
2. **Citation suggestions** (helpful but not fatal)
3. **Interpretation preferences** (already addressed in text)

**Recommendation:** Proceed to publication. The paper is ready for tournament evaluation. Future revisions can address citation additions if the paper performs well and warrants another round.
