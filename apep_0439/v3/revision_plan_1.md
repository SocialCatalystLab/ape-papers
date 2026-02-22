# Revision Plan 1: apep_0439 v2 -> v3

**Paper:** Where Cultural Borders Cross: Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy

**Reviews received:**
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: ACCEPT
- Exhibit Review (Gemini): Constructive feedback on figures/tables
- Prose Review (Gemini): Constructive feedback on writing
- Advisor (Gemini): FAIL (2 fatal errors)

---

## Priority 1: Fatal Errors (Must Fix)

### F1. Figure 3 missing left panel (language permutation distribution)
**Source:** Advisor Gemini (Fatal Error 1)
**Issue:** Text and caption claim Figure 3 shows permutation distributions for both the "language effect (left)" and "interaction (right)." Only the interaction panel is displayed. The language panel is missing.
**Fix:** Update the R code to produce a two-panel figure: left = language coefficient permutation distribution, right = interaction permutation distribution. Ensure the figure caption matches the content.

### F2. Unexplained N drop in Table 2 Column 6
**Source:** Advisor Gemini (Fatal Error 2)
**Issue:** Columns 1--5 report N=8,727 but Column 6 (with municipality controls) reports N=8,723. The loss of 4 observations is unexplained.
**Fix:** Either (a) investigate data and add a table note explaining which municipalities lack eligible-voter/turnout data, or (b) impute/fix the missing control data to maintain N=8,727 across all columns.

---

## Priority 2: Clearly Actionable Improvements

### A1. Table 6 formatting issues (scientific notation, truncation)
**Source:** Exhibit Review
**Issue:** Column 6 shows a truncated scientific notation coefficient. Top journals prefer standard decimals.
**Fix:** Replace scientific notation with standard decimal format (e.g., -0.0009 instead of -9e-04). Check all tables for similar issues.

### A2. Figure 1 caption/legend color mismatch
**Source:** Exhibit Review
**Issue:** Caption says "red" and "green" but figure shows "purple" and "grey."
**Fix:** Update either the caption text or the figure colors so they match.

### A3. Table 5 scientific notation
**Source:** Exhibit Review
**Issue:** Permutation inference table uses scientific notation (-9e-04) which is discouraged in top journals.
**Fix:** Convert to standard decimal format.

### A4. Table 2 minor label fixes
**Source:** Exhibit Review
**Issue:** (a) "French-speaking" vs "Catholic (historical)" inconsistent naming style. (b) Add note clarifying dependent variable is on 0--1 scale so coefficients are in percentage points.
**Fix:** Standardize variable labels. Add clarifying note on scale.

### A5. Table 4 readability
**Source:** Exhibit Review
**Issue:** Dense table. Year column would help readability.
**Fix:** Add a "Year" column. Consider bolding the interaction coefficients that are the paper's focus.

### A6. Promote interaction plot (Figure 7) to main text
**Source:** Exhibit Review
**Issue:** The "parallel lines" interaction plot in the appendix is the most intuitive visualization of modularity. It belongs in the main text.
**Fix:** Move Figure 7 (interaction plot) into the main text, either replacing or supplementing the current Figure 1.

### A7. Add map of Switzerland showing the 2x2 culture groups
**Source:** Exhibit Review
**Issue:** For a spatial paper targeting AER/QJE, a "treatment map" showing which municipalities fall into which culture group is essentially mandatory.
**Fix:** Create a choropleth map of Swiss municipalities colored by the four culture groups (French-Protestant, French-Catholic, German-Protestant, German-Catholic), highlighting the crossing region in Fribourg/Bern/Valais.

### A8. Clarify "average modularity" vs "uniform modularity"
**Source:** GPT-5.2 (Section 3.2, Writing Issue 1)
**Issue:** Referendum-level interactions show significant values with opposite signs (e.g., +3.4 in 1981, -4.8 in 2020). The pooled zero is a weighted average of heterogeneous interactions. The narrative sometimes slides between "average modularity" (mean interaction = 0) and "uniform modularity" (interaction = 0 for each issue).
**Fix:** Add a paragraph in Results or Discussion explicitly distinguishing these concepts. Add a joint test of H0: all referendum-specific interactions = 0. Report whether the variance of referendum-specific interactions exceeds what sampling error alone would produce.

### A9. Add wild cluster bootstrap p-values for canton-level clustering
**Source:** GPT-5.2 (Critical Inference Concern 1)
**Issue:** Catholic varies at the canton level with only ~21 cantons. Conventional cluster-robust SEs may be distorted with few clusters.
**Fix:** Add wild cluster bootstrap (canton-level) p-values for the Catholic and French x Catholic coefficients. Report in a robustness table or as a row in Table 6. Use the `fwildclusterboot` or `boottest` R package.

### A10. Document non-gender referenda classification
**Source:** GPT-5.2 (Section 3.4)
**Issue:** The falsification using non-gender referenda is striking but under-documented. Which referenda are included? How is "progressive" direction coded?
**Fix:** Add an appendix table listing all non-gender referenda used in the falsification, their dates, topics, and how progressive/conservative direction was coded.

### A11. Add missing literature references
**Source:** GPT-5.2 (Section 4), Grok (Section 4)
**Fix:** Add the following references to the bibliography:
- Cameron, Gelbach, Miller (2008) -- few-cluster inference (wild cluster bootstrap)
- Conley (1999) -- spatial HAC SEs
- Guiso, Sapienza, Zingales (2006) -- culture and economic outcomes
- Alesina & Fuchs-Schundeln (2007) -- ideology persistence

### A12. Prose improvements (targeted)
**Source:** Prose Review
**Fixes (selective):**
- Strengthen the concluding sentence (currently flat)
- Reduce "academic throat-clearing" (e.g., "Several limitations merit acknowledgment" -> just state them)
- Add human-stakes translation of key coefficients (e.g., "In a French-Protestant town, gender equality commands majority support; in a German-Catholic one, it is a minority position")

---

## Deferred to Future Revision

The following suggestions are noted but NOT addressed in this revision:

- **Spatial RDD / border discontinuity analysis** (GPT-5.2 Suggestion C) -- would require substantial new analysis infrastructure
- **Conley spatial HAC standard errors** (GPT-5.2) -- requires specialized spatial econometrics setup
- **Restricted/spatially-structured permutation inference** (GPT-5.2) -- interesting but current permutation approach is already adequate per Grok and Gemini
- **Fractional logit / quasi-binomial robustness** (GPT-5.2) -- OLS on vote shares is standard in the Swiss referendum literature
- **Hierarchical / random coefficients model for referendum heterogeneity** (GPT-5.2 Suggestion B.2) -- useful but not essential given joint test
- **Individual-level survey data (Swiss Household Panel)** (Grok, Gemini) -- entirely new data source, out of scope
- **Mechanism proxies (newspaper circulation, church attendance)** (Grok, Gemini) -- data availability uncertain
- **Cohort/age heterogeneity** (Gemini) -- municipality-level data precludes this
- **Remove Figure 5 from appendix** (Exhibit Review) -- low priority cosmetic change
- **Omitted-interaction bias formalization** (GPT-5.2 Suggestion D) -- theoretical addition beyond scope of this revision

---

## Implementation Order

1. Fix F1 (Figure 3 two-panel) and F2 (N consistency) -- these block advisor re-pass
2. Fix A1--A5 (table/figure formatting)
3. Add A7 (map) and A6 (promote interaction plot)
4. Add A8 (joint heterogeneity test) and A9 (wild cluster bootstrap)
5. Add A10 (non-gender referenda documentation) and A11 (references)
6. Apply A12 (prose polish)
7. Recompile and re-run advisor review
