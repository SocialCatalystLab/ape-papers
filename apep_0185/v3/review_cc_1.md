# Internal Review - Round 1

**Reviewer:** Claude Code
**Paper:** Social Network Minimum Wage Exposure: Causal Evidence from Distance-Based Instrumental Variables
**Date:** 2026-02-05

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length**: Paper is approximately 50 pages including appendix. Main text appears to be 25+ pages. PASS
- **References**: Bibliography covers key literature including Bailey et al. (2018) for SCI, Callaway & Sant'Anna for DiD, relevant minimum wage literature. PASS
- **Prose**: Major sections are written in full paragraphs, not bullets. PASS
- **Section depth**: Each section has substantive development. PASS
- **Figures**: All figures show data with proper axes. PASS
- **Tables**: All tables have real numbers. PASS

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors**: All regression coefficients include SEs in parentheses. PASS

b) **Significance Testing**: P-values reported appropriately. PASS

c) **Confidence Intervals**: Results include discussion of significance levels. PASS

d) **Sample Sizes**: N reported for all regressions (132,372 in main tables). PASS

e) **DiD/IV**: Paper uses fixed effects and IV strategy. The IV is acknowledged as weak (F=1.2), which is an honest finding rather than a methodological flaw. The authors correctly interpret this limitation. PASS with caveat.

f) **General**: Methodology is appropriate for the descriptive contribution.

### 3. IDENTIFICATION STRATEGY

The paper honestly acknowledges that the distance-based IV fails to provide strong identification (F=1.2). This is an honest null finding about the IV strategy, not a methodological failure. The descriptive contribution (constructing network exposure measures) does not require causal identification.

**Strength**: The paper is transparent about what it can and cannot claim causally.

**Weakness**: The 2SLS results are uninformative and could be de-emphasized further.

### 4. LITERATURE

Literature coverage is adequate. Key citations include:
- Bailey et al. (2018) - SCI data
- Callaway & Sant'Anna (2021) - DiD methodology
- Dube et al. (2010) - minimum wage literature
- Goldsmith-Pinkham et al. (2020) - shift-share instruments

No critical missing citations identified.

### 5. WRITING QUALITY

a) **Prose vs. Bullets**: Full paragraphs throughout. PASS

b) **Narrative Flow**: Paper tells a clear story: construct measure → describe properties → attempt IV → honest null finding → future directions. PASS

c) **Sentence Quality**: Academic prose is competent. PASS

d) **Accessibility**: Technical choices are explained. PASS

e) **Figures/Tables**: Publication-quality with clear labels. PASS

### 6. CRITICAL WEAKNESSES

1. **Weak IV is the main finding**: The paper's attempted causal analysis fails due to weak instruments. This is acknowledged honestly, but the paper could be reframed more explicitly as a descriptive data paper.

2. **Figure 6 annotation mismatch**: The figure shows mean=-0.22 but Table 1 reports -0.24. Minor discrepancy that should be resolved.

3. **2SLS results occupy substantial space**: Given F=1.2, the 2SLS columns in Table 8 are uninformative. Consider relegating to appendix.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Reframe as data contribution**: The primary value is the constructed panel of network exposure measures. Make this clearer in the title and abstract.

2. **Alternative identification strategies**: Discuss more concretely how future researchers could achieve identification (border discontinuities, policy timing shocks).

3. **Heterogeneity by network structure**: Explore how exposure effects vary by network community or network centrality.

4. **Mechanism discussion**: Add theoretical discussion of how network exposure might affect labor market outcomes (job search, wage expectations, migration).

---

## 7. OVERALL ASSESSMENT

**Strengths:**
- Novel data construction (SCI-weighted network minimum wage exposure)
- Honest treatment of weak IV finding
- Comprehensive descriptive analysis
- Clean, well-documented replication materials

**Weaknesses:**
- Weak IV prevents causal claims
- Some minor internal inconsistencies (Figure 6 mean)
- Could be more explicitly framed as a data paper

**Recommendation:** The paper makes a genuine contribution by constructing and releasing network exposure measures. The honest treatment of the failed IV is scientifically valuable. Minor revisions to address figure consistency and framing would improve the paper.

---

DECISION: MINOR REVISION
