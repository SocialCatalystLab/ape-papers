# Human Initialization
Timestamp: 2026-02-05T10:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-5

## Revision Information

**Parent Paper:** apep_0185
**Parent Title:** Social Network Minimum Wage Exposure: A New County-Level Measure Using the Facebook Social Connectedness Index
**Parent Decision:** MAJOR REVISION (GPT-5-mini, Grok-4.1-Fast) / REJECT AND RESUBMIT (Gemini-3-Flash)
**Parent Integrity Status:** SEVERE (27 flags, 2 CRITICAL)
**Revision Rationale:** Address critical code integrity issues plus reviewer concerns about lack of statistical inference and causal analysis

## Key Changes Planned

### Priority 1: Code Integrity Fixes (CRITICAL)
1. Fix DATA_FABRICATION flag in 01b_fetch_qcew.R - add documentation explaining quarterly proxy approach
2. Fix STATISTICAL_IMPOSSIBILITY in 03_main_analysis.R:118 - change SE=0 to SE=NA for reference year
3. Rename "Network Shift-Share DiD" to "Continuous Exposure Effects Design" (methodology mismatch)
4. Add DATA_SOURCES.md with machine-readable links to DOL, NCSL data
5. Fix selective reporting - report ALL lags, time windows, outcomes, clustering approaches
6. Change p-value format from "0.000" to "<0.001"

### Priority 2: Statistical Inference
7. Add 95% bootstrap CIs to all correlations (Table 2)
8. Add clustered SEs to group means (Tables 3-5)
9. Add explicit N to all tables
10. Add p-values for group differences

### Priority 3: Proof-of-Concept Causal Analysis
11. Add new Section 7: "Illustrative Application" using existing 03_main_analysis.R code
12. Include three-tier specification hierarchy
13. Include event study around 2015 with pre-trends test
14. Include industry heterogeneity (high-bite vs low-bite)

### Priority 4: Comprehensive Robustness
15. Add new Section 8: Report ALL robustness checks from 04_robustness.R
16. Report randomization inference (500 permutations)
17. Report leave-one-state-out (ALL major states)
18. Report ALL lag specifications (1, 2, 4 quarters)
19. Report BOTH time windows (pre-2020 AND post-2015)
20. Report ALL outcomes (employment, earnings, hiring)
21. Report BOTH clustering approaches (state AND network)

### Priority 5: Citations and Prose
22. Add missing methodological citations (Callaway & Sant'Anna, Goodman-Bacon, Sun & Abraham, Goldsmith-Pinkham et al., Adao et al.)
23. Convert bullet lists to narrative prose
24. Add "Data Limitations" subsection

## Original Reviewer Concerns Being Addressed

1. **GPT-5-mini:** "Lack of statistical inference and uncertainty quantification" -> Adding CIs/SEs to all descriptives
2. **GPT-5-mini:** "Important construction choices need stronger justification and sensitivity analyses" -> Comprehensive robustness section
3. **Gemini-3-Flash:** "Paper is purely descriptive...must conduct rigorous statistical inference" -> Adding inference + proof-of-concept analysis
4. **Gemini-3-Flash:** "Too many bullet points" -> Converting to narrative prose
5. **Grok-4.1-Fast:** "No inference on descriptives (CIs/SEs missing)" -> Adding bootstrap CIs
6. **Grok-4.1-Fast:** "Lit gaps on DiD/shift-share" -> Adding methodological citations
7. **Corpus Scanner:** "SEVERE verdict with 2 CRITICAL issues" -> Fixing code integrity issues first

## Inherited from Parent

- Research question: Network spillovers of minimum wage policy through social connections
- Identification strategy: SCI-weighted exposure measure with leave-own-state-out design
- Primary data source: Facebook SCI + State minimum wage histories
