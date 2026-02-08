# Reply to Reviewers - Round 1

We thank the reviewer for the thorough and constructive feedback. We have addressed all major concerns. Below we detail our responses to each point.

## Response to Critical Issues

### 1. Paper Length (14 pages → 25+)

**Addressed.** The revised paper is now 30 pages, including a new Related Literature section, expanded Institutional Background, new Robustness section, and an Appendix with additional tables.

### 2. Treatment Coding - Pre-2018 States

**Addressed.** We now:
- **Exclude Nevada entirely** from the main sample as always-treated (Section 3.4)
- **Code Delaware, Montana, Oregon** as treated in 2018 when they expanded from limited operations to full single-game wagering
- Add a robustness table (Table 7) testing sensitivity to alternative treatments of pre-Murphy states
- Explicitly frame our study as examining the post-Murphy "expansion" rather than initial legalization

### 3. Outcome Validity - NAICS 7132 Limitations

**Addressed.** We now include a detailed "Measurement Considerations" subsection (Section 4.2) that explicitly discusses:
- NAICS 7132 scope limitations (captures establishments, not all sports betting workers)
- Remote work attribution challenges
- Mobile sportsbook employment potentially coded elsewhere
- This measurement limitation is acknowledged in the Discussion (Section 8)

### 4. Spillovers/SUTVA Concerns

**Addressed.** We now:
- Discuss SUTVA threats explicitly in Section 5.2 (Threats to Identification)
- Add a "Border State Effects" robustness check (Section 7.4) testing for spillover contamination
- Find no evidence of differential pre-trends in border states

### 5. COVID Confounding

**Addressed.** We now include:
- Explicit discussion of COVID overlap in Institutional Background (Section 3.3)
- A full COVID sensitivity subsection (Section 7.1) with Table 5 showing results:
  - Main specification: ATT = 1,122
  - Excluding 2020: ATT = 1,045
  - Pre-COVID cohorts only: ATT = 1,287
- Results robust across all specifications

### 6. Missing Placebo Tests

**Addressed.** We now include Table 4 with explicit placebo tests on:
- Manufacturing (NAICS 31-33): null effect
- Agriculture (NAICS 11): null effect
- Professional Services (NAICS 54): null effect
- All placebos show no significant effects, supporting specificity of our findings

## Response to Methodological Issues

### 7. Annual vs. Quarterly Data

**Acknowledged as limitation.** We note that quarterly data would provide more precision but annual data is sufficient for our identification strategy given the policy variation. Future work could exploit quarterly timing.

### 8. Pre-Trends Sensitivity

**Addressed.** We now:
- Cite Roth (2022) on pre-test limitations (Section 2.3)
- Report wild cluster bootstrap p-values in addition to asymptotic SEs
- Discuss HonestDiD as an extension for future work

### 9. Literature Engagement

**Addressed.** We added a new Related Literature section (Section 2) with 15+ additional references including:
- Gambling economics: Grinols & Mustard (2006), Evans & Topoleski (2002), Cotti (2008), Humphreys & Marchand (2013)
- DiD methodology: Bertrand et al. (2004), Cameron & Miller (2015), Borusyak et al. (2024), Rambachan & Roth (2023)
- Sports betting: Baker et al. (2024)

## Summary of Changes

| Concern | Status | Location |
|---------|--------|----------|
| Paper length | Fixed (30 pages) | Throughout |
| Nevada handling | Fixed (excluded) | Section 3.4 |
| Pre-Murphy states | Fixed (robustness) | Section 3.4, Table 7 |
| NAICS limitations | Acknowledged | Section 4.2, Section 8 |
| Spillovers/SUTVA | Addressed | Section 5.2, Section 7.4 |
| COVID confounding | Addressed | Section 7.1, Table 5 |
| Placebo tests | Added | Table 4 |
| Literature | Expanded | Section 2 (new) |
| Inference | Improved | Wild bootstrap reported |

We believe these revisions substantially strengthen the paper and address all critical concerns raised by the reviewer.
