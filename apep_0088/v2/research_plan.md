# Working Research Plan

## Inherited from Parent (apep_0133), Updated for Revision

### Research Question
Does sub-national climate policy experimentation generate political support for federal harmonization?

### Identification
Spatial RDD at Swiss canton borders. Primary specification: same-language (German-German) borders only.

### Data
- Referendum results: BFS via swissdd R package (2,120 Gemeinden)
- Spatial data: BFS municipality boundaries with SMMT correspondence tables
- Treatment: 5 cantons with comprehensive MuKEn laws before May 2017

### Exposure Alignment
- **Who is treated:** Gemeinden in 5 cantons (AG, BE, BL, BS, GR) that adopted comprehensive MuKEn energy laws before May 2017
- **Primary estimand population:** Voters in treated-canton Gemeinden near canton borders (within MSE-optimal bandwidth ~3.2km)
- **Control population:** Voters in neighboring control-canton Gemeinden on the opposite side of the same border
- **Design:** Spatial RDD (cross-sectional) + Difference-in-Discontinuities (panel)

### Key Results
- Same-language RDD: -5.91 pp (SE=2.32, p=0.011, BW=3.2km, N=862)
- Pooled RDD: -4.49 pp (SE=2.32, p=0.053, BW=3.7km, N=1278)
- DiDisc with border-pair FE: -4.65 pp (SE=1.76, p=0.008, N=5259)
- OLS with language controls: -1.80 pp (SE=1.93, p=0.35, N=2120)

### Revision Focus (This Round)
1. Rewrite abstract and introduction (Shleifer prose standards)
2. Add conceptual framework with H1/H2 predictions
3. Fix DiDisc staggered treatment coding
4. Interpret treated-side border dip pattern
5. Polish prose throughout
6. Sharpen discussion and conclusion
