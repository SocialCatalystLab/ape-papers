# Reply to Reviewers

**Paper:** Do Energy Efficiency Resource Standards Reduce Electricity Consumption? Evidence from Staggered State Adoption
**Date:** 2026-01-30

---

## Reviewer 1 (Major Revision)

### Identification Credibility
**Concern:** Never-treated states systematically differ; need weather controls, region-by-year FE, policy controls.

**Response:** We acknowledge this is the central limitation. Our Discussion section (Section 9.2) explicitly notes that omitted weather controls (HDD/CDD), concurrent policies (RPS, building codes, ARRA), and regional economic trends are the primary threats to identification. We present this estimate as "suggestive but imprecise" throughout. Adding HDD/CDD controls, region-by-year FE, and policy bundle controls are priority items for a future revision.

### Binary Treatment Definition
**Concern:** EERS vary in stringency; binary treatment causes attenuation.

**Response:** We agree. Moving to continuous treatment (annual savings targets, DSM spending per capita) would sharpen the analysis substantially. This is noted as a key extension in Section 9.3.

### Inference
**Concern:** Need wild cluster bootstrap or randomization inference.

**Response:** We report standard clustered SEs as implemented in the `did` R package. Adding wild cluster bootstrap (Cameron-Gelbach-Miller) and randomization inference would strengthen the paper. This is a priority for revision.

### Placebos
**Concern:** Industrial electricity not a clean placebo given EERS may cover C&I.

**Response:** We acknowledge this limitation and have revised the text to note that industrial electricity is an imperfect placebo. Transportation energy use would be a cleaner falsification test.

### Literature
**Concern:** Need more DSM evaluation literature and political economy citations.

**Response:** We have positioned our contribution carefully but agree the literature engagement could be deeper. We will expand the literature review in revision.

---

## Reviewer 2 (Reject and Resubmit)

### Core Identification
**Concern:** Time-varying confounds (climate, economic structure, policy bundles) are first-order; state+year FE insufficient.

**Response:** We agree these are serious threats. Our paper frames the estimate as capturing an "EERS policy bundle" effect rather than a pure EERS mandate effect. Section 9.2 discusses these limitations explicitly. We plan to add weather controls and concurrent policy indicators in revision.

### Policy Bundling
**Concern:** 2008 adoption cohort coincides with RPS expansions, ARRA, recession, building codes.

**Response:** This is a key concern. The 2008 cohort is the largest (8 jurisdictions), and the timing coincidence with ARRA and the recession is problematic. We discuss this in the limitations section. A future revision would construct a policy panel controlling for RPS, decoupling, and ARRA funding.

### Treatment Intensity
**Concern:** Binary EERS → continuous treatment using targets, spending, verified savings.

**Response:** We agree this would substantially improve the analysis. EIA Form 861 DSM spending data and ACEEE scorecard information could provide intensity measures.

### Alternative Estimators
**Concern:** Consider augmented SCM, stacked DiD, interactive FE.

**Response:** We use CS-DiD as the primary estimator with Sun-Abraham and TWFE as benchmarks. Adding stacked DiD and augmented SCM would strengthen the robustness analysis.

### Inference
**Concern:** Wild cluster bootstrap and randomization inference needed.

**Response:** We will add these in a future revision. The paper currently reports the main estimate as statistically insignificant at conventional levels, which is the honest interpretation.

---

## Reviewer 3 (Reject and Resubmit)

### Never-Treated Counterfactual
**Concern:** Never-treated states concentrated in Southeast/Mountain West; not credible without stronger controls.

**Response:** We acknowledge this fundamental limitation. The geographic sorting of treatment and control is the primary challenge. Region-specific comparisons and matching on pre-trends would improve credibility. We discuss this in Section 9.2.

### Policy Bundling
**Concern:** Cannot separate EERS from correlated policy regimes.

**Response:** We frame our estimand as the "EERS policy bundle" effect and discuss this limitation explicitly. We acknowledge that without controlling for concurrent policies, the interpretation is ambiguous.

### Triple-Difference Design
**Concern:** Use state × sector design with residential vs. commercial/industrial.

**Response:** This is an excellent suggestion. A DDD design using residential consumption relative to commercial/industrial within the same state-year would absorb state-year shocks (including weather) and provide a much more credible identification strategy.

### Inference
**Concern:** Wild cluster bootstrap and uniform confidence bands needed.

**Response:** We will add these methods in revision. Current inference uses the `did` package defaults.

### Magnitude Interpretation
**Concern:** "Coal plants avoided" calculation premature given imprecision.

**Response:** We have added appropriate caveats to the policy implications section, noting the estimate is imprecise and the welfare implications are illustrative rather than definitive.

---

## Summary of Changes Made

### In Current Version (Pre-Publication)
1. Reframed entire paper to honestly report statistical insignificance
2. Fixed conceptual framework sign inconsistency
3. Added Bacon decomposition results
4. Corrected cohort descriptions and treatment timing definitions
5. Improved table precision and figure quality
6. Removed unsupported claims (fake treatment timing, commercial placebo)
7. Fixed balanced panel language contradictions

### Planned for Future Revision
1. Weather controls (HDD/CDD from NOAA)
2. Concurrent policy controls (RPS, building codes, ARRA, decoupling)
3. Continuous treatment intensity (DSM spending, savings targets)
4. Wild cluster bootstrap inference
5. Rambachan-Roth honest DiD sensitivity
6. Triple-difference design (residential vs. C&I within state)
7. Expanded literature review
8. Publication-quality figures
