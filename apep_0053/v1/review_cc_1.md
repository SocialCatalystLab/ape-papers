# Internal Review Round 1

**Reviewer:** Claude Code (Self-Review)
**Date:** 2026-01-22
**Recommendation:** MAJOR REVISION

---

## Summary

This paper evaluates the causal effect of Automatic Voter Registration (AVR) laws on voter registration and turnout using staggered difference-in-differences methods with CPS Voting Supplement data (2010-2022). The study finds null effects: AVR increases registration by a statistically insignificant 0.2 percentage points (p=0.78) and has no effect on turnout (-0.1pp, p=0.94). Event studies reveal violations of parallel trends, with treated states exhibiting declining pre-treatment registration rates. The paper provides honest reporting of null results and discusses identification challenges, measurement issues, and potential explanations for the discrepancy with single-state studies.

**Strengths:**
1. Rigorous application of modern DiD methods (TWFE, Sun-Abraham, Callaway-Sant'Anna)
2. Transparent reporting of null results and identification failures
3. Comprehensive robustness checks (6 specifications)
4. Honest discussion of pre-trends violations and selection bias
5. Good motivation and clear research question

**Weaknesses:**
1. **Pre-trends violations undermine identification** - The significant negative coefficient at t=-2 (p=0.013) indicates selection into treatment based on declining registration trends. This fundamentally undermines the parallel trends assumption.
2. **Limited policy contribution given null results** - While null results are scientifically valid, the paper needs stronger discussion of \*why\* results differ from Oregon case study.
3. **Measurement challenges insufficiently addressed** - CPS self-reported data has known biases; paper should validate with administrative records or discuss limitations more thoroughly.
4. **Missing figures** - The paper references 6 figures but they are not included (compilation error). Event study plots are critical for visualizing pre-trends.
5. **Heterogeneity analysis lacks depth** - Null effects across ALL subgroups is puzzling and needs more investigation.

---

## Detailed Comments

### Major Issues

**1. Identification**

The pre-trend violation (t=-2: β=-0.019, p=0.013) is the paper's Achilles heel. States that adopted AVR were on declining registration trajectories \*before\* treatment. This suggests:
- Selection on unobservables: states adopted AVR \*because\* registration was falling
- Standard DiD cannot separate AVR's effect from continuation of pre-existing decline
- Estimates are biased upward (true effect likely more negative than +0.2pp)

**Required revisions:**
- Add sensitivity analysis: How negative would the true effect need to be to explain the pre-trend?
- Discuss Rambachan-Roth (2023) HonestDiD bounds explicitly
- Consider synthetic control methods for early adopters (Oregon, California)
- Acknowledge that causal interpretation is compromised

**2. Oregon discrepancy**

Oregon's +7pp effect vs this paper's +0.2pp requires deeper explanation. Current discussion (Section 5.2) lists possibilities but doesn't adjudicate between them.

**Suggested addition:**
- Decompose Oregon's effect: Was it AVR itself, or concurrent 2016 election mobilization?
- Compare Oregon's pre-trends to other early adopters (California, Vermont)
- If Oregon is an outlier in pre-trends, that explains the discrepancy

**3. Measurement**

CPS self-reported registration overstates true registration by ~5-10pp. The paper mentions this (p.16) but doesn't quantify its impact.

**Suggested addition:**
- Bound analysis: If measurement error attenuates by 50%, true effect could be +0.4pp (still null but larger)
- Validate using state-level administrative data (voter file counts) if available
- Report intracluster correlation to assess power

**4. Concurrent reforms**

Many AVR states also adopted same-day registration, early voting expansion, or mail ballots. The paper acknowledges this but doesn't systematically code concurrent reforms.

**Required:**
- Create a table listing all concurrent reforms by state-year
- Estimate heterogeneous effects: AVR-only states vs bundled states
- If bundled states show larger effects, AVR's independent contribution is smaller

### Minor Issues

**5. Heterogeneity**

Null effects across ALL subgroups (young, low-income, minorities) is surprising. Either:
- AVR truly has no effect on anyone, or
- Small sample sizes preclude detection

**Suggested:**
- Report power calculations for subgroup analyses
- Acknowledge that null heterogeneity doesn't rule out individual-level effects

**6. Missing figures**

Figures 1-6 are referenced but not included in PDF. Without event study plots, readers cannot visualize pre-trends. This is critical for publication.

**Required:**
- Generate all 6 figures
- Include in main text (event studies, maps, time series)

**7. Writing clarity**

Some sections are overly technical for a policy journal. Simplify:
- Abstract: Lead with substantive finding ("no evidence of effects") before methods
- Introduction: Tighten to 3 pages (currently 4)
- Discussion: Add policy implications subsection

---

## Recommendation: MAJOR REVISION

This paper makes an important contribution by replicating AVR studies with multi-state data and finding null results. However, the pre-trends violation undermines causal identification, and the paper needs deeper analysis of why results differ from Oregon.

**Required for next round:**
1. Sensitivity analysis for pre-trends violation (HonestDiD, bounds)
2. Concurrent reforms table and heterogeneity analysis
3. All figures included in PDF
4. Deeper discussion of Oregon discrepancy
5. Power calculations for heterogeneity

If these revisions are made, the paper could be publishable at a field journal (e.g., Election Law Journal, State Politics \& Policy Quarterly) as a replication/extension piece. Top general-interest journals (AER, JPE) would require either:
- Credible identification (which current design lacks), or
- Novel contribution beyond null replication (e.g., mechanism for why AVR fails)

---

## Decision: REVISE AND RESUBMIT
