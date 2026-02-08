# Revision Plan

## Summary of Reviews

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| Gemini-3-Flash | Conditionally Accept | Add theoretical literature on geographic sorting |
| Grok-4.1-Fast | Minor Revision | Add 95% CIs, additional references |
| GPT-5-mini | Major Revision | Power calculations, measurement validation, soften claims |

## Priority 1: Address All Reviewers

### 1.1 Add 95% Confidence Intervals
**All three reviewers request explicit CIs.**

Action: Add 95% CIs to Tables 3, 4, 5, 6, 7 for main coefficients.

### 1.2 Add Missing References

**Gemini suggests:**
- Iversen & Soskice (2019) on advanced capitalism and sorting

**Grok suggests:**
- Chetty et al. (2014) on geographic sorting/mobility
- Autor (2019) AER Insights on work disappearing
- Kuziemko et al. (2021) on partisan gaps/education

**GPT suggests:**
- Lee & Lemieux (2010) on RDD methodology
- McCrary (2008) on manipulation tests
- Imbens & Kalyanaraman (2012) on bandwidth selection

Action: Add all 7 references to bibliography and cite appropriately.

## Priority 2: Methodological Improvements

### 2.1 Power Calculations (GPT)
Add formal power analysis showing minimum detectable effect (MDE) for within-CBSA and gains specifications.

Action: Calculate MDE with 80% power, report in text.

### 2.2 Measurement Validation (GPT)
Show correlations between modal age and other technology proxies.

Action: Add correlation table or discussion in appendix.

### 2.3 Soften Causal Claims (GPT)
Reframe null result as "evidence inconsistent with large causal effects" rather than definitive refutation.

Action: Revise conclusion language.

## Priority 3: Presentation Improvements

### 3.1 Tighten Introduction (GPT)
Consolidate key tests and interpretations into single crisp paragraph.

### 3.2 SE Reporting Consistency (GPT)
Ensure all tables consistently report clustered SEs.

## Implementation Order

1. Update R code to calculate and output 95% CIs
2. Add power calculation section
3. Add references to bibliography
4. Revise paper text (claims softened, new citations)
5. Recompile and verify

## Files to Modify

- `code/05_tables.R` - Add CI columns
- `references.bib` - Add 7 new references
- `paper.tex` - Revise text, add citations, add power discussion
