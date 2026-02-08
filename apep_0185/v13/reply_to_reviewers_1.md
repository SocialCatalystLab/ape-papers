# Reply to Reviewers: apep_0203 → paper_188

## Response to GPT-5-mini (Major Revision)

### Concern 1: Event study IV plot needed
**Response:** The event study (Figure 5) now shows both employment (Panel A) and earnings (Panel B) dynamic treatment effects. Figure 6 presents structural vs. reduced-form event studies side by side. Pre-treatment coefficients are small and insignificant, providing no evidence of differential pre-trends.

### Concern 2: Wild cluster bootstrap
**Response:** We now report shock-robust inference in Table 5, including state clustering, two-way clustering, Anderson-Rubin, permutation inference (2,000 draws), and Borusyak et al. origin-state clustering. All methods confirm significance for population-weighted specification.

### Concern 3: Complier characterization
**Response:** Table 9 in Appendix B.2 characterizes compliers by IV sensitivity quartile, showing high-compliance counties have stronger cross-state social connections.

## Response to Grok-4.1-Fast (Major Revision)

### Concern 1: Housing price discussion
**Response:** Added Section 11.2 "Housing Prices: An Important Omission" discussing how housing costs could partially offset welfare gains from higher wages, citing Roback (1982) and Bailey et al. (2018b). Acknowledged as important direction for future research.

### Concern 2: Event study needed
**Response:** See Figure 5 (dual-panel event study) and Figure 6 (structural vs. reduced-form), both now in the main manuscript.

### Concern 3: Magnitude concerns
**Response:** Added detailed magnitude discussion in Section 11.1, contextualizing the 9% employment effect through LATE interpretation, standard deviation framing ($0.96 SD → 8.6% employment), and comparisons to Kline and Moretti (2014) spatial multipliers.

## Response to Gemini-3-Flash (Minor Revision)

### Concern 1: Strengthen instrument credibility
**Response:** Added Figure 2 showing within-state residual variation in the instrument under both unconstrained and distance-constrained (≥500km) conditions. This visually demonstrates that the IV exploits meaningful within-state variation, not just cross-state differences absorbed by state fixed effects. Also restructured Table 1 to show distance-credibility tradeoff directly in the main results.

### Concern 2: Earnings analysis alongside employment
**Response:** Earnings is now the primary outcome (Panel A in Table 1). The 6-column format shows OLS, main IV, and distance-restricted IV specifications for both earnings and employment side by side.
