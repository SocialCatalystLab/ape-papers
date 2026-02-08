# Reply to Reviewers - Round 1

**Paper:** The Marginal Value of Public Funds for Unconditional Cash Transfers in a Developing Country: Evidence from Kenya
**Date:** 2026-02-04

---

## Response to Reviewer 1 (GPT-5-mini)

Thank you for your thorough and constructive review. We address your main concerns below.

### Statistical Methodology

**Concern:** Bootstrap procedure insufficiently documented; CIs appear too tight.

**Response:** The tight CI for direct MVPF [0.86, 0.88] reflects that the direct WTP component ($850) is deterministic—it equals the transfer amount ($1,000) minus admin costs (15%). The only uncertainty comes from fiscal externalities (~$23), which have relatively small SEs. We will add a footnote clarifying this in the next revision.

The bootstrap resamples from normal approximations to published SEs for:
- Consumption effects (for VAT externality)
- Earnings effects (for income tax externality)
- Spillover effects (for spillover WTP)

We acknowledge that this does not capture parameter uncertainty (informality, VAT coverage, MCPF), which is why we present extensive sensitivity analysis varying each parameter.

### Literature

**Concern:** Missing methodological citations.

**Response:** We will add citations to Goodman-Bacon (2021), Callaway & Sant'Anna (2021), and Kleven (2014) in a future revision. While these DiD methods are not directly used (our identification is from RCTs), they provide useful context for understanding heterogeneous treatment effects.

### External Validity

**Concern:** Need quantitative scenarios for government implementation.

**Response:** Table 9 (MCPF sensitivity) addresses this: MVPF falls to 0.67 under MCPF=1.3 and 0.58 under MCPF=1.5. We will add scenarios for higher admin costs (25-40%) in a future revision.

---

## Response to Reviewer 2 (Grok-4.1-Fast)

Thank you for your detailed review and helpful literature suggestions.

### New Empirical Analysis

**Concern:** Paper is a calibration exercise using published summaries, not new regressions.

**Response:** This is accurate. The MVPF methodology, as developed by Hendren & Sprung-Keyser (2020), is specifically designed to compute welfare metrics from published treatment effects. Their entire Policy Impacts library (208 US programs) uses this approach. The value-add is applying the framework to a new context (developing countries) with careful attention to fiscal parameters unique to Kenya (informality, VAT structure).

We acknowledge this limitation explicitly in Section 7.3 and note that microdata analysis could improve inference.

### Prose Quality

**Concern:** Bullet lists in major sections should be prose.

**Response:** We will convert the key findings bullets in Sections 2.2-2.3 to flowing paragraphs in a future revision.

### Literature

**Concern:** Missing citations to Blattman et al. (2022), Pomeranz (2015).

**Response:** These are excellent suggestions. Blattman et al. provides a direct Uganda comparison, and Pomeranz addresses VAT enforcement in developing countries. We will add these.

---

## Response to Reviewer 3 (Gemini-3-Flash)

Thank you for your constructive suggestions.

### Calibration vs Estimation

**Concern:** Reliance on published coefficients rather than microdata is a limitation.

**Response:** Agreed. We discuss this in Section 7.3. The replication data are publicly available on Harvard Dataverse, and future work could re-estimate treatment effects with additional heterogeneity analysis.

### Literature

**Concern:** Need engagement with broader welfare economics literature.

**Response:** We will add citations to Atkinson & Stiglitz (1976) on optimal taxation and Kleven (2014) on informality.

### WTP > 1 for Credit-Constrained Households

**Concern:** In developing countries with binding credit constraints, WTP could exceed $1 per dollar transferred.

**Response:** This is an excellent point. If recipients would borrow at high interest rates to achieve the same consumption smoothing, their WTP for a lump-sum transfer exceeds face value. We will add a discussion of this in Section 3.2, noting that our assumption of WTP=1 is conservative.

---

## Summary of Changes Made

For this publication version:
1. Fixed all internal consistency issues identified in advisor review
2. Corrected spillover calculation from PPP to USD
3. Added missing CI for "With spillovers, MCPF=1.3" specification
4. Updated all figures and tables with corrected values

---

## Changes Deferred to Future Revision

1. Additional literature citations (Goodman-Bacon, Callaway & Sant'Anna, Kleven, Pomeranz, Blattman)
2. Variance decomposition table
3. Component-level SEs
4. Government implementation scenarios with higher admin costs
5. Prose conversion for bullet-point sections
6. Discussion of WTP>1 under credit constraints

These enhancements will be addressed in a subsequent revision of this paper.
