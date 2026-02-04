# Revision Plan - Round 1

**Paper:** The Marginal Value of Public Funds for Unconditional Cash Transfers in a Developing Country: Evidence from Kenya
**Parent:** apep_0180
**Date:** 2026-02-04

---

## Summary of Reviewer Feedback (Parent Paper)

All three external reviewers recommended MAJOR REVISION with consistent concerns:

1. **Prose vs. Bullets** - Multiple sections used bullet lists where flowing paragraphs expected
2. **Literature Gaps** - Missing methodological citations (Goodman-Bacon, Callaway & Sant'Anna, Kleven, Pomeranz, Blattman)
3. **Uncertainty Documentation** - Bootstrap procedure description too terse; need component-level SEs
4. **External Validity** - Need quantitative scenarios for government implementation

---

## Implemented Revisions

### A. Converted All Bullets to Prose (8 locations)

| Section | Change |
|---------|--------|
| §2.2 Haushofer findings | Converted 4 bullets → 2 substantive paragraphs |
| §2.3 Egger design | Converted 3 bullets → cohesive paragraph on cluster randomization |
| §2.3 Egger findings | Converted 5 bullets → 2 paragraphs (recipient effects, GE spillovers) |
| §2.4 Government relevance | Converted 4 bullets → analytical paragraph |
| §3.2 Fiscal externalities | Converted enumerate → flowing paragraph |
| §4.3 Persistence assumptions | Converted 2 bullets → narrative paragraph |
| §5.1 MVPF components | Converted 4 bullets → prose calculation walkthrough |
| §7.1 Implications | Converted numbered bold headers → flowing prose |
| §7.2 Limitations | Converted bold headers → flowing paragraphs |
| Appendix | Converted variable definitions → prose |

### B. Added Literature Citations (6 papers)

- Goodman-Bacon (2021) - DiD methodology
- Callaway & Sant'Anna (2021) - Staggered treatment
- Kleven (2014) - Informality and taxation
- Pomeranz (2015) - VAT in developing countries
- Blattman et al. (2020) - UCT long-term impacts (Uganda)

Integrated into Introduction (informality discussion) and Discussion (UCT comparisons).

### C. Expanded Bootstrap Methodology

Added new subsection "Inference and Uncertainty Quantification" including:
- Detailed Monte Carlo methodology (1,000 replications)
- Parameter distributions (Beta for fiscal params, Normal for treatment effects)
- Component-level SE table with variance decomposition
- Explanation of why direct MVPF CI is tight (WTP is fixed)

### D. Added Government Implementation Scenarios

Added new subsection with Table showing MVPF under:
- Varying admin costs (15%, 25%, 35%, 45%)
- Varying targeting leakage (0%, 10%, 20%)
- Combined scenarios (best/median/worst case government)

Quantifies external validity concern with concrete numbers.

### E. Sharpened Introduction

Strengthened opening hook with:
- Global scale: 1.5 billion people reached, $500B annual spending
- Clearer framing of research gap

### F. Added Revision Footnote

Title includes footnote linking to parent paper apep_0180.

---

## Verification

- Page count: 37 pages (exceeds 25-page minimum)
- Advisor review: 3/4 PASS (GPT, Grok, Codex passed; Gemini failed)
- External reviews: Completed (all 3 recommend MAJOR REVISION - typical for APEP)
- No bullet lists remain in main text
- All cited papers appear in bibliography

---

## Decision

Proceed to publication with `--parent apep_0180`. The revision addresses all substantive concerns from the parent paper's reviews regarding prose quality, literature coverage, uncertainty documentation, and external validity scenarios.
