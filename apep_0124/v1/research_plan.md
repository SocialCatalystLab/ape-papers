# Initial Research Plan

**Title:** Do Close Referendum Losses Demobilize Voters? Evidence from Swiss Municipal Voting

**Date:** 2026-01-31

---

## 1. Research Question

Does narrowly losing a local referendum vote affect subsequent voter turnout? Specifically, in municipalities where a national referendum passed but the local vote was narrowly against it (vs. narrowly for it), do voters subsequently turn out at different rates for thematically related referendums?

### Theoretical Motivation

Two competing hypotheses from the political behavior literature:

1. **Demobilization hypothesis:** Losing—especially narrowly—reduces democratic efficacy beliefs and subsequent participation. Voters who "almost won" but lost may feel the system is unresponsive, leading to withdrawal.

2. **Mobilization hypothesis:** Narrow losses galvanize opposition. Voters who "almost won" may be motivated to turn out more strongly in future related votes to finally achieve their policy goals.

The winner-loser gap literature documents attitude effects (losers become more skeptical of referendum legitimacy), but **turnout effects** remain understudied.

---

## 2. Identification Strategy

### Regression Discontinuity Design (RDD)

**Setting:** Swiss federal referendums where the proposal **passed nationally** but some municipalities voted against it.

**Running variable:** Municipal-level "Yes" vote share (continuous, 0-100%)

**Cutoff:** 50%

**Treatment:**
- "Local losers" = municipalities with Yes share just below 50% (voted No, but national proposal passed)
- "Local winners" = municipalities with Yes share just above 50% (voted Yes, national proposal passed)

**Outcome:** Voter turnout in subsequent referendums on thematically related topics

### Why This Works

1. **Local randomization near cutoff:** Municipalities with 49.9% Yes are plausibly similar to those with 50.1% Yes in all characteristics except the "winning/losing" psychological experience.

2. **Policy outcome is constant:** Since we restrict to referendums that passed nationally, all municipalities experience the same policy change—the only difference is whether they "won" or "lost" locally.

3. **Rich data:** ~2,100 Swiss municipalities × ~700 federal referendums since 1981 provides substantial sample for detecting effects.

---

## 3. Pre-Specified Design Choices

### 3.1 Defining "Thematically Related" Referendums

Use the official Swissvotes policy domain classification (12 categories):
1. Institutional order
2. Foreign policy
3. Security/national defense
4. Economy
5. Agriculture
6. Public finances
7. Energy
8. Transport/infrastructure
9. Environment/living space
10. Social policy
11. Education/research
12. Culture/media/family

**Pre-registration:** A "related" subsequent referendum is one in the **same policy domain** as the focal referendum.

### 3.2 Sample Restrictions

- **Focal referendums:** Federal referendums that **passed** (both popular and cantonal majorities if required)
- **Time window for outcomes:** 1-5 years after focal referendum
- **Bandwidth for RDD:** Optimal bandwidth selection via rdrobust package (Calonico et al. 2014)
- **Minimum sample:** Only include focal referendums with ≥50 municipalities within ±10pp of cutoff

### 3.3 Estimation

**Primary specification:**
```
Turnout_{m,t+k} = α + β × LocalWin_m + f(YesShare_m - 50) + ε_{m,t+k}
```

Where:
- `Turnout_{m,t+k}` = turnout in municipality m for related referendum k periods later
- `LocalWin_m` = 1 if Yes share > 50%, 0 otherwise
- `f(·)` = local polynomial (1st or 2nd order, selected via rdrobust)
- Standard errors clustered at canton level

**Preferred estimator:** rdrobust with MSE-optimal bandwidth and robust bias-corrected inference (Calonico, Cattaneo, Titiunik 2014)

---

## 4. Validity Tests

### 4.1 Density Test (McCrary)

Test for manipulation of the running variable at the 50% cutoff. Under local randomization, there should be no discontinuity in the density of municipalities around 50%.

### 4.2 Covariate Balance

Test for discontinuities in pre-determined covariates at the 50% cutoff:
- Population (log)
- Language region (German, French, Italian, Romansh)
- Canton
- Urbanity classification
- Historical turnout (pre-focal referendum average)

### 4.3 Placebo Tests

1. **Fake cutoffs:** Run RDD at 40%, 45%, 55%, 60% — should find no effects
2. **Pre-period turnout:** Use turnout in referendums *before* the focal referendum — should find no effects
3. **Unrelated domains:** Use turnout in subsequent referendums from *different* policy domains — should find smaller/no effects

### 4.4 Robustness

- Bandwidth sensitivity (0.5×, 0.75×, 1.25×, 1.5× of optimal)
- Polynomial order (1 vs 2)
- Kernel choice (triangular, uniform, Epanechnikov)
- Exclude municipalities exactly at 50% (to address potential heaping)

---

## 5. Data Sources

### 5.1 Referendum Results (Municipality Level)

**Source:** Swiss Federal Statistical Office via voteinfo-app.ch API

**Format:** JSON files for each referendum date

**Variables:**
- `geoLevelnummer`: Municipality ID
- `geoLevelname`: Municipality name
- `jaStimmenInProzent`: Yes vote share (%)
- `jaStimmenAbsolut`: Yes votes (count)
- `neinStimmenAbsolut`: No votes (count)
- `stimmbeteiligungInProzent`: Turnout (%)
- `anzahlStimmberechtigte`: Eligible voters

**Coverage:** 1981-present, ~2,100 municipalities, ~700 referendums

### 5.2 Referendum Metadata

**Source:** Swissvotes database (CSV)

**Variables:**
- Vote date
- Policy domain (12 categories)
- Vote type (initiative, counter-proposal, referendum)
- National outcome (passed/failed)
- Party recommendations

### 5.3 Municipal Covariates

**Source:** BFS via PXWeb API / bfs_get_base_maps()

**Variables:**
- Population
- Language region
- Canton
- Urbanity classification

### 5.4 Municipal Merger Mapping

**Source:** SMMT R package

**Purpose:** Create consistent municipal panel by mapping historical municipality IDs to current boundaries

---

## 6. Expected Results

### 6.1 If Demobilization Hypothesis Holds

- β < 0: Local losers subsequently turn out at lower rates than local winners
- Effect should be stronger for:
  - Closer votes (narrower margins)
  - Higher-salience referendums
  - Voters with weaker prior partisan attachment

### 6.2 If Mobilization Hypothesis Holds

- β > 0: Local losers subsequently turn out at higher rates than local winners
- "Sore loser" mobilization to reverse outcomes

### 6.3 Null Result Interpretation

If β ≈ 0, this is still informative:
- Suggests winning/losing experiences in direct democracy don't persistently affect participation
- Democratic resilience: voters continue participating regardless of past outcomes
- Contrasts with "democratic fatigue" concerns

---

## 7. Contribution

1. **Methodological:** First application of close-election RDD to referendum turnout dynamics
2. **Theoretical:** Tests competing hypotheses about democratic participation and policy feedback
3. **Policy:** Informs design of direct democracy institutions (does frequent voting build or erode engagement?)

---

## 8. Robustness to Reviewer Concerns (Anticipated)

| Concern | Response |
|---------|----------|
| "Close votes aren't random" | RDD local randomization at cutoff; covariate balance tests |
| "Municipalities self-select" | Selection on running variable doesn't bias RDD at cutoff |
| "Effects are small" | Large sample size provides power; minimum detectable effect analysis |
| "Domain matching is arbitrary" | Pre-specified using official Swissvotes classification |
| "Only applies to Switzerland" | Swiss direct democracy is benchmark case; generalizable to other referendum systems |

---

## 9. Timeline (Phases)

1. **Data collection:** Fetch referendum results for all votes since 1981
2. **Data processing:** Create municipal panel, handle mergers, construct variables
3. **Estimation:** Run primary RDD and all robustness checks
4. **Visualization:** Event study plots, RDD discontinuity graphs
5. **Writing:** Full paper with results

---

## 10. Primary Estimand

**Local Average Treatment Effect (LATE) at the 50% cutoff:**

The effect of "local winning" vs "local losing" on subsequent turnout, for municipalities whose Yes vote share was exactly at 50%.

This is identified under standard RDD assumptions:
1. Continuity of potential outcomes at cutoff
2. No manipulation of running variable
3. Local randomization near cutoff
