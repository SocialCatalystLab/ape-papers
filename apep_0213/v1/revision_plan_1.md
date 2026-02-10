# Revision Plan — Round 1

## Summary of Reviewer Feedback

- **GPT-5-mini (R1):** MAJOR REVISION — Concerns about YRBS sampling error in state-aggregate analysis, limited first-stage evidence, need for time-varying controls and placebo outcomes, missing references, explicit 95% CIs.
- **Grok-4.1-Fast (R2):** MINOR REVISION — Fix Miller & Tucker bib year, add 3-4 references, formalize pre-trend Wald p-values, tighten Bacon paragraph.
- **Gemini-3-Flash (R3):** MINOR REVISION — Add 95% CIs to Table 2, discuss YRBS selection, discuss NVSS mortality data as extension, treatment intensity proxy.
- **Exhibit Review:** Reformat Table 3 (diagonal → column), reduce Figure 3 CI alpha, standardize Figure 4 x-axes, move Figure 5 to appendix, label appendix table.
- **Prose Review:** Trim roadmap, punchier results preview, active voice fixes, clarify "wrong direction" result.

## Planned Changes

### 1. References & Bibliography
- Fix Miller & Tucker bib year (2020 → 2011)
- Add: Roth et al. (2023), Athey & Imbens (2022), Conley & Taber (2011), Aronow & Samii (2017)
- Cite new references in relevant sections

### 2. Tables
- **Table 2:** Add explicit 95% CIs for primary outcomes
- **Table 3:** Reformat from diagonal to standard column layout (Female, Male, Criminal, School-Only)

### 3. Figures
- **Figure 3:** Reduce confidence interval alpha for better visibility
- **Figure 4:** Standardize x-axis limits across panels A-C
- **Figure 5:** Move to appendix

### 4. Paper Text Revisions
- **Sampling design discussion:** Add paragraph in Data section acknowledging that state-aggregate analysis doesn't account for within-state sampling variance, discuss WLS robustness and why aggregate approach is defensible (standard in literature, clustered SEs at state level with 40+ clusters)
- **ITT interpretation:** Make explicit in Strategy section that estimates are intent-to-treat
- **NVSS/mortality data:** Add to Discussion as natural extension/future work
- **Treatment intensity:** Discuss lack of enforcement/funding data as limitation
- **YRBS selection:** Address in Data section — near-universal participation among treated states
- **SA cohort composition:** Add explicit cohort counts and sizes
- **Trim roadmap paragraph** (p.5)
- **Active voice fixes** (RI section)
- **Clarify "wrong direction"** result more boldly
- **Label appendix treatment matrix** as Table A1
- **Punchier results preview** in introduction

### 5. Not Addressed (Infeasible)
- Individual-level YRBS microdata re-estimation (no access to restricted-use microdata)
- NVSS mortality data analysis (separate data infrastructure needed)
- Formal YRBS selection probability regression (no state-level participation outcome data)
- Bacon decomposition scatter plot (minor, text discussion sufficient)
