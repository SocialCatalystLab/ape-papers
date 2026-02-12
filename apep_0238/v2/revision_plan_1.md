# Revision Plan — Stage C (Post-Referee Review)

## Reviews Received
- **GPT-5-mini:** MAJOR REVISION
- **Grok-4.1-Fast:** MINOR REVISION
- **Gemini-3-Flash:** MINOR REVISION

## Key Concerns Addressed

### 1. Missing Methodological Citations (GPT, Grok)
- Added Goodman-Bacon (2021) and Callaway & Sant'Anna (2021) to references.bib
- Added paragraph in Empirical Strategy explaining why LP is preferred over TWFE/staggered DiD
- GPS, Borusyak et al., Adao et al., Dupraz et al. already cited

### 2. Reduced-Form vs IV Language Clarity (GPT)
- Paper already has explicit paragraph (Section 5.1) clarifying this is reduced-form LP, not 2SLS
- No additional changes needed — GPT acknowledged the paper defines the estimand

### 3. Permutation Algorithm Documentation (GPT)
- Added formal 4-step algorithm description in appendix robustness section
- Documents: baseline estimation, 1,000 random reassignments, re-estimation, two-sided p-value computation

### 4. Migration Discussion (All 3 reviewers)
- Strengthened "Compositional changes" subsection in Threats to Validity
- Added citation to Dao (2017) on declining interstate migration
- Note that 84-month persistence despite migration underscores demand-shock severity

### 5. Welfare CE Contextualization (GPT)
- Added sentence explaining what 33.5% CE loss means in practical terms
- Clarified that magnitude reflects permanent productivity decline through scarring

### 6. Prose Improvements (Exhibit + Prose reviews)
- Removed roadmap paragraph (Section 1)
- Punched up opening of Results section 6.1
- Strengthened welfare asymmetry hook ("staggering" + own sentence)
- Active verbs in mechanisms section ("choke off hiring, trapping workers")

### 7. Table Specification Rows (Exhibit review)
- Added "State controls: No" and "Region fixed effects: No" rows to Table 3

## Items NOT Addressed (acknowledged as limitations)
- Worker-level mediation analysis (CPS microdata) — beyond scope of this revision
- PPP/fiscal policy controls — data not available at required granularity
- Wild cluster bootstrap — infeasible with 9 clusters (already discussed in paper)
- F-statistics — paper uses reduced-form, not 2SLS; R² reported as relevance proxy
