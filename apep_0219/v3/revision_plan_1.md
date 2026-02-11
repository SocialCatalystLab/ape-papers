# Revision Plan — Stage C (Post-Review)

## Reviews Received

| Reviewer | Decision | Key Concerns |
|----------|----------|-------------|
| GPT-5-mini | MAJOR REVISION | First stage, pooling inference, heterogeneity |
| Grok-4.1-Fast | MINOR REVISION | Missing RDD canon cites, first stage desirable |
| Gemini-3-Flash | MINOR REVISION | First stage only significant hurdle |
| Internal (CC R1) | MINOR REVISION | County switching stats, ITT framing, Eggers cite |
| Internal (CC R2) | MINOR REVISION | Confirmed issues minor, fixable in revision |

## Changes Made

### 1. Added Missing RDD Canon Citations (All reviewers)
- Lee (2008), Eggers et al. (2018) now cited in Empirical Strategy section alongside Imbens & Lemieux (2008)
- Lee & Lemieux (2010) cited as canonical framework

### 2. Explicit ITT Framing (GPT, Internal)
- Added explicit intent-to-treat language in Results section before Table 3
- Cross-references Section 5.6 (Mechanisms) for first-stage limitation

### 3. County-Switching Statistics (Internal)
- Added paragraph in Data section: 83/369 counties (22%) switch status, 42 always Distressed, 244 never Distressed
- Motivates panel specification with year FEs

### 4. USAspending Exploration (All reviewers)
- Added mention of USAspending.gov (CFDA 23.002) exploration in Mechanisms section
- Documented partial coverage (FY2008-2015) and data quality limitations
- Strengthens honest engagement with first-stage limitation

### 5. Section Label for Cross-Referencing
- Added \label{sec:mechanisms} to Mechanisms subsection for internal cross-references

## Changes NOT Made (and why)

### First Stage / Fuzzy RDD (All reviewers)
- The USAspending data covers only 8 of 11 sample years and doesn't distinguish Distressed-targeted grants
- A formal first stage with incomplete coverage would be misleading
- The limitation is thoroughly discussed in Sections 5.6 and 6.2
- This is the paper's acknowledged primary limitation

### Randomization Inference (GPT)
- Adds marginal value given the already comprehensive robustness battery
- Would require additional computation without changing conclusions
- Can be added in future revision if requested by editor

### Spatial Spillovers (Gemini)
- Interesting extension but beyond scope of current revision
- Noted for future research

### Coal Dependence Heterogeneity (Grok, Gemini)
- Central Appalachia subgroup analysis already in Section 5.3 proxies for this
- County-level coal dependence data not readily available for the sample period
