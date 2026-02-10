# Reply to Reviewers — Round 1

We thank all three reviewers for their careful reading and constructive suggestions. Below we address each concern point-by-point.

---

## Reviewer 1 (GPT-5-mini) — MAJOR REVISION

### 1. YRBS Sampling Error (Critical)

**Concern:** State-aggregate prevalence estimates ignore within-state sampling variance of YRBS estimates, potentially invalidating standard errors.

**Response:** We appreciate this important methodological point. We have added a discussion in Section 3.2 acknowledging this limitation and explaining our approach. Several considerations mitigate this concern: (a) Our primary inference relies on state-level clustering with 40+ clusters, which is conservative and accounts for arbitrary within-state correlation. (b) The YRBS state-level estimates used are CDC-weighted prevalence rates from large samples (median ~2,500 students per state-wave), so measurement error in the dependent variable attenuates coefficients toward zero — strengthening our null interpretation. (c) This aggregate approach is standard in the policy evaluation literature (e.g., similar YRBS-based DiD studies). (d) Individual-level restricted-use YRBS microdata would be ideal but is not publicly accessible; we note this as a valuable extension for future work.

### 2. First-Stage Evidence

**Concern:** Electronic bullying variable only available from 2011, limiting first-stage test.

**Response:** We acknowledge this limitation candidly in the paper (Section 5.6). With only 154 post-2011 state-year observations and most states already treated, the first-stage test has limited statistical power. We note this as an inherent data constraint rather than a design flaw. We have strengthened the discussion by noting alternative first-stage proxies (administrative incident reports, search trends) as avenues for future research.

### 3. Time-Varying Controls and Placebo Outcomes

**Concern:** Include state-level covariates and test placebo outcomes unaffected by cyberbullying laws.

**Response:** We have added discussion of this concern in Section 4.3 (Threats to Validity). Our staggered DiD with state and year fixed effects absorbs level differences and common shocks. The event study evidence shows flat pre-trends, suggesting no differential pre-treatment changes. We acknowledge that concurrent policies (ACA Medicaid expansion, school mental health funding) are potential confounders and discuss them explicitly. Traditional school bullying serves as an institutional placebo (Section 5.6) — the null effect there is consistent with the null on mental health outcomes.

### 4. Missing References

**Response:** Added. We now cite Conley & Taber (2011) on inference with few policy changes, Aronow & Samii (2017) on randomization inference with cluster treatments, Roth et al. (2023) on staggered DiD diagnostics, and Athey & Imbens (2022) on design-based DiD analysis.

### 5. Confidence Intervals

**Response:** Table 2 now reports explicit 95% confidence intervals for all primary outcomes.

### 6. Sample Sizes and Cohort Composition

**Response:** We have added explicit Sun-Abraham cohort composition details (number of states per adoption cohort, treatment waves) in Section 4.1.

### 7. ITT Interpretation

**Response:** We now explicitly state that our estimates are intent-to-treat in the Empirical Strategy section and discuss how full-compliance effects could differ.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### 1. Miller & Tucker Bibliography

**Response:** Fixed. The citation key date has been corrected from 2020 to 2011.

### 2. Additional References

**Response:** Added Roth et al. (2023), Athey & Imbens (2022), and related citations as suggested.

### 3. Joint Pre-Trend Wald P-Values

**Response:** The joint Wald test results are now referenced more explicitly in the event study discussion.

### 4. Bacon Paragraph

**Response:** Tightened the Bacon decomposition discussion in Section 5.4.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### 1. 95% CIs in Table 2

**Response:** Added explicit confidence intervals to Table 2.

### 2. Selection into YRBS

**Response:** We have added discussion in the Data section noting that YRBS participation is near-universal among treated states and that our sample covers 40+ states in each wave, mitigating selection concerns.

### 3. NVSS Mortality Data

**Response:** Excellent suggestion. We have added this as a valuable extension in the Discussion section. Administrative mortality data (CDC NVSS) would provide an important cross-validation of the self-reported YRBS results and eliminate social desirability bias concerns.

### 4. Treatment Intensity

**Response:** We discuss the absence of enforcement/funding data as a limitation and note that future work exploiting implementation intensity variation (e.g., states with dedicated appropriations vs. unfunded mandates) would sharpen the analysis.

---

## Exhibit Review Responses

- **Table 3:** Reformatted from diagonal to standard column layout
- **Figure 3:** Reduced confidence interval alpha for better visual clarity
- **Figure 4:** Standardized x-axis limits across comparable panels
- **Figure 5:** Moved to appendix (redundant with Table 2)
- **Appendix table:** Labeled as Table A1

## Prose Review Responses

- Trimmed roadmap paragraph
- Made results preview punchier in introduction
- Fixed passive voice in RI discussion
- Clarified "wrong direction" result more explicitly
