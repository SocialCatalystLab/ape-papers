# Reply to Reviewers - Round 1

Thank you for the thorough and constructive review. We address each major concern below.

## 1. Internal Inconsistency (Table 2)

**Concern:** The interaction model implies smaller effect for high-automation workers, but stratified models show larger effects.

**Response:** We appreciate this careful reading. The inconsistency arises because the interaction model constrains age slopes to be equal across groups. When age-LFP slopes differ between high- and low-education groups (as they do in our data), the restricted interaction model produces biased estimates of subgroup-specific effects.

**Fix:** We now present stratified results as the main evidence and remove the misleading interaction specification. The stratified estimates represent subgroup-specific RDD effects without imposing cross-group constraints. Using rdrobust with CCT robust inference:
- High automation (HS or less): -3.6 pp [95% CI: -7.2, -1.6]
- Low automation (College+): -2.2 pp [95% CI: -4.6, 0.2]
- Difference: -1.4 pp

## 2. RDD Implementation

**Concern:** Discrete running variable, polynomial specification, ad hoc bandwidth.

**Response:** We now:
- Use rdrobust with CCT robust bias-corrected inference as the main specification
- Report MSE-optimal bandwidth selection (3.2-3.4 years)
- Acknowledge the discrete running variable limitation explicitly
- Present covariate balance tests showing no discontinuities at age 65 for any observable

**Covariate balance results:** All seven tested covariates (female, white, black, Hispanic, married, high automation, college grad) show insignificant jumps at age 65 (all p > 0.1).

## 3. Education as Automation Proxy

**Concern:** Education correlates with factors beyond automation exposure.

**Response:** We acknowledge this limitation more explicitly. We reframe the heterogeneity analysis as "education-based heterogeneity" with automation exposure as one interpretation among several (health, wealth, pension coverage, job amenities). We discuss why occupation-based measures are challenging due to selection into employment.

## 4. Paper Length and Literature

**Concern:** Paper is too short; literature engagement insufficient.

**Response:** We have expanded:
- Institutional background with Medicare enrollment details
- Literature review with suggested citations
- Mechanism discussion
- Robustness checks

## Remaining Limitations

We acknowledge:
1. Discrete running variable limits precision of RDD inference
2. Education proxy captures multiple factors
3. Cannot distinguish demand-side from supply-side channels

These are noted in the revised Discussion section.
