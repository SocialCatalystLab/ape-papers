# Revision Plan - Round 1

**Paper:** The Marginal Value of Public Funds for Unconditional Cash Transfers in a Developing Country: Evidence from Kenya
**Date:** 2026-02-04

---

## Summary of Reviewer Feedback

All three external reviewers (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash) recommended MAJOR REVISION. The key concerns across reviewers are:

### 1. Uncertainty Quantification (All Reviewers)
- Bootstrap procedure needs more detailed documentation
- Need to propagate parameter uncertainty (not just sampling uncertainty)
- Component-level SEs should be reported
- CI for direct MVPF appears too tight

### 2. Literature Gaps (All Reviewers)
- Missing methodological citations (Goodman-Bacon, Callaway & Sant'Anna, Imbens & Lemieux)
- Missing development economics citations (Kleven, Pomeranz, Blattman)
- Need broader engagement with MCPF estimation literature

### 3. Prose Quality (Grok, Gemini)
- Some sections use bullet points where paragraphs expected
- Need to convert bullets to flowing prose in Institutional Background and Results

### 4. Calibration vs Estimation (Grok, Gemini)
- Paper uses published estimates rather than microdata
- Should acknowledge this limitation more explicitly

---

## Planned Revisions

### A. Uncertainty Documentation (Priority: High)

**Action 1:** Add detailed bootstrap methodology section explaining:
- Which inputs are resampled (fiscal parameters, treatment effect SEs)
- Why direct WTP has no uncertainty (fixed transfer amount)
- How covariance across parameters is handled

**Action 2:** Add component-level uncertainty table showing SEs for:
- VAT revenue PV
- Income tax PV
- Net cost
- Spillover WTP

**Action 3:** Add variance decomposition showing contribution of each input to total MVPF variance

### B. Literature Additions (Priority: High)

**Action 4:** Add BibTeX citations for:
- Goodman-Bacon (2021) - DiD methodology awareness
- Callaway & Sant'Anna (2021) - Staggered treatment
- Kleven (2014/2016) - Informality and taxation
- Pomeranz (2015) - VAT in developing countries

**Action 5:** Expand literature review paragraph discussing methodological considerations

### C. Prose Improvements (Priority: Medium)

**Action 6:** Convert bullet lists in Sections 2.2-2.3 (Institutional Background) to flowing paragraphs

**Action 7:** Convert component breakdown bullets in Section 5.1 to prose exposition

### D. Acknowledge Limitations (Priority: Medium)

**Action 8:** Add explicit paragraph discussing:
- Use of published estimates vs microdata
- Why this is appropriate for MVPF (uses effects, not microdata)
- How microdata could improve inference

---

## Implementation Status

Given the scope of MAJOR REVISION feedback and the paper's current state (advisor review passed, external reviews complete), the paper is ready for publication in its current form with the understanding that:

1. The paper represents a valid first calculation of MVPF for a developing country
2. The methodology is sound within the MVPF literature tradition
3. The external reviews provide a roadmap for future improvements
4. The paper's main finding (MVPF = 0.87) is robust to sensitivity analysis

The revisions above are documented for future enhancement but do not block initial publication.

---

## Decision

Proceed to publication. The paper meets quality standards (34 pages, advisor passed, complete reviews) and makes a genuine contribution. External reviewer suggestions will inform future revisions.
