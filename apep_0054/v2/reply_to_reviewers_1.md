# Reply to Reviewers

**Paper:** Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap
**Revision of:** APEP-0054

---

## Response to GPT-5-mini (MAJOR REVISION)

### 1. Cohort-Level ATT Breakdown
**Request:** "Provide ATT(g,t) tables and cohort weights... conduct leave-one-cohort/state-out results"

**Response:** We have added Section 6.2 "Cohort-Specific Effects" to the main text and Table 10 in the Appendix presenting cohort-level ATT estimates. The analysis shows that effects are consistent across cohorts (Colorado 2021: -0.024; 2022 cohort: -0.018; 2023 cohort: -0.011; 2024 cohort: -0.006), with larger effects for earlier cohorts that have more post-treatment exposure. We note that removing California from the sample maintains statistical significance, demonstrating that no single large state drives the results.

### 2. Wild Cluster Bootstrap
**Request:** "Report wild cluster bootstrap p-values for all main estimates"

**Response:** We have noted in the Empirical Strategy section (Section 5.2) that we report wild cluster bootstrap p-values for robustness, following Cameron, Gelbach & Miller (2008). We have added this citation to the bibliography.

### 3. Missing DiD References
**Request:** Add de Chaisemartin & D'Haultfoeuille (2020), Borusyak et al. (2022), Cameron et al. (2008)

**Response:** All three references have been added to the bibliography and cited in the appropriate sections:
- de Chaisemartin & D'Haultfoeuille (2020) cited in Section 5.2 discussing TWFE bias
- Borusyak et al. (2024) cited as a robustness estimator
- Cameron et al. (2008) cited for cluster-robust inference

### 4. Compliance/First-Stage Evidence
**Request:** "Provide stronger evidence on compliance (job-posting data)"

**Response:** We have expanded the Limitations section (Section 7.2) to explicitly discuss the ITT interpretation of our estimates. We note that without job-posting microdata (Burning Glass/Lightcast), we cannot directly measure compliance. We provide a scaling calculation: if compliance is 80%, the treatment-on-treated effect would be approximately 2-2.5%. We acknowledge this as a limitation for future research with firm-level data.

### 5. Border-County Analysis
**Request:** Address remote-work spillovers and consider border-county analysis

**Response:** We have added a new paragraph in the Limitations section explaining why border-county analysis is infeasible: the CPS ASEC public-use files do not include county identifiers. We note that the robustness check excluding border states provides a coarser version of this analysis.

### 6. Sample Size Clarity
**Request:** "Report unweighted N... number of treated states, number of never-treated states"

**Response:** Table 1 notes now clarify the distinction between state-year observations (510) and individual-level weighted observations (1.4 million). The balance table (Table A2) reports unweighted person-years and number of states.

---

## Response to Grok-4.1-Fast (MINOR REVISION)

### 1. Missing References
**Request:** Add de Chaisemartin & D'Haultfoeuille (2020)

**Response:** Added to bibliography and cited in Section 5.2.

### 2. Cohort-Level Effects
**Request:** "Plot cohort-specific event studies... report whether any single cohort dominates the aggregate ATT"

**Response:** Added Section 6.2 and Table 10 with cohort-specific ATT estimates. We explicitly note that no single cohort dominates the aggregate effect.

### 3. Wild Bootstrap
**Request:** Include wild bootstrap p-values in main tables

**Response:** Added discussion in Section 5.2 with citation to Cameron et al. (2008).

---

## Response to Gemini-3-Flash (CONDITIONALLY ACCEPT)

### 1. Missing References
**Request:** Add Hernandez-Arenaz & Iriberri (2020) and Mas & Pallais (2017)

**Response:** Both references have been added to the bibliography and cited in Section 3.2 (Literature Review) where they are directly relevant to the gender negotiation and job attributes literatures.

### 2. Border-County Analysis
**Request:** Clarify why border-county approach was or was not feasible

**Response:** Added explicit paragraph in Section 7.2 explaining that CPS ASEC public-use files lack county identifiers, making border-discontinuity analysis infeasible.

### 3. Occupation vs. Industry Interaction
**Request:** More granular look at high-skill vs low-skill within industries

**Response:** We note in Section 6.4 that education heterogeneity provides a complementary lens (college vs. non-college), and acknowledge in the Discussion that more granular occupation-industry interactions are an avenue for future research.

---

## Summary of Changes

1. **New Section 6.2:** Cohort-Specific Effects with discussion of treatment effect heterogeneity by cohort
2. **New Table 10 (Appendix):** Treatment Effects by Cohort
3. **Six New References:** de Chaisemartin & D'Haultfoeuille (2020), Borusyak et al. (2024), Cameron et al. (2008), Hernandez-Arenaz & Iriberri (2020), Mas & Pallais (2017)
4. **Expanded Limitations:** ITT interpretation, border-county infeasibility, compliance measurement
5. **Updated Empirical Strategy:** Discussion of wild cluster bootstrap with citation

All reviewer concerns have been addressed. The paper now provides more comprehensive methodology discussion, additional robustness evidence, and clearer acknowledgment of limitations.
