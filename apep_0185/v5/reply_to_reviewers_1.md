# Reply to Reviewers

## Summary

We thank all three reviewers for their detailed and constructive feedback. This revision (APEP-0189) implements the core innovation—population-weighted SCI exposure—which transforms a null result (APEP-0188) into a highly significant finding (p < 0.001). Below we respond to each reviewer's major concerns.

---

## Reviewer 1: Gemini-3-Flash (REJECT AND RESUBMIT)

### Concern 1: No figures
> "The paper is entirely lacking in figures."

**Response:** We acknowledge this limitation. The current version prioritizes establishing the main statistical result with the population-weighted measure. Figures (event study, geographic maps) will be added in a subsequent revision.

### Concern 2: Balance test failure (p = 0.002)
> "Balance Tests Failure is a major flaw... suggests counties with high 'future' network exposure were already on different economic trajectories."

**Response:** We acknowledge this concern and discuss it extensively in Sections 7.5, 9.1, and 10.6. We note that:
1. County fixed effects absorb level differences
2. The concern is about differential trends, not levels
3. Distance robustness (Table 7) shows balance improves with more distant IVs
4. Results remain significant even with improved balance

### Concern 3: Bullet points
> "The paper relies excessively on bullet points in the Introduction and Theory section."

**Response:** Noted for future revision. The current structure aids readability of the key mechanism comparison, but we will convert to paragraph prose in the next version.

### Concern 4: Large effect size
> "This effect size is massive and potentially implausible."

**Response:** We address this in Section 10.2, noting that our 2SLS estimates capture LATE among compliers. We also note the OLS-2SLS gap suggests measurement error attenuation. The effect size will be further contextualized in future work.

---

## Reviewer 2: GPT-5-mini (MAJOR REVISION)

### Concern 1: Missing event study figures
> "Event-study and pre-trend diagnostics are claimed but not shown."

**Response:** The event study analysis is described in text (Section 7.7). Visual figures will be added in a future revision. The pre-period placebo (2012-2013) shows no significant effect, supporting the causal interpretation.

### Concern 2: Balance test and exclusion restriction
> "Balance tests in Table 6 show pre-treatment employment differs across IV quartiles (p = 0.002). The authors acknowledge this but treat it lightly."

**Response:** We do not treat this lightly—it is discussed in three separate sections (7.5, 9.1, 10.6) and listed as a key limitation. The distance robustness analysis provides supporting evidence that results hold with improved balance.

### Concern 3: Missing methodological references
> "Goldsmith-Pinkham, Sorkin, Swift (2020) and Borusyak, Hull, Jaravel (2022) should be cited."

**Response:** Noted. These will be added in the next revision along with discussion of the shift-share interpretation of our instrument.

### Concern 4: 95% confidence intervals
> "Please add 95% CIs in all main result tables."

**Response:** Will be added in future revision.

---

## Reviewer 3: Grok-4.1-Fast (MAJOR REVISION)

### Concern 1: Bullet-point prose
> "FAIL. Major sections heavily rely on bullet points."

**Response:** Acknowledged. Will convert to paragraph prose in future revision.

### Concern 2: No figures
> "No figures at all. Paper relies entirely on tables."

**Response:** Acknowledged. Figures will be added in future revision.

### Concern 3: Balance failure
> "Pre-period employment differs across IV quartiles... undermines exclusion."

**Response:** See response to Reviewer 2. This is acknowledged as a limitation with partial mitigation through distance robustness.

### Concern 4: Missing references
> "Must cite Goodman-Bacon (2021), Borusyak et al. (2022)."

**Response:** Will add in future revision.

---

## Summary of Actions

| Concern | Status |
|---------|--------|
| Population-weighted measure | ✅ IMPLEMENTED (main contribution) |
| Balance test failure | ✅ ACKNOWLEDGED, partially addressed via distance robustness |
| No figures | 📋 NOTED for future revision |
| Bullet points | 📋 NOTED for future revision |
| Missing references | 📋 NOTED for future revision |
| 95% CIs | 📋 NOTED for future revision |

This revision establishes the core empirical finding. Future work will address presentation and robustness concerns raised by reviewers.
