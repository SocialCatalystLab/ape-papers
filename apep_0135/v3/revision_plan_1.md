# Revision Plan - Round 1

## Summary of Reviews

| Reviewer | Decision | Key Issues |
|----------|----------|------------|
| GPT-5-mini | MAJOR REVISION | Missing 95% CIs, pre-2012 placebo tests, migration data |
| Grok-4.1-Fast | MAJOR REVISION | Missing 95% CIs in main tables |
| Gemini-3-Flash | CONDITIONALLY ACCEPT | Excellent overall; suggests 2008 data and "horse race" with China shock |

## Critical Issues to Address

### 1. Missing 95% Confidence Intervals (All reviewers)
**Issue:** Tables report SEs but not explicit 95% CIs.
**Action:** Add 95% CIs to main tables (Tables 3, 5, 7) either in brackets or as separate columns.
**Priority:** HIGH - cited as "unpublishable without" by Grok

### 2. Pre-2012 Data (GPT, Gemini)
**Issue:** Cannot include 2008 election because technology data starts in 2010 (need 2007 for 2008 election).
**Action:** Add explicit note explaining this limitation. The 2012 baseline already serves as pre-Trump placebo.
**Priority:** MEDIUM - explain limitation clearly

### 3. Literature Gaps (All reviewers)
**Issue:** Missing de Chaisemartin & D'Haultfoeuille (2020), Sun & Abraham (2021), Dijkstra et al. (2020)
**Action:** Add to bibliography and cite in methods section.
**Priority:** MEDIUM

## Changes NOT Needed

1. **DiD methodology concerns:** Paper does NOT use staggered DiD - uses panel correlations with FE. Reviewers acknowledge this.
2. **Causal claims:** Paper explicitly disclaims causality - this is appropriate.
3. **China shock horse race:** Beyond scope of current revision; would require additional data.

## Implementation

1. Add 95% CIs to main regression tables
2. Add note about 2008 data limitation
3. Add missing citations to bibliography
4. Recompile PDF
