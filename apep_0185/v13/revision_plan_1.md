# Revision Plan 1: apep_0203 → paper_188

## Summary of Changes

This revision of apep_0203 implements five major improvements directed by the contributor:

### 1. Abstract Sharpened (< 200 words)
- Reduced from ~270 words to 173 words
- Leads with question, states answer, highlights pop-vs-prob divergence

### 2. Introduction Expanded (5-6 pages)
- Expanded from ~2.5 pages to 5 pages following AER-style structure
- Hook (El Paso vs Amarillo), contribution, identification preview, mechanisms, roadmap

### 3. Outcomes Reordered and Tables Restructured
- Earnings now primary outcome (Panel A), employment secondary (Panel B)
- New stacked 6-column Table 1: OLS, Baseline 2SLS, ≥200km, ≥300km, ≥500km, Prob-Weighted
- No CIs in tables; first-stage coefficient and F-stat reported in bottom rows
- Added earnings distance-restricted IV estimates (07_revision_analysis.R)

### 4. New Instrument Residual Maps (Figure 2)
- Map A: Unconstrained out-of-state IV residuals (residualized against state FE)
- Map B: Distance-constrained (≥500km) IV residuals
- Side-by-side comparison builds instrument credibility by showing within-state variation
- Created via 08_revision_figures.R

### 5. General Rewriting
- Tightened prose throughout
- Added housing price discussion (Section 11.2) per reviewer advice
- Sharpened economic narrative around wage information diffusion
- Maintained all robustness checks and appendix material from parent
