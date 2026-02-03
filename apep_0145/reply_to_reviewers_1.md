# Reply to Reviewers - Round 1
**Paper:** EERS and Residential Electricity Consumption (apep_0145)
**Date:** 2026-02-03

---

## Context

This paper is a targeted revision of apep_0144 implementing two specific changes requested by the principal investigator:
1. Remove industrial production robustness check
2. Add Honest DiD (Rambachan-Roth) sensitivity analysis

Both changes have been successfully implemented. We thank the reviewers for their constructive feedback, which we address below.

---

## Response to GPT-5-mini (MAJOR REVISION)

### Inference Concerns

**Reviewer:** "The paper must provide cluster-robust bootstrap inference for CS-DiD estimates."

**Response:** We appreciate this concern. The paper currently reports:
- Analytical clustered SEs at the state level for all specifications
- 95% confidence intervals for all main estimates
- Wild cluster bootstrap for the TWFE benchmark (p=0.14)
- Honest DiD sensitivity analysis (Rambachan-Roth) showing bounds under parallel trends violations

The CS-DiD package (`did` in R) implements clustered inference internally. We acknowledge that additional bootstrap procedures specifically for CS-DiD would strengthen the paper. This is noted for future work.

### Placebo Tests

**Reviewer:** "Present placebo outcomes in main tables."

**Response:** The industrial electricity placebo has been removed from this revision per user request. The paper retains discussion of why residential electricity is the appropriate outcome and why total electricity shows pre-trend violations.

### Missing Literature

**Reviewer:** Suggests adding Abadie et al. (2010), Imbens & Lemieux (2008), Conley & Taber (2011).

**Response:** Thank you for these references. These would strengthen the methodological positioning. Noted for future revision.

---

## Response to Grok-4.1-Fast (MINOR REVISION)

### Missing References

**Reviewer:** Suggests Mildenberger et al. (2022), Knittel & Stolper (2023), Imbens & Lemieux (2008).

**Response:** Thank you. The Mildenberger et al. reference is particularly relevant as a predecessor using TWFE (biased) methods. Will add in future revision.

### Industrial Placebo

**Reviewer:** "Table industrial placebo."

**Response:** The industrial placebo section has been removed per user request, as it was not central to the paper's contribution.

### Prose-ify Contributions

**Reviewer:** "Convert italic/bold contributions list to prose."

**Response:** Thank you for this stylistic suggestion. The Introduction structure is inherited from the parent paper and follows common conventions in applied economics journals.

---

## Response to Gemini-3-Flash (CONDITIONALLY ACCEPT)

We thank the reviewer for the positive assessment and constructive suggestions.

### Dose-Response

**Reviewer:** "Treatment intensity specification would yield more granular policy recommendations."

**Response:** We removed the DSM treatment intensity analysis from this revision due to data provenance concerns with the EIA Form 861 data processing. The suggestion to use continuous EERS target stringency is valuable for future work.

### Commercial Sector

**Reviewer:** "More dedicated look at commercial sector."

**Response:** The commercial sector analysis is beyond the scope of this targeted revision but would be valuable for a comprehensive follow-up study.

### COVID Robustness

**Reviewer:** "Exclude 2020-2022 pandemic years."

**Response:** Excellent suggestion. The late adopter cohorts (2018-2020) have limited post-treatment data regardless, and the Honest DiD analysis already reveals sensitivity at long horizons. A pandemic-specific robustness check is noted for future work.

### Missing Reference

**Reviewer:** Suggests Metcalf & Hassett (1999) for energy paradox discussion.

**Response:** Thank you. This foundational reference would strengthen the engineering-econometric gap discussion.

---

## Summary

The core requested changes (remove industrial robustness, add Honest DiD) have been successfully implemented. The reviewer feedback provides an excellent roadmap for future enhancements. The paper now includes sophisticated sensitivity analysis (Rambachan-Roth Honest DiD) that transparently documents the fragility of long-run effect estimates to parallel trends violations.
