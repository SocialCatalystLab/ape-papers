# Initial Research Plan: The Quiet Life Goes Macro

## Research Question

Did state anti-takeover laws (business combination statutes) contribute to the secular rise of market power in the United States? Specifically, did the staggered adoption of BC statutes across ~32 states between 1985-1997 causally reduce business dynamism, increase market concentration, and lower the labor share of income?

## Identification Strategy

**Design:** Staggered Difference-in-Differences using Callaway & Sant'Anna (2021) estimator.

**Treatment:** Adoption of business combination (BC) statute, dated per Karpoff & Wittry (2018) corrected classification. BC statutes impose moratoriums (typically 3-5 years) on mergers between large shareholders (>10-20% ownership) and target firms, effectively neutralizing hostile takeover threats.

**Treatment group:** ~32 states that adopted BC statutes (1985-1997).
**Control group:** ~18 states + DC that never adopted BC statutes (including California, Texas, Florida, Colorado, North Carolina).

**Parallel trends assumption:** In the absence of BC statute adoption, treated and control states would have followed similar trajectories in business dynamism, concentration, and labor share. Supported by:
- 5-10+ pre-treatment periods for all treated states
- Event-study pre-trend validation
- Multiple robustness checks on control group composition

## Expected Effects and Mechanisms

**Mechanism:** BC statute → reduced hostile takeover threat → less market discipline for incumbent firms → "quiet life" (Bertrand & Mullainathan 2003) → reduced efficiency investment → higher markups → macro consequences.

**Expected effects (post-treatment):**
1. **Business dynamism:** Decline in establishment entry rate, increase in average establishment size (entrenched incumbents deter entry)
2. **Labor share:** Decline (firms extract higher markups → profit share rises relative to compensation)
3. **Employment concentration:** Increase in large-establishment employment share

**Heterogeneity predictions:**
- Effects concentrated in industries with low ex-ante competition (Giroud & Mueller 2010)
- Stronger in states where local firms dominate incorporation (vs. Delaware-incorporated multinationals)
- Growing over time as cumulative effects of reduced discipline compound

## Primary Specification

$$ATT(g,t) = E[Y_{it} - Y_{it}(0) | G_i = g]$$

Estimated via `did::att_gt()` with:
- `yname`: outcome (entry_rate, labor_share, avg_estab_size)
- `tname`: year
- `idname`: state FIPS
- `gname`: BC adoption year (0 for never-treated)
- `control_group`: "nevertreated"
- Clustered at state level

Aggregate to:
- Overall ATT: `aggte(type = "simple")`
- Event study: `aggte(type = "dynamic")`
- Calendar time: `aggte(type = "calendar")`

## DiD-Specific Sections

### Exposure Alignment

- **Who is treated?** Firms incorporated in adopting states. Practically, the dominant local firms (which are typically incorporated in their home state) are the primary channel.
- **Primary estimand population:** All establishments in treated states (intent-to-treat at state level)
- **Control population:** All establishments in never-treated states
- **Design:** Standard 2-group staggered DiD (no triple-diff needed)

### Power Assessment

- **Pre-treatment periods:** 7-10 years for most states (CBP starts 1986; earliest treatment 1985)
- **Treated clusters:** 32 states
- **Post-treatment periods:** 25+ years for early adopters (1985 → 2020)
- **Total observations:** ~51 states × 35 years ≈ 1,785 state-years
- **MDE consideration:** With 32 treated and 18 control states, and long pre/post periods, well-powered for detecting moderate effects

## Planned Robustness Checks

1. **Drop lobbying states:** Remove states where specific firm lobbying documented (e.g., Indiana/Cummins Engine)
2. **Alternative treatment dates:** Use Bertrand & Mullainathan (2003) original dates as sensitivity
3. **Randomization inference:** Permute treatment assignment to generate null distribution
4. **Synthetic control:** For largest early adopters (NY 1985, IN 1986)
5. **Placebo outcomes:** Test on outcomes that should NOT be affected (e.g., weather, demographics)
6. **Goodman-Bacon decomposition:** Diagnose TWFE bias, show CS estimator resolves it
7. **HonestDiD sensitivity:** Rambachan-Roth bounds on parallel trends violations
8. **Alternative control groups:** Not-yet-treated as controls (in addition to never-treated baseline)
9. **Drop Delaware:** Extreme incorporation state; verify results robust to exclusion
10. **Industry heterogeneity:** Split by ex-ante competitiveness (HHI quartiles)

## Data Sources

| Source | Variables | Coverage | Access |
|--------|-----------|----------|--------|
| Census CBP | Establishments, employment, payroll by state-industry | 1986-2021 | Census API |
| BEA Regional | State GDP, compensation of employees | 1977-2023 | FRED API / BEA |
| Karpoff-Wittry (2018) | BC statute adoption dates | 1985-1997 | Coded from paper |
| Census BDS | Firm births/deaths, job creation/destruction | 1978-2021 | Census download |
| FRED | National recession dates, controls | 1970-present | FRED API |
