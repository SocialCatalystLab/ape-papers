# Reply to Reviewers — apep_0238 v3

**Paper:** "Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets"
**Date:** 2026-02-12
**Revision round:** 1

We thank all reviewers for their careful reading and constructive feedback. Below we address each concern point by point. Changes are referenced by the revision plan item numbers (C = Critical, I = Important, N = Nice-to-have).

---

## Reply to GPT-5-mini (Decision: Major Revision)

### 1. Format Check

> "The LaTeX calls \bibliography{references} but that file is not included in the source you provided. Please ensure the .bib file is included in resubmission."

**Response:** The references.bib file is included in the submission package. The reviewer was evaluating the LaTeX source without access to the companion .bib file. No action needed; the compiled PDF includes the full bibliography (pages 44-49 as confirmed by Gemini).

> "Ensure all figure files are embedded... has labeled axes including units, has a clear legend if multiple lines appear, shows 95% confidence intervals when reported, and is legible in grayscale."

**Response:** All figures in the compiled PDF have labeled axes with units, legends for multi-line plots, and 95% confidence intervals where applicable. We will verify grayscale legibility in the revision. [N4]

> "All regression tables must show coefficients with standard errors (or CIs), sample sizes N, and R^2 where appropriate."

**Response:** All regression tables report coefficients, HC1 standard errors in parentheses, permutation p-values in brackets, sample sizes, and R-squared values. We will expand table notes to make this clearer. [I6]

### 2. Statistical Methodology

> **2A.** "Explicit first-stage regressions where exposure predicts the local employment decline... Report F-statistics (or effective partial R^2)... A clear statement of the estimand."

**Response:** We add a paragraph clarifying that the LP estimates are reduced-form effects of exogenous exposure, not IV-LATE parameters. The R-squared values (0.10-0.13) for the relationship between exposure and initial employment decline are documented. We explicitly state the estimand as an intent-to-treat parameter. [C2, I2]

> **2B.** "Report permutation p-values... for key horizons... present results using the Adao-Kolesar-Morales (AKM) exposure-robust standard errors explicitly... When clustering by division, justify the choice of cluster level and discuss the implications of too-few clusters (9). Consider wild cluster bootstrap."

**Response:** Permutation p-values are reported in brackets in Table 3 for all horizons. We add discussion of AKM inference and its relationship to our permutation approach, noting that both address the finite-sample concerns inherent in shift-share designs. Regarding wild cluster bootstrap with 9 divisions: we discuss its infeasibility (too few clusters for reliable bootstrap inference) and note that permutation tests are the preferred small-sample method. [C1, I1]

> **2C.** "Add the Goldsmith-Pinkham, Sorkin & Swift (2020) discussion... Report the distribution of national industry shocks (g_j) and the exposure shares... Present an industry-level placebo."

**Response:** We add citations to Goldsmith-Pinkham et al. (2020) and discuss the Bartik instrument's properties. We add a paragraph discussing the distribution of industry shocks and noting the leave-one-out construction that ensures no single industry drives the results. The leisure/hospitality sector's dominance in COVID exposure is the identifying variation, consistent with the supply-shock interpretation. [C7, I3]

> **2D.** "Address potential serial correlation across horizons in the LP IRF inference... discuss how multiple-horizon inference is handled (multiple testing)."

**Response:** We add a discussion noting that each horizon is estimated independently (cross-sectional regressions), so serial correlation across horizons is not a standard concern. The consistent pattern of persistent negative coefficients across all post-recession horizons for the Great Recession provides joint evidence stronger than any single horizon. Permutation tests assess the full coefficient path. [I5]

> **2E.** "Include state-level measures of fiscal support intensity (PPP loans per capita, CARES Act transfers)... For the Great Recession, include ARRA intensity measures by state."

**Response:** We expand the discussion of policy confounding. Controlling for fiscal support intensity would introduce post-treatment bias since policy response is endogenous to shock type — supply shocks invite targeted, temporary programs (PPP) while demand shocks invite delayed, broader fiscal stimulus (ARRA). The paper's core argument is precisely that shock type determines both the recovery path and the policy response. We acknowledge this as a fundamental identification challenge and discuss it transparently. [C3]

> **2F.** "Include net migration flows by state... report results controlling for net domestic out-migration during the recovery."

**Response:** We expand the migration discussion. Migration could attenuate measured scarring (workers leaving depressed areas improve remaining employment-to-population ratios), so our estimates are if anything conservative. We cite Yagan (2019), who demonstrates individual-level scarring persists even controlling for migration. We acknowledge this as a limitation of state-level analysis while noting that the aggregate perspective captures equilibrium effects including migration responses. [C6]

> **2G.** "Add an individual-level mediation analysis using CPS micro-data... show that in states with larger housing exposure, long-term unemployment shares and duration increased more."

**Response:** This is an excellent suggestion that would strengthen the paper. However, it requires substantial new data collection and analysis (CPS micro-data extraction, individual-level regression). We note this as an important avenue for future work. The current paper provides state-level evidence on unemployment duration and LFPR that is consistent with the proposed mechanism. [Out of scope for text-only revision]

> **2I.** "Provide CIs or sensitivity ranges for these model-based statistics... Some sensitivity analysis is present (appendix), but add confidence / robustness statements to the welfare numbers in the main text."

**Response:** We add an explicit caveat paragraph in the welfare discussion noting that magnitudes depend on calibration assumptions (risk neutrality, discount rate, skill depreciation rate). We reference the appendix sensitivity analysis (Tables 11 and 16) and state that the welfare comparisons should be interpreted as illustrative of the asymmetry's economic magnitude rather than precise point estimates. [C5]

### 3. Identification Strategy

> "Exogeneity of the housing boom: strengthen with additional controls for pre-boom labor market trends, construction employment shares, or supply elasticity proxies (Saiz 2010)... a placebo test using alternative pre-boom windows."

**Response:** We expand the exogeneity discussion, referencing the Mian-Sufi literature that establishes housing boom exogeneity through credit supply channels. The pre-trend tests (Figure 1) show no divergence before the boom. We note that Saiz (2010) housing supply elasticity measures and pre-boom employment growth controls are natural robustness checks and discuss their relationship to the existing leave-one-out and Sand State exclusion results. [I4]

> "Omitted variables correlated with exposure and long-run outcomes: examples include industry composition, demographic change, state-level policy responses."

**Response:** We discuss these potential confounders and note that our controls (pre-recession employment growth, population, regional fixed effects) absorb much of this variation. The subsample robustness results (excluding Sand States, alternative base years) provide evidence that results are not driven by specific state characteristics. [I4]

### 4. Literature

> "Please add at least the following: Callaway & Sant'Anna (2021), Goodman-Bacon (2021), Adao et al. (2019), Borusyak et al. (2022), Goldsmith-Pinkham et al. (2020), Jorda (2005)."

**Response:** We add all suggested citations. For Callaway-Sant'Anna and Goodman-Bacon, we add a sentence explaining why staggered DiD methods are not applicable (the paper uses cross-sectional LP with continuous exposure, not panel TWFE). For shift-share references, we cite in the inference discussion. Jorda (2005) is already cited; we ensure the citation is complete. [C7]

### 5. Writing Quality

> **5a.** "Add a short roadmap paragraph."

**Response:** The prose reviewer recommends removing the existing roadmap. We follow the prose reviewer's advice, as the narrative flow is strong without an explicit roadmap. We ensure section transitions remain clear. [N1]

> **5b.** "Give a one-paragraph intuitive explanation near the empirical strategy for why a cross-sectional LP is preferred over panel TWFE."

**Response:** This intuition is provided in Section 5.1. We expand slightly to be more explicit for non-specialist readers. [I2]

> **5c.** "Make sure captions are fully informative... expand them for readers."

**Response:** We review and expand table notes throughout. [I6]

> **5d.** "Provide more intuition and a sensitivity paragraph... about how modeling assumptions drive these large magnitudes."

**Response:** Addressed in C5 above.

### 6. Constructive Suggestions

> "Individual-level mediation... Control for state-level policy response... Implement a two-stage LP (LP-IV)... Add migration controls... Present more granular heterogeneity."

**Response:** These are valuable suggestions for strengthening the empirical analysis. The individual-level mediation, LP-IV, migration controls, and granular heterogeneity analyses all require new data and code. We note these as important directions for future work. The text-only revisions strengthen the conceptual arguments around these channels. [Out of scope for text-only revision]

> "Provide confidence ranges for welfare decomposition... Compare calibrated model's implied long-term unemployment distribution to the data."

**Response:** We add caveats and reference the existing sensitivity analysis. The unemployment distribution comparison is an excellent suggestion for future model validation. [C5]

---

## Reply to Grok-4.1-Fast (Decision: Minor Revision)

### 2. Statistical Methodology

> "Small N=48-50 risks low power... Suggest wild bootstrap in revision for extra rigor (feasible with 9 divisions)."

**Response:** We add discussion of wild bootstrap feasibility. With only 9 census divisions, wild cluster bootstrap inference is unreliable (Cameron, Gelbach, and Miller 2008 recommend at least 20-30 clusters). Permutation inference is the preferred approach for our setting and already confirms the HC1 results. [I1]

### 3. Identification Strategy

> "Add Sunspot/Ramey-Plosser placebo (pre-2000 housing-LP) for GR; Borusyak et al. (2022) estimator for Bartik."

**Response:** The pre-2000 housing placebo is an excellent suggestion that would require historical data construction. We note this as future work. The Borusyak et al. estimator citation is added to the methodology discussion. [C7, out of scope for code changes]

### 4. Literature

> "Missing: Ramey and Zubairy (2018), Plagborg-Moller and Wolf (2021), Jorda-Schularick-Taylor (2013), Gupta-Grossman-Sant'Anna (2023)."

**Response:** We add all four citations. Ramey-Zubairy is cited in the LP methodology discussion to justify LP over VAR for nonlinear dynamics. Plagborg-Moller-Wolf strengthens the small-N inference defense. Jorda-Schularick-Taylor is a direct precursor for cross-event LP comparison. Gupta-Grossman-Sant'Anna is cited for recent Bartik advances. [C7]

### 5. Writing Quality

> "Minor repetition (scarring defined 5x); tighten Conclusion limitations (1 para)."

**Response:** We define "scarring" precisely once in the Introduction and remove redundant definitions elsewhere. The conclusion limitations paragraph is compressed. [N7, N8]

### 6. Constructive Suggestions

> "Worker-level CPS mediation... net migration (BLS/IRS)... Pre-1980 housing-LP placebo... VAR-LP comparison... UK/EU cross-country... policy counterfactuals (no-PPP sim)."

**Response:** These are all excellent extensions. The CPS mediation, migration data, pre-1980 placebo, VAR-LP comparison, and cross-country analysis all require new data and estimation. The no-PPP simulation requires model modification. We note these as promising avenues for future work. [Out of scope for text-only revision]

> "Lead Intro with welfare (147:1) for punch; policy box."

**Response:** We feature the 147:1 ratio more prominently in the conclusion and consider adding it to the abstract if the 150-word limit permits. [N9]

> "Decompose GR/COVID via JOLTS flows in LP (state JOLTS?); richer model (firm het, per Jarosch 2023)."

**Response:** State-level JOLTS is limited (only available for a subset of states). We discuss this limitation in the mechanisms section. The firm heterogeneity extension is noted as future model development. [Out of scope]

---

## Reply to Gemini-3-Flash (Decision: Minor Revision)

### 3. Identification Strategy

> "The author acknowledges that the 'clean' demand/supply dichotomy is an abstraction."

**Response:** We appreciate the reviewer's recognition that the demand/supply labels are validated through JOLTS data and the structural model. No additional action needed beyond the existing discussion.

### 4. Literature

> "The paper would benefit from engaging more deeply with the 'Plucking' models of recessions... Dupraz, Nakamura, and Steinsson (2024)."

**Response:** Dupraz et al. is already in the bibliography. We integrate it more deeply into the structural model discussion, noting that the plucking model's prediction of asymmetric recoveries is consistent with our finding that supply shocks "bounce back" while demand shocks do not. [C7]

### 6. Constructive Suggestions

> "Migration Interaction: I suggest a 'migration-adjusted' employment outcome to see if the scarring is purely a 'place-based' effect or if it follows the 'people.'"

**Response:** Addressed in our expanded migration discussion. Constructing migration-adjusted employment requires individual-level or flow data that is beyond the scope of the current state-level analysis. We cite Yagan (2019) who provides this individual-level perspective and confirms worker-level scarring. [C6]

> "Model vs. Data Divergence: In Figure 8, the model for the demand shock deepens much more aggressively than the LP data markers at the 100-month horizon."

**Response:** We add a paragraph discussing this divergence. The model abstracts from mean-reverting forces that operate at very long horizons (new labor market entrants, slow housing normalization, delayed fiscal stimulus). The model captures the scarring mechanism but intentionally does not model all recovery forces, which is why it overpredicts persistence beyond h = 80 months. This is an honest limitation of the stylized DMP framework. [C4]

> "Fiscal Policy Decomposition: A more formal mediation analysis (perhaps using state-level ARRA or PPP disbursement amounts) could strengthen the claim."

**Response:** Addressed in our expanded policy discussion. We argue that conditioning on policy intensity introduces post-treatment bias and that the paper's contribution is precisely to show that shock type determines both recovery dynamics and policy responses. [C3]

---

## Reply to Exhibit Review — Gemini (Round 1)

> "Figure 1: Increase the font size of the axis labels and titles."

**Response:** We will increase font sizes in Figure 1 when implementing code changes. [N4, deferred to code stage]

> "Figure 6: Move to Appendix. While helpful, these are 'fact-establishing' plots of raw national data."

**Response:** We agree and will move Figure 6 to the appendix, referencing it from the main text. This frees space for additional discussion. [N2]

> "Figure 13: Remove. Redundant with Table 11."

**Response:** We agree and will remove Figure 13. Table 11 provides the same sensitivity information more precisely. [N3]

> "Missing: A 'Figure 0' or 'Conceptual Sketch' showing the theoretical mechanism (the skill depreciation loop)."

**Response:** This is a creative suggestion. Creating a new conceptual figure is beyond the scope of the current text-only revision but is noted for future improvement. [Out of scope]

---

## Reply to Prose Review — Gemini (Round 1)

> **Improvement 1:** "In Section 3.8, replace 'A permanent reduction in a (demand shock) lowers the right-hand side' with a more Glaeser-esque narrative."

**Response:** We adopt this suggestion, replacing formal model language with more vivid intuition in the key transitional paragraphs. [N5]

> **Improvement 2:** "Eliminate Roadmap: Delete the final paragraph of the Introduction ('This paper contributes to four literatures...'). Instead, weave those contributions into the discussion of results."

**Response:** We adopt this suggestion. The literature contribution paragraph is removed from the Introduction and the specific contributions are woven into the relevant results and discussion sections where they feel "earned." [N1]

> **Improvement 3:** "Table Narration: Replace 'Table 3 presents the central results. Panel A reports...' with 'The persistent damage of the housing bust is documented in Table 3.'"

**Response:** We adopt this suggestion, leading with findings rather than table references throughout the results sections. [N6]

> **Improvement 4:** "Active Voice Check: 'The Bartik results are qualitatively similar but attenuated' could be 'The Bartik instrument yields similar, though attenuated, results.'"

**Response:** We adopt this and similar active voice improvements throughout the results and robustness sections. [N6]

> **Improvement 5:** "Contextualizing Welfare: The 147:1 welfare loss ratio is a 'wow' number. Lead with it more aggressively in the abstract and conclusion."

**Response:** We feature the welfare asymmetry more prominently in the conclusion's policy implications. We consider adding it to the abstract within the 150-word constraint. [N9]

> **Overall weakness:** "The structural model section occasionally lapses into 'Value Function prose.' The transition from vivid reduced-form results back into Bellman equations can feel slightly jarring."

**Response:** We add a bridging paragraph before the formal model section that connects the empirical findings to the model's purpose, easing the transition from reduced-form evidence to structural analysis. [N5]

---

## Summary of Responses

| Category | Count | Status |
|----------|-------|--------|
| Addressed in text revision | 22 | Will implement |
| Out of scope (requires new analysis) | 10 | Noted as future work |
| No action needed | 3 | Already in paper |
| **Total concerns raised** | **35** | |
