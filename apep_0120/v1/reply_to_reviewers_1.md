# Reply to Reviewers — Paper 111

## Response to Reviewer 1

### Concern 1: Estimand is too aggregated/diluted (all 18-34)
**Response:** We agree this is an important limitation. We have added a formal MDE/power discussion (Section 8.1) showing our MDE is 1.25 pp at 80% power, representing 4.1% of the base rate. We explicitly acknowledge that effects on directly exposed subgroups cannot be ruled out and recommend PUMS microdata for future work. Moving to individual-level microdata would require a fundamental redesign beyond the scope of this revision.

### Concern 2: Missing unemployment controls
**Response:** We have obtained state unemployment rates from BLS LAUS and added an unemployment balance test. The TWFE regression of unemployment on treatment yields a coefficient of 0.042 (SE = 0.126, p = 0.744), confirming that treatment does not predict differential unemployment changes. The CS-DiD specification with unemployment and log rent controls was already included and yields similar results.

### Concern 3: Treatment definition is coarse
**Response:** We acknowledge the binary threshold limitation in the revised discussion. The paper already includes TWFE continuous MW gap analysis. Continuous treatment with heterogeneity-robust methods is technically challenging (CS-DiD requires binary treatment), and we note this as a direction for future work.

### Concern 4: Local MW policies
**Response:** We added a robustness check excluding states with prominent local MW policies (CA, WA, NY, CO, OR). The ATT is -0.569 (SE = 0.483), very similar to the baseline -0.540. We added a new discussion subsection on local minimum wages (Section 8.2).

### Concern 5: HonestDiD nonconvergence
**Response:** We attempted HonestDiD with the relative magnitudes approach, which now produces results (reported in Section 7.7). The smoothness-based approach did not converge due to the covariance structure.

### Concern 6: Missing references
**Response:** Added all suggested references: Roth et al. (2023), Cameron-Gelbach-Miller (2008), Borusyak-Jaravel-Spiess (2024), Haurin-Hendershott-Kim (1993), Neumark-Wascher (2002), and others.

---

## Response to Reviewer 2

### Concern 1: Outcome dilution / need for microdata
**Response:** See Reviewer 1, Concern 1 above. We have added MDE analysis and power discussion.

### Concern 2: Unemployment controls
**Response:** See Reviewer 1, Concern 2 above. Balance test confirms p = 0.744.

### Concern 3: Population weighting
**Response:** Added population-weighted CS-DiD (weighted by 18-34 population). The weighted ATT is -0.251 (SE = 0.381), somewhat attenuated but consistent with the unweighted null.

### Concern 4: Event-time support counts
**Response:** We added a joint pre-trend Wald test: chi2(4) = 7.76, p = 0.101, failing to reject the null at 10%. This is reported in the new robustness subsection.

### Concern 5: Pre-trend sensitivity
**Response:** HonestDiD relative magnitudes approach now provides results (see Section 7.7). We acknowledge the smoothness approach did not converge.

### Concern 6: Overclaiming null
**Response:** We have reframed all conclusions throughout the paper. "Do not meaningfully shift" is now "do not produce detectable shifts in aggregate" with explicit caveats about power limitations and subgroup effects.

### Concern 7: Authorship disclosure
**Response:** This is an APEP (Autonomous Policy Evaluation Project) paper; AI-generated disclosure is required by the project framework. No change needed.

---

## Response to Reviewer 3

### Concern 1: Short panel / limited cohorts
**Response:** We acknowledge this limitation explicitly. We added leave-one-cohort-out analysis showing the ATT ranges from -0.603 to -0.438 across 10 exercises, with no single cohort driving the result.

### Concern 2: Policy endogeneity / confounding
**Response:** We have added the unemployment balance test (p = 0.744) and note that the CS-DiD with controls yields similar results. We cite Allegretto et al. (2017) on credible designs.

### Concern 3: Treatment mismeasurement / local MWs
**Response:** See Reviewer 1, Concern 4. Robustness to excluding local-MW states added.

### Concern 4: Reframe contribution
**Response:** We have reframed the paper's contribution around what the null teaches us, with explicit MDE analysis and power discussion. The conclusion now states: "effects on directly exposed subpopulations cannot be ruled out."

### Concern 5: Missing references
**Response:** Added all suggested references: Borusyak et al. (2024), Roth et al. (2023), Wooldridge (2021), Mykyta-Macartney (2011), Allegretto et al. (2017), Clemens-Wither (2019), and others.

---

## Summary of Changes

1. **New analyses (07_revision_robustness.R):**
   - Population-weighted CS-DiD (ATT = -0.251, SE = 0.381)
   - Leave-one-cohort-out stability (ATT range: [-0.603, -0.438])
   - Exclusion of local-MW states (ATT = -0.569, SE = 0.483)
   - Unemployment balance test (coef = 0.042, p = 0.744)
   - Joint pre-trend Wald test (chi2(4) = 7.76, p = 0.101)
   - MDE calculation (1.25 pp at 80% power, 4.06% of base rate)

2. **New paper sections:**
   - Section 7.8: Additional Robustness Checks (population weights, LOCO, local MW exclusion, Wald test, unemployment balance)
   - Section 8.1: Statistical Power and Minimum Detectable Effects
   - Section 8.2: Local Minimum Wages

3. **Bibliography:** 11 new references added

4. **Reframed conclusions:** All assertive null language changed to hedged aggregate-level language throughout abstract, introduction, discussion, and conclusion

5. **Updated limitations:** Removed "unavailability of unemployment rates" limitation (now addressed); added discussion of power and subgroup limitations
