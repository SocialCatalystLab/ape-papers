# Initial Research Plan: Cantonal Energy Laws and Federal Referendum Voting

## Research Question

Do cantonal energy law reforms affect municipal voting patterns on federal energy referendums? Specifically, did Swiss municipalities in cantons that had adopted comprehensive energy legislation prior to May 2017 show higher support for the federal Energy Strategy 2050 (Energiegesetz) referendum?

## Identification Strategy

**Spatial Regression Discontinuity Design (RDD)**

We exploit the sharp geographic boundary between cantons with different energy law adoption timing. The key identifying assumption is that municipalities on either side of a canton border are similar in all relevant respects except for cantonal policy exposure.

**Running variable:** Signed distance from municipality centroid to nearest canton border
- Positive values = "treated" side (canton with energy law adopted before May 2017)
- Negative values = "control" side (canton without prior energy law)

**Treatment definition:** Municipality located in a canton that adopted comprehensive energy legislation before the May 21, 2017 federal referendum:
- Treated cantons: GR (2010), BE (2011), AG (2012), BL (2016), BS (2016)
- Control cantons: All others (including LU, FR, AI which adopted later)

**Border pairs for analysis:**
1. AG-ZH (Aargau vs Zürich)
2. AG-SO (Aargau vs Solothurn)
3. BE-JU (Bern vs Jura)
4. BE-NE (Bern vs Neuchâtel)
5. BE-FR (Bern vs Fribourg) — note: FR adopted in 2019
6. BL-SO (Basel-Landschaft vs Solothurn)
7. GR-SG (Graubünden vs St. Gallen)
8. GR-TI (Graubünden vs Ticino)

## Expected Effects and Mechanisms

**Primary hypothesis:** Municipalities in treated cantons show 2-5 percentage points higher "Yes" vote share on the Energy Strategy 2050 referendum.

**Mechanisms:**
1. **Information/learning:** Residents in treated cantons have more experience with energy policy implementation, reducing uncertainty about federal proposals
2. **Attitude priming:** Exposure to cantonal energy messaging shifts preferences toward pro-environmental positions
3. **Demonstrated feasibility:** Seeing cantonal policy function reduces perceived costs of federal action
4. **Partisan cue consistency:** Cantonal governments that adopted energy laws signal alignment with federal proposal

**Heterogeneity predictions:**
- Effects may be larger near urban centers (higher policy awareness)
- Effects may vary by language region (different media exposure)
- Effects may be stronger at borders with larger treatment "dosage" (earlier adoption)

## Primary Specification

Using the `rdrobust` package in R:

```r
# Main RDD specification
rd_main <- rdrobust(
  y = gemeinde_data$yes_share,      # Outcome: % voting "Yes"
  x = gemeinde_data$signed_distance, # Running var: distance to border
  c = 0,                            # Cutoff at border
  cluster = gemeinde_data$border_pair, # Cluster by border pair
  covs = cbind(elevation, population, language_region)
)
```

**Outcome variable:** Yes vote share (%) on the May 21, 2017 Energy Strategy 2050 referendum

**Sample:** All municipalities within optimal bandwidth of treated canton borders

## Planned Robustness Checks

### Required (per GPT review)

1. **Placebo outcomes:** Run RDD on earlier environmental referendums (pre-treatment):
   - 2000 Energy levy referendum
   - 2008 Anti-nuclear initiative
   - Green party vote shares

2. **Border-pair heterogeneity:** Estimate separately by each border pair; report pooled estimate only if effects are coherent across borders

3. **Spatial RDD diagnostics:**
   - Donut RDD (exclude municipalities within 1km of border)
   - Bandwidth sensitivity (0.5×, 0.75×, 1.25×, 1.5× optimal)
   - Covariate balance at cutoff
   - Border-segment fixed effects

### Additional robustness

4. **Manipulation tests:** McCrary density test at the cutoff (should show no bunching)

5. **Alternative specifications:**
   - Local linear vs local quadratic polynomial
   - Different kernel weights (triangular, uniform, epanechnikov)

6. **Turnout analysis:** Check if treatment affects turnout (extensive margin) vs vote choice (intensive margin)

7. **Geographic controls:**
   - Elevation and terrain ruggedness
   - Distance to nearest city
   - Population density

## Data Requirements

| Data | Source | Granularity | Notes |
|------|--------|-------------|-------|
| Referendum results | swissdd R package | Municipality | Vote ID 612 (May 2017) |
| Municipality boundaries | BFS R package | Polygons | `bfs_get_base_maps()` |
| Canton boundaries | BFS R package | Polygons | For border identification |
| Municipality mergers | SMMT R package | Mapping | 2000-2017 concordance |
| Population/demographics | BFS PXWeb | Municipality | Control variables |
| Elevation | swisstopo | Municipality | Geographic control |

## Analysis Timeline

1. **Data acquisition:** Fetch referendum results, geographic boundaries, merge datasets
2. **Border identification:** Compute municipality centroids, identify border-adjacent pairs
3. **Running variable construction:** Calculate signed distance to nearest border
4. **Main analysis:** Run primary RDD specification
5. **Robustness:** Placebo tests, bandwidth sensitivity, covariate balance
6. **Visualization:** RDD plots, maps, event study style figures

## Power Considerations

- ~2,100 Swiss municipalities in 2017
- Border-adjacent municipalities (within 20km): ~600-800
- Expected treatment effect: 2-5 percentage points
- Standard deviation of yes share: ~15 percentage points
- With optimal bandwidth RDD: should have adequate power for 3+ pp effect

## Limitations

1. **Selection into cantonal adoption:** Cantons that adopted energy laws early may be systematically "greener" — this is why placebo tests on pre-treatment referenda are critical

2. **Bundled treatments:** Energy laws include multiple provisions (subsidies, mandates, building codes) — cannot isolate which component drives effects

3. **Single referendum:** Results based on one federal vote — generalizability to other policy domains uncertain

4. **No individual-level data:** Municipality-level analysis cannot identify individual-level mechanisms

## Contribution

This paper makes three contributions to the literature on policy feedback and federalism:

1. **Methodology:** Demonstrates spatial RDD as a credible identification strategy for policy feedback effects in multi-level federal systems

2. **Substantive:** Provides first causal evidence on how cantonal policy experience shapes federal voting preferences in Switzerland

3. **Policy relevance:** Informs debates about policy sequencing and bottom-up federalism in environmental policy
