# Research Idea Ranking

**Generated:** 2026-01-19T18:30:41.264035
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 3586
**OpenAI Response ID:** resp_0ffd1c5811c4b39000696e6a104edc81958a6c4201adc6d0dd

---

### Rankings

**#1: Does Income Support Help Workers Escape Automation Risk? EITC Eligibility and Occupational Mobility at Age 25**
- **Score: 67/100**
- **Strengths:** The age-25 EITC eligibility cutoff is a plausibly clean assignment variable, and the “automation-exposed workers” heterogeneity angle is genuinely more novel than estimating another average EITC effect. High policy relevance given recurring proposals to expand EITC for childless adults.
- **Concerns:** This is not a truly *sharp* RD in treatment receipt—eligibility changes discretely, but actual EITC receipt depends on filing and earnings, so the design is effectively **fuzzy** and likely weak given the small credit (~$600). The biggest practical risk is the **outcome**: CPS ASEC is largely cross-sectional, so “occupational switching/transition” is hard to measure cleanly without matched monthly CPS panels (and then you lose annual earnings/EITC proxies).
- **Novelty Assessment:** Moderate. The age-25 EITC RD has been studied (you cite Bastian & Jones and there is broader EITC RD/eligibility work), but **automation-exposure heterogeneity** at this discontinuity is not a well-trodden contribution.
- **Recommendation:** **CONSIDER** (upgrade to PURSUE if you can credibly measure switching using matched CPS panels or link to admin/tax data; otherwise the “mobility” core outcome may not be feasible).

---

**#2: WIOA Youth Program Eligibility and Labor Market Outcomes at Age 24**
- **Score: 52/100**
- **Strengths:** The age-based eligibility rule is an intuitive RD setup, and an interaction with automation exposure would be novel. If you had administrative enrollment/participation data, this could become a credible evaluation of an important workforce program.
- **Concerns:** With **CPS alone**, you do not observe WIOA take-up, so the design is reduced-form and likely extremely diluted (low awareness + low participation rates among all age-eligible individuals). The “eligibility at 24/25” cutoff is also operationally messy: many youth services start before 25 and can plausibly continue past 24, blurring the discontinuity; plus the simultaneous EITC eligibility change at 25 is a serious confound that will be hard to fully net out with CPS-reported “has children” (which is not the tax unit).
- **Novelty Assessment:** Fairly high *for this exact RD*, but WIOA/WIA youth programs have been evaluated in other ways (program evaluations, non-experimental and sometimes experimental components), so the incremental novelty hinges on executing a truly convincing RD with the right data.
- **Recommendation:** **CONSIDER** (but only if you can access WIOA administrative data such as PIRL with DOB/age and outcomes; with CPS as proposed, I would not prioritize it).

---

**#3: Automation Exposure Threshold and Occupational Dynamics**
- **Score: 28/100**
- **Strengths:** Feasible to implement quickly with available data and could be a descriptive companion piece (e.g., documenting gradients in switching/unemployment by automation exposure).
- **Concerns:** This is not credibly causal: occupation choice is endogenous, and “just above vs. below the median automation score” is an arbitrary threshold with no policy or institutional discontinuity—so it’s essentially a dressed-up correlation. Given the existing large literature correlating automation/AI exposure measures with labor outcomes, the marginal contribution is likely small.
- **Novelty Assessment:** Low. There are many papers relating automation/robot/AI exposure measures to wages, employment, and reallocation; the proposed “threshold” framing does not add much identification or conceptual novelty.
- **Recommendation:** **SKIP** (at most, treat as descriptive background for a better-identified design).

---

### Summary

This batch contains one reasonably credible quasi-experiment (Idea 1) plus one potentially high-value but currently underpowered/mismeasured program-evaluation concept (Idea 2), and one largely non-causal correlational design (Idea 3). I would start by salvaging Idea 1 through a data plan that can actually measure occupational transitions (matched CPS monthly panels or admin linkages); absent that, the project risks collapsing back into another (likely null) average EITC RD. Idea 2 becomes attractive only with WIOA administrative participation/outcome data—using CPS alone is unlikely to deliver interpretable effects.