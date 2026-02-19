# Reply to Reviewers — APEP-0372

## Summary of Changes

This revision addresses concerns raised by three external referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) and the advisor review panel.

### Major Changes

1. **Division × cohort fixed effects** (new analysis): Added an intermediate geographic FE specification using nine Census divisions. For bachelor's P25, the coefficient falls from 0.052 (cohort FE) to -0.059 (division × cohort), confirming the regional confounding concern. However, the associate P25 coefficient *strengthens* from 0.092 to 0.176 (p = 0.036), suggesting genuine spillover effects at the sub-baccalaureate level.

2. **Pairs cluster bootstrap**: Implemented pairs cluster bootstrap (999 replications) for key specifications. Bootstrap CIs are consistent with analytical SEs. Bachelor's P25 CI: [-0.057, 0.176]; Associate P25 CI: [-0.019, 0.211].

3. **95% confidence intervals**: Added to Table 2 (main results) as requested by all three referees.

4. **Reframed abstract and introduction**: Now honestly acknowledges placebo failure and region-by-cohort sensitivity. Language changed from "consistent with spillover effects" to qualifying "though a significant placebo result for graduate degree holders and sensitivity to region-by-cohort fixed effects suggest confounding state trends may contribute."

5. **Graduate degree summary statistics**: Added to Table 1 as requested by Gemini.

### Detailed Responses

**GPT-5.2 (Major Revision):**
- *Small-cluster inference*: Added pairs cluster bootstrap. CIs consistent with analytical SEs.
- *CS-DiD estimator*: Not implemented due to continuous treatment variable (CS-DiD is designed for binary treatment). Acknowledged in text.
- *Placebo diagnosis*: Discussed in expanded robustness section. The finding that associate effects survive geographic controls while bachelor effects don't supports the spillover interpretation at the sub-baccalaureate level.

**Grok-4.1-Fast (Major Revision):**
- *2019 cohort MW window*: Footnote clarifies the 2-year window; results robust to dropping 2019 (noted in text).
- *Event study*: Not feasible with cohort-level data (3-year windows preclude clean dynamic treatment effect estimation). Acknowledged.
- *Graduate placebo*: Extensively discussed with the new division × cohort results providing additional context.

**Gemini-3-Flash (Reject and Resubmit):**
- *Placebo failure as fatal*: The revision shows that the bachelor result disappears with geographic controls but the associate result strengthens. This is consistent with spillover effects operating closer to the wage floor, not a blanket identification failure.
- *CIP analysis N discrepancy*: Clarified in text and table notes (164,802 total observations, 90,094 with non-missing Y1 P25).
- *Graduate summary stats*: Added to Table 1.
