# Internal Review — Claude Code (Round 2)

**Role:** Reviewer 2 (harsh, skeptical)
**Paper:** paper.pdf (post-revision)
**Timestamp:** 2026-02-22

---

## Review After Round 1 Fixes

### Issues Addressed Since Round 1

1. **Text-table consistency on referendum-specific interactions**: The paper now explicitly acknowledges that some individual referenda show statistically significant interactions (+3.4pp for 1981, -4.8pp for 2020, -2.7pp for 2021), and explains that sign-switching yields the pooled null. The subsection title changed from "Consistently Zero" to "Averages Zero." This is honest and accurate.

2. **14.8pp vs 15.5pp inconsistency**: Fixed in Discussion section. Now consistently uses 15.5pp (from the interaction model, which is the main specification).

3. **Scientific notation in tables**: Table 5 now shows -0.0009 instead of -9e-04. Table 6 (robustness) no longer has truncated coefficients.

### Remaining Minor Issues

1. **Permutation figure panels**: Gemini flagged that Figure 3 caption says "language effect (left) and interaction (right)" but may show only one panel. Should verify the figure code generates both panels. This is a code issue in 05_figures.R, not a paper tex issue.

2. **4 dropped observations**: Table 2 Column 6 has N=8,723 vs 8,727 in other columns. Should add a brief note explaining these 4 municipality-referendum pairs have missing eligible voter data.

3. **Interaction plot (Appendix Figure 7)**: Both the exhibit review and internal review recommend promoting this to the main text. The parallel-lines visualization is the most intuitive proof of modularity.

### Assessment

The paper has addressed the primary issues from Round 1. The text-table consistency problem (the most serious issue) has been resolved by honest acknowledgment of sign-switching. The remaining items are minor formatting and exhibit issues that do not affect the substance.

**Strengths maintained:**
- Novel modularity test with clean empirical design
- Large, precisely estimated main effects
- Dramatic falsification (sign reversal on non-gender)
- Honest treatment of null result
- Strong prose quality

**Recommendation:** Ready for external review.

DECISION: MINOR REVISION
