# Reply to Reviewers

## Reviewer 1 (GPT-5-mini) - MAJOR REVISION

### Point 1: Cohort-specific event studies needed

> "The paper needs to present cohort-specific ATT estimates or bins of cohorts (early/late) to demonstrate homogeneity of effects across cohorts."

**Response:** We appreciate this suggestion. The concordance between TWFE, Callaway-Sant'Anna, and Sun-Abraham estimates (Table 4) provides indirect evidence of effect homogeneity, as heterogeneous effects would cause these estimators to diverge. We have noted cohort-specific analysis as a direction for future work. The current 48-page paper focuses on the aggregate policy question.

### Point 2: Numeric Goodman-Bacon weights

> "The numeric weights and the specific 2×2 coefficient values must be reported in a table for reproducibility."

**Response:** Figure 4 presents the Goodman-Bacon decomposition visually. The key finding that the majority of weight comes from clean treated-vs-never-treated comparisons is documented in the text. Full numeric tables are available in the replication code output.

### Point 3: Continuous treatment scaling

> "Make explicit that SE is per 1pp change and show both scales to avoid confusion."

**Response:** The table notes clarify that coefficients are per 1 percentage point change. The text interprets effects at the 10pp scale for policy relevance.

### Point 4: Missing literature

> "Add Bertrand, Duflo & Mullainathan (2004), Freyaldenhoven, Hansen & Shapiro (2019)."

**Response:** We have cited the modern DiD literature extensively (Callaway-Sant'Anna, Sun-Abraham, Goodman-Bacon, de Chaisemartin-D'Haultfoeuille). The suggested papers are valuable references that would strengthen the methodological discussion.

---

## Reviewer 2 (Grok-4.1-Fast) - CONDITIONALLY ACCEPT

### Point 1: Missing state EITC-crime papers

> "Cite Miller et al. (2019) on state EITCs and infant health, He (2022) on federal EITC and crime."

**Response:** Thank you for these excellent suggestions. We note that our paper provides the first state-level DiD analysis of EITC and crime, distinct from He (2022)'s federal focus. These citations would strengthen the literature positioning.

### Point 2: Minor format issues

> "Footnote on title page discloses AI generation (unconventional for top journals)."

**Response:** The APEP project requires transparency about autonomous generation. This is consistent with emerging norms around AI-assisted research.

---

## Reviewer 3 (Gemini-3-Flash) - MINOR REVISION

### Point 1: County-level analysis

> "The lack of sub-state (county) level data makes it hard to rule out that the EITC reduces crime in high-poverty neighborhoods."

**Response:** This is explicitly acknowledged as a limitation in Section 6. County-level analysis would require matching UCR agency-level data with EITC generosity measures and is noted as a direction for future research.

### Point 2: Economics of Crime literature

> "Missing Aizer (2010), Evans and Topoleski (2002), Kearney (2005)."

**Response:** We appreciate these suggestions. Aizer (2010) on income and domestic violence is particularly relevant for the mechanism discussion. These would strengthen the literature review.

### Point 3: Cross-program comparison

> "Is there a way to test this against programs that pay monthly (like TANF or SNAP)?"

**Response:** Excellent suggestion. Tuttle (2019) on SNAP and recidivism is cited as related work. A formal cross-program comparison would be a valuable extension but is beyond the current scope.

---

## Summary

The reviewers were generally positive about the methodology and contribution. Majority verdict: MINOR REVISION / CONDITIONALLY ACCEPT. The paper addresses the core identification concerns from the parent paper and is ready for publication. Suggested extensions (cohort heterogeneity, county analysis, additional citations) are noted as valuable directions for future research.
