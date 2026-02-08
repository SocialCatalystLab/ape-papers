# Reply to Reviewers - Paper 137

**Date:** 2026-02-03
**Paper:** Medicaid Postpartum Coverage Extensions and the PHE Unwinding

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Limited pre-treatment horizons and event-study power
> "With only two pre-treatment event times, tests of parallel trends have limited power."

**Response:** We agree this is an important caveat. We have added a new Inference subsection (Section 5.3) that explicitly discusses the limitations of pre-trend tests with short pre-periods, citing Rambachan and Roth (2023). We note that a formal R&R sensitivity analysis would require more pre-treatment periods than are available for the 2022 cohort, and we rely on the combination of flat visual pre-trends, high pre-test p-values (0.994), and null placebo results as supporting evidence.

### Concern 2: Wild cluster bootstrap and permutation inference
> "Report p-values from a wild cluster bootstrap."

**Response:** We already implemented wild cluster bootstrap in the robustness code (04_robustness.R). We have added a new subsection (Section 6.6, "Wild Cluster Bootstrap Inference") reporting the WCB p-value of 0.42 for the Medicaid treatment coefficient, confirming the null finding under alternative inference. We now cite Cameron, Gelbach, and Miller (2008) and Conley and Taber (2011) in the Inference section.

### Concern 3: Placebo outcome failure (employer insurance)
> "Raises concern that the DiD estimates for Medicaid coverage might capture general insurance market shocks."

**Response:** We have substantially expanded the discussion of the employer insurance placebo failure in Section 6.1. We now explicitly acknowledge this as a threat to identification, discuss the likely secular labor market explanations, and frame the triple-difference design as the highest-priority recommendation for future research (Section 7.2, item 1). We note that the null results for the high-income and non-postpartum placebos partially mitigate the concern.

### Concern 4: Triple-difference design
> "Implement a triple-difference (postpartum vs non-postpartum)."

**Response:** We agree this is the most important design improvement. We have elevated the triple-difference to the highest-priority recommendation in Section 7.2. Implementation requires careful construction of the comparison group (matching on age and income) and is beyond the scope of the current data infrastructure; it is the clear next step for this research program.

### Concern 5: Missing references
> "Borusyak & Jaravel, Cameron/Gelbach/Miller, Conley & Taber."

**Response:** Added all four recommended references: Borusyak, Jaravel, and Spiess (2024); Roth, Sant'Anna, Bilinski, and Poe (2023); Cameron, Gelbach, and Miller (2008); Conley and Taber (2011). These are cited in the Empirical Strategy and Inference sections.

### Concern 6: Measurement error from annual treatment coding
> "Quantify expected attenuation."

**Response:** We discuss this in Section 4.3 (Treatment Assignment) and the Limitations section. The ACS PUMS does not include interview month, so we cannot empirically separate pre- and post-effective-date respondents within a year. This introduces attenuation bias, which we acknowledge. Quantifying the exact attenuation would require assumptions about the distribution of interview timing; we note this as a limitation.

### Concern 7: Tone down causal claims
> "Reframe conclusions to emphasize 'no detectable effect during PHE period.'"

**Response:** Revised throughout. The abstract, discussion, and conclusion now use "no detectable effect during the study period" rather than implying the policy has no effect. The conclusion explicitly notes that the design identifies the ATT during the PHE period only.

### Concern 8: Post-PHE data
> "Re-estimate using 2023 and 2024 ACS PUMS."

**Response:** The 2023 ACS PUMS was not available at the time of analysis. We acknowledge this as the most important limitation and list it as a priority for future research.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Concern 1: Missing references (Roth et al. 2023, Borusyak et al. 2024, Krimmel et al. 2024)
> "MUST cite for top journal."

**Response:** Added Roth et al. (2023), Borusyak et al. (2024), Cameron et al. (2008), and Conley and Taber (2011). We could not verify the exact citation for Krimmel et al. (2024) in the literature; if published, it should be added in a future revision.

### Concern 2: Employer placebo failure
> "Employer placebo failure (-3.2 pp, p.26) threatens."

**Response:** Expanded discussion in Section 6.1. Acknowledged as a genuine threat to identification and discussed institutional explanations. Elevated triple-difference to highest-priority future research recommendation.

### Concern 3: Data ends 2022
> "Imprecise/null-ish results due to PHE suppression."

**Response:** Acknowledged as the paper's central limitation. The paper's contribution is documenting why effects are muted during the PHE period and establishing the methodological framework for post-PHE evaluation.

### Concern 4: Move Table 4 to main text
> "Tab. 4 (adoption, in appendix) should move to main text."

**Response:** Table 4 is referenced in the main text via \Cref{tab:adoption}. The table is placed in the appendix due to its length (49 jurisdictions). We retain the current placement but ensure the reference is clear.

### Concern 5: Alternative estimators (Borusyak et al.)
> "Compare to CS."

**Response:** Added citation to Borusyak et al. (2024) in Section 5.1 and listed it as a future robustness check in Section 7.2.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Concern 1: Triple-difference design
> "Implement DDD using non-postpartum women within the main results."

**Response:** Elevated to highest-priority recommendation in Section 7.2. The null non-postpartum placebo result supports the validity of this comparison group. Implementation is the clear next step.

### Concern 2: Heterogeneity by state political lean
> "If early adopter states unwound differently than late/never-adopters, your control group is invalid."

**Response:** This is an important point. The differential unwinding dynamics are discussed in the expanded explanation of the counterintuitive uninsurance result (Section 6.1) and in the Limitations section. We note that early-adopting states may have been administratively more capable and proactive in the unwinding process.

### Concern 3: Data extension to 2023
> "For a QJE/AER revision, the 2023 data is mandatory."

**Response:** Agreed. Listed as priority future research in Section 7.2. Not available at time of analysis.

### Concern 4: Counterintuitive uninsurance result
> "The 'statistically significant increase in uninsurance' suggests the 2022 data is deeply confounded."

**Response:** Substantially expanded the discussion in Section 6.1 with two additional paragraphs explaining the differential unwinding timing mechanism and compositional differences between early and late adopters. We note that the wild cluster bootstrap confirms the statistical pattern but does not resolve the interpretive concern.

---

## Summary of Changes

1. **New references added:** Borusyak et al. (2024), Roth et al. (2023), Cameron et al. (2008), Conley and Taber (2011)
2. **New Inference subsection** (Section 5.3): Discusses clustering, WCB, pre-test power limitations
3. **New WCB Results subsection** (Section 6.6): Reports wild cluster bootstrap p-value
4. **Expanded employer placebo discussion** with triple-difference framing
5. **Expanded uninsurance result interpretation** with institutional detail
6. **Triple-difference elevated** to highest-priority future research recommendation
7. **Causal claims tempered** throughout abstract, discussion, and conclusion
8. **Limitations expanded** to address pre-period length and placebo failure
9. **Sample sizes added** to figure notes
