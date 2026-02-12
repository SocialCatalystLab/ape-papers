# Research Ideas

## Idea 1: Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets

**Policy:** Natural experiment comparing the Great Recession (2007-2009, demand-driven) vs. COVID recession (2020, supply-driven with rapid fiscal response). No single policy but rather the aggregate macroeconomic shock structure differs.

**Outcome:** State-level employment, unemployment rate, labor force participation rate, wages from FRED (BLS CES/LAUS). Monthly frequency, 2005-2023. 50 states + DC.

**Identification:** LP-IV with Bartik instrument. For each recession, construct predicted state-level employment shock using pre-recession industry composition × national industry-level employment changes (excluding own-state). This gives exogenous variation in how hard each state was hit. Estimate local projections of state employment recovery paths for h = 0, 1, ..., 120+ months.

**Why it's novel:**
- Direct cross-recession comparison of hysteresis at the state level with 16+ years of post-2008 data
- Nobody has exploited the demand-vs-supply nature of the two recessions for hysteresis identification
- Yagan (2019 AER) is closest but uses individual IRS data through 2015 only; we extend to 2023 and add COVID comparison
- Structural search model with endogenous participation and skill depreciation generates testable predictions
- Policy-relevant: distinguishes permanent vs. temporary employment effects based on shock type

**Feasibility check:**
- [CONFIRMED] FRED state-level nonfarm payrolls: 50 states, monthly, 2005-2023 (228 obs each)
- [CONFIRMED] FRED state-level unemployment rates: 50 states, monthly, 2005-2023
- [CONFIRMED] FRED state-level LFPR: 50 states, monthly, 2005-2023
- [CONFIRMED] FRED state × industry employment: 6+ industries per state (MFG, CONS, FIRE, INFO, LEIH, EDUH)
- [CONFIRMED] FRED national macro series: GDP, unemployment, JOLTS
- Cross-section: 50 states × 2 recessions × 228 months = massive panel

**Model:** DMP search model with endogenous labor force participation, human capital depreciation during unemployment, and two types of aggregate shocks (demand vs. supply). Model predicts demand shocks create hysteresis (via prolonged unemployment → skill loss → LFP exit) while supply shocks don't (temporary separation, no skill loss).

---

## Idea 2: The Fiscal Multiplier Through the Labor Market Lens: Evidence from ARRA

**Policy:** American Recovery and Reinvestment Act (2009). $787 billion in federal spending allocated differentially across states through formula grants, competitive grants, and tax provisions.

**Outcome:** State employment, unemployment, wages from FRED/BLS. Quarterly frequency.

**Identification:** LP-IV using cross-state variation in ARRA spending per capita (instrumented by pre-existing formula shares). Wilson (2012 AER) and Chodorow-Reich (2019) establish the basic design.

**Why it's novel:**
- Decompose fiscal multiplier into JOB CREATION vs. prevented JOB DESTRUCTION channels
- Use JOLTS-style flow data at state level to distinguish hiring response from layoff prevention
- Model: NK model with heterogeneous firms and search frictions, fiscal spending as demand shock

**Feasibility check:**
- ARRA spending data: Recovery.gov archive (may be difficult to access programmatically)
- State employment: confirmed from FRED
- LIMITATION: ARRA spending data requires manual compilation from archived sources

---

## Idea 3: Geographic Labor Mobility as a Shock Absorber: Migration Responses to Regional Recessions

**Policy:** No specific policy; exploits regional variation in recession severity as quasi-experiment.

**Outcome:** IRS county-to-county migration flows (SOI), state employment, population estimates.

**Identification:** Bartik shocks to state employment → measure how migration responds → assess whether mobility dampens or amplifies local recessions.

**Why it's novel:**
- Tests Blanchard-Katz (1992) adjustment mechanism with modern data and methods
- IRS SOI migration data allows tracking flows directly (not just stocks)
- Model: spatial equilibrium with moving costs and search frictions

**Feasibility check:**
- IRS SOI migration data: public download, annual, county-to-county, 2004-2020
- State employment: confirmed
- LIMITATION: IRS migration data is annual (low frequency for business cycle analysis)
- LIMITATION: IRS data ends 2020, misses full COVID recovery

---

## Idea 4: Skill Mismatch and the Slow Recovery: Occupational Reallocation After the Great Recession

**Policy:** No specific policy; exploits the Great Recession as a reallocation shock.

**Outcome:** CPS occupational employment shares, wages by occupation, unemployment duration.

**Identification:** Pre-recession occupation-level exposure to housing bust × post-recession reemployment patterns.

**Why it's novel:**
- Tests Sahin et al. (2014) mismatch hypothesis with longer follow-up
- Traces occupational reallocation paths at individual level (CPS matched panels)
- Model: multi-occupation search model with occupation-specific capital

**Feasibility check:**
- CPS data: via IPUMS API (confirmed available)
- Occupation codes: SOC/Census codes in CPS
- LIMITATION: CPS matching across panels requires careful handling of rotation groups
- LIMITATION: occupation codes changed (SOC 2010 vs 2018 crosswalk issues)
