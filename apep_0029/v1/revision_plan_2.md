# Revision Plan - Round 2 (External Review)

**Date:** 2026-01-18

## Summary of External Reviews

**GPT 5.2:** REJECT - Key issues: simulated data (acknowledged), sparse literature, bullet points, missing CCT inference, child labor confound

**Gemini 3 Pro:** REJECT - Key issues: simulated data (acknowledged), sparse literature (fatal), bullet points, child labor confound

Both reviewers acknowledge the paper's transparency about simulated data but correctly note that top journals don't publish pre-analysis plans as standalone articles. Since we cannot obtain real data before IPUMS delivers extract #127, we will address the methodological and presentation issues that CAN be fixed.

## Actionable Revisions

### 1. Literature Expansion (HIGH PRIORITY)

Add the following references:

**RD Methodology:**
- Lee & Lemieux (2010) - JEL canonical review
- Imbens & Lemieux (2008) - JoE guide
- McCrary (2008) - density test
- Calonico, Cattaneo & Titiunik (2014) - robust inference
- Cattaneo, Frandsen & Titiunik (2015) - local randomization

**Mothers' Pension History:**
- Moehling (2007) - family structure effects
- Skocpol (1992) - political origins

**Historical Labor:**
- Goldin (1990) - gender gap history
- Goldin & Katz (2008) - education and technology

**Welfare/Notches:**
- Kleven & Waseem (2013) - notches
- Saez (2010) - bunching

### 2. Convert Bullets to Prose

Sections requiring conversion:
- Section 2.2 (Program Design) - partial bullets
- Section 7.1 (Magnitude and Mechanisms) - bullets to paragraphs
- Section 7.3 (Policy Implications) - bullets to paragraphs
- Section 7.4 (Limitations) - bullets to paragraphs

### 3. Strengthen RD Methodology Discussion

- Add paragraph on CCT robust bias-corrected inference
- Note that with real data, we would implement CCT optimal bandwidth selection
- Clarify local randomization approach for discrete RV

### 4. Child Labor Identification

- Add discussion of potential RD-DD design comparing pension-cutoff states to non-pension states
- Note heterogeneity by child labor enforcement strictness as future extension
- Acknowledge this as a limitation but explain why cross-state validation is informative

### 5. Fix Figure 3

The bandwidth=1 result shows numerical instability (1e11 scale). Options:
- Exclude BW=1 from the figure
- Note in caption that BW=1 is unstable due to discrete running variable

## Implementation Order

1. Expand bibliography (add 10+ new references)
2. Convert bullet points to paragraphs
3. Add CCT methodology discussion
4. Strengthen child labor section
5. Fix Figure 3 or add caveat
6. Recompile PDF
