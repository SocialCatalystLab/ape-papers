# Research Idea Ranking

**Generated:** 2026-02-21T16:20:25.409716
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 5159

---

### Rankings

**#1: The Convergence of Gender Attitudes: Forty Years of Swiss Municipal Referenda**
- **Score: 74/100**
- **Strengths:** Exceptionally rich, underused revealed-preference data (municipality vote shares) over a very long horizon with large N, enabling precise documentation of persistence vs. convergence in gender-related political attitudes. The “β-convergence of norms” framing plus falsification on non-gender referenda is a clean, publishable contribution even if interpreted as persistence patterns rather than strict causality.
- **Concerns:** The core estimand is not inherently causal—1981 “progressivism” is a baseline trait, and AIPW cannot rescue violations of unconfoundedness (deep cultural/geographic factors may drive both 1981 and 2020 votes). Language region/canton political culture may mechanically account for most persistence; if so, the incremental insight beyond “geography predicts politics” could be limited without strong within-region designs.
- **Novelty Assessment:** **High.** There is a broad literature on cultural persistence and on Swiss direct democracy, but *municipality-level long-run persistence/convergence of gender attitudes using multiple gender referenda as revealed preferences* is not (to my knowledge) a crowded or “100-papers-already” topic.
- **Recommendation:** **PURSUE (conditional on: (i) pre-specifying “within language-region” and “within-canton” analyses as primary; (ii) showing robustness to municipality mergers/harmonization choices; (iii) making the interpretation explicit as persistence/convergence rather than causal “effects” unless you add a stronger quasi-experiment).**

---

**#2: The Röstigraben Effect on Gender Policy: Cultural Discontinuity Across Swiss Language Borders**
- **Score: 67/100**
- **Strengths:** Among the three, this has the most promising path to *credible causal identification* because sharp cultural borders can approximate a spatial discontinuity design; the question “is the gap narrowing over time?” is policy- and society-relevant. Border restriction naturally improves comparability versus national cross-sectional regressions.
- **Concerns:** As proposed, it stops short of a true spatial RDD and instead uses AIPW, which reintroduces functional-form and selection concerns; the design is only as good as the claim that nothing else jumps at the border. A major risk is **confounding by canton boundaries/policies** (taxes, education, family policy, church-state relations) that may coincide with parts of the language border; small sample near the border also raises precision and specification sensitivity issues.
- **Novelty Assessment:** **Moderate.** The Röstigraben is heavily studied (labor markets, welfare preferences, etc.). The *gender-referenda panel* angle is plausibly new, but you’ll need to differentiate clearly from the existing “language border as culture” canon.
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: (i) you implement a bona fide spatial RDD / local randomization design with pre-registered bandwidth rules; (ii) you prioritize border segments within the same canton or otherwise transparently net out canton-policy discontinuities; (iii) you run density/manipulation analogs and balance tests on predetermined covariates at the border).**

---

**#3: Religion, Secularization, and Gender Progressivism in Swiss Municipalities**
- **Score: 54/100**
- **Strengths:** Strong face validity and good data availability; combining referendum outcomes with changing local religious composition can descriptively illuminate whether compositional change vs. within-group attitude change correlates with shifting gender-policy support. Large sample provides power for heterogeneity and decomposition exercises.
- **Concerns:** Identification is the weakest of the three: religious composition is plausibly endogenous to migration/sorting and to broader modernization trends that also drive gender attitudes (education expansion, urbanization, sectoral change), so even “historical shares” may proxy persistent unobservables rather than causal religious influence. The “religion → gender attitudes” link is widely studied in adjacent fields, so the marginal contribution may look incremental unless you add a sharper instrument or quasi-experiment.
- **Novelty Assessment:** **Moderate-to-low.** Many papers in political economy/sociology link Catholicism/secularization to social policy and gender attitudes; using Swiss municipal referenda is a nice data twist, but the underlying relationship is well-trodden.
- **Recommendation:** **SKIP (unless you can add a stronger design—e.g., plausibly exogenous historical instruments tied to Reformation-era exposure or church institutions, and a clear case that these shift religion without directly shifting modern gender-policy preferences except through religion).**

---

### Summary

This is a solid batch with unusually strong Swiss municipal data and a coherent theme. **Idea 1** is the best bet on novelty + feasibility and can yield a valuable “mapping and persistence” paper if framed honestly; **Idea 2** could become the best *causal* paper if redesigned as a proper spatial discontinuity study that convincingly rules out canton-policy confounding. **Idea 3** is likely to face “endogeneity + already-known relationship” skepticism unless paired with a much sharper identification strategy.