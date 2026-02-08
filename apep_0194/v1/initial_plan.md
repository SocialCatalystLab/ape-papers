# Initial Research Plan: Digital Exodus or Digital Magnet?

## Research Question

Do state comprehensive data privacy laws reshape the composition of the technology sector? Specifically, do privacy laws cause a **sorting equilibrium** in which privacy-enhancing firms (cybersecurity, encrypted communications, compliance technology) are attracted while surveillance-economy firms (ad tech, data brokers, targeted advertising) are repelled — potentially leaving net tech employment unchanged or even positive?

## Identification Strategy

**Staggered Difference-in-Differences** exploiting variation in the timing of state comprehensive data privacy law adoption across 20+ states from 2020 to 2025.

- **Treatment:** Effective date of state comprehensive privacy law (binary)
- **Estimator:** Callaway & Sant'Anna (2021) heterogeneity-robust DiD
- **Unit of analysis:** State × quarter (QCEW) or state × month (BFS)
- **Controls:** State + time FEs, state GDP growth, total employment, partisan composition
- **Robustness:** Sun & Abraham (2021), de Chaisemartin & d'Haultfoeuille (2020), HonestDiD sensitivity analysis, Fisher randomization inference

### Treatment Timing (Comprehensive Privacy Laws)

| State | Enacted | Effective | Notes |
|-------|---------|-----------|-------|
| California (CCPA) | Jun 2018 | Jan 2020 | First mover; amended by CPRA (Jan 2023) |
| Virginia (VCDPA) | Mar 2021 | Jan 2023 | |
| Colorado (CPA) | Jun 2021 | Jul 2023 | |
| Connecticut (CTDPA) | May 2022 | Jul 2023 | |
| Utah (UCPA) | Mar 2022 | Dec 2023 | |
| Iowa | Mar 2023 | Jan 2025 | |
| Indiana | May 2023 | Jan 2026 | |
| Tennessee | May 2023 | Jul 2025 | |
| Montana | May 2023 | Oct 2024 | |
| Oregon | Jul 2023 | Jul 2024 | |
| Texas | Jun 2023 | Jul 2024 | |
| Delaware | Sep 2023 | Jan 2025 | |
| New Hampshire | Mar 2024 | Jan 2025 | |
| New Jersey | Jan 2024 | Jan 2025 | |
| Kentucky | Apr 2024 | Jan 2026 | |
| Nebraska | Apr 2024 | Jan 2025 | |
| Maryland | May 2024 | Oct 2025 | |
| Minnesota | May 2024 | Jul 2025 | |
| Rhode Island | Jun 2024 | Jan 2026 | |

**20+ treated states with staggered adoption. 30+ never-treated states as controls.**

## Expected Effects and Mechanisms

### Primary Hypothesis: Sorting Equilibrium
- **H1a:** Privacy laws REDUCE employment in data-intensive sub-sectors (NAICS 5191 - data processing/hosting, 5182 - data storage, portions of 5121 - software with data models)
- **H1b:** Privacy laws INCREASE employment in privacy-enhancing sub-sectors (NAICS 5182 - cybersecurity, 5415 - IT consulting/compliance, portions of 5112 - privacy software)
- **H1c:** Net effect on total Information Sector (NAICS 51) employment is approximately ZERO or POSITIVE

### Secondary Hypothesis: Business Formation Sorting
- **H2:** Privacy laws increase applications for businesses in compliance-related categories while decreasing applications in data-broker categories, as measured by BFS sector-level data

### Mechanism: Worker and Capital Reallocation
- **H3:** Using IRS SOI migration data, high-income workers (AGI > $200k) show differential migration responses in high-tech vs. low-tech counties within treated states

### Counter-intuitive Prediction
The "Brussels Effect" hypothesis: regulation ATTRACTS certain types of economic activity by building consumer trust and creating first-mover advantage in privacy-compliant business models. If true, the net effect of privacy laws on tech employment is non-negative.

## Primary Specification

$$Y_{st} = \alpha + \beta \cdot \text{PrivacyLaw}_{st} + \gamma_{s} + \delta_{t} + X_{st}'\phi + \varepsilon_{st}$$

Where:
- $Y_{st}$ = log employment in sector $k$ in state $s$ at time $t$
- $\text{PrivacyLaw}_{st}$ = 1 if state $s$ has an effective privacy law at time $t$
- $\gamma_{s}$ = state fixed effects
- $\delta_{t}$ = time fixed effects
- $X_{st}$ = time-varying state controls (GDP growth, total employment, political composition)

Estimated with Callaway-Sant'Anna for group-time ATTs, then aggregated.

## Planned Robustness Checks

1. **Pre-trend diagnostics:** Event-study plot showing no pre-treatment differential trends
2. **HonestDiD sensitivity:** Rambachan & Roth (2023) bounds under violations of parallel trends
3. **Randomization inference:** Fisher permutation test (randomly reassign treatment dates)
4. **Alternative estimators:** Sun & Abraham (2021), de Chaisemartin & d'Haultfoeuille (2020)
5. **Placebo outcomes:** Non-tech sectors (construction, retail) should show no effect
6. **Dose-response:** Laws with stronger enforcement provisions should have larger effects
7. **Spillover test:** Do neighboring states' privacy laws affect focal state employment?
8. **Concurrent policy controls:** COVID stimulus, state tax changes, federal tech regulation

## Data Sources

| Data | Source | Granularity | Period | Access |
|------|--------|-------------|--------|--------|
| Employment by industry | BLS QCEW | State × quarter × NAICS | 2015-2024 | Public API |
| Business applications | Census BFS | State × month × sector | 2005-2024 | Public download |
| Interstate migration | IRS SOI | State-to-state × year × AGI | 2011-2022 | Public download |
| State GDP | BEA | State × quarter | 2005-2024 | Public API |
| Privacy law dates | NCSL/IAPP | State | 2018-2025 | Manual coding |

## Analysis Scripts (Planned)

- `00_packages.R` — Load libraries, set themes
- `01_fetch_data.R` — Download QCEW, BFS, BEA, IRS data
- `02_clean_data.R` — Merge datasets, construct treatment indicators, variable construction
- `03_main_analysis.R` — Primary CS-DiD regressions, event studies
- `04_robustness.R` — Alternative estimators, placebos, HonestDiD, randomization inference
- `05_figures.R` — All figure generation
- `06_tables.R` — All table generation
