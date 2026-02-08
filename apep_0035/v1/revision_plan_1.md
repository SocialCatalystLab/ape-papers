# Revision Plan - Round 1

**Paper:** The Ballot and the Paycheck: Women's Suffrage and Female LFP
**Review Decision:** REJECT AND RESUBMIT
**Date:** 2026-01-19

---

## Summary of Major Concerns

1. **Completeness** - Tables have placeholders, figures missing
2. **Statistical Reporting** - Missing Ns, SEs, pre-trends p-values
3. **Identification** - Selection into adoption, sparse time periods

---

## Planned Revisions

### Critical (Must Fix)

1. **Replace all placeholders with actual numbers**
   - Table 2: Fill in summary statistics from analysis_sample.rds
   - Table 3: Fill in N, pre-trends p-value
   - Fix all "Table ??" and "Figure ??" references

2. **Add missing statistical reporting**
   - Report pre-trends p-value (currently ~0.003)
   - Add N to all tables
   - Include event study coefficient table (not just figure)

3. **Expand paper length** (currently 11 pages, target 25+)
   - Extend historical background with more detail on suffrage campaigns
   - Add data section with IPUMS extract details
   - Expand robustness with additional specifications

### Important (Should Address)

4. **Strengthen identification argument**
   - Add HonestDiD sensitivity analysis for pre-trends violations
   - Consider synthetic DiD (Arkhangelsky et al. 2021)
   - Restrict to 1910-1918 wave for cleaner pre-periods

5. **Add missing literature**
   - de Chaisemartin & D'Haultfoeuille (2020)
   - Rambachan & Roth (2023)
   - Borusyak, Jaravel & Spiess (2021)

6. **Clarify treatment definition**
   - Document exact suffrage rights (full vs. partial)
   - Explain territory/state transitions

### Nice to Have (If Time Permits)

7. **Mechanism analysis**
   - Occupation transitions
   - Policy channel tests (labor legislation)

8. **Few clusters inference**
   - Wild cluster bootstrap p-values

---

## Status: PILOT DEMONSTRATION

**Important Note:** This paper uses **simulated pilot data** for demonstration purposes. The IPUMS extract is still processing. Final results will be updated when real data is available.

Given the pilot nature of this analysis, we will:
- Acknowledge simulation in abstract/note
- Mark as "preliminary" pending real data
- Focus on demonstrating the methodology pipeline

---

## Next Steps

1. Update paper with actual statistics from simulated data
2. Add acknowledgment of pilot/demonstration status
3. Expand literature review
4. Proceed to publication as pilot paper
