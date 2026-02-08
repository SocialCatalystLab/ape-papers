# Revision Plan — Paper 178

## Review Summary
- GPT-5-mini: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MAJOR REVISION

## Priority Fixes (All Reviewers)

### 1. Add Missing References (All 3 reviewers)
- Acquisti et al. (2016) — economics of privacy survey
- Goldfarb & Tucker (2011) — privacy regulation and online advertising
- Peukert et al. (2023) — privacy legislation and digital advertising market structure
- Miller & Tucker (2009) — HIPAA and technology diffusion
- Athey & Imbens (2017/2022) — design-based DiD inference

### 2. Add 95% CIs to Table 2 (GPT, Grok)
- Report confidence intervals for main ATT estimates alongside SEs

### 3. Strengthen RI / Small-Sample Inference Discussion (GPT, Gemini)
- Increase RI permutations from 500 to 1000
- Be explicit that RI p-values are preferred for inference with few treated clusters
- Add discussion comparing asymptotic vs RI inference

### 4. Address California Dependence (All 3)
- Be more explicit that much identification comes from CA
- Consider DDD (tech vs non-tech within treated states) as additional robustness
- Note that more post-treatment data from 2024-2025 cohorts will sharpen estimates

### 5. Expand Discussion Section (GPT, Gemini)
- Broaden discussion of alternative interpretations
- Link "Brussels Effect" more explicitly to results
- Discuss external validity more carefully

### 6. Trim Repetition (Grok)
- Reduce "only eight states" to 2-3 mentions max (Intro + Data)

## Implementation (Feasible within current scope)

1. Add 5 new bibliography entries
2. Add CIs to Table 2 panel text
3. Increase RI to 1000 permutations, re-run
4. Expand Discussion section (~1 page)
5. Trim repetitive phrasing
6. Write reply_to_reviewers.md
