# Initial Research Plan: The Border Discontinuity in Cannabis Access and Traffic Safety

## Research Question

Does geographic access to legal cannabis reduce alcohol-involved fatal traffic crashes? We exploit the sharp discontinuity in legal access at state borders using Spatial Regression Discontinuity Design.

## Identification Strategy

### Design: Spatial RDD at State Borders

The treatment is legal cannabis access. The running variable is **signed distance to the nearest legal-state border**:
- Negative values = inside legal state (treated)
- Positive values = inside prohibition state (control)
- Zero = at the border (discontinuity)

### Estimand

$$\tau_{RDD} = \lim_{d \to 0^+} E[AlcoholInvolved | Distance = d] - \lim_{d \to 0^-} E[AlcoholInvolved | Distance = d]$$

We expect $\tau < 0$: crashes just inside the legal state have lower alcohol involvement.

### Key Assumption: Continuity

Potential outcomes (crash characteristics absent treatment) are continuous across the border. This is plausible because:
1. Crash locations are not manipulated (crashes are quasi-random events)
2. Populations on either side of the border are similar
3. Road characteristics are continuous
4. Economic conditions are similar

## Expected Effects and Mechanisms

### Main Effect
Alcohol involvement rate should drop discontinuously when crossing from prohibition to legal state. The magnitude depends on substitution elasticity and local demand.

### Mechanisms to Test

1. **Time of Day:** Effects should be stronger at night (recreational use hours)
2. **Age:** Effects should be stronger for ages 21-45; null for 65+
3. **Distance Gradient:** The jump at the border should be sharpest; effects may attenuate with distance

### Potential Null Result

A null result would be informative. It could indicate:
- No substitution at the extensive margin (same people, different substance)
- Substitution exists but doesn't affect driving behavior
- Cross-border purchasing is insufficient to shift behavior

## Primary Specification

### Outcome Variable
$Y_i$ = 1 if crash $i$ involves any alcohol-impaired driver (DRUNK_DR >= 1)

### Running Variable
$X_i$ = signed perpendicular distance to nearest legal-state border (km)
- Computed using great-circle distance to nearest point on border polyline
- Positive = prohibition state, Negative = legal state

### Estimation
Local polynomial regression with optimal bandwidth selection (Imbens-Kalyanaraman or Calonico-Cattaneo-Titiunik):

$$Y_i = \alpha + \tau \cdot \mathbb{I}(X_i < 0) + f(X_i) + \epsilon_i$$

where $f(X_i)$ is a polynomial (linear or quadratic) allowed to differ on each side of the cutoff.

### Bandwidth Selection
- MSE-optimal bandwidth (rdrobust default)
- Report sensitivity to alternative bandwidths (0.5x, 2x optimal)

## Planned Robustness Checks

1. **Bandwidth sensitivity:** 50%, 100%, 200% of optimal
2. **Polynomial order:** Linear vs. quadratic local regression
3. **Kernel choice:** Triangular, uniform, Epanechnikov
4. **Placebo cutoffs:** Fake borders at various distances
5. **Donut RDD:** Exclude observations very close to border (manipulation check)
6. **Covariate balance:** Test smoothness of covariates at cutoff

## Visual Evidence Plan

### Maps (Building Context)
1. **Study Region Map:** Legal/illegal states with borders highlighted
2. **Crash Density Map:** Heat map of crashes near borders
3. **Road Network Map:** Major roads crossing borders
4. **Dispensary Map:** Licensed dispensaries near borders

### Scatter Plots (Raw Patterns)
5. **Raw Scatter:** Alcohol involvement vs. distance, colored by legal status
6. **Loess/Lowess:** Non-parametric regression through raw data
7. **Binned Scatter:** Standard RDD binned scatter plot

### RDD Plots (Formal Evidence)
8. **Main RDD Plot:** Local polynomial with 95% CI bands
9. **Mechanism Plots:** Separate by time of day, age group
10. **Robustness Plots:** Different bandwidths, polynomial orders

## Data Requirements

### FARS (Crash Data)
- States: ID, WY, NE, KS, UT, AZ, MT, NM (prohibition) + CO, OR, WA, NV, CA (legal)
- Years: 2016-2019
- Variables: lat/lon, DRUNK_DR, hour, driver age, state

### TIGER/Line (Geography)
- State boundary shapefiles
- Used to compute distance to border

### OpenStreetMap (Context)
- Dispensary locations (shop=cannabis)
- Road network for maps
