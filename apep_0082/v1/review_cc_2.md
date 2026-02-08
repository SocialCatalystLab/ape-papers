# Internal Review - Round 2

**Reviewer:** CC-Reviewer-2 (Internal)
**Paper:** "Recreational Marijuana Legalization and Business Formation"
**Paper ID:** APEP-0110
**Date:** 2026-01-29
**Decision:** MINOR REVISION
**Previous Decision:** MAJOR REVISION

---

## Summary of Revisions

I have read the revised version of the paper alongside the authors' response to my first-round report. The paper has improved substantially. The three major issues I identified have all been addressed, some quite effectively. I now recommend minor revision.

---

## Assessment of Responses to Major Issues

### Issue 1: BF8Q Treatment -- RESOLVED

The revised paper now handles the BF8Q outcome with appropriate care. Specifically:

- The BF8Q analysis is clearly labeled as "descriptive only" both in the table notes and in the text discussion. The revised Table 5 includes an explicit footnote stating that the BF8Q coefficient is not causally identified due to limited post-treatment coverage.
- The authors have added discussion of which treatment cohorts contribute post-treatment BF8Q observations, making transparent that only early adopters (roughly 2014-2018 cohorts) have any post-treatment data in this series.
- The paper now includes a brief but useful discussion of the application-BF8Q divergence, suggesting that while business applications may decline, those that do proceed may be more likely to become established businesses. This compositional interpretation is plausible and appropriately caveated.

This issue is satisfactorily resolved.

### Issue 2: Power Concerns and TWFE-CS Gap -- SUBSTANTIALLY IMPROVED

The authors have made meaningful improvements:

- The paper now includes a minimum detectable effect discussion, noting that the design can reliably detect effects of approximately 8-10 log points. This is transparent about the design's limitations for detecting smaller effects.
- Randomization inference and the pairs cluster bootstrap are now presented with greater prominence in the results discussion, appropriately framed as the preferred inferential tools given the cluster count.
- The TWFE-CS gap receives expanded discussion, with the authors noting that negative weighting in TWFE with heterogeneous treatment timing can inflate the magnitude of the TWFE estimate. The Callaway-Sant'Anna decomposition by cohort provides useful evidence on which groups drive the difference.

One remaining concern: the paper could still benefit from a sentence or two explicitly stating the direction of potential bias from the moderate cluster count. With 21 clusters, are cluster-robust standard errors likely to be over- or under-rejected? The econometric literature (Cameron, Gelbach, and Miller, 2008) suggests over-rejection, meaning the RI and bootstrap p-values are the more conservative and reliable benchmarks. A brief note to this effect would strengthen the discussion.

### Issue 3: Event Study and Pre-Trends -- IMPROVED

The revised event study discussion is stronger:

- Pre-treatment coefficients are now accompanied by a joint test for pre-trends, which fails to reject the null of no pre-treatment effects. Good.
- The paper discusses the possibility that growing post-treatment negative effects could reflect either genuine dynamics or emerging confounders, and notes that the pattern is robust to excluding Colorado and Washington (the earliest adopters).

Remaining minor concern: the event study figure would benefit from explicitly marking the treatment period with a vertical line or shading if this is not already present. Additionally, confidence intervals at longer horizons are wide, which the paper should note explicitly as a consequence of limited post-treatment observations for later cohorts.

---

## Remaining Minor Issues

### 1. Literature (Partially Addressed)

The revised paper incorporates some of the suggested references but could still benefit from a brief mention of the regulatory burden literature (Djankov et al., 2002; Branstetter et al., 2014). The mechanism by which legalization affects non-cannabis business formation likely runs partly through regulatory environment changes, and situating the paper in this literature would strengthen the contribution framing.

### 2. Dependent Variable Means

Tables still do not appear to report the mean of the dependent variable. This is a minor but useful addition that helps readers assess economic significance. A coefficient of -0.068 log points is more interpretable when the reader knows the baseline level.

### 3. COVID Robustness Detail

The paper mentions that results are robust to excluding 2020-2021. It would be helpful to note whether the COVID exclusion also drops 2022 or only the acute pandemic years, and whether the event study pattern (growing negative effects) is preserved under this restriction.

### 4. Conclusion Length

The conclusion is somewhat brief relative to the paper's length. Given the policy relevance of the topic and the nuance of the results (borderline significance, divergent BF8Q pattern, growing event study effects), a slightly expanded conclusion discussing policy implications and directions for future research would be appropriate.

---

## Strengths Reinforced

The revised paper retains all the strengths I noted in my first report and has added:

- Greater methodological transparency, particularly around power and inference.
- More careful handling of the BF8Q outcome, which was the most important revision.
- Improved event study discussion with formal pre-trend testing.

The paper continues to demonstrate scientific integrity in its treatment of borderline results. The authors resist the temptation to oversell statistical significance and instead present an honest picture of what the data can and cannot tell us. This is the right approach.

---

## Decision: MINOR REVISION

The paper has substantially improved since the first round. The major methodological and presentation issues have been addressed. The remaining issues are minor and should be straightforward to resolve. I recommend acceptance conditional on minor revisions:

1. Add a brief note on the direction of finite-cluster bias and why RI/bootstrap are preferred.
2. Include dependent variable means in regression tables.
3. Expand the COVID robustness discussion slightly.
4. Consider a modestly longer conclusion.

I do not need to see the paper again after these revisions are made.
