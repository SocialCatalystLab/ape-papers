# Revision Plan - Round 2

## Response to GPT 5.2 External Review (REJECT AND RESUBMIT)

### Critical Issue 1: Internal Inconsistencies (MUST FIX)

**Problem:** Sample sizes and coefficient magnitudes inconsistent across paper:
- Abstract: "136,000"
- Data section: "~150,000"
- Table 2: 135,952
- Appendix Table 5: shows "$30,000" but main result is $23,843
- Appendix trimming table shows ~$29-30k

**Fix:**
- Use 135,952 consistently throughout (this is the actual analysis sample)
- Correct Appendix Table 5 to show $23,843 (the actual preferred estimate)
- Fix trimming table to show consistent estimates
- Remove all "approximately" language in regression tables

### Critical Issue 2: Incomplete Inference (MUST FIX)

**Problem:** Table 4 (heterogeneity) lacks standard errors and CIs

**Fix:**
- Add standard errors to all heterogeneity estimates
- Add 95% CIs to main results in Table 2
- Note in table caption that these are conditional estimates

### Critical Issue 3: Identification Framing

**Problem:** Paper oscillates between causal ATT framing and descriptive framing

**Fix:**
- Commit fully to descriptive framing throughout
- Change title to remove "Causally"
- Remove ATT estimand discussion or clearly label as "what we would estimate IF CIA held"
- Add explicit statement early that this is descriptive evidence

### Critical Issue 4: Thin Literature

**Problem:** Only 9 references, missing key works

**Fix:** Add citations for:
- Rosenbaum & Rubin (1983) - propensity scores
- Hirano, Imbens & Ridder (2003) - efficient estimation
- Imbens & Wooldridge (2009) - program evaluation
- Altonji, Elder & Taber (2005) - selection on observables
- Oster (2019) - coefficient stability
- Cooper et al. (2016) - pass-through taxation
- Cullen & Gordon (2007) - taxes and entrepreneurship
- Levine & Rubinstein (2017) - entrepreneur earnings

### Critical Issue 5: Section 2 Bullet Lists

**Problem:** Institutional background uses bullet lists instead of prose

**Fix:** Convert to flowing paragraphs that integrate institutional details analytically

### Issue 6: Paper Length

**Problem:** ~16 pages is below 25-page expectation

**Fix:** Expand literature, data measurement discussion, and robustness discussion

### Issue 7: Hours Worked as Bad Control

**Problem:** Reviewer notes hours may be a mediator (post-treatment)

**Fix:** Add explicit discussion in Section 7 about this concern; note that specification (2) without hours is also economically meaningful

## Implementation Order

1. Fix all numerical inconsistencies (abstract, data section, appendix tables)
2. Add SEs to heterogeneity table
3. Add 95% CIs to main table
4. Reframe title and abstract as descriptive
5. Convert Section 2 bullets to prose
6. Expand literature with suggested citations
7. Add discussion of hours-worked-as-mediator concern
8. Visual QA and recompile
