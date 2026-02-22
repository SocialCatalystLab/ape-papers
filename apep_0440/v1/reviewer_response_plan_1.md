# Stage C Revision Plan — APEP-0440

## Summary of Referee Feedback

All 3 referees recommend MAJOR REVISION. Key concerns cluster around:

### 1. Identification / Selection (ALL 3 referees)
- Conditioning on employment when employment changes at the threshold invalidates the RDD
- Need to redefine estimand or adopt selection-robust framework (Lee 2009 bounds)
- Covariate imbalance at 65 is "fatal" for standard RDD interpretation

### 2. Missing RDD References (ALL 3)
- Imbens & Lemieux (2008), Calonico et al. (2014), Lee & Lemieux (2010)
- Lee (2009) bounds, McCrary (2008), Kolesár & Rothe (2018)

### 3. Confidence Intervals (GPT, Grok)
- Add 95% CIs to all main result tables

### 4. Framing (ALL 3)
- "Well-identified null" is too strong given threats
- Soften claims to match what the design can identify

### 5. Few-Cluster Inference (GPT)
- Report number of clusters, discuss implications

### 6. Prose Polish (Prose Review)
- Remove variable codes from body text
- Fix "well-identified null" language
- Improve first-stage interpretation
- Shorten roadmap paragraph

### 7. Exhibit Improvements (Exhibit Review)
- Fix Figure 3 title ("Underemployment" → "Overqualification")
- Add density figure
- Move year-by-year figure to appendix

---

## Planned Changes

### A. References (references.bib)
Add: Imbens & Lemieux 2008, Calonico et al. 2014, Lee & Lemieux 2010, Lee 2009,
McCrary 2008, Kolesár & Rothe 2018, Lise & Postel-Vinay 2020

### B. Paper.tex — Identification & Selection
1. Add new subsection in Discussion: "Selection Into Employment and Bounds"
   - Discuss Lee (2009) bounds conceptually
   - Frame the null as bounded: selection reduces employment ~3.5pp; monotonicity implies the always-employed show at most X pp effect
   - Cite Lee 2009, Manski 1990
2. Soften "well-identified null" throughout (Introduction, Conclusion)
3. Add discussion of few-cluster issue (Empirical Strategy)
4. Add rdrobust/CCT citation and explanation of why we use feols

### C. Paper.tex — Prose
1. Remove raw variable codes (AGEP, SCHL, OCCP, etc.) from body text
2. Rewrite "well-identified null" → "The results are clear: social insurance does not unlock better jobs"
3. Improve first-stage interpretation with more vivid language
4. Compress roadmap paragraph
5. Fix "self-congratulatory" tone in results

### D. Tables (06_tables.R)
1. Add 95% CIs to Table 2 (main results)
2. Report number of clusters in table notes

### E. Figures
1. Fix Figure 3 title in paper.tex
2. Add density figure (simple histogram of observations by age)
3. Move year-by-year figure to appendix

### F. R Code
1. Add density figure generation to 05_figures.R
2. Add CI columns to 06_tables.R

---

## Execution Order
1. Add references to .bib
2. Modify 05_figures.R (density figure)
3. Modify 06_tables.R (CIs)
4. Run R scripts
5. Edit paper.tex comprehensively
6. Recompile PDF
7. Write reply_to_reviewers_1.md
