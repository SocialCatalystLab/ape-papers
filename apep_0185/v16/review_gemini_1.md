# Gemini-3-Flash Review

**Role:** External referee review
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-09T15:18:34.986344
**Route:** Direct Google API + PDF
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 29515 in / 1189 out
**Response SHA256:** 169331410a9ad8b6

---

This review evaluates "Friends in High Places: Social Network Connections and Local Labor Market Outcomes." The paper investigates whether social network exposure to high-minimum-wage areas affects local county-level earnings and employment, using Facebook's Social Connectedness Index (SCI) and a shift-share IV strategy.

---

### 1. FORMAT CHECK
- **Length**: 54 pages (including references and appendix). This meets the substantive requirements for a top-tier submission.
- **References**: Extensive (34–37). Covers key SCI literature (Bailey et al.), shift-share methodology (Borusyak et al.; Goldsmith-Pinkham et al.), and minimum wage literature.
- **Prose**: Major sections are written in professional paragraph form.
- **Figures/Tables**: Figures are high-quality, though Figure 4 (binned scatter) and Figure 5 (tradeoff) are particularly effective at conveying identification strength. Tables are complete with real data.

---

### 2. STATISTICAL METHODOLOGY
- **Inference**: Coefficients include standard errors in parentheses. Significance is denoted by asterisks and p-values are reported in text.
- **Standard Errors**: Clustered at the state level (51 clusters), which is appropriate given that the "shocks" (minimum wage changes) occur at the state level.
- **Shift-Share DiD**: The paper avoids simple staggered TWFE pitfalls by using a shift-share IV design. It reports shock-robust inference (Table 4) and addresses exposure to specific high-MW states (Leave-one-state-out, Table 11).
- **Weak Instruments**: The paper reports Anderson-Rubin confidence sets, which are robust to weak instruments—a critical inclusion given that some distance-restricted specifications have lower F-stats (Table 1).

---

### 3. IDENTIFICATION STRATEGY
The identification relies on the "shocks" (state MW changes) being exogenous to local county conditions, conditional on state-by-time fixed effects.
- **Credibility**: The use of out-of-state connections as an instrument is clever. It purges the endogenous own-state component.
- **Distance Restriction**: The "Distance-Credibility Tradeoff" (Figure 5/Table 7) is a highlight. Showing that results *strengthen* as nearby (potentially endogenous) connections are removed is a powerful defense against local spatial correlation.
- **Placebo Tests**: The use of GDP and Employment as placebo shocks (Table 12) effectively rules out the idea that the SCI is just picking up general economic "vibrancy" rather than wage information.

---

### 4. LITERATURE
The paper is well-positioned. However, to satisfy the highest level of rigor in shift-share designs, the authors should explicitly cite:
- **Adao, Kolesár, and Morales (2019)** regarding the specific clustering requirements for shift-share (the paper mentions them but could more explicitly discuss the "shift-share SE" vs. state-clustering).
- **BibTeX Suggestion**:
  ```bibtex
  @article{adao2019shift,
    author = {Adao, Rodrigo and Koles{\'a}r, Michal and Morales, Eduardo},
    title = {Shift-Share Designs: Theory and Inference},
    journal = {The Quarterly Journal of Economics},
    year = {2019},
    volume = {134},
    number = {4},
    pages = {1949--2010}
  }
  ```

---

### 5. WRITING QUALITY
- **Narrative Flow**: The introduction is excellent. The Amarillo vs. El Paso example provides immediate intuition for why "scale" (population weighting) matters.
- **Clarity**: The "Population-vs-Probability" divergence is the paper's strongest intellectual contribution and is explained with great clarity. 
- **Accessibility**: The USD-denominated specifications (Table 2) make the magnitudes ($1 increase = 9% employment) easy to grasp, even for non-specialists.

---

### 6. CONSTRUCTIVE SUGGESTIONS
1.  **The 9% Employment Magnitude**: This is a very large effect. While the authors compare it to Moretti's multipliers, a 9% increase in county employment from a $1 change in *network* wages implies a massive labor supply response or search efficiency gain. I suggest a more detailed "back-of-the-envelope" calculation: how many workers would actually have to move or enter the labor force to reach 9%, and is that feasible given the QWI job flow data?
2.  **Reservation Wages**: The model in Appendix A hinges on reservation wages. If the authors can find a proxy for local reservation wages (perhaps from a survey like the SCE or local job posting data showing higher starting offers), it would move the mechanism from "plausible" to "proven."
3.  **Heterogeneity by Education**: Minimum wage information should matter most for low-skilled workers. If the authors can slice the QWI data by education or age (proxies for low-wage earners), they should show that the 9% effect is concentrated there.

---

### 7. OVERALL ASSESSMENT
This is a high-quality empirical paper that introduces a meaningful methodological refinement to the SCI literature (population weighting). The identification is exceptionally robust, particularly the distance-restriction analysis. The divergence between share and scale provides a rare "built-in" test of the information channel.

**DECISION: MINOR REVISION**