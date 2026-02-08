# Internal Review Round 1 - Claude Code (Reviewer 2)

**Paper:** Does Broadband Internet Change How Local Politicians Talk? Evidence from U.S. Local Government Meetings

**Date:** 2026-01-22

---

## Overall Assessment

This paper examines an interesting question about the effects of broadband internet on moral language in local government discourse. The null finding is well-documented and robust across specifications. However, several issues need to be addressed before the paper is ready for submission.

**Recommendation:** MINOR REVISION

---

## Major Issues

### 1. Missing Table and Figure References
Throughout the main text, table and figure references appear as "Table ??" and "Figure ??". This is a critical formatting issue that must be fixed. Specifically:
- Page 11: "Table ?? presents summary statistics for the LocalView data"
- Page 12: "Table ?? presents summary statistics for broadband adoption"
- Page 15: "Table ?? presents summary statistics for the analysis sample"
- Page 15: "Figure ?? plots mean broadband adoption rates"
- Page 20: "Table ?? presents our main estimates"
- Pages 21-25: Multiple additional undefined references

**Action Required:** Add proper `\label{}` tags to tables and figures in the main body sections, or include the actual tables/figures that are referenced.

### 2. Paper Number Mismatch
The title page indicates "APEP Working Paper #0063" but this is paper 68 in the output folder. This should be reconciled.

### 3. Missing Main Body Tables and Figures
The paper text references summary statistics tables, main results tables, and event study figures that appear to exist only in the appendix. The main body should include:
- Table 1: Summary statistics for LocalView data
- Table 2: Summary statistics for broadband adoption
- Table 3: Summary statistics for analysis sample
- Table 4: Main TWFE results
- Table 5: Callaway-Sant'Anna results
- Figure 1: Broadband adoption trends
- Figure 2: Moral foundations by treatment status
- Figure 3: Event study - Individualizing
- Figure 4: Event study - Binding
- Figure 5: Coefficient plot for all foundations

---

## Minor Issues

### 4. Introduction Length
The introduction is approximately 5 pages, which is appropriate and meets the 4+ page requirement. However, the roadmap paragraph at the end could be shortened.

### 5. Literature Citations
The paper includes approximately 45 references, well exceeding the 20+ requirement. The citations are appropriate and well-integrated.

### 6. Precision of Null Results Discussion
On page 21, the paper states effects can be ruled out "larger than a few tenths of a standard deviation" and later "0.15 standard deviations." Be consistent throughout about the precision of the null.

### 7. Data Section Clarity
- The paper should clarify when moral foundations scores were actually computed on the transcripts (was this done fresh or did LocalView provide pre-computed scores?)
- The eMFD methodology section (page 13-14) is clear but could benefit from a brief discussion of validation studies for the dictionary.

### 8. Appendix Organization
The appendix is comprehensive (12 subsections, ~19 pages) with robust tables. However:
- Some tables have notes that appear cut off or oddly formatted
- The event study figure (A2/page 49) could use clearer axis labels

### 9. Discussion of Identification Threats
While parallel trends are discussed, the paper could strengthen discussion of:
- Potential SUTVA violations (spillovers across municipalities)
- Measurement error in broadband rates (ACS sampling error at small geographies)

---

## Items Done Well

1. **Comprehensive robustness checks:** Alternative thresholds, continuous treatment, Goodman-Bacon decomposition, heterogeneity analysis, placebo tests
2. **Modern DiD methods:** Proper use of Callaway-Sant'Anna estimator alongside TWFE
3. **Clear theoretical framework:** Three competing hypotheses are well-articulated
4. **Honest interpretation of null results:** Does not over-claim, discusses limitations thoughtfully
5. **Well-written prose:** Flows well, appropriate for top journal
6. **Extensive appendix:** Provides transparency and replicability

---

## Required Revisions Before Next Round

1. **[CRITICAL]** Fix all undefined table/figure references in main text
2. **[CRITICAL]** Include actual tables and figures in the main body (not just appendix)
3. Fix paper number (should be 0064 or whatever is next in sequence, not 0063)
4. Add brief discussion of SUTVA/spillovers
5. Ensure consistency in precision language for null results

---

## Verdict

The paper is close to being publication-ready. The research design is sound, the null result is interesting and well-documented, and the writing quality is high. The main issue is formatting - the missing table/figure definitions need to be fixed immediately. Once these issues are addressed, I would recommend ACCEPT with minor revisions.
