# GPT 5.2 Review - Round 2/10

**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** high
**Timestamp:** 2026-01-20T16:01:54.165259
**Response ID:** resp_06510c5d74ad771f00696f982f39c8819398866b628bf8efa9
**Tokens:** 9461 in / 6526 out
**Response SHA256:** a64ccaca64918ab0

---

## Referee Report: “The Incorporation Premium: Descriptive Evidence on Business Structure and Self‑Employment Earnings” (Jan 20, 2026)

### Summary
The paper documents a large earnings gap between incorporated and unincorporated self‑employed workers in the 2022 ACS (raw gap ≈ $41k; adjusted ≈ $24k), using linear regression, propensity score weighting, and Cinelli–Hazlett sensitivity analysis. The paper is careful to label estimates as descriptive associations rather than causal effects, and the sensitivity analysis is a welcome transparency device.

For a top general‑interest journal (AER/QJE/JPE/ReStud/Ecta) or AEJ:EP, the current draft is not close to the bar. The main limitation is not “inference” (you report SEs/CIs), but *scientific contribution and identification*: the paper does not deliver a credible causal estimand, does not use outcomes tightly linked to business performance, and does not demonstrate novelty relative to existing work showing that incorporated “smart” self‑employment has higher earnings (e.g., Levine & Rubinstein 2017). The draft also fails basic top‑journal format expectations (length/section depth; writing reads like a technical memo).

Below I give a demanding but constructive roadmap.

---

# 1. FORMAT CHECK (fixable, but important)

### Length
- **Fails top‑journal norm.** The PDF page numbers suggest **~19 pages total** with references/appendix included; the **main text is ~14 pages** (pp. 1–14), with references beginning around p. 16 and appendix tables around pp. 18–19.
- The prompt standard (“≥25 pages excluding references/appendix”) is **not met**.

### References / coverage
- References include many standard causal inference and entrepreneurship citations (Hamilton 2000; Moskowitz & Vissing-Jorgensen 2002; Levine & Rubinstein 2017; Rosenbaum & Rubin; Cinelli & Hazlett; Oster).
- **But coverage is incomplete** in (i) organizational form/taxes literature, (ii) measurement/ACS and survey weights, and (iii) empirical papers specifically about S‑corps/pass‑throughs and income shifting. Details and BibTeX are in Section 4 below.

### Prose vs bullets
- Major sections are mostly paragraphs, but there are **prominent bullet lists** (e.g., sample construction on p. 6–7; mechanisms on p. 3–4). Bullets are fine in Data/Methods, but you need substantially more **narrative exposition** in Intro/Results/Discussion.

### Section depth (3+ substantive paragraphs each)
- Several major sections are **too thin** for a top journal:
  - **Institutional Background (Section 2, pp. 3–4):** reads like 1–2 dense blocks plus subheadings; needs more substance and evidence.
  - **Related Literature (Section 3, p. 4–5):** largely a catalogue; not enough engagement.
  - **Conceptual Framework (Section 4, p. 5):** very short; identification discussion is mostly “CIA likely violated” without deeper structure.
  - **Discussion (Section 7, pp. 12–13):** has content, but still brief and somewhat repetitive.

### Figures
- Figure 1 has axes and visible distributions. However:
  - The version shown appears **low‑resolution** (looks like a raster screenshot). For a top journal, figures must be **vector** (PDF/eps) with publication-quality typography and legible labels.
  - You need additional figures showing **outcome distributions** (income is extremely skewed).

### Tables
- Tables contain real numbers and SEs/CIs—good.
- Table 2 reports CIs and SEs, but **no explicit p-values/stars**; you state significance in notes. That is acceptable, but top journals typically expect either **stars or p-values** consistently.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

On the narrow checklist, you mostly “pass,” but there are important inference/design problems for ACS and for the estimand.

### (a) Standard errors
- **PASS mechanically:** Table 2 and others show SEs in parentheses; Appendix Table 5 also reports robust SEs.

### (b) Significance testing
- **Borderline:** You assert “p < 0.001” (Table 2 notes) and provide t-stats in text (e.g., p. 9). But you should report **p-values or stars** systematically, not ad hoc.

### (c) Confidence intervals
- **PASS:** 95% CIs shown in Table 2; also in abstract.

### (d) Sample sizes
- **PASS:** N is reported (e.g., Table 2; Table 5).

### (e) DiD with staggered adoption
- Not applicable (no DiD).

### (f) RDD
- Not applicable (no RDD).

### Critical inference issue you *do* have: ACS complex survey design
- You treat the ACS like i.i.d. microdata with “robust SEs.” For ACS PUMS, correct uncertainty ideally uses **replicate weights** (or at minimum, survey design–robust methods). Ignoring the survey design can misstate precision—often underestimating SEs.
- At minimum, you need a section (Data/Inference) explaining:
  1) whether you used **ACS replicate weights** (e.g., PWGTP1–PWGTP80), and if not,  
  2) a justification and a sensitivity check comparing robust vs replicate-weight SEs.

### Propensity score / “doubly robust” claims are not executed to top-journal standard
- You describe doubly robust estimation (pp. 5–6), but in results you present OLS with controls and an IPW estimate, not a clearly defined **AIPW/DR estimator** with full formula, implementation details, and diagnostics.
- Missing essentials:
  - Covariate **balance checks** (standardized mean differences before/after weighting).
  - Clear definition of **estimand** (ATT vs ATE) for each method and table.
  - **Overlap** diagnostics beyond one histogram (common support trimming rules, effective sample size).
  - If you want to invoke modern DR credibility, use **cross-fitting** (Chernozhukov et al. 2018) or at least acknowledge why you do not.

---

# 3. IDENTIFICATION STRATEGY

### Credibility
- The paper does **not** have a credible identification strategy for causal inference; it is explicitly descriptive (Intro/Discussion, pp. 2, 12–14).
- For top journals, “descriptive correlations + sensitivity analysis” is rarely sufficient unless the descriptive fact is (i) entirely new and (ii) of first-order importance with compelling measurement and extensive robustness. Here, novelty is weak (see Section 4), and measurement of “business success” is not tight (PINCP is not business profit).

### Assumptions and limitations
- You correctly discuss the likely failure of CIA and provide sensitivity analysis (Section 6.4, p. 10–11; Section 7, p. 12–13). That’s good.
- However, the sensitivity analysis is **not a substitute** for research design. RV=0.11 is not especially large in an environment where omitted variables like firm size, sectoral profitability, and ability are plausibly very strong.

### Robustness and placebo tests
- Robustness is limited:
  - Industry FE reduces the estimate materially (Table 2 col. 4: ~$19k vs ~$24k). Yet your “preferred” is col. (3) (p. 9). For a descriptive paper, you should present the **maximally adjusted** model as primary, then step back to discuss mediators.
  - No state FE in main table (only mentioned as a robustness possibility on p. 7). This is a major omission because incorporation costs/tax climates vary by state and correlate with income.
  - No occupation FE (critical in self-employment).
  - No distributional analysis (median/quantiles/log income).
  - No examination of negative/zero income self-employment (you drop them), which likely induces selection and changes the estimand.

### Conclusions vs evidence
- You mostly avoid causal language, but you sometimes drift toward policy implications (Section 7.2, p. 13) that read as if incorporation might be a lever. Without design-based causal evidence, policy discussion needs to be **much more constrained** (or reframed as hypotheses).

---

# 4. LITERATURE (missing references + BibTeX)

### (i) Closest empirical work: incorporated vs unincorporated self-employment
You cite Levine & Rubinstein (2017), but you understate how directly it overlaps: they already emphasize incorporated self-employment (“smart”) earning premia. You need to explain clearly what is new relative to that paper (different dataset year? different method? sensitivity analysis?).

### (ii) Organizational form choice & taxation (key missing foundations)
You should cite classic work on taxes and organizational form:

```bibtex
@article{GordonMacKieMason1994,
  author  = {Gordon, Roger H. and MacKie-Mason, Jeffrey K.},
  title   = {Tax Distortions to the Choice of Organizational Form},
  journal = {Journal of Public Economics},
  year    = {1994},
  volume  = {55},
  number  = {2},
  pages   = {279--306}
}
```

A direct empirical link between tax incentives and incorporation / income shifting is crucial for your “mechanical tax” channel:

```bibtex
@article{Goolsbee2004,
  author  = {Goolsbee, Austan},
  title   = {The Impact of the Corporate Income Tax: Evidence from State Organizational Form Data},
  journal = {Journal of Public Economics},
  year    = {2004},
  volume  = {88},
  number  = {11-12},
  pages   = {2283--2299}
}
```

(If you use a different Goolsbee organizational-form paper, cite that precisely; the point is: you need *organizational form response to tax differentials* as a central pillar.)

### (iii) Pass-through taxation and income shifting (beyond Cooper et al. 2016)
Add evidence on pass-through owners and tax-motivated reporting behavior:

```bibtex
@article{Slemrod2007,
  author  = {Slemrod, Joel},
  title   = {Cheating Ourselves: The Economics of Tax Evasion},
  journal = {Journal of Economic Perspectives},
  year    = {2007},
  volume  = {21},
  number  = {1},
  pages   = {25--48}
}
```

And on behavioral responses and income shifting around tax reforms (choose the most relevant to your eventual design; a placeholder example you can tailor):

```bibtex
@article{SaezSlemrodGiertz2012,
  author  = {Saez, Emmanuel and Slemrod, Joel and Giertz, Seth H.},
  title   = {The Elasticity of Taxable Income with Respect to Marginal Tax Rates: A Critical Review},
  journal = {Journal of Economic Literature},
  year    = {2012},
  volume  = {50},
  number  = {1},
  pages   = {3--50}
}
```

### (iv) Survey weighting / inference with microdata (important for ACS)
You should cite the canonical “what are we weighting for?” paper:

```bibtex
@article{SolonHaiderWooldridge2015,
  author  = {Solon, Gary and Haider, Steven J. and Wooldridge, Jeffrey M.},
  title   = {What Are We Weighting For?},
  journal = {Journal of Human Resources},
  year    = {2015},
  volume  = {50},
  number  = {2},
  pages   = {301--316}
}
```

### (v) Sensitivity analysis practice (you cite Cinelli–Hazlett and Oster; consider adding)
If you want to sell sensitivity analysis as a methodological contribution, also cite the “sensemakr” implementation and/or related sensitivity frameworks used in applied micro:

```bibtex
@article{CinelliFerwerdaHazlett2020,
  author  = {Cinelli, Carlos and Ferwerda, Jeremy and Hazlett, Chad},
  title   = {sensemakr: Sensitivity Analysis Tools for OLS in R and Stata},
  journal = {Journal of Statistical Software},
  year    = {2020},
  volume  = {XX},
  number  = {XX},
  pages   = {XX--XX}
}
```

(Replace XX with the correct bibliographic fields; the key point is to cite the widely used applied tool/paper if you emphasize method.)

---

# 5. WRITING QUALITY (CRITICAL)

### Prose and structure
- The paper is readable but not yet “top-journal readable.” It currently reads like a competent policy memo/technical note rather than a paper with a compelling scholarly narrative.
- The Intro (Section 1, pp. 2–3) has a clear motivating question, but it quickly becomes a methods summary. Top journals expect a sharper pitch: *Why should a general-interest reader care? What conceptual puzzle does this resolve?*

### Narrative flow
- The arc “fact → adjustment → sensitivity → interpretation” is logical, but too compressed. The paper would benefit from:
  - A clearer conceptual distinction between **incorporation as legal form** vs **incorporation as a proxy for firm type/scale**.
  - A stronger explanation of why ACS can credibly speak to the question despite missing firm-level variables.

### Sentence-level issues and consistency
- There are internal inconsistencies in descriptive numbers:
  - Table 1 implies 99,474 vs 58,124, but the text says “exceeding $99,000” and also “approximately $102,000 versus $59,000” (Section 6.1, p. 8). Tighten all reported moments to match one source (weighted vs unweighted must be stated).
- Some claims overreach given design (policy implications section).

### Figures/tables presentation
- Figures need publication quality (vector, consistent fonts, clearer captions).
- Tables should clearly indicate:
  - whether moments are **weighted**,
  - what income concept is used (PINCP includes non-labor income),
  - whether SEs account for ACS replicate weights.

---

# 6. CONSTRUCTIVE SUGGESTIONS (how to make this publishable somewhere strong)

## A. Tighten the outcome and sample to measure “business earnings”
Right now the outcome is **total personal income (PINCP)**, which includes non-business income (interest/dividends/retirement/etc.). That is a major interpretability problem.
- Use outcomes closer to entrepreneurial returns:
  - self-employment income component(s) if available (e.g., net self-employment income),
  - labor earnings (wages + self-employment) excluding transfers/capital income,
  - or at least show decompositions: how much of the gap is wages vs self-employment vs other income.

Also reconsider sample restrictions:
- Dropping zero/negative income is consequential for self-employment; at minimum show results including them using **IHS(y)** or quantile methods.

## B. Make the descriptive contribution genuinely “new”
If you want a stylized fact paper:
- Show the premium across the **full distribution** (median, p25/p75/p90/p95) and by **industry × education × gender** with formal interaction tests.
- Show how results change with:
  - occupation FE,
  - state FE,
  - metro FE,
  - immigrant status,
  - business cycle proxies (if pooling years becomes possible).
- Provide a careful “measurement appendix” about ACS topcoding and reporting error.

## C. If you want top-journal potential: add a research design (recommended)
A top journal will want a quasi-experimental design, not only sensitivity analysis. Feasible directions:
1. **Panel / event study on incorporation transitions**  
   Use administrative data or a panel survey (SIPP, PSID, or linked administrative) to study income before/after incorporation within person, with controls and event-time plots (while acknowledging endogeneity of timing).
2. **Policy variation in incorporation costs**  
   Exploit state-level changes in LLC/corporation fees, publication requirements, annual franchise taxes, or changes in S-corp rules and implement DiD with modern estimators.
3. **Tax reforms encouraging pass-through behavior**  
   Reforms like TCJA/199A created large incentives for pass-through income characterization; a careful design could connect legal form and reported income.

## D. Fix the causal language and estimand clarity
Even as descriptive:
- Clearly label each estimate as **difference in conditional means** under a particular adjustment set, not “premium” unless you repeatedly remind the reader it is not causal.
- Decide whether hours is a confounder or mediator; right now you acknowledge ambiguity (Section 7.3, p. 13) but still call (3) “preferred.” For descriptive work, present both as co-primary and interpret them as different estimands.

## E. Bring inference up to ACS standards
- Implement replicate-weight SEs (or show they do not matter).
- Add balance diagnostics for propensity weighting and clearly present the DR/AIPW estimator if you claim “doubly robust.”

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Clear descriptive objective and transparent presentation of large raw and adjusted gaps (Tables 1–2, pp. 8–9).
- Correct instinct to include sensitivity analysis and to warn against causal interpretation (Sections 6.4 and 7, pp. 10–13).
- Baseline inference elements (SEs, CIs, N) are mostly present.

### Critical weaknesses (fatal for top journals as-is)
1. **No credible identification strategy** for causal interpretation; sensitivity analysis does not substitute for research design.
2. **Outcome misalignment:** PINCP is not a clean measure of business performance; results may reflect non-business income differences correlated with incorporation.
3. **Novelty gap:** Incorporated self-employment earning premia are already emphasized in the literature you cite (notably Levine & Rubinstein 2017); the paper does not yet convincingly articulate what is newly learned.
4. **ACS inference and design issues:** robust SEs without replicate weights; unclear weighted vs unweighted reporting.
5. **Manuscript maturity:** too short, thin literature engagement, and not written at the narrative depth expected at AER/QJE/JPE/ReStud/Ecta/AEJ:EP.

---

DECISION: REJECT AND RESUBMIT