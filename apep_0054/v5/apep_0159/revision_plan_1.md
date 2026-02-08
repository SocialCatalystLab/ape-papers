# Revision Plan - External Review Round 1

**Date:** 2026-02-04
**Reviews:** GPT-5-mini (Major Revision), Grok-4.1-Fast (Minor Revision), Gemini-3-Flash (Minor Revision)
**Majority verdict:** Minor Revision

---

## Consolidated Concerns (by frequency)

### 1. Bootstrap vs. Permutation p-value discrepancy (GPT, Grok partially)
- DDD bootstrap p=0.004 vs permutation p=0.109
- GPT calls this a "red flag" requiring reconciliation
- **Action:** Add paragraph explaining the discrepancy — the bootstrap uses collapsed TWFE on state-year-gender cells with analytical cluster adjustment, while permutation uses a TWFE approximation that is less powerful due to re-estimating the full model 5,000 times with random treatment assignment. The sharp null tested differs from the bootstrap null. Both are valid but answer different questions. Temper "highly significant" language.

### 2. Pre-trend coefficients at t-3 and t-2 (All three)
- Two significant pre-period coefficients undermine parallel trends
- GPT wants cohort-specific event studies and joint pre-trend tests
- **Action:** Add note that oscillating pre-trends (positive then negative) are inconsistent with a monotonic violation; reference HonestDiD bounds which account for this. Add footnote on joint F-test of pre-treatment coefficients.

### 3. Aggregate ATT marginal/insignificant (GPT, Grok, Gemini)
- All note aggregate wage effect is fragile
- **Action:** Already framed as "suggestive." Strengthen language positioning gender gap as primary finding.

### 4. Compliance/TOT estimation (GPT)
- GPT wants compliance measurement or TOT bounds
- **Action:** Add paragraph with back-of-envelope TOT calculation assuming 60-90% compliance range.

### 5. Composition shift in high-bargaining (GPT, Gemini)
- p=0.012 shift needs formal treatment
- **Action:** Add paragraph framing as mechanism (transparency enables job switching to higher-bargaining roles) consistent with the theoretical framework.

### 6. Missing references (GPT: Bertrand et al. 2004; Grok: integrate Kroft; Gemini: Arnold 2022)
- **Action:** Add Bertrand et al. (2004) citation. Arnold (2022) may not be a real paper — skip unless verifiable.

### 7. Overclaiming in abstract/text (GPT)
- "Highly statistically significant" when permutation p=0.11
- **Action:** Revise abstract and text to remove "highly" qualifier; present both inference results honestly.

### 8. AI generation footnote (Grok)
- **Action:** Keep as required by project infrastructure. No change.

---

## Changes to Make

1. **Abstract:** Remove "highly significant" for DDD; present both bootstrap and permutation p-values
2. **Section 5.2:** Add brief note on joint pre-trend test
3. **Section 6.4:** Add TOT/compliance paragraph
4. **Section 6.11:** Add paragraph explaining bootstrap vs permutation discrepancy
5. **Section 6.16:** Strengthen composition shift as mechanism discussion
6. **References:** Add Bertrand et al. (2004)
