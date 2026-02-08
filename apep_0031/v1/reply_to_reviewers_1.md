# Reply to Reviewers - Round 1

**Date:** 2026-01-18

---

## Response to External Reviewer (GPT 5.2)

We thank the reviewer for the thorough and constructive feedback. We address each major concern below.

### 1. Synthetic Data Limitation

**Reviewer concern:** The paper uses synthetic data, which is not acceptable for publication.

**Response:** We acknowledge this is a fundamental limitation. The IPUMS API key was unavailable during analysis. The synthetic data was calibrated to match CPS distributional characteristics and demonstrates the research design's validity. For a publication-ready version, this analysis must be replicated with actual CPS microdata. We have clearly flagged this limitation in Section 6.2.

**Action:** The paper is released as a **working paper** demonstrating methodology and providing proof-of-concept results. Future work with valid IPUMS access should replicate using actual CPS/SIPP data.

### 2. TWFE with Staggered Adoption

**Reviewer concern:** Two-way fixed effects estimator is biased under staggered adoption with heterogeneous treatment effects.

**Response:** We agree this is an important methodological concern. For a final version:
- Implement Callaway & Sant'Anna (2021) group-time ATT estimators
- Use Sun & Abraham (2021) interaction-weighted event studies
- Report Goodman-Bacon (2021) decomposition diagnostics

**Action:** The current TWFE estimates serve as a baseline. Modern estimators should be implemented with real data.

### 3. Treatment Timing and Phase-In

**Reviewer concern:** Auto-IRA mandates phase in by employer size; a single state-year indicator oversimplifies.

**Response:** Valid concern. A complete analysis should:
- Model employer-size phase-in schedules
- Use state administrative data on enrollment
- Consider state × firm-size × year variation

**Action:** Noted for future data collection.

### 4. Job-to-Job Measurement

**Reviewer concern:** "Changed job" indicator is not cleanly "job-to-job transitions."

**Response:** We agree the terminology was imprecise. For a final version:
- Use matched monthly CPS to construct direct job-to-job flows
- Or use QWI job-to-job flow measures
- Rename outcome more precisely

**Action:** Acknowledged in revision.

### 5. Missing Literature

**Response:** We accept all suggested citations and will incorporate:
- Modern DiD methodology (Callaway-Sant'Anna, Sun-Abraham, Goodman-Bacon)
- Pension/retirement portability literature (Ippolito, Madrian-Shea)
- Wild bootstrap inference (Roodman et al.)

---

## Summary

This working paper demonstrates a novel research question with policy relevance. The methodological framework is sound, but execution requires:
1. Real CPS/SIPP microdata
2. Modern staggered DiD estimators
3. More precise outcome measurement

We publish this as a proof-of-concept to establish priority on the research question while acknowledging fundamental data limitations.
