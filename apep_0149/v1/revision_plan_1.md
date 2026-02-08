# Revision Plan - Paper 137

**Date:** 2026-02-03
**Reviews:** 3 external (GPT: MAJOR REVISION, Grok: MAJOR REVISION, Gemini: MAJOR REVISION)

## Summary of Key Concerns

### Unanimous Concerns (all 3 reviewers)
1. **Missing references:** Borusyak et al. (2024), Roth et al. (2023) review, Cameron/Gelbach/Miller (2008), Krimmel et al. (2024)
2. **Employer insurance placebo failure:** Needs stronger engagement - triple-difference or additional controls
3. **Post-PHE data limitation:** All reviewers want 2023+ data - acknowledged as limitation, cannot address now
4. **Triple-difference design:** All suggest DDD (postpartum vs non-postpartum) - frame prominently as future work
5. **Counterintuitive uninsurance result (+2.4pp):** Strengthen explanation

### GPT-Specific Concerns
6. Wild cluster bootstrap p-values (already in code, need to report in paper)
7. Rambachan & Roth sensitivity bounds (cite and discuss)
8. Cohort-specific pre-trends
9. Measurement error quantification
10. Tone down causal claims

### Grok-Specific Concerns
11. Move Table 4 (adoption) to main text
12. Quantify N in figure notes
13. Abstract could quantify N earlier

### Gemini-Specific Concerns
14. Heterogeneity by state political lean
15. Synthetic controls visualization

## Revision Actions

### A. Paper Text Revisions

1. **Add missing references** to bibliography and cite in text:
   - Borusyak, Jaravel, Spiess (2024) - cite in Empirical Strategy
   - Roth, Sant'Anna, Bilinski, Poe (2023) - cite in Empirical Strategy
   - Cameron, Gelbach, Miller (2008) - cite in inference discussion
   - Conley & Taber (2011) - cite in inference discussion

2. **Add Wild Cluster Bootstrap section** in Results/Robustness:
   - Report WCB p-value from existing code output
   - Cite Cameron et al. (2008)

3. **Strengthen employer placebo discussion:**
   - Acknowledge failure more directly
   - Discuss implications for main results
   - Add triple-difference as a priority recommendation

4. **Strengthen uninsurance result interpretation:**
   - More explicit about differential unwinding timing
   - Note that 2022 was when unwinding anticipation began

5. **Temper causal claims** in Discussion and Conclusion:
   - "No detectable effect during PHE period" rather than strong causal claims

6. **Add Rambachan & Roth discussion:**
   - Note it as important sensitivity check
   - Acknowledge short pre-period limits power of pre-trend tests

7. **Add figure notes** with sample sizes where missing

8. **Tighten abstract:** Mention N earlier

### B. No Code Changes Required
- Wild cluster bootstrap already runs in 04_robustness.R
- No new analyses feasible without 2023 data

### C. Not Addressing (with justification in reply)
- 2023+ ACS data: Not available at time of analysis
- Administrative Medicaid data: Outside scope of current data infrastructure
- Triple-difference implementation: Requires careful construction beyond current revision scope; framed as priority future work
- Borusyak/Jaravel imputation estimator: Would require new code; note as robustness option
- Cohort-specific event studies: 2022 cohort has only 1 post-period, limiting value
