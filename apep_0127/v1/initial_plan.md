# Initial Research Plan: School Transport Subsidies and Educational Equity in Sweden

## Research Question

**Primary Question:** Do school transport subsidies (skolskjuts) increase educational opportunity for disadvantaged students?

**Specific Hypotheses:**
1. Families living just beyond the skolskjuts eligibility threshold (2-3 km) are more likely to exercise school choice (attend non-assigned schools) than those just below the threshold.
2. The effect of transport subsidies on school choice is larger for low-income neighborhoods than high-income neighborhoods.
3. Increased school choice access translates to improved educational outcomes (merit points).

## Identification Strategy

### Spatial Regression Discontinuity Design (Spatial RDD)

**Running Variable:** Distance from DeSO neighborhood centroid to nearest municipal school

**Cutoff:** Municipality-specific skolskjuts eligibility thresholds:
- 2 km for grades F-3 (preschool through 3rd grade)
- 3 km for grades 4-6

**Treatment:** Eligibility for free school transport (skolskjuts)

**Assignment:** Sharp discontinuity—students living beyond the threshold are eligible; those within are not

### Identification Assumptions

1. **No precise manipulation:** Families cannot precisely sort to either side of the distance threshold. Supported by:
   - Distance thresholds are municipal policy, not individual choice
   - Housing decisions are made long before school enrollment
   - Thresholds vary across municipalities (no single "target" to game)

2. **Continuity:** All other factors affecting school choice and educational outcomes vary smoothly at the threshold

3. **Excludability:** The only channel through which living beyond the threshold affects outcomes is through transport subsidy eligibility

### Threats to Identification

1. **Measurement error:** Using DeSO centroids rather than individual addresses introduces error in the running variable. Mitigation: Focus on DeSOs that clearly fall on one side of the threshold (exclude "donut hole" near cutoff).

2. **Heterogeneous thresholds:** Different municipalities use different thresholds and grade-specific rules. Mitigation: Collect municipality-specific rules and estimate municipality-specific discontinuities; pool using inverse-variance weighting.

3. **Compound treatments:** Students just beyond the threshold may differ in other ways (more rural, different school supply). Mitigation: Balance tests on pre-determined DeSO characteristics; border-pair analysis as robustness.

## Expected Effects and Mechanisms

### Causal Chain
```
Transport subsidy eligibility
    ↓
Lower effective cost of attending distant schools
    ↓
More school choice (attend non-assigned schools, including friskolor)
    ↓
Better "match" between student and school
    ↓
Improved educational outcomes
```

### Predicted Effect Sizes
Based on Andersson, Malmberg & Östh (2012) showing ~20% of 15-year-olds travel >10km to school:
- School choice uptake: 3-8 percentage point increase at threshold
- Travel distance: 0.5-1.5 km increase in average distance traveled
- Merit points: 2-5 point increase (modest, as mechanism is indirect)

### Heterogeneity
- **By neighborhood SES:** Expect larger effects in low-income DeSOs (transport cost is binding constraint)
- **By urbanity:** Expect larger effects in suburban/semi-urban areas (rural areas have fewer school options; urban areas have dense transit)
- **By immigrant status:** Expect larger effects in high-immigrant DeSOs (information barriers compound cost barriers)

## Primary Specification

### Main Estimating Equation

For DeSO $d$ in municipality $m$:

$$Y_{dm} = \alpha + \tau \cdot \mathbf{1}[\text{Distance}_d > \text{Threshold}_m] + f(\text{Distance}_d - \text{Threshold}_m) + X_{dm}'\beta + \gamma_m + \epsilon_{dm}$$

Where:
- $Y_{dm}$ = outcome (school choice rate, average merit points)
- $\mathbf{1}[\cdot]$ = indicator for skolskjuts eligibility
- $f(\cdot)$ = polynomial in centered running variable (linear default)
- $X_{dm}$ = pre-determined DeSO characteristics (optional)
- $\gamma_m$ = municipality fixed effects
- $\tau$ = local average treatment effect at the threshold

### Bandwidth Selection
- Use Imbens-Kalyanaraman (IK) optimal bandwidth
- Report sensitivity to bandwidth choices (0.5×, 0.75×, 1×, 1.25×, 1.5× optimal)
- Implement bias-corrected RD estimator (Calonico, Cattaneo, Titiunik 2014)

### Inference
- Cluster standard errors at municipality level (policy variation)
- Report both conventional and robust confidence intervals
- Permutation inference as robustness

## Data Sources

### Outcome Data (Kolada API)

| Variable | KPI Code | Level | Years |
|----------|----------|-------|-------|
| Merit points (average) | N15504 | Municipality | 2010-2024 |
| Merit points (municipal schools) | N15505 | Municipality | 2010-2024 |
| Merit points (friskola) | N15506 | Municipality | 2010-2024 |
| SALSA deviation | U15416 | Municipality | 2010-2024 |

### Geographic Data (SCB Open Geodata)

| Data | Source | Format |
|------|--------|--------|
| DeSO boundaries | SCB | GeoPackage |
| DeSO centroids | Derived | Points |
| Municipal boundaries | SCB | GeoPackage |

### School Location Data

| Data | Source | Method |
|------|--------|--------|
| School addresses | Skolenhetsregistret API | JSON |
| School coordinates | OpenStreetMap OR geocoding | GeoJSON |

### Neighborhood Demographics (SCB API)

| Variable | Level | Years |
|----------|-------|-------|
| Income distribution | DeSO | 2018-2024 |
| Education level | DeSO | 2018-2024 |
| Immigration status | DeSO | 2018-2024 |
| Age structure | DeSO | 2018-2024 |

### Policy Data (Manual Collection)

| Data | Source | Method |
|------|--------|--------|
| Skolskjuts distance thresholds | Municipal websites | Web scraping / manual |
| Threshold by grade level | Municipal regulations | Manual coding |

## Planned Robustness Checks

1. **Bandwidth sensitivity:** Report results for multiple bandwidth choices around optimal
2. **Polynomial order:** Linear, quadratic, and local-linear specifications
3. **Donut RDD:** Exclude observations very close to threshold (address measurement error)
4. **Placebo thresholds:** Test for discontinuities at non-threshold distances
5. **Border discontinuity:** Compare DeSOs on opposite sides of municipal borders with different thresholds
6. **Pre-treatment balance:** Test for discontinuities in pre-determined characteristics
7. **Manipulation test:** Density test (McCrary 2008) for bunching at threshold

## Figures and Tables Plan

### Main Figures
1. **RDD plot:** Outcome vs distance with regression fit, showing discontinuity
2. **Map:** Sweden showing municipal threshold variation (2km vs 3km)
3. **Heterogeneity:** RDD estimates by neighborhood SES quintile

### Main Tables
1. **Summary statistics:** DeSO characteristics by above/below threshold
2. **Balance table:** Pre-determined characteristics at threshold
3. **Main results:** RDD estimates for primary outcomes
4. **Robustness:** Bandwidth and specification sensitivity

### Appendix
- Manipulation test results
- Placebo threshold tests
- Full municipality-level estimates
- Data construction details

## Timeline and Milestones

1. **Data collection:** Fetch Kolada, SCB, Skolenhetsregistret data
2. **Geocoding:** Construct school coordinates via OSM/HERE geocoding
3. **Policy mapping:** Collect municipal skolskjuts thresholds
4. **Distance calculation:** Compute DeSO-to-school distances
5. **Analysis:** Estimate RDD models
6. **Writing:** Draft paper with visualizations

## Known Limitations

1. **Aggregate data:** DeSO-level analysis (not individual students) limits precision
2. **Outcome timing:** Merit points measured at grade 9, but treatment (skolskjuts) varies by grade level
3. **Threshold heterogeneity:** Some municipalities have complex eligibility rules beyond simple distance
4. **School supply endogeneity:** School locations may respond to demand (long-run concern)
