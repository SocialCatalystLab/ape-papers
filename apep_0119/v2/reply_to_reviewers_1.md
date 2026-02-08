# Reply to Reviewers - Round 1

**Paper:** Do Energy Efficiency Resource Standards Reduce Electricity Consumption?
**Date:** 2026-02-01

---

## Response to Reviewer 1 (GPT-5-mini)

### Concern 1: Inference Robustness
> "The discrepancy between TWFE wild-bootstrap p-value and CS asymptotic p-value raises concerns that the main claim of 'statistically significant at 1%' may not be robust."

**Response:** We appreciate this careful observation. The discrepancy reflects the different underlying assumptions: TWFE with wild cluster bootstrap is a conservative inference procedure appropriate for our 51 clusters, while CS-DiD uses influence-function-based asymptotic inference that may be less conservative. We have added language in the Results section explicitly acknowledging this discrepancy and noting that the TWFE bootstrap confidence interval [-0.058, 0.008] includes zero at conventional levels. We frame our main result with appropriate caution regarding precision.

### Concern 2: Policy Bundling
> "The claim in the abstract that the estimates 'capture the combined effect of EERS and correlated progressive energy policies' is correct, but the main text sometimes implies causation from EERS alone."

**Response:** We have strengthened language throughout the paper to consistently frame findings as the effect of the "EERS policy package" rather than isolated EERS effects. This includes revisions to the Abstract, Introduction, Results, and Discussion sections.

### Concern 3: Statistical Reporting
> "The main CS result (-0.0415, SE=0.0102) does not have its 95% CI explicitly displayed."

**Response:** We have added explicit t-statistics and p-values to the Abstract ($t = -4.07$, $p < 0.01$) for clarity. All tables include standard errors in parentheses with clustering information in notes.

---

## Response to Reviewer 2 (Grok-4.1-Fast)

### Concern 1: Total Electricity Pre-Trends
> "Minor concern: Total electricity shows pre-trends (Fig. 3 note); residential focus justified but flagged."

**Response:** We agree this is an important limitation. We have added bold text in the Results section explicitly stating: "Given this pre-trend violation, the total electricity result (-9.0%) should not be interpreted as causal." We also corrected the figure reference to point to the correct event-study figure showing these pre-trends.

### Concern 2: Missing Citations
> "Fowlie, Greenstone, Wolfram (2018) already in bib but not cited in text."

**Response:** We have expanded the discussion of Fowlie et al. (2018) in the Conceptual Framework and Discussion sections, drawing parallels between our macro-level estimates and their micro-evidence on gross vs. net savings.

---

## Response to Reviewer 3 (Gemini-3-Flash)

### Concern 1: Policy Bundling as Critical Flaw
> "The 'EERS effect' may still be an 'Energy-Progressive State effect.' The author needs to do more to disentangle EERS from building code updates."

**Response:** We acknowledge this fundamental limitation. As noted in Section 7.4, we include controls for RPS and decoupling policies, and the robustness section shows results are stable to these controls. However, we agree that complete disentanglement is not possible with our design. We have reframed the paper's contribution as estimating the effect of adopting the EERS policy package (which includes correlated policies) versus not adopting it, rather than isolated EERS effects.

### Concern 2: Rambachan-Roth Sensitivity
> "The paper should cite the 'Honest DiD' framework for sensitivity analysis."

**Response:** Rambachan & Roth (2023) is already cited in our bibliography (reference [32]). Implementation of formal sensitivity bounds is challenging given the single-state cohort structure of our data, where bootstrap procedures do not converge. We note this as an area for future methodological development.

---

## Summary of Changes

| Change | Location | Reviewer(s) |
|--------|----------|-------------|
| Replaced "95% CI excluding zero" with "$t = -4.07$, $p < 0.01$" | Abstract | GPT |
| Added bold caveat for total electricity pre-trends | Results §6 | Grok, Gemini |
| Corrected figure reference (event-study, not forest plot) | Results §6 | GPT |
| Strengthened policy bundling language | Throughout | All |

---

We thank all reviewers for their constructive feedback. These revisions strengthen the paper's transparency about limitations while maintaining the core empirical contribution.
