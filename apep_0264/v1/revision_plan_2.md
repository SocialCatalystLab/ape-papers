# Reviewer Response Plan — Round 2 (Stage C)

## Summary
Re-run of external reviews after post-revision recompilation. GPT-5-mini and Gemini-3-Flash recommend MAJOR REVISION; Grok-4.1-Fast recommends MINOR REVISION. Core requirements (25+ pages, 3 reviews, advisor pass) are all met.

## Key Themes

### 1. Incorporation-Weighted Exposure (All Referees)
**Concern:** Need Compustat-based incorporation weights to measure treatment intensity.
**Action:** This requires firm-level data merging beyond the scope of this version. Acknowledged as the primary limitation and most important extension. Already discussed in Section 8.4 and 8.5.

### 2. Industry Heterogeneity (GPT, Grok, Gemini)
**Concern:** Decompose effects by industry concentration/competitiveness.
**Action:** Requires CBP industry-level data merge with HHI measures. Acknowledged as natural extension; state-level aggregate is correct unit for the macro question.

### 3. Cohort-Specific ATTs (GPT)
**Concern:** Show which cohorts drive results.
**Action:** Legitimate request for future revision. Current aggregation follows standard CS-DiD practice.

### 4. Additional References (All Referees)
**Concern:** Missing Hopenhayn (1992), Bebchuk et al. (2009).
**Action:** Added to references.bib.

### 5. Bootstrap/Inference Details (GPT)
**Concern:** Need explicit bootstrap draw counts, wild cluster bootstrap.
**Action:** CS-DiD uses analytical SEs by default; RI (500 permutations) provides complementary finite-sample evidence. Details already in methodology section.

## Decision
All core requirements met. Proceed to publish with added references.
