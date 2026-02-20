# Research Idea Ranking

**Generated:** 2026-02-20T19:40:47.755650
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6478

---

### Rankings

**#1: The Long Arc of Rural Roads — Dynamic Treatment Effects of PMGSY Over Two Decades**
- **Score: 76/100**
- **Strengths:** Builds on a very credible eligibility-threshold design with enormous sample size and adds genuinely valuable *dynamic* evidence on persistence/decay of infrastructure impacts—something policymakers and the infrastructure literature care about. Nightlights provide a rare annual panel to trace the time path, not just “before vs after Census.”
- **Concerns:** The design is unlikely to be truly **sharp**: PMGSY eligibility at 500 is best treated as an *instrument* for actual road completion (fuzzy RDD/IV), and dynamics should ideally be indexed to **construction/completion dates** (OMMAS) rather than eligibility year to avoid attenuation. Nightlights require careful DMSP/VIIRS harmonization and saturation corrections (especially in brighter places).
- **Novelty Assessment:** **Moderate.** PMGSY at the 500 cutoff is heavily studied (Asher & Novosad is canonical), but the *post-2011 long-run dynamic profile* with annual outcomes is plausibly new and publishable if executed cleanly.
- **Recommendation:** **PURSUE (conditional on: using fuzzy RDD/IV with road completion data or a defensible exposure measure; rigorous DMSP–VIIRS calibration and robustness to saturation/truncation).**

---

**#2: The Governance Gap — Census Town Classification and India's Subaltern Urbanization**
- **Score: 72/100**
- **Strengths:** High-upside question with clear policy relevance (urban governance vs rural panchayat administration) and a setting that is plausibly under-exploited. SHRUG gives unusually rich outcomes (nightlights + Census transitions) and a large local sample around the cutoff.
- **Concerns:** Identification is the main risk. Census Town status in 2011 is determined by **2011** population/density/sectoral composition—so using **2001 population** as the running variable makes the threshold less “mechanical” than it sounds and could load on underlying growth trajectories (i.e., 2001≥5000 may proxy for places already on a steeper urbanization path). First-stage strength and the interpretation of the LATE (“classification effect” vs “being on-track-to-urbanize”) need to be nailed down; manipulation/sorting is less obvious than in electoral settings but must be tested.
- **Novelty Assessment:** **High.** I’m not aware of a standard/popular RDD at the 5,000 Census Town threshold in India; most work is descriptive/typological or uses broader comparisons.
- **Recommendation:** **PURSUE (conditional on: demonstrating a strong first stage; showing continuity in 2001 covariates and pre-trends in nightlights; clarifying that the estimand is the effect of *classification/governance regime* rather than simply “larger villages”).**

---

**#3: Does Political Alignment Bring Development? A Village-Level Close Election RDD for Indian State Assemblies**
- **Score: 63/100**
- **Strengths:** Close-election RDD is a well-understood, high-credibility quasi-experimental tool when implemented carefully, and combining it with high-frequency nightlights could uncover short-run distributive favoritism that conventional survey outcomes miss. The question is politically salient and speaks directly to discretionary allocation.
- **Concerns:** Two identification/implementation pitfalls loom large: (i) **defining “alignment”** is nontrivial in Indian state elections because government formation is itself an election outcome—so “aligned with the ruling party” is partly post-election and can be endogenous unless you handle coalition formation/pivotality (e.g., drop elections where the statewide majority is razor-thin; define treatment relative to *pre-election incumbent government*; or explicitly model government formation). (ii) Boundary changes (delimitation) and constituency-village mapping can introduce measurement error that erodes the RDD signal.
- **Novelty Assessment:** **Low-to-moderate.** India close-election RDDs are common; “alignment/favoritism” has also been studied in many countries. The incremental novelty here is mainly **granularity (village/nightlights) + long panel**, not the core design.
- **Recommendation:** **CONSIDER (only if: alignment is defined in a way that is not mechanically tied to statewide seat totals; mapping/boundary issues are demonstrably clean; placebo tests and manipulation tests around the margin are strong).**

---

**#4: Breaking the Poverty Trap? Long-Run Effects of MGNREGA Phase I Assignment**
- **Score: 49/100**
- **Strengths:** If feasible, the long-run “head start” question is interesting and policy-relevant: it speaks to whether temporary early access to a large safety net produces persistent local development effects. Nightlights offer a rare long panel to study dynamics.
- **Concerns:** This is fragile on both reconstruction and identification: the backwardness index/cutoffs are often hard to reproduce exactly, and any mismatch between your reconstructed running variable and the official assignment creates serious error-in-variables problems right at the threshold. Substantively, the treatment is only a **~2-year timing difference** before universal rollout, so long-run effects are likely small and easily confounded by differential trends in “backward” districts, plus limited power near cutoffs with only a few hundred districts.
- **Novelty Assessment:** **Moderate.** The phase-assignment design is known (e.g., Zimmermann), and MGNREGA has an enormous literature; the novelty is mostly the long-run nightlights dynamic angle.
- **Recommendation:** **SKIP (unless: you can obtain the official index and exact cutoffs/assignment files; and you can show strong local balance + sufficient sample near cutoffs to detect realistically small long-run effects).**

---

### Summary

This is a relatively strong batch because two ideas are threshold/RDD-based with plausible administrative rules and large-scale data (Ideas **2** and **1**). I would start with **PMGSY dynamics (Idea 2)** because the identification and power can be extremely strong if you anchor exposure to actual road completion, and the dynamic contribution is genuinely useful. **Idea 1** is high-novelty but needs especially careful interpretation of what crossing 5,000 in 2001 truly “randomizes” about later Census Town classification. No ideas here are DiD, so the DiD checklist is not applicable.