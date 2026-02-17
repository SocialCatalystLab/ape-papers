# Reply to Reviewers

## Reviewer 1 (GPT-5.2)

**Concern 1: Treatment variable is endogenous to the claims data.**
We agree this is an important concern. We have added an extended discussion in Section 5.3 (Threats to Validity) addressing four specific reasons why endogenous treatment detection is unlikely to bias our results: (1) sustained jump requirements filter transient coding changes; (2) the 15% threshold exceeds compositional noise; (3) placebo tests on E/M codes show no effect; and (4) the institutional narrative (ARPA funding, CMS spending plans) provides external validation. We acknowledge that a comprehensive fee schedule crosswalk would further strengthen the design and note this as a direction for future work.

**Concern 2: NPI counts conflate supply with consolidation.**
This is a valid limitation that we discuss in Section 8 (Discussion). The heterogeneity analysis (Panel C of Table 4) provides indirect evidence: individual providers decline significantly while organizational providers show similar but noisier declines. This pattern is consistent with consolidation rather than workforce contraction. We note in the limitations section that linking T-MSIS to payroll data could distinguish these margins.

**Concern 3: Confidence intervals not in tables.**
We have added explicit 95% confidence intervals in the results narrative for all TWFE specifications.

**Concern 4: RI vs. TWFE p-value discrepancy.**
Section 7.4 now provides a detailed explanation of why the Fisher exact p-value (0.024) differs from the asymptotic TWFE p-value (0.261): the tests answer different questions. The TWFE test evaluates whether beta=0 under clustered asymptotic theory; the RI test evaluates whether the observed coefficient could arise under random treatment assignment.

**Concern 5: Literature too thin.**
We have added citations for Montgomery et al. (2019) on home care wages and entry, and Kleiner (2000) on occupational licensing.

## Reviewer 2 (Grok-4.1-Fast)

**Concern 1: Confidence intervals not tabulated.**
Added 95% CIs in the results text for all TWFE estimates.

**Concern 2: Literature gaps.**
Added Montgomery et al. (2019) and Kleiner (2000). We appreciate the specific citation suggestions.

**Concern 3: First-stage not quantified.**
Table 5 (Appendix) reports pre/post rates by treated cohort. The event study explicitly uses t-1 as the reference period.

**Concern 4: Prose improvements.**
Incorporated structural improvements to the Discussion section.

## Reviewer 3 (Gemini-3-Flash)

**Concern 1: Dose-response endogeneity.**
We agree that the largest rate increases likely reflect responsive policy to ongoing crises. We have excluded Wyoming (1,422% outlier) from the dose-response analysis and note that the remaining coefficient (-0.042, p=0.784) is economically small and statistically insignificant.

**Concern 2: Consolidation mechanism underexplored.**
Section 7.2 and Section 8 discuss the consolidation mechanism in detail. The significant decline in individual providers (16.3%) combined with an insignificant decline in organizational providers is consistent with formalization.

**Concern 3: Rate detection threshold arbitrary.**
Section 7.3 shows results are robust across 10%, 20%, and 25% thresholds, with consistent negative-to-null estimates regardless of the cutoff.
