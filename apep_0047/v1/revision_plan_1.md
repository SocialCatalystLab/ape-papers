# Revision Plan - Round 1

**Date:** 2026-01-21
**Responding to:** GPT 5.2 Review (REJECT AND RESUBMIT)

## Critical Issues to Address

### 1. Inference Problem (HIGHEST PRIORITY)
**Reviewer concern:** Treatment varies at industry level (19 industries), but we cluster at state-industry level, leading to implausible t-stat of -30.

**Fix:**
- Add industry-level clustering as default in main tables
- Implement wild bootstrap with industry clusters
- Report CR2 small-sample corrections
- Add randomization inference permuting high/low harassment labels

### 2. Inconsistent Treatment Definition
**Reviewer concern:** Paper refers to "five high-harassment industries" but median split gives ~9-10.

**Fix:**
- Standardize to median split (creates ~9-10 treated industries)
- Update all prose to match
- Rebuild Table 3 (industry classification) to be consistent

### 3. Missing DiD Methodology References
**Reviewer concern:** Missing Bertrand-Duflo-Mullainathan, Goodman-Bacon, Callaway-Sant'Anna, Moulton, etc.

**Fix:**
- Add 7 key methodology references to bibliography
- Add discussion acknowledging grouped regressor issue (Moulton 1990)
- Reference modern DiD literature in methods section

### 4. Mechanism Evidence
**Reviewer concern:** Pence Effect is asserted but not directly tested.

**Fix:**
- Add qualifying language ("consistent with," "suggestive")
- Discuss limitations of mechanism identification
- Add discussion of alternative explanations

### 5. COVID-era Concerns
**Reviewer concern:** COVID disproportionately affected high-harassment industries.

**Fix:**
- Show separate event studies for pre-COVID (2014-2019) and full sample
- Add more explicit sample definitions

## Changes to Make

### References (references.bib)
Add the following entries:
- Bertrand, Duflo, Mullainathan (2004) QJE
- Goodman-Bacon (2021) JoE
- Sun & Abraham (2021) JoE
- Callaway & Sant'Anna (2021) JoE
- Cameron & Miller (2015) JHR
- Moulton (1990) REStat

### Methods Section (05_methods.tex)
- Add paragraph on inference challenges with few clusters
- Reference Moulton and Cameron-Miller
- Discuss industry-level clustering approach

### Results Section (06_results.tex)
- Add industry-clustered inference to main results
- Present both clustering approaches transparently

### Robustness Section (07_robustness.tex)
- Expand inference robustness with industry-level clustering
- Add leave-one-industry-out analysis

### Introduction/Conclusion
- Soften mechanism claims
- Use "consistent with" language
