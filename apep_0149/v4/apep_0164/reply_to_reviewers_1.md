# Reply to Reviewers

**Paper:** Does the Safety Net Bite Back? Medicaid Postpartum Coverage Extensions
**Date:** 2026-02-04

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Format Check
> Length, references, prose, section depth, figures, tables all pass.

**Response:** Thank you.

### Statistical Methodology
> Methodology is present and appropriate. CS-DiD, permutation, WCB, HonestDiD all implemented.

**Response:** Thank you.

### Identification Strategy

> The pre-treatment window is short (2017-2019). Show power of the pre-trend test.

**Response:** Acknowledged. The 3 clean pre-PHE years are a structural limitation of this evaluation period. The DDD pre-trend joint test (p = 0.595) cannot detect small violations. We discuss this limitation explicitly in Section 8.5. Adding pre-trend power calculations is deferred to future work.

> Need diagnostics on endogeneity of adoption timing. Show correlations between adoption timing and pre-PHE enrollment trends.

**Response:** The unwinding intensity analysis (Section 7.14) correlates KFF disenrollment rates with adoption timing via Spearman rank correlation. We also include a TWFE interaction of treated × high-disenrollment. These partially address the endogeneity concern. Stratified permutations and formal adoption-timing regressions are deferred to future work.

> Thin control group (4 states) requires reweighting or synthetic control.

**Response:** The leave-one-out analysis (Table 8) shows results are robust to dropping any single control state. Synthetic control and entropy balancing are noted as valuable extensions but are deferred given the scope of the current revision.

> Power and precision: MDE ~4.3 pp should be emphasized more prominently.

**Response:** **Implemented.** The abstract now explicitly compares MDE (4.3 pp) to the point estimate (0.99 pp) and plausible effect range (2.5-10.5 pp), noting the data can rule out large effects but cannot distinguish modest positive from true zero.

> Add heterogeneity along unwinding intensity axis.

**Response:** The unwinding intensity analysis (Section 7.14) includes a TWFE interaction splitting states by disenrollment rate. Expanding this to DDD heterogeneity is deferred.

### Literature
> Add Goldsmith-Pinkham, Sorkin, Swift (2020).

**Response:** Noted for future revision.

### Writing Quality
> Generally strong. Shorten abstract; add plain-English summary.

**Response:** Abstract updated with clearer power context. Plain-English summary addition deferred.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Format, Methodology, Identification
> All pass. "Gold-standard methodology." "Publication-ready."

**Response:** Thank you.

### Literature
> Add Kline et al. (2024), Soni et al. (2023), Courtmanche et al. (2018).

**Response:** Noted for future revision. These are valuable additions that would strengthen the unwinding and ACS measurement discussions.

### Constructive Suggestions
> Admin data merge, synthetic controls, heterogeneity by race/unwinding, crowd-out.

**Response:** All valuable extensions noted for future work. Administrative data comparison is identified as the most important next step in Section 8.6.

---

## Reviewer 3 (Gemini-3-Flash): CONDITIONALLY ACCEPT

### All Sections
> Pass. "Very high-quality empirical paper." "Heroic null."

**Response:** Thank you.

### Suggestions
> Heterogeneity by state admin quality; magnitudes in abstract.

**Response:** Abstract magnitudes **implemented** (explicit MDE comparison). Admin quality heterogeneity is a valuable suggestion deferred to future work pending data availability.

> Add Guth & Ammula (2024) KFF reference.

**Response:** Noted for future revision.

---

## Summary of Changes

| Change | Status |
|--------|--------|
| Abstract power framing | Implemented |
| SE consistency (0.69 -> 0.63) | Implemented |
| Monte Carlo -> analytic references | Implemented |
| 2024-only text reconciliation | Implemented |
| Permutation documentation | Implemented |
| Additional references | Deferred |
| Stratified permutations | Deferred |
| Synthetic control / reweighting | Deferred |
| Admin quality heterogeneity | Deferred |
