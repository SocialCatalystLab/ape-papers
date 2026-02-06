# Internal Review - Round 2

**Role:** Reviewer 2 (harsh, skeptical) - Second Pass
**Paper:** Do State College Promise Programs Increase Enrollment? Evidence from Staggered Adoption
**Timestamp:** 2026-02-06

---

## PART 1: CRITICAL REVIEW (Second Pass)

This review builds on Round 1, focusing on additional concerns and verifying previous issues.

### 1. FORMAT CHECK

**Length:** Main text ~17 pages (pages 1-17). **Still below 25-page requirement.** This is a hard constraint that must be addressed.

**All other format elements pass:** Good references, full prose, adequate section depth, clear figures and tables.

### 2. STATISTICAL METHODOLOGY

**Verification of Round 1 Assessment:**

✓ Standard errors present for all coefficients
✓ 95% CIs reported
✓ Sample sizes documented (N=676 main, N=637 cohort analysis)
✓ Callaway-Sant'Anna estimator correctly implemented
✓ Multiple inference alternatives (wild bootstrap, randomization inference)

**Statistical methodology passes.** The econometric approach is sound.

### 3. IDENTIFICATION STRATEGY - DEEPER CONCERNS

**Issue A: Parallel Trends Test is Weak**

The formal F-test (F=0.87, p=0.51, page 25) has limited power with only 5 pre-treatment periods. Failing to reject the null of no pre-trends is not the same as accepting parallel trends. The event study coefficients at t=-5 and t=-4 are visually imprecise (wide CIs in Figure 1).

**Issue B: Selection into Treatment**

States that adopted Promise may have done so in response to enrollment pressures:
- Declining enrollment → political pressure → Promise adoption
- This would violate parallel trends even if pre-treatment coefficients are zero

The paper acknowledges this (Section 5.3) but does not:
- Test whether pre-adoption enrollment trends predict Promise adoption
- Use propensity score methods to balance treatment and control groups
- Employ synthetic control as a robustness check

**Issue C: SUTVA Violations**

Promise programs may have spillover effects:
- Students crossing state lines to attend Promise-eligible institutions
- Competitive dynamics (non-Promise states losing students to Promise states)

These general equilibrium effects could bias estimates toward zero if enrollment shifts between states rather than increasing in aggregate.

### 4. LITERATURE - ADDITIONAL GAPS

Beyond Round 1 citations, the paper should engage with:

**On Promise program effects:**
```bibtex
@article{Bell2022,
  author = {Bell, Elizabeth and Bettinger, Eric},
  title = {The Effects of the Tennessee Promise on College Attendance and Completion},
  journal = {Journal of Policy Analysis and Management},
  year = {2022},
  volume = {41},
  pages = {1054--1080}
}
```
This is directly relevant - examines Tennessee Promise with individual-level data.

**On state-level higher education policy evaluation:**
```bibtex
@article{Bound2019,
  author = {Bound, John and Braga, Breno and Khanna, Gaurav and Turner, Sarah},
  title = {Public Universities: The Supply Side of Building a Skilled Workforce},
  journal = {RSF: Russell Sage Foundation Journal of the Social Sciences},
  year = {2019},
  volume = {5},
  number = {5},
  pages = {43--66}
}
```

### 5. WRITING QUALITY

**Strengths confirmed:** Clear prose, logical flow, accessible to non-specialists.

**Areas for improvement:**

1. **Introduction hook (page 2):** Opens with policy description rather than a surprising fact or puzzle. Consider leading with: "Despite $2 billion in annual spending on Promise programs, their aggregate effects remain unknown."

2. **Results presentation (page 11):** The null finding is stated plainly but could be made more impactful. Frame it as: "This paper provides the first rigorous evidence that Promise programs may not increase total college enrollment—a finding that challenges prevailing policy assumptions."

3. **Conclusion (page 16-17):** Could be tightened. Three interpretations are offered but the paper doesn't take a stance on which is most likely given the evidence.

### 6. QUANTITATIVE ISSUES

**Issue D: MDE Calculation Details**

The MDE formula and assumptions are not fully specified (page 14-15):
- What standard deviation is used (within-state, between-state, total)?
- What R² adjustment is applied?
- How does clustering affect the calculation?

Without these details, the 29% MDE claim cannot be verified.

**Issue E: Cohort-Specific Results Interpretation**

Table 3 (page 14) shows the 2021 cohort (Michigan) has a significant *negative* effect (-5.6%, p<0.05). This is interpreted as "limited post-treatment data" but:
- Michigan Reconnect targets adults (25+), not traditional students
- This is a fundamentally different program type
- The significant negative effect deserves more discussion—is it real or an artifact?

**Issue F: COVID Sensitivity**

Section C.3 claims excluding 2020-2021 produces "nearly identical results" but doesn't report the specific coefficient. The reader cannot verify this claim.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

### High-Priority Improvements

1. **Expand main text to 25+ pages** by:
   - Adding balance tests comparing Promise vs. non-Promise states
   - Expanding heterogeneity analysis by program design features
   - Including discussion of Michigan Reconnect as a separate case study
   - Moving some appendix robustness results to main text

2. **Report additional statistics for transparency:**
   - Exact COVID-excluded specification results
   - MDE calculation details
   - Treatment timing verification (cite legislative sources)

3. **Address selection concern:**
   - Test whether pre-adoption enrollment trends predict Promise timing
   - Consider instrumental variables (e.g., political composition as instrument)

### Medium-Priority Enhancements

4. **Synthetic control complement:**
   - Apply synthetic control to Tennessee (8 years post-treatment)
   - Show whether individual-state analysis corroborates pooled null

5. **Decomposition analysis:**
   - If IPEDS data available, show community college vs. 4-year enrollment separately
   - Test crowd-out hypothesis directly

6. **Cost-effectiveness frame:**
   - Calculate cost per marginal student (even if effect is small)
   - Compare to other enrollment interventions

---

## OVERALL ASSESSMENT

### Strengths
1. Methodologically sound—correct use of Callaway-Sant'Anna
2. Honest about limitations—MDE discussion is exemplary
3. Well-written prose with clear narrative
4. Comprehensive robustness checks

### Critical Weaknesses
1. **Length below minimum** (17 vs. 25 pages required)
2. **Power limitations severe** (MDE=29% vs. expected effects of 5-15%)
3. **Outcome measure misaligned** with treatment (total vs. first-time enrollment)
4. **Selection into treatment** not adequately addressed

### Path Forward

The paper has a solid foundation but needs expansion and refinement. The key question is whether the null finding is *informative* or *uninformative*:
- If uninformative due to power, the contribution is limited
- If informative (actual null effect on aggregate enrollment), this challenges policy assumptions

The authors should:
1. Expand to meet length requirements
2. Strengthen identification (selection tests, synthetic control)
3. Either obtain better data or reframe the contribution

---

**DECISION: MAJOR REVISION**
