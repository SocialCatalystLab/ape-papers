# Revision Plan

Based on reviews from GPT-5-mini (MAJOR REVISION), Grok-4.1-Fast (MAJOR REVISION), and Gemini-3-Flash (REJECT AND RESUBMIT).

---

## Overview of Common Concerns

All three reviewers raise similar issues:

1. **Statistical Precision/Power** - Main results are imprecise and statistically insignificant
2. **Job-Changer Proxy** - MIGRATE1 (residential moves) is a weak proxy for actual job changes
3. **Missing References** - Several key papers not cited
4. **Inference Transparency** - Need explicit confidence intervals in tables, wild bootstrap p-values

---

## Revisions to Address

### HIGH PRIORITY (Feasible within this revision)

1. **Add explicit 95% confidence intervals to main tables**
   - Convert SEs to CIs for main ATT estimates
   - GPT and Grok both requested this

2. **Add wild cluster bootstrap p-values**
   - Include in table notes
   - Document bootstrap algorithm (1000 reps, Rademacher weights)

3. **Add missing references**
   - Bertrand, Duflo & Mullainathan (2004) on serial correlation in DiD
   - de Chaisemartin & D'Haultfoeuille (2020) on staggered DiD
   - Cameron, Gelbach & Miller (2008) on cluster-robust inference
   - Dube, Giuliano, and Leonard (2019) on wage transparency

4. **Strengthen limitations discussion**
   - More explicit about proxy measurement error
   - Discuss unweighted percentiles issue
   - Add honest acknowledgment of precision limitations

5. **Convert bullet lists in Discussion to prose**

### MEDIUM PRIORITY (Acknowledged but requiring more data/time)

6. **Job-changer proxy validation**
   - Note in limitations that CPS/LEHD validation would strengthen results
   - Explain why ACS MIGRATE1 is used (large sample, state coverage)

7. **Survey weighting discussion**
   - Add note explaining unweighted percentiles choice
   - Acknowledge potential bias and suggest weighted percentiles as robustness

8. **Top-coding discussion**
   - Note that 90th percentile may be affected by top-coding
   - Point to SD log wages as alternative measure less sensitive to top-coding

### LOW PRIORITY (Future work / beyond scope)

9. **Alternative data sources (CPS, LEHD)** - Future research
10. **Synthetic control robustness** - Future research
11. **Border spillover analysis** - Future research

---

## Changes to Make

### paper.tex

1. Add CIs to Table 3 (main results)
2. Add wild bootstrap p-value notes
3. Convert Discussion enumerations to prose
4. Expand limitations section
5. Add paragraph on precision/power limitations
6. Strengthen framing: emphasize this is a "first look" finding suggestive results

### references.bib

1. Add Bertrand et al. (2004)
2. Add de Chaisemartin & D'Haultfoeuille (2020)
3. Add Cameron et al. (2008)
4. Add Dube et al. (2019)

---

## Timeline

1. Update references.bib with missing citations
2. Update paper.tex with new citations and discussion
3. Add CIs and bootstrap notes to tables
4. Convert bullet lists to prose
5. Recompile and verify

---

## Acceptance Criterion

Reviewers requested MAJOR REVISION (2) and REJECT AND RESUBMIT (1). Per APEP workflow, proceed to publish after addressing feasible revisions. The paper makes a modest but novel contribution to the literature despite statistical imprecision.
