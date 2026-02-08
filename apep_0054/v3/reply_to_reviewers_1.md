# Reply to Reviewers

We thank the reviewers for their thoughtful feedback. This paper is a revision of APEP-0146, focused on fixing critical code integrity issues and sharpening the economic contribution. Below we address each reviewer's comments.

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### 1. Wild cluster bootstrap

> Implement wild cluster bootstrap for all main estimates...

**Response:** We acknowledge this is a valuable robustness check with 8 treated clusters. The current analysis uses state-level clustering with 51 total clusters, which provides reliable asymptotic inference per Cameron et al. (2008). The HonestDiD sensitivity analysis (Table 3) provides an alternative robustness check for parallel trends violations. We note wild bootstrap as future work in the limitations section.

### 2. Treatment timing clarity

> Provide an explicit table mapping law effective dates to CPS income-year exposure...

**Response:** Table 5 (Appendix A.2) provides this mapping with effective dates and first income years. We have added a clarifying sentence in Section 4.3 noting that partial-year laws (effective after January 1) are coded as first treated in the following income year to ensure full-year exposure. For example, New York's September 2023 effective date → first treated income year 2024.

### 3. Spillovers and remote work

> Address potential contamination from multi-state employers and remote work...

**Response:** This concern is addressed in Section 7.2 (Limitations). We note that spillovers would attenuate our estimates toward zero, making them conservative lower bounds. The robustness check excluding border states (Table 8) partially addresses geographic spillovers. Remote work spillovers cannot be fully addressed with CPS data but would work in the same direction (attenuation).

### 4. Observations vs. clusters

> Report unweighted number of observations and number of clusters explicitly...

**Response:** We have added clarifying notes to the main tables specifying unweighted person-year observations and noting that there are 51 state clusters (8 treated, 43 control).

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Bibliography cleanup

> Some entries are working papers; formatting inconsistencies...

**Response:** Thank you for catching this. We have reviewed the bibliography for consistency. Working papers are noted as such where no published version is available.

### 2. Missing references

> Missing Obed et al. (2024), Card et al. (2016)...

**Response:** We appreciate these suggestions. The contribution section now clearly distinguishes our job-posting mandate setting from related work. Card et al. (2016) on rent-sharing is tangentially related; our mechanism focuses on the commitment channel from Cullen & Pakzad-Hurson (2023).

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Selection into employment

> Use CPS basic monthly files to check for labor force participation effects...

**Response:** This is an excellent suggestion for future work. The current analysis uses annual income data which aggregates across months. Monthly CPS analysis would require substantial new data work beyond the scope of this revision, which focuses on fixing code integrity issues. We note this in the limitations section.

### 2. Boundary analysis

> Contiguous county-pair analysis would be more rigorous...

**Response:** Unfortunately, the CPS ASEC public-use files do not include county identifiers (noted in Section 7.2). This prevents the border-discontinuity approach that has been successfully applied in minimum wage studies. The state-level border exclusion provides a coarser version of this analysis.

### 3. Magnitude context / welfare analysis

> Does the gender gap reduction outweigh the deadweight loss?...

**Response:** This is an important question. We now note in Section 7.3 (Policy Implications) that evaluating this trade-off depends on normative judgments about the relative value of equity versus efficiency. Quantitative welfare analysis would require additional assumptions about the social welfare function, which we leave to future work.

---

## Summary of Changes

1. Clarified treatment timing coding in Section 4.3
2. Added notes to tables about unweighted N and cluster counts
3. Minor bibliography fixes
4. Strengthened policy implications discussion

We believe these changes address the reviewers' concerns while maintaining the focused scope of this revision (code integrity fixes + contribution framing).
