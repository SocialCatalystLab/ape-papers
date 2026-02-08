# Research Idea Ranking

**Generated:** 2026-02-03T19:21:01.307813
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 4559

---

### Rankings

**#1: Salary History Bans and Wage Compression**
- **Score: 69/100**
- **Strengths:** Good policy variation (≈22 adopting states, staggered timing) and extremely feasible wage microdata (ACS/IPUMS) make this implementable and potentially publishable. The *inequality/compression* angle is more novel than the well-trodden gender-gap focus.
- **Concerns:** The outcome is likely **highly diluted** if computed on *all* workers (most workers are not job switchers/applicants in a given year), pushing estimates toward zero. Adoption correlates with progressive policy bundles (pay transparency, equal-pay enforcement, minimum wage hikes), raising serious **concurrent-policy** and **selection** concerns unless explicitly addressed.
- **Novelty Assessment:** **Moderately novel.** Salary history bans have an existing literature (esp. gender wage gaps, hiring), but “overall wage dispersion/compression” is less studied and could add value if executed carefully.
- **DiD Assessment (CS / staggered adoption):**
  - **Pre-treatment periods:** **Strong** (ACS allows long pre-period; you can easily get 5+ years pre for most adopters).
  - **Selection into treatment:** **Marginal** (adoption plausibly related to political ideology and pre-existing wage-inequality/gender-equity trends).
  - **Comparison group:** **Marginal** (never-treated/late-treated states differ systematically from early adopters; needs careful weighting, region×year trends, and event-study diagnostics).
  - **Treatment clusters:** **Strong** (≈22 states treated → inference more credible than “<10 treated” designs).
  - **Concurrent policies:** **Marginal → Weak risk** (states adopting bans often enact other labor-market policies around similar dates; you’ll need explicit controls/stacked designs/exclusion of confounded windows).
  - **Outcome-Policy Alignment:** **Marginal** (mechanism targets *job applicants/new hires*; state-wide wage dispersion among all workers is an indirect proxy and may not move much even if treated workers’ wages change).
  - **Data-Outcome Timing:** **Marginal** (ACS wage/income reflects roughly the **prior 12 months** and interviews occur year-round; many laws are effective mid-year, so “first treated year” often has partial exposure and mechanical attenuation unless you align to effective dates or drop transition years).
  - **Outcome Dilution:** **Weak (potential dealbreaker unless fixed)** (affected group is job changers/new hires—typically well under 20% of workers annually; computing a state-year 90/10 or Gini on *all workers* likely dilutes effects heavily).
- **Recommendation:** **CONSIDER (conditional on: (i) redefining outcomes on a higher-exposure sample—e.g., recent job changers/new hires if feasible, or age/tenure proxies; (ii) tight timing alignment around effective dates, possibly dropping partial-exposure years; (iii) a credible strategy for concurrent policy bundles—e.g., control sets, policy-stacking, or restricting to “clean” adopters).**

---

**#2: Medicaid Expansion and Healthcare Worker Wages**
- **Score: 57/100**
- **Strengths:** Big policy shock with many treated units and long panels; outcomes (QCEW industry wages; ACS occupation wages) are directly related to provider labor markets, and dilution is low if you focus on healthcare industries/occupations. Feasible to implement with standard tools and rich robustness checks.
- **Concerns:** **Novelty is limited**: Medicaid expansion has an enormous literature, including hospital finances, labor demand, and some workforce outcomes. Identification is challenged by **endogenous adoption** (non-expansion states are systematically different) and overlapping ACA-era changes and state health policies.
- **Novelty Assessment:** **Low-to-moderate.** “Provider market equilibrium” is a reasonable angle, but Medicaid expansion has been studied intensively; you’d need a clearly new margin (e.g., specific occupations, rural vs urban shortages, wage compression within healthcare, or contract labor).
- **DiD Assessment (CS / staggered adoption):**
  - **Pre-treatment periods:** **Strong** (data exist well before 2014 in QCEW/ACS).
  - **Selection into treatment:** **Weak** (states self-select into expansion; adoption correlates with politics, baseline uninsured rates, provider markets, and trends—this is a classic DiD vulnerability).
  - **Comparison group:** **Marginal → Weak risk** (non-expansion states disproportionately Southern and structurally different; credible comparison may require bordering-state designs, synthetic controls, or within-region comparisons).
  - **Treatment clusters:** **Strong** (≈40 treated states).
  - **Concurrent policies:** **Marginal** (ACA market reforms, state waivers, delivery-system reforms, COVID-era shocks; not all coincide exactly, but enough overlap to threaten clean attribution).
  - **Outcome-Policy Alignment:** **Strong** (policy plausibly increases demand for healthcare services → labor demand/wages for healthcare workers).
  - **Data-Outcome Timing:** **Strong** for QCEW (quarterly; expansion often effective Jan 1, though some mid-year/waiver-based rollouts exist and must be coded carefully). **Marginal** for ACS (prior-12-month earnings).
  - **Outcome Dilution:** **Strong** (if you restrict to healthcare industries/occupations; weak only if using overall state wages).
- **Recommendation:** **CONSIDER (conditional on: (i) a design that directly tackles endogenous adoption—e.g., border-county comparisons, event-study with strong pretrend evidence, or IV-style timing instruments if defensible; (ii) careful handling of staggered timing and COVID-period heterogeneity; (iii) a sharply defined contribution vs existing provider/workforce papers).**

---

**#3: Universal License Recognition (ULR) and Entrepreneurship**
- **Score: 42/100**
- **Strengths:** The policy is new and expanding across many states, and the question is genuinely policy-relevant (occupational licensing reform is active legislation). If measured well, effects on entry/new firm creation could be important.
- **Concerns:** **Data feasibility and outcome alignment are the core problems.** BDS does not cleanly identify “licensed occupations” entrepreneurship, and the post-treatment window (2019–2024) is short and badly contaminated by **COVID-era shocks** that differentially affected states and small business formation—creating major threats to parallel trends.
- **Novelty Assessment:** **High.** ULR is recent and not nearly as saturated as Medicaid expansion or salary history bans, but novelty can’t compensate for weak measurement/ID.
- **DiD Assessment (staggered DiD):**
  - **Pre-treatment periods:** **Marginal** (you can get many pre-years in BDS, but policy starts late and composition/trends in entrepreneurship shift notably in late 2010s; still testable).
  - **Selection into treatment:** **Marginal → Weak risk** (ULR often adopted in response to labor shortages, migration/workforce concerns, or political ideology—could be correlated with entrepreneurship trends).
  - **Comparison group:** **Marginal** (adopting states may systematically differ; feasible but requires careful matching/weighting).
  - **Treatment clusters:** **Strong** (≈26 states).
  - **Concurrent policies:** **Weak** (timing overlaps with COVID emergency policies, reopening rules, PPP reliance, and state-level regulatory changes—big, differential shocks right in the treatment window).
  - **Outcome-Policy Alignment:** **Weak** if using BDS without a convincing “licensed occupation” proxy (industry ≠ licensed occupation; many licensed jobs are employees, not new firms; mechanism-to-measure mismatch).
  - **Data-Outcome Timing:** **Marginal** (BDS is annual; many ULR laws take effect mid-year; first “treated year” may have partial exposure).
  - **Outcome Dilution:** **Weak** if outcome is overall business formation (licensed occupations are a small share; even “professional services” is too broad).
- **Recommendation:** **SKIP (unless you can secure outcome data that directly capture licensed workers’ entry—e.g., administrative licensing board microdata on new licensees/new in-state applicants, or high-resolution occupation-level self-employment/firm entry measures that map tightly to licensed fields).**

---

### Summary

This is a decent batch with one clearly best option, but **all three** face typical DiD pitfalls. **Idea 1** is the most promising *if* you solve the **outcome dilution** and **timing alignment** problems and credibly address concurrent policy bundles; otherwise it risks a clean-looking but mechanically attenuated null. **Idea 2** is feasible but crowded and endogeneity-heavy; **Idea 3** is novel but currently fails on **outcome alignment** and is heavily confounded by the COVID period.