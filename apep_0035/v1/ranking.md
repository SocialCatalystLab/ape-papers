# Research Idea Ranking

**Generated:** 2026-01-19T03:18:31.801749
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4266
**OpenAI Response ID:** resp_0d0609d7d403124d00696d944bb5588193ae927d1f2b18ef35

---

### Rankings

**#1: Women’s Suffrage and Female Labor Force Participation**
- **Score: 68/100**
- **Strengths:** Clear, policy-salient question with unusually strong “never-treated” comparison group (33 states pre-1920) and good outcome measurement (female LABFORCE) in full-count IPUMS. The ability to use linked individuals (HISTID) is a real upgrade over typical state-level DiD in this era.
- **Concerns:** Identification hinges on parallel trends despite strong selection into early suffrage (western/progressive states) and potentially different contemporaneous shocks (sectoral composition, migration/frontier dynamics). The decennial structure (few pre/post points and treatment timing between censuses) makes pre-trend assessment and dynamic effects harder, and linkage may induce nonrandom sample selection.
- **Novelty Assessment:** **Moderately novel.** Suffrage has a large literature on public spending/policy and longer-run outcomes; **female labor supply is less saturated**, but not untouched—expect some related work and close substitutes.
- **Recommendation:** **PURSUE** (but design it around robustness to differential trends: region×year trends, border-pair analyses, and restricting to the 1910–1918 wave).

---

**#2: State Prohibition and Male Labor Market Outcomes**
- **Score: 61/100**
- **Strengths:** Many treated states and a meaningful set of never-treated controls before federal prohibition provide decent leverage for staggered-adoption DiD. The question is policy-relevant (alcohol regulation) and could speak to current debates about substance controls and labor market functioning.
- **Concerns:** Key outcomes for prime-age men (LFP) are near-saturated historically, limiting signal; occupational “stability” is also noisy at decennial frequency. Identification is threatened by concurrent nationwide shocks that are hard to net out with census timing (WWI mobilization, 1918 influenza, pre-trends in industrialization/urbanization), plus major heterogeneity in enforcement and “dry” intensity within states.
- **Novelty Assessment:** **Somewhat novel.** Prohibition is well-studied for consumption/health/crime, but **male labor-market impacts at the state-law margin are less central**—still, you’ll be competing with a nontrivial economic history literature on prohibition’s effects.
- **Recommendation:** **CONSIDER** (stronger if you can proxy enforcement/intensity and focus on plausibly affected subgroups/industries rather than overall male LFP).

---

**#3: Workers’ Compensation and Occupational Risk-Taking**
- **Score: 53/100**
- **Strengths:** Interesting mechanism (insurance → risk-taking/sectoral reallocation) and broad policy rollout across states provides variation. Full-count IPUMS enables large samples and subgroup analysis by age/industry/immigrant status.
- **Concerns:** No never-treated states means identification relies heavily on timing assumptions; early-adopter vs late-adopter comparisons are likely confounded by differential industrialization, unionization, and Progressive Era reforms. Constructing an “occupation risk” index from OCC1950 is nontrivial (measurement error and researcher discretion), and wage/income measurement is limited pre-1940, pushing you toward imputed earnings indices that may themselves be endogenous to changing occupational composition.
- **Novelty Assessment:** **Low-to-moderate novelty.** Workers’ compensation has a **large existing literature** (historical and modern) on wages, employment, and safety; “occupational risk-taking” is a somewhat newer angle but close to well-trodden margins (compensating differentials, injury risk, industry mix).
- **Recommendation:** **CONSIDER** only if you can pre-register/externally validate the risk measure and tighten identification (e.g., border-county designs, industry-specific exposure, or exploiting sharp benefit-schedule discontinuities if available).

---

**#4: Compulsory Schooling and Child Labor Force Participation (RDD)**
- **Score: 37/100**
- **Strengths:** The causal question is classic and policy-relevant, and both SCHOOL and LABFORCE are observable in the census. In principle, an age-threshold design is attractive.
- **Concerns:** With age measured in years (not months/days), the running variable is coarse, inviting heaping and weak RDD diagnostics; compliance/enforcement is historically uneven, so the design is unlikely to be “sharp.” Most importantly, this space is extremely crowded (schooling laws/child labor using age cutoffs and related IV/RD strategies), so incremental contribution is likely low unless you have a truly distinctive twist (e.g., new administrative enforcement data or a uniquely binding threshold).
- **Novelty Assessment:** **Very low novelty.** Compulsory schooling/child labor is among the most-studied identification problems in applied micro; an RDD of this form will look derivative unless it brings new data or a new institutional discontinuity.
- **Recommendation:** **SKIP** (unless you can access higher-frequency age data or an unusually sharp enforcement discontinuity).

---

### Summary
This is a solid batch in terms of feasibility (IPUMS full count + HISTID), but identification is the main differentiator: decennial timing and endogenous policy adoption loom large. The suffrage project is the best combination of novelty, feasible outcomes, and credible comparison group—start there, with explicit strategies to address western/progressive differential trends; prohibition is the next-best backup if you can sharpen exposure and outcomes beyond overall male LFP.