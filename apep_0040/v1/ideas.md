# Research Ideas

## Idea 1: The Remote Work Wage Premium — A Doubly Robust Analysis

**Policy/Treatment:** Working from home (remote work) vs. commuting to workplace

**Outcome:** Annual wages and salary income

**Data Source:** American Community Survey PUMS 2022 via Census API (no authentication required)

**Identification Strategy:** Doubly Robust estimation (AIPW/DML) with cross-fitting

The key identification assumption is selection on observables: conditional on detailed occupation, industry, education, demographics, and state, remote work assignment is as-good-as-random. This is plausible because:

1. **Occupation determines feasibility:** Most variation in remote work comes from occupation-level technical feasibility. Software developers can work remotely; surgeons cannot. By controlling for 500+ detailed occupation codes, we absorb most of this selection.

2. **Industry norms vary:** Within occupations, industry matters (tech vs manufacturing). We control for 270+ industry codes.

3. **Education signals skills:** Higher education workers are more likely to have jobs amenable to remote work. We control for 25 education levels.

4. **Rich demographics:** Age, sex, race, marital status, state capture remaining observable determinants.

**Estimand:** Average Treatment Effect on the Treated (ATT) — the wage effect for workers who work remotely

**Feasibility Check:**
- ✓ California sample: 117,422 observations (23,170 WFH, 92,942 commuters)
- ✓ Raw wage gap: $37,123 (WFH $105,589 vs Commuters $68,466)
- ✓ Rich covariates: OCCP, INDP, SCHL, AGEP, SEX, RAC1P, MAR, ST, WKHP, COW
- ✓ Data accessible via Census API without authentication

**Why It's Novel:**
1. Post-pandemic remote work is a major policy debate; this provides rigorous causal evidence
2. Prior studies are correlational or use simpler methods; DR/DML provides better causal identification
3. Detailed occupation × industry controls make unconfoundedness more credible than prior work
4. Sensitivity analysis (E-values, calibrated bounds) will quantify how strong unmeasured confounding would need to be

**Mechanisms to Explore:**
- Heterogeneity by occupation type (knowledge work vs other)
- Gender heterogeneity (childcare implications)
- Urban vs rural differences
- Firm type (for-profit vs nonprofit vs government)

**Required Sensitivity Analysis:**
- E-values for unmeasured confounding
- Calibrated sensitivity (benchmark to education coefficient)
- Negative control outcomes (placebo tests)

---

## Idea 2: Employer-Sponsored Health Insurance and Labor Supply

**Policy/Treatment:** Having employer-sponsored health insurance vs. other insurance sources

**Outcome:** Usual hours worked per week (WKHP)

**Data Source:** American Community Survey PUMS 2022

**Identification Strategy:** Doubly Robust estimation controlling for income, family structure, occupation, industry, age, and health status proxies

**Why It's Interesting:** Post-ACA, employer-sponsored insurance remains dominant for working-age adults. Does ESI create "job lock" that increases hours worked beyond optimal levels?

**Feasibility Check:**
- ✓ HINS1 variable captures employer-sponsored insurance
- ✓ WKHP measures usual hours worked
- ✓ Rich demographic and labor market controls available
- Challenge: Selection into ESI is correlated with employment itself

**Novel Angle:** Focus on intensive margin (hours conditional on employment) rather than extensive margin

---

## Idea 3: Self-Employment Premium — Incorporated vs Unincorporated Businesses

**Policy/Treatment:** Incorporated self-employment vs unincorporated self-employment

**Outcome:** Total personal income (PINCP)

**Data Source:** American Community Survey PUMS 2022

**Identification Strategy:** Doubly Robust estimation controlling for occupation, industry, education, demographics

**Why It's Interesting:** Prior work shows incorporated self-employed earn more than unincorporated. Is this selection or causal? Incorporation provides liability protection and tax advantages.

**Feasibility Check:**
- ✓ COW=7 (incorporated) vs COW=6 (unincorporated)
- ✓ ~3.9M incorporated, ~5.9M unincorporated in workforce
- ✓ Incorporated mean income: $102,113 vs Unincorporated: $59,075
- ✓ Rich occupation/industry controls available

**Novel Angle:** Use DR methods to estimate causal effect of incorporation, controlling for occupation-specific selection

---

## Recommendation

**Pursue Idea 1 (Remote Work Wage Premium)** as the primary research focus:

1. Highest policy relevance — post-pandemic remote work is a major debate
2. Cleanest identification — occupation largely determines WFH eligibility
3. Richest data — detailed occupation × industry × education controls
4. Most novel — first rigorous DR/DML analysis of remote work wage effects
5. Clear mechanisms to explore and heterogeneity analyses

Ideas 2 and 3 are feasible backups if Idea 1 encounters unforeseen problems.
