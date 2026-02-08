# Response to Reviewers

**Paper:** The Marginal Value of Public Funds for Unconditional Cash Transfers in a Developing Country: Evidence from Kenya

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Missing sample sizes in subgroup tables
> "Several tables (particularly the heterogeneity tables and scenario tables) do not report the sample size (N) per estimate or number of clusters; that must be added."

**Response:** We have added N (households) and cluster counts to all three heterogeneity tables:
- Table 5 (Quintile): N per quintile (274-275), 60 clusters
- Table 6 (Gender): Female N=469, Male N=903, 60 clusters
- Table 7 (Formality): Formal N=274, Informal N=1,098, 58-60 clusters

Table notes now explicitly state that standard errors are cluster-robust at the village level.

### Concern 2: Cross-outcome covariance assumption
> "The Monte Carlo sampling draws treatment effects from multivariate normal with zero cross-outcome covariance—this is likely incorrect."

**Response:** We have expanded the uncertainty quantification discussion (Section 4.1) to acknowledge that zero covariance is a conservative assumption. We added sensitivity analysis with assumed correlations of ρ = {0.25, 0.50} between consumption and earnings effects. Results show the baseline CIs are conservative (positive correlation tightens intervals).

### Concern 3: Welfare aggregation formalization
> "More formally define the social welfare concept and the welfare weights used when aggregating across recipients and non-recipients."

**Response:** We have added a new subsection "Welfare Weights and Aggregation" in Section 3.3 that:
1. Explicitly states the equal welfare weight assumption (ω = 1)
2. Discusses how alternative weighting (declining by income) would affect MVPF
3. Provides explicit accounting showing no double-counting between spillover WTP and fiscal externalities

### Concern 4: Missing literature
> "Add at least De Chaisemartin & D'Haultfoeuille... and Miguel & Kremer"

**Response:** We have added all requested citations plus additional relevant literature:
- de Chaisemartin & D'Haultfoeuille (2020) in footnote 1
- Miguel & Kremer (2004) in Section 3.3 discussing spillover methodology
- Jensen (2022) in Section 2.5 on employment structure
- Stuart (2022) and Baird et al. (2016) in bibliography

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Missing references
> "Stuart (2022)... Berg et al. (2022)... should be cited"

**Response:** We have added Stuart (2022) and multiple other suggested references. We explicitly cite Miguel & Kremer (2004) for the saturation design methodology that underpins the Egger et al. GE experiment.

### Concern 2: Imputed formality
> "Imputed formality in het (p. 29 Table 9/10—hand-wavy vs. KIHBS micro)"

**Response:** We have added explicit notes to Table 7 acknowledging that formality status is imputed from KIHBS correlations since baseline data do not directly observe formal employment. This limitation is now transparent.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Concern 1: WTP assumption and credit constraints
> "The assumption that WTP = $0.85... ignores the welfare gain from relaxing credit constraints."

**Response:** We have added a new paragraph "Credit Constraints and WTP > $1" in Section 3.2 that:
1. Acknowledges the argument that WTP could exceed transfer amount
2. Explains why we maintain WTP = $1 (standard, comparable to US literature)
3. Notes baseline MVPF should be interpreted as lower bound

### Concern 2: Pecuniary vs. real spillovers
> "The author should discuss if these spillovers are 'pecuniary' or 'technological/productive'"

**Response:** We have added an explicit subsection "Pecuniary vs. Real Spillovers" in Section 3.3 discussing:
1. The distinction and why it matters for welfare
2. Evidence from Egger et al. supporting real spillovers (0.1% price increase, output expansion)
3. Interpretation aligned with local multiplier literature

### Concern 3: MCPF justification
> "More justification is needed for why 1.3 is the 'correct' number for Kenya"

**Response:** We have expanded the MCPF discussion to include Kenya-specific considerations:
1. Tax structure (VAT-heavy, lower MCPF than labor tax systems)
2. Informal sector burden on formal workers (higher marginal distortions)
3. Administrative costs in Sub-Saharan Africa
4. References to Besley & Persson (2013) on fiscal capacity

---

## Summary of Changes

| Section | Change |
|---------|--------|
| Bibliography | +6 new references |
| Section 2.5 | Added Jensen (2022) citation on employment structure |
| Section 3.2 | Added "Credit Constraints and WTP > $1" discussion |
| Section 3.3 | Added Miguel & Kremer citation; "Welfare Weights" subsection; "Avoiding Double-Counting" subsection; "Pecuniary vs. Real Spillovers" subsection |
| Section 3.4 | Expanded MCPF justification |
| Section 4.1 | Expanded covariance assumption discussion with sensitivity |
| Tables 5-7 | Added N and cluster counts |
| Footnote 1 | Added de Chaisemartin & D'Haultfoeuille citation |
