# Research Idea Ranking

**Generated:** 2026-01-17T02:03:08.020425
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5126

---

### Rankings

**#1: Texas Nurse Mandatory Overtime Ban and Labor Supply**
- **Score:** 66/100  
- **Strengths:** Clear, occupation-targeted policy with a sharp implementation date and large sample sizes in ACS for nurses, making estimates reasonably powered. The question is policy-relevant (staffing, burnout, shortages) and the outcomes (hours, employment, wages) are directly observed.  
- **Concerns:** DiD credibility hinges on parallel trends around 2009 (Great Recession, healthcare demand changes, and other state-level nurse policies could confound). The policy may shift *mandatory* overtime to *voluntary* overtime, which ACS can’t distinguish.  
- **Novelty Assessment:** Moderately novel—there is broader literature on nurse staffing/overtime regulations and patient outcomes, but fewer clean, Texas-specific microdata causal estimates of labor supply responses.  
- **Recommendation:** **PURSUE**

---

**#2: Iowa Universal Occupational License Recognition and Interstate Migration**
- **Score:** 58/100  
- **Strengths:** High policy relevance and timely: many states are adopting recognition, and migration/labor supply is exactly what legislators claim it will affect. A triple-difference design (licensed vs. unlicensed occupations, Iowa vs. controls, pre/post) could materially strengthen identification relative to a simple state DiD.  
- **Concerns:** The June 2020 timing is a major identification problem because COVID dramatically affected migration and sectoral labor markets; ACS 2020 is also problematic (experimental/nonresponse issues). “Licensed occupations” are an imperfect proxy for “licensed workers,” and licensing requirements vary by state and sub-occupation, creating measurement error that will attenuate effects.  
- **Novelty Assessment:** Somewhat studied—there are already papers on universal recognition (often healthcare-focused). A broad, cross-occupation microdata study is a useful incremental contribution but not a “blank slate.”  
- **Recommendation:** **CONSIDER** (worth doing only if you can execute a convincing design beyond simple DiD and handle 2020 data issues)

---

**#3: Maine Earned Paid Leave and Employment Effects**
- **Score:** 52/100  
- **Strengths:** Very strong novelty—“any reason” paid leave mandates are rare, and Maine’s policy is genuinely distinctive relative to sick-leave mandates. The policy question is relevant for current debates on leave design.  
- **Concerns:** The proposed identification (“near the 10-employee threshold”) is not feasible in ACS PUMS because firm size/coverage and actual leave access are not observed—so treatment assignment is fundamentally noisy. Implementation in 2021 is heavily confounded by COVID-era labor market turbulence and policy heterogeneity, making parallel trends especially doubtful.  
- **Novelty Assessment:** High novelty for this exact law/design; however, the broader paid leave/sick leave literature is extensive, which raises the bar for credible identification.  
- **Recommendation:** **SKIP** as currently framed (would need administrative data with employer size/coverage or a design that actually isolates affected workers)

---

**#4: Maine Cost-of-Living Indexed Minimum Wage Effects**
- **Score:** 47/100  
- **Strengths:** High policy relevance and feasible data construction; Maine vs. NH is a natural regional comparison, and the multi-step increases plus indexing allow an event-study style analysis.  
- **Concerns:** Novelty is low: minimum wage effects are one of the most studied topics in labor economics, and a Maine-vs-NH DiD using ACS is unlikely to shift beliefs unless the design is unusually strong. ACS wage measurement (annual earnings, imputed hourly wage, hours/weeks error) can be problematic exactly for low-wage workers, and regional differential trends (tourism, housing, cross-border labor markets) threaten DiD assumptions.  
- **Novelty Assessment:** Low-to-moderate—indexing is less studied than one-time hikes, but the marginal contribution is still likely small given the saturated literature.  
- **Recommendation:** **SKIP** (unless you have a genuinely novel identification angle—e.g., border discontinuities with finer geography than PUMS, or administrative payroll data)

---

### Summary
The strongest idea in this batch is the **Texas nurse overtime ban**: it is relatively clean to implement with ACS, has adequate power, and a defensible policy shock. **Iowa license recognition** is promising but only if you explicitly design around COVID/2020 data disruptions (e.g., dropping 2020, using triple-diff, careful control selection). The two Maine projects are either not identifiable with ACS as proposed (paid leave) or face very low novelty given the existing minimum wage literature.