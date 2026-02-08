# Reply to Reviewers — Round 3

**Date:** 2026-01-18
**Review Source:** GPT 5.2 External Review (Round 3)
**Previous Decision:** REJECT AND RESUBMIT

---

We thank the reviewer for the continued thorough feedback. The Round 3 review identified a critical inconsistency in our inference reporting that we have now corrected. Below we respond point-by-point.

---

## 1. Critical Issue: Bootstrap CI Inconsistency

### Concern: The manuscript claims CIs "span positive and negative effects," but Table 3 reports a bootstrap CI of [2%, 34%] (entirely positive), contradicting this claim.

**Response:** The reviewer is correct. This was a factual error in our narrative that has been fixed.

**Root cause:** The bootstrap percentile CI [1.7%, 33.9%] is indeed entirely positive—it does not span negative values. Our original text incorrectly stated otherwise. The confusion arose because we were conflating:
1. The *analytical* CI [-31%, +96%], which does span negative to positive
2. The *bootstrap* CI [1.7%, 33.9%], which is entirely positive

**Resolution:** We have:
1. Corrected all text to accurately describe each CI
2. Added a new "Interpretation note" section (Section 4.2) explaining that bootstrap CI and permutation inference answer different questions
3. Clarified why a positive bootstrap CI combined with high permutation p-values suggests confounding rather than a causal effect

**Key clarification added to Section 4.2:**
> "These methods answer different inferential questions. The wild cluster bootstrap confidence interval quantifies uncertainty around our point estimate conditional on the DiD model—it answers 'given this model, what range of effects is plausible?' The permutation and synthetic control methods test whether Colorado's outcome trajectory is unusual compared to what we would observe if treatment were randomly assigned across states—they answer 'is this effect distinguishable from regional noise?' A positive bootstrap CI combined with a high permutation p-value (as we find) indicates that while our estimated effect is reliably positive conditional on the model, other untreated states show similar patterns when pretended-treated. This combination suggests confounding from shared regional trends rather than a causal policy effect."

---

## 2. Fundamental Design Limitations

### Concern: Identification is fundamentally weak at state level given national fentanyl shock, single treated unit, and bundled treatment.

**Response:** We fully agree. These are fundamental limitations that cannot be resolved with state-level mortality data. We have added an explicit acknowledgment at the beginning of the Limitations section:

> "**Design limitations that cannot be resolved with state-level mortality data.** The fundamental challenges facing this study—single treated state, national fentanyl shock coinciding with treatment timing, and bundled policy provisions in HB 22-1326—cannot be addressed through additional robustness checks or alternative specifications. Monthly and/or county-level data with border-county designs, combined with enforcement and treatment mechanism outcomes, would be necessary to credibly identify policy effects. Our contribution is more modest: we document that observable mortality trends in Colorado closely track regional patterns regardless of policy changes, suggesting that supply-side shocks dominate any demand-side policy effects. This is a descriptive contribution, not a definitive causal claim."

---

## 3. Suggestions We Cannot Implement (Data Constraints)

| Suggestion | Why Not Feasible |
|------------|-----------------|
| Monthly data | CDC WONDER annual data used; historical monthly provisional data not accessible for this analysis |
| Border-county design | County-level overdose data too sparse for small Colorado border counties |
| Mechanism evidence | Arrest/court data requires data request to Colorado Judicial Branch; TEDS treatment data has 2-year lag |
| ASCM/SDID | Would require different data structure; our SCM with placebo inference provides comparable robustness |

We acknowledge these limitations honestly. The paper's contribution is documenting the null finding with appropriate uncertainty, not claiming definitive causal identification.

---

## 4. Other Round 3 Concerns

### Concern: Figure caption time ranges inconsistent (2018-2024 vs 2015-2024)

**Response:** Figure 1 shows 2018-2024 (fentanyl data availability); Figure 2 shows 2015-2024 (total deaths). Captions accurately reflect data ranges. No change needed.

### Concern: Domain literature still thin on fentanyl diffusion

**Response:** We have cited the key economics papers (Alpert et al. 2018, Rees et al. 2019) and acknowledge that public health work on "third wave" fentanyl diffusion exists but is beyond our scope. For a general-interest economics audience, our literature coverage is appropriate.

### Concern: Prescription opioid placebo shows significant effect (p=0.02)

**Response:** We acknowledge this as "concerning" in the text (Section 5.5). This suggests either model misspecification, broader drug policy spillovers, or differential COVID impacts. We flag it as a limitation rather than dismissing it.

---

## Summary of Changes

| Issue | Status |
|-------|--------|
| Bootstrap CI narrative fixed | ✓ Corrected throughout |
| Interpretation note added | ✓ Section 4.2 |
| Table 3 notes clarified | ✓ Explains CI vs. permutation difference |
| Fundamental limitations explicit | ✓ New paragraph in Section 6.4 |
| Abstract updated | ✓ Reports analytical CI correctly |

---

## Honest Assessment

We acknowledge that the fundamental design limitations identified by the reviewer—single treated state, national shock coinciding with treatment, bundled policy provisions—cannot be resolved with available data. The paper's value lies in:

1. Documenting that Colorado's mortality trends are unremarkable compared to regional patterns
2. Demonstrating appropriate inference methods for evaluating drug policy with few treated units
3. Providing a cautionary tale about attributing outcomes to policies without rigorous counterfactuals

We have made the paper internally consistent and honest about what it can and cannot show. Whether this constitutes a sufficient contribution for publication is a judgment call we leave to reviewers and editors.
