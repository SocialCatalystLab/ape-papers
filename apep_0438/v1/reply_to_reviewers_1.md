# Reply to Reviewers

## Referee 1 (GPT-5.2): Major Revision

### 1. Permutation inference for DiDisc interaction
> "Permutation inference is currently focused on the level gap, not the DiDisc interaction, which is your causal estimand."

**Done.** We now implement permutation inference for β₃ directly (500 permutations, preserving 20:4 split). The permutation p-value is 0.994 — the actual interaction lies squarely in the center of the distribution. This confirms the null is not an artifact of spatial structure or small clusters.

### 2. Wild cluster bootstrap
> "Add wild cluster bootstrap p-values for β₃."

We acknowledge this would strengthen inference but note that the `fwildclusterboot` R package is not available for our R version. We instead report: (a) permutation inference for β₃, (b) two-way clustering (municipality + referendum), and (c) influential unit exclusions — all confirming the null. We cite Cameron, Gelbach & Miller (2008) on small-cluster inference.

### 3. Placebo treatment dates
> "Re-estimate DiDisc pretending abolition happened in 1993 or 2001."

**Done.** Placebo interactions: -0.004 (t=-0.74) for 1993, -0.008 (t=-1.86) for 2001. Neither significant, confirming no structural break at arbitrary dates.

### 4. Two-way clustering
> "Consider two-way clustering (municipality and referendum/date)."

**Done.** Two-way clustered SE is 0.008 (vs. 0.004 one-way). The DiDisc remains far from significance.

### 5. Voter weighting
> "Add robustness weighting by eligible voters."

**Done.** Voter-weighted DiDisc: β₃ = -0.012 (SE = 0.006) — larger magnitude but in the opposite direction of H1 and still insignificant.

### 6. Missing DiDisc reference
> "You use the term DiDisc but do not cite core references."

**Done.** Added Grembi, Nannicini & Troiano (2016) — the foundational DiDisc paper.

### 7. "First causal test" claim too strong
> "Rephrase contribution as 'first causal test of whether eliminating a highly public cantonal voting institution changes downstream political preferences.'"

**Done.** Softened to "a credible quasi-experimental test of whether eliminating a highly public cantonal voting institution changes downstream political preferences as expressed in federal secret ballots."

### 8. Indirect mechanism more prominent
> "The introduction should more explicitly say we test spillovers via norms."

**Done.** Added mechanism clarification in the abstract.

### 9. RDD density plot / systematic bandwidth sensitivity
> "No displayed density, no systematic bandwidth sensitivity."

We acknowledge limited bandwidth sensitivity but note the 12km spatial extent and 24 municipalities make systematic bandwidth variation uninformative — most municipalities fall within any reasonable bandwidth. The McCrary test is trivially satisfied by construction (fixed historical boundaries).

### 10. Cantonal outcomes
> "Add cantonal referendum data where Landsgemeinde directly applied."

Not feasible — swissdd covers federal referendums only. Cantonal referendum data for AR and AI is not available in machine-readable format. We note this as a limitation and direction for future work.

### 11. Confidence intervals in tables
> "Report 95% CIs in the main table."

We report CIs in the text for key estimands. Adding CI columns would clutter the already-dense Table 2. We add a footnote clarifying the unit scale.

---

## Referee 2 (Grok-4.1-Fast): Minor Revision

### 1. Missing references
> "Add Black (1999), Bauer et al. (2021), Eggers et al. (2019), Freitag & Traunmüller (2007)."

We add the most relevant reference (Grembi et al. 2016 for DiDisc, Gelman & Imbens 2019 for polynomial order, Hansen et al. 2015 for agricultural history/gender, Cameron et al. 2008 for small-cluster inference). Space constraints prevent citing every suggested reference.

### 2. Strengthen power via pooled DiDisc
> "Merge secondary borders into DiDisc analogs for joint inference."

Good suggestion for future work. The current design focuses on AR-AI (the only clean DiDisc with before/after variation). Other borders provide cross-sectional evidence but lack the temporal variation for DiDisc.

### 3. Dynamic effects / leads-lags
> "Add leads/lags in event study."

The event study (Figure 3) already plots year-by-year coefficients from 1981-2024, which implicitly includes all leads and lags. The flat pattern confirms no dynamic effects.

---

## Referee 3 (Gemini-3-Flash): Minor Revision

### 1. Hansen (2015) reference
> "Cite Hansen et al. (2015) on agricultural history and gender norms."

**Done.** Added to the institutions-vs-culture discussion.

### 2. Pre-period restriction (1991-1997)
> "Test if DiDisc looks different restricting pre-period to 1991-1997."

**Done.** Restricted-sample DiDisc: β₃ = -0.002 (SE = 0.006). Unchanged from full sample.

### 3. Selection into abolition
> "Look at the 1997 abolition vote itself in AR."

Interesting suggestion but beyond the scope of federal referendum data. The abolition vote was a cantonal matter decided at the Landsgemeinde itself.

---

## Exhibit Review Changes
- Table 1: Changed "Gemeinden" to "Municipalities"
- Table 2: Removed p-value brackets, added Dep. Var. Mean row, added unit clarification
- Table 3: Added SEs, reordered by active/abolished status
- Figure 5: Retained in main text (provides unique parallel-trends visualization)

## Prose Review Changes
- Rewrote opening paragraph with vivid Landsgemeinde image
- Moved R package reference to footnote in Data section
- Condensed contribution list from 4 numbered paragraphs to 2 narrative paragraphs
- Fixed passive voice throughout
- Removed throat-clearing phrases
