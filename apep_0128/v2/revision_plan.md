# Revision Plan: apep_0128 → Nuclear Rebuild

## Parent Paper
- **ID:** apep_0128
- **Title:** Environmental Regulation and Housing Markets: Evidence from the Dutch Nitrogen Crisis Using Synthetic Control Methods
- **Rating:** 22.4 (4W-18L-5T)
- **Integrity:** CLEAN scan, not replicated

## Why Revision Is Needed

The parent paper has a fundamentally flawed empirical strategy:
1. **N=1 national SCM with p=0.69** — statistically meaningless
2. **COVID confounding** — pre-COVID effect is 0.58 (full-sample ATT is 4.52)
3. **Donor fragility** — dropping Spain reverses the sign
4. **No mechanism evidence** — claims supply constraints but never shows permits/construction data
5. **Thin execution** — 925 lines of LaTeX, missing modern SCM literature

## Revision Strategy: Four-Pronged Sub-National Design

### 1. PRIMARY: Municipality-Level DiD
- Treatment: N2000 share of municipality area (continuous, from GIS)
- Outcome: log average purchase price (CBS 83625ENG, annual)
- ~350 municipalities, 2012-2024
- Municipality + year FEs (year FEs absorb COVID)
- Pre-COVID main spec (2012-2019), full-sample robustness

### 2. FIRST STAGE: Building Permits
- CBS 83671NED, quarterly, municipality level
- Show sharp differential permit decline in Q3 2019 for high-N2000 municipalities
- Event study with quarterly leads/lags

### 3. COMPLEMENT: Augmented SCM + SDID
- Upgrade national analysis to augmented SCM (Ben-Michael et al. 2021)
- Conformal inference for proper p-values
- SDID (Arkhangelsky et al. 2021)

### 4. SPATIAL RDD (if feasible)
- rdrobust at N2000 boundary
- Include if N > 50 within optimal bandwidth

## Data Sources
- CBS 83625ENG: housing prices by municipality (annual)
- CBS 83671NED: building permits by municipality (quarterly)
- CBS 85819ENG: COROP price indices (quarterly)
- CBS 81955ENG: dwelling stock changes (annual)
- EEA: Natura 2000 GIS shapefiles
- PDOK/CBS: municipality boundary shapefiles
- BIS/FRED: national HPI for 16 European countries

## Target
- 30+ pages main text, 10 figures, 8 tables
- All 4 advisors PASS
- 3 external reviews
- Rating: 27+ (from 22.4)
