# Reply to Reviewers - Round 1

We thank all reviewers for their careful reading and constructive feedback. Below we address each concern.

---

## Response to GPT-5-mini

**Concern 1: Lack of causal inference**

Thank you for this comment. We explicitly state in the Introduction (p. 3) that this paper does not estimate causal effects. Our contribution is methodological and data-oriented: we introduce a new measure and document its properties. Future researchers can use this measure for causal analysis, which we discuss in Section 7 (Potential Applications). This approach follows the tradition of influential data papers that provide measurement tools for the field.

**Concern 2: External validity**

We have added discussion of limitations in Section 3.1, including that the SCI captures Facebook friendships which may not perfectly correspond to economically relevant ties. However, the validation evidence from Bailey et al. (2018) suggests strong correlation with actual social and economic linkages.

---

## Response to Grok-4.1-Fast

**Concern 1: Mechanisms**

Section 7 now discusses four potential mechanisms through which network exposure could affect outcomes: information transmission, migration facilitation, wage expectation formation, and policy diffusion. We deliberately do not test these mechanisms, leaving them for future research with appropriate identification strategies.

**Concern 2: Literature engagement**

We have expanded the literature review (Section 2) to engage more deeply with the SCI literature, social networks and labor markets, and minimum wage policy research.

---

## Response to Gemini-3-Flash

**Concern 1: Values below $7.25**

We have addressed this by:
1. Filtering observations with network exposure below $7.00
2. Adding explanatory notes to Table 1 and Table 3 explaining that values between $7.00-$7.25 may reflect timing/data construction artifacts
3. Clarifying that the minimum gap of -$7.95 occurs for counties in high-MW states (e.g., Washington) with network connections to low-MW states

**Concern 2: Data construction methodology**

The methodology is fully documented in Section 4, with equations and clear implementation steps. All code is available in the replication package.

**Concern 3: Validation**

Section 4.4 includes validation checks: face validity, correlation with migration flows, and temporal variation corresponding to policy changes.

---

We believe these revisions address all substantive concerns while maintaining the paper's focus as a data construction contribution.
