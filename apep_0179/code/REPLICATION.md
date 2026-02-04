# Replication Code for Paper 70

## Data Sources

### Primary Data: NBER Natality Public Use Files

**Source:** National Bureau of Economic Research (NBER)
**URL:** https://www.nber.org/research/data/vital-statistics-natality-birth-data
**Years:** 2016-2023

**Download URLs:**
- 2016: https://data.nber.org/nvss/natality/dta/2016/natality2016us.dta
- 2017: https://data.nber.org/nvss/natality/dta/2017/natality2017us.dta
- 2018: https://data.nber.org/nvss/natality/dta/2018/natality2018us.dta
- 2019: https://data.nber.org/nvss/natality/dta/2019/natality2019us.dta
- 2020: https://data.nber.org/nvss/natality/dta/2020/natality2020us.dta
- 2021: https://data.nber.org/nvss/natality/dta/2021/natality2021us.dta
- 2022: https://data.nber.org/nvss/natality/dta/2022/natality2022us.dta
- 2023: https://data.nber.org/nvss/natality/dta/2023/natality2023us.dta

**File sizes:** Approximately 800-900 MB each (Stata format)

**Documentation:** CDC User Guide available at:
https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/DVS/natality/

## Key Variables

| Variable | Description |
|----------|-------------|
| `MAGER` | Mother's single year of age (running variable) |
| `PAY` | Source of payment for delivery (1=Medicaid, 2=Private, 3=Self-pay, 4-9=Other) |
| `DMAR` | Marital status (1=Married, 2=Unmarried) |
| `MEDUC` | Mother's education |
| `MBSTATE_REC` | Mother's birth state (used for US-born indicator) |
| `PRECARE5` | Month prenatal care began |
| `DBWT` | Birth weight in grams |
| `COMBGEST` | Combined gestation estimate (weeks) |

## Replication Instructions

### Step 1: Download Data

Run `01_fetch_data.R` to download natality files from NBER.

```r
source("01_fetch_data.R")
```

This will download ~7 GB of data and may take 30-60 minutes depending on connection speed.

### Step 2: Process Data

Run `02_clean_data.R` to construct the analysis sample.

```r
source("02_clean_data.R")
```

This script:
- Reads each year's Stata file
- Filters to mothers ages 22-30
- Creates outcome and covariate variables
- Saves a combined RDS file

### Step 3: Run Analysis

Run scripts in order:

```r
source("03_main_analysis.R")    # Main RDD results
source("04_validity_tests.R")   # Validity tests
source("05_figures.R")          # Generate figures
source("06_robustness.R")       # Robustness checks
source("07_tables.R")           # Generate LaTeX tables
```

## Software Requirements

R version 4.0 or higher with the following packages:

```r
install.packages(c(
  "tidyverse",
  "data.table",
  "haven",
  "rdrobust",
  "rddensity",
  "rdlocrand",
  "fixest",
  "sandwich",
  "lmtest",
  "ggplot2",
  "latex2exp",
  "scales"
))
```

## Output

- `data/natality_analysis.rds`: Processed analysis sample
- `data/age_summary.rds`: Age-level summary statistics
- `data/rd_results.rds`: Main RDD results
- `data/balance_results.rds`: Covariate balance tests
- `data/placebo_results.rds`: Placebo cutoff tests
- `data/bandwidth_sensitivity.rds`: Bandwidth sensitivity results
- `figures/`: PDF figures
- `paper.pdf`: Compiled paper

## Citation

Data are from the National Vital Statistics System, provided by NCHS and archived by NBER.

```
National Center for Health Statistics. Natality Public Use File.
Hyattsville, MD. Available from NBER at:
https://www.nber.org/research/data/vital-statistics-natality-birth-data
```
