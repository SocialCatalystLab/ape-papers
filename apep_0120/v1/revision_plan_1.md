# Revision Plan — Paper 111

## Summary of External Review Feedback

All three reviewers issued **REJECT AND RESUBMIT**. There is strong consensus on the key weaknesses. Below I consolidate the concerns, assess feasibility within the current pipeline, and outline the revision.

---

## Consolidated Reviewer Concerns (by priority)

### 1. CRITICAL: Unemployment/Labor Market Controls Missing (All 3 reviewers)

**Concern:** The paper states unemployment rates were "unavailable due to an API issue." All reviewers call this unacceptable — BLS LAUS data is available from FRED or direct download.

**Action:** Fetch state-level unemployment rates from FRED (series LAUST##0000000000003 or similar), merge into panel, add as robustness control. Show main results hold with and without unemployment controls.

**Feasibility:** High. FRED API key is available. This is the single most damaging omission.

### 2. CRITICAL: Outcome Dilution / Need for Subgroup Analysis (All 3 reviewers)

**Concern:** Using state-level aggregate shares for ALL 18–34 year-olds severely dilutes any effect. Reviewers unanimously recommend ACS microdata (PUMS) to focus on exposed subgroups (non-college, low-wage, etc.).

**Action:** We cannot feasibly switch to PUMS microdata in this revision cycle — that would be a complete redesign. Instead:
- Add explicit **power analysis / MDE discussion** showing what effects we can and cannot detect
- Add **heterogeneity by age subgroup** using existing B09021 cells (18-24 vs 25-34)
- Reframe conclusions more carefully as "we cannot detect effects on the aggregate; subgroup analysis beyond our data's resolution"
- Add **population weighting** as robustness check

**Feasibility:** Medium. Age subgroup analysis and MDE discussion are feasible. Full PUMS redesign is not.

### 3. IMPORTANT: Missing Literature References (All 3 reviewers)

**Concern:** Missing key references: Borusyak-Jaravel-Spiess (2024), Roth et al. (2023) JEP/JEcma, Cameron-Gelbach-Miller (2008) wild bootstrap, Allegretto et al. (2017), Haurin-Hendershott-Kim (1993), Neumark-Wascher (2002), Mykyta-Macartney (2011), Clemens-Wither (2019), Meer-West (2016), Wooldridge (2021).

**Action:** Add all missing references to bibliography and cite appropriately in text.

**Feasibility:** High.

### 4. IMPORTANT: Treatment Definition Too Coarse (All 3 reviewers)

**Concern:** Binary "$1 above federal" is arbitrary. Should use continuous "bite" measure or dose-response with heterogeneity-robust methods.

**Action:** The paper already includes a TWFE continuous MW gap robustness check. Add discussion of limitations of binary threshold and why continuous treatment is only explored via TWFE (CS-DiD requires binary treatment). Add this as explicit limitation.

**Feasibility:** Medium. Better framing is feasible; implementing a full dose-response design is not.

### 5. IMPORTANT: Local Minimum Wages Not Addressed (All 3 reviewers)

**Concern:** Major cities (Seattle, SF, NYC) have local MWs above state levels, contaminating never-treated controls and creating measurement error.

**Action:** Add discussion of local MW contamination as limitation. Add robustness check excluding states with prominent local MWs (CA, WA, NY, CO, etc.).

**Feasibility:** High for discussion; medium for robustness check (requires identifying which states have local MWs).

### 6. IMPORTANT: HonestDiD Nonconvergence (R1, R2, R3)

**Concern:** "Did not converge" is not acceptable. Must fix or provide alternative sensitivity analysis.

**Action:** Attempt to fix HonestDiD with different settings (fewer event times, trimmed window). If still fails, implement Rambachan-Roth with smaller M-bar grid or alternative sensitivity bounds.

**Feasibility:** Medium.

### 7. IMPORTANT: Short Panel / Limited Contributing Cohorts (All 3 reviewers)

**Concern:** Only 16 states contribute to CS-DiD ATT. Reviewers suggest extending panel earlier (2010+).

**Action:** Extending the panel is feasible — ACS B09021 has been available since 2010. This would add more pre-treatment periods and include earlier cohorts. However, this is a major data restructuring. Instead, add clearer discussion of this limitation and provide leave-one-cohort-out sensitivity.

**Feasibility:** Low for panel extension; High for better framing and leave-one-cohort-out.

### 8. MODERATE: Wild Cluster Bootstrap for Regional Heterogeneity (R1, R3)

**Concern:** Regional subsamples have few clusters (12-17 states). Should use wild cluster bootstrap.

**Action:** Implement wild cluster bootstrap for regional heterogeneity results using `fwildclusterboot` R package.

**Feasibility:** Medium.

### 9. MODERATE: Population Weighting (R1, R2, R3)

**Concern:** Unweighted state-level estimates may not reflect national average impact. Should show population-weighted results.

**Action:** Add population-weighted CS-DiD results as robustness check.

**Feasibility:** High — population data is already in the ACS.

### 10. MODERATE: Professional Presentation (R2)

**Concern:** "Autonomously generated by Claude" disclosure is unprofessional for a scholarly submission.

**Action:** This is an APEP paper — the AI-generated disclosure is required by the project. No change needed.

**Feasibility:** N/A.

### 11. MODERATE: Reframe Null Result with MDE (R2, R3)

**Concern:** Conclusion "no meaningful effect" is too strong. Should present MDE and acknowledge power limitations.

**Action:** Add formal MDE calculation and reframe conclusion language.

**Feasibility:** High.

### 12. MODERATE: Joint Pre-trend Test (R2, R3)

**Concern:** Should report formal Wald/F-test for joint significance of pre-treatment event-study coefficients.

**Action:** Add joint pre-trend test to main analysis or appendix.

**Feasibility:** High.

---

## Revision Execution Plan

### Phase 1: Data & Analysis (R code changes)

1. **Fetch state unemployment rates from FRED** → merge into panel
2. **Add unemployment-controlled specifications** to main analysis and robustness
3. **Add population-weighted CS-DiD** as robustness check
4. **Add age subgroup analysis** (18-24 vs 25-34) using existing B09021 cells
5. **Add joint pre-trend test** (Wald test on pre-treatment coefficients)
6. **Attempt HonestDiD fix** or alternative sensitivity
7. **Add leave-one-cohort-out** analysis
8. **Exclude local-MW states** robustness check

### Phase 2: Paper Revisions (LaTeX)

1. Add all missing references (10+ new BibTeX entries)
2. Expand literature review sections
3. Add MDE/power discussion
4. Reframe conclusion language (more hedged)
5. Strengthen conceptual framework section
6. Improve discussion of treatment definition limitations
7. Add local MW contamination discussion
8. Update results sections with new analyses
9. Add new robustness rows to tables

### Phase 3: Compile & QA

1. Recompile PDF
2. Visual QA
3. Write reply_to_reviewers.md
