# Initial Research Plan: Who Bears the Burden of Monetary Tightening?

## Research Question

How does monetary policy tightening differentially affect employment across industries, and what are the aggregate welfare implications of this heterogeneity? Specifically: (1) Which industries bear the largest job losses from contractionary monetary shocks? (2) What labor market flows (openings, hires, separations, quits, layoffs) drive these differential responses? (3) Can a two-sector New Keynesian model with search frictions rationalize these patterns? (4) How large are the distributional welfare costs that representative-agent models miss?

## Identification Strategy

**High-frequency monetary policy shocks (Jarocinski-Karadi 2020):**
- Extract surprise changes in federal funds rate expectations from 30-minute windows around FOMC announcements
- Sign-restriction decomposition separates pure monetary policy shocks (rates up, stocks down) from central bank information shocks (rates up, stocks up)
- We use ONLY the pure monetary policy component — this is the state-of-the-art solution to the "Fed information effect" (Nakamura-Steinsson 2018)
- Identification assumption: within the narrow FOMC window, movements in financial prices reflect only the policy announcement, not other news

**Local projections (Jorda 2005):**
- Direct estimation of impulse responses without VAR misspecification risk
- Newey-West HAC standard errors with bandwidth h+1

## Pre-Specified Heterogeneity Dimensions

All heterogeneity analyses are pre-specified HERE before data fetch:

1. **Industry-level IRFs:** 13 CES supersectors individually (manufacturing, construction, mining/logging, wholesale trade, retail trade, information, financial activities, professional/business services, education/health services, leisure/hospitality, other services, government, transportation/utilities)

2. **Goods vs. services:** Binary classification. Goods = manufacturing + construction + mining/logging. Services = all others except government. Theory: goods sectors are more interest-rate sensitive (durable demand, capital intensity).

3. **Cyclical sensitivity:** Industries ranked by beta-cyclicality = Cov(employment_growth_i, GDP_growth) / Var(GDP_growth), computed using 1990-2000 data ONLY (before estimation). Top tercile = "high cyclicality," bottom = "low cyclicality."

4. **JOLTS flow decomposition:** Separate LPs for openings, hires, total separations, quits, layoffs for each industry. Theory predicts: openings fall first (demand), then hires fall, quits fall (fewer outside options), finally layoffs rise.

5. **Skill intensity:** Industries classified by share of workers with BA+ using 1990s CPS cross-section averages. Theory: low-skill industries face steeper employment losses because wages are closer to reservation values.

## Data Sources

### Primary Data
1. **JK Monetary Policy Shocks** (GitHub CSV)
   - URL: https://raw.githubusercontent.com/marekjarocinski/jkshocks_update_fed_202401/main/shocks_fed_jk_m.csv
   - Frequency: Monthly (aggregated from per-meeting)
   - Coverage: 1990m1-2024m1
   - Variables: mp_shock (pure monetary), info_shock (information), total_shock

2. **FRED CES Employment** (fredapi)
   - 13 supersector series: PAYEMS, MANEMP, USCONS, USMINE, USWTRADE, USTRADE, USINFO, USFIRE, USPBS, USEHS, USLAH, USSERV, USGOVT
   - Plus: CES0500000001 (total private), USTPU (transportation/utilities)
   - Frequency: Monthly, seasonally adjusted
   - Coverage: 1990m1-2024m12

3. **FRED JOLTS** (fredapi)
   - Job openings, hires, separations, quits, layoffs by industry
   - Series pattern: JTS{INDUSTRY}{FLOW}
   - Frequency: Monthly, seasonally adjusted
   - Coverage: 2001m1-2024m12

4. **FRED Macro Controls** (fredapi)
   - Federal funds rate: FEDFUNDS
   - 10-year Treasury: GS10
   - CPI: CPIAUCSL
   - Unemployment: UNRATE
   - Industrial production: INDPRO
   - GDP: GDPC1 (quarterly, interpolated)

## Empirical Specification

### Aggregate local projection
$$y_{t+h} - y_{t-1} = \alpha_h + \beta_h \cdot MP_t + \gamma_h' Z_{t-1} + \varepsilon_{t+h}$$

where:
- $y_t$ = log employment (or JOLTS flow rate)
- $MP_t$ = JK monetary policy shock
- $Z_{t-1}$ = vector of controls (12 lags of shock, unemployment, inflation, output growth)
- $h = 0, 1, 2, 3, 6, 9, 12, 18, 24, 36, 48$ months

### Heterogeneous local projection (industry panel)
$$y_{i,t+h} - y_{i,t-1} = \alpha_{i,h} + \beta_h \cdot MP_t + \delta_h \cdot (MP_t \times X_i) + \gamma_h' Z_{t-1} + \varepsilon_{i,t+h}$$

where $X_i$ is a pre-determined industry characteristic (goods dummy, cyclicality tercile, skill share).

### Inference
- Newey-West HAC standard errors with bandwidth $\lfloor 1.5 \times (h+1) \rfloor$
- Driscoll-Kraay standard errors for panel specification (robust to cross-sectional dependence)
- 90% and 68% confidence bands (standard in macro LP literature)

## Structural Model

### Two-Sector NK Model with DMP Search Frictions

**Environment:**
- Two sectors $s \in \{G, S\}$ (goods, services)
- DMP matching: $m_{s,t} = \chi_s u_{s,t}^\alpha v_{s,t}^{1-\alpha}$ with $\alpha = 0.5$ (Hosios condition)
- Endogenous separation: $\rho_{s,t} = \rho_s + \sigma_\rho \max(0, \bar{A}_s - A_{s,t})$ (productivity below threshold triggers extra separations)
- Nash bargained wages: $w_{s,t} = \eta(A_{s,t} + \kappa_s \theta_{s,t}) + (1-\eta)b$ with $\eta = 0.5$
- Calvo pricing: firms set prices with probability $1-\lambda_s$ each period
- Taylor rule: $i_t = \rho_i i_{t-1} + (1-\rho_i)[\phi_\pi \pi_t + \phi_y y_t] + \varepsilon_t^{mp}$

**Calibration targets:**
- Employment shares: goods (14%), services (72%), government (14%)
- JOLTS moments by sector: separation rates, vacancy-filling rates, job-finding rates
- Aggregate moments: output volatility, inflation persistence, unemployment rate

**Solution method:**
- Log-linearize around deterministic steady state
- Solve linear rational expectations system via eigenvalue decomposition (Blanchard-Kahn)
- Compute IRFs to 25bp monetary policy shock

## Welfare Analysis

- Consumption-equivalent welfare loss by worker type (goods vs. services, high-skill vs. low-skill)
- Compare heterogeneous model welfare to representative-agent counterfactual
- Decompose: how much welfare cost comes from (a) differential job destruction vs (b) differential wage responses vs (c) transition dynamics

## Planned Robustness Checks

1. Alternative monetary shocks: Bu-Rogers-Wu (2021) from Federal Reserve website
2. Subsample stability: 1990-2007, 2001-2024, excluding ZLB (2009-2015)
3. Additional controls: oil price changes, fiscal policy measures, VIX
4. Excluding outlier FOMC meetings (>2 SD shocks)
5. Alternative LP specifications: cubic controls, different lag structures
6. Placebo: financial market variables should not predict PRIOR employment changes

## Expected Results

Based on economic theory and prior literature:
1. **Aggregate:** Employment falls 0.1-0.3% in response to 25bp tightening, peaking at 12-24 months (consistent with Christiano-Eichenbaum-Evans 2005)
2. **Heterogeneity:** Goods sector employment falls 2-4x more than services (consistent with Bernanke-Gertler 1995 on credit channel)
3. **JOLTS:** Job openings respond fastest (within 3 months), followed by hires, then separations. Quits fall (fewer outside options) while layoffs rise (forced reductions).
4. **Model:** Two-sector model matches cross-sector IRF heterogeneity that one-sector model cannot
5. **Welfare:** Distributional costs are 30-50% larger than representative-agent model implies

## Table and Figure Plan

### Tables (9)
1. Summary statistics (employment, shocks, JOLTS, macro)
2. Aggregate LP results (multiple horizons, multiple specifications)
3. Industry-level peak employment responses
4. Goods vs. services interaction results
5. JOLTS decomposition by sector
6. Robustness (alternative shocks, subsamples, controls)
7. Model calibration parameters
8. Model fit: data vs model IRFs
9. Welfare analysis (consumption-equivalent losses)

### Figures (10+)
1. JK monetary policy shock series (time series plot)
2. Aggregate employment IRF (with confidence bands)
3. Industry-level IRF panel (4x4 grid)
4. Goods vs. services IRF comparison
5. JOLTS flow decomposition IRFs
6. Cyclicality interaction (high vs. low beta industries)
7. Model vs. data IRFs (aggregate + sectoral)
8. Welfare decomposition (bar chart by worker type)
9. Robustness: alternative shocks (BRW vs. JK)
10. Placebo: pre-FOMC employment changes
