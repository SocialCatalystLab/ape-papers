# Initial Research Plan: MGNREGA and Structural Transformation

## Research Question

Did India's employment guarantee program (MGNREGA) accelerate or retard the structural transformation of rural labor markets — the shift of workers from agriculture to non-farm employment?

## Identification Strategy

**Design:** Staggered difference-in-differences exploiting MGNREGA's three-phase rollout.

- **Phase I (Feb 2006):** 200 most backward districts (treatment cohort 1)
- **Phase II (Apr 2007):** 130 additional districts (treatment cohort 2)
- **Phase III (Apr 2008):** All remaining ~310 rural districts (late treatment / control)

**Assignment mechanism:** Districts assigned to phases based on Planning Commission's composite "backwardness index" incorporating: agricultural wages, SC/ST population share, agricultural productivity, poverty rate. Phase I = most backward districts; Phase III = least backward. This creates potential selection bias that we address through:
1. CS-DiD estimator (Callaway & Sant'Anna 2021) using not-yet-treated as controls
2. Pre-treatment balance tests on nightlights 2000–2005
3. Pre-treatment balance on Census 2001 outcomes
4. Event study dynamics showing no differential pre-trends

**Estimator:** Callaway & Sant'Anna (2021) group-time ATTs with:
- Groups: Phase I (g=2006), Phase II (g=2007)
- Not-yet-treated as comparison units
- Dynamic event study aggregation
- Clustered SEs at district level (200+ clusters)

## Expected Effects and Mechanisms

**Mechanism 1 (Transformation hypothesis):** MGNREGA raised agricultural wages → increased cost of hired labor → incentivized mechanization → released surplus labor → workers shifted to non-farm employment (construction, services, household industry).

**Mechanism 2 (Retention hypothesis):** MGNREGA provided guaranteed rural employment → reduced distress migration → workers remained in agricultural labor rather than seeking non-farm work → structural transformation slowed.

**Expected direction:** Ambiguous ex ante. This is a genuine horse race between competing mechanisms, making either result publishable.

## Exposure Alignment

- **Who is treated:** Rural workers in districts receiving MGNREGA
- **Primary estimand population:** Rural working-age population in treated districts
- **Placebo/control population:** Phase III districts (not yet treated during 2006–2007)
- **Design:** Staggered DiD (not triple-diff)

## Power Assessment

- **Pre-treatment periods:** 6 years of nightlights (2000–2005); Census 2001
- **Treated clusters:** Phase I = 200 districts; Phase II = 130 districts
- **Post-treatment periods:** 8 years nightlights (2006–2013); Census 2011
- **Observations:** ~596,000 villages
- **MDE:** With 200+ treated clusters and 596K villages, power is very high. Even small effects (0.05 SD) should be detectable.

## Primary Specification

### Census DiD (long difference, 2001–2011)

$$\Delta Y_{v,2011-2001} = \alpha + \beta_1 \cdot \text{PhaseI}_d + \beta_2 \cdot \text{PhaseII}_d + X_{v,2001}'\gamma + \epsilon_v$$

Where $\Delta Y$ is the change in worker composition shares (non-farm share, agricultural labor share, etc.), PhaseI/II are district-level treatment indicators, and $X_{2001}$ are baseline controls. SEs clustered at district level.

### Nightlights CS-DiD (annual panel)

Using `did` R package with Callaway & Sant'Anna estimator:
- Unit: village (or district aggregation for computational feasibility)
- Time: year (2000–2013)
- Group: year of MGNREGA introduction (2006, 2007, 2008)
- Outcome: log(nightlights + 1)

## Planned Robustness Checks

1. **Pre-trends test:** Event study dynamics for nightlights 2000–2005
2. **Alternative estimators:** Sun & Abraham (2021), Borusyak et al. (2024)
3. **Placebo outcomes:** Outcomes that shouldn't respond to MGNREGA (e.g., total population)
4. **Dose-response:** Treatment intensity (person-days per capita from MGNREGA MIS)
5. **Heterogeneity:** By gender, by SC/ST share, by baseline agricultural labor share
6. **Spillovers:** Effect on non-treated neighboring districts
7. **Alternative clustering:** State-level clustering (28+ clusters)
8. **Randomization inference:** Permute district-phase assignment

## Data Sources

1. **SHRUG Census PCA** (2001, 2011): Worker composition by type × gender, literacy, population, SC/ST shares — ~596K villages
2. **SHRUG DMSP Nightlights** (1994–2013): Annual calibrated luminosity at village level — ~19M village-year observations
3. **SHRUG VIIRS Nightlights** (2012–2023): Annual luminosity at district level — post-period extension
4. **SHRUG Geographic Crosswalk** (pc11_td): Village → district → state mapping with amenities
5. **MGNREGA Phase Assignment**: District-to-phase mapping from Imbert & Papp (2015) replication data or government gazette notifications
6. **FRED**: State-level GDP and macro controls (if needed)

## Output Structure

```
output/apep_0434/v1/
├── code/
│   ├── 00_packages.R
│   ├── 01_fetch_data.R      (load SHRUG + construct MGNREGA phase)
│   ├── 02_clean_data.R      (merge, construct variables)
│   ├── 03_main_analysis.R   (CS-DiD, Census long-diff)
│   ├── 04_robustness.R      (pre-trends, placebos, alt estimators)
│   ├── 05_figures.R         (event study, maps, worker composition)
│   └── 06_tables.R          (main results, robustness, heterogeneity)
├── data/
├── figures/
├── tables/
└── paper.tex
```
