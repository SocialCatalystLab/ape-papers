# Revision Plan: apep_0168 → apep_0169

**Parent:** apep_0168 (revision of apep_0167)
**Title:** Shining Light on Nothing? Null Effects of Salary Transparency Laws on New Hire Wages

## Reviewer Verdicts (Parent Paper)

| Reviewer | Decision | Primary Concerns |
|----------|----------|------------------|
| GPT-5-mini | MAJOR REVISION | Small-cluster inference, MDE/power, concurrent policies |
| Gemini-3-Flash | REJECT AND RESUBMIT | Bullets in prose, McCrary test, pre-trend sensitivity |
| Grok-4.1-Fast | MINOR REVISION | Missing refs, occupation heterogeneity, cosmetic issues |

## Changes Implemented

### 1. Prose Overhaul (Gemini's Critical Concern) ✓

Converted all bullet-style sections to flowing academic prose:
- Section 2.1 (Policy Setting): Integrated policy dimensions into coherent paragraphs
- Section 2.2 (Mechanisms): Rewrote as narrative prose with proper transitions
- Section 3 (Conceptual Framework): Removed structural bolding, improved flow
- Section 8 (Discussion): All subsections converted to paragraph form
- Section 9 (Conclusion): Streamlined concluding arguments

### 2. Remove Excessive "NULL" Bolding ✓

Replaced 10+ instances of bold "NULL" with varied professional language:
- "statistically insignificant"
- "indistinguishable from zero"
- "no detectable effect"
- Updated all tables (Tables 2, 4, 5) with professional terminology

### 3. Add Power Analysis and MDE Calculations (GPT's Critical Concern) ✓

Created new script `04e_power_analysis.R`:
- Computed MDE at 80% power: 3.9% (given SE = 0.014)
- Added MDE discussion to abstract and Discussion section
- Documented that null is informative, not underpowered

### 4. Add Rambachan-Roth Sensitivity Analysis ✓

Added to `04_robustness.R`:
- Implemented pre-trend sensitivity check
- Maximum pre-trend is ~3.4% (126% of bias needed to overturn null)
- Conclusion: Results robust to plausible parallel trends violations

### 5. Add Missing Citations ✓

Added to bibliography:
- McCrary (2008) - manipulation test methodology
- Lee & Lemieux (2010) - RDD in economics
- Sant'Anna & Zhao (2020) - doubly robust DiD
- Athey & Imbens (2018) - state of applied econometrics
- Imbens & Lemieux (2008) - RDD guide to practice

Integrated citations into empirical strategy section.

### 6. Minor Fixes ✓

- Updated title footnote to reference apep_0168 (not apep_0167)
- Removed bold emphasis from abstract
- Fixed table caption inconsistencies

## Review Results (This Revision)

| Reviewer | Decision |
|----------|----------|
| GPT-5-mini | MAJOR REVISION |
| Gemini-3-Flash | MINOR REVISION (improved from REJECT AND RESUBMIT) |
| Grok-4.1-Fast | MINOR REVISION |

## Files Modified

1. **paper.tex** - Major prose revisions, citations, MDE discussion
2. **04_robustness.R** - Added Rambachan-Roth sensitivity analysis
3. **04e_power_analysis.R** (new) - MDE calculations
4. **initialization.md** - Revision metadata
