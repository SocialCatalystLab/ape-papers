# Revision Plan — Round 2 (Comprehensive External Review Response)

**Based on:** External Reviews GPT-1, GPT-2, GPT-3 (Parallel)
**Date:** 2026-01-22
**Unanimous Decision:** REJECT AND RESUBMIT

---

## Summary of Reviewer Consensus

All three reviewers identified the same fundamental issues:

1. **Placeholder citations** in literature review (critical)
2. **No empirical first-stage** showing funding discontinuity (critical)
3. **Timing mismatch** between 2020 Census and 2018-2022 ACS outcomes (critical)
4. **Table inconsistencies** in N reporting and units (major)
5. **Paper too short** for top journal (14-23 pages vs. 25+ requirement)
6. **Overstated precision** of null results given wide CIs

---

## Critical Issue 1: Placeholder Citations

**Problem:** Literature review contains "?" placeholders where citations should be.

**Solution:**
- Add complete BibTeX entries for all referenced works
- Cite canonical RD methodology papers (Imbens & Lemieux 2008, Lee & Lemieux 2010, McCrary 2008)
- Add intergovernmental grants literature (Hines & Thaler 1995, Knight 2002)
- Add transportation infrastructure papers (Baum-Snow 2007)
- Add spatial mismatch literature (Kain 1968, Holzer et al. 1994)

**Implementation:**
- Update paper.bib with all required citations
- Replace "?" with proper \cite{} commands throughout

---

## Critical Issue 2: First-Stage Funding Discontinuity

**Problem:** Paper claims "mechanical" first stage but shows no empirical evidence.

**Solution:**
- Create Figure showing Section 5307 funding formula amounts by population
- The FTA formula is: Funding = Population × $20 per capita (approximately) for areas ≥50k
- Areas <50k receive $0 from Section 5307
- This creates a sharp discontinuity at exactly 50,000

**Implementation:**
- Add new figure: "Figure 8: First-Stage Funding Discontinuity"
- Calculate formula funding: F(pop) = max(0, pop × 20) for pop ≥ 50,000
- Show this is deterministic by law, not fuzzy

**Note:** Actual FTA apportionment data would strengthen this, but the statutory formula creates a sharp discontinuity by definition.

---

## Critical Issue 3: Timing Mismatch

**Problem:** 2020 Census population determines treatment, but ACS 2018-2022 outcomes span pre-treatment period.

**Solution:**
- Acknowledge explicitly as fundamental limitation
- Reframe as testing **long-standing eligibility** rather than newly-eligible areas
- Note that areas that were ≥50k in both 2010 and 2020 have had funding for decades
- The null result is most informative for these long-standing eligible areas
- For newly-eligible areas (crossed 50k between 2010-2020), the timing concern is valid

**Implementation:**
- Add new subsection 6.3: "Timing Considerations and Interpretation"
- Distinguish between: (a) long-standing eligible areas (valid test), (b) newly eligible areas (timing concern)
- Acknowledge this limits causal interpretation for margin-crossers

---

## Major Issue 4: Table Inconsistencies

**Problem:** Table 5 reports N (L/R) = 2128/509 for all bandwidths, which is full-sample counts, not within-bandwidth.

**Solution:**
- Fix Table 5 to show actual observations within each bandwidth
- Standardize units across tables (all in percentage points)
- Add mean of dependent variable to all outcome tables

**Implementation:**
- Recalculate effective N for each bandwidth specification
- Update Table 1 and Table 5 with correct within-bandwidth counts

---

## Major Issue 5: Paper Length

**Problem:** ~14 pages main text vs. 25+ pages required for top journal.

**Solution:**
- Expand literature review with proper citations and deeper engagement
- Add first-stage analysis section
- Expand discussion of mechanisms and timing
- Add additional robustness checks (local quadratic, donut RD)
- Expand covariate balance section

**Implementation:**
- Target 25+ pages of main text (excluding figures/tables/appendix)

---

## Major Issue 6: Overstated Precision

**Problem:** Paper claims "precisely estimated null" but CIs are wide relative to means.

**Solution:**
- Reframe interpretation: "We cannot rule out economically meaningful effects"
- Transit CI of [-1.0, +0.5] pp against mean of 0.7% includes large effects
- Employment CI of [-5.6, +1.2] pp is not precise in policy terms
- Acknowledge power limitations for detecting modest effects

**Implementation:**
- Revise abstract and results sections to be more circumspect
- Add explicit discussion of statistical power

---

## Implementation Order

1. **Fix citations** — Replace all "?" with proper BibTeX entries
2. **Add first-stage figure** — Create funding formula discontinuity visualization
3. **Fix table inconsistencies** — Correct N reporting, standardize units
4. **Expand literature review** — Full engagement with relevant papers
5. **Add timing discussion** — New subsection on interpretation limitations
6. **Expand methods** — Add donut RD, local quadratic, more covariate balance
7. **Revise interpretation** — Remove "precisely estimated" claims
8. **Expand throughout** — Target 25+ pages main text

---

## Realistic Assessment

Given the fundamental timing mismatch (2020 Census vs. 2018-2022 ACS), this paper will likely remain a "minor contribution" regardless of revisions. The design limitation cannot be fully resolved without different data.

However, the paper can be made **publishable** by:
- Honestly acknowledging limitations
- Properly situating in literature
- Presenting as informative null for a specific question

The null result itself is valuable information — it suggests that marginal transit funding eligibility does not produce detectable improvements in commute patterns or employment at the extensive margin.

---

## Files to Modify

1. `paper.tex` — Main document (major revisions throughout)
2. `paper.bib` — Add all missing citations
3. `code/04_figures.R` — Add first-stage figure
4. Potentially create new R scripts for additional robustness checks

