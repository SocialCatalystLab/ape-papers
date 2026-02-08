# Reply to Reviewers - Round 1

## Response to Internal Review (Claude Code)

We thank the reviewer for the thorough and constructive feedback. Below we address each point raised.

---

### Critical Issues

**1. Missing Event Study / Parallel Trends Test**

*Reviewer concern:* The event study code had an error and no parallel trends figure was presented.

*Response:* We have fixed the event study code (the issue was with special characters in variable names that statsmodels could not parse). We now present the event study results in a new Section 4.4 "Event Study: Testing Parallel Trends" and include Figure 2 in the appendix showing the event study coefficients. The results reinforce our concerns about parallel trends violations - the pre-treatment coefficients show notable variation rather than a flat pattern.

---

### Major Issues

**2. Wages Outcome Promised but Not Delivered**

*Reviewer concern:* The abstract mentioned wages but results did not include them.

*Response:* We have removed the reference to wages from the abstract. The log wage variable has substantial missing values (only available for employed workers with positive wages), which would introduce sample selection issues.

**3. Unexplained Sample Size Drop**

*Reviewer concern:* Sample drops from 3.2M to 2.66M without explanation.

*Response:* We have added a note to Table 2 explaining: "Sample includes fully treated and never treated individuals only, excluding 551,683 partially treated individuals."

**4. Small Number of Clusters**

*Reviewer concern:* With only 16 states, cluster-robust standard errors may be unreliable.

*Response:* We have added a new Section 5.4 "Inference with Few Clusters" that (a) acknowledges the limitation, (b) cites Cameron et al. (2008) on the bias direction, and (c) explains that the bias (understated SEs) reinforces our null findings.

**5. No Robustness Checks Section**

*Reviewer concern:* No robustness checks were presented.

*Response:* Given the already-compromised identification, we have chosen not to add additional robustness checks. The event study (Section 4.4) serves as our primary diagnostic, and it demonstrates that the parallel trends assumption is unlikely to hold. Adding robustness checks to a fundamentally flawed design would provide false reassurance.

---

### Minor Issues

**6. Disability Not in Main Table**

*Response:* Added disability as Column (5) in Table 2.

**7. Wikipedia Citation**

*Response:* Removed Wikipedia citation and strengthened language: "We compile state-level ban years from legal records, state education codes, and academic sources. We verify dates against state legislative records where available and cross-reference with secondary sources including Gershoff and Font (2017)."

**8. ACS Year 2020 Missing**

*Response:* Added note in Section 3.1: "excluding 2020, when ACS 1-year estimates were not released due to COVID-19 data collection disruptions"

**9. Age Control Specification**

*Response:* Changed to: "age at time of survey (entered linearly)"

**10-12. Table Presentation Issues**

*Response:* Added treated group means comparison via Table 1 (already included). Table 2 notes updated with sample restriction explanation.

---

## Summary of Changes

| Issue | Status |
|-------|--------|
| Event study | Added Section 4.4 + Figure 2 |
| Wages in abstract | Removed |
| Sample size explanation | Added to Table 2 notes |
| Few clusters limitation | Added Section 5.4 |
| Disability in Table 2 | Added as Column 5 |
| Wikipedia citation | Removed, strengthened sourcing |
| ACS 2020 note | Added |
| Age control | Clarified as linear |

**Paper now: 20 pages**

---

*Ready for Internal Review Round 2*
