# Research Ideas

## Idea 1: Who Bears the Burden of Monetary Tightening? Heterogeneous Labor Market Responses and Aggregate Implications

**Policy:** Federal Reserve monetary policy tightening — identified via Jarocinski-Karadi (2020) high-frequency FOMC shocks extracted from fed funds futures around FOMC announcements, 1990-2024.

**Outcome:** Bureau of Labor Statistics Current Employment Statistics (CES) — monthly industry-level nonfarm payroll employment for 13 major supersectors (manufacturing, construction, mining, wholesale trade, retail trade, information, financial activities, professional/business services, education/health, leisure/hospitality, other services, government, transportation/utilities). Supplemented by JOLTS (job openings, hires, separations, quits, layoffs) available 2001-2024, and CPS occupation-level employment.

**Identification:** High-frequency monetary policy shocks from Jarocinski-Karadi (2020). These shocks exploit narrow (30-minute) windows around FOMC announcements to extract exogenous monetary policy surprises orthogonal to the Fed's information set. Combined with Jorda (2005) local projections for direct impulse response estimation without VAR misspecification risk.

**Why it's novel:**
1. Existing literature (Romer-Romer 2004, Christiano-Eichenbaum-Evans 2005, Gertler-Karadi 2015) focuses on *aggregate* employment responses. We document the *cross-industry distribution* of monetary policy's labor market effects using state-of-the-art identification.
2. We connect empirical heterogeneity to a two-sector NK model with Diamond-Mortensen-Pissarides (DMP) search frictions — a structural channel absent from standard HANK models which focus on consumption heterogeneity rather than job destruction heterogeneity.
3. Welfare analysis quantifies the distributional costs that representative-agent models miss: monetary tightening disproportionately destroys jobs in cyclically sensitive, low-skill sectors.

**Feasibility check:**
- JK shocks: publicly available CSV on GitHub (updated through Jan 2024)
- FRED CES data: all 13 supersector series available monthly 1990-present via fredapi
- FRED JOLTS data: available 2001-present
- Local projections: straightforward OLS with Newey-West HAC SEs (statsmodels)
- Two-sector NK-DMP model: analytically tractable, can be linearized with scipy

## Idea 2: Monetary Policy and the Skills Premium

**Policy:** Same FOMC monetary shocks (JK 2020).

**Outcome:** CPS Annual Social and Economic Supplement (ASEC) — hourly wages by education level (less than HS, HS, some college, BA+). Monthly frequency, 1990-2024.

**Identification:** JK high-frequency shocks + local projections. Interact shocks with education dummies.

**Why it's novel:** Documents how monetary tightening affects the college wage premium. Related to Coibion et al. (2017) on income inequality but uses cleaner identification and direct wage outcomes.

**Feasibility check:** CPS data accessible via IPUMS or BLS API. Wage series are noisier monthly; may need quarterly aggregation. Strong backup idea.

## Idea 3: The Gig Economy Channel of Monetary Policy

**Policy:** Same FOMC monetary shocks (JK 2020).

**Outcome:** CPS Contingent Worker Supplement (conducted in 2005, 2017, 2023) + monthly CPS alternative work arrangement measures.

**Identification:** JK shocks + local projections on gig/contingent work share.

**Why it's novel:** Tests whether monetary tightening pushes workers from traditional to contingent employment as firms shed permanent positions first. New margin of adjustment.

**Feasibility check:** CPS supplement only conducted in 3 years — very limited time series. Would need to rely on monthly CPS measures of self-employment/multiple jobholding as proxies. Weakest of the three ideas due to data limitations.
