# Revision Plan 5 - Addressing Round 4 External Reviews

## Round 4 Feedback Summary

### GPT 5.2 (REJECT)
1. **TWFE still not acceptable** - Must implement CS/SA or similar
2. **Event study misinterpreted** - "Negative event time" ≠ "pre-treatment"
3. **16 clusters insufficient** - Wild bootstrap mentioned but not shown
4. **Missing references** - Rambachan & Roth 2023, Conley & Taber 2011, MacKinnon & Webb 2017

### Gemini 3 Pro (MAJOR REVISION)
1. **Sample restriction unacceptable** - "3.2M obs trivial for modern computing"
2. **Must implement SCM/SDiD** - "Methodologically negligent to identify solution but refuse to implement"
3. **Missing references** - Sorensen et al. 2022, Aizer & Doyle 2015

---

## Core Critique

Both reviewers agree: **The paper identifies the problem (parallel trends fails) and suggests a solution (SCM) but refuses to implement it.** This is intellectually incomplete.

---

## Revision Strategy: Implement Synthetic Control

Given reviewer consensus, we will implement Synthetic Control Method (SCM) to attempt to construct valid counterfactuals for early-ban states.

### Implementation Plan

**Step 1: State-Level Data Aggregation**
- Aggregate individual-level ACS data to state-by-birth-cohort cells
- Outcome: Mean years of education by (state, birth_cohort)
- This reduces the unit of analysis from 3.2M individuals to ~800 state-cohort cells

**Step 2: Synthetic Control for Massachusetts (1971)**
- Treated unit: Massachusetts
- Donor pool: Never-ban states
- Pre-treatment period: Birth cohorts 1950-1965 (schooled before 1971)
- Post-treatment period: Birth cohorts 1966-1990 (schooled after 1971)
- Match on: Pre-treatment education levels by cohort

**Step 3: Report Results**
- Synthetic Massachusetts vs. Actual Massachusetts plot
- Placebo tests (in-time and in-space)
- Gap estimates with permutation-based inference

**Step 4: Interpret**
- If SCM achieves balance → Report causal estimate
- If SCM fails to achieve balance → Stronger negative result

---

## New Analysis Code

Create `code/04_synthetic_control.py`:
- Uses `SyntheticControlMethod` from causalimpact or manual implementation
- State-level aggregation
- Pre/post treatment comparison

---

## Additional Revisions

1. **Add missing references**:
   - Rambachan & Roth (2023)
   - Conley & Taber (2011)
   - MacKinnon & Webb (2017)
   - Sorensen et al. (2022)
   - Aizer & Doyle (2015)

2. **Reframe event study discussion** to address "negative event time ≠ pre-treatment" critique

3. **Add SCM results section** (Section 4.5)

4. **New Figure 3**: Synthetic Control plot for Massachusetts

---

## Implementation Order

1. Create synthetic control analysis script
2. Run analysis to generate results
3. Add results to paper (new section, new figure)
4. Add missing references
5. Recompile and visual QA
