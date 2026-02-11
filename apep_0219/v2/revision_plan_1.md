# Revision Plan — apep_0219 v2

## Parent Paper
- **Paper ID:** apep_0219
- **Title:** The Distress Label Trap: Place-Based Aid and Economic Stagnation in Appalachia
- **Rating:** mu=20.2, sigma=2.24, conservative=13.4

## Changes Made

### Critical Fix: Bibliography
- Replaced manual `\begin{thebibliography}` block with `\bibliography{references}` using natbib + aer.bst
- Added 5 missing BibTeX entries (bartik1991, cameron2008, hahn2001, austin2018, papke1994)
- Added Imbens & Lemieux (2008) RDD survey per reviewer request
- Fixed duplicate `fig:yearly` label
- Fixed broken `\thanks{}` macro in title
- Result: zero undefined references/citations in compiled PDF

### Substantive: Alternative Outcomes (Non-CIV)
- Added 3 alternative outcomes not mechanically linked to CIV assignment variable:
  - Log total wages & salaries (BEA CAINC5N): coef=-0.124, p=0.472
  - Log total personal income (BEA CAINC1): coef=-0.087, p=0.496
  - Population growth (Census intercensal): coef=0.260, p=0.577
- All null — reinforces main finding through independent data sources
- New Table 7 (alt outcomes) and Appendix Figure (RDD plots)

### Substantive: CIV Distribution Analysis
- Added CIV histogram figure near threshold (bin width=1)
- Confirms continuous running variable with no heaping
- New Figure 5 in main text

### Substantive: Year-by-Year McCrary Tests
- Ran density tests separately for each of 11 fiscal years
- 10/11 pass at 5% level; FY2017 marginal rejection (p=0.030) consistent with chance
- New Appendix Table (tab:mccrary_yearly)

### Substantive: FY2017 Exclusion Robustness
- Added sensitivity check excluding FY2017 (year with density test rejection)
- Results virtually identical: unemployment 0.010->0.008, log PCMI 0.012->0.011, poverty 0.095->0.102

### Internal Consistency Fixes (Advisor Feedback)
- Clarified sample counts: abstract now says "369 of the 420 Appalachian counties"
- Explained 4,600 vs 4,620 arithmetic gap (boundary adjustments FY2007-2008)
- Added Panel D (placebo thresholds) to robustness table
- Added effective N note to robustness table
- Qualified first-stage funding claims as back-of-envelope calculations
- Clarified robustness table bandwidth sensitivity specifications
- Added explicit 95% CIs to main results table

### Prose and Presentation
- Added revision footnote linking to parent paper
- Strengthened first-stage framing in introduction
- Updated outcome-assignment overlap discussion to reference new alternative outcomes
- Added Imbens & Lemieux (2008) citation in empirical strategy

## Review Results
- Advisor review: 3/3 PASS (Gemini rate limited)
- External review: 1 Major Revision, 2 Minor Revision
- All reviewers praised methodology as "exemplary" / "gold standard"
- Primary limitation flagged: lack of county-level grant disbursement data (acknowledged, FOIA required)
