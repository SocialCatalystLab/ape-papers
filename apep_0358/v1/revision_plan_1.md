# Revision Plan (Round 1)

**Paper:** Does Coverage Create Capacity? Medicaid Postpartum Extensions and the Supply of Maternal Health Providers
**Paper ID:** apep_0356 v1
**Date:** 2026-02-18

## Review Summary

| Reviewer | Model | Verdict |
|----------|-------|---------|
| Referee 1 | GPT-5.2 | MAJOR REVISION |
| Referee 2 | Grok-4.1-Fast | MINOR REVISION |
| Referee 3 | Gemini-3-Flash | MAJOR REVISION |

All three referees praised the novel data, modern methods (CS-DiD), excellent writing, strong placebos, and transparent limitations. The critical issue across all three reviews is the balanced panel result (ATT near 0 when restricted to 17 states with consistent reporting), which raises the possibility that the main effect is driven by T-MSIS reporting improvements rather than real provider behavior changes.

---

## Revision Items

### 1. Add a "Data Validity" Subsection (Critical -- All 3 Referees)

**Problem:** The balanced panel restriction (17 states with consistent reporting) produces ATT = 0.0028, suggesting that the main result may be driven by states transitioning from zero to positive T-MSIS reporting rather than genuine behavioral responses to the policy. All three referees flagged this as the most important concern. GPT-5.2 recommends elevating data quality from a "limitation" to a "core identification challenge with a proposed resolution." Gemini suggests a "leads test" for whether reporting onset coincides exactly with policy adoption.

**Plan:**
- Add a new subsection (Section 6.7 or restructure within Section 6.6) titled "Data Validity and Reporting Artifacts" between the current robustness section and heterogeneity section.
- In this subsection:
  - Characterize the 17 balanced-panel states vs. the remaining 34 states explicitly (which states, what changed in their reporting).
  - Discuss the zero-to-positive transition pattern: how many states shift from zero postpartum claims to positive claims around adoption? Does the timing of first T-MSIS postpartum reporting align exactly with policy adoption dates, or is there separation?
  - Acknowledge directly that if reporting onset is contemporaneous with policy adoption, the main effect cannot be cleanly separated from reporting improvement.
  - Frame the balanced-panel estimate (ATT = 0.0028) not as a minor robustness check but as a plausible lower bound on the true effect, with the full-sample estimate (0.2834) as an upper bound that includes both real effects and reporting artifacts.
  - Note that the antepartum placebo (null effect) provides partial reassurance -- if the effect were purely driven by general T-MSIS reporting improvements, we would expect antepartum claims to rise as well. The postpartum-specific pattern is more consistent with either (a) a real policy effect or (b) postpartum-code-specific reporting changes.
- Revise the Limitations subsection (Section 7.3) to reference this new subsection rather than treating data quality as a minor caveat.
- Soften the abstract and conclusion language from "increased postpartum care claims by 33%" to framing that acknowledges the range of estimates.

**Feasibility:** HIGH -- this is primarily a rewriting and reframing task using existing results.

---

### 2. Explain the RI vs. Conventional p-value Discrepancy (Critical -- GPT-5.2)

**Problem:** The conventional CS-DiD p-value is 0.027 while the randomization inference p-value is 0.21. GPT-5.2 calls this "a red flag unless clearly explained." The discrepancy likely arises from the different null hypotheses (sharp null of zero effect for all units vs. the conventional null of zero average effect) and the small number of effective comparison units (4 never-treated states).

**Plan:**
- Add an explicit paragraph in the robustness section (Section 6.6) or in the new Data Validity subsection explaining:
  - The conventional p-value tests H0: ATT = 0 using the asymptotic distribution of the CS-DiD estimator with bootstrap SEs. With 51 clusters and 47 treated, the bootstrap may overstate precision.
  - The RI p-value tests the sharp null that treatment assignment is independent of outcomes. With only 4 never-treated states and 47 treated, the permutation distribution has limited variation -- most permuted assignments look similar to the observed one, making rejection difficult.
  - The RI result is more conservative and reflects the fundamental limitation of having few comparison units. This is a finite-sample power issue, not necessarily evidence against the effect.
  - Recommend interpreting the evidence as "suggestive" rather than "definitive" -- consistent with the paper's existing cautious tone.
- Increase RI permutations from 200 to 1,000 (per Grok's recommendation) in the R code to improve RI precision. Report the updated p-value.

**Feasibility:** HIGH -- explanation is a writing task; increasing permutations requires a minor code change and re-run.

---

### 3. Add Literature Citations (Minor -- GPT-5.2, Grok)

**Problem:** Both GPT-5.2 and Grok recommend 3-4 additional citations in the staggered DiD methods literature and the Medicaid/maternal health literature.

**Plan:**
Add the following references:
- **Sun & Abraham (2021)** -- "Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects," *Journal of Econometrics*. Cite in the Empirical Strategy section alongside CS and Goodman-Bacon to acknowledge the broader heterogeneity-robust DiD literature.
- **de Chaisemartin & D'Haultfoeuille (2020)** -- "Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects," *American Economic Review*. Cite when discussing TWFE attenuation bias to provide the full methodological context.
- **Borusyak, Jaravel & Spiess (2024)** -- "Revisiting Event Study Designs," *Review of Economic Studies*. Cite alongside Sun & Abraham as an alternative imputation-based approach, noting that CS-DiD is the preferred estimator here.
- Optionally: **Dunn et al. (2021)** on geography of Medicaid provider participation (per Gemini) or **Sommers et al. (2016)** on insurance churning.

Add BibTeX entries and cite in the appropriate text locations (Introduction, Empirical Strategy, Discussion).

**Feasibility:** HIGH -- adding references and brief citations to existing paragraphs.

---

### 4. Discuss HCPCS Code Bundling (Minor -- Gemini)

**Problem:** Gemini raises the concern that postpartum care code 59430 is often bundled into global maternity codes (59400 for vaginal delivery with postpartum care, 59510 for cesarean with postpartum care). If the extension causes providers to unbundle -- billing 59430 separately rather than using the global code -- this could inflate the measured claims increase without reflecting additional care.

**Plan:**
- Add a paragraph in the Data section (Section 4.2, after describing the key HCPCS codes) or in the Discussion (Section 7) explaining:
  - Global obstetric codes (59400, 59510) bundle antepartum, delivery, and postpartum care into a single payment. When providers use global codes, the postpartum component is not separately billable as 59430.
  - The extension could incentivize unbundling: if a patient's coverage extends beyond the typical postpartum period, providers may bill the delivery globally but add separate 59430 claims for follow-up visits in months 3-12.
  - This unbundling would represent a real change in billing behavior (and plausibly in care delivery, since separate billing implies separate visits) but would overstate the "new care" interpretation if some of these visits were previously occurring under global code payment.
  - Note that delivery codes (used as placebo) show no change, providing partial reassurance that global code billing patterns are stable. If unbundling were occurring, we might expect delivery claims (which include global codes) to shift downward as some switch to delivery-only codes.
- Keep this brief (one paragraph) since we cannot empirically separate unbundling from new visits with the available data.

**Feasibility:** HIGH -- this is a discussion/framing addition.

---

### 5. Strengthen Framing Around Balanced Panel Limitation (Moderate -- All 3 Referees)

**Problem:** The current paper treats the balanced panel result as one robustness check among several. All three referees agree it deserves much more prominence. GPT-5.2 says the headline claim is "too strong" given this result.

**Plan:**
- **Abstract:** Revise the final sentence to acknowledge sensitivity. Current: "...though the effect on the extensive margin of provider participation is more modest and sensitive to specification." Revise to mention that the claims effect is also sensitive to sample composition, with the balanced-panel estimate near zero.
- **Introduction (paragraph 7):** Where the paper currently reports robustness results, add a sentence noting that the balanced-panel estimate is near zero and that the range of estimates (0.00 to 0.28) reflects the challenge of separating policy effects from T-MSIS reporting improvements.
- **Conclusion:** Revise from "a qualified yes" to language that acknowledges the bounded interpretation: the full-sample estimate suggests a positive effect, but the balanced-panel result means we cannot rule out that reporting artifacts account for much of the measured increase.
- **Discussion (Section 7.1, Interpreting the Magnitude):** Add a paragraph noting that the 33% headline figure should be interpreted as an upper bound. The true effect likely lies between the balanced-panel estimate (approximately 0%) and the full-sample estimate (33%).

**Feasibility:** HIGH -- rewriting and reframing existing text.

---

### 6. Additional Minor Improvements

**6a. Increase RI permutations** (Grok): Change from 200 to 1,000 in R code and re-run. Report updated p-value.

**6b. Specify bootstrap scheme** (GPT-5.2): Add a sentence in Section 5 or in table notes clarifying that bootstrap CIs use state-level block bootstrap (resampling states, not individual observations) to preserve within-state serial correlation.

**6c. Exhibit improvements** (Exhibit review): Consider adding a Post-PHE marker to Figure 1 (main event study); consider moving Figure 5 (contraceptive event study) and Figure 7 (RI histogram) to the appendix to tighten the main text.

**6d. Prose polish** (Prose review): Remove "Importantly" on p.5; sharpen the opening of Section 6.2; vary sentence length in conclusion per prose reviewer suggestions.

---

## Items Deferred to Future Revision

The following suggestions from referees are valuable but require substantial new data collection or analysis beyond the scope of this revision:

- **Broader outcome measures** (GPT-5.2): Constructing postpartum visit rates per 100 births, payment ($) outcomes, or broader code baskets requires re-pulling T-MSIS data with different aggregations.
- **County-level heterogeneity** (Grok): Using NPPES ZIP codes for rural/urban analysis requires substantial geographic data processing.
- **State reimbursement rate interaction** (Gemini): Merging Medicaid-to-Medicare fee ratios requires external data (Urban Institute/Kaiser) not currently in the pipeline.
- **Post-PHE bindingness interaction** (GPT-5.2): Estimating separate effects for pre- vs. post-April 2023 adopters within the CS-DiD framework requires restructuring the estimation.
- **NPI entity type decomposition** (GPT-5.2): Separating individual vs. organizational NPIs requires NPPES entity-type coding not currently used.

These are flagged for a potential v2 revision.

---

## Priority Order

1. Data Validity subsection (Item 1) -- addresses the central concern from all referees
2. Strengthen balanced-panel framing throughout (Item 5) -- ensures the paper's claims match the evidence
3. RI vs. conventional p-value explanation (Item 2) -- resolves a specific "red flag" from GPT-5.2
4. Literature citations (Item 3) -- straightforward additions
5. Code bundling discussion (Item 4) -- brief but important for Gemini
6. Minor improvements (Item 6) -- polish
