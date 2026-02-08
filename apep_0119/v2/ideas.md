# Research Ideas

## Revision of apep_0119

This paper is a revision of apep_0119, not a new paper. The research idea is inherited from the parent.

## Idea 1: Effect of EERS on Residential Electricity Consumption (REVISION)

**Policy:** Energy Efficiency Resource Standards (EERS) - mandatory state requirements for utilities to achieve energy savings targets. 28 jurisdictions adopted between 1998-2020.

**Outcome:** Per-capita residential electricity consumption from EIA SEDS (1990-2023)

**Identification:** Staggered DiD using Callaway-Sant'Anna (2021) with never-treated states as controls

**Why this revision is needed:**
1. Parent paper had code integrity issues (heterogeneity misclassification, selective reporting)
2. Reviewers raised concerns about counterfactual credibility
3. Policy bundling (RPS, decoupling) not adequately addressed
4. Inference improvements needed (wild bootstrap)

**Improvements in this revision:**
- Fixed treatment coding in heterogeneity analysis
- Added region-year fixed effects
- Added controls for concurrent policies
- Added wild cluster bootstrap inference
- Expanded literature (Borusyak, Arkhangelsky, Gardner)

**Feasibility check:** Confirmed - parent paper already published with verified data access
