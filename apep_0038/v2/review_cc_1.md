# Internal Review - Round 1

**Reviewer:** Claude Code Internal Review
**Paper:** Betting on Jobs? The Employment Effects of Legal Sports Betting in the United States
**Date:** 2026-01-30

---

## PART 1: CRITICAL REVIEW

### Format Check

**Length:** Approximately 25 pages of main text (through the Conclusion section), meeting the minimum requirement. Total PDF is 35 pages including appendix figures and tables.

**References:** Bibliography includes 23 entries covering foundational DiD methodology (Callaway-Sant'Anna, Goodman-Bacon, Rambachan-Roth), gambling economics literature, and policy-relevant work. Adequate coverage.

**Prose:** Paper is written in full paragraphs throughout. No bullet-point issues in main sections.

**Section depth:** All major sections have substantive content with 3+ paragraphs.

**Figures:** All 6 figures display visible data with proper axes, titles, and legends. Figure 3 (map) shows treatment timing by state.

**Tables:** All 7 tables contain real numbers with no placeholders.

### Statistical Methodology

**PASS** - Paper uses appropriate statistical methods:
- Callaway-Sant'Anna estimator for staggered DiD (avoids TWFE bias)
- Standard errors clustered at state level
- 95% confidence intervals reported
- Sample sizes (N) reported in all tables
- Pre-trend F-tests provided
- HonestDiD sensitivity analysis included

### Identification Strategy

**Strengths:**
- Murphy v. NCAA provides plausibly exogenous variation
- Pre-trend tests support parallel trends assumption
- Multiple robustness checks (COVID exclusion, iGaming controls, PASPA states, leave-one-out)
- HonestDiD bounds robust to M=2

**Concerns:**
- NAICS 7132 is a noisy measure of sports betting employment specifically
- Never-treated states may differ systematically from treated states
- Geographic attribution issues for mobile-first operators

These concerns are acknowledged and discussed in the paper.

### Literature

Adequate coverage of:
- DiD methodology (Callaway-Sant'Anna, Goodman-Bacon, Rambachan-Roth)
- Gambling economics (Evans-Topoleski, Grinols-Mustard)
- Labor market effects of regulation

### Writing Quality

**PASS** - Well-written with clear narrative arc:
- Introduction hooks with Murphy decision and policy question
- Logical flow from background → data → methods → results → robustness
- Technical concepts explained with intuition
- Magnitudes contextualized (81,000 jobs nationally, 42% mobile premium)

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Wage analysis:** Could strengthen the contribution by examining whether new jobs are high- or low-wage

2. **Establishment-level analysis:** QCEW provides establishment counts; examining extensive vs intensive margin would be informative

3. **Spillovers:** Cross-border betting effects could be examined using border county data

4. **Job quality:** Worker turnover, benefits provision could be assessed with supplemental data

---

## OVERALL ASSESSMENT

**Key Strengths:**
- Clean identification from Murphy decision
- Modern DiD methods (Callaway-Sant'Anna, HonestDiD)
- Comprehensive robustness checks
- Well-written with clear policy relevance

**Weaknesses:**
- Outcome measure (NAICS 7132) is imperfect for sports betting
- Treatment timing for some states is debatable
- Effects may include displacement from other gambling

**Verdict:** Solid revision of apep_0038 that addresses major reviewer concerns. Ready for external review.

---

DECISION: MINOR REVISION
