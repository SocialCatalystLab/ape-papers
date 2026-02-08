# Revision Plan 1: Paper 184

## Summary of Referee Feedback

Two external referees reviewed the paper. GPT-5-mini recommended **Major Revision** and Grok-4.1-Fast recommended **Minor Revision**. Both referees agreed the paper asks an important question, uses a credible natural experiment, and is well-written. The key concerns centered on (1) missing citations and TWFE justification, (2) absence of confidence intervals in main tables, (3) inference robustness discussion, and (4) SUTVA/spillover treatment.

## Changes Made

### 1. Added Missing Citations (Both Reviewers)

- **Sun & Abraham (2021)**: Added to bibliography. Event study estimator robust to heterogeneous treatment effects. Journal of Econometrics.
- **Koster et al. (2019)**: Added to bibliography. Dutch housing supply regulations. Journal of Urban Economics.
- **Goodman-Bacon (2021)**: Already cited; verified present in bibliography.

### 2. TWFE Justification Paragraph (Both Reviewers)

Added a new paragraph in the Identification Assumptions subsection (Section 5.5) titled "Applicability of standard TWFE." This paragraph:
- Explains why standard TWFE is appropriate here: single common shock date (May 29, 2019), no staggered adoption
- Notes that the Goodman-Bacon decomposition does not produce "forbidden comparisons" in this design
- Acknowledges that heterogeneous dynamic responses across treatment intensities are theoretically possible
- Explains how the event study reference period approach and dose-response analysis address this concern
- Cites Sun & Abraham (2021), Goodman-Bacon (2021), de Chaisemartin & d'Haultfoeuille (2020), Callaway & Sant'Anna (2021), Koster et al. (2019), and Vermeulen & Rouwendal (2007)

### 3. Added 95% Confidence Intervals to Main Tables (Both Reviewers)

- **Table 2 (First-Stage: Building Permits)**: Added CI row showing [lower, upper] 95% CI for all four columns
- **Table 3 (Main Results: Housing Prices)**: Added CI row showing [lower, upper] 95% CI for all four columns
- Updated table notes to mention "95% confidence intervals in brackets"
- Updated table notes to state exact cluster count (342 clusters)

### 4. Strengthened Inference Discussion (GPT Reviewer)

Expanded the standard errors paragraph in Section 5.1 (Empirical Strategy) to:
- Note that 342 municipality clusters ensure well-behaved asymptotic inference
- List all clustering levels checked: municipality (342), COROP (40), province (12)
- Mention wild cluster bootstrap with 999 replications at province level
- Describe Conley spatial HAC standard errors with 50 km bandwidth
- State that exact cluster counts are reported in each table note
- Reference the full inference comparison in Table 10

### 5. Expanded SUTVA/Spillovers Discussion (GPT Reviewer)

Added a substantial new paragraph to the "Spillover Effects and General Equilibrium" subsection (Section 8.3) that:
- Reports the SUTVA assessment findings: low-N2000 municipalities show permit declines (not increases), inconsistent with displacement
- Notes statistical insignificance of permit changes in low-exposure municipalities
- Explains that the DiD estimates capture differential effects, not aggregate effects
- Discusses the caveat that if displacement occurred, the differential estimate would overstate the gap
- Connects to the national-level ASCM null result as evidence of offsetting local effects
- References Appendix Table A4 (SUTVA Assessment)

## Files Modified

- `paper.tex`: All changes above (bibliography, TWFE paragraph, CI rows, inference paragraph, spillovers paragraph)
- `revision_plan_1.md`: This file
- `reply_to_reviewers_1.md`: Point-by-point response
