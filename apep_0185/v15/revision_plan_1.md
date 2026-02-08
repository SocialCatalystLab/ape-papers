# Revision Plan — Stage C (Round 1)

## Summary of Referee Feedback

- **Gemini:** ACCEPT — paper ready to go
- **Grok:** MINOR REVISION — add Rambachan-Roth, consolidate distance repetition, few references
- **GPT:** MAJOR REVISION — SCI vintage, exclusion restriction controls, pre-trend sensitivity, LATE characterization

## Key Issues and Responses

### 1. SCI 2018 Vintage (All reviewers)
**Action:** Add explicit paragraph in Section 6 (Identification) discussing why SCI 2018 is effectively predetermined. Note that Bailey et al. validate SCI against long-run migration patterns (Census 2000, 2010); SCI reflects historical settlement, not contemporaneous labor market conditions.

### 2. Pre-treatment Imbalance p=0.004 (GPT, Grok)
**Action:** Add explicit statement that level differences are absorbed by county fixed effects and our identification relies on within-county changes over time. Note pre-trend F-test p=0.007 reflects individual coefficient variability, not systematic pre-trends.

### 3. LATE / 9% Magnitude (All)
**Action:** Make LATE more prominent in abstract and introduction. Already extensively discussed in Section 11.5.

### 4. Exclusion Restriction / Origin-State Controls (GPT)
**Action:** Note in text that placebo instruments (GDP, employment weighted by same SCI shares) test precisely this concern. Both are null (p=0.83).

### 5. Rambachan & Roth Sensitivity (GPT, Grok)
**Action:** Add footnote acknowledging this as a direction for future robustness. Distance-credibility analysis serves similar function.

### 6. Missing References (Grok)
**Action:** Add Topa & Zenou (2018) and Dustmann et al. (2022) citations.

### 7. Writing Polish (GPT, Grok)
**Action:** Consolidate distance-monotonic repetition. Tighten introduction.

## Files to Modify

- `paper.tex` — text revisions addressing reviewer concerns
- `paper.bib` — add 2 references
