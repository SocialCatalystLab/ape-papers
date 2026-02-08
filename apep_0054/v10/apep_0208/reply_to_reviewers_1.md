# Reply to Reviewers (Round 1)

We thank the three reviewers for their careful reading and constructive suggestions. Below we address each concern.

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### R1.1: Inference Transparency (Fisher p=0.154)
**Concern:** The divergence between asymptotic (p<0.001) and permutation (p=0.154) p-values for the CPS gender DDD should be highlighted more prominently.

**Response:** We agree this deserves attention and have strengthened the discussion. The paper already reports both p-values prominently in Table 11 and discusses them at length in Section 7.2. We have added a sentence in the abstract acknowledging this limitation and strengthened the QWI corroboration language in the results section. The QWI provides an independent test with 51 clusters where asymptotic inference is reliable (p<0.001).

### R1.2: Mechanism Evidence (Composition vs. Within-Firm)
**Concern:** QWI cannot distinguish within-firm pay changes from compositional shifts.

**Response:** We acknowledge this limitation explicitly in Section 8.3. The consistency between CPS individual-level estimates (which control for demographics, occupation, and industry) and QWI aggregate estimates provides indirect evidence against pure composition effects. Linked employer-employee data with job-posting information would strengthen mechanism identification and is noted as a priority for future research.

### R1.3: Threshold Heterogeneity
**Concern:** Policy variation in employer thresholds (all vs. 4+ vs. 15+ vs. 50+) is unexploited.

**Response:** We agree this is a promising avenue and discuss it in Section 8.3 (Limitations). However, exploiting this variation requires employer-level data (to identify firms near the threshold), which is beyond the scope of this revision. We flag it as the natural next step.

### R1.4: Survey Weights
**Concern:** Clarify whether CPS uses survey weights and QWI uses employment weights.

**Response:** We have added explicit statements in Section 5.2 about ASECWT usage and in Section 5.3 about QWI's construction-level weighting.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### R2.1: Missing Citations
**Concern:** Add Cowgill (2021) and Blundell et al. (2022/2024).

**Response:** Both are already cited in the paper (Cowgill 2021 as NBER WP, Blundell et al. 2022 as IFS WP). No change needed.

### R2.2: Permutation p-value
**Concern:** Same as R1.1.

**Response:** Addressed as described above.

### R2.3: Extensions
**Concern:** Threshold RD, spillover tests, job-posting data linkage.

**Response:** We discuss these as future research directions in Section 8.3. They are beyond the scope of the current paper.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### R3.1: Employment Selection (Extensive Margin)
**Concern:** Gender gap narrowing could reflect who stays employed rather than within-worker wage changes.

**Response:** We have expanded the Limitations section to explicitly discuss this possibility. The CPS composition tests (Section 7.4) show no significant changes in percent female, which provides indirect evidence against extensive-margin selection. Lee bounds (lower: 0.042, upper: 0.050) formally address sample selection under monotonicity.

### R3.2: Remote Work Spillovers
**Concern:** Colorado's remote provisions may create geographic spillovers.

**Response:** We have added a brief discussion of this in the Limitations section, noting that Colorado's initial application to remote-eligible positions may attenuate treatment-control differences.

### R3.3: Bargaining Mechanism
**Concern:** Strengthen bargaining analysis with O*NET negotiation indices.

**Response:** The CPS analysis already includes a high-bargaining occupation indicator (management, business/financial, legal, etc.). The QWI industry-level splits provide a complementary test. O*NET linkage would enrich the analysis but is beyond the scope of this revision.
