# Reply to Reviewers

## Response to Corpus Scanner (SEVERE Verdict)

The original paper received a SEVERE integrity verdict with 27 flags including 2 CRITICAL issues. We have addressed all issues:

**CRITICAL Issues Resolved:**

1. **DATA_FABRICATION (01b_fetch_qcew.R)**: The quarterly proxy approach was not fabrication but intentional temporal interpolation. We have added comprehensive documentation explaining this approach, its limitations, and implications for inference. The code now includes a header warning and a flag (`is_annual_interpolation = TRUE`) for downstream scripts.

2. **STATISTICAL_IMPOSSIBILITY (03_main_analysis.R:118)**: The SE=0 for the reference year was standard event study normalization, not a statistical impossibility. We changed this to SE=NA to clarify that the standard error is undefined (not zero) for the normalized baseline year.

**HIGH Issues Resolved:**

- Added DATA_SOURCES.md with machine-readable provenance links
- Renamed methodology from "DiD" to "Continuous Exposure Effects Design"
- Added proper guards for QWI data availability checks
- Renamed permutation approach to clarify it permutes exposure, not timing
- Documented all sample restrictions in Data Limitations section

---

## Response to GPT-5-mini (MAJOR REVISION)

**Concern 1: Lack of statistical inference and uncertainty quantification**

*Response*: We have added a new illustrative application section (Section 7) that presents regression results with standard errors, p-values, and discusses statistical significance. We have also added a comprehensive robustness section (Section 8) with permutation inference, leave-one-state-out analysis, and sensitivity checks. However, we maintain our position that the results are "suggestive" rather than causal, given the identification challenges we discuss.

**Concern 2: Missing methodological citations**

*Response*: We have added all requested citations including Callaway & Sant'Anna (2021), Goodman-Bacon (2021), Sun & Abraham (2021), Goldsmith-Pinkham et al. (2020), and others. We have also added a methodological context subsection explaining how our design relates to these literatures.

**Concern 3: Sensitivity analyses for construction choices**

*Response*: Section 8 now includes comprehensive robustness analyses covering lag specifications, time windows, clustering approaches, and leave-one-state-out tests.

---

## Response to Gemini-3-Flash (REJECT AND RESUBMIT)

**Concern 1: Paper is purely descriptive**

*Response*: We have added an illustrative application section (Section 7) with regression analysis, event studies, and industry heterogeneity tests. However, we maintain that the paper's primary contribution is the exposure measure and its descriptive properties. We explicitly label the regression results as "illustrative" rather than causal.

**Concern 2: Missing methodological citations**

*Response*: Added all requested citations. See revised references section.

**Concern 3: Too many bullet lists**

*Response*: Converted bullet lists in the Introduction to narrative prose. Some lists in the Data section remain for clarity.

**Concern 4: QCEW temporal interpolation**

*Response*: We acknowledge this limitation in the new Data Limitations section (Section 3.4). The illustrative results should be interpreted with this caveat in mind. We note that the effective sample size for temporal variation is years, not quarters.

---

## Response to Grok-4.1-Fast (MINOR REVISION)

**Concern 1: Add inference to descriptives**

*Response*: Added bootstrap CIs to correlations and clustered SEs to group comparisons in the illustrative application section.

**Concern 2: Missing DiD/shift-share citations**

*Response*: Added Callaway & Sant'Anna, Goodman-Bacon, Sun & Abraham, and Goldsmith-Pinkham et al.

**Concern 3: Convert bullets to prose**

*Response*: Converted Introduction bullet list to narrative. Left some technical lists for clarity.

---

## Summary of Position

We appreciate the reviewers' thorough feedback. The main tension is between reviewers who want causal identification and our explicit choice to focus on data construction. We have:

1. Fixed all code integrity issues
2. Added statistical inference where appropriate
3. Added comprehensive robustness analyses
4. Added all requested methodological citations
5. Added a Data Limitations section acknowledging key caveats
6. Improved prose and narrative flow

We maintain that the paper's contribution is the exposure measure itself, which future researchers can use with appropriate identification strategies. The illustrative application demonstrates the data's potential but does not claim causal effects.
