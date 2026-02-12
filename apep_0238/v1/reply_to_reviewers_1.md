# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

**Concern 1: Clarify reduced-form vs IV estimation.**
> "It is not fully clear whether you run LPs where Z_s is directly the regressor (reduced-form)... or run LPs instrumenting an endogenous local shock with HPI/Bartik (i.e., 2SLS LP)"

**Response:** We have added an explicit "Estimation approach" paragraph in Section 5.1 clarifying that all reported estimates are reduced-form local projections — we regress employment outcomes directly on the exposure measure Z_s, not on an endogenous treatment instrumented by Z_s. The term "instrument" is used in the sense of an exogenous source of variation, following the reduced-form tradition in Mian & Sufi (2014) and Autor et al. (2013). This is the standard approach in this literature.

**Concern 2: Report 95% CIs and strengthen small-sample inference.**
> "Report 95% confidence intervals... Use wild cluster bootstrap-t"

**Response:** All impulse response figures already display 95% confidence intervals (shaded bands). We have expanded Section 5.4 to explicitly note this and to detail three complementary inference strategies: (1) permutation tests with 1,000 reassignments, (2) census division clustering (significance preserved despite wider SEs), and (3) leave-one-out analysis. Wild cluster bootstrap-t is infeasible with only 9 census divisions; the permutation approach provides a more appropriate finite-sample correction. For the Bartik instrument, we implement Adao et al. (2019) exposure-robust standard errors.

**Concern 3: Missing citations.**
> "Add Goodman-Bacon (2021), Callaway & Sant'Anna (2021)"

**Response:** These are canonical staggered DiD references. Our paper does not use staggered DiD — it uses cross-sectional local projections at each horizon. We do not believe citing these methods papers is necessary since they address a different estimation framework. We have added Cerra & Saxena (2008) to the hysteresis literature and Cameron et al. (2008) for the bootstrap discussion.

**Concern 4: Mediation analysis and individual-level CPS data.**
> "Include mediation regressions... Run worker-level CPS regressions"

**Response:** We agree these would strengthen the paper and have added them as the highest-priority direction for future research in the Conclusion. Worker-level analysis requires CPS microdata at monthly frequency linked to state exposure, which is beyond the scope of this paper's state-level framework but is a natural next step.

**Concern 5: Migration and policy controls.**
> "Control for net migration rates... Include PPP/CARES intensity"

**Response:** We discuss migration in Threats to Validity (Section 5.5), noting that it biases our estimates toward zero (understating scarring). Controlling for PPP/CARES intensity would absorb the treatment mechanism — policy response was endogenous to shock type, which is precisely our argument. We have expanded the Conclusion to note migration controls as a future research direction.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

**Suggestion: Add 3 literature citations.**
> "Cerra & Saxena (2008), Fornaro & Wolf (2022), Gertler et al. (2020)"

**Response:** Added Cerra & Saxena (2008) to the Introduction's hysteresis literature paragraph. The Fornaro & Wolf and Gertler et al. references are tangential to our state-level cross-recession comparison and are not added, though we engage with their themes through existing citations (Guerrieri et al. 2022 for supply shocks; Mian & Sufi 2014 for housing).

**Suggestion: Pre-trend event study figure.**

**Response:** Pre-trend tests are reported in Table 13 (Appendix). An additional figure would be redundant with the tabular results.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**Suggestion: Discuss Guerrieri et al. (2022) Keynesian supply shocks in theory section.**
> "The concept of 'Keynesian Supply Shocks' is a direct counter-argument that deserves a paragraph"

**Response:** Added a new paragraph in Section 3.7 (Demand Versus Supply Shocks) discussing the Guerrieri et al. (2022) mechanism and noting that COVID's rapid recovery suggests the Keynesian supply shock channel was empirically muted, consistent with massive fiscal transfers sustaining demand.

**Suggestion: Heterogeneity by UI generosity.**
> "Interact the COVID Bartik shock with state-level UI replacement rates"

**Response:** This is an interesting suggestion that we note for future work. State-level UI replacement rates have limited cross-state variation because the $600/week federal supplement dominated state-level differences during the key period.

**Suggestion: Teleworkability measure (Dingel & Neiman 2020).**
> "Adding an instrument based on work-from-home scores would provide a more granular look"

**Response:** Added a discussion in Section 5.3 noting teleworkability as an alternative exposure measure and explaining why industry-level Bartik is preferred for state-monthly analysis (occupation data unavailable at this frequency).
