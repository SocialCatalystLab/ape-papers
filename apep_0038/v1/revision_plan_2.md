# Revision Plan - Round 2

## Summary of Reviewer Concerns

GPT 5.2 gave another **MAJOR REVISION** verdict, identifying these key issues:

### Critical Issues (Must Fix)
1. **Citation errors** - Stranahan & Borg (2004) is about scholarships not gambling; Humphreys & Marchand "Colorado" vs "Canada" mismatch
2. **Policy timing inconsistencies** - Tennessee listed as 2019 but launched late 2020; state counts vary across tables
3. **Placeholder values** - Table 1 has "1,234,567" which looks like placeholder
4. **NAICS 7132 too aggregated** - Cannot cleanly attribute to sports betting
5. **Annual vs quarterly** - Should use quarterly QCEW

### Methodological Gaps
6. **Missing DiD references** - Abadie (2005), Donald & Lang (2007), Conley & Taber (2011), Cengiz et al. (2019)
7. **No Rambachan-Roth bounds** - Mentioned but not implemented
8. **Confounding policies** - iGaming, casino expansions not addressed

### Presentation Issues
9. **Institutional background** - Too list-like, needs paragraph form
10. **Cohort counts inconsistent** - Tables 2/3/8 show different numbers

## Revision Strategy

### A. Fix Citation Errors (CRITICAL)
1. Remove Stranahan & Borg (2004) - wrong paper
2. Fix Humphreys & Marchand - clarify Canada study
3. Add missing methodology references (Abadie, Donald & Lang, Conley & Taber, Cengiz et al.)

### B. Fix Data Inconsistencies
1. Remove placeholder values (1,234,567)
2. Reconcile state counts: 34 treated vs 38 legalized - clarify DC + timing
3. Fix Tennessee cohort classification (2020 not 2019)

### C. Strengthen Limitations Discussion
1. More prominently acknowledge NAICS 7132 cannot isolate sports betting jobs
2. Acknowledge quarterly would be better, note this as limitation
3. Discuss iGaming/casino expansion confounds explicitly

### D. Add Missing References
- Abadie (2005)
- Donald & Lang (2007)
- Conley & Taber (2011)
- Cengiz et al. (2019)

### E. Improve Presentation
1. Rewrite institutional background into proper paragraphs
2. Ensure cohort tables consistent

## Implementation Priority

**Must do for Round 3:**
- Fix citation errors
- Fix placeholder values
- Reconcile state/cohort counts
- Add missing methodology references
- Expand limitations on NAICS 7132 measurement
- Acknowledge annual vs quarterly limitation

**Note for future:**
- Quarterly data would require re-running analysis
- Rambachan-Roth bounds ideal but complex to implement
- iGaming controls would need additional data
