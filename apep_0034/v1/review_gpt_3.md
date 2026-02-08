# GPT 5.2 Review - Round 3/10

**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** high
**Timestamp:** 2026-01-19T14:27:32.770010
**Response ID:** resp_007d48179441c11000696e30a63adc81909023035cf403efdb
**Tokens:** 8916 in / 7168 out
**Response SHA256:** 6402c32955d5eb98

---

## Referee Report: “Breaking the Chains of Contract: The Labor Market Effects of State Noncompete Agreement Restrictions” (Jan 2026)

### Summary (what the paper does, why it matters)
The paper studies the labor-market effects of six state-level noncompete-agreement (NCA) reforms adopted 2021–2023 (NV, OR, IL, DC, CO, MN), using state–quarter outcomes from the Census QWI (2018Q1–2024Q2). The main design is staggered DiD using Callaway–Sant’Anna (CS) group-time ATTs with never-treated states as controls. The headline results are null short-run effects on aggregate turnover and average earnings (Abstract p.1; Results pp.9–12).

This is an important policy question and the authors make an appropriate initial methodological choice (heterogeneity-robust DiD rather than naive TWFE). However, in its current form the paper is not close to publishable in a top general-interest journal: the contribution is limited by (i) severe aggregation that mechanically attenuates effects, (ii) heterogeneous and often *prospective/thresholded* legal changes bundled into one treatment, (iii) very short post periods for key reforms (especially Minnesota), (iv) unresolved inference challenges with only six treated clusters, and (v) major presentation problems (length, bullet-style exposition in key sections, placeholder figures).

---

# 1. FORMAT CHECK

### Length
- **Fail for top journals.** The manuscript as provided is **~17 pages** including references (page numbers shown run to 17). Top general-interest outlets typically expect **≥25 pages of main text** (excluding refs/appendix), and often substantially more when the design requires extensive robustness and institutional detail. You will need a substantial expansion (likely +15–30 pages including appendices).

### References / coverage
- The reference list includes core NCA and DiD citations (Gilson 1999; Marx et al. 2009; Starr et al. 2019, 2021; CS 2021; Sun–Abraham 2021; Goodman-Bacon 2021; de Chaisemartin–D’Haultfoeuille 2020; Borusyak et al. 2024; Roth 2022; MacKinnon–Webb 2017).
- **But it is not yet adequate** for (i) inference with few treated clusters in DiD, (ii) modern DiD sensitivity/robustness, and (iii) closely related NCA empirical/policy work (details in Section 4 below).

### Prose vs bullets (major sections must be paragraphs)
- **Problem.** Several major parts read like a policy memo/technical report rather than an AER/QJE paper:
  - Institutional background lists each reform in bullet-like blocks (Section 2.2, pp.3–4).
  - Data section uses bullets for key variables (Section 5.1, p.6), which is fine, but the surrounding narrative is thin.
  - Event-study “figure” is essentially a placeholder plus bullet summary (Section 7.1, p.11).
- For top journals, **Introduction/Results/Discussion must be fully written prose with a narrative arc**. Bullets can appear in an appendix or briefly in Data for definitions, not as a substitute for exposition.

### Section depth (3+ substantive paragraphs each)
- Some sections meet this (Introduction, Related Literature subsections).
- Others do not:
  - **Section 7 (“Robustness and Heterogeneity”) is not developed**; it mostly asserts robustness, but does not show results (pp.10–13).
  - **Conclusion** is mostly a list of caveats (pp.14–15) rather than a deep interpretation and reconciliation with prior evidence.

### Figures
- **Fail.** Figure 1 is not a real figure (“[Event study coefficients with 95% CIs]”, p.11). A top journal will desk-reject a paper with placeholder figures. Event-study plots must show estimates, axes, CI bands, sample windows, and omitted period.

### Tables
- Tables shown have real numbers (e.g., Tables 1–2). That said:
  - There is an **internal inconsistency**: N is reported as **1,207** (Table 2 notes, p.9) but later the text says **1,212** (MDE section, p.13). This must be reconciled.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors
- **Pass for the main table.** Table 2 reports SEs in parentheses and mentions state clustering (p.9). Good.

### (b) Significance testing
- **Mostly pass.** Table 2 has wild bootstrap p-values and conventional SE-based inference. However:
  - You do not report p-values (or SEs) for the *event-study coefficients* because the event-study is not actually displayed. For publication, **every plotted coefficient must have an underlying table or directly readable uncertainty**.

### (c) Confidence intervals
- **Pass for main estimates.** Table 2 provides 95% CIs.

### (d) Sample sizes
- **Partial pass.** N is reported for Table 2, but (i) the N discrepancy noted above must be fixed, and (ii) any additional specifications/robustness/heterogeneity analyses must report N as well.

### (e) DiD with staggered adoption
- **Pass in principle.** Using Callaway–Sant’Anna with never-treated controls is the right direction (Section 5.3, p.7; Table 2 Panel A, p.9).
- However, for a top journal you need to be much more explicit about:
  - exact CS implementation choices (universal base period vs varying base, not-yet-treated vs never-treated, weighting scheme, anticipation),
  - how you handle missing cells and QWI suppression,
  - whether you use outcome regression / doubly robust CS, and
  - whether you weight by state employment (see below).

### (Inference with few treated clusters — currently not resolved)
This is the biggest statistical concern.

You have **only six treated jurisdictions**, and treatment timing is staggered, leaving very few treated units contributing at each event time. Cluster-robust SEs are unreliable in this setting; wild bootstrap helps, but **does not fully solve design-based uncertainty** with staggered adoption and only 6 treated clusters.

You gesture at randomization inference in Section 3.4 (p.5) but **do not implement it**. For a top journal, you likely need at least one of:
1. **Randomization inference / permutation tests** over treated states and/or adoption timing (sharp null), reported for main outcomes.
2. **Conley–Taber-style inference** (or modern analogs) tailored to few treated groups.
3. A **design with more treated units** (e.g., expand to earlier reforms, or use a continuous/treatment-intensity design across many states using thresholds/enforceability).

**As written, the paper’s inference is not yet at the standard required for AER/QJE/JPE/ReStud/ECTA.** I would not call it “unpublishable” on inference alone (you do have SEs/CIs and a bootstrap), but it is **not yet credible enough** for a top general-interest venue.

### Additional econometric concerns you must address
- **Weighting:** You report unweighted summary stats (Table 1 notes, p.9). Are the DiD estimates population-weighted or equally weighted by state? In state-policy evaluation, both can be informative, but you must be explicit and ideally report both. The estimand differs dramatically.
- **Outcome definition & composition:** QWI “average earnings among stably employed workers” (Section 5.1, p.6) is vulnerable to composition changes induced by policy (even if mobility doesn’t change). You need to discuss and test composition sensitivity.
- **Standard errors for aggregated panels:** With state-quarter panels, serial correlation is material. State clustering is necessary but, again, insufficient with 48 clusters and only 6 treated; you should report alternative inference (RI, cluster bootstrap variants, etc.).

---

# 3. IDENTIFICATION STRATEGY

### Credibility of identification
The paper’s central identification claim is parallel trends between treated states and never-treated states (Section 5.4, p.8), supported by an event study and a joint pre-trends test (Section 7.1, p.11). In principle that is standard.

But in this application, identification is substantially weaker than the writeup suggests, for four reasons:

1. **Treatment is not a single policy.** You bundle fundamentally different legal changes (full ban, income thresholds, hourly carve-outs, criminal penalties) into one “restriction” indicator (Section 7.4, p.12). This makes the treatment ill-defined and the pooled ATT hard to interpret structurally or for policy.

2. **Prospective applicability implies mechanically small short-run effects.** Minnesota’s ban is explicitly prospective (Section 2.2, p.4), so existing contracts may remain. Many threshold reforms affect only a slice of workers. In aggregate state-level outcomes, the “first-stage” (share actually affected) is likely tiny in 2018–2024.

3. **Short post windows, especially for MN.** You have at most ~3–4 quarters post for Minnesota (Section 6.4, p.10), which is not enough for equilibrium adjustments, contract turnover, litigation deterrence, or employer substitution into other restraints.

4. **Spillovers/SUTVA violations are plausible.** For example, MN’s ban could affect cross-border commuting to WI/ND/SD and firm location decisions. With state-level aggregates, spillovers contaminate both treated and controls.

### Placebos and robustness
You list robustness ideas (alternative controls, placebo tests, MN neighbors) but you **do not actually present** the placebo estimates, alternative-control estimates, or MN-neighbor DiD results in tables/figures (Section 5.4, p.8; Section 7.2–7.5, pp.12–13). Top journals require those results, not descriptions.

### Do conclusions follow?
Your conclusion is appropriately cautious given null results (Section 8, pp.14–15). However, you sometimes imply that the null is informative about policy effectiveness, when the paper’s own discussion suggests **low power and severe attenuation** (Section 6.4, p.10; Section 7.6, p.13). The correct interpretation is closer to: *“state-quarter aggregates cannot detect the plausible effects implied by micro evidence, especially when reforms are prospective/thresholded.”*

---

# 4. LITERATURE (missing references + BibTeX)

### Methodology you should add (high priority)
1. **Conley & Taber (2011)** — canonical DiD inference with few treated groups.
```bibtex
@article{ConleyTaber2011,
  author  = {Conley, Timothy G. and Taber, Christopher R.},
  title   = {Inference with {Difference} in {Differences} with a Small Number of Policy Changes},
  journal = {Review of Economics and Statistics},
  year    = {2011},
  volume  = {93},
  number  = {1},
  pages   = {113--125}
}
```

2. **Cameron & Miller (2015)** — practical clustering guidance; you cite Cameron et al. (2008) but this review piece is standard.
```bibtex
@article{CameronMiller2015,
  author  = {Cameron, A. Colin and Miller, Douglas L.},
  title   = {A Practitioner's Guide to Cluster-Robust Inference},
  journal = {Journal of Human Resources},
  year    = {2015},
  volume  = {50},
  number  = {2},
  pages   = {317--372}
}
```

3. **Arkhangelsky et al. (2021) Synthetic DiD** — very relevant alternative estimator, especially with few treated and strong time shocks (COVID).
```bibtex
@article{ArkhangelskyEtAl2021,
  author  = {Arkhangelsky, Dmitry and Athey, Susan and Hirshberg, David A. and Imbens, Guido W. and Wager, Stefan},
  title   = {Synthetic Difference-in-Differences},
  journal = {American Economic Review},
  year    = {2021},
  volume  = {111},
  number  = {12},
  pages   = {4088--4118}
}
```

4. **Rambachan & Roth (2023)** — sensitivity to violations of parallel trends (you cite Roth 2022 but not the sensitivity framework).
```bibtex
@article{RambachanRoth2023,
  author  = {Rambachan, Ashesh and Roth, Jonathan},
  title   = {A More Credible Approach to Parallel Trends},
  journal = {Review of Economic Studies},
  year    = {2023},
  volume  = {90},
  number  = {5},
  pages   = {2555--2591}
}
```

5. **Abadie, Diamond, Hainmueller (2010)** — synthetic control as an alternative for Minnesota (single prominent reform).
```bibtex
@article{AbadieDiamondHainmueller2010,
  author  = {Abadie, Alberto and Diamond, Alexis and Hainmueller, Jens},
  title   = {Synthetic Control Methods for Comparative Case Studies: Estimating the Effect of {California}'s Tobacco Control Program},
  journal = {Journal of the American Statistical Association},
  year    = {2010},
  volume  = {105},
  number  = {490},
  pages   = {493--505}
}
```

### Domain/policy literature you should engage (illustrative)
Your NCA literature leans heavily on Gilson/Marx/Starr and cross-state enforceability indices. A top journal will expect you to engage more with:
- empirical work on **worker mobility restrictions and monopsony** more broadly,
- **post-2010 NCA policy changes** (several states changed laws earlier than 2021),
- and the legal/institutional literature on enforceability vs incidence and substitution to NDAs/non-solicits.

Concrete additions (at minimum) should include: (i) a careful mapping of reforms across *all* states over a longer horizon, (ii) evidence on NCA incidence by state/industry/occupation (e.g., using survey data), and (iii) work on substitutes to NCAs.

(If you want, I can propose a more tailored list once you specify whether you are willing/able to use restricted-access LEHD, CPS/ASEC, SIPP, or private datasets like Revelio/LinkedIn.)

### Contribution relative to prior work
Right now, the paper claims “first rigorous evaluation” of MN and the 2021–23 wave (Introduction p.2), but with 3–4 post quarters and state-level aggregates, the evaluation is not “rigorous” in the sense top journals use (i.e., sharply defined treatment, strong first stage, compelling design, and decisive inference). You need to reposition the contribution more honestly (e.g., “state-level aggregates show no detectable short-run effects; we bound effects above X”) and then **add designs/outcomes where effects should appear if the mechanism is real**.

---

# 5. WRITING QUALITY (CRITICAL)

### Prose vs bullets
- **Fail for a top journal in current form.** The paper repeatedly uses bullet lists to carry important content (policy descriptions, variable definitions, figure “content,” interpretation). For AER/QJE/JPE/ReStud, the *main text* should be paragraphs with a clear narrative; bullets belong in an appendix.

### Narrative flow and framing
- The opening motivation is standard and fine, but the paper does not provide a compelling “why now/why this design reveals something new” hook beyond “new reforms exist” (Intro pp.1–2).
- The story also lacks a tight link between (i) the micro evidence in Starr et al. and (ii) what is detectable in QWI aggregates. You only raise attenuation/power late (Section 6.4, p.10), but it should be front-and-center.

### Sentence-level clarity
- Generally readable, but it reads like a report: many claims are asserted without showing corresponding figures/tables (e.g., pre-trend ranges, cohort-specific estimates, placebo tests). Top outlets will penalize this.

### Accessibility
- Econometric choices are named (CS estimator, heterogeneity concerns) but the intuition for the estimand and the weighting is not well explained, and legal nuance (prospective vs retroactive; enforceability vs signing) is not integrated into the empirical predictions.

### Tables/Figures quality
- Not publication-ready. The event-study must be a real figure, and robustness must be in appendix tables/figures with clear captions and notes.

---

# 6. CONSTRUCTIVE SUGGESTIONS (how to make this publishable)

## A. Fix the “first stage”: measure who is actually affected
Right now the treatment is an indicator for “restriction enacted.” That is too coarse. You need an estimand closer to: effect per exposed worker.

Options:
1. **Treatment intensity**: Construct an exposure measure using pre-policy NCA incidence by state × occupation/industry (from surveys like Starr et al. or other sources). Estimate event studies with intensity (continuous DiD).
2. **Exploit thresholds** (IL/OR/DC): Use QWI stratification by earnings/age/industry to approximate the affected margin; show effects above vs below threshold-like groups (imperfect but better than aggregates).
3. **Industry/occupation focus**: QWI allows disaggregation by NAICS and worker characteristics. At minimum, show results for sectors plausibly heavy in NCAs (professional/technical services, finance, information).

## B. Change outcomes to ones that should move quickly
Aggregate turnover may be too blunt. Consider:
- **new-hire earnings** (wage posting competition may show up there first),
- **separation and hire rates separately** (you list them but don’t emphasize results),
- **job-to-job flows** if available (or proxied),
- **firm entry / establishment dynamics** (if you can merge in BDS or similar) given the entrepreneurship channel.

## C. Minnesota deserves a dedicated design
If you want “first evaluation of Minnesota,” do it properly:
- **Border-county design** (MN vs WI/IA/SD) using county-level data (restricted LEHD if necessary). State aggregates are not credible for this claim.
- **Synthetic control / synthetic DiD** as a main design for MN, with transparent donor pool and placebo permutations.

## D. Strengthen inference explicitly for few treated states
Implement at least two of:
- **Randomization inference** (state-level permutation of adoption among eligible states; report exact/approximate p-values),
- **Conley–Taber** style inference,
- **Design-based aggregation**: present cohort-specific effects with honest uncertainty and avoid over-aggregating into one ATT that masks heterogeneity and shrinks SEs artificially.

## E. Address confounding contemporaneous policies and COVID dynamics
Given 2018–2024 spans COVID and recovery, you should:
- show robustness to **dropping 2020–2021** or modeling pandemic dynamics flexibly,
- control for major contemporaneous state policies (minimum wage hikes, UI changes, paid leave, etc.) or at least show they are not differentially timed with NCA reforms.

## F. Presentation overhaul
- Replace Section 2.2 bullets with a narrative institutional section and a table summarizing: effective date, applicability (prospective/retroactive), coverage (thresholds), enforcement mechanism, expected exposed share.
- Provide a full event-study figure with readable axes and confidence bands; put all event-study coefficients in an appendix table.
- Resolve all internal inconsistencies (N, dates-to-quarters mapping, outcome definitions).

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important policy question with active state experimentation (Intro/Background).
- Correct recognition that TWFE is problematic with staggered adoption; CS estimator is an appropriate starting point (Sections 3.3, 5.3).
- Appropriate caution in interpreting null effects; mentions power and aggregation issues (Sections 6.4, 7.6).

### Critical weaknesses (deal-breakers for a top journal in current form)
1. **Not enough evidence shown**: placeholder figure; robustness described but not presented.
2. **Treatment is ill-defined**: pooling heterogeneous reforms into one binary treatment undermines interpretability.
3. **Aggregation likely destroys identification power**: state-level QWI is too coarse for mechanisms operating on a minority of workers, especially with prospective laws.
4. **Inference remains incomplete with only six treated clusters**: wild bootstrap is not sufficient by itself; RI/Conley–Taber/sensitivity needed.
5. **Manuscript not at top-journal polish**: too short; bullet-heavy in key places; reads like a report rather than a paper.

---

DECISION: REJECT AND RESUBMIT