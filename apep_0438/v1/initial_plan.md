# Initial Research Plan

## Title
Secret Ballots and Women's Political Voice: Evidence from the Swiss Landsgemeinde

## Research Question
Does the format of democratic participation affect women's political engagement? We exploit the staggered abolition of the Landsgemeinde — Switzerland's centuries-old open-air assembly where citizens vote by raising hands — to estimate how public vs. secret ballot voting shapes voting patterns on gender-related policy.

## Institutional Context

### The Landsgemeinde
The Landsgemeinde is one of the oldest democratic institutions in the world, dating to the 1200s. Citizens gather in a public square on a designated day and vote on cantonal matters by show of hands. Key features:
- **Public, non-secret voting** — everyone can see how you vote
- **Physical presence required** — must be in the square
- **Historically male-dominated** — women were excluded until 1971 (federal mandate) and 1990 (Appenzell Innerrhoden, forced by Supreme Court)
- **Social pressure** — conformity incentives in small communities

### Abolition Timeline
| Canton | Status | Year |
|--------|--------|------|
| Nidwalden (NW) | Abolished | 1996 |
| Appenzell Ausserrhoden (AR) | Abolished | 1997 |
| Obwalden (OW) | Abolished | 1998 |
| Glarus (GL) | **Still active** | — |
| Appenzell Innerrhoden (AI) | **Still active** | — |

### Why Gender?
The Landsgemeinde was a physically male space for centuries. Even after formal women's suffrage:
1. Public voting creates social pressure that may disproportionately suppress dissenting women's voices
2. Physical presence requirement disadvantages primary caregivers (predominantly women)
3. Male-dominated assembly culture signals politics as a "male domain"
4. Show-of-hands voting prevents women from supporting gender-progressive policies without social cost

## Identification Strategy

### Primary Design: Difference-in-Discontinuities (DiDisc) at the AR–AI Border

The AR–AI border pair is the cleanest test:
- **Before 1997:** Both cantons had Landsgemeinde → NO discontinuity at the border (both had same institution for federal votes, same cultural background)
- **After 1997:** AR abolished Landsgemeinde → any EMERGING discontinuity at the border identifies the effect of the institution
- This differences out permanent cross-border differences

**Running variable:** Signed distance from Gemeinde centroid to the AR–AI canton boundary (positive = AR/abolished side)

### Secondary: Cross-Sectional Spatial RDD at Multiple Borders
Pool border pairs where one side has/had Landsgemeinde and the other never did:
- **AI ↔ SG:** Landsgemeinde vs. ballot (contemporary)
- **GL ↔ SG:** Landsgemeinde vs. ballot (contemporary, pre-2011 when GL had 25 Gemeinden)
- **OW ↔ LU:** Abolished 1998 vs. never had
- **NW ↔ LU:** Abolished 1996 vs. never had

### Inference Strategy (addressing few-cluster concern)
- **Primary:** Permutation inference — randomize treatment assignment across border pairs and re-estimate
- **Secondary:** Spatial HAC / Conley standard errors (correct for spatial correlation without clustering at canton)
- **Tertiary:** Wild cluster bootstrap at canton level (conservative, wide CIs expected)

### Pre-Trends Validation (CRITICAL)
Use pre-1997 federal referendums at the AR–AI border to verify NO discontinuity before abolition:
- 1981–1996: multiple referendums should show NO significant discontinuity at border
- Event-study plot: estimated border discontinuity by year, expect null before 1997 and emerging effect after

## Expected Effects and Mechanisms

### Predictions
1. **Turnout:** Ambiguous. Funk (2010) shows social pressure increases turnout. Landsgemeinde cantons may have higher turnout due to social pressure, but this may fall after abolition when social incentive is removed.
2. **Gender referendum voting:** Gemeinden in cantons that abolished Landsgemeinde should vote MORE PROGRESSIVELY on gender-related referendums compared to Gemeinden across the border in cantons that kept Landsgemeinde.
3. **Placebo:** No discontinuity on NON-gender referendums (military, infrastructure, tax votes) — the Landsgemeinde effect should be specific to issues where gender preferences diverge.

### Key Gender-Related Federal Referendums
| Date | Topic | National Result |
|------|-------|-----------------|
| 2002-06-02 | Abortion liberalization (Fristenregelung) | Passed 72.2% |
| 2003-02-09 | Maternity insurance (rejected) | Rejected 61.8% |
| 2004-09-26 | Maternity insurance (passed) | Passed 55.4% |
| 2020-09-27 | Paternity leave | Passed 60.3% |
| 2021-09-26 | Marriage for all | Passed 64.1% |

### Placebo Referendums (gender-neutral)
Military spending, tax reform, infrastructure — expect NO border discontinuity

## Primary Specification

### Model (DiDisc at AR–AI border):
y_{it} = α + β₁ · Abolished_i + β₂ · Post_t + β₃ · (Abolished_i × Post_t) + f(distance_i) + ε_{it}

Where:
- y_{it} = yes-share (or turnout) in Gemeinde i for referendum t
- Abolished_i = 1 if Gemeinde is in AR (abolished 1997), 0 if in AI
- Post_t = 1 if referendum date ≥ 1997
- distance_i = signed distance to AR–AI border
- f(·) = local polynomial (linear or quadratic), allowed to differ on each side

### RDD Specification (cross-sectional at border):
y_i = α + τ · Treated_i + f(distance_i) + X_i'γ + ε_i

Where:
- Treated_i = 1 if Gemeinde is on the non-Landsgemeinde side
- bandwidth selected via MSE-optimal (Calonico, Cattaneo, Titiunik 2014)

## Power Assessment
- **Gemeinden near AR–AI border:** ~26 (AR: 20, AI: 6)
- **Panel dimension:** ~150+ federal referendums (1981–2024)
- **Effective observations:** ~3,900+ for AR–AI DiDisc
- **Additional border pairs (pooled):** ~50–80 more Gemeinden
- **Pre-2011 GL data:** 25 Gemeinden (before mega-merger)
- **Gender referendums:** ~15–20 → ~500 observations for gender-specific analysis

## Planned Robustness Checks
1. Bandwidth sensitivity (half, double MSE-optimal)
2. Donut RDD (exclude Gemeinden < 1km from border)
3. McCrary density test (municipality locations are fixed — should trivially pass)
4. Covariate balance at border (population, language, urbanity)
5. Placebo borders (shift border randomly, expect null)
6. Pre-1997 event study at AR–AI border (must show null)
7. Same-language border restriction (all borders here are German-German ✓)
8. Different polynomial orders (linear, quadratic, cubic)
9. Gender vs. non-gender referendum heterogeneity (placebo test)
10. Individual border pair estimates (not just pooled)

## Data Sources
- **Voting:** swissdd R package (Gemeinde-level federal referendum results, 1981–2024)
- **Spatial:** BFS R package (Gemeinde boundaries/polygons)
- **Mergers:** SMMT R package (municipality mutation mapping)
- **Covariates:** BFS PXWeb API (population, demographics by Gemeinde)
- **Treatment coding:** Hand-coded from Wikipedia + official cantonal records
