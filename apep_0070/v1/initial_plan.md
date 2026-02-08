# Initial Research Plan

## Title
Childcare Mandates and Maternal Labor Supply: A Spatial Regression Discontinuity at Swiss Canton Borders

## Research Question
Does mandatory provision of after-school childcare increase maternal labor force participation? We exploit the 2010 Bern/Zurich childcare mandate to examine effects at canton borders where treatment status changes discontinuously.

## Institutional Context

### The 2010 Childcare Mandate
In 2010, the cantons of Bern and Zurich amended their Volksschulgesetz (compulsory education law) to require:
1. Annual municipal surveys of parental demand for after-school care (Tagesbetreuung/Tagesschule)
2. Mandatory provision of lunchtime and afternoon care if ≥10 children sign up for any time slot
3. Care facilities certified by cantonal school authority (minimum 1 caretaker per 10 children)
4. Fee structure graduated by parental income

**Later adopters:** Basel-Stadt, Graubünden, Lucerne, Neuchâtel, Schaffhausen (2014-2016)
**Non-adopters (as of 2017):** Aargau, Solothurn, St. Gallen, Thurgau, Uri, Schwyz, Zug

### Why This Matters for Gender Gaps
Switzerland has one of the highest maternal part-time rates in Europe (~80% of working mothers) but also one of the highest childcare costs (75% of second-earner wage goes to childcare + taxes). The male breadwinner model remains culturally dominant, especially in German-speaking cantons. After-school care availability is a binding constraint for mothers seeking full-time employment.

## Identification Strategy

### Primary Design: Spatial RDD at Canton Borders
- **Treatment:** Gemeinden in cantons with childcare mandates (BE, ZH post-2010)
- **Control:** Gemeinden in adjacent cantons without mandates (SO, AG, SG, TG)
- **Running variable:** Signed distance to nearest treated-control canton border (positive = treated side)
- **Cutoff:** c = 0 (the canton border)

### Same-Language Borders (Avoids Röstigraben Confound)
Per APEP-0088 methodology, we restrict to German-German borders:
- **BE-SO:** Bern (treated 2010) vs Solothurn (control)
- **ZH-AG:** Zurich (treated 2010) vs Aargau (control)
- **ZH-SG:** Zurich (treated 2010) vs St. Gallen (control)
- **ZH-TG:** Zurich (treated 2010) vs Thurgau (control)

French-speaking borders (BE-FR, BE-NE, BE-JU) are excluded to avoid language confounding.

### Addressing GPT-5.2 Concerns

**1. Outcome Dilution**
- Primary outcome: Employment rate for women aged 25-44 (prime childbearing years)
- If available: Employment rate for mothers of school-age children (ages 4-12)
- Robustness: Part-time (50%+ FTE) vs marginal part-time (<50% FTE) breakdown

**2. Treatment Intensity (Fuzzy Treatment)**
- Collect/construct cantonal childcare capacity measures (slots per child)
- Use mandate indicator as instrument for actual childcare availability
- Report both sharp RDD (mandate) and fuzzy RDD (capacity) if data permit

**3. Pre-Trend Validation**
- Test for discontinuity at borders using pre-2010 female employment (2006-2009)
- McCrary density test: municipality locations are fixed, should be no bunching
- Covariate balance: test discontinuity in population, income, urban/rural at border

## Data Sources

### Outcome Data
- **BFS STATPOP:** Population by employment status, sex, age, Gemeinde (2006-present)
- **BFS Employment Statistics:** Erwerbstätige by Gemeinde, sex, sector
- **swissdd:** Family policy referendum votes for attitude pre-trends

### Spatial Data
- **BFS bfs_get_base_maps():** Municipal boundaries for distance calculation
- **SMMT package:** Municipality mergers for panel consistency

### Policy Timing
- **LexFind:** Cantonal Volksschulgesetz texts and amendment dates
- **HuggingFace swiss_legislation:** Pre-scraped cantonal law database

## Specifications

### Primary Specification
Local linear regression with triangular kernel, MSE-optimal bandwidth:
```
Y_i = α + τ·1{d_i ≥ 0} + β_1·d_i + β_2·d_i·1{d_i ≥ 0} + ε_i
```
Where Y_i is female employment rate in Gemeinde i, d_i is signed distance to border.

### Five RDD Specifications (following APEP-0088)
1. Pooled, MSE-optimal bandwidth
2. Same-language borders only (preferred)
3. Half bandwidth
4. Double bandwidth
5. Local quadratic polynomial

### Robustness Checks
- McCrary density test
- Covariate balance at border
- Donut RDD (exclude 0.5-2km from border)
- Bandwidth sensitivity plot (1-10km sweep)
- Border-pair heterogeneity (forest plot)
- Randomization inference (permute canton treatment)
- Panel pre-trends (2006-2009 vs 2010-2016)

## Expected Results

**Hypothesis:** The childcare mandate increases maternal labor force participation at the border. Effect size likely 2-5 percentage points based on Felfe et al. (2016) DiD estimates.

**Possible findings:**
- H1: Positive effect on female employment (policy feedback)
- H0: Null effect (mandate too conditional/heterogeneous)
- H2: Effect on intensive margin (part-time → full-time) but not extensive margin

## Timeline

1. Data acquisition and cleaning (fetch BFS, construct borders)
2. Descriptive statistics and maps (5 maps per APEP-0088)
3. Main RDD estimation (5 specifications)
4. Robustness battery
5. Paper writing
6. Review and revision

## Key References

- Felfe, C., Lechner, M., & Thiemann, P. (2016). After-school care and parents' labor supply. *Labour Economics*, 42, 64-75.
- Ravazzini, L. (2018). Childcare and maternal part-time employment: a natural experiment using Swiss cantons. *Swiss Journal of Economics and Statistics*, 154(1), 1-16.
- Keele, L., & Titiunik, R. (2015). Geographic boundaries as regression discontinuities. *Political Analysis*, 23(1), 127-155.
- Cattaneo, M. D., Idrobo, N., & Titiunik, R. (2020). *A practical introduction to regression discontinuity designs*. Cambridge University Press.
