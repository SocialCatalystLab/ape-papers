# Reply to Reviewers

## Summary of Changes

We thank the reviewers for their thoughtful comments. All three reviewers identified similar concerns, and we have substantially revised the paper to address them. The paper has grown from approximately 17 pages to 23 pages (main text ends at page 18 before references and appendix).

---

## Reviewer 1

### "Paper is too short (~17 pages)"

**Response:** The paper now spans 23 pages including the appendix. The main text (through the Conclusion) is approximately 18 pages. We expanded:
- The Introduction with more context on identification challenges
- The Institutional Background section with detail on CEP and COVID waivers
- A new subsection formalizing the recall-window mismatch problem
- A new Triple-Difference specification and results section
- A substantially expanded Discussion section

### "No credible identification strategy—must choose a path"

**Response:** We chose **Path A** (methodological contribution) but with enhanced empirical content. The paper now:
1. Formalizes the recall-window mismatch as an estimand problem (Section 3.2.1)
2. Implements a triple-difference specification that yields a more credible null result
3. Reports randomization inference to stress-test the naive estimates
4. Explicitly frames the positive TWFE coefficient as a diagnostic of design failure

### "Missing key DiD literature"

**Response:** We have added citations to:
- Sun & Abraham (2021)
- Borusyak, Jaravel & Spiess (2024)
- de Chaisemartin & D'Haultfoeuille (2020)
- Conley & Taber (2011)
- Cameron & Miller (2015)
- Ferman & Pinto (2019)
- Rambachan & Roth (2023)

### "95% CIs needed in tables"

**Response:** All main tables now include 95% confidence intervals in brackets below standard errors.

### "Few-cluster inference inadequate"

**Response:** We added:
1. Wild cluster bootstrap (Table 5)
2. Randomization inference with permutation distribution (Figure 4)
3. Discussion of inference limitations with 4 treated clusters

### "Need placebo tests or triple-differences"

**Response:** We implemented a triple-difference specification (Table 4) comparing households with versus without school-age children. The DDD estimate is -0.9 pp (SE = 1.3 pp), essentially zero and precisely estimated. This is now the most informative result in the paper.

---

## Reviewer 2

### "Why would you submit a paper that explicitly cannot identify a treatment effect?"

**Response:** We have reframed the paper more explicitly as a methodological contribution. The positive TWFE estimate (4.7 pp increase in food insecurity from free meals) serves as a diagnostic signal of design failure. The central contribution is the formalization of how recall-window mismatch invalidates DiD designs—a problem that generalizes to many survey-based settings.

### "Bullet lists instead of prose"

**Response:** All bullet lists have been converted to prose paragraphs. The Introduction no longer uses numbered lists for the "fundamental problems."

### "Missing references"

**Response:** See response to Reviewer 1 above. All suggested references have been added.

---

## Reviewer 3

### "Paper should either formalize the methodological point or extend the data"

**Response:** We chose to formalize the methodological point. Section 3.2.1 now presents a formal exposition of the exposure-intensity problem:
- Defines the true exposure measure as the fraction of months in the recall window with treatment
- Shows that for August adopters surveyed in December, first "post" observation has only 25% exposure
- Explains why binary treatment coding conflates mixed-exposure outcomes

### "Need 95% CIs"

**Response:** Done. All tables now include 95% confidence intervals.

### "Need triple-diff or DDD"

**Response:** Done. Table 4 presents triple-difference results. The DDD estimate is the most credible finding in the paper.

### "Need randomization inference"

**Response:** Done. Table 5 reports RI p-value = 0.015. Figure 4 shows the permutation distribution.

---

## Summary of New Results

| Specification | Estimate | 95% CI | Interpretation |
|---------------|----------|--------|----------------|
| TWFE | 0.047** | [0.009, 0.085] | Design failure (positive = more food insecurity from free food) |
| CS ATT | 0.052** | [0.005, 0.099] | Same recall-window problem as TWFE |
| Triple-diff (DDD) | -0.009 | [-0.035, 0.017] | Near-zero effect when state confounds differenced out |
| RI p-value | — | — | 0.015 (positive TWFE unlikely under random assignment) |

The key insight is that the naive DiD (positive, significant) and triple-diff (zero, insignificant) tell very different stories. The discrepancy suggests state-level confounds—not school meal effects—drive the naive results.
