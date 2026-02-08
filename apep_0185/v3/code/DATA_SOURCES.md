# Data Sources

This document provides machine-readable citations and URLs for all data sources
used in this analysis. Last verified: 2026-02-05.

## Primary Data Sources

### 1. Facebook Social Connectedness Index (SCI)

**Source:** Meta Data for Good / Humanitarian Data Exchange (HDX)

**URL:** https://data.humdata.org/dataset/social-connectedness-index

**Direct download (US county-to-county):**
https://data.humdata.org/dataset/e9988552-74e4-4ff4-943f-c782ac8bca87/resource/97dc352f-c9c5-47d6-a6ef-88709e14006c/download/us_counties.zip

**Citation:**
Bailey, M., Cao, R., Kuchler, T., Stroebel, J., & Wong, A. (2018). Social
connectedness: Measurement, determinants, and effects. Journal of Economic
Perspectives, 32(3), 259-280.

**Data vintage used:** 2018 release (treated as time-invariant)

**License:** Creative Commons Attribution International (CC BY-IGO)

---

### 2. State Minimum Wage Data

**Primary sources:**
- U.S. Department of Labor Wage and Hour Division
  - URL: https://www.dol.gov/agencies/whd/state/minimum-wage/history
  - Historical minimum wage tables by state

- National Conference of State Legislatures (NCSL)
  - URL: https://www.ncsl.org/labor-and-employment/state-minimum-wages
  - Current and historical state minimum wage rates

**Academic reference:**
Vaghul, K., & Zipperer, B. (2016). Historical state and sub-state minimum wage
data. Washington Center for Equitable Growth.
URL: https://github.com/benzipperer/historicalminwage

**Note:** The minimum wage data in 01_fetch_data.R is manually curated from
these sources. Each entry has been verified against DOL and NCSL records.
The data covers 2010-2023 and includes federal minimum wage as a floor.

---

### 3. County Geography

**Source:** U.S. Census Bureau TIGER/Line Shapefiles via `tigris` R package

**URL:** https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html

**Year:** 2019 vintage county boundaries

**Citation:**
Walker, K. (2016). tigris: An R package to access and work with geographic data
from the US Census Bureau. The R Journal, 8(2), 231-242.

---

### 4. Quarterly Workforce Indicators (QWI)

**Source:** U.S. Census Bureau Longitudinal Employer-Household Dynamics (LEHD)

**API endpoint:** https://api.census.gov/data/timeseries/qwi/sa

**Documentation:** https://www.census.gov/data/developers/data-sets/qwi.html

**Variables used:**
- Emp: Beginning-of-quarter employment
- EarnS: Average monthly earnings
- HirA: Hires (accessions)

**Coverage:** 2012-2022, county-level, private sector

---

### 5. QCEW Employment Data (Alternative)

**Source:** Bureau of Labor Statistics Quarterly Census of Employment and Wages

**URL:** https://www.bls.gov/cew/

**Bulk download format:**
https://data.bls.gov/cew/data/files/{year}/csv/{year}_annual_by_area.zip

**Note:** Annual averages are replicated across quarters as a proxy for
quarterly variation. See code documentation in 01b_fetch_qcew.R for
limitations of this approach.

---

## Data Processing Notes

1. **SCI time-invariance:** The 2018 SCI vintage is used throughout, treating
   social connections as stable over the 2010-2023 analysis period. Bailey et
   al. document year-over-year SCI correlations exceeding 0.97, supporting this
   assumption.

2. **Leave-own-state-out:** Network exposure excludes same-state county pairs
   to avoid mechanical correlation with own-state minimum wage policies.

3. **Anomalous value filter:** County-quarters with network exposure below
   $7.00 (federal minimum) are excluded (~8% of observations). These represent
   data quality issues or missing SCI links.

---

## Replication

To replicate data fetching:

```r
# Run in code/ directory
source("00_packages.R")
source("01_fetch_data.R")
source("01b_fetch_qcew.R")
source("02_clean_data.R")
```

Data files are saved to `data/` directory as .rds files.
