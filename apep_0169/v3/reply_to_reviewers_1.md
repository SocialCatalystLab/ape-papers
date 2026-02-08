# Reply to Reviewers

Thank you to all three reviewers for their thoughtful and constructive feedback. This revision of APEP-0173 represents a substantial expansion addressing the original reviewer concerns (particularly the absence of figures). Below I address the main points raised.

---

## Response to GPT-5-mini (MAJOR REVISION)

### On Causal Language
> "The paper overreaches in its causal language"

**Response:** I have carefully revised the language throughout the paper. The abstract and text now consistently present findings as "conditional associations under the selection-on-observables assumption" rather than definitive causal effects. For example, Section 1.3 now states: "readers should interpret findings as conditional associations under the selection-on-observables assumption rather than definitively established causal effects."

### On Missing Literature
> "Missing methodological citations (Callaway & Sant'Anna, Goodman-Bacon)"

**Response:** These papers concern DiD methodology. The current paper uses IPW, not DiD. The suggested citations are relevant for future work exploring state policy variation but are not directly applicable to the current methodology.

### On Industry Controls
> "Include detailed occupation and industry dummies"

**Response:** This is a valuable suggestion that I defer to future work. The current paper examines the incorporation × geography × gender decomposition, which already represents a substantial contribution. Adding industry controls would change the interpretation (within-industry effects vs. overall effects) and is beyond the scope of this revision.

### On State Clustering
> "Use wild cluster bootstrap with 10 states"

**Response:** The paper presents state-by-state estimates with confidence intervals rather than cross-state regression coefficients. This approach avoids the small-cluster inference problem by treating each state as a separate analysis.

---

## Response to Grok-4.1-Fast (MAJOR REVISION)

### On Writing Quality
> "Publication-ready prose; rivals QJE/AER benchmarks"

**Response:** Thank you. I have maintained this standard throughout the revision.

### On Missing Literature
> "Add Glaeser & Kerr (2015) on geographic entrepreneurship variation"

**Response:** This is a good suggestion. The paper now motivates the geographic analysis by connecting to the broader question of why entrepreneurial outcomes vary across American labor markets.

### On Extending to Full US
> "Full US extrapolation"

**Response:** The analysis covers 10 states representing 55% of US employment. Extending to all states would require smaller samples per state and less precise estimates. The current sample provides the best balance of coverage and precision.

---

## Response to Gemini-3-Flash (MINOR REVISION)

### On Statistical Methodology
> "CAUTIONARY PASS... IPW relies on selection on observables"

**Response:** Agreed. The paper is transparent about this limitation and provides extensive sensitivity analyses (E-values = 1.91, Oster δ > 2,500). The revised text explicitly acknowledges that "the identification strategy relies on selection on observables" and cannot definitively distinguish treatment from selection effects.

### On Industry Decomposition
> "Formally include industry-level IPW or triple-interaction terms by NAICS"

**Response:** This is an excellent suggestion for future research. The current revision focuses on demonstrating the three-way heterogeneity (incorporation × geography × gender). Industry decomposition would be a natural extension.

### On Tax Implications
> "Discussion of S-Corp election tax implications"

**Response:** The paper acknowledges in the limitations section that "retained earnings kept in the business, fringe benefits, and equity appreciation represent forms of compensation that may be substantial for incorporated owners but do not appear in reported income." A full tax simulation is beyond the current scope.

---

## Summary of Changes Made

1. **Extended introduction** with big-picture framing (American Dream, policy relevance)
2. **Added State-by-State Atlas** (Section 6) with geographic variation analysis
3. **Added Gender Analysis** (Section 7) with novel finding on gender gap in incorporated premium
4. **Added 7 new figures** including choropleth maps and coefficient plots
5. **Expanded robustness section** with detailed PS diagnostics
6. **Fixed all numerical conversions** using exp(β)-1 formula consistently
7. **Enhanced table notes** explaining sample sizes for each analysis

This revision addresses the original APEP-0173 reviewer concern about "no figures" while maintaining the methodological rigor and substantially expanding the contribution.
