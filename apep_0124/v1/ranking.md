# Research Idea Ranking

**Generated:** 2026-01-31T20:52:52.802541
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6194

---

### Rankings

**#1: Close Referendum Losses and Subsequent Voter Turnout (RDD)**
- **Score: 76/100**
- **Strengths:** The “local winner vs local loser” framing in a setting where the *policy* outcome is national but the *psychological* win/loss is local is a clever and plausibly exogenous treatment at the 50% cutoff. Data are unusually rich (many referendums × many municipalities) and should support precise estimates and extensive falsification tests.
- **Concerns:** The biggest threat is that the running variable (municipal Yes share) is partly a proxy for unobserved mobilization/salience; if salience changes discretely at 50% (because communities interpret “we won” differently), that’s the mechanism—but you must show there’s no *other* discontinuity (e.g., recounts, media coverage rules, administrative actions) at 50%. Also, defining “thematically related” later votes risks researcher degrees of freedom unless pre-registered / rule-based.
- **Novelty Assessment:** **Moderately high.** Close-election RDD is extremely well-trodden, and “winner/loser effects” on attitudes/legitimacy are well-studied, but **using close local referendum win/loss to identify subsequent turnout dynamics across policy domains in Swiss direct democracy** is much less standard and likely publishable if executed tightly.
- **Recommendation:** **PURSUE (conditional on: (i) using raw vote counts to avoid rounding/heaping and running McCrary + balance tests; (ii) pre-specifying how “related topics” are classified; (iii) implementing strong placebo tests—e.g., fake cutoffs, outcomes in pre-period referendums, and unrelated-domain turnout).**

---

**#2: Language Border Voting Information Asymmetry (Spatial RDD)**
- **Score: 52/100**
- **Strengths:** Switzerland’s language boundary is a compelling natural setting, and restricting to **within-canton** language borders is a sensible way to reduce confounding from canton institutions/policy. Data are feasible (vote results + GIS + language classification) and results could be interpretable if the design is tightened.
- **Concerns:** Identification is the core weakness: language borders are not “as-good-as-random” assignment, and spatial RDD assumptions are easy to violate (sorting, discontinuities in geography, religion, settlement patterns, commuting zones, media markets). The “treatment” (information asymmetry) is also **not sharp**—bilingualism, cross-border media consumption, and national campaigns reduce the discontinuity and risk attenuation plus interpretational ambiguity (culture vs information).
- **Novelty Assessment:** **Low-to-moderate.** The Röstigraben is heavily documented; causal spatial-RD applications exist in related Swiss border contexts, so this can feel derivative unless you isolate a clearly asymmetric-information mechanism (e.g., referendums where campaign messaging differs sharply by language, measured via media text or ad buys).
- **Recommendation:** **CONSIDER (conditional on: (i) a clear, measurable “information shock” varying by language—media content, ad intensity, or timing; (ii) strong geographic covariate smoothness checks and alternative border specifications; (iii) demonstrating adequate sample mass near the border).**

---

**#3: Compulsory Voting Abolition and Long-Run Civic Engagement (DiD)**
- **Score: 41/100**
- **Strengths:** The question is important and potentially high-impact: whether compulsory voting creates durable participation norms is of real policy interest. Switzerland has rare institutional variation (staggered abolition; one canton retains compulsory voting), and historical turnout series for votes/elections are plausibly obtainable.
- **Concerns:** As currently framed (“turnout + civic membership + trust”), the DiD is likely to fail on *core* identification requirements: (i) **no credible control group for long-run civic culture outcomes** (surveys start in 1988, long after many abolitions), (ii) **policy endogeneity** (cantons may abolish in response to enforcement feasibility or participation trends), and (iii) many **concurrent long-run political changes** (suffrage expansions, party system changes, media, education, migration) confound “civic culture” trends over decades.
- **Novelty Assessment:** **Moderate.** Compulsory voting effects are extensively studied internationally; Switzerland/Schaffhausen is studied, but “abolition long-run civic culture” is less directly covered. Novelty can’t compensate for weak DiD fundamentals here.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Weak** for civic engagement/trust (survey series begins 1988, so most abolitions have *no* pre-periods); **Strong** only if restricted to turnout outcomes with long historical data.
  - **Selection into treatment:** **Marginal → Weak** (likely endogenous abolition tied to enforcement costs, political pressure, or turnout/legitimacy trends).
  - **Comparison group:** **Weak** as proposed (effectively one never-treated canton, Schaffhausen; very thin support). “Not-yet-treated” comparisons could help for turnout, but for long-run culture outcomes you still lack credible pre-trends.
  - **Treatment clusters:** **Strong** (many cantons change policy; cluster count is not the main problem).
  - **Concurrent policies:** **Weak** over 1920s–1970s horizons (multiple institutional and social changes plausibly affect turnout/civic culture simultaneously).
  - **Outcome-Policy Alignment:** **Strong** for turnout; **Marginal** for “civic membership/trust” (measured much later and may reflect many intervening forces beyond compulsory voting).
  - **Data-Outcome Timing:** **Marginal** (turnout measured on vote dates is fine if abolition effective dates are precisely coded; for survey outcomes decades later, timing is conceptually misaligned with a clean “post” period and susceptible to accumulated confounding).
  - **Outcome Dilution:** **Strong** (policy applies broadly to eligible voters; not a targeted subpopulation).
- **Recommendation:** **SKIP (unless re-scoped).** A salvageable version would: (i) focus narrowly on turnout in elections/referendums with many pre-periods; (ii) use modern staggered-adoption estimators (Sun–Abraham / Callaway–Sant’Anna); (iii) explicitly address endogeneity (e.g., instrument with enforcement-capacity shocks or legal/court discontinuities—if they exist); and (iv) avoid “trust/membership” unless you can assemble pre-treatment civic data.

---

### Summary

This is a strong batch in terms of creative use of Swiss institutions and data, but only **Idea 1** currently combines novelty, clean identification, and high feasibility without major inferential fragility. **Idea 3** is feasible but needs a sharper treatment definition and stronger validation to overcome spatial-RD skepticism. **Idea 2** fails key DiD checklist items (especially pre-trends for civic outcomes and control group credibility) and should be dropped or substantially redesigned.