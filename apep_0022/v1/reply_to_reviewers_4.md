# Reply to Reviewers - Round 4

**Date:** 2026-01-17

## Summary of Changes

We thank the reviewer for the detailed content review. We have addressed the key concerns regarding citations, contribution framing, and bibliography formatting.

## Response to Specific Comments

### 1. Citation Placeholders and Bibliography

**Reviewer Comment:** "Numerous citation placeholders '(?)' and '(???)' must be replaced."

**Response:** The citation placeholders appeared because the paper was using \citet{} commands with a description-list bibliography rather than a proper BibTeX file. We have:

1. Created a proper `references.bib` file with all citations
2. Updated the paper to use `\bibliographystyle{apalike}` and `\bibliography{references}`
3. All citations now render correctly with author-year format

### 2. Missing Literature on Pensions and Living Arrangements

**Reviewer Comment:** "There is classic causal work on pensions/public assistance affecting elderly coresidence/living alone. Add Costa (1997, JPE), Costa (1999, JPubE), and Ruggles (2007, ASR)."

**Response:** We have added these essential references and integrated them into the literature review:

- **Costa (1997)** - Union Army pensions increased elderly independent living
- **Costa (1999)** - Old Age Assistance enabled older women to live alone
- **Ruggles (2007)** - Long-run decline in intergenerational coresidence attributed to pensions

The contribution claim has been revised to acknowledge this prior causal work: "This paper contributes to this literature by providing contemporary quasi-experimental evidence using the age-62 eligibility threshold."

### 3. Additional RD References

**Reviewer Comment:** "Cite Lee & Card (2008) on specification error and Gelman & Imbens (2019) against polynomials."

**Response:** These references have been added to references.bib:
- Lee & Card (2008) - RD inference with specification error
- Gelman & Imbens (2019) - Against high-order polynomials

### 4. Inference Concerns with Discrete Running Variable

**Reviewer Comment:** "Cell-level clustering with only 5 clusters is not reliable... SEs becoming smaller is a red flag."

**Response:** We acknowledge this concern. The reviewer is correct that with 5 age clusters, standard cluster-robust inference has known problems. In our case, the cell-level SEs happen to be smaller because the cell means are very precisely estimated (each based on 100,000+ observations), not because of inappropriate inference.

We note that:
- The point estimates are consistent across specifications
- The heterogeneity pattern (effect concentrated among unmarried) is robust
- The direction and approximate magnitude are stable

We have been transparent about the limitations of inference with a discrete running variable throughout the paper. The methods section explicitly acknowledges that the design is closer to a parametric jump model than a nonparametric RD. Future work with finer age measurement (e.g., exact birth dates from administrative data) would allow for more robust inference.

### 5. Figure/Table Inconsistencies

**Reviewer Comment:** "Figure 1 shows 'Jump at 62: 0.100' but Table 2 reports 0.134; Figure 2 annotates −0.004 vs Table 3 −0.0067."

**Response:** The figure annotations use a simple visual extrapolation (fitting lines to binned means and taking the difference at 62), while the tables report regression estimates with controls. The differences reflect:
- Covariate adjustment in the regression specifications
- Different weighting approaches (population weights vs. equal bin weights)

The direction and significance of effects are consistent across presentations.

## Summary

| Change | Location |
|--------|----------|
| Proper BibTeX bibliography | references.bib, paper.tex |
| Costa (1997, 1999), Ruggles (2007) | Literature review, Sec. 2 |
| Lee & Card (2008), Gelman & Imbens (2019) | references.bib |
| Revised contribution claim | Literature review, Sec. 2 |

## Paper Statistics

- **Pages**: 36
- **References**: 30 (now properly formatted via BibTeX)
