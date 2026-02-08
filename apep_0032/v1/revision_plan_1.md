# Revision Plan - Round 1

**Paper:** Compulsory Schooling Laws and Mother's Labor Supply
**Date:** 2026-01-19
**Based on:** Internal Review (review_cc_1.md)

---

## Priority 1: Critical Identification Issues

### 1.1 Implement Triple-Differences Design

**Problem:** Failed childless women placebo (-5.1 pp) suggests state-level confounding.

**Solution:** Implement triple-differences using childless women as within-state control:

```
Y_ist = β(Treated_st × SchoolAgeChild_i × Mother_i)
      + [all 2-way interactions]
      + [main effects]
      + State FE + Year FE + ε
```

**Interpretation:** β captures whether MOTHERS with school-age children in treated states increase LFP MORE than CHILDLESS women in those same states. This differences out state-level trends affecting all women.

**Code changes:** Modify `03_main_analysis.py` to add triple-diff specification.

### 1.2 Reframe Results Appropriately

If triple-diff works: Present as primary specification
If triple-diff fails: Reframe entire paper as descriptive analysis of correlations

---

## Priority 2: Missing Visual Evidence

### 2.1 Add Event Study Figure

**Problem:** Event study discussed but figure not included.

**Solution:** Include `figures/event_study.png` in the paper. Add LaTeX:
```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.8\textwidth]{figures/event_study.png}
\caption{Event Study: Effects by Years Since Law Adoption}
\label{fig:event_study}
\end{figure}
```

### 2.2 Add Pre-Trends Discussion

Explicitly discuss what the event study shows about parallel trends.

---

## Priority 3: Modern Econometric Methods

### 3.1 Acknowledge Staggered DiD Literature

Add paragraph discussing:
- Goodman-Bacon (2021) decomposition
- Sun & Abraham (2021) interaction-weighted estimator
- Callaway & Sant'Anna (2021)

### 3.2 Justify or Implement

Option A: Implement modern estimators
Option B: Argue why standard TWFE is appropriate here (e.g., limited treatment timing variation in analysis window)

---

## Priority 4: Paper Length and Completeness

### 4.1 Add PIH Test Results Section

Create new Section 5.5 "Tests of Permanent Income Hypothesis Predictions" with:
- Duration test results (by child age)
- Persistence test results
- Insurance test results (already partially in heterogeneity)

### 4.2 Expand Literature Review

Add discussion of:
- Added worker effect literature (Lundberg 1985, Stephens 2002)
- Credit constraints and consumption smoothing
- Historical female labor supply

### 4.3 Add Mechanism Section

New Section 6.X discussing:
- How did mothers actually enter the labor force?
- What occupations did they take?
- Geographic variation in labor market opportunities

---

## Priority 5: Data Clarifications

### 5.1 Fix Sample Description

**Problem:** Abstract says "IPUMS Full Count Census" but body says "1% samples"

**Solution:** Verify actual data used and correct description. Looking at code, it appears to use 1% samples. Update abstract to say "IPUMS census samples" not "Full Count Census."

---

## Implementation Order

1. **Data clarification** (5 min) - Fix abstract wording
2. **Add event study figure** (15 min) - Include existing figure in paper
3. **Triple-diff analysis** (30 min) - Implement in code, run, add results
4. **PIH tests section** (20 min) - Add new section with existing results
5. **Modern DiD discussion** (15 min) - Add paragraph acknowledging literature
6. **Expand literature** (20 min) - Add references and discussion
7. **Recompile and review** (10 min) - Visual QA

---

## Expected Outcome

If triple-diff shows positive and significant β:
- Paper strengthened considerably
- Can claim more credible identification

If triple-diff shows null:
- Reframe as descriptive analysis
- Emphasize correlations, not causation
- Still publishable but in different journals

---

## Files to Modify

1. `code/03_main_analysis.py` - Add triple-diff specification
2. `paper.tex` - Multiple sections
3. `paper.bib` - Add references (Goodman-Bacon, Sun-Abraham, etc.)
