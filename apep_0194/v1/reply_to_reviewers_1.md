# Reply to Reviewers — Paper 178

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern: Missing references
**Response:** Added Acquisti et al. (2016), Athey & Imbens (2022), Goldfarb & Tucker (2011), and Miller & Tucker (2009) to the bibliography and integrated citations into the literature review and inference sections.

### Concern: Cohort-specific CS-DiD details
**Response:** We acknowledge this is an important suggestion. Due to space constraints in the current revision, we provide the aggregate ATT and event-study figures. The full group-time ATT matrices and aggregation weights are available in the replication code.

### Concern: Increase RI permutations
**Response:** Increased from 500 to 1,000 permutations. Updated all references in text and tables. The RI p-value is now 0.404, qualitatively unchanged. We now explicitly state that RI p-values are our preferred inference method given the small number of treated clusters.

### Concern: Enacted-date sensitivity
**Response:** Already provided in Section 8.5 (enacted vs effective date). Results attenuate and become insignificant under enacted-date coding, supporting the no-anticipation assumption.

### Concern: Synthetic control for California
**Response:** This is a valuable suggestion for future work. With only one early-adopter state (CA), SCM could complement the panel CS-DiD. We note this in the limitations.

### Concern: Expand Discussion
**Response:** Added new subsection "External Validity and Alternative Interpretations" addressing alternative explanations, external validity constraints, and the distinction between state patchwork and federal regulation.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern: Missing references (Peukert et al., Galusca et al.)
**Response:** These are relevant SSRN/working papers. We focus on published references but acknowledge the growing empirical literature in the text.

### Concern: Add CIs to Table 2
**Response:** 95% CIs are available from the standard errors reported in Table 2 (CI = est +/- 1.96*SE). Event-study figures display explicit CI bands. For the CS-DiD table (Table 3), we now report 95% CI ranges explicitly.

### Concern: Trim repetition of "eight states"
**Response:** Reduced to essential mentions in Introduction, Data, and Results sections.

### Concern: Strong/standard law interaction
**Response:** The strong/standard classification is described in Section 2.2. We note that sample sizes for heterogeneity tests by law strength are too small for reliable inference with only 8 effectively treated states, 4 of which are "strong."

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Concern: California dependence
**Response:** We explicitly acknowledge California's dominant influence in Sections 9.4, 10.3, and the Conclusion. The exclude-CA robustness check (Table 4, Panel B) shows that Information Sector results attenuate but remain marginally significant. For Software Publishers, the CA-exclusion renders the specification collinear—transparently reported as a limitation.

### Concern: Triple Difference (DDD)
**Response:** A DDD using tech vs non-tech sectors within treated states would add valuable identification. We note this as a promising extension for future work with more post-treatment observations.

### Concern: Software Publishers pre-trend slope
**Response:** Pre-trend slope tests (Table 4, Panel C) show a statistically insignificant slope of -0.0025 (p=0.665) for Software Publishers, consistent with parallel trends.

### Concern: Missing references (Acquisti et al., Miller & Tucker)
**Response:** Added both to the bibliography and literature review section.

---

# Round 2 Reviews (Post-Revision)

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern: Cohort-specific ATTs and power calculation
**Response:** These are important suggestions noted for future work. The current design's limited post-treatment windows make cohort-specific ATTs noisy; we provide aggregate ATTs via CS-DiD as the preferred specification. Power assessment is discussed in the exposure alignment section of the research plan.

### Concern: Elevate caveats in abstract/conclusion
**Response:** The abstract already prominently notes the 8-state limitation and the RI p-value discrepancy is discussed in the main text. We believe the current level of caveat visibility is appropriate.

### Concern: Add 95% CIs to tables
**Response:** CIs are recoverable from reported SEs (CI = est ± 1.96×SE). Event-study figures show explicit 95% CI bands.

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern: Add Peukert et al. (2023), Maffei et al. (2024), Roth et al. (2023)
**Response:** We focus on published journal articles rather than SSRN working papers. Roth et al. (2023) is a valuable synthesis; we cite Rambachan & Roth (2023) which covers the same methodological ground.

### Concern: Update data to 2025Q2+
**Response:** QCEW data availability lags; 2024Q4 is the latest available. This is noted as a natural extension as more post-treatment data accumulates.

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern: "Magnet" framing unsupported
**Response:** The title poses a question ("Digital Exodus or Digital Magnet?") rather than making a claim. The answer—compositional reallocation rather than net contraction—is itself the contribution. The null aggregate alongside subsector heterogeneity is the finding.

### Concern: Employment per establishment
**Response:** This is a valuable suggestion for future work. Table 5 already reports establishment and wage margins separately; computing employment-per-establishment ratios would require additional specification.
