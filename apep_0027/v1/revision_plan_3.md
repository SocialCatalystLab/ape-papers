# Revision Plan - Round 3 (External Review Response)

**Date:** January 18, 2026
**Reviews:** GPT 5.2 Round 2, Gemini 3 Pro Round 2
**Verdicts:** GPT: FAIL (24 pages); Gemini: MAJOR REVISION (content issues)

---

## Summary of External Feedback

### GPT 5.2
- **Format**: Main text ~24 pages, needs ≥25
- All other format checks passed

### Gemini 3 Pro
- **Format**: Passed (counted 25 pages)
- **Statistical Methodology**: Critical fail - need Wild Cluster Bootstrap
- **Identification**: Fail - parallel trends violated, suggests Synthetic Control
- **Literature**: Fail - missing key methodology references

---

## Response Plan

### 1. Add Content for Length (Address GPT concern)
- Expand Section 4.2 (Main Results) with additional interpretation
- Add more detail to Results section interpretation

### 2. Implement Wild Cluster Bootstrap (Address Gemini concern)
- Add bootstrap inference to did_analysis.py
- Report bootstrap p-values alongside standard cluster-robust SEs
- Update Table 2 with bootstrap results
- This is a reasonable request and computationally feasible

### 3. Add Missing References (Address Gemini concern)
- Bertrand, Duflo, Mullainathan (2004) on DiD inference
- Goodman-Bacon (2021) on staggered DiD
- de Chaisemartin & D'Haultfoeuille (2020) on TWFE
- Callaway & Sant'Anna (2021) on robust DiD

### 4. Address TWFE/Staggered Adoption Concern
- Add discussion in Section 3.3 noting the Goodman-Bacon critique
- Explain that our exclusion of partially-treated mitigates some concerns
- Acknowledge this as a limitation

### 5. Respond to Synthetic Control Suggestion
- This is beyond scope given our explicit acknowledgment that the design fails
- The paper's contribution is partly methodological: illustrating when DiD fails
- Synthetic control wouldn't solve the fundamental selection problem
- Will add as future research direction

---

## Implementation

1. Run wild cluster bootstrap on main specifications
2. Update paper.tex with:
   - Bootstrap results
   - New references
   - Discussion of Goodman-Bacon/TWFE issues
   - Additional results interpretation (~1 page)
3. Recompile PDF
4. Re-run external review
