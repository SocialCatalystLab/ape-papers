# Reviewer Response Plan

## Grouped Concerns and Revisions

### 1. Compound Treatment / Estimand Clarity (GPT #1, Gemini #3)
**Action:** Reframe throughout to be more precise. The estimand is the "effect of the 1,000-inhabitant electoral regime change" which bundles parity + proportional representation. Add a clarifying paragraph in the Introduction and tighten language throughout.

### 2. Add 95% CIs to Table 2 (GPT)
**Action:** Add CI columns to Table 2 (main results) using robust bias-corrected CIs from rdrobust.

### 3. Add Missing References (GPT, Grok, Gemini)
**Action:** Add Imbens & Lemieux (2008), Calonico, Cattaneo & Titiunik (2014), Pande (2003). These are the most important missing references.

### 4. Treatment Intensity Discussion (Gemini #2)
**Action:** Add a paragraph in Mechanisms discussing whether the 2.7pp first stage is too small to generate detectable downstream effects.

### 5. Prose Improvements (Prose review)
**Action:** Already applied opening hook, "It is worth noting" removal, punchier conclusion. Done.

### 6. Exhibit Improvements (Exhibit review)
**Action:** The exhibits were rated "exceptional quality." Main suggestion was to consolidate Figures 2&3 into panels — defer as optional polish.

## Execution Order
1. Add CIs to Table 2 (code change + rerun)
2. Add references to .bib
3. Reframe estimand language in paper.tex
4. Add treatment intensity paragraph
5. Recompile and verify
