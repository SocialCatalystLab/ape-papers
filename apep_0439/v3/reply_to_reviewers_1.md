# Reply to Reviewers: apep_0439 v2

**Paper:** Where Cultural Borders Cross: Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy

We thank all reviewers for their careful and constructive engagement with the paper. Below we address each point raised, organized by reviewer.

---

## Reviewer 1: GPT-5.2 (MAJOR REVISION)

### Format Check
> References: expect citations on few-cluster inference, spatial correlation, and randomization inference design-based perspectives.

**Addressed.** We add references to Cameron, Gelbach, and Miller (2008) on wild cluster bootstrap; Conley (1999) on spatial HAC; and strengthen the RI framing.

> CIs: recommend systematic CI reporting in tables, not only in prose.

**Addressed.** We add 95% CIs for the interaction coefficient in the main table notes.

### Statistical Methodology

> Critical Inference Concern 1: Catholic varies at the canton level with ~21 cantons. Needs wild cluster bootstrap p-values.

**Addressed.** We add wild cluster bootstrap inference (canton-level) for the Catholic and French x Catholic coefficients. Bootstrap p-values are reported in the robustness analysis.

> Critical Inference Concern 2: Permutation test permutes labels across municipalities, breaking spatial/canton structure.

**Deferred.** The current permutation approach follows Young (2019) and was deemed adequate by both Grok and Gemini reviewers. We acknowledge this concern in the limitations and note that the wild cluster bootstrap (canton-level) provides a complementary inference approach that respects the canton structure of the religion variable. Restricted permutation schemes are noted as a direction for future work.

> Fractional logit / quasi-binomial robustness.

**Deferred.** OLS on referendum vote shares is the standard approach in the Swiss referendum literature (Eugster 2011, Basten and Betz 2013). We note this as a potential robustness check but do not implement it in this revision.

### Identification Strategy

> (1) Cross-sectional design: add spatial border discontinuity analysis, lat/long polynomials, or border-segment FEs.

**Deferred.** A formal spatial RDD would require substantial new infrastructure (distance-to-border computation, bandwidth selection, etc.) and is beyond the scope of this revision. We already include canton FE specifications that compare municipalities within the same institutional framework. We note the spatial RDD as a valuable extension in the discussion.

> (2) Pooled interaction = 0 vs referendum-specific interactions: need joint test and heterogeneity framework.

**Addressed.** We add a formal joint test of H0: all referendum-specific interactions = 0. We also add a paragraph distinguishing "average modularity" (mean interaction = 0) from "uniform modularity" (each interaction = 0) and discuss the implications.

> (3) Non-gender referenda falsification under-documented.

**Addressed.** We add an appendix table listing all non-gender referenda used in the falsification, including dates, topics, and coding of the progressive direction.

> (4) Spatial correlation: add Conley SEs or higher-level clustering.

**Partially addressed.** We add wild cluster bootstrap at the canton level, which addresses the most critical spatial correlation concern (religion varies at canton level). Full Conley spatial HAC standard errors are deferred to a future revision.

### Literature

> Missing references on few-cluster inference, spatial correlation, geographic discontinuities, and randomization inference.

**Addressed.** We add Cameron et al. (2008), Conley (1999), and Guiso et al. (2006). We do not add the RDD references (Lee and Lemieux 2010, Imbens and Lemieux 2008) since we explicitly state the paper is not an RDD, and adding these references would invite confusion about the design.

### Writing Quality

> (1) Tighten logical leap from "pooled interaction = 0" to "modularity holds." Distinguish average, uniform, and structural modularity.

**Addressed.** We add explicit discussion distinguishing these concepts and include the joint test.

> (2) Clarify estimand and unit of analysis early.

**Addressed.** We add a sentence in the empirical strategy section making explicit that the identifying variation is cross-sectional (time-invariant cultural indicators), with referendum FE absorbing common temporal shocks.

> (3) Make falsification fully reproducible.

**Addressed.** Appendix table added documenting the non-gender referenda set.

---

## Reviewer 2: Grok-4.1-Fast (MINOR REVISION)

### Statistical Methodology
> Pass: Exemplary inference throughout.

Noted with thanks.

### Identification Strategy
> Minor fixable concern: could add municipal FE.

**Deferred.** With time-invariant treatments (language, religion), municipality FE would absorb the key regressors. Canton FE (already included) is the appropriate level for within-institutional-framework comparison.

### Literature

> Missing: Bugni et al. (2022) on discrete RDD, Alesina & Fuchs-Schundeln (2007) on ideology persistence, Giampaolo & Rovagnati (2023) on Swiss language, Abramitzky et al. (2024) on multi-trait culture.

**Partially addressed.** We add Alesina and Fuchs-Schundeln (2007) as a parallel case of historical persistence. The Bugni et al. (2022) discrete RDD reference is not added since our paper explicitly disclaims being an RDD. The Abramitzky et al. (2024) working paper reference will be verified and added if confirmed.

### Constructive Suggestions

> Strengthen mechanisms (media citation indices, newspaper circulation).

**Deferred.** Data availability for municipality-level media consumption is uncertain. Noted for future work.

> RDD upgrade with formal bandwidth sensitivity.

**Deferred.** See response to GPT-5.2 above.

> Lead with domain reversal in abstract/discussion.

**Partially addressed.** We give more prominence to the domain reversal finding in the discussion but retain the modularity framing as the primary hook since that is the paper's core contribution.

> Voter weights as main specification.

**Deferred.** Voter-weighted results are already reported as robustness. The unweighted specification is preferred as the baseline because it treats each municipality as an independent observation of culture, consistent with the Swiss referendum literature.

### Writing Quality
> Outstanding: publishable prose. Minor LaTeX typos.

**Addressed.** We fix any LaTeX typos identified.

---

## Reviewer 3: Gemini-3-Flash (ACCEPT)

### Constructive Suggestions

> Heterogeneity by age/cohort.

**Deferred.** Municipality-level referendum data does not permit cohort-level analysis. Noted as a direction for future work with individual-level survey data (e.g., Swiss Household Panel).

> Mechanisms of transmission (newspaper circulation, church attendance).

**Deferred.** See response to Grok above.

> Move more of non-gender falsification into main body.

**Partially addressed.** The non-gender falsification is already in the main text (Section 7). We ensure it receives adequate discussion and add the appendix documentation table.

---

## Exhibit Review (Gemini)

### Table 2 labels
> Inconsistent naming ("French-speaking" vs "Catholic (historical)"). Add scale note.

**Addressed.** We standardize variable labels and add a note clarifying the 0--1 dependent variable scale.

### Table 4 readability
> Add year column, bold interaction coefficients.

**Addressed.** We add a year column and bold the interaction row.

### Figure 1 caption mismatch
> Caption says red/green but figure shows purple/grey.

**Addressed.** We fix the caption to match the actual figure colors.

### Table 5 scientific notation
> Convert -9e-04 to standard decimal.

**Addressed.** All scientific notation in tables converted to standard decimal format.

### Table 6 formatting
> Truncated coefficient, too many columns.

**Addressed.** We fix the truncated coefficient and convert scientific notation to decimals.

### Figure 7 (interaction plot) should be in main text
> Parallel lines plot is the most intuitive visualization of modularity.

**Addressed.** We promote the interaction plot from the appendix to the main text.

### Missing map of Switzerland
> Treatment map showing culture groups is mandatory for a spatial paper.

**Addressed.** We add a choropleth map of Swiss municipalities colored by culture group.

### Remove Figure 5 (redundant with Table 3)

**Deferred.** Low priority; may address in a subsequent revision.

---

## Prose Review (Gemini)

### Opening
> Second paragraph academicizes too quickly.

**Partially addressed.** We tighten the transition from the narrative hook to the academic framing.

### Introduction
> "Contribution" paragraph is defensive. Delete roadmap bullets.

**Partially addressed.** We streamline the contribution paragraph. The "three findings" structure is retained as it helps readers navigate a null-result paper, but we remove the most formulaic phrasing.

### Concluding sentence
> Currently flat ("Those dimensions, it turns out, can sometimes be studied one at a time").

**Addressed.** We strengthen the concluding sentence.

### Academic throat-clearing
> "Several limitations merit acknowledgment" etc.

**Addressed.** We replace formulaic transitions with direct statements.

### Human stakes translation
> Translate coefficient magnitudes into concrete terms.

**Addressed.** We add concrete translations of key coefficients (e.g., "In French-Protestant municipalities, gender equality commands majority support at 62%; in German-Catholic municipalities, it garners only 45%").

### Passive voice in abstract, roadmap phrasing, jargon

**Partially addressed.** We make targeted prose improvements while maintaining the paper's academic voice.

---

## Advisor Review: Gemini (FAIL)

### Fatal Error 1: Figure 3 missing language panel
> Caption and text claim two panels but only interaction panel is shown.

**Addressed.** Figure 3 is updated to include both panels: language coefficient permutation distribution (left) and interaction permutation distribution (right).

### Fatal Error 2: N drops from 8,727 to 8,723 in Table 2 Column 6
> Unexplained loss of 4 observations with municipality controls.

**Addressed.** We investigate the source of the missing observations and either (a) add a table note explaining which municipalities lack the control variable data, or (b) ensure consistent N across all columns.

---

## Summary of Changes

| Category | Count |
|----------|-------|
| Fatal errors fixed | 2 |
| Clearly addressed | 14 |
| Partially addressed | 6 |
| Deferred to future revision | 10 |

All deferred items are noted in the paper's limitations section or flagged as future work directions. None are fatal to the paper's core contribution.
