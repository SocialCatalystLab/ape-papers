# Final Review

**Purpose:** Log the paper's final state after all revisions
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Timestamp:** 2026-01-29T19:19:36.535591
**Response ID:** resp_0bd26e0d036b6aa800697ba4054944819090deb00c2c8ba12c
**Tokens:** 21718 in / 6786 out
**Response SHA256:** 3d80a8a39a118a90

---

## Referee Report: “Recreational Marijuana Legalization and Business Formation: Evidence from Staggered State Adoption” (Jan 29, 2026)

### Summary
The paper studies whether opening recreational marijuana retail markets affects entrepreneurship, proxied by state-level EIN applications from the Census Business Formation Statistics (BFS), exploiting staggered adoption (first retail sales) across 21 states (2014–2024). The preferred estimator is Callaway & Sant’Anna (2021) using never-treated controls. The headline estimate is small and imprecise (overall ATT ≈ −0.028 log points; Table 3, p.16). Event studies show no clear pre-trends and suggest gradually more negative effects over 6–7 years (Figure 2, p.19). Numerous robustness checks are provided (Table 6, p.21–23).

The paper is competently executed and uses modern DiD tools. However, for a top general-interest outlet, the **identification is not yet persuasive at the state-year level**, the **main effect is statistically weak and economically ambiguous**, and the **paper lacks a compelling mechanism or sharper design** to interpret a small negative change in total applications in the presence of likely sectoral reallocation and cross-border spillovers. A substantial redesign/extension is needed.

---

# 1. FORMAT CHECK

**Length**
- Appears to be ~35 pages total including appendix (appendix starts ~p.31; references around p.27–30). Main text is roughly **p.1–26**, i.e., **meets the 25-page minimum** (excluding references/appendix).

**References**
- Bibliography covers key DiD-with-staggering papers (Callaway–Sant’Anna; Goodman-Bacon; Sun–Abraham; de Chaisemartin–D’Haultfœuille; Borusyak–Jaravel–Spiess) and BFS/entrepreneurship citations (Haltiwanger; Decker et al.).
- Domain/policy literature is **thin** given the ambition (see Section 4 below). Several important adjacent methods papers are missing (synthetic DiD, interactive FE, cluster wild bootstrap practice).

**Prose vs bullets**
- Major sections (Intro, Results, Discussion) are in paragraph form. Bullets are mainly in Data/variable definitions (acceptable).

**Section depth**
- Intro (pp.1–4) has multiple substantive paragraphs and a clear roadmap.
- Institutional background and conceptual framework have multiple subsections; generally ≥3 substantive paragraphs per major section.
- Results and Discussion are reasonably developed.

**Figures**
- Figures shown (Figure 1, Figure 2, Figure 3, Figure 4, Figures 5–6 in appendix) have visible data, axes, titles, and uncertainty bands (good).
- For publication quality: font sizes and line weights look “working paper” rather than journal-ready; also some figures rely on color only (needs grayscale-friendly styling).

**Tables**
- Tables contain real numbers (no placeholders), include SEs and/or CIs, and report N (good).

**Format issues to flag**
- Several claims of “log points” are slightly sloppy: “−0.028 log points” is fine, but interpretation should consistently map to percent changes (approx 2.8%) and clarify when using log(y/pop) (percent change in per-capita applications).
- Table/figure notes are generally good, but abbreviations (BA/HBA/WBA/CBA/BF8Q) should be reiterated in every relevant table note for standalone readability.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard Errors
**Pass.** Coefficients in TWFE tables have SEs in parentheses and CIs in brackets (e.g., Table 4, p.17; Table 5, p.19–20). CS estimates report bootstrap SEs (Table 3, p.16).

### (b) Significance Testing
**Pass (with caveats).** You report SEs/CIs and p-values in robustness inference (randomization inference; bootstrap p-values, Table 6 and text around p.23). However:
- Event-study inference is incomplete: you explicitly state a **joint pre-trends test cannot be computed due to a singular covariance matrix** (Appendix B.1, ~p.32). That is a red flag for a top journal unless fixed.

### (c) 95% Confidence Intervals
**Pass.** Main results include 95% CIs.

### (d) Sample Sizes
**Pass.** N is reported across tables; BF8Q sample limitations are clearly disclosed (pp.9–10; Table 5; Section 6.5).

### (e) DiD with staggered adoption
**Pass (design choice is modern).** You correctly treat TWFE as a benchmark and use Callaway–Sant’Anna with never-treated controls as the main specification (Section 5.3; Table 3).

**But:** the paper should do more to demonstrate that the CS implementation is statistically well-behaved in your setting:
- Clarify whether you use **state-level clustered bootstrap** (resampling states) versus naive bootstrap on state-years. With 51 clusters, implementation details matter.
- Consider reporting alternative robust DiD estimators (Sun–Abraham; Borusyak–Jaravel–Spiess imputation; Gardner 2SDiD) as *main* robustness, not only as citations.

### (f) RDD
Not applicable.

**Bottom line on methods:** The paper clears the minimum “publishable” bar for inference and staggered DiD implementation. The core obstacle is not “no SEs” (you have them), but **credibility of identification and interpretability of the estimand** given treatment timing, spillovers, and aggregation.

---

# 3. IDENTIFICATION STRATEGY

### Credibility of identification
The identification rests on **state-level parallel trends** in business applications per capita, comparing treated states to never-treated (or subsets) around retail opening.

This is a high-level policy DiD with strong reasons to worry about violations:

1. **Policy endogeneity / differential macro trends.**
   - States that open recreational retail differ systematically (politics, migration, industrial composition, tech sector, urbanization) and may have different post-2014 entrepreneurial dynamics independent of cannabis policy. State FE absorbs levels, not differential growth paths.
   - Your event-study shows no statistically significant pre-trends, but (i) annual data are low power; (ii) you report pre-trend point estimates up to ~0.08 in magnitude (Appendix B.1), comparable to some post effects. That undermines the “parallel trends is fine” narrative.

2. **Annual aggregation creates serious exposure misclassification.**
   - You treat “treatment year” as the year of first retail sales, but opening dates vary widely within year (e.g., Ohio Aug 2024; Maine Oct 2020). With annual outcomes, “event time 0” is not comparable across cohorts and will attenuate and distort dynamics (you acknowledge this in Discussion, Section 7.3, p.24–25). For top journals, acknowledging is not enough—**you should implement the monthly design**.

3. **Spillovers and interference.**
   - You do an “interior states” restriction (Table 6; text around p.22–23), which is useful but blunt and produces a very small control group (9 states). That raises external validity and precision issues and may select on regional trends (the interior set is heavily Southern + HI + MN).

4. **Choice of “never-treated” controls includes states that partially treated (legal possession but no retail).**
   - Coding VA/DE/MN as never-treated may be problematic if legalization itself (possession/homegrow) affects business behavior (tourism, enforcement, expectations) before retail. You motivate retail as the relevant treatment (reasonable), but then those states are neither clean controls nor treated. At minimum: treat them as a separate “legal-no-retail” group or drop them in robustness.

5. **No mechanism test.**
   - A small negative effect on total EIN applications is hard to interpret without showing where it comes from (industries, employer vs non-employer, reallocation to existing firms, etc.). Your BFS series decomposition is helpful but not decisive; BF8Q is not causally identified (Section 6.5, p.20). For a top journal, readers will ask: *What is the economic channel?* Right now, the conceptual framework offers many possibilities but the empirics do not discriminate among them.

### Assumptions discussed?
- Parallel trends is discussed (Section 5.1; Appendix B.1) and you cite Roth (2022), which is good.
- But the paper does not deliver the stronger modern practice: sensitivity/bounds (Rambachan–Roth HonestDiD), pooled/binned leads, or alternative identification strategies.

### Placebos / robustness
- Strength: multiple robustness checks (COVID exclusion; medical-only controls; interior controls; randomization inference; pairs cluster bootstrap).
- Weakness: many robustness checks are variants of the same design, rather than tests that isolate the channel or strengthen identification (e.g., border-county design; within-state local option variation; placebo outcomes; negative controls).

### Do conclusions follow?
- Generally yes: you are careful about imprecision and about BF8Q not being causal.
- But the Discussion sometimes leans into interpretation (“regulatory burden deters marginal entrepreneurs”) without direct evidence. For a top journal, you need either (i) sharper evidence on mechanisms, or (ii) more circumspect interpretation.

### Limitations
- You candidly discuss limitations (COVID, annual aggregation, spillovers, BF8Q timing). This is a strength—but again, the biggest limitations are so central that they threaten publishability without major additional work.

---

# 4. LITERATURE (missing references + BibTeX)

### Methods literature to add (high priority)

1) **Synthetic DiD / SCM family** (particularly relevant given staggered adoption, few treated units early, and concerns about differential trends)
- Arkhangelsky et al. (2021) Synthetic DiD is now standard in policy evaluation with staggered adoption.
```bibtex
@article{Arkhangelsky2021,
  author  = {Arkhangelsky, Dmitry and Athey, Susan and Hirshberg, David A. and Imbens, Guido W. and Wager, Stefan},
  title   = {Synthetic Difference-in-Differences},
  journal = {American Economic Review},
  year    = {2021},
  volume  = {111},
  number  = {12},
  pages   = {4088--4118}
}
```

2) **Augmented synthetic control** (improves fit, helps with differential trends; natural complement to your “interior controls” idea)
```bibtex
@article{BenMichael2021,
  author  = {Ben-Michael, Eli and Feller, Avi and Rothstein, Jesse},
  title   = {The Augmented Synthetic Control Method},
  journal = {Journal of the American Statistical Association},
  year    = {2021},
  volume  = {116},
  number  = {536},
  pages   = {1789--1803}
}
```

3) **Matrix completion / interactive FE** (addresses unobserved time-varying confounders; relevant when state entrepreneurial trends differ)
```bibtex
@article{Athey2021,
  author  = {Athey, Susan and Bayati, Mohsen and Doudchenko, Nikolay and Imbens, Guido W. and Khosravi, Kevan},
  title   = {Matrix Completion Methods for Causal Panel Data Models},
  journal = {Journal of the American Statistical Association},
  year    = {2021},
  volume  = {116},
  number  = {536},
  pages   = {1716--1730}
}
```

4) **Cluster-robust inference practice (wild bootstrap)**  
You cite MacKinnon et al. (2023) but do not implement the canonical wild-cluster bootstrap-t for key estimates. Add and (ideally) implement:
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
(If you use `boottest`, also cite Roodman et al.)
```bibtex
@article{Roodman2019,
  author  = {Roodman, David and Nielsen, Morten \O rregaard and MacKinnon, James G. and Webb, Matthew D.},
  title   = {Fast and Wild: Bootstrap Inference in Stata Using boottest},
  journal = {The Stata Journal},
  year    = {2019},
  volume  = {19},
  number  = {1},
  pages   = {4--60}
}
```

5) **Cluster SE foundations** (often requested by general-interest referees/editors)
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

### Domain/policy literature to strengthen positioning (medium/high priority)
Your domain citations are mostly broad reviews and a small set of cannabis economics papers. For a top journal, you should engage more directly with:
- papers on **local dispensary openings** and local economic outcomes (beyond the one you cite),
- papers on **banking/credit constraints** and regulated industries,
- papers on **policy spillovers across borders** (particularly for “sin” goods).

I am not listing BibTeX here because the cannabis-specific empirical literature is sprawling and heterogeneous in quality; but the revision should add 8–15 tightly relevant, peer-reviewed studies and clearly distinguish how your outcome (EIN applications) complements/contrasts with establishment births, employment, and sectoral reallocation evidence.

---

# 5. WRITING QUALITY (CRITICAL)

### (a) Prose vs bullets
- **Pass.** Intro/Results/Discussion are in paragraphs. Bullets are mostly definitional (fine).

### (b) Narrative flow
- Motivation is clear and topical, but the paper reads more like a careful policy memo than a “must-read” general-interest contribution.
- The introduction could be sharper on the core puzzle: why would a major deregulation that creates a new industry reduce total applications? That tension is your hook—lean into it earlier and more explicitly.

### (c) Sentence quality
- Generally competent and readable.
- But there is some repetitiveness (“modest but imprecise,” “cannot be interpreted causally,” etc.)—true, but can be tightened.

### (d) Accessibility
- Econometric choices are explained reasonably well for an econ audience; “BF8Q is forward-looking” is clearly explained (good).
- The magnitude discussion sometimes mixes “log points,” “percent,” and “applications per year” in a way that invites confusion. Standardize: report % effects and implied count changes for representative states (small/median/large).

### (e) Figures/Tables
- Clear, but not yet journal-polished (font sizes, grayscale compatibility, richer notes).
- Event study (Figure 2, p.19): readers will want simultaneous confidence bands and transparent binning of long leads/lags.

---

# 6. CONSTRUCTIVE SUGGESTIONS (what would make this publishable)

## A. Re-estimate at **monthly frequency** (essential, not optional)
You explicitly acknowledge annual misclassification (Section 7.3). Given BFS is monthly, a top-journal revision should:
- Use state×month panel, with **month-by-year fixed effects** (or year-month FE) and state FE.
- Define treatment at the **exact month of first retail sales**.
- Recompute CS (or BJS imputation) event studies in monthly event time.
This single change would materially improve identification and the interpretability of event-time 0/1/2.

## B. Fix event-study inference and pre-trends diagnostics (currently not top-journal standard)
- Bin leads (e.g., ≤−5) and lags (e.g., ≥+5) to avoid singular covariance and to stabilize estimates.
- Implement **Rambachan–Roth HonestDiD** sensitivity bounds for the main ATT and a few dynamic post periods.
- Report a **joint test** of pre-trends after binning (or using an estimator that yields a well-conditioned covariance).
- Provide **simultaneous confidence bands** for the event study (not just pointwise CIs).

## C. Address policy endogeneity with stronger designs
State-level DiD is unlikely to convince AER/QJE/JPE unless paired with a sharper strategy. Options:
1. **Border-county design** (preferred): Compare counties near treated–untreated borders; exploit timing of retail opening; test spillovers explicitly.
2. **Within-state local option / municipality bans**: Many states allow local bans. Use within-state variation to identify effects of actual market access rather than statewide legal status.
3. **Synthetic DiD / augmented SCM** for early adopters: Colorado/Washington are pivotal; show that results are not an artifact of differential trends.

## D. Mechanisms: show *what changes* in entrepreneurship
Right now the outcome is aggregate applications. To interpret a negative effect, you need evidence of composition or displacement:
- Link BFS to any available **industry proxies** (even if not NAICS-by-state in BFS): e.g., use QCEW/CBP/BDS sector outcomes, business registrations by sector, or alternative data (NETS, SafeGraph foot traffic to dispensaries, etc.).
- Show whether the decline is in **non-employer-type** applications (speculative/self-employment) versus employer-intent (you partially do this with WBA/HBA, but effects are weak).
- If feasible, examine **application-to-employer conversion rates** in a way not mechanically contaminated (your BF8Q critique is correct; redesign is needed). One approach: use formation-year measures (BDS establishment births) even if lagged, focusing on cohorts up to 2021/2022.

## E. Treatment definition and control groups
- Separate “legal possession but no retail” states from true never-treated; include as (i) excluded, (ii) separate group, or (iii) an additional treatment stage (two-stage policy adoption).
- Consider multi-valued treatment: legalization date, retail opening date, and later policy shocks (e.g., banking guidance changes, enforcement memos) to better align with theory.

## F. Inference upgrades
- Implement **wild cluster bootstrap-t** for TWFE benchmarks and, where feasible, for aggregated post-treatment contrasts in CS-style estimates.
- For permutation tests: clarify and justify the randomization scheme (does it preserve adoption-year distribution and “no adoption before 2014”? does it preserve regional clustering?).

---

# 7. OVERALL ASSESSMENT

### Strengths
- Uses an appropriate modern DiD estimator for staggered adoption (CS) and transparently contrasts it with TWFE (Tables 3–4).
- Careful about BF8Q timing and does not overclaim causality there (Section 6.5).
- Good transparency on data construction and sample limitations (Section 4).
- Robustness checks go beyond defaults (randomization inference, bootstrap; interior controls).

### Critical weaknesses (why this is not ready for a top journal)
1. **Identification is not sharp enough** at the state-year level given plausible differential trends, COVID-era confounding, endogenous policy adoption, and spillovers.
2. **Annual aggregation** undermines treatment timing and dynamic interpretation (you admit this; it must be fixed).
3. **Event-study inference is incomplete** (singular covariance; no joint pre-trend test in the main specification).
4. **Mechanisms are speculative**: without sectoral/within-state evidence, it is hard to interpret a small negative effect on aggregate applications.

### Concrete path to a successful revision
A credible “top-journal” version likely needs: monthly design + stronger pre-trend diagnostics/sensitivity + either border-county or within-state local-option variation + clearer mechanism evidence (industry/employer-intent/reallocation).

---

DECISION: MAJOR REVISION