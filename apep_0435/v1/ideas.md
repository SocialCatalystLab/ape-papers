# Research Ideas — Switzerland + Gender (DR)

## Idea 1: The Convergence of Gender Attitudes: Forty Years of Swiss Municipal Referenda

**Policy:** Switzerland's unique direct democracy produces a continuous revealed-preference record of gender attitudes. Gender-relevant federal referenda span 1981–2021: the 1981 Gleichstellungsartikel (equal rights, 60.3% yes), the 1984 maternity insurance initiative (rejected 84.3%), the 1999 maternity insurance (rejected 61.1%), the 2004 maternity insurance (approved 55.5%), the 2020 paternity leave (approved 60.3%), and the 2021 same-sex marriage (approved 64.1%). Each provides Gemeinde-level YES shares for ~2,100 municipalities.

**Outcome:** Gemeinde-level YES vote shares on gender-relevant referenda 2004–2021 (swissdd R package, verified available from 1981-present at municipal level). Specifically: maternity insurance 2004, paternity leave 2020 (vote #634.00), same-sex marriage 2021. Non-gender referenda for falsification (e.g., military, agriculture, immigration votes from the same years).

**Identification:** Doubly Robust / AIPW estimation. The core question: does 1981 gender progressivism (Gleichstellungsartikel YES share) predict 2020/2021 gender policy preferences, conditional on observable municipality characteristics? Treatment is continuous (1981 YES share). AIPW combines a propensity model (P[high progressivism | X]) with an outcome model (E[2020 YES share | treatment, X]). Controls include language region (French/German/Italian/Romansh), religious composition (Catholic/Protestant share from BFS), population density, urban/rural classification, altitude, cantonal fixed effects, and employment structure. Double robustness: consistent if either the treatment model or the outcome model is correctly specified.

Secondary analysis tests β-convergence: do initially conservative municipalities "catch up" to progressive ones over time? This applies the Barro–Sala-i-Martin convergence framework to political attitudes — regressing the change in gender progressivism (Δ vote share, 1981→2020) on the initial level (1981 share). Negative β = convergence; positive β = divergence.

**Why it's novel:**
1. **No existing study** measures persistence of gender norms using municipal referendum data across 2,100+ municipalities over 40 years. The closest work is Slotwinski & Stutzer (2023, EJ), who use Swiss cantonal suffrage staggering to study female LFP and marriage — but they study behavioral outcomes of suffrage, not the persistence of political attitudes.
2. **Revealed preferences >> survey data.** Most persistence-of-culture studies use survey measures (e.g., World Values Survey). Swiss referenda capture actual consequential votes — not what people say they believe, but how they vote when it matters.
3. **β-convergence of political attitudes** is unstudied. Growth economists have studied income convergence exhaustively; applying the same framework to gender norms is genuinely new.
4. **Falsification with non-gender referenda** tests whether persistence is specific to gender norms or reflects general political inertia. If military/agriculture votes show similar persistence, the story is less about gender norms and more about political culture.
5. **Mechanism channel.** Can test whether cantonal suffrage timing (treatment at canton level) mediates the persistence relationship — building on but extending Slotwinski & Stutzer.

**Feasibility check:**
- ✅ Variation: Massive cross-Gemeinde variation in YES shares (e.g., paternity leave 2020 ranged from ~30% to >80% across municipalities).
- ✅ Data: swissdd gives 1981-present at Gemeinde level; BFS PXWeb API for covariates; SMMT for merger harmonization. All publicly accessible, no API keys needed.
- ✅ Novelty: Not in APEP list (no Swiss/gender papers). Not overstudied — persistence of gender norms using referendum data is novel.
- ✅ Sample: ~2,100 Gemeinden provides excellent power for DR estimation.
- ✅ Method: DR/AIPW is the natural fit for cross-sectional observational comparison with rich controls.

**Key risks:** (1) Language region may absorb most variation — if French-speaking ≈ progressive and German-speaking ≈ conservative, the "persistence" is really just geography. Mitigation: cantonal FE + within-language-region analysis. (2) Gemeinde mergers require harmonization (3,095 Gemeinden in 1981 → ~2,100 today). Mitigation: SMMT R package provides concordance tables. (3) The unconfoundedness assumption is untestable. Mitigation: sensitivity analysis (Oster 2019 δ, Cinelli & Hazlett 2020 partial R²).

---

## Idea 2: The Röstigraben Effect on Gender Policy: Cultural Discontinuity Across Swiss Language Borders

**Policy:** The Röstigraben (French-German language border) creates a sharp cultural discontinuity across Swiss municipalities. French-speaking cantons adopted women's suffrage 10+ years earlier (Vaud/Neuchâtel 1959 vs. most German cantons 1971) and consistently vote more progressively on gender issues. But is this a fixed cultural cleavage, or has the gap narrowed?

**Outcome:** Gemeinde-level YES shares on gender referenda (1981–2021) for municipalities within 30km of the French-German language border. The language border provides a sharp spatial discontinuity: adjacent municipalities share labor markets and infrastructure but differ in language-culture.

**Identification:** Spatial DR at the language border. Rather than classic spatial RDD (which requires a running variable), I use AIPW comparing French-speaking border municipalities to German-speaking border municipalities, controlling for distance to border, altitude, population, cantonal policies, and economic structure. The DR estimand captures the causal effect of language-culture on gender policy preferences, robust to either model misspecification.

Panel extension: repeat the spatial DR for each gender referendum (1981, 2004, 2020, 2021) to test whether the Röstigraben gap is closing, stable, or widening.

**Why it's novel:** The Röstigraben has been extensively studied for unemployment (Brügger, Lalive & Zweimüller 2011), welfare preferences (Eugster et al. 2011), and working mothers/childlessness (Steinhauer). But no one has tracked the gender norm gap specifically using a 40-year panel of gender-relevant referenda. The panel dimension — does the gap close? — is the key contribution.

**Feasibility check:**
- ✅ Data: swissdd + BFS, same infrastructure as Idea 1.
- ✅ Variation: Well-documented 10-20 percentage point gap at the border.
- ⚠️ Sample: Border municipalities only (~200-400), smaller than Idea 1.
- ✅ Novelty: Panel of Röstigraben gender gap is new.
- ⚠️ Existing literature: Extensive Röstigraben studies — must differentiate clearly.

---

## Idea 3: Religion, Secularization, and Gender Progressivism in Swiss Municipalities

**Policy:** Switzerland's religious composition (historically Catholic vs. Protestant) has been a powerful predictor of gender attitudes. Catholic cantons were among the last to adopt women's suffrage (Appenzell Innerrhoden, 1990). But Switzerland has undergone rapid secularization since the 1970s — the share reporting "no religion" rose from <2% in 1970 to >28% by 2020. Does secularization explain convergence in gender attitudes?

**Outcome:** Gemeinde-level YES shares on gender referenda (1981–2021). Religious composition from BFS census/structural survey (Catholic share, Protestant share, no-religion share) at Gemeinde level for multiple time points.

**Identification:** AIPW/DR estimating the effect of religious composition (continuous treatment: Catholic share) on gender policy preferences, controlling for language, urbanization, education, income, and cantonal FE. The panel structure allows testing whether the religion effect has weakened as secularization progresses.

Mediation analysis: Does the declining Catholic share mechanically explain convergence in gender attitudes? Decompose the change in vote shares into (a) within-religion attitude shifts and (b) compositional shifts from secularization.

**Why it's novel:** While the Catholic-Protestant cleavage in Swiss politics is well-known, no study has used AIPW/DR to isolate the religion effect on specifically gender-relevant referenda across 40 years, nor decomposed the role of secularization in gender norm convergence.

**Feasibility check:**
- ✅ Data: BFS provides religious composition at Gemeinde level for census years (1970, 1980, 1990, 2000) and structural survey (2010+). swissdd for referendum data.
- ✅ Variation: Catholic share ranges from <5% (some Protestant cantons) to >90% (Uri, Schwyz, Obwalden).
- ✅ Sample: ~2,100 Gemeinden.
- ⚠️ Endogeneity: People sort across municipalities by preferences. Mitigation: use historical (1970) religious composition as pre-determined "treatment."
- ⚠️ Novelty: Religion-gender link is well-studied in sociology. Economic contribution is the AIPW method + revealed preferences.

---

## Ranking Summary

| Idea | Novelty | Identification | Feasibility | Power | Overall |
|------|---------|---------------|-------------|-------|---------|
| 1. Convergence | ★★★★★ | ★★★★ | ★★★★★ | ★★★★★ | **Best** |
| 2. Röstigraben | ★★★ | ★★★★ | ★★★★ | ★★★ | Good backup |
| 3. Religion | ★★★ | ★★★ | ★★★★ | ★★★★★ | Decent |

**Recommendation:** Idea 1 (Convergence) is the strongest candidate. It's genuinely novel, uses massive public data, and the β-convergence framing adds theoretical depth. The falsification test (gender vs. non-gender referenda) strengthens identification. DR/AIPW is methodologically appropriate.
