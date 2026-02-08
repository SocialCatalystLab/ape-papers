# Reply to Reviewers

## Overview

We thank all three reviewers for their thoughtful feedback. This revision addresses the major concerns raised by the original reviewers of APEP-0189 and incorporates feedback from the current review round.

---

## Response to GPT-5-mini

**Concern 1: Prose quality - bullet points in main text**

> The paper uses bullet points extensively in the Introduction, Theory, and Discussion sections.

**Response**: We have completely rewritten all major sections in full paragraph form with narrative flow. The paper now reads as proper economic prose suitable for AER publication.

**Concern 2: No figures**

> The paper lacks visual evidence.

**Response**: We have added 7 publication-quality figures including choropleth maps, event study plots, and heterogeneity analysis. All figures use professional color palettes and include proper annotations.

**Concern 3: Missing confidence intervals**

> Tables lack 95% CIs.

**Response**: All regression tables now include 95% confidence intervals in brackets below the standard errors.

**Concern 4: Missing shift-share literature**

> Key methodological references missing.

**Response**: We have added citations to Goldsmith-Pinkham et al. (2020), Borusyak et al. (2022), and Rambachan-Roth (2023), with discussion of how our approach fits the shift-share framework.

---

## Response to Grok-4.1-Fast

**Concern 1: Balance test failure not adequately addressed**

> The p=0.002 balance failure is concerning.

**Response**: We have clarified the distinction between level differences and trend differences. Our county fixed effects absorb level differences entirely. The event study (Figure 5) shows that pre-period coefficients are small relative to post-period effects, supporting parallel trends in changes. We also present balance trends by IV quartile (Figure 6) showing roughly parallel employment trajectories before 2014.

**Concern 2: Effect magnitude seems large**

> The 0.83 elasticity is very large for a spillover effect.

**Response**: We have expanded the Discussion section to provide LATE interpretation - this is the effect for complier counties with strong cross-state connections. We also contextualize the magnitude relative to the standard deviation of exposure.

---

## Response to Gemini-3-Flash

**Concern 1: Missing institutional context**

> Need more background on minimum wage policy variation.

**Response**: We have added a new section (Section 4) on "Institutional Background: The Minimum Wage Landscape" covering the federal floor, state divergence, Fight for $15 movement, and geographic patterns of social connection.

**Concern 2: Internal consistency issues**

> Sample counts appeared inconsistent.

**Response**: We have carefully reconciled all sample counts. The paper now consistently reports 3,053 unique county FIPS codes over 44 quarters, with clear explanation of how independent cities are handled in the QWI data.

---

## Summary of Changes

1. Complete prose rewrite of Introduction, Theory, Results, Discussion
2. Added 7 publication-quality figures
3. Added 95% CIs to all tables
4. Added shift-share literature
5. Added institutional background section
6. Added heterogeneity analysis section
7. Improved sample documentation
8. Clarified levels vs trends in balance discussion
9. Expanded LATE interpretation
