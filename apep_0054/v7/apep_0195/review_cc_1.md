# Internal Review - Round 1

**Paper:** "Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap"
**Reviewer:** Claude Code (Internal)
**Date:** 2026-02-04
**Context:** Revision of apep_0154 (v4 → v5). Major additions: collapsed-cell wild cluster bootstrap, Fisher randomization, LOTO sensitivity, HonestDiD gender gap, composition tests.

---

## PART 1: CRITICAL REVIEW

### Format
- **Length:** 47 pages total (well above 25-page minimum)
- **References:** Comprehensive bibliography with new additions (Ferman & Pinto 2019, Arkhangelsky et al. 2021, Athey & Imbens 2022)
- **Prose:** All major sections in paragraph form
- **Figures/Tables:** All figures show visible data; all tables have real numbers

### Statistical Methodology
- **Standard Errors:** All regressions report SEs in parentheses. Clustered at state level.
- **DiD Method:** Uses Callaway-Sant'Anna (2021) for aggregate ATT; TWFE with sunab() for specifications requiring controls/interactions. Appropriate for staggered adoption.
- **Inference:** Three complementary approaches address small-cluster concern:
  1. Collapsed-cell wild cluster bootstrap (Webb 6-point, 99,999 iterations): DDD p=0.004
  2. Fisher randomization (5,000 permutations): DDD p=0.109
  3. Leave-one-treated-state-out: DDD range [0.058, 0.066]

### Key Concerns (Round 1)

1. **HonestDiD gender gap uninformative at M>0:** The sensitivity analysis only survives under exact parallel trends (M=0). At M≥0.5, bounds are [-1.58, 1.88] — uninformative. This limits the strength of the gender gap finding.
   - **Assessment:** The paper now correctly acknowledges this limitation. The table shows only M=0, 0.5, 1.0 with an extensive note explaining why bounds widen. Permutation inference provides complementary evidence.

2. **Permutation p-value for DDD is 0.109:** Just above the conventional 0.10 threshold. The paper frames this as "providing additional support" rather than claiming significance.
   - **Assessment:** Bootstrap p=0.004 is the primary design-based test; permutation uses a TWFE approximation on collapsed cells which is less powerful. Framing is appropriate.

3. **Aggregate ATT insignificant under alternative inference:** Bootstrap p=0.346, permutation p=0.389. The aggregate wage effect is fragile.
   - **Assessment:** Paper appropriately focuses the gender gap as the main finding. The aggregate ATT is presented as suggestive.

4. **Composition test shows significant high-bargaining shift (p=0.012):** This could indicate differential selection rather than causal effect.
   - **Assessment:** Paper discusses this in Section 6.16 but should clarify whether this undermines the main result or is consistent with a mechanism story (transparency → workers shift to high-bargaining occupations).

### Minor Issues
- Map (Figure 1) shows NY colored as 2023 cohort but income year is 2024. Caption now clarifies this distinction.
- Event study table should have explicit star notation in notes (now added).

## PART 2: CONSTRUCTIVE SUGGESTIONS
- The composition shift in high-bargaining occupations could be framed as a mechanism (transparency enables job switching) rather than a threat to identification.
- Consider adding a brief discussion of whether the gender gap narrowing comes from women's wages rising or men's wages falling.

## OVERALL ASSESSMENT
The revision substantially strengthens the inference framework with three complementary approaches to address the small-cluster problem. The gender gap result is robust to bootstrap and LOTO but sensitivity to parallel trends violations is limited (HonestDiD uninformative at M>0). The paper is honest about these limitations.

DECISION: MINOR REVISION
