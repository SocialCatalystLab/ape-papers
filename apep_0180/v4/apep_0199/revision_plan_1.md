# Revision Plan 1 — Addressing Referee Feedback

## Summary of Reviews

| Reviewer | Decision | Key Concerns |
|----------|----------|-------------|
| GPT-5-mini | MAJOR REVISION | Covariance estimation, non-recipient FE, WTP>1, randomization inference |
| Grok-4.1-Fast | MINOR REVISION | 3 missing references, minor polish |
| Gemini-3-Flash | MINOR REVISION | Bullet list in 4.1, welfare weights, non-recipient FE |

## Planned Changes

### 1. Convert Section 4.1 bullet list to prose (Gemini)
- Replace `\itemize` list of three calibration sources with flowing paragraphs

### 2. Add non-recipient fiscal externalities as robustness (GPT, Gemini)
- Compute MVPF including VAT/income tax on non-recipient consumption/earnings gains
- Present as alternative specification in Table 5 or new table
- This reduces net cost further, increasing MVPF

### 3. Add welfare weights discussion (Gemini, GPT)
- Add paragraph discussing distributional MVPF under CRRA utility
- Note that UCT recipients are much poorer than average taxpayer, so social MVPF > private MVPF

### 4. Add WTP>1 sensitivity (GPT)
- Add row to sensitivity table showing MVPF under WTP = 1.1 and WTP = 1.2
- Brief paragraph noting credit constraint interpretation

### 5. Strengthen covariance assumption justification (GPT)
- Note that zero-covariance is conservative (positive correlation tightens CIs)
- Already show sensitivity with ρ = 0.25 and 0.50
- Add note that microdata are available at Harvard Dataverse for replication

### 6. Add missing references (all reviewers)
- Olken & Singhal (2011) on informal taxation
- Add 1-2 additional references from reviewer suggestions

### 7. Minor prose polish
- Tighten causal language ("the estimate under X assumptions is 0.88" rather than definitive)
- Ensure consistent PPP year labeling
