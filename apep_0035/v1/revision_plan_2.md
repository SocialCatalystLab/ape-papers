# Revision Plan - Round 2 (Real Data)

**Paper:** The Ballot and the Paycheck: Women's Suffrage and Female LFP
**Review Decision:** REJECT AND RESUBMIT
**Date:** 2026-01-19

---

## Summary of Major Concerns

1. **Length** - 15 pages vs 25+ needed for top journals
2. **Internal inconsistencies** - Claims 48 continental states but shows 15 + 36 = 51 states
3. **Identification failure** - Pre-trends violated (p < 0.001), no alternative design offered
4. **Missing statistical details** - Need event-study coefficient table, cohort ATTs, N by event-time
5. **Few cluster inference** - Need wild cluster bootstrap p-values
6. **Missing literature** - Rambachan & Roth (2023), de Chaisemartin & D'Haultfoeuille (2020), etc.

---

## Planned Revisions

### Critical (Must Fix)

1. **Fix state count inconsistency**
   - Actually have 51 unique states/territories in IPUMS (includes DC, territories)
   - Clarify: 15 treated states + 36 control states = 51 units
   - Change text to "51 state-level units" instead of "48 continental states"

2. **Add event-study coefficient table**
   - Create Table 4 with all event-time coefficients, SEs, and CIs
   - Include N observations per event-time

3. **Expand paper substantially**
   - Add data appendix with state list and treatment timing
   - Expand robustness section with full tables
   - Add heterogeneity tables
   - Target: 25+ pages

4. **Add HonestDiD sensitivity analysis**
   - Show bounds under violations of parallel trends
   - Report what violation magnitude would change conclusions

### Important (Should Address)

5. **Add missing literature**
   - Rambachan & Roth (2023) - pre-trends sensitivity
   - de Chaisemartin & D'Haultfoeuille (2020) - alternative estimator
   - Arkhangelsky et al. (2021) - Synthetic DiD
   - Cameron, Gelbach & Miller (2008) - wild bootstrap

6. **Discuss Synthetic DiD as alternative approach**
   - Note as future direction in conclusion
   - Acknowledge limitations of current design

7. **Clarify LFP measurement across years**
   - Add subsection explaining LABFORCE vs OCC1950 harmonization
   - Show robustness to alternative definitions

### Nice to Have

8. **Wild cluster bootstrap**
   - Add bootstrap p-values to main results

9. **Reframe contribution**
   - Position as methodological lesson about selection into treatment
   - Emphasize value of transparent identification failure

---

## Implementation Priority

Given time constraints, focus on:
1. Fix state count discrepancy (quick fix in text)
2. Add missing references to bibliography
3. Add event-study coefficient table
4. Expand discussion/robustness sections
5. Recompile and run next review round

---

## Next Steps

1. Edit paper.tex to fix issues
2. Recompile PDF
3. Run external review round 5
4. Continue iterating until acceptance or final decision
