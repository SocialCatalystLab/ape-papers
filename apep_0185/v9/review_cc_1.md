# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** "Friends in High Places: How Social Networks Transmit Minimum Wage Shocks"
**Date:** 2026-02-06

---

## PART 1: CRITICAL REVIEW

### Format Check
- **Length:** ~50 pages including appendix, well above 25-page threshold. PASS.
- **References:** Comprehensive bibliography covering SCI literature, shift-share methodology, minimum wage spillovers, and labor market networks. Key additions include Sun & Abraham (2021), de Chaisemartin & D'Haultfouille (2020), Kramarz & Skandalis (2023). PASS.
- **Prose:** All major sections in proper paragraph form. No bullet-point sections outside the testable predictions list (appropriate). PASS.
- **Section depth:** Each section has 3+ substantive paragraphs. PASS.
- **Figures:** All 8 figures render with proper axes and labels. Figure 8 (migration patterns) now renders from data. PASS.
- **Tables:** All tables contain real regression output with SEs, CIs, and sample sizes. PASS.

### Statistical Methodology

a) **Standard Errors:** All coefficients have clustered SEs in parentheses (state-level, 51 clusters). PASS.

b) **Significance Testing:** Comprehensive inference including state clustering, two-way clustering, Anderson-Rubin weak-IV-robust inference, permutation inference (2,000 draws), and origin-state clustering following Borusyak et al. (2022). PASS.

c) **Confidence Intervals:** 95% Wald CIs reported for all main specifications. Anderson-Rubin CIs for 2SLS. PASS.

d) **Sample Sizes:** N=134,317 (3,053 counties x 44 quarters) reported consistently. PASS.

e) **Staggered Adoption:** Not applicable -- this is a shift-share IV design with continuous treatment, not staggered binary DiD. Event study is diagnostic only. Sun & Abraham discussion included in Section 11.5. PASS.

### Identification Strategy

**Strengths:**
- Out-of-state instrument is well-motivated and achieves F=556
- Distance-restricted instruments show effects persist to 400km
- Anderson-Rubin CIs confirm weak-IV-robust inference
- Placebo shock tests (GDP, employment) show null -- supporting exclusion restriction
- Joint state exclusion (CA+NY, CA+NY+WA) shows stability
- Leave-one-origin-state-out analysis comprehensive

**Concerns:**
1. **SCI timing:** The SCI is from 2018 -- a single cross-section applied to 2012-2022 panel. Network structure likely evolved over this period. While treated as "pre-determined shares" in the shift-share framework, the 2018 vintage is actually mid-sample. The paper acknowledges this but could engage more with how network evolution might bias results.

2. **Pre-period coefficient:** The 2012 event study coefficient is large (~1.4), though the paper honestly reports this. With only 2 pre-periods (2012-2013), the evidence for parallel pre-trends is thin. The Rambachan & Roth sensitivity analysis helps but cannot fully resolve this.

3. **County-level ecological inference:** Effects are estimated at county level. Individual-level mechanisms (information updating, wage expectations) are inferred rather than directly measured.

### Literature
Literature coverage is now comprehensive following the revision. Key additions of Sun & Abraham, de Chaisemartin & D'Haultfouille, Kramarz & Skandalis, Bleemer, Mincer, and Belot & Van den Berg strengthen the theoretical grounding.

**Possible additions:**
- Caldwell & Harmon (2019) on outside options and wage bargaining
- Hagedorn et al. (2017) on unemployment insurance spillovers across labor markets

### Writing Quality
The paper is well-written with compelling narrative flow. The El Paso vs. Amarillo framing in the introduction is effective. Interpretation of the coefficient as a "market-level equilibrium multiplier" is well-developed. Prose is in active voice with varied sentence structure.

### Internal Consistency
After this revision round, numerical values appear internally consistent:
- Main 2SLS coefficient: 0.820 in Table 2, 0.82 throughout text
- AR CI: [0.51, 1.15] consistent across abstract, tables, conclusion
- First-stage F: 556 consistent
- Prob-weighted: 0.281 in Table 3, 0.28 in text (appropriate rounding)

**Remaining minor issue:** Figure 2 (first-stage scatter) may show F=551 in the figure label while the text/tables report F=556. This should be verified.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Industry heterogeneity:** The paper correctly notes this as a future direction since aggregate QWI cannot test it. If industry-level QWI data becomes available, testing that high-bite industries (retail, food service) show larger effects would significantly strengthen the information mechanism.

2. **Wage outcomes:** The paper focuses on employment. Adding wage regressions (using QWI earnings data already in the analysis) could distinguish between information effects on extensive vs. intensive margin.

3. **Temporal dynamics:** The event study could be extended to examine how quickly information effects materialize and whether they persist or fade over time.

4. **Heterogeneity by network composition:** Do counties with more concentrated network ties (lower SCI HHI) respond differently than those with diffuse connections?

---

## OVERALL ASSESSMENT

**Strengths:**
- Novel theoretical contribution: population vs. probability weighting as a test of information volume
- Exceptionally strong first stage (F=556) with comprehensive weak-IV diagnostics
- Creative placebo shock tests supporting exclusion restriction
- Migration mechanism analysis using IRS data adds credibility
- Well-written with clear narrative

**Weaknesses:**
- Thin pre-period evidence (2 years only) with large 2012 coefficient
- SCI vintage (2018) applied to full 2012-2022 panel raises temporal concerns
- County-level ecological inference about individual mechanisms

**Decision:** This paper makes a genuine contribution with rigorous execution. The population vs. probability weighting insight is novel and the empirical analysis is comprehensive. Weaknesses are acknowledged. Ready for external review.

DECISION: MINOR REVISION
