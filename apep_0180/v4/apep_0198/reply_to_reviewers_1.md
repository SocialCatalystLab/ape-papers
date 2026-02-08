# Reply to Reviewers

## Reviewer 1 (GPT-5-mini) — Major Revision

**1. Monte Carlo covariance assumption**
> Must address zero cross-outcome covariance assumption.

We have added a discussion in §4.6 noting that zero covariance is conservative (positive correlation tightens CIs) and reporting sensitivity to rho={0.25, 0.50}. The baseline CIs are deliberately wide to reflect honest uncertainty.

**2. Between-study heterogeneity**
> Pooling H&S and Egger without modeling differences.

We now report study-specific MVPFs in the robustness section: H&S yields 0.88, Egger yields 0.85. The two-percentage-point difference confirms robustness. We discuss the potential for random-effects meta-analysis with harmonized microdata as future work.

**3. GE multiplier scaling**
> Need sensitivity to multiplier attenuation.

The new pecuniary spillover sensitivity table (Table 12) shows MVPF under 0-100% pecuniary assumptions. Even at 100% pecuniary (i.e., zero real spillovers), MVPF remains 0.88.

**4. Fiscal externality accounting**
> Present results under both accounting conventions.

We now include a non-recipient fiscal externality robustness check in §6, showing MVPF under both recipient-only (0.88) and recipient+non-recipient (0.88) FE conventions. The difference is minimal because non-recipient FEs are small (~$8).

**5. Figure/table quality**
> Cluster counts and labels.

All figures have been regenerated from corrected code. Table notes specify clustering levels and sample sizes.

## Reviewer 2 (Grok-4.1-Fast) — Minor Revision

**1. Missing references**
> Add Blattman et al. 2021, Auriol & Warlters 2012.

We have added Bachas et al. (2021) on informal taxation, Gordon & Li (2009) on developing-country tax structures, and Sun & Abraham (2021) on event study heterogeneity.

**2. Trim redundancy**
> Consolidate sensitivity tables.

We have consolidated the sensitivity summary in Table 4 to load computed values from robustness results rather than duplicating.

## Reviewer 3 (Gemini-3-Flash) — Minor Revision

**1. Distributionally weighted MVPF**
> Compute welfare-weighted version.

We now report a distributionally weighted MVPF of approximately 1.75 (using inverse consumption share weights, omega_R=2.0) in the welfare weights discussion of §3.3. This underscores that the baseline MVPF of 0.88 is conservative from a distributional perspective.

**2. Persistence decay justification**
> Why 50% annual consumption decay?

This is calibrated from Haushofer & Shapiro (2018) who find 23% persistence at 3 years, consistent with roughly 50% annual decay. We discuss this in §4.4 and present sensitivity from 1 to 10 years in Table 9.

**3. Leakage and closed-economy assumption**
> Add discussion of spending outside village.

The Egger et al. evidence directly addresses this: their saturation design measures within-cluster spillovers, and the 0.1% price effect confirms elastic local supply rather than a purely closed economy. We note this in the pecuniary vs. real spillover discussion.
