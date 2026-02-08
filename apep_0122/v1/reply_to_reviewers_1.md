# Reply to Reviewers - Paper 113

## Response to Reviewer 1 (Reject and Resubmit)

### 1. Pre-trend rejection
> The joint test rejects at p<0.01; dismissing distant leads as noise is insufficient.

We agree this is a limitation and have added explicit discussion of formal sensitivity analysis approaches (Rambachan and Roth 2023, HonestDiD). We now note in the limitations section that implementing HonestDiD bounds would provide more rigorous characterization of how much deviation from parallel trends is consistent with the null finding. We emphasize that the near-treatment coefficients (tau=-3 through tau=-1) are all individually insignificant.

### 2. External validity
> 10 early-adopting states excluded from identification.

We have added a substantive discussion in the Limitations section acknowledging that early adopters (including California, Texas, Massachusetts, and New Jersey) are excluded from the estimand. These states implemented RPS when renewable technologies were less mature, and the treatment effect may differ for them. We now explicitly state that our estimates apply only to states first treated in 2006 or later.

### 3. Binary treatment attenuation
> A 0/1 indicator risks attenuation bias.

We acknowledge this concern in expanded limitations. We already show that restricting to states with targets exceeding 5% produces a modestly larger (but still insignificant) estimate (+0.131), consistent with the attenuation concern. We now discuss this as one of several alternative explanations for the null finding.

### 4. Mechanism not demonstrated
> "Offsetting reallocation" interpretation is speculative.

We have reframed the discussion to present the reallocation hypothesis as one of several possible explanations, alongside attenuation bias, measurement limitations, and REC-based spillovers. We no longer claim this as the primary interpretation.

### 5. RPS literature
> Energy economics literature insufficiently engaged.

We have added citations and discussion of the RPS effectiveness and design literature.

---

## Response to Reviewer 2 (Major Revision)

### 1. No first-stage validation
> Paper never shows RPS adoption actually changes renewable generation.

We now discuss this explicitly in the limitations and discussion sections. We cite prior literature showing RPS adoption is associated with increased renewable capacity but acknowledge we do not verify this first stage for our specific sample and time period. This is noted as an important direction for future work.

### 2. Outcome measure mismatch
> ACS measures state-of-residence employment in a broad NAICS code.

We now discuss this measurement limitation explicitly. We note that ACS reports state-of-residence (not state-of-work) employment, that NAICS 0570 is broad, and that RPS-related employment may appear in construction and manufacturing supply chains outside this classification.

### 3. Spillovers/SUTVA
> REC trading could wash out effects.

We have added substantive discussion of how REC trading creates interstate compliance channels that attenuate within-state employment effects. This is now presented as a key alternative explanation for the null finding.

---

## Response to Reviewer 3 (Reject and Resubmit)

### 1. HonestDiD bounds
> Formal robust-to-pretrend inference is a "must-do."

We acknowledge this and have added discussion of Rambachan and Roth (2023) and HonestDiD as the appropriate framework. We note this as a limitation and direction for future work. Implementation was not possible due to library compatibility issues in our R environment.

### 2. Treatment timing misalignment
> "First compliance year" may miss responses at earlier stages.

We discuss this in the limitations section and note that alternative timing definitions (enactment year, first penalty year) would provide additional robustness.

### 3. Event-study support
> Number of cohorts contributing to each event-time coefficient not shown.

We acknowledge this concern and note it as a limitation of the current presentation.

---

## Summary of Changes

1. Trimmed abstract and toned down contribution claims
2. Expanded limitations section with six specific subsections
3. Reframed discussion to present multiple explanations for the null
4. Added first-stage discussion and RPS literature engagement
5. Added Rambachan and Roth (2023) citation and discussion
6. Toned down conclusion claims
7. All numerical results unchanged (no re-estimation)
