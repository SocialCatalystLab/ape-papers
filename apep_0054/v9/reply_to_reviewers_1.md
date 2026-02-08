# Reply to Reviewers

## Response to GPT-5-mini (MAJOR REVISION)

### Issue 1: Bullets in Introduction/Results
**Original concern:** Intro and Results use bullet lists; top journals require paragraph prose.

**Response:** All bullet lists in the Introduction and Results sections have been converted to flowing prose. The Introduction now presents results in connected paragraphs rather than itemized lists. The border decomposition section now uses prose to explain the level vs. change distinction.

### Issue 2: Wild Cluster Bootstrap
**Original concern:** With 17 state clusters, asymptotic inference may be unreliable.

**Response:** We have added wild cluster bootstrap inference using the fwildclusterboot package with Webb (6-point) weights, following MacKinnon & Webb (2017). Bootstrap p-values are computed for the main TWFE specification and sex-specific analyses. Code is in 04c_wild_bootstrap.R.

### Issue 3: Industry Heterogeneity
**Original concern:** Cannot test occupational heterogeneity due to QWI limitations.

**Response:** We now provide industry heterogeneity analysis at the state-quarter level. We classify industries into high-bargaining (Information, Finance, Professional Services, Management) and low-bargaining (Retail, Accommodation/Food, Healthcare) and test whether effects differ by bargaining intensity, as predicted by Cullen et al.'s commitment mechanism. Code is in 04d_industry_heterogeneity.R.

---

## Response to Grok-4.1-Fast (MAJOR REVISION)

### Issue 1: Section 4.4 Inconsistency
**Original concern:** The paragraph claiming "2% wage reduction 'buys' 1pp gender gap reduction" contradicts the null findings.

**Response:** This paragraph has been completely rewritten. The new text explains that the null findings on both margins make the equity-efficiency trade-off question moot for job-posting mandates in the short run.

### Issue 2: Bullets to Prose
**Response:** Addressed as described above.

### Issue 3: Missing References
**Original concern:** Suggested adding Kessler et al. (2024) and Menzel (2023).

**Response:** Both references have been added to the bibliography, along with Arnold (2022) on employer power.

### Issue 4: "Null" Repetition
**Original concern:** The word "null" appears too frequently.

**Response:** We have varied the language throughout, using alternatives such as "no detectable effect," "statistically insignificant," "zero effect cannot be rejected," and "consistent with no impact."

---

## Response to Gemini-3-Flash (MINOR REVISION)

### Issue 1: Wild Cluster Bootstrap
**Response:** Implemented as described above.

### Issue 2: Industry Heterogeneity
**Response:** Implemented as described above.

---

## Summary
All major concerns from the three reviewers have been addressed. The paper now:
1. Uses proper prose narrative throughout
2. Includes wild cluster bootstrap inference
3. Provides industry heterogeneity analysis
4. Fixes the Section 4.4 inconsistency
5. Adds suggested references
6. Reduces repetitive language
