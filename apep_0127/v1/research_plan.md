# Research Plan: Car Ownership, Housing Tenure, and Educational Achievement in Swedish Municipalities

## Updated Research Question

**Primary Question:** How do car ownership and housing tenure patterns relate to educational achievement across Swedish municipalities?

**Motivation:** In the context of Swedish school choice and transport policy (skolskjuts), families' transportation resources and housing stability may systematically affect their ability to exercise school choice and support educational achievement. This paper examines the relationship between:
1. Car ownership (proxy for transport accessibility)
2. Housing tenure (rental vs. owner-occupied, proxy for residential stability)
3. Educational outcomes (merit points at grade 9)

## Theoretical Framework

### Economic Theory Predictions

**Car Ownership Channel:**
- Higher car ownership → greater mobility → more school choice options
- But: Low car ownership correlates with urbanity → better public transit → more school options
- Prediction: Ambiguous sign; urban areas (low car) may have better outcomes due to school density

**Housing Tenure Channel:**
- Owner-occupied housing → residential stability → better school outcomes
- But: Rental markets → mobility → ability to move near good schools
- Cooperative housing (bostadsrätt) → wealth and stability → better outcomes
- Prediction: Owner/coop dominant municipalities may have higher achievement

**Interaction Effects:**
- Low car + high rental = urban poor, potentially disadvantaged
- Low car + high owner/coop = urban middle class, well-served by transit
- High car + high owner = suburban/rural wealthy, may send kids to distant good schools

## Identification Strategy

### Descriptive Analysis
Given data limitations (cross-sectional municipal data), we employ a descriptive approach:
1. Correlational analysis of car ownership, housing tenure, and merit points
2. Conditional means across terciles of car ownership and housing tenure
3. Multivariate regression with municipality-level controls

### Regression Specification

$$MeritPoints_{m,t} = \alpha + \beta_1 \cdot CarsPer1000_{m,2013} + \beta_2 \cdot RentalShare_{m,2013} + X_{m,t}'\gamma + \epsilon_{m,t}$$

Where:
- $m$ indexes municipalities
- $t$ indexes years (2015, 2016)
- $X_{m,t}$ includes teacher qualifications, county fixed effects

### Limitations
- No causal identification: Observational cross-sectional data
- Omitted variables: Wealth, urbanity, school quality unobserved at municipality level
- Aggregation: Municipality-level analysis masks within-municipality heterogeneity

## Data Sources

| Variable | Source | Years | N municipalities |
|----------|--------|-------|------------------|
| Merit points (grade 9) | Kolada N15566 | 2015-2016 | 290 |
| Teacher qualifications | Kolada N15030 | 2015-2016 | 290 |
| Cars per 1000 inhabitants | Kolada N07935 | 2013 | 290 |
| Rental housing share | Kolada N07956 | 2013 | 290 |
| Owner-occupied share | Kolada N07958 | 2013 | 290 |
| Cooperative housing share | Kolada N07957 | 2013 | 290 |

## Expected Findings

Based on preliminary data exploration:
1. Low car ownership municipalities (urban) have higher mean merit points
2. Cooperative-dominant municipalities have highest merit points
3. Teacher qualifications are positively correlated with merit points

## Figures and Tables

1. **Figure 1:** Map of Sweden showing car ownership variation
2. **Figure 2:** Scatter plot: Car ownership vs. merit points
3. **Figure 3:** Merit points by housing tenure type
4. **Table 1:** Summary statistics
5. **Table 2:** Correlations
6. **Table 3:** Regression results

## Contribution

1. First analysis linking car ownership patterns to educational outcomes in Sweden
2. Documents urban-rural disparities in educational achievement
3. Provides descriptive evidence relevant to school transport policy debates
