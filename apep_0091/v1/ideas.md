# Research Ideas: Cannabis Dispensary Access and Traffic Safety

## Selected Idea: The Border Discontinuity in Substance Substitution

### Research Question

Does geographic access to legal cannabis dispensaries reduce alcohol-involved fatal traffic crashes? We exploit the sharp discontinuity in legal access at state borders to identify causal effects using Spatial Regression Discontinuity Design (SpatialRDD).

---

## Conceptual Framework: A Behavioral Model of Substance Substitution

### The Economic Model

Consider a representative agent who derives utility from recreational intoxication. The agent faces a discrete choice between two intoxicants: alcohol (A) and cannabis (C). Both provide hedonic utility but impose costs including health risks, legal risks, and impairment-related dangers.

**Utility from Intoxication:**

$$U = \max\{U_A(a) - c_A, U_C(c) - c_C, 0\}$$

where:
- $U_A(a)$ = utility from alcohol consumption level $a$
- $U_C(c)$ = utility from cannabis consumption level $c$
- $c_A$ = total cost of alcohol (monetary + time + legal risk + impairment risk)
- $c_C$ = total cost of cannabis (monetary + time + legal risk + impairment risk)

**The Key Insight: Geographic Discontinuity in Costs**

In a prohibition state near a legal border:
- $c_A$ is roughly constant across geography (alcohol is locally available everywhere)
- $c_C$ varies sharply with distance to the nearest legal dispensary

For a crash location at distance $d$ from the legal border:
$$c_C(d) = p_{retail} + \tau \cdot t(d) + \lambda \cdot \mathbb{I}(d > 0)$$

where:
- $p_{retail}$ = dispensary retail price
- $\tau$ = opportunity cost of time per minute
- $t(d)$ = round-trip travel time as function of distance
- $\lambda$ = legal risk of transporting cannabis across state lines (applies when $d > 0$, i.e., in the prohibition state)

**The Discontinuity:**

At the border ($d = 0$), residents on the legal side face:
$$c_C^{legal} = p_{retail}$$

while residents just across the border (prohibition side) face:
$$c_C^{prohibition} = p_{retail} + \tau \cdot t(\epsilon) + \lambda > c_C^{legal}$$

This creates a **sharp discontinuity** in the relative price of cannabis vs. alcohol at the state border.

### Behavioral Predictions

**Prediction 1 (Main Effect):**
If cannabis and alcohol are substitutes, lower cannabis access costs lead to higher cannabis use and lower alcohol use. Crashes on the prohibition side of the border should have higher alcohol involvement rates than crashes on the legal side.

**Prediction 2 (Local Average Treatment Effect):**
The LATE at the border captures the causal effect of legal cannabis access on crash composition for the "compliers" - marginal substance users who would substitute.

**Prediction 3 (Mechanism - Time of Day):**
Effects should concentrate at night (9pm-5am) when recreational substance use peaks. Daytime crashes serve as a placebo.

**Prediction 4 (Mechanism - Demographics):**
Effects should be stronger for ages 21-45 (prime recreational users) than for elderly drivers (65+), who rarely engage in cross-border cannabis purchasing.

**Prediction 5 (Mechanism - Distance Gradient):**
Effects should decay with distance from the border as travel costs rise, but the *discontinuity at zero* should remain sharp.

---

## Identification Strategy: Spatial RDD

### The Running Variable

Distance from crash location to the nearest legal-state border, with positive values on the prohibition side and negative values on the legal side.

$$X_i = \text{signed distance to border}$$

- $X_i < 0$: Legal state (treatment = 1)
- $X_i > 0$: Prohibition state (treatment = 0)
- $X_i = 0$: The border (discontinuity)

### The Estimand

$$\tau_{LATE} = \lim_{x \to 0^+} E[Y_i | X_i = x] - \lim_{x \to 0^-} E[Y_i | X_i = x]$$

where $Y_i$ = indicator for alcohol involvement in crash $i$.

We expect $\tau_{LATE} < 0$: crashes just inside the legal state have *lower* alcohol involvement than crashes just inside the prohibition state.

### Key Assumptions

1. **No manipulation:** Crash locations are not manipulated around the border. Traffic crashes are quasi-random events - drivers don't choose where to crash.

2. **Continuity:** Potential outcomes are continuous in distance to the border. Absent the treatment (legal cannabis access), crash characteristics would evolve smoothly across the border.

3. **Local randomization:** Near the border, treatment assignment is "as good as random" - units just inside vs. just outside the border are comparable except for treatment.

### Visual Evidence Strategy

1. **Map 1: Study Region** - Show legal/illegal states with state borders highlighted
2. **Map 2: Crash Density** - Heat map of crashes near borders
3. **Map 3: Road Network** - Show major roads crossing borders (potential crossing points)
4. **Map 4: Dispensary Locations** - Show dispensaries near borders

5. **Scatter Plot 1:** Alcohol involvement rate vs. distance to border (raw data with loess)
6. **Scatter Plot 2:** Binned scatter plot (standard RDD visualization)
7. **RDD Plot:** Local polynomial regression with confidence bands

8. **Mechanism Plots:** Separate RDD plots by time of day, age group, distance band

---

## Data Sources

### Crash Data: FARS (Fatality Analysis Reporting System)
- Source: NHTSA
- Years: 2016-2019
- Variables: Latitude/longitude, alcohol involvement (DRUNK_DR), time, driver age
- Scope: All fatal crashes in study states

### Border Geography: US Census TIGER/Line
- State boundary shapefiles
- County boundary shapefiles

### Dispensary Locations: OpenStreetMap
- Extract shop=cannabis features
- Focus on dispensaries near state borders

### Road Network: OpenStreetMap
- Major highways crossing borders
- Routing for visual presentation

---

## Study Region

### Border Pairs (Prohibition-Legal)

| Prohibition State | Legal State | Border Characteristics |
|-------------------|-------------|------------------------|
| Idaho | Oregon | Ontario, OR dispensaries serve ID |
| Idaho | Washington | Spokane area dispensaries |
| Wyoming | Colorado | I-25 corridor, Fort Collins area |
| Nebraska | Colorado | I-76/I-80 corridor |
| Kansas | Colorado | I-70 corridor, limited crossing |
| Utah | Nevada | Wendover border town |
| Arizona | Nevada | Laughlin/Bullhead City area |
| New Mexico | Colorado | Trinidad, Antonito |

### Primary Focus: Wyoming-Colorado Border

The Wyoming-Colorado border along I-25 offers ideal conditions:
- Heavy traffic corridor (Cheyenne-Fort Collins)
- Multiple dispensaries in northern Colorado
- Clear border crossing points
- Sufficient crash density for RDD

---

## Expected Contributions

1. **Methodological:** First application of Spatial RDD to cannabis-alcohol substitution
2. **Visual:** Rich graphical evidence building intuition before formal estimation
3. **Causal:** Clean identification at the border discontinuity
4. **Mechanisms:** Tests of behavioral predictions (time, age, distance)

---

## Feasibility Check

- **Variation:** Sharp discontinuity at state borders - CONFIRMED
- **Data access:** FARS is public, TIGER/Line is public, OSM is public - CONFIRMED
- **Sample size:** ~18,000 crashes in 8 states over 4 years; ~5,000+ within 100km of borders - CONFIRMED
- **Novelty:** No existing SpatialRDD paper on this topic - CONFIRMED
- **Even null results valuable:** A well-identified null would challenge substitution hypothesis - YES
