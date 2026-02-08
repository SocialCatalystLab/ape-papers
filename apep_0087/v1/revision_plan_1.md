# Revision Plan for Paper 110

Based on external reviews from 3 parallel GPT-5.2 reviewers.

## Review Outcome: REJECT AND RESUBMIT (All 3 Reviewers)

## Key Issues Identified

### 1. Identification Strategy (Critical)
- **Problem**: Distance to dispensary is fundamentally confounded with rurality, road type, enforcement intensity, demographics, and other spatial factors
- **Current approach**: State + year FE does not address within-state spatial confounding
- **Required**: Move to a border-discontinuity design or county-month panel exploiting CA/NV openings as shocks

### 2. Estimand Issues (Critical)
- **Problem**: Studying composition (share of crashes involving alcohol) rather than levels makes causal interpretation difficult
- **Required**: Estimate counts/rates of alcohol-involved crashes with Poisson/PPML, not just conditional shares

### 3. Treatment Measurement (Major)
- **Problem**: Driving time approximated with Haversine × 1.3 / constant speed is too crude
- **Required**: Use actual routing (OSRM/OpenRouteService) at least for validation

### 4. Inference (Major)
- **Problem**: Only 8 state clusters; no 95% CIs reported; spatial correlation not addressed
- **Required**: Report CIs, implement Conley spatial HAC SEs, consider county-level clustering

### 5. Literature (Major)
- **Problem**: Bibliography is too thin for top-journal standards
- **Required**: Add citations for:
  - Modern DiD methods (Callaway & Sant'Anna, Goodman-Bacon, Sun & Abraham)
  - Spatial inference (Conley 1999, Cameron & Miller 2015)
  - Border designs (Dube-Lester-Reich 2010, Holmes 1998)
  - Cannabis policy literature (Santaella-Tenorio et al. 2017, others)

### 6. Presentation (Minor-Moderate)
- Missing 95% confidence intervals
- Figures not publication-quality (need scale bars, better legends)
- Too many bullet lists in conceptual framework section

## Recommended Next Steps

Given the scope of required changes, this paper requires fundamental methodological redesign rather than cosmetic revision:

1. **Rebuild research design** around county-month panel with dispensary opening dates
2. **Implement event-study/DiD** around NV (2017) and CA (2018) openings
3. **Estimate levels** (crash counts/rates), not just composition
4. **Upgrade inference** with spatial HAC, better clustering, and 95% CIs
5. **Expand literature review** substantially

## Current Status

The paper has passed the advisor review (no fatal errors) and demonstrates:
- Novel research question
- Clean continuous treatment measure concept
- Appropriate wild cluster bootstrap for few-cluster inference
- Publication-quality tables

However, the identification strategy needs fundamental rethinking to meet top-journal standards.
