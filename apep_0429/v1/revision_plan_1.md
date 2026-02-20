# Reviewer Response Plan — Round 1

## Summary of Feedback

### Referee 1 (GPT-5.2): MAJOR REVISION
- Missing first-stage evidence (eligibility → actual road construction)
- Need joint test / multiple-testing framework for dynamic estimates
- Spatial correlation in nonparametric RDD
- Add CI columns to tables
- Better pre-trend explanation
- Missing references (Lee & Lemieux, McCrary, Romano-Wolf, Anderson)

### Referee 2 (Grok-4.1-Fast): MINOR REVISION
- Add Lee & Lemieux (2010) reference
- First-stage discontinuity plot (desirable)
- Heterogeneity by market access
- Tighten Discussion sentences

### Referee 3 (Gemini-3-Flash): CONDITIONALLY ACCEPT
- Add Ghani et al. (2016) reference
- Heterogeneity by electrification status
- Distance to cities interaction

### Exhibit Review
- Fix balance table labels (formal names)
- Add SDs to summary stats table
- Consider promoting balance figure to main text

### Prose Review
- Rewrite opening sentence (drop throat-clearing)
- Translate coefficients to % changes consistently
- Delete roadmap paragraph
- Improve results narration (less table-reading)

## Revision Plan

### Workstream 1: Prose Improvements
1. Rewrite opening paragraph with a hook
2. Delete roadmap sentence
3. Translate all asinh coefficients to % luminosity immediately after
4. Improve results narration (less "column X shows")

### Workstream 2: References
1. Add Lee & Lemieux (2010)
2. Add Ghani et al. (2016)
3. Add McCrary (2008)

### Workstream 3: Table Fixes
1. Fix balance table covariate labels to formal names
2. This is done via R code change in 06_tables.R

### Workstream 4: Acknowledge Reviewer Suggestions
1. Note first-stage limitation more prominently
2. Acknowledge joint-testing suggestion in text
3. Note spatial displacement as future work

### NOT Doing (infeasible without new data):
- PMGSY connection data / first-stage plot (requires OMMAS data not available)
- Fuzzy RDD / event-study by connection year
- Town-level spillover analysis
- Distance to nearest city interactions
- Electrification interactions
