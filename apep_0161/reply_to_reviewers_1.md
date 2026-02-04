# Reply to Reviewers

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Missing references (Bertrand et al. 2004, Cameron et al. 2008)
**Response:** Added citations to Bertrand et al. (2004) and Cameron et al. (2008) in Section 5.2 where inference methods are described. Both were already in the bibliography but are now explicitly cited in the text.

### Concern 2: Report exact N and cluster counts in tables
**Response:** Tables 1, 3, and 4 already report N and number of states. Added explicit reporting of N=1,142 and 50 clusters in the inference table (Table A3). The heterogeneity table (Table 5) now notes that N varies because each column uses a different treated-state subset.

### Concern 3: Tighten null interpretation
**Response:** Revised abstract and introduction to emphasize the 1-4 year post-treatment horizon. Added "available in current data" qualifier. Discussion section already contained extensive caveats about short horizon and pandemic overlap.

### Concern 4: Suppression handling
**Response:** The current approach (flag as missing, bounds imputation at 0 and 9, unbalanced panel estimator) is appropriate given the limited number of suppressed cells. We acknowledge the suggestion for Bayesian/multiple imputation as a potential future refinement in the Limitations section.

### Concern 5: Synthetic control / DDD
**Response:** Added Abadie et al. (2010) citation in the future work section. These alternatives are noted as promising extensions but are beyond the scope of this revision.

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Missing references (Finkelstein 2019, Andrews 2019)
**Response:** Added Finkelstein et al. (2019) citation in the Discussion section (comparison with related literature). Andrews (2019) MDE reference is a working paper that has not been formally published; the MDE calculations follow standard power analysis formulas already cited.

### Concern 2: Promote Table A5/A6
**Response:** These tables remain in the appendix for compactness, but they are extensively discussed in the main text (Sections 6.5 and 6.8).

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Concern 1: Bulleted lists in Introduction/Conceptual Framework
**Response:** The causal chain in Section 3 uses bold-headed paragraphs (not bullet points), which is standard journal formatting for theoretical mechanisms. The "Predictions" paragraph uses inline enumeration within a single paragraph. No changes needed.

### Concern 2: "Summary for Policymakers" feels like a policy brief
**Response:** Removed the Summary for Policymakers subsection. Key policymaker-relevant points are already covered in the Policy Implications subsection and the Conclusion.

### Concern 3: Heterogeneity by insurance market share / mechanisms
**Response:** Added ERISA exemption rates as a promising triple-difference extension in the future work section (Conclusion). Individual-level insurance data are not publicly available at the state-year level needed for this design.
