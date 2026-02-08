# GPT 5.2 Review - Round 2/10

**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** high
**Timestamp:** 2026-01-19T14:20:35.584683
**Response ID:** resp_098812db47f6b28500696e2efd3d248197ae6d3e9416849e8b
**Tokens:** 6987 in / 7619 out
**Response SHA256:** efdd999163776e07

---

## Summary (what the paper does and why it matters)

The paper studies the labor-market effects of a recent wave of state noncompete restrictions (NV, OR, IL, DC, CO, MN) using 2018Q1–2024Q2 QWI data and staggered DiD with Callaway–Sant’Anna (CS) estimators. The headline finding is essentially “no detectable short-run aggregate effects” on turnover or earnings.

This is a relevant policy question and the attempt to use heterogeneity-robust DiD methods is directionally aligned with current standards. However, in its current form the paper is **not** at the level required for a top general-interest journal or AEJ:EP. The main issues are (i) **format and presentation are far below top-journal norms**, (ii) **key empirical objects (event-study figures; full regression/event-time coefficient tables) are missing**, (iii) **treatment definition pools legally and economically heterogeneous reforms**, and (iv) **inference and power are not handled at the level required given only 6 treated states and short post windows**—making “null effects” hard to interpret.

Below is a detailed, demanding review.

---

# 1. FORMAT CHECK

### Length
- The provided draft is **~13 pages** through references (page numbers show 1–13). This is **far below** the typical **≥25 pages of main text** expected at AER/QJE/JPE/ReStud/Ecta/AEJ:EP (excluding references/appendix).  
- **Fail on length** as currently provided.

### References coverage
- The bibliography is **thin** for a top-journal paper on noncompetes + modern DiD. It includes some key items (Callaway–Sant’Anna; Goodman-Bacon; Gilson; Marx et al.; Starr et al.), but misses several central DiD/event-study papers and much of the most relevant recent noncompete empirical literature (see Section 4 of this report).

### Prose vs bullets
- Several important sections rely heavily on bullet lists (e.g., **Section 2.2 “Recent State Policy Changes”**; parts of **6.4 “Interpreting the Null Results”** read like enumerations). Bullet points are acceptable for short institutional summaries, but in a top-journal submission the **Introduction, Results, and Discussion must be paragraph-driven**, with a clear narrative and argumentation.

### Section depth (3+ substantive paragraphs per major section)
- Many sections are **too short** and do not meet the “deep development” norm:
  - **Section 6 (Results)** has limited depth and lacks displayed event-study estimates/figures despite discussing them.
  - **Section 7 (Robustness and Heterogeneity)** is extremely brief given the identification challenges.
  - **Section 5 (Data & Empirical Strategy)** needs substantially more detail on QWI measurement, weighting, cohort definition, and inference.

### Figures
- The text references event-study plots (“Event study estimates show…”, Section 6.2), but **no figures are included**. For a DiD paper, **event-study figures are not optional** in a top journal.  
- **Fail on figures** (not present).

### Tables
- Tables shown have real numbers (good), but they are insufficient:
  - Table 2 combines CS and TWFE in a very compressed way; it does not show the underlying event-time coefficients, cohort-specific effects, or robustness variants.
  - No table reports the dynamic event-study coefficients with SEs/CIs.
- **Pass on “real numbers,” fail on adequacy/completeness**.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors
- Table 2 reports SEs in parentheses for the main ATT estimates. **Pass** on the narrow criterion.

### (b) Significance testing
- The paper does not report **p-values** or **t-stats**, and Table 2 has no conventional significance markers. The text says “all p > 0.10,” but top journals generally require **transparent reporting** (at least t-stats or p-values, and usually stars in tables).  
- I would not call this a hard fail, but it is **below standard** and should be fixed.

### (c) Confidence intervals
- Table 2 reports 95% CIs. **Pass**.

### (d) Sample sizes
- Table 2 reports N, but there are **internal inconsistencies**:
  - The text says “We include 48 states” (Section 5.2) after excluding CA/ND/OK. If DC is included, arithmetic needs to be explicit (50 states + DC = 51; minus 3 = 48).
  - Table 2 says “47 states,” 26 quarters, N = 1,207. But 47×26 = 1,222, not 1,207. If 48×26 = 1,248.  
  This raises concerns about missingness and sample construction that must be explained.
- **Fail on internal consistency and clarity of N**.

### (e) DiD with staggered adoption
- The choice of **Callaway–Sant’Anna with never-treated controls** is appropriate and avoids the most severe TWFE timing bias. **Pass** on design choice.
- That said, the paper still reports TWFE as a “comparison” without decompositions or diagnostics; if included, you should show Goodman-Bacon weights or at least discuss why TWFE is not your preferred estimator.

### Critical inference concern: only 6 treated states
Even if you cluster by state, with **only 6 treated clusters**, conventional asymptotics can be misleading. A top-journal referee will expect:
- **Randomization inference / permutation tests** over treatment timing/states, or
- **Wild cluster bootstrap** procedures designed for few treated clusters, and/or
- Sensitivity to alternative clustering/HAC approaches.

Right now, the paper’s inference is likely **too optimistic or too noisy**, and the “null” may be an artifact of low effective power and short post periods. This does not make the paper “unpublishable,” but it makes it **not ready** for a top outlet.

---

# 3. IDENTIFICATION STRATEGY

### Credibility
The identification argument is currently **too thin** relative to the stakes of causal claims in a top journal.

Key threats that are not adequately handled:

1. **Treatment heterogeneity / pooling fundamentally different reforms**
   - The “treatment” includes: a near-ban (DC), a full ban but prospective only (MN), duration/income-threshold changes (OR, IL), hourly-worker carveouts (NV), and criminal penalties (CO).
   - Pooling these as a single binary “restriction” implicitly assumes comparable first-stage changes in enforceability and in actual contracting behavior. That is unlikely.
   - At minimum, you need (i) separate estimates by state/reform type, (ii) an intensity measure, or (iii) a design that uses thresholds (e.g., wage cutoffs) where applicable.

2. **Prospective nature of MN ban**
   - MN applies to agreements signed after July 2023 (as the paper notes). That mechanically predicts muted short-run effects on incumbent workers. A top-journal paper must align hypotheses and estimands with legal details: you likely want outcomes for **new hires**, **job changers**, or cohorts plausibly newly covered by the law.

3. **Short post windows**
   - For MN in particular, there are only a handful of post quarters. For some other states, post periods coincide with unusual macro conditions (2021–2022 labor market churn). You need sharper discussion of how macro shocks might interact with treatment.

4. **Parallel trends evidence is asserted, not shown**
   - The paper states “no pre-trends,” but provides no figure/table of lead coefficients with SEs/CIs.

### Placebos and robustness
The robustness section (Section 7) is not adequate. For credibility in a top journal, I would expect at least:

- Full **event-study** with multiple lead/lag bins, plotted with 95% CIs
- Alternative control groups (never-treated vs not-yet-treated) and **discussion of contamination**
- **Placebo adoption dates** and/or permutation inference
- State-specific linear trends (with clear discussion of pros/cons)
- Sensitivity to weighting (employment-weighted vs unweighted)
- Drop-one-treated-state (“leave-one-out”) results, because N_treated=6

### Do conclusions follow from evidence?
The conclusion appropriately hedges, but still risks overinterpreting a noisy null. A top-journal version must separate:
- “We estimate effects close to zero with tight bounds” (informative null) vs
- “We cannot detect effects in aggregate data” (uninformative null)

Right now it reads closer to the second.

### Limitations
Limitations are mentioned (power; aggregation; short horizon). That is good, but insufficient without:
- formal **minimum detectable effect** calculations,
- explicit bounding (“we can rule out effects larger than X”), and
- a clearer mapping from theory to expected magnitude in aggregates (share bound by noncompetes × expected effect on affected workers).

---

# 4. LITERATURE (MISSING REFERENCES + BibTeX)

## Missing / under-engaged methodology literature (DiD/event studies)
You cite Callaway–Sant’Anna and Goodman-Bacon, but a top-journal DiD paper should also engage:

1) **Sun & Abraham (2021)** — canonical event-study estimator under heterogeneous treatment effects  
```bibtex
@article{SunAbraham2021,
  author  = {Sun, Liyang and Abraham, Sarah},
  title   = {Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects},
  journal = {Journal of Econometrics},
  year    = {2021},
  volume  = {225},
  number  = {2},
  pages   = {175--199}
}
```

2) **de Chaisemartin & D’Haultfoeuille (2020)** — TWFE failure modes and alternative estimands  
```bibtex
@article{deChaisemartinDHaultfoeuille2020,
  author  = {de Chaisemartin, Cl{\'e}ment and D'Haultfoeuille, Xavier},
  title   = {Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects},
  journal = {American Economic Review},
  year    = {2020},
  volume  = {110},
  number  = {9},
  pages   = {2964--2996}
}
```

3) **Borusyak, Jaravel & Spiess** (published version now exists; cite either WP or journal)  
```bibtex
@article{BorusyakJaravelSpiess2024,
  author  = {Borusyak, Kirill and Jaravel, Xavier and Spiess, Jann},
  title   = {Revisiting Event Study Designs: Robust and Efficient Estimation},
  journal = {American Economic Review: Insights},
  year    = {2024},
  volume  = {6},
  number  = {2},
  pages   = {215--232}
}
```

4) **Roth (2022/2023)** on pre-trends, pretesting, and sensitivity in DiD  
```bibtex
@article{Roth2022,
  author  = {Roth, Jonathan},
  title   = {Pretest with Caution: Event-Study Estimates after Testing for Parallel Trends},
  journal = {American Economic Review: Insights},
  year    = {2022},
  volume  = {4},
  number  = {3},
  pages   = {305--322}
}
```

## Missing inference literature for few treated clusters
Given only 6 treated states, you should cite and use tools from the few-cluster literature:

```bibtex
@article{CameronGelbachMiller2008,
  author  = {Cameron, A. Colin and Gelbach, Jonah B. and Miller, Douglas L.},
  title   = {Bootstrap-Based Improvements for Inference with Clustered Errors},
  journal = {Review of Economics and Statistics},
  year    = {2008},
  volume  = {90},
  number  = {3},
  pages   = {414--427}
}
```

```bibtex
@article{MacKinnonWebb2017,
  author  = {MacKinnon, James G. and Webb, Matthew D.},
  title   = {Wild Bootstrap Inference for Wildly Different Cluster Sizes},
  journal = {Journal of Applied Econometrics},
  year    = {2017},
  volume  = {32},
  number  = {2},
  pages   = {233--254}
}
```

## Missing noncompete / worker mobility policy literature
Your domain citations are selective. A top-journal paper needs a more complete map of:
- enforceability and labor market outcomes,
- entrepreneurship and innovation,
- contractual “shadow effects,”
- recent state reforms (e.g., MA, WA) and their empirical study if available.

At minimum, consider adding and engaging more directly with **Lavetti/Lipsitz/Johnson/Starr** strands beyond a single working paper mention, and any peer-reviewed updates if now published. (Your reference “Johnson et al. (2021) working paper” is too vague for a 2026 submission—update to the latest version and provide full details.)

If you cannot find journal versions, provide NBER/SSRN working paper bib entries with WP numbers and URLs in an appendix.

---

# 5. WRITING QUALITY (CRITICAL)

### Prose vs bullets (top-journal bar)
- The institutional background (Section 2.2) reads like policy notes rather than scholarly exposition.
- Results interpretation (Section 6.4) is list-like and would benefit from a coherent argument tying legal design → exposure → expected timing/magnitude → what the estimates can and cannot rule out.

### Narrative flow
- The paper has the right components (motivation → method → findings), but the narrative is not yet compelling enough for a general-interest journal:
  - The introduction (pp. 1–2) states facts and summarizes methods quickly, but does not **set up a sharp puzzle** (e.g., “Why do we see strong micro evidence but no aggregate movement after the biggest wave of reforms in decades?”).
  - The “contribution” claim (“first rigorous evaluation of Minnesota”) is plausible but not yet substantiated with an analysis that is truly MN-centered and institutionally tailored.

### Accessibility / magnitudes
- You report ATTs in percentage points/log points, but you do not clearly translate them into economically meaningful bounds (e.g., “we can rule out earnings increases larger than ~X% in the first Y quarters”).
- You should explicitly benchmark expected aggregate effects given only ~20% coverage by noncompetes and the prospective nature of MN.

### Tables/figures as communication tools
- For DiD papers, the event-study figure is the main object readers look at. Its absence is a major presentation failure.

---

# 6. CONSTRUCTIVE SUGGESTIONS (HOW TO MAKE THIS TOP-JOURNAL-READY)

## A. Redefine the estimand to match legal reality
1) **MN prospective ban**: focus on outcomes for:
- new hires (QWI has new-hire earnings),
- job-to-job movers (preferably LEHD J2J flows),
- industries/occupations with high noncompete prevalence.

2) **OR/IL threshold reforms**: do not pool them with bans.
- Use a **triple-difference**: high-earning vs low-earning categories (if QWI allows earnings bins) in treated vs control states, pre vs post.
- If QWI cannot support that, you likely need different data (UI micro, CPS with occupation/industry, or proprietary resume/job-switching data).

## B. Fix inference for “only 6 treated states”
- Add **randomization inference/permutation tests**: reassign treatment dates/states under plausible adoption processes and show where the true estimate sits in the placebo distribution.
- Add **wild cluster bootstrap** p-values.
- Report **MDE / power** calculations and translate into “effects we can rule out.”

## C. Show the full dynamic results
- Provide event-time coefficient plots and corresponding tables:
  - leads (at least -8 quarters if possible),
  - lags (bin long lags),
  - 95% CI bands,
  - cohort-specific event studies (or at least leave-one-out).

## D. Treatment heterogeneity and measurement
- Do not treat “restriction” as homogeneous. At minimum:
  - Estimate separately: (i) bans/near-bans (DC, MN) vs (ii) thresholds/duration (OR, IL) vs (iii) enforcement penalties (CO) vs (iv) carveouts (NV).
  - Alternatively, construct an **intensity score**: predicted fraction of workers newly uncovered by the reform (using pre-reform wage distribution + legal threshold).

## E. Improve data design (this is likely necessary)
State-level aggregates are a blunt instrument. A top-journal contribution likely requires at least one of:
- **Restricted-access LEHD microdata** (actual job-to-job transitions, earnings trajectories).
- **Border discontinuity / border-county DiD** around MN and other reforms (this can be compelling if executed carefully, with donut checks, spatial trends, and commuting-zone logic).
- **Occupation/industry subgroup analysis** where noncompetes are prevalent (tech, professional services, healthcare).

## F. Address contemporaneous confounds explicitly
2021–2023 was an unusual labor-market period. You should:
- control for other state policy changes (minimum wage, paid leave, UI supplements, etc.), or
- show that results are robust within narrower windows, or
- explicitly model macro heterogeneity (region-by-time effects, etc.).

## G. Clarify sample construction and weighting
- Resolve the 48 vs 47 states inconsistency and the N mismatch.
- Report results weighted by employment (average worker effect) vs unweighted (average state effect). In AEJ:EP this distinction matters.

---

# 7. OVERALL ASSESSMENT

## Key strengths
- Important policy question with high public interest.
- Uses an appropriate modern staggered DiD estimator (Callaway–Sant’Anna) rather than relying solely on TWFE.
- Transparently acknowledges plausible reasons for null results (power, aggregation, timing).

## Critical weaknesses (blocking for top journals)
1) **Not remotely ready in format/presentation**: too short; missing event-study figures; results not displayed in the way the field expects.
2) **Treatment definition is too coarse**: pooling fundamentally different legal reforms undermines interpretability.
3) **Inference is not credible with only 6 treated states** without randomization inference / wild bootstrap and careful power/bounds.
4) **Mismatch between policy design and outcome timing** (especially MN’s prospective ban): the paper’s main outcomes are not tailored to where effects should first appear.
5) **Insufficient robustness and heterogeneity analysis** given the identification burden and high likelihood of subgroup-concentrated effects.

## Bottom line
This is a promising project direction, but the current draft reads like an initial research memo rather than a top-journal submission. To become publishable in a top outlet, the paper likely needs (i) a redesigned empirical strategy around exposure/thresholds/border designs or micro data, (ii) substantially stronger inference, and (iii) a complete rewrite and expansion with publication-quality figures/tables.

DECISION: REJECT AND RESUBMIT