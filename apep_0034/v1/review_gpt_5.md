# GPT 5.2 Review - Round 5/10

**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** high
**Timestamp:** 2026-01-19T14:36:53.438090
**Response ID:** resp_03d8378589edfa5200696e32ae8f548193b5cfbf6139297e38
**Tokens:** 9757 in / 9696 out
**Response SHA256:** 78512d319e8b9b1b

---

## Referee Report: “Breaking the Chains of Contract: The Labor Market Effects of State Noncompete Agreement Restrictions” (Jan 2026)

### Summary
The paper studies whether recent state restrictions on noncompete agreements (NV, OR, IL, DC, CO, MN; 2021–2023) affected aggregate turnover and earnings. Using QWI state-quarter data (2018Q1–2024Q2) and staggered DiD with Callaway–Sant’Anna (C&S), the authors report essentially zero short-run effects on turnover (ATT ≈ −0.01 pp, SE 0.15) and a small, statistically insignificant negative effect on log earnings (ATT ≈ −0.02, SE 0.01), with event studies showing no pre-trends and no clear post effects.

This is a relevant policy question. However, in its current form the paper is **not close** to publishable in a top general-interest journal. The key problems are (i) **treatment definition/coding and control-group contamination** (very likely misclassified “never-treated” states), (ii) limited ability of aggregate QWI outcomes to detect the mechanisms the paper emphasizes, and (iii) presentation/writing choices that read like a policy report rather than a top-journal article.

Below I provide a demanding, detailed checklist-style evaluation and concrete steps that would be required for a serious resubmission.

---

# 1. FORMAT CHECK

### Length
- The provided draft appears to be **~19 pages including references** (page numbers shown up to 19). This is **below** a typical top-journal expectation for a main text of **≥25 pages** (excluding references/appendix).  
  **Action**: Expand substantially (and/or add a serious appendix) with: law coding, validation, additional outcomes, heterogeneity, and stronger designs.

### References
- The bibliography is **not adequate** for a top-journal paper in this area. It is missing foundational DiD practice references (e.g., Bertrand–Duflo–Mullainathan) and modern alternatives (synthetic DiD), and it is thin on the institutional/policy and noncompete empirical literatures beyond a handful of citations. Details and BibTeX are in Section 4 below.

### Prose vs bullets
- Several major sections rely heavily on **bulleted lists**:
  - Section **2.2** (“Recent State Policy Changes”) is almost entirely bullets.
  - Section **5.1** outcome definitions are bullets (acceptable), but the paper repeatedly uses list formatting where a top journal expects narrative synthesis.
  - Parts of **6.4** and **7** read like internal memo bulleting rather than polished exposition.
- Top journals strongly prefer paragraph-form institutional discussion and results interpretation.

### Section depth (3+ substantive paragraphs each)
- Section **2** and parts of **6–7** do not meet this standard as written (bullets and short commentary rather than developed paragraphs).
- The “Minnesota focus” subsection (7.5) is too thin given the prominence of the Minnesota claim.

### Figures
- **No figures are shown** in the draft you provided. Yet you describe event-study “plots.” For a DiD paper, publication-quality figures are not optional.
  **Action**: Include (at minimum) (i) event-study plots with CIs, (ii) cohort-specific dynamics, (iii) a map/timeline of adoptions, and (iv) diagnostic plots (pre-trend visualization, permutation distribution if doing randomization inference).

### Tables
- Tables shown contain real numbers (good).  
- However, several tables lack important regression metadata (e.g., whether weighted, exact N used for each outcome/specification, list of jurisdictions included after missingness).

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### a) Standard errors
- **PASS**: Main estimates report SEs (Table 2), and the event-study table includes SEs.

### b) Significance testing
- **PASS**: p-values and/or stars appear; wild bootstrap p-values are reported for main outcomes (Table 2).

### c) Confidence intervals
- **PASS**: 95% CIs are reported in Table 2 and Table 3.

### d) Sample sizes
- **PARTIAL PASS / NEEDS WORK**:
  - Table 2 reports a global N (=1,207) and treated/control counts.
  - But each robustness table/specification should report the exact estimation sample used (N, number of states, number treated, post periods), particularly because QWI suppression implies changing samples across outcomes/strata.

### e) DiD with staggered adoption
- **PASS on estimator choice**: You use Callaway–Sant’Anna with never-treated controls, and you compare to TWFE.

### f) Inference with few treated clusters
- This is where the paper is **not yet acceptable** for a top journal.
  - You acknowledge the issue (Section 3.4) and report wild cluster bootstrap p-values (good first step), but with **only 6 treated jurisdictions**, conventional cluster methods remain fragile, and “wild bootstrap with 48 clusters” does not fully address the “few treated” problem emphasized by Conley–Taber and the subsequent literature.
  - You *mention* randomization inference but do not implement it; likewise you do not implement Conley–Taber-style inference tailored to few policy changes.

**Bottom line**: The methodology is not an outright fail, but for a top journal you need a more convincing inference strategy targeted to “few treated” and “treatment timing is not random.”

**Required upgrades**:
1. **Randomization inference / permutation tests**: Reassign adoption timing across states (respecting staggered structure) and show where your ATT lies in the placebo distribution.
2. Implement **Conley & Taber (2011)**-style inference (or a modern equivalent) explicitly for your setting, not just cite it.
3. Report **effect sizes and RI-based p-values** as primary, with clustered SEs as secondary.

---

# 3. IDENTIFICATION STRATEGY

### Core credibility
Even if the C&S estimator is correctly implemented, the identification strategy is currently **not credible** because the *treatment and control classification appears wrong or incomplete*.

#### (1) Control-group contamination (major)
You define “never-treated” controls as the 42 jurisdictions not in {NV, OR, IL, DC, CO, MN} and exclude only CA/ND/OK due to long-standing bans. This is almost certainly incorrect given the well-known wave of **pre-2021** reforms:
- **Massachusetts (2018)** Noncompetition Agreement Act
- **Washington (2019 law, effective 2020)** income threshold + other restrictions
- **Maryland (2019)** low-wage noncompete limits
- **New Hampshire (2019)** notice + low-wage restrictions
- **Rhode Island (2020)** restrictions
- **Virginia (2020)** low-wage ban
- Many others had material changes earlier than 2021

If these states are in your “never-treated” control pool, you are comparing 2021–2023 adopters to a control group partially “already treated,” mechanically biasing estimates toward **zero** and making null findings largely uninterpretable.

**This is a first-order identification failure.** You must construct a comprehensive policy panel of noncompete legal changes for *all* states over a long horizon and either:
- redefine treatment as *any* meaningful restriction (multiple cohorts), or
- restrict the control group to states with demonstrably stable policy over the full window, or
- use methods that can accommodate multiple treatments/continuous intensity.

#### (2) Treatment heterogeneity and “prospective only” policies
You pool very different legal changes: full ban (MN), high-income carve-outs (DC), duration/threshold changes (OR/IL), hourly-only protections (NV), penalties (CO). Moreover, MN applies **prospectively** to agreements signed after the effective date, implying minimal immediate effect on incumbent workers.

This makes your “short-run null” close to an equilibrium prediction rather than a surprising finding. A top-journal paper must map the legal change into an **exposure/intensity** measure (share of workforce affected each quarter).

At minimum:
- model treatment as ramping up with new hires (e.g., proportional to hire rate × post period),
- or use a triple-difference: post × treated × high-noncompete-exposure industries/occupations.

#### (3) Parallel trends and placebo tests
- You provide an event-study table (Table 3) and a joint pre-trend test (p=0.47). This is helpful but not sufficient given:
  - pandemic disruptions (2019–2021),
  - endogenous adoption (states changing laws because of labor market conditions),
  - contaminated controls (above).

You also promise placebo tests and alternative control groups in Section 5.4, but do not show the placebo results clearly and comprehensively.

#### (4) Outcome validity: turnover ≠ job-to-job mobility
QWI “turnover/separation from stable employment” is not clearly the job-to-job transition margin most directly linked to noncompetes. Noncompetes primarily restrict *moves to competitors* and may affect **job-to-job** flows more than separations overall (which include exits to nonemployment).

If your outcome does not tightly match the mechanism, null results are not informative.

**Required**:
- Use LEHD J2J (job-to-job flows) if possible, or at least QWI measures that better proxy job-to-job transitions.
- If restricted data are unavailable, the contribution is likely too limited for a top outlet.

### Do conclusions follow?
The conclusion (“caution about expecting immediate aggregate effects”) is plausible, but given treatment misclassification and weak mechanism measurement, the paper currently cannot claim even that modest conclusion confidently.

### Limitations
You discuss power/aggregation/short window (Section 6.4, 7.6). That is good. But the biggest limitation—**policy panel mismeasurement**—is not acknowledged.

---

# 4. LITERATURE (Missing references + BibTeX)

### Methodology references that should be added
You cite C&S, Sun–Abraham, Goodman-Bacon, de Chaisemartin–D’Haultfoeuille, Borusyak et al., Roth. Good. But you are missing several “expected” citations for a top general-interest journal:

1) **Bertrand, Duflo, Mullainathan (2004)** — canonical DiD inference / serial correlation.
```bibtex
@article{BertrandDufloMullainathan2004,
  author = {Bertrand, Marianne and Duflo, Esther and Mullainathan, Sendhil},
  title = {How Much Should We Trust Differences-in-Differences Estimates?},
  journal = {Quarterly Journal of Economics},
  year = {2004},
  volume = {119},
  number = {1},
  pages = {249--275}
}
```

2) **Arkhangelsky et al. (2021)** synthetic DiD (highly relevant for MN and few treated units).
```bibtex
@article{ArkhangelskyEtAl2021,
  author = {Arkhangelsky, Dmitry and Athey, Susan and Hirshberg, David A. and Imbens, Guido W. and Wager, Stefan},
  title = {Synthetic Difference-in-Differences},
  journal = {American Economic Review},
  year = {2021},
  volume = {111},
  number = {12},
  pages = {4088--4118}
}
```

3) **Abadie, Diamond, Hainmueller (2010)** synthetic control (again, MN case).
```bibtex
@article{AbadieDiamondHainmueller2010,
  author = {Abadie, Alberto and Diamond, Alexis and Hainmueller, Jens},
  title = {Synthetic Control Methods for Comparative Case Studies: Estimating the Effect of California's Tobacco Control Program},
  journal = {Journal of the American Statistical Association},
  year = {2010},
  volume = {105},
  number = {490},
  pages = {493--505}
}
```

4) **Xu (2017)** generalized synthetic control (panel interactive fixed effects alternative).
```bibtex
@article{Xu2017,
  author = {Xu, Yiqing},
  title = {Generalized Synthetic Control Method: Causal Inference with Interactive Fixed Effects Models},
  journal = {American Economic Review},
  year = {2017},
  volume = {107},
  number = {4},
  pages = {1197--1225}
}
```

5) **Ferman and Pinto (2019)** (or similar) on DiD inference with few treated groups.
```bibtex
@article{FermanPinto2019,
  author = {Ferman, Bruno and Pinto, Cristine},
  title = {Inference in Differences-in-Differences with Few Treated Groups and Heteroskedasticity},
  journal = {Review of Economics and Statistics},
  year = {2019},
  volume = {101},
  number = {3},
  pages = {452--467}
}
```

### Domain literature that should be engaged
You cite Gilson (1999), Marx et al. (2009), Starr et al. (2019, 2021), Garmaise (2011), Bishara (2011), Johnson–Lavetti–Lipsitz (2023). That is a start. But a top-journal version should engage more directly with innovation/entrepreneurship and labor-market dynamism channels often attributed to noncompetes.

A widely cited piece:
- **Samila and Sorenson (2011)** on noncompetes and entrepreneurship/innovation.
```bibtex
@article{SamilaSorenson2011,
  author = {Samila, Sampsa and Sorenson, Olav},
  title = {Noncompete Covenants: Incentives to Innovate or Impediments to Growth},
  journal = {Management Science},
  year = {2011},
  volume = {57},
  number = {3},
  pages = {425--438}
}
```

Also, given your focus on **policy changes**, you should cite and discuss:
- FTC rulemaking documents and economic reports (even if not journal articles) and the emerging empirical work studying recent state reforms (some may be working papers; top journals still expect discussion).

### Why this matters
Right now the literature review reads as if the empirical contribution is “first evaluation of MN + wave of reforms.” But without a correct national policy panel and without outcomes that directly map to job-to-job mobility and bargaining, the paper is not cleanly positioned relative to existing evidence on enforceability and mobility.

---

# 5. WRITING QUALITY (CRITICAL)

### a) Prose vs bullets
- **FAIL for a top journal draft**: Section 2.2 is a bullet list; multiple other places lean on list formatting where synthesis is required. Bullets are fine for variable definitions, not for the main institutional narrative or interpretation.

### b) Narrative flow
- The introduction is serviceable, but the narrative arc is undermined by (i) premature emphasis on estimator choice, (ii) limited institutional discussion of how each law changes actual worker constraints, and (iii) results framed as “null” without a strong prior about implementation lags and prospective-only application.

### c) Sentence/paragraph quality
- Many paragraphs read like a technical report (“Our main findings are threefold…”; “This paper contributes to several literatures…”) rather than a compelling economic narrative.
- The paper should more clearly distinguish: *what is being identified* (legal change) vs *what is being measured* (aggregate turnover/earnings) vs *what is the mechanism* (outside options/bargaining).

### d) Accessibility
- Key constructs need clearer definitions on first use:
  - What exactly is “turnover rate” in QWI terms?
  - What is “stable employment”?
  - Why should a prospective ban move **aggregate** turnover within 3 quarters?
- Magnitudes: you do some of this (baseline 7.9%), but the “MDE” discussion has an internal inconsistency (Section 3.4 suggests ~0.30 pp; Section 7.6 suggests ~0.42 pp). This needs to be reconciled.

### e) Figures/tables publication quality
- Tables are a start. But top journals require figures that allow readers to assess identifying variation and dynamics visually (event studies, cohort-specific plots, placebo distributions).

---

# 6. CONSTRUCTIVE SUGGESTIONS (What would make this publishable)

To have a credible shot at AEJ:EP (let alone AER/QJE/JPE/ReStud/Ecta), I think you need to restructure around at least one of the following “strong designs,” and fix treatment measurement.

## A. Build a comprehensive 50-state policy panel (non-negotiable)
- Code *all* meaningful noncompete reforms since at least ~2010 (ideally earlier).
- Reclassify controls accordingly (exclude “already reformed” states, or treat them appropriately).
- Provide a detailed appendix documenting legal provisions, effective dates, and whether changes apply prospectively/retroactively.

## B. Use an exposure / triple-difference design (to recover power and mechanism)
Because only ~20% of workers have noncompetes and many reforms apply only to subsets:
- Construct exposure by industry/occupation using external prevalence data (e.g., Starr et al. survey-based prevalence by occupation/industry; or other credible proxies).
- Estimate:  
  **(treated state × post) × (high-exposure industry/occupation)** within a state-quarter panel.  
This is far more likely to detect economically meaningful effects than state aggregates.

## C. Measure job-to-job mobility directly
- If possible, obtain LEHD **J2J** measures or restricted microdata access.
- Alternatively, augment with CPS/ASEC (job tenure, quits) or JOLTS (though state-level is limited), or use UI microdata if accessible.

## D. Minnesota-centered design with modern comparative case study tools
For MN specifically:
- Use **Synthetic DiD** or **Synthetic Control** with a carefully chosen donor pool.
- Consider border-county comparisons if you can access county-level outcomes (restricted data may be required). If you cannot, MN should not be marketed as a headline “first evaluation” for a top journal.

## E. Inference upgrades for “few treated”
- Make **randomization inference** a primary inferential tool.
- Report permutation distributions for the ATT and key event-time coefficients.

## F. Mechanisms and alternative outcomes
If the key mechanism is bargaining power/outside options, effects may show up in:
- wage growth of stayers vs movers,
- within-job raises,
- distributional effects (upper tail for high-skilled, or threshold-affected workers in IL/OR/DC),
- hiring composition, firm entry, and entrepreneurship (BDS, Business Formation Statistics).

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Uses a modern staggered DiD estimator (C&S) and acknowledges TWFE pitfalls.
- Transparently reports null results with SEs/CIs and discusses power and aggregation.
- Recognizes few-treated inference concerns and attempts wild bootstrap.

### Critical weaknesses
1. **Likely misclassification of “never-treated” controls** given widespread pre-2021 reforms in many states. This alone makes the causal claims unreliable and likely biases results toward zero.
2. **Outcome mismatch**: aggregate turnover/separations may not capture the job-to-job competitor mobility margin most affected by noncompetes.
3. **Treatment heterogeneity and prospective-only application** imply short-run aggregate nulls are not surprising; the paper needs an exposure/intensity framework.
4. **Insufficient figures and narrative writing** for a top journal.
5. **Inference for few treated** is not yet at top-journal standard; randomization inference should be implemented, not just cited.

### What I would need to see in a serious revision
- A correct 50-state policy timeline and a defensible control group.
- An exposure-based design and/or microdata-based mobility measures.
- Stronger Minnesota case-study methods (SDID/SCM) if MN remains central.
- Full visual evidence (event-study figures, placebo/permutation distributions).
- Rewritten institutional and results sections in paragraph form with clear economic interpretation.

---

DECISION: REJECT AND RESUBMIT