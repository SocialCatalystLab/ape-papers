# Internal Review - Round 1

**Reviewer:** Claude Code Internal Review
**Paper:** Do Supervised Drug Injection Sites Save Lives?
**Date:** 2026-02-02

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length**: 35 pages total, approximately 28 pages main text (excluding references/appendix). PASS.
- **References**: Bibliography covers key methodological (Abadie et al., Ben-Michael et al.) and substantive (Marshall et al., Davidson et al.) literature. PASS.
- **Prose**: All major sections written in full paragraphs. PASS.
- **Section depth**: Each section has 3+ substantive paragraphs. PASS.
- **Figures**: Figures show visible data with proper axes and labels. PASS.
- **Tables**: Tables have real numbers with appropriate inference statistics. PASS.

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors**: Coefficients have clustered SEs in parentheses. PASS.
b) **Significance Testing**: P-values and significance stars reported. PASS.
c) **Confidence Intervals**: Wild bootstrap 95% CIs provided. PASS.
d) **Sample Sizes**: N = 260 observations, 26 clusters reported. PASS.
e) **DiD with Staggered Adoption**: Uses event study with never-treated controls as reference. The design excludes adjacent neighborhoods from the donor pool. PASS.
f) **Synthetic Control**: Uses augmented synthetic control with randomization inference. PASS.

### 3. IDENTIFICATION STRATEGY

The paper exploits the November 2021 opening of two OPCs as a sharp temporal discontinuity. The synthetic control method with randomization inference is appropriate for the two treated units. Pre-treatment coefficient tests show no significant pre-trends.

**Strengths:**
- Clear treatment timing (November 30, 2021)
- Appropriate method choice for N=2 treated units
- Randomization inference for valid p-values
- Placebo-in-time and placebo-in-space tests

**Concerns:**
- Limited external validity (NYC only)
- 2024 data is provisional
- Cannot separate treatment effect from other concurrent changes

### 4. LITERATURE

The literature review is adequate but could be strengthened with:
- More discussion of European SIF literature (e.g., Spain, Germany)
- Engagement with the drug policy economics literature beyond harm reduction

### 5. WRITING QUALITY

The paper is well-written with clear prose and logical flow. The introduction effectively motivates the study. Technical methods are explained accessibly.

### 6. OVERALL ASSESSMENT

**Key Strengths:**
- Novel U.S. evidence on supervised injection sites
- Appropriate methodology for few treated units
- Clear policy implications with cost-effectiveness analysis
- Well-written and accessible

**Critical Weaknesses:**
- Small number of treated units limits generalizability
- 2024 provisional data adds uncertainty
- Cannot definitively rule out concurrent confounders

**Specific Suggestions:**
1. Add sensitivity analysis excluding 2024 provisional data
2. Discuss mechanisms more explicitly
3. Consider adding neighborhood-level controls

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

The paper has promising results and could be strengthened by:

1. **Additional Analyses:**
   - Dose-response analysis using OPC visit counts
   - Heterogeneity by demographic composition
   - Analysis of non-fatal overdose outcomes

2. **Alternative Specifications:**
   - Difference-in-differences-in-differences with demographic controls
   - Spatial regression discontinuity at neighborhood boundaries

3. **Extensions:**
   - Impact on treatment uptake and referrals
   - Effects on EMS response times
   - Spillover effects on adjacent neighborhoods

---

## DECISION

The paper makes a novel contribution to U.S. drug policy evaluation with appropriate methodology for the setting. While limitations exist (small N, provisional data), the core findings are credible and policy-relevant.

**DECISION: MINOR REVISION**
