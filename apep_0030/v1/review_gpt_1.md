# External Review — GPT 5.2

**Date:** 2026-01-18

# Referee report

Manuscript: "Decriminalize, Then Recriminalize: Evidence from Colorado’s Fentanyl Policy Reversal"  
Authors: Autonomous Policy Evaluation Project

## 1. Summary of the paper’s contribution
- The paper studies Colorado’s two-step policy experiment on possession penalties: an across-the-board felony→misdemeanor reduction in 2019 (HB 19-1263) and a partial recriminalization for fentanyl (possession >1g felony) in 2022 (HB 22-1326). (Background description pp. 3–6.)
- The empirical approach is a difference-in-differences (DiD) / event-study comparing Colorado to a set of neighboring states (NM, AZ, UT, WY, NE, KS, OK) for 2015–2024, using CDC provisional overdose death counts (synthetic opioids and other drug categories). (Data and methods, pp. 6–9.)
- Main empirical finding: no statistically significant effect of either decriminalization or recriminalization on total overdose deaths or fentanyl-specific deaths. Point estimates imply a modest positive effect of decriminalization (≈17–24%), but confidence intervals are wide and include zero. (Main results: Figures 1–3 pp. 9–14; Table 2 pp. 11–13.)
- The paper’s value: (i) evaluation of a rare within-state “reversal” policy experiment; (ii) highlighting that imprecise nulls can be informative; (iii) a cautionary note that massive, temporally-concentrated supply shocks (illicit fentanyl) complicate state-level causal inference. (pp. 2–4, 16–17.)

## 2. Major concerns (methodology, data, identification)
These concerns are substantive and, in my view, must be addressed before the paper is publishable in a top journal.

1. Identification threatened by a large, contemporaneous, heterogeneous supply shock and COVID-19
   - The fentanyl surge is a nationwide (but regionally staggered) supply shock that begins around the same time as the 2019 policy change. The authors themselves note this (pp. 2–3, 14–16), and conclude the supply shock likely dominates any policy signal. If the timing of fentanyl penetration differs across states, the DiD estimates will be biased. The current analysis does not convincingly separate policy effects from seasonal/regionally-staggered supply dynamics.
   - Recommendation: control for, or explicitly model, timing of fentanyl market entry by state (e.g., DEA seizure data, forensic lab reports, 911/Narcan administration trends, toxicology positive rates). Alternatively, exploit variation in timing at the substate (county) level where the policy was uniform but supply infiltration varied.

2. Limited pre-treatment information for fentanyl-specific outcomes
   - Synthetic-opioid (fentanyl) deaths are available only from 2018 for most states (noted in Table 1, p. 6 and p. 16). That leaves essentially one pre-treatment year for the primary outcome of interest, which makes parallel-trends tests for fentanyl nearly impossible and undermines causal claims about fentanyl-specific effects.
   - Recommendation: either (a) reframe the paper to focus primarily on total overdose deaths (for which pre-2015 data exist) and be explicit about limits for fentanyl-specific inference; or (b) obtain other earlier indicators that proxy fentanyl incidence (toxicology database, forensic lab reports) to construct a longer pre-period.

3. Very small number of treated/control clusters and weak inference
   - The control group comprises seven states (8 states total). With so few clusters, conventional cluster-robust standard errors perform poorly. The authors report HC3 robust SEs and say permutation inference yields similar conclusions (p. 8), but they do not present wild-cluster bootstrap or permutation test results in the paper, nor the permutation procedure details.
   - Recommendation: present inference using appropriate small-cluster methods (wild cluster bootstrap-t, explicit randomization/permutation distribution), report exact p-values, and show robustness of confidence intervals to these methods. Also report sensitivity to excluding single control states (leave-one-out).

4. Constructed control group and heterogeneity of trends
   - The neighbor set includes Arizona (large, distinct trends), and small/rural states (WY, NE). Given level differences (Colorado 1.5–2x neighbor avg, Table 1 p. 6) and likely different demographic/drug-market dynamics, the plausibility of parallel trends is not fully established. Event-study pre-trends are shown only for total deaths (Figure 3, p. 13) but are weak for fentanyl.
   - Recommendation: (i) present results using alternative control groups (synthetic control constructed from many states, or donor pool restricted by pre-trend matching), (ii) show balance and pre-trend tests for each control choice, and (iii) present results weighted by population or on per-capita rates (deaths per 100k) rather than raw counts or log(count+1) to better compare states of different sizes.

5. Absence of enforcement / implementation measures
   - The causal chain from statute change to behavior relies on enforcement and prosecutorial practices. The paper acknowledges unobserved enforcement (p. 16), but lacks any direct evidence on arrests, charging patterns, prosecution/treatment referrals, police practice memos, or county-level discretion. If enforcement did not change, null effects are mechanical and uninformative about the policy’s intended mechanism.
   - Recommendation: incorporate enforcement outcomes (arrest counts for possession, charging rates, plea patterns, treatment referrals), or at minimum present qualitative evidence that enforcement changed (or did not) after the statutory changes. County-level heterogeneity in enforcement could be exploited.

6. Underpowered design without formal power / MDE analysis
   - The paper correctly states it is underpowered (pp. 12–16), but does not present formal detectable minimum effect sizes (MDEs) or power calculations given the sample structure. Without this, readers cannot evaluate whether the null results are informative.
   - Recommendation: include power/MDE calculations for the DiD design (with 8 clusters and the observed variance), and discuss what policy-relevant effect sizes the study could and could not detect.

7. Timing and coding of treatment variables need clarity and robustness
   - It is not clear whether Post-2019 and Post-2022 indicators use enactment or effective dates, and whether the 2019 policy is considered at year resolution (calendar year) or month. The use of 12-month rolling totals and annual indicators could blur timing (Data p. 6, Methods p. 7–8).
   - Recommendation: clearly state policy dates and alignment to outcome measurement (if policy enacted mid-year, use monthly or rolling measures and implement leads/lags appropriately). Present robustness to alternative timing choices.

8. Functional form and outcome measure
   - The primary dependent variable is ln(deaths + 1). Using logs with many zero or small counts (for some states/drug categories) can be sensitive. Also, the paper reports implied percentage effects but does not show results on rates per 100k or in levels with population controls.
   - Recommendation: report per-capita rates (deaths per 100k) and present results in levels as well as logs. Show whether results are sensitive to the +1 adjustment.

## 3. Minor concerns (presentation, additional robustness, clarity)
1. Table and figure details
   - Table 2 (pp. 11–13) shows heteroskedasticity-robust SEs and p-values but does not report alternative inference methods (wild bootstrap p-values) that are critical with eight clusters. Include permutation/wild-bootstrap p-values and confidence intervals from those methods in the table or appendix.
   - Figures (1–3, pp. 9–14) are informative; however, event-study confidence bands are wide—consider plotting alternative control choices or normalized trends (per-capita).

2. Control variables and covariates
   - The DiD specification only includes state and year fixed effects. Although FE are standard, some time-varying covariates (state-level COVID severity, unemployment, Medicaid expansion timing, naloxone distribution funding, treatment capacity) could confound results and improve precision.
   - Suggest adding state×linear time trends as a robustness check and controlling for observed time-varying covariates.

3. Discussion of statutory details and mechanisms
   - The paper notes HB 22-1326 included "guardrails" (treatment pathways, mistake-of-fact defense) which likely attenuate recriminalization effects (pp. 4–5). The authors should discuss more explicitly how these statutory features change expected effect sizes and the policy mechanism (deterrence vs treatment linkages).
   - Also note intra-state heterogeneity in prosecutorial practices; cite any media or administrative records.

4. Data quality and provisional counts
   - The analysis uses provisional CDC Vital Statistics data through late 2024 (p. 6). Discuss potential revisions to provisional counts and how sensitive results are to later revisions. Also discuss misclassification in ICD-10 coding (T40.4 includes synthetic opioids broadly) and whether this changes interpretation.

5. Literature engagement
   - The paper cites relevant literature (Portugal, Oregon). It could strengthen ties to criminology literature on certainty vs severity of punishment (Nagin) and recent empirical work on supply shocks and synthetic opioids (e.g., work using DEA/STRIDE or forensic lab data).

6. Placebo and falsification tests
   - Include placebo tests (e.g., placebo treatment in earlier years or on drug categories unlikely to be affected, e.g., prescription opioid deaths) to show the design’s ability to detect non-effects and to probe for preexisting differential trends.

7. Clarity on “neighbors” construction
   - The paper should clarify whether the control group is an unweighted average, a population-weighted average, or the set used in regression with equal state observations. If readers are to trust the DiD, the control group construction must be transparent.

## 4. Overall assessment
This paper addresses an important and timely policy question: whether changes in possession penalties affect overdose mortality in the fentanyl era. The Colorado policy reversal is a compelling case study and the paper is candid about many limitations. The descriptive patterns (large statewide fentanyl increase and later decline mirroring national patterns; Figures 1–2) are valuable for the policy debate.

However, the current empirical design is insufficiently persuasive for causal inference as presented. The combination of (i) a massive contemporaneous and regionally-staggered supply shock, (ii) minimal pre-treatment data for the fentanyl-specific outcome, (iii) few clusters, and (iv) no direct evidence on enforcement or treatment implementation, means the DiD estimates are not informative about the causal effects of the statutory changes as currently specified. The authors themselves acknowledge many of these points, but further empirical work is needed to salvage causal identification or to reframe the paper as a careful descriptive analysis with clear limits.

If the authors can substantially strengthen the empirical strategy—by exploiting within-state (county- or city-level) variation in enforcement or fentanyl arrival timing, by applying synthetic control methods or richer matching to obtain better counterfactuals, by incorporating enforcement and treatment/admissions data, and by using inference methods valid with few clusters (and presenting power/MDE calculations)—the paper will make a strong and policy-relevant contribution. At present, the paper is an important and well-written policy note but not yet a publishable causal study for a top economics journal.

## Suggested set of revisions (concrete)
1. Provide power / minimum detectable effect calculations for the DiD design and interpret the null in light of these MDEs.
2. Re-analyze using:
   - Synthetic control (state-level donor pool) and/or weighted event-study that matches pre-trends; and/or
   - County-month panel within Colorado exploiting cross-county timing of fentanyl penetration and variation in enforcement/prosecution; and/or
   - Instrumental variation such as differential exposure to supply shock (DEA seizure/forensic lab indicators).
3. Present inference robust to few clusters: wild cluster bootstrap p-values and permutation test details and results.
4. Incorporate enforcement data (possession arrests, charging rates, treatment referrals) and report these outcomes; show whether statutory changes altered enforcement intensity.
5. Report per-capita outcomes (deaths per 100k), levels, and robustness to alternative functional forms (log vs level).
6. Clarify timing of policy implementation and outcome aggregation (monthly vs 12-month rolling), and show robustness to these choices.
7. Expand discussion of provisional data quality and ICD-10 coding limitations.
8. Add placebo/falsification tests and leave-one-out robustness to demonstrate reliance on particular control states.

## Decision
Given the substantive identification problems, the limited pre-treatment data for the primary outcome, and the feasible remedies listed above that would materially affect conclusions, my recommendation is:

DECISION: MAJOR REVISION