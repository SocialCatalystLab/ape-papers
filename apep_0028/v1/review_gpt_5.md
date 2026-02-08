# GPT 5.2 Review - Round 5/10

**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** high
**Timestamp:** 2026-01-18T19:16:39.293042
**Response ID:** resp_096b490f830da75100696d22a9515c8190a8a327e7685407f7
**Tokens:** 15827 in / 9385 out
**Response SHA256:** a1ab4e2dadb519d6

---

## Referee Report (AER/QJE/Econometrica standard)

### Summary
The paper evaluates Montana’s 2023 statewide zoning reforms (ADU + duplex legalization) using state-level monthly building permits (BPS) from Nov 2019–Oct 2025. It reports (i) a TWFE DiD estimate of +3.2 permits per 100k per month (insignificant) and (ii) a synthetic control estimate near zero (−0.7 per 100k; placebo p=0.958), with an event study suggesting problematic pre-trends. The paper concludes (correctly) that credible identification is not achieved at the state level and calls for place-level work.

For a top journal, the current design is not remotely close to the credibility threshold: the outcome is poorly aligned with the policy margin (ADUs/duplexes), treatment varies within-state, the panel has a single treated unit with short post and major legal uncertainty, and pre-trends are visibly non-parallel. The paper reads more like a careful *negative feasibility note* than a publishable causal evaluation.

---

# 1. FORMAT CHECK

**Length**
- Approx. **36 pages total** including references and appendix (see table of contents). Main text runs roughly **pp. 5–31** (≈27 pages), **meets** the ≥25-page guideline excluding references/appendix.

**References coverage**
- Bibliography includes key classic housing-regulation references (Saiz 2010; Glaeser & Gyourko; Hsieh & Moretti) and modern DiD papers (Callaway & Sant’Anna; Goodman-Bacon; Sun & Abraham; de Chaisemartin & d’Haultfœuille; Roth et al.). However it **misses several essential synthetic control and inference references** and **under-cites empirical upzoning/ADU evaluations** (details in Section 4).

**Prose (not bullets)**
- Major sections (Intro, Background, Literature, Results, Discussion) are written in paragraphs. **Pass.**

**Section depth (3+ substantive paragraphs each)**
- **Introduction (p.5)**: ≥3 paragraphs. Pass.
- **Policy background (pp.6–9)**: Pass.
- **Literature review (pp.9–12)**: Pass, but thin on *closest empirical analogs*.
- **Data & Methods (pp.13–17)**: Pass, though key institutional/data limitations deserve more formal treatment.
- **Results (pp.18–26)**: Mostly pass via subsections; some subsections are short and could be consolidated.
- **Discussion (pp.27–30)** and **Conclusion (p.31)**: Pass.

**Figures**
- Figures shown (Fig. 1 p.19; Fig. 2 p.22; Fig. 3 p.26; appendix figs p.36) have axes and visible data. **Pass**, though journal-quality versions should improve readability (fonts, line weights, clearer legends, consistent y-axis scaling across related plots).

**Tables**
- Tables contain numeric entries (Tables 1–5). **Pass**, but there are labeling/interpretation issues:
  - **Table 1 (p.18)** uses “Total Permits” but appears to report **average monthly permits**, not totals over the period (447.4 with N=50 strongly suggests a mean). This is confusing and should be fixed.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard Errors
- Main DiD coefficient reports clustered SEs in parentheses (Table 2 p.19), plus CIs and p-values. **Pass**.
- Other regressions report SEs and p-values (Tables 3–4). **Pass**.

### (b) Significance testing
- p-values are reported, including wild cluster bootstrap p-value (Table 2). **Pass**.

### (c) Confidence intervals
- Main DiD result includes a 95% CI (Table 2). **Pass**.
- Other key specifications (Table 4 robustness) **do not show CIs**; add 95% CIs consistently for all headline specifications.

### (d) Sample sizes
- N reported for regressions (e.g., N=432 in Tables 2–3). **Pass**.

### (e) DiD with staggered adoption
- No staggered adoption across units; Montana is the single treated unit; controls are never-treated. **Pass** on the “TWFE staggered timing” criterion.

### Core inference problems *despite passing the checklist*
Even though the paper satisfies basic reporting requirements, the inference and estimands are not persuasive for a top journal:

1. **Few-cluster DiD is fragile**: with 6 states (MT + 5 controls), cluster-robust SEs are unreliable; wild bootstrap helps but is not a panacea (and depends on design quality). Consider Conley-Taber-style inference more centrally (they cite Conley & Taber 2011 but do not implement it).

2. **SCM inference and fit**: SCM pre-fit RMSPE ≈10 (Table 5 p.24) is not great relative to signal; monthly permits are extremely noisy. SCM conclusions depend heavily on fit quality and donor pool curation. The paper needs more extensive SCM diagnostics (weights table, pre-fit plots with standardized differences, leave-one-out donor sensitivity, alternative loss functions / augmented SCM).

**Bottom line on methodology**: The paper is *reporting* inference correctly, but the design cannot support publishable causal inference. This is not a “fails to report SEs” situation; it is a “the data/design do not identify the causal estimand” situation.

---

# 3. IDENTIFICATION STRATEGY

### Credibility
Identification is **not credible** as currently executed; the paper essentially admits this (Discussion/Conclusion, pp.27–31). Key issues:

1. **Outcome does not measure the policy margin (severe measurement error)**
   - ADUs are often conversions/additions not captured as “new privately-owned residential building permits” in a way that maps cleanly into BPS state totals. Duplex legalization should primarily affect **2-unit permits** specifically, yet the main outcome is **total permits** and then broad “multi-family.” This is an attenuating and potentially non-classical measurement problem.

2. **Treatment is not statewide in exposure**
   - SB323 applies only to municipalities above population thresholds (and in certain counties). State-level aggregation with a whole-state population denominator mechanically **dilutes** treatment intensity and violates the implicit “treated unit” model. This is not a small caveat; it undermines the estimand.

3. **Pre-trends are visibly problematic**
   - The event study (Fig. 2 p.22) shows large pre-treatment deviations. The paper labels this “problematic pre-trends,” but it does not offer a design-based correction or an alternative identification strategy.

4. **Treatment timing is confounded by legal uncertainty**
   - Preliminary injunction from Dec 2023–Mar 2025 (pp.9, 23) means Jan 2024 is not a clean adoption date. Coding treatment at Jan 2024 creates an “intent-to-treat under uncertainty” estimand that is not well defined, while coding Mar 2025 yields only ~8 months post (Table 4 p.23). This is not just low power; it is ambiguity about what “treated” means.

5. **Control group validity is weak**
   - The 5-state control set (p.14) is ad hoc and includes states with very different housing cycles (Idaho boom; Wyoming energy exposure). SCM mitigates some of this, but SCM fit is imperfect and donor pool may be contaminated by other states’ reforms (see below).

### Placebos and robustness
- The paper includes some robustness checks (exclude Idaho; alternative treatment date) and SCM placebo distribution (p.24–26). This is directionally correct but **insufficient** given the identification problems.

### Do conclusions follow from evidence?
- The paper’s main conclusion—**credible identification is not achieved with available data**—does follow from the evidence. However, this is also why the paper is not publishable in a top journal: the core contribution is essentially “we tried state-level DiD/SCM and it doesn’t work.”

### Limitations
- Limitations are discussed (pp.30–31). This is a strength, but it also underscores that the paper does not meet the evidentiary bar for causal claims.

---

# 4. LITERATURE (Missing references + BibTeX)

### What’s good
- Strong coverage of modern DiD warnings and alternatives (Callaway & Sant’Anna; Sun & Abraham; Goodman-Bacon; Roth et al.).
- Some housing regulation fundamentals (Saiz; Glaeser/Gyourko; Hsieh/Moretti).

### What’s missing / underdeveloped
#### (A) Synthetic control: core methodological and inference references
You should cite (and ideally use) modern SCM variants and inference frameworks:

```bibtex
@article{Abadie2021,
  author  = {Abadie, Alberto},
  title   = {Using Synthetic Controls: Feasibility, Data Requirements, and Methodological Aspects},
  journal = {Journal of Economic Literature},
  year    = {2021},
  volume  = {59},
  number  = {2},
  pages   = {391--425}
}
```

```bibtex
@article{BenMichaelFellerRothstein2021,
  author  = {Ben-Michael, Eli and Feller, Avi and Rothstein, Jesse},
  title   = {The Augmented Synthetic Control Method},
  journal = {Journal of the American Statistical Association},
  year    = {2021},
  volume  = {116},
  number  = {536},
  pages   = {1789--1803}
}
```

```bibtex
@article{ChernozhukovWuthrichZhu2021,
  author  = {Chernozhukov, Victor and W{\"u}thrich, Kaspar and Zhu, Yinchu},
  title   = {An Exact and Robust Conformal Inference Method for Counterfactual and Synthetic Controls},
  journal = {Journal of the American Statistical Association},
  year    = {2021},
  volume  = {116},
  number  = {536},
  pages   = {1849--1864}
}
```

Why relevant: your setting is the canonical SCM use case (single treated unit, noisy panel). A top-journal paper must show awareness of augmented SCM, sensitivity, and modern inference beyond basic placebo ranking.

#### (B) Land-use regulation measurement and institutional background
You should cite the Wharton land-use regulation index paper, which is standard in the literature and relevant for motivating heterogeneity and baseline restrictiveness:

```bibtex
@article{GyourkoSaizSummers2008,
  author  = {Gyourko, Joseph and Saiz, Albert and Summers, Anita},
  title   = {A New Measure of the Local Regulatory Environment for Housing Markets: The Wharton Residential Land Use Regulation Index},
  journal = {Urban Studies},
  year    = {2008},
  volume  = {45},
  number  = {3},
  pages   = {693--729}
}
```

#### (C) Political economy of zoning opposition (highly relevant given the injunction)
```bibtex
@book{EinsteinGlickPalmer2019,
  author    = {Einstein, Katherine Levine and Glick, David M. and Palmer, Maxwell},
  title     = {Neighborhood Defenders: Participatory Politics and America's Housing Crisis},
  publisher = {Cambridge University Press},
  year      = {2019}
}
```

#### (D) Empirical upzoning evidence (more than Auckland)
The paper leans heavily on Auckland as the “rigorous” upzoning reference. For a US-focused statewide reform paper, you need to more comprehensively cite US upzoning/rezoning evaluations (even if imperfect), and ADU production evidence beyond policy reports. One widely cited upzoning evaluation:

```bibtex
@article{Freemark2020,
  author  = {Freemark, Yonah},
  title   = {Upzoning Chicago: Impacts of a Zoning Reform on Property Values and Housing Construction},
  journal = {Urban Affairs Review},
  year    = {2020},
  volume  = {56},
  number  = {6},
  pages   = {1810--1842}
}
```

(If any bibliographic details differ, correct them precisely; but the point is that the closest empirical work must be engaged seriously.)

---

# 5. WRITING AND PRESENTATION

**Structure and clarity**
- Generally clear and transparent; the paper is honest about design limitations (pp.27–31). That said, the narrative oscillates between “we estimate effects” and “identification fails.” For a top journal, you must reframe: either you have a credible design and answer a question, or you do not.

**Overstatements / unsupported claims**
- Claims like “most aggressive state-level intervention into local zoning authority in U.S. history” (Intro/Background, pp.5–6) require careful substantiation and comparative referencing; otherwise they read as advocacy.

**Figure/table quality**
- Readable but not publication-quality yet (fonts/line thickness/legend clarity). Event study should include (i) a formal pre-trends test, (ii) consistent scaling, (iii) possibly fewer bins (annual rather than quarterly) given noise.

**Terminology/labels**
- “Total Permits” in Table 1 is mislabeled/ambiguous (p.18).
- Donor pool count inconsistency: text says “47 donor states” after excluding CA/OR/ME (p.16, p.24). This arithmetic likely does not add up unless DC or other units are included. A top journal will flag this.

---

# 6. CONSTRUCTIVE SUGGESTIONS (How to make it publishable/impactful)

To be blunt: **state-level BPS DiD/SCM is not salvageable into an AER/QJE/Ecta paper** for this policy. To have a chance, you need a new design/data that matches the policy margin and creates credible counterfactuals.

## A. Use place-level variation within Montana (required)
1. **Triple-difference (DDD) using SB323 thresholds**
   - Compare permit changes in MT cities eligible for duplex legalization vs MT cities ineligible, relative to similar city groups in other states.
   - This uses within-state untreated units and reduces reliance on cross-state comparability.

2. **Border discontinuity / near-border county design**
   - Compare MT counties/cities near the border to adjacent counties/cities in WY/ND/SD/ID, controlling for local trends. Still imperfect, but far better than state totals.

## B. Measure the policy margin correctly (required)
1. **Outcome decomposition**
   - For duplex legalization, focus on **2-unit permits** specifically (not “multi-family” broadly).
   - For ADUs, BPS is likely inadequate; collect **administrative ADU permit counts** from major municipalities, or use BPS place-level microdata if it identifies ADU-related permit categories (often it won’t).

2. **Compliance/implementation measurement**
   - Code city-level adoption/ordinance updates, enforcement dates, and litigation-related pauses. Treat the reform as **treatment intensity** rather than a 0/1 state shock.

## C. Address the injunction explicitly (required)
- Model as two-stage: de jure adoption (Jan 2024) vs de facto enforceability (Mar 2025).
- Consider an event study with two events, or treat the injunction window as “partial treatment / uncertainty” and estimate separate effects.

## D. Improve single-treated inference beyond what’s currently done
- Implement **Conley & Taber (2011)** inference explicitly for the DiD setting with one treated unit.
- For SCM, add **augmented SCM**, leave-one-out donor sensitivity, alternative donor pools excluding *all* states with meaningful contemporaneous housing/zoning reforms, and consider conformal inference.

## E. Expand outcomes (to be policy-relevant)
- Permits are an intermediate outcome. Add:
  - housing starts/completions (where available),
  - rents/prices (Zillow/ACS/CPI rent indexes),
  - housing stock changes (ACS, USPS vacancy proxies),
  - composition (small multifamily vs large multifamily).

Without these steps, the paper remains an internally-consistent demonstration that “aggregate state-level data + single treated unit + noisy monthly outcomes” does not identify the effect.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Timely question and transparent workflow.
- Correctly reports inference objects (SEs, CIs, p-values; wild bootstrap; SCM placebo).
- The paper does not over-claim; it flags pre-trends and identification failure (pp.22, 27–31).

### Critical weaknesses (fatal for top journals)
- **Mismatch between policy and data** (ADUs/duplexes vs state-level BPS totals).
- **Non-credible identification** (clear pre-trends; within-state treatment heterogeneity; ambiguous treatment timing due to injunction).
- **Short and contaminated post-period** for any meaningful housing-supply response.
- Contribution is primarily negative (“this design doesn’t work”), without delivering a credible alternative estimate.

### Specific improvements (minimum to resubmit elsewhere)
- Move to place-level administrative permit data and exploit within-MT variation around SB323 eligibility thresholds.
- Rebuild SCM/DiD with an estimand that corresponds to actual exposure and measured outcomes (2-unit permits; ADU permits).

---

## VERDICT: REJECT

The paper meets basic reporting standards for inference, but it fails the core top-journal requirement: **credible identification of a policy effect on a correctly measured outcome**. As written, it is not a causal evaluation; it is a careful but ultimately inconclusive attempt using data that cannot answer the question. A publishable version would require fundamentally different data and a within-state (or threshold-based) research design.