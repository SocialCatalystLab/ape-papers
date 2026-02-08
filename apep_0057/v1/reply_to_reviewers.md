# Reply to Reviewers

Thank you for the thorough and constructive reviews. All three reviewers identified the same fundamental issues, which validates the concerns and clarifies the path forward.

## Response to All Reviewers

### 1. On the "Shift-Share" Framing

**Reviewers' Critique:** Regressing y_i on Σ w_ij × y_j is NOT shift-share. It's a spatial autoregressive model with reflection/simultaneity issues. The "shifts" must be exogenous shocks, not contemporaneous outcomes.

**Response:** The reviewers are correct. We misapplied the shift-share framework. In a proper Bartik design, the "shifts" are external (e.g., national industry growth rates), and the "shares" capture differential exposure. Our construction uses other counties' realized outcomes as "shifts," which are endogenous by construction.

**Planned Fix:** We will either (a) find exogenous shocks (plant closures, natural disasters) and compute SCI-weighted exposure to those shocks, or (b) reframe the paper entirely as spatial correlation measurement without causal language.

### 2. On Inference

**Reviewers' Critique:** OLS with state-clustered SEs is inadequate. Need Conley (1999) spatial HAC SEs.

**Response:** Agreed. We will implement Conley SEs and show sensitivity to distance cutoffs.

### 3. On ACS Timing

**Reviewers' Critique:** ACS 5-year windows overlap (2015-2019 vs 2017-2021), making "COVID shock" interpretation invalid.

**Response:** Agreed. We acknowledged this in the revision but underestimated its severity. We will switch to BLS LAUS monthly data for precise shock windows.

### 4. On Leave-Out-State Results

**Reviewers' Critique:** The sign flip with out-of-state exposure is devastating—it suggests the correlation is geographic, not social.

**Response:** We agree this is the most important finding in the paper. Rather than treating it as a limitation, we should make it central: the correlation between network exposure and outcomes is driven by within-state geographic structure, not by social network transmission. This null finding is itself informative.

### 5. On Missing Literature

**Response:** We will add all suggested citations, particularly:
- Spatial econometrics (Anselin 1988, Conley 1999)
- Reflection problem (Manski 1993)
- Shift-share inference (Adao et al. 2019, Borusyak et al. 2022)
- Networks and labor (Topa 2001, Bayer-Ross-Topa 2008)

### 6. On Writing Quality

**Response:** We will expand the main text to 25+ pages, convert bullet lists to paragraphs, and develop the identification discussion more rigorously.

## Conclusion

The reviewers have identified that this paper attempted a causal network transmission story but the evidence points against that interpretation. The honest finding—that labor market co-movement correlates with SCI but this reflects geography rather than social transmission—is still a contribution, but requires a fundamentally different framing.

We are grateful for the detailed feedback and will pursue a major revision.
