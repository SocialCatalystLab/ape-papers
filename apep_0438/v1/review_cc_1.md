# Internal Review — Claude Code (Round 1)

**Role:** Internal reviewer (Reviewer 2 mode)
**Paper:** Secret Ballots and Women's Political Voice: Evidence from the Swiss Landsgemeinde
**Date:** 2026-02-21

---

## Summary

The paper exploits the 1997 abolition of the Landsgemeinde in Appenzell Ausserrhoden to test whether public voting suppresses women's political voice. Using a spatial difference-in-discontinuities design at the AR-AI border, the paper finds a precisely estimated null: the cross-border gap in federal referendum voting is stable before and after abolition. The null contributes to the institutions-vs-culture debate.

## Strengths

1. **Clean natural experiment**: The AR-AI border provides near-ideal identification — two half-cantons with shared history, language, geography, and (until 1997) the same Landsgemeinde institution.
2. **Compelling event study**: Figure 3 is the paper's strongest evidence — the flat line before and after 1997 makes the null visually undeniable.
3. **Honest reporting**: The paper doesn't torture the data to find significance. The null is presented as a genuine contribution.
4. **Comprehensive robustness**: Permutation inference (level and DiDisc), placebo dates, pre-period restriction, influential unit exclusion, two-way clustering, voter weighting.

## Concerns

1. **Indirect mechanism**: The outcome (federal secret-ballot voting) is not directly affected by the Landsgemeinde (cantonal public voting). The paper acknowledges this but could do more to address it.
2. **Small sample on AI side**: Only 4 AI municipalities in the border region. This limits nonparametric RDD and creates inference challenges.
3. **Power for gender subgroup**: MDE of 7pp for gender referendums means moderate effects cannot be ruled out.
4. **No cantonal-level outcomes**: Cantonal referendum data would provide a more direct test of the public-voting mechanism.

## Minor Issues

- Placeholder author fields (@CONTRIBUTOR_GITHUB) — will be replaced at publish
- Could add a density plot for the running variable (municipality distance distribution)

## Verdict

**ACCEPT with minor revisions.** The null result is well-identified and the robustness checks are thorough. The main limitations (indirect mechanism, small N) are inherent to the setting and honestly discussed. The contribution to the institutions-vs-culture debate is genuine and the paper is well-written.
