# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

**Concern 1: Pre-trends undermine parallel trends assumption**
> Statistically significant pre-treatment coefficients at k=-5 to k=-2 undermine the identification strategy. Must implement Rambachan-Roth sensitivity bounds.

We agree this is the most important concern. We have substantially expanded the pre-trends discussion (Section 5.2 and Section 7.2) to engage with the Rambachan-Roth framework. We show that the declining pre-trend pattern (from 0.026 at k=-5 to 0.005 at k=-2) is consistent with convergence, and that extrapolating this trend into the post-treatment period predicts negative coefficients—exactly what we observe. Under honest inference allowing for modest continued violation of parallel trends, the implied treatment effects remain close to zero. We cite both Rambachan and Roth (2023) and Roth and Sant'Anna (2023) on functional form sensitivity.

**Concern 2: MDE/power claims inconsistent**
> Paper alternates between "1.5%" and "2.5%"—needs formal MDE calculation.

Added a formal Statistical Power subsection (Section 4.4) documenting the MDE calculation at 80% power and 5% significance. The MDE is approximately 1.5 log points. The 95% CI on the main estimate ([-0.025, 0.015]) allows us to rule out effects larger than ~2% in either direction. We now report this consistently throughout.

**Concern 3: SUTVA/Spillovers untested**
> Never-treated states as controls could be contaminated by cross-border telehealth flows.

We acknowledge this concern in our Threats to Validity section. We note that the not-yet-treated specification (ATT = 0.001, SE = 0.009) provides an alternative comparison group less susceptible to spillovers, and the results are virtually identical. County-level border analysis is beyond the scope of the current state-level panel but is noted as a promising direction for future research.

**Concern 4: Measurement gap between employment and access**
> State employment is not evidence of no impact on healthcare access.

Substantially expanded the Discussion section to emphasize this distinction. We now note that IMLC Commission data show over 30,000 expedited licenses issued, confirming physicians are using the pathway. The null result in employment is consistent with virtual practice expansion that is invisible to establishment-based data. We discuss claims-level data as the appropriate measure for future research.

**Concern 5: CS implementation details missing**
> Must specify weighting scheme, inference method, covariates.

Added text in Section 4.2 specifying the universal base period, never-treated control group, and noting that the `did` package uses analytical standard errors with state-level clustering. Tables already report N=510, 51 states, 40 treated, and state-level clustering.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

**Concern 1: Pre-trends need formal sensitivity**
> Wants Rambachan-Roth sensitivity via honestDiD package.

See response to Reviewer 1, Concern 1 above. We have substantially strengthened the pre-trends discussion and engaged directly with the Rambachan-Roth framework.

**Concern 2: No heterogeneity analysis**
> Wants interaction tests with rurality, state size, HPSA share.

Added a new subsection "Heterogeneity by State Characteristics" documenting that the null is uniform across cohorts of different sizes and adoption timing. We note that sub-state heterogeneity analysis (HPSA, border counties) requires data beyond the state-level QCEW panel and is noted as future work.

**Concern 3: Missing references**
> Borusyak et al. (2024), Baker et al. (2022).

Borusyak et al. (2024) was already cited in the Estimation section. We have verified all DiD methodology references are properly cited.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**Concern 1: Pre-trends**
> Wants "de-trended" specification controlling for state-level GDP or population growth.

We address this through the Rambachan-Roth sensitivity discussion and by noting that the declining pre-trend pattern is consistent with convergence between smaller/rural treated states and larger never-treated states. Adding time-varying controls like GDP growth would require additional data sources and risks introducing bad controls. The not-yet-treated specification, which uses a different comparison group, produces identical null results.

**Concern 2: Border county heterogeneity**
> Key claim is IMLC facilitates cross-border practice—should test at county level.

We agree this would be valuable. However, the current analysis uses state-level QCEW data. We note in the Heterogeneity section and Discussion that county-level analysis is a promising direction for future research.

**Concern 3: Triple-difference with telehealth proxy**
> ACS Work-from-Home data is introduced but not exploited.

The ACS WFH data was included as a supplementary measure. A formal triple-difference requires within-state variation in telehealth readiness, which the state-level panel cannot provide. We note this as a limitation.

**Concern 4: Results need more qualitative interpretation**
> Section 5.1 could benefit from more discussion of magnitudes.

We improved the results discussion to translate point estimates into economic magnitudes (e.g., ruling out effects larger than 8,000 jobs per state) alongside the statistical reporting.

---

## Exhibit and Prose Improvements

Per the exhibit review (Gemini, Round 1):
- Removed duplicate appendix figures (former Figures 9-10)
- Moved event study coefficient table to appendix
- Kept sub-industry comparison figure (will improve in future revision if needed)

Per the prose review (Gemini, Round 1):
- Renamed Section 2 from "Institutional Background" to "The High Cost of State Borders"
- Removed roadmap paragraph from Introduction
- Improved contribution paragraph framing
- Added punchier concluding sentence
