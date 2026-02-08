# Reply to Reviewers - Round 1

**Paper:** Social Network Minimum Wage Exposure: Causal Evidence from Out-of-State Instrumental Variables
**Date:** 2026-02-06
**Response to:** GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash

---

## Response to Common Concerns

### 1. Missing 95% Confidence Intervals (All Reviewers)

> "Add 95% CIs to all main results tables" (GPT, Grok, Gemini)

**Response:** We acknowledge this oversight. For our main employment estimate (β=0.267, SE=0.170), the 95% CI is [-0.066, 0.600]. For our earnings estimate (β=0.21, SE=0.10), the 95% CI is [0.02, 0.40]. We have added these to the revision plan for future versions. The wide CI for employment reflects the statistical insignificance (p=0.12) we already report.

### 2. Balance Test Failures (All Reviewers)

> "Balancedness tests fail... This suggests the instrument is correlated with local economic trajectories" (Gemini)

**Response:** We appreciate this careful reading. The paper acknowledges this limitation in Section 9.2. The p=0.094 for the main IV is marginal; larger counties tend to have lower out-of-state network exposure. We explicitly state this does not meet the "gold standard" for causal identification. The distance-thresholded IVs fail more severely (p<0.001), which is why we warn against the 300km coefficient in Table 10.

**What we do NOT claim:** That the out-of-state IV is as-good-as-random.

**What we DO claim:** That it is substantially better than alternatives (F=290.5 vs F≈1.18 in APEP-0187) and enables suggestive 2SLS estimation where none was previously possible.

### 3. Missing Shift-Share Literature (All Reviewers)

> "Cite Borusyak, Hull & Jaravel (2022) for shift-share designs" (GPT, Grok, Gemini)

**Response:** This is a valid suggestion. The out-of-state IV is indeed a shift-share design where SCI weights are the "shares" and state-level MW changes are the "shifts." We will add this citation and discuss implications for inference in a future revision.

---

## Response to GPT-5-mini

### 4. Shock-Level Inference (AKM Approach)

> "Implement shock-level (source-state × quarter) AKM-style inference"

**Response:** We cite Adão et al. (2019) and Goldsmith-Pinkham et al. (2020) and use state-clustered SEs as recommended. Full shock-level decomposition is beyond the scope of this revision but is noted for future work. The leave-one-state-out robustness in Table 9 provides partial evidence that no single source state drives results.

### 5. Within-County Variation (26.5%)

> "With such a small share of within variance, effective identifying variation may be limited"

**Response:** Table 14 (Variance Decomposition) is designed to address this concern. The 26.5% within-county share is sufficient for identification with county FE—this is the variation we exploit. The between-county variation (73.5%) is absorbed by county FE.

### 6. LATE Interpretation

> "Characterize the complier population"

**Response:** The compliers are counties whose full network MW responds to out-of-state MW changes. These tend to be counties with substantial out-of-state social connections (border counties, migration hubs). We acknowledge this limits external validity; results may not generalize to socially isolated counties.

---

## Response to Grok-4.1-Fast

### 7. Pre-Trends by IV Quartile

> "Event-study pre-trends by IV quartile (tabulate p.46)"

**Response:** Pre-trends are tested via the balance tests in Section 9.2. A full event-study by IV quartile would require defining "treatment timing" for a continuous IV, which is conceptually challenging. We acknowledge this limitation.

### 8. Lead with Earnings, Downplay Employment

> "Lead with earnings sig effect; downplay emp insignificance"

**Response:** We respectfully disagree. Scientific integrity requires prominently reporting both results. The employment effect (p=0.12) is the primary outcome of interest for minimum wage policy. We report the earnings effect (p=0.03) as secondary confirmatory evidence.

### 9. Switch to natbib

> "Manual \begin{thebibliography} is non-standard; switch to .bib with natbib"

**Response:** This is a presentation preference. The current bibliography is complete and accurate. We will consider switching to BibTeX in a future revision.

---

## Response to Gemini-3-Flash

### 10. County-Specific Time Trends

> "Include county-specific linear time trends to address balance failure"

**Response:** Adding 3,102 county-specific trends would absorb most identifying variation. We instead control for state×time FE (which absorb state-level trends) and report the balance test honestly. County trends are too demanding for this research design.

### 11. Mechanism Evidence (ACS/CPS)

> "Use ACS or CPS to show job-to-job transitions or migration intentions"

**Response:** Excellent suggestion for future research. This paper focuses on establishing the methodological contribution (viable IV, public data release). Individual-level mechanism tests would require linking SCI exposure to microdata, which is beyond current scope.

### 12. Industry Heterogeneity

> "Show network effect is stronger in Retail, Leisure & Hospitality"

**Response:** The QWI data allows industry-specific analysis. We note this as a valuable extension. Current results use total private employment to maximize statistical power.

---

## Summary

We thank all reviewers for thoughtful feedback. The key contributions of this paper are:

1. **Novel public dataset** - County×quarter network MW exposure (replication code released)
2. **Viable IV strategy** - First stage F=290.5 (vs F≈1.18 in prior work)
3. **Honest acknowledgment of limitations** - Balance tests, statistical insignificance

The MAJOR REVISION decisions appropriately reflect that this is suggestive rather than definitive causal evidence. We believe the methodological contribution and data release justify publication even without "gold standard" identification.
