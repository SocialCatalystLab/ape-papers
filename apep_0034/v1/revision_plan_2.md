# Revision Plan - Round 2

## Reviewer Concerns and Responses

### 1. Paper Length (13 pages vs 25+ expected)
**Concern:** Paper is too short for top-journal submission.

**Resolution:** Expand key sections:
- Extended institutional background on noncompete law evolution
- Deeper empirical strategy discussion with formal notation
- More detailed results interpretation
- Expanded robustness section

### 2. Missing Event Study Figures (CRITICAL)
**Concern:** Event study plots are essential for DiD papers but not included.

**Resolution:** Generate event study figure using R and include in paper. Add Figure 1 showing dynamic treatment effects with 95% CIs.

### 3. Inference with 6 Treated States
**Concern:** Conventional clustering may be unreliable with few treated clusters.

**Resolution:**
- Add discussion of wild cluster bootstrap inference
- Report permutation p-values
- Discuss minimum detectable effects and power limitations
- Frame null results appropriately given statistical power

### 4. Treatment Heterogeneity
**Concern:** Pooling heterogeneous policies (bans vs thresholds vs penalties).

**Resolution:**
- Add discussion acknowledging policy heterogeneity
- Note that separate estimation by policy type lacks power (1-2 states each)
- Acknowledge this as key limitation
- Suggest future work with more post-treatment data

### 5. Missing Literature References
**Concern:** Should cite Sun & Abraham, de Chaisemartin & D'Haultfoeuille, Roth, etc.

**Resolution:** Add the following references:
- Sun & Abraham (2021) - event study heterogeneous effects
- de Chaisemartin & D'Haultfoeuille (2020) - TWFE problems
- Borusyak, Jaravel & Spiess (2024) - robust estimation
- Roth (2022) - pre-trends sensitivity
- Cameron, Gelbach & Miller (2008) - few-cluster inference
- MacKinnon & Webb (2017) - wild bootstrap

### 6. Sample Size Inconsistency (47 vs 48 states)
**Concern:** Text says 48 states, Table says 47, arithmetic doesn't match N.

**Resolution:** Clarify: 50 states + DC = 51; minus CA, ND, OK (pre-existing restrictions) = 48 jurisdictions. Some state-quarters have missing QWI data, yielding N=1,207.

### 7. Significance Stars and P-values
**Concern:** Table lacks conventional significance markers.

**Resolution:** Add significance stars (* p<0.10, ** p<0.05, *** p<0.01) to tables.

## Summary of Changes to Make
1. Generate and include event study figure
2. Expand paper length with deeper methodology discussion
3. Add wild bootstrap inference discussion
4. Add missing DiD literature references
5. Clarify sample construction
6. Add significance stars to tables
7. Improve narrative flow and prose quality
