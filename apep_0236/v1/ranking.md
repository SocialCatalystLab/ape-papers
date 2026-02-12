# Research Idea Ranking

**Generated:** 2026-02-12T12:08:44.905870
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7961

---

### Rankings

**#1: Licensing to Log In: The Interstate Medical Licensure Compact and Healthcare Supply Creation (Idea 1)**
- **Score: 77/100**
- **Strengths:** Large, policy-driven staggered adoption (many states; multiple cohorts) with long pre-periods makes this one of the cleaner opportunities in the remote-work/licensing space. High policy relevance: IMLC is a central “cross-state telehealth infrastructure” reform and expansion is ongoing.
- **Concerns:** The proposed QCEW outcomes (NAICS 62 / even 621) risk **outcome dilution** because IMLC directly targets *physicians’ licensing* while employment/wages in broad healthcare sectors are dominated by non-physician labor. Also, adoption may correlate with unobserved state preferences for deregulatory health policy (selection).
- **Novelty Assessment:** **Good novelty.** I know of limited causal work directly on IMLC; most related work is on occupational licensing broadly or telehealth utilization, not state healthcare establishment creation.
- **DiD Assessment (MANDATORY 8 criteria):**
  - **Pre-treatment periods:** **Strong** (2012Q1–2016Q4 gives 5+ years before 2017Q2 first go-live)
  - **Selection into treatment:** **Marginal** (state adoption is political/administrative; plausibly not driven by *short-run* healthcare employment shocks, but not clearly exogenous)
  - **Comparison group:** **Marginal** (never-treated includes very distinctive states like CA/NY; you’ll likely need robustness with matched controls / dropping outliers)
  - **Treatment clusters:** **Strong** (~42 treated states; many cohorts)
  - **Concurrent policies:** **Marginal** (post-2020 telehealth/COVID regulatory shocks overlap with later cohorts; needs careful controls or sample restrictions)
  - **Outcome-Policy Alignment:** **Marginal** as written (QCEW NAICS 62/621 is not physician-specific; stronger alignment if you focus on **NAICS 621111 Offices of Physicians**, physician wages, physician establishments, or combine with NPPES/AMA physician counts)
  - **Data-Outcome Timing:** **Strong** if coded correctly (IMLC operational April 2017 → **2017Q2** is full-quarter exposure; for later states, code treatment at the **first full quarter** after operational date if mid-quarter)
  - **Outcome Dilution:** **Marginal** (or **Weak** if using NAICS 62). IMLC affects a small share of “healthcare employment” overall; mitigate by narrowing outcomes to physician offices / physician employment proxies.
- **Recommendation:** **PURSUE (conditional on: (i) primary outcomes narrowed to physician-aligned measures—e.g., NAICS 621111/physician establishments and/or NPPES physician counts; (ii) robustness to dropping extreme never-treated states and to pretrend/event-study diagnostics; (iii) sensitivity to excluding/post-2020 period or flexibly controlling for COVID-era telehealth shocks).**

---

**#2: Telehealth Parity Laws and the Geography of Healthcare Work (Idea 2)**
- **Score: 58/100**
- **Strengths:** Highly policy-relevant (telehealth reimbursement rules are active levers for states/insurers). There is credible staggered timing in the *pre-2020* wave that avoids the worst COVID confounding.
- **Concerns:** The proposed “worked from home” ACS outcome is a poor match for parity laws (many healthcare workers cannot WFH; parity targets reimbursement, not workplace modality), creating major dilution/misalignment risk. Parity adoption may respond to telehealth market development (endogenous policy adoption), and the second wave (2020–21) is heavily confounded by COVID.
- **Novelty Assessment:** **Moderate.** Telehealth parity has a sizeable utilization literature; provider-side labor-market impacts are less studied, but the general policy is not new to the literature.
- **DiD Assessment (MANDATORY 8 criteria):**
  - **Pre-treatment periods:** **Strong** *for early adopters* (often 5+ years of pre if you start the panel well before adoption)
  - **Selection into treatment:** **Marginal** (states may adopt because telehealth supply/demand is already rising; not clearly external)
  - **Comparison group:** **Marginal** (non-parity states may differ systematically in insurance regulation and healthcare markets)
  - **Treatment clusters:** **Marginal** (~16 pre-2020 treated states is borderline for inference; workable but not great)
  - **Concurrent policies:** **Marginal** (telehealth coverage mandates, Medicaid telehealth rules, and broader insurance reforms may move alongside parity)
  - **Outcome-Policy Alignment:** **Weak as proposed** (ACS WFH among “healthcare workers” is not tightly linked to reimbursement parity; CMS telehealth utilization is better aligned; labor outcomes should focus on telehealth-eligible provider groups)
  - **Data-Outcome Timing:** **Marginal** (ACS WFH refers to “last week” at interview date spread across the year; parity effective dates are often mid-year → partial exposure and attenuation unless you harmonize to full-exposure years)
  - **Outcome Dilution:** **Weak** (telehealth-eligible clinical providers are a minority of “healthcare workers”; pre-2020 WFH levels are tiny, making signal-to-noise low)
- **Recommendation:** **CONSIDER (only if redesigned)** — specifically: use **telehealth claims (CMS, APCDs where available) and provider-group-specific employment outcomes** (e.g., psychologists, psychiatrists, primary care physicians) and restrict to **pre-2020 adopters** with harmonized “first full year of exposure.”

---

**#3: Stacked Healthcare Compacts and Provider Supply Elasticity (Idea 4)**
- **Score: 47/100**
- **Strengths:** Very novel conceptual contribution—treating compacts as modular “interstate remote-work institutions” and leveraging within-state cross-industry exposure is intellectually attractive.
- **Concerns:** Identification is likely to become opaque: multiple overlapping treatments, different implementation definitions, and serious risk that “control industries” are indirectly affected (violating stable unit treatment). High probability of coincident policy changes (especially around 2020) and specification search.
- **Novelty Assessment:** **High.** I am not aware of a clean causal paper estimating combined effects of multiple licensing compacts across professions using a unified framework.
- **DiD Assessment (MANDATORY 8 criteria):**
  - **Pre-treatment periods:** **Strong** (for IMLC/PT/NLC components you can have long pre-periods; PSYPACT complicates post-2020)
  - **Selection into treatment:** **Marginal** (adoption is political and may correlate across compacts within a “deregulatory” state type)
  - **Comparison group:** **Marginal** (states adopting multiple compacts are likely structurally different from those adopting few)
  - **Treatment clusters:** **Strong** in raw counts, **but** effective clusters per compact/industry cell can be much smaller (**risk of thin cells**)
  - **Concurrent policies:** **Weak** (high likelihood of overlapping healthcare reforms, telehealth changes, and COVID shocks—especially because PSYPACT starts 2020)
  - **Outcome-Policy Alignment:** **Marginal** (QCEW sub-industries help, but cross-compact spillovers mean outcomes may not cleanly map to a single treatment)
  - **Data-Outcome Timing:** **Marginal** (different compacts have different operational dates; plus lag from legal adoption → actual multi-state practice)
  - **Outcome Dilution:** **Marginal/Weak** (even within sub-industries, only a subset of workers are license-holders; establishment-level changes may be subtle)
- **Recommendation:** **SKIP (unless narrowed)** — it becomes promising only if you (i) **drop PSYPACT/post-2020**, (ii) focus on **one or two compacts** with clean timing, and (iii) pre-register a small set of hypotheses/specs.

---

**#4: State Broadband Infrastructure Mandates and Rural Remote Work Adoption (Idea 5)**
- **Score: 44/100**
- **Strengths:** Policy-relevant and potentially important for place-based policy; broadband is a core constraint for rural labor markets. Data are feasible (ACS WFH; county splits).
- **Concerns:** As proposed, this is classic endogenous policy DiD: states expand broadband policy *because* they are rural/underserved and often on different trajectories. Timing is also problematic—policy enactment is far upstream of actual broadband availability (long, heterogeneous implementation lags), weakening treatment definition.
- **Novelty Assessment:** **Moderate-to-low.** There is a large literature on broadband and labor-market outcomes; “WFH adoption” is newer, but broadband-to-work outcomes is not a blank slate.
- **DiD Assessment (MANDATORY 8 criteria):**
  - **Pre-treatment periods:** **Marginal** (depends on exact coding; many programs are recent and intensify post-2021)
  - **Selection into treatment:** **Weak** (broadband policy adoption is strongly related to baseline broadband gaps and economic conditions—directly related to outcomes)
  - **Comparison group:** **Marginal** (never/late adopters are systematically different; rural composition differs)
  - **Treatment clusters:** **Strong** (~30+ states)
  - **Concurrent policies:** **Weak** (IIJA/BEAD, ARPA, and other pandemic-era shocks coincide with adoption/scale-up)
  - **Outcome-Policy Alignment:** **Marginal** (policy is an input; outcome is remote work—requires actual deployment/quality changes, not just office creation)
  - **Data-Outcome Timing:** **Weak** (multi-year lags from legislation/office creation to buildout; ACS WFH responds to realized service)
  - **Outcome Dilution:** **Marginal** (state-level WFH averages dilute rural effects; county-level rural focus helps, but then treatment is state policy vs county outcomes)
- **Recommendation:** **SKIP (unless re-identified)** — would need a more credible design (e.g., quasi-random grant scoring cutoffs, shock to funding formulas, or using FCC availability changes as treatment rather than policy dates).

---

**#5: The Psychology Interjurisdictional Compact (PSYPACT) and Mental Health Access (Idea 3)**
- **Score: 32/100**
- **Strengths:** Extremely policy-relevant given the mental health access crisis; PSYPACT is a major institutional change with broad adoption.
- **Concerns:** Timing is fundamentally confounded: PSYPACT starts July 2020, exactly when COVID massively shifts mental health demand, telehealth, and labor supply. Even with many pre-2020 quarters available, the first-treatment period coincides with a structural break, making parallel trends and stable counterfactuals very hard to defend.
- **Novelty Assessment:** **High.** I do not know of strong causal work on PSYPACT’s labor-market effects specifically—this is an open space.
- **DiD Assessment (MANDATORY 8 criteria):**
  - **Pre-treatment periods:** **Strong in length** (you can have many pre-2020 quarters), **but practically Weak** because the relevant “policy era” begins exactly at the COVID break
  - **Selection into treatment:** **Marginal/Weak** (adoption during/after COVID could respond to acute access problems)
  - **Comparison group:** **Weak** (few credible “untreated” states post-2020; non-adopters may be systematically different)
  - **Treatment clusters:** **Strong** (many adopters), but **effective control group is thin**
  - **Concurrent policies:** **Weak** (COVID emergency telehealth waivers, payment changes, licensure enforcement changes, demand shocks)
  - **Outcome-Policy Alignment:** **Marginal** (QCEW mental health employment is not telepsychology practice; shortage designations move slowly and are administratively determined)
  - **Data-Outcome Timing:** **Marginal** (policy mid-2020; quarterly outcomes help, but COVID-era timing dominates)
  - **Outcome Dilution:** **Marginal/Weak** (telepsychology-eligible providers are a subset; broad NAICS categories include many roles)
- **Recommendation:** **SKIP** (unless you can find a design that isolates PSYPACT from COVID-era shocks—e.g., leveraging within-state licensing board processing rules, discrete operational “go-live” discontinuities, or microdata on cross-state telepsychology encounters with pre-2020 baselines, which is unlikely).

---

### Summary

Only **Idea 1 (IMLC)** looks like a strong “institute-quality” project as written, because it combines a long pre-period, many treatment cohorts, and feasible administrative outcomes—*but it must fix outcome alignment/dilution by focusing on physician-specific measures*. Ideas 2–5 all have at least one major DiD identification failure (especially **outcome mismatch/dilution**, **timing**, or **endogenous adoption/confounding**), with PSYPACT (Idea 3) the weakest due to unavoidable COVID confounding. If you start one project now, start with **Idea 1** and redesign **Idea 2** only if you can move to telehealth-claims/provider-specific outcomes and a pre-2020 identification window.