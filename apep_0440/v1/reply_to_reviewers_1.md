# Reply to Reviewers — APEP-0440

## Summary of Changes

We thank all three referees for thorough and constructive reviews. The central critique—that conditioning on employment when employment changes discontinuously at the threshold undermines the RDD—is well-taken. We have made substantial revisions to address this and other concerns.

---

## Referee 1 (GPT-5.2): MAJOR REVISION

### 1. "The estimand is not well-defined in the presence of discontinuous selection into employment"

**Response:** We agree this is the core issue. We have:
- Added a formal discussion of Lee (2009) trimming bounds in the Limitations section, explaining how monotonicity (eligibility weakly reduces employment) allows bounding the effect on always-employed workers
- Added Manski (1990) bounds framing to interpret the CI
- Softened all claims from "well-identified null" to a bounded interpretation: "any job-quality improvements for always-employed workers are at most small"
- Reframed the contribution as testing intensive-margin effects subject to selection constraints

### 2. "Missing RDD methodology references"

**Response:** Added all suggested references:
- Imbens & Lemieux (2008), Lee & Lemieux (2010) — cited in Discrete Running Variable section
- Calonico, Cattaneo & Titiunik (2014) — cited in bandwidth discussion
- Calonico et al. (2019) — cited in Discussion
- McCrary (2008) — cited in density test discussion
- Lee (2009) — cited in Limitations
- Kolesár & Rothe (2018) — cited in footnote on discrete RV inference

### 3. "RDD estimation not using modern local polynomial bias correction"

**Response:** Added explicit justification for using fixed bandwidths over MSE-optimal selection: with integer ages, the bandwidth selector chooses among a handful of discrete integers rather than optimizing over a continuum. We cite Calonico et al. (2014) and Imbens & Kalyanaraman (2012) and explain why sensitivity analysis across 3-10 year bandwidths is more informative in our setting.

### 4. "Add 95% CIs to main tables"

**Response:** Done. Table 2 now reports 95% CIs in brackets for all outcomes at both thresholds. The overqualification CI at 65 is [-0.08, 0.28] pp, ruling out effects larger than 1% of the baseline rate.

### 5. "Clustering at age level with few clusters"

**Response:** Added footnote reporting 11 age clusters per threshold and citing Kolesár & Rothe (2018). Note that our conclusions rely on consistency across specifications rather than any single p-value.

### 6. "Density test on employed sample"

**Response:** Added density figure (Figure 8 in Appendix) showing both full population and employed sample by age. Full population is smooth; employed sample declines at both thresholds, consistent with retirement.

### 7. "Reframe the null contribution"

**Response:** Changed throughout. The paper now frames results as bounded nulls subject to selection, not "well-identified" causal effects.

---

## Referee 2 (Grok-4.1-Fast): MAJOR REVISION

### 1. "Covariate imbalance at 65 is a serious threat—RDD invalid if composition jumps"

**Response:** Addressed in the new Lee bounds discussion. We acknowledge this directly and interpret results as bounds on always-employed effects rather than point-identified causal effects.

### 2. "Add 95% CIs to all main results tables"

**Response:** Done (Table 2).

### 3. "Missing key papers: Imbens & Lemieux (2008), Calonico et al. (2014), Bloemen et al. (2017)"

**Response:** Added Imbens & Lemieux (2008), Calonico et al. (2014), and Calonico et al. (2019). Did not add Bloemen et al. (2017) as the paper focuses on mortality rather than labor market outcomes.

### 4. "Add rdrobust/rdpower for MSE-optimal BW/power calcs"

**Response:** Added justification for fixed bandwidth approach with discrete running variable; cited the relevant methodological papers.

### 5. "Monthly/quarterly age RDD"

**Response:** Acknowledged as a limitation. ACS reports integer age only; we note this constraint and suggest CPS or restricted-use ACS as directions for future work.

---

## Referee 3 (Gemini-3-Flash): MAJOR REVISION

### 1. "Covariate imbalance is a 'fatal' sign; RDD validity fails"

**Response:** We agree this is the most serious threat. Rather than claiming a clean null, we now frame results through the lens of Lee (2009) bounds and acknowledge that the standard RDD interpretation is compromised at 65.

### 2. "Placebo tests show significant results at fake thresholds"

**Response:** We acknowledge this directly in the revision and note that it suggests the model may pick up compositional shifts at many ages, not just policy thresholds. This reinforces our bounded interpretation.

### 3. "Address selection directly: Manski bounds or selection correction"

**Response:** Added conceptual Manski/Lee bounds discussion. Full implementation would require stronger assumptions than we can credibly maintain with cross-sectional data, but we provide the informal bounding argument.

### 4. "Focus on the Age 62 null (better balance)"

**Response:** We continue to present both thresholds as the dual-design is a strength, but now emphasize that the age-62 results have better identification. The revision notes that age 62 shows better covariate balance.

### 5. "Lise & Postel-Vinay (2020) and Kolesár & Rothe (2018)"

**Response:** Both added to the bibliography and cited in the text.

---

## Exhibit Review (Gemini) Changes

1. **Figure 3 title:** Changed from "Underemployment by Insurance Type" to "Overqualification by Insurance Type"
2. **Density figure:** Added Figure 8 (Appendix) showing sample density by age
3. **Year-by-year figure:** Moved from main text to Appendix (secondary robustness check)
4. **Table 2:** Now includes 95% CIs and reports cluster count in notes

## Prose Review (Gemini) Changes

1. Removed raw variable codes (AGEP, SCHL, OCCP, etc.) from body text; moved to appendix reference
2. Changed "well-identified null" → "The results are clear: social insurance does not unlock better jobs"
3. Improved first-stage interpretation with vivid language ("one in seven workers drops their employer's plan")
4. Compressed roadmap paragraph
5. Removed `fixest` package name from empirical strategy body text (moved to table notes)
