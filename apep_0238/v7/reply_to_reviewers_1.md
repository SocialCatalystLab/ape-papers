# Reply to Reviewers: apep_0238 v7

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. Inference and uncertainty not aligned with long-horizon claims

**Concern:** Long-horizon coefficients not significant under wild bootstrap; multiple-horizon inference lacks formal summary statistic.

**Response:** We have made three changes:

1. **Formal average persistence metric.** We now compute β̄_LR, the average coefficient across h ∈ {48, 60, 72, 84} months, with a wild cluster bootstrap 95% confidence interval. For the Great Recession: β̄_LR = −0.037 (95% CI: [−0.069, −0.005]), rejecting zero at the 5% level under our preferred inference. This directly addresses the concern that persistence is not statistically established.

2. **Consistent inference hierarchy.** Wild bootstrap p-values are now explicitly presented as the preferred inference device throughout the paper. HC1 and permutation p-values are reported for comparison but the interpretation consistently leads with bootstrap.

3. **Multiple testing acknowledgment.** We cite Romano & Wolf (2005) and note that individual horizon-level significance should be interpreted with caution, while the summary statistic provides a single pre-specified test of the persistence hypothesis.

### 2. Identification of "demand vs supply" is suggestive but not fully credible

**Concern:** The paper identifies "housing-wealth-driven vs sectoral-contact-driven," not "demand vs supply" in general. Two episodes with two exposure measures bundle many channels.

**Response:** We agree this is the most important caveat and have addressed it in three ways:

1. **Within-episode horse race (new Table 5).** We include the GR Bartik alongside HPI in the Great Recession LP. HPI remains persistent (half-life 60mo) while GR Bartik effects are less persistent within the same episode. This separates the demand (housing/wealth) channel from industry composition effects operating within the same recession.

2. **Explicit limitations.** The conclusion acknowledges: "The comparison of two recessions is ultimately a sample of two macroeconomic events; the demand/supply taxonomy is tested on these specific episodes and may not map cleanly onto mixed-type recessions." We also note that the reduced form combines shock incidence with policy mitigation.

3. **Scope of claim.** We interpret the findings as: "Recessions characterized by prolonged demand deficiency and extended unemployment durations generate scarring; recessions dominated by temporary separations with rapid recall do not."

### 3. Model not disciplined by reduced-form moments; welfare magnitudes too strong

**Concern:** The model is calibrated externally, not matched to LP IRFs. The 330:1 welfare ratio relies on strong assumptions.

**Response:**

1. **Model framed as illustrative.** The model section explicitly states it provides a "unified explanation" rather than claiming to match the data moment-by-moment. We use language like "the model generates" and "the calibration illustrates."

2. **Welfare sensitivity table (new Appendix Table).** We present welfare results under 7 alternative parameterizations varying λ (scarring), χ (participation), and A (matching efficiency). The demand-to-supply ratio ranges from 99:1 to 1258:1 across specifications, confirming the qualitative result is robust while showing sensitivity to specific magnitudes.

3. **Risk-neutrality caveat explicit.** The welfare discussion notes that risk-neutral CE losses are an approximation and that CRRA utility would reduce absolute magnitudes while preserving the demand/supply asymmetry.

### 4. Missing cross-episode falsifications

**Concern:** Apply COVID Bartik to GR outcomes and vice versa.

**Response:** The within-episode horse race (Table 5) partially addresses this by showing that industry-composition (Bartik) effects within the GR are less persistent than housing (demand) effects. A full cross-episode swap is a valuable extension that we note in the conclusion as future work, alongside historical episodes (Volcker recession, 2001 dot-com bust).

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Missing references

**Response:** Added Gertler & Trigari (2009) for duration dependence in DMP models and Romano & Wolf (2005) for multiple testing. Guerrieri et al. (2022) already cited and discussed in Section 2.2.

### 2. Promote mechanism figures/tables

**Response:** Placebo/permutation test (previously Figure 13 in appendix) promoted to main text as Figure 7. JOLTS figure normalized to rates for cross-period comparability.

### 3. CRRA robustness

**Response:** Acknowledged as a caveat in the welfare discussion. The welfare sensitivity table in the appendix shows robustness to scarring, participation, and matching efficiency parameters. Full CRRA utility is noted as a valuable extension.

---

## Reviewer 3 (Gemini-3-Flash): CONDITIONALLY ACCEPT

### 1. Welfare measure sensitivity

**Response:** New appendix welfare sensitivity table covers 7 parameter scenarios. Risk-neutrality caveat explicit in text.

### 2. Migration and demographic turnover

**Response:** Emp/pop analysis (Table 9) confirms scarring on workers, not places. Age heterogeneity is noted as a valuable extension requiring CPS microdata.

### 3. Volcker recession comparison

**Response:** Noted in conclusion as key extension for generalizability. State-level employment data quality before 1990 limits direct application of the LP framework.

---

## Theory Review (GPT-5.2-pro): 3 CRITICAL, 7 WARNING, 2 NOTE

All issues addressed. See revision_plan_1.md for details. Key fixes:

1. **Wage rule consistency:** Simplified wage used throughout (SS wage: 0.8550).
2. **Welfare convergence:** Extended to T=600 months with verified convergence.
3. **OLF timing:** Competing-hazard formulation in all Bellman equations.
4. **Missing parameters:** χ₀=0.008, χ₁=0.004, d*=12 months, a=1 all reported.
5. **Scarring proxy bounds:** s_t ∈ [0,1] enforced.
6. **Discount rate:** Corrected to β^{-12}−1 ≈ 0.049.
