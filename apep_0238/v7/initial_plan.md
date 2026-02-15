# Initial Research Plan: Demand Recessions Scar, Supply Recessions Don't

## Research Question

Do demand-driven recessions produce larger and more persistent labor market scarring effects than supply-driven recessions? Specifically, how do the persistence profiles of state-level employment responses differ between the Great Recession (2007-2009) and the COVID recession (2020)?

## Identification Strategy

**Local Projections with Bartik Instrument (LP-IV)**

For each recession episode r ∈ {Great Recession, COVID}:

1. **Bartik instrument construction:**
   - Pre-recession industry employment shares by state: share_{s,j,t0} = E_{s,j,t0} / E_{s,t0}
   - National industry employment changes (leave-one-out): ΔE_{-s,j,t} = (E_{j,t} - E_{j,t-1} - ΔE_{s,j,t}) / (E_{j,t-1} - E_{s,j,t-1})
   - Bartik shock: B_{s,t} = Σ_j share_{s,j,t0} × ΔE_{-s,j,t}

2. **Local projection specification:**
   y_{s,t+h} - y_{s,t-1} = β_h × B_{s,t} + γ_h × X_{s,t} + α_s + ε_{s,t+h}

   for h = 0, 3, 6, 12, 24, 36, 48, 60, 72, ..., 120 months

3. **Key comparison:** β_h^{GR} vs β_h^{COVID} at long horizons (h > 36)
   - If β_h^{GR} stays negative while β_h^{COVID} → 0: demand recessions scar, supply don't

## Exposure Alignment

**Who is treated:** All workers in states with greater pre-recession exposure. For the Great Recession, treatment intensity is the 2003--2006 housing price boom. For COVID, treatment intensity is the Bartik-predicted employment shock. This is a continuous exposure design, not binary treatment.

**Affected population:** State-level labor markets. Outcomes: employment, unemployment rate, labor force participation.

**Comparison group:** States with lower exposure serve as implicit controls across the continuous exposure distribution.

## Expected Effects and Mechanisms

**Primary hypothesis:** β_h^{GR} remains significantly negative at h = 60-120, while β_h^{COVID} converges to zero by h = 24-36.

**Mechanisms (from structural model):**
1. **Skill depreciation:** Prolonged unemployment in demand recessions → human capital loss → lower reemployment probability
2. **Participation exit:** Long unemployment durations → discouraged workers exit labor force → permanent employment loss
3. **Duration dependence:** Employers discriminate against long-term unemployed → self-reinforcing unemployment trap

**Why COVID differs:**
- Supply shock: firms shut down but demand preserved → rapid recall when restrictions lift
- Fiscal transfers (CARES Act, PPP): maintained income → prevented forced consumption cuts
- Short unemployment spells: minimal skill depreciation
- Furlough/recall mechanism: preserved job matches

## Primary Specification

- **Dependent variables:** log(employment), unemployment rate, LFPR, log(wages)
- **Treatment:** Bartik-predicted cumulative employment shock during recession window
- **Sample:** 50 states + DC, monthly, 2005-2023
- **Fixed effects:** State FE, calendar month FE
- **Standard errors:** Clustered by state (Driscoll-Kraay for robustness)
- **Instrument validity:** Goldsmith-Pinkham et al. (2020) Rotemberg decomposition

## Planned Robustness Checks

1. Alternative Bartik base years (2005, 2006, 2007)
2. Leave-one-industry-out sensitivity
3. Exclude outlier states (NV, AZ for Great Recession; NY, NJ for COVID)
4. Control for pre-trends (pre-recession employment growth)
5. Alternative clustering (census division)
6. FGLS with AR(1) errors
7. Placebo shocks (random permutation of Bartik across states)
8. Subsample analysis: by census region, state population, pre-recession employment level

## Structural Model

**DMP Search Model with Endogenous Participation and Skill Depreciation**

- Workers: heterogeneous human capital h, choose participation
- Firms: free entry, post vacancies
- Two shock types: demand (productivity a ↓) and supply (separation δ ↑ temporarily)
- Human capital depreciates during unemployment: h' = h × exp(-λ × duration)
- Participation decision: enter labor force if V_U(h) > V_OLF

**Calibration targets:**
- Average unemployment rate, job finding rate, separation rate
- Unemployment duration distribution
- Labor force participation rate and cyclicality
- Cross-state employment persistence after each recession

**Counterfactuals:**
1. What if Great Recession had COVID's shock structure (temporary supply)?
2. What if COVID had no fiscal stimulus (pure demand contraction)?
3. Shutting off each mechanism: no skill depreciation, no participation exit, no duration dependence

## Data Sources

| Source | Series | Frequency | Coverage |
|--------|--------|-----------|----------|
| FRED (BLS CES) | State nonfarm payrolls | Monthly | 50 states, 2005-2023 |
| FRED (BLS CES) | State industry employment (6+ industries) | Monthly | 50 states, 2005-2023 |
| FRED (BLS LAUS) | State unemployment rate | Monthly | 50 states, 2005-2023 |
| FRED (BLS LAUS) | State labor force participation | Monthly | 50 states, 2005-2023 |
| FRED (BEA) | State GDP | Annual | 50 states, 2005-2023 |
| FRED | National series (GDP, CPI, FFR, JOLTS) | Monthly | 2005-2023 |
