# Replication Report

**Paper ID:** apep_0132
**Title:** Does Local Climate Policy Build Demand for National Action? Evidence from Swiss Energy Referendums\thanks{Revision of apep\_0125 (Rating: 18.0). Key change in this revision: streamlined main text by relocating supplementary maps and diagnostic figures to appendix for improved narrative flow.
**Replication Date:** 2026-02-03
**Replicator:** Claude Code

---

## Summary

**Classification:** PARTIAL WITH ERRORS

**Overall Assessment:**
5 of 13 scripts failed. Results may be incomplete.

### Execution Summary

- **Total Scripts:** 13
- **Successful:** 8
- **Failed:** 5

---

## 1. Computing Environment

- **Platform:** macOS-15.6.1-arm64-arm-64bit-Mach-O
- **Processor:** arm
- **Python Version:** 3.14.2
- **R Version:** R version 4.5.2 (2025-10-31) -- "[Not] Part in a Rumble"

### R Packages
```
> 
>         pkgs <- c("fixest", "rdrobust", "did", "ggplot2", "modelsummary", "haven", "tidyverse")
>         installed <- installed.packages()
>         for (p in pkgs) {
+             if (p %in% rownames(installed)) {
+                 cat(sprintf("%s: %s
+ ", p, installed[p, "Version"]))
+             }
+         }
fixest: 0.13.2
rdrobust: 3.0.0
did: 2.3.0
ggplot2: 4.0.1
modelsummary: 2.5.0
haven: 2.5.5
tidyverse: 2.0.0
>         
>
```

---

## 2. Code Inventory

**R Scripts:** 13
**Python Scripts:** 0
**Main Script:** 00_packages.R

| Script | Language |
|--------|----------|
| `00_packages.R` | R |
| `00b_verify_treatment.R` | R |
| `01_fetch_data.R` | R |
| `02_clean_data.R` | R |
| `03_main_analysis.R` | R |
| `04_robustness.R` | R |
| `05_figures.R` | R |
| `06_tables.R` | R |
| `07_expanded_analysis.R` | R |
| `08_revision_fixes.R` | R |
| `09_fix_rdd_sample.R` | R |
| `10_placebo_corrected.R` | R |
| `11_didisc_analysis.R` | R |

---

## 3. Execution Results

| Script | Success | Duration | Exit Code |
|--------|---------|----------|-----------|
| `00_packages.R` | Yes | 1.6s | 0 |
| `00b_verify_treatment.R` | Yes | 1.4s | 0 |
| `01_fetch_data.R` | Yes | 402.7s | 0 |
| `02_clean_data.R` | Yes | 18.8s | 0 |
| `03_main_analysis.R` | Yes | 2.7s | 0 |
| `04_robustness.R` | **No** | 2.9s | 1 |
| `05_figures.R` | **No** | 27.6s | 1 |
| `06_tables.R` | **No** | 1.6s | 1 |
| `07_expanded_analysis.R` | Yes | 113.8s | 0 |
| `08_revision_fixes.R` | **No** | 3.3s | 1 |
| `09_fix_rdd_sample.R` | Yes | 60.6s | 0 |
| `10_placebo_corrected.R` | Yes | 2.0s | 0 |
| `11_didisc_analysis.R` | **No** | 59.1s | 1 |

### Errors

#### 04_robustness.R

```
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.6
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.1     ✔ tibble    3.3.1
✔ lubridate 1.9.4     ✔ tidyr     1.3.2
✔ purrr     1.2.1     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
************************************************************
*                     swissdd 1.1.5                        *
*                  developed by politan.ch                 *
*                                                          *
*                     Data sources:                        *
*                Federal Statistical Office                *
*                 https://www.bfs.admin.ch/                *
*                                                          *
*                      Swissvotes                          *
*                  https://swissvotes.ch/                  *
*                                                          *
************************************************************
Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

Attaching package: ‘scales’

The following object is masked from ‘package:fixest’:

    pvalue

The following object is masked from ‘package:purrr’:

    discard

The following object is masked from ‘package:readr’:

    col_factor

Base directory: /Users/dyanag/auto-policy-evals/output/replication_apep_0132
Packages loaded. Ready for analysis.
Running placebo tests on pre-treatment referenda...
Pre-treatment energy votes found: 5
  Placebo: Verfassungsartikel über eine Förderabgabe für erneuerbare Energien ( 2000-09-24 )
Error in `transmute()`:
ℹ In argument: `canton_abbr = canton_abbr`.
Caused by error:
! object 'canton_abbr' not found
Backtrace:
     ▆
  1. ├─...
```

#### 05_figures.R

```
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.6
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.1     ✔ tibble    3.3.1
✔ lubridate 1.9.4     ✔ tidyr     1.3.2
✔ purrr     1.2.1     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
************************************************************
*                     swissdd 1.1.5                        *
*                  developed by politan.ch                 *
*                                                          *
*                     Data sources:                        *
*                Federal Statistical Office                *
*                 https://www.bfs.admin.ch/                *
*                                                          *
*                      Swissvotes                          *
*                  https://swissvotes.ch/                  *
*                                                          *
************************************************************
Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

Attaching package: ‘scales’

The following object is masked from ‘package:fixest’:

    pvalue

The following object is masked from ‘package:purrr’:

    discard

The following object is masked from ‘package:readr’:

    col_factor

Base directory: /Users/dyanag/auto-policy-evals/output/replication_apep_0132
Packages loaded. Ready for analysis.
Creating Figure 1: Treatment map...
   Saved fig1a_treatment_map.pdf and fig1b_voteshare_map.pdf
Creating Figure 1c: Language zones map...
   Saved fig1c_language_map.pdf
Creating Figure 1d: Treatment timing map...
   Saved fig1d_timing_map.pdf
Creating Figure 1e: Border municipalities map...
Computing CORRECT policy border f
```

#### 06_tables.R

```
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.6
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.1     ✔ tibble    3.3.1
✔ lubridate 1.9.4     ✔ tidyr     1.3.2
✔ purrr     1.2.1     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
************************************************************
*                     swissdd 1.1.5                        *
*                  developed by politan.ch                 *
*                                                          *
*                     Data sources:                        *
*                Federal Statistical Office                *
*                 https://www.bfs.admin.ch/                *
*                                                          *
*                      Swissvotes                          *
*                  https://swissvotes.ch/                  *
*                                                          *
************************************************************
Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

Attaching package: ‘scales’

The following object is masked from ‘package:fixest’:

    pvalue

The following object is masked from ‘package:purrr’:

    discard

The following object is masked from ‘package:readr’:

    col_factor

Base directory: /Users/dyanag/auto-policy-evals/output/replication_apep_0132
Packages loaded. Ready for analysis.
Error in gzfile(file, "rb") : cannot open the connection
Calls: readRDS -> gzfile
In addition: Warning message:
In gzfile(file, "rb") :
  cannot open compressed file '/Users/dyanag/auto-policy-evals/output/replication_apep_0132/data/rd_results_full.rds', probable reason 'No such file or directory'
Execution halted

```

#### 08_revision_fixes.R

```
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.6
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.1     ✔ tibble    3.3.1
✔ lubridate 1.9.4     ✔ tidyr     1.3.2
✔ purrr     1.2.1     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
************************************************************
*                     swissdd 1.1.5                        *
*                  developed by politan.ch                 *
*                                                          *
*                     Data sources:                        *
*                Federal Statistical Office                *
*                 https://www.bfs.admin.ch/                *
*                                                          *
*                      Swissvotes                          *
*                  https://swissvotes.ch/                  *
*                                                          *
************************************************************
Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

Attaching package: ‘scales’

The following object is masked from ‘package:fixest’:

    pvalue

The following object is masked from ‘package:purrr’:

    discard

The following object is masked from ‘package:readr’:

    col_factor

Base directory: /Users/dyanag/auto-policy-evals/output/replication_apep_0132
Packages loaded. Ready for analysis.
Loading required package: viridisLite

Attaching package: ‘viridis’

The following object is masked from ‘package:scales’:

    viridis_pal

Warning messages:
1: In rdrobust(y = sample_seg$yes_share, x = sample_seg$distance_to_border,  :
  c should be set within the range of x
2: In rdrobust(y = sample_seg$yes_share, x = samp
```

#### 11_didisc_analysis.R

```
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.6
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.1     ✔ tibble    3.3.1
✔ lubridate 1.9.4     ✔ tidyr     1.3.2
✔ purrr     1.2.1     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
************************************************************
*                     swissdd 1.1.5                        *
*                  developed by politan.ch                 *
*                                                          *
*                     Data sources:                        *
*                Federal Statistical Office                *
*                 https://www.bfs.admin.ch/                *
*                                                          *
*                      Swissvotes                          *
*                  https://swissvotes.ch/                  *
*                                                          *
************************************************************
Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

Attaching package: ‘scales’

The following object is masked from ‘package:fixest’:

    pvalue

The following object is masked from ‘package:purrr’:

    discard

The following object is masked from ‘package:readr’:

    col_factor

Base directory: /Users/dyanag/auto-policy-evals/output/replication_apep_0132
Packages loaded. Ready for analysis.
Error in `select()`:
! Can't select columns that don't exist.
✖ Column `same_language` doesn't exist.
Backtrace:
     ▆
  1. ├─panel_df %>% ...
  2. ├─dplyr::left_join(...)
  3. ├─dplyr:::left_join.data.frame(...)
  4. │ └─dplyr::auto_copy(x, y, copy = copy)
  5. │   ├─dplyr::same_src(x, y)
  6. │   └─dplyr:::same_src.data.fr
```


---

## 4. Figure Comparisons

| Figure | Original | Generated | Status |
|--------|----------|-----------|--------|
| `fig4_bandwidth_sensitivity.pdf` | Yes | Yes | Visual inspection required |
| `fig_randomization_inference.pdf` | Yes | Yes | Visual inspection required |
| `fig3_spatial_rdd.pdf` | Yes | Yes | Visual inspection required |
| `fig1d_timing_map.pdf` | Yes | Yes | Visual inspection required |
| `fig_language_comparison.pdf` | Yes | Yes | Visual inspection required |
| `fig_balance_expanded.pdf` | Yes | **No** | NOT GENERATED |
| `fig_placebo_referendums.pdf` | Yes | **No** | NOT GENERATED |
| `fig_cs_event_study.pdf` | Yes | Yes | Visual inspection required |
| `fig1_canton_votes.pdf` | Yes | **No** | NOT GENERATED |
| `fig_density_test.pdf` | Yes | Yes | Visual inspection required |
| `fig_rdd_main.pdf` | Yes | Yes | Visual inspection required |
| `fig_rdd_specifications.pdf` | Yes | Yes | Visual inspection required |
| `fig_bandwidth_sensitivity.pdf` | Yes | Yes | Visual inspection required |
| `fig1c_language_map.pdf` | Yes | Yes | Visual inspection required |
| `fig1b_voteshare_map.pdf` | Yes | Yes | Visual inspection required |
| `fig1e_border_map.pdf` | Yes | Yes | Visual inspection required |
| `fig_rdd_specifications_corrected.pdf` | Yes | **No** | NOT GENERATED |
| `fig_covariate_balance.pdf` | Yes | Yes | Visual inspection required |
| `fig2_treatment_effect.pdf` | Yes | **No** | NOT GENERATED |
| `fig_donut_rdd.pdf` | Yes | Yes | Visual inspection required |
| `fig_event_study.pdf` | Yes | Yes | Visual inspection required |
| `fig4_placebo.pdf` | Yes | **No** | NOT GENERATED |
| `fig_urbanity_heterogeneity.pdf` | Yes | Yes | Visual inspection required |
| `fig2_distribution.pdf` | Yes | Yes | Visual inspection required |
| `fig_distribution_treatment.pdf` | Yes | Yes | Visual inspection required |
| `fig1e_border_map_corrected.pdf` | Yes | **No** | NOT GENERATED |
| `fig_ols_coefficients.pdf` | Yes | Yes | Visual inspection required |
| `fig6_border_pair_rdds.pdf` | Yes | **No** | NOT GENERATED |
| `fig_rdd_corrected.pdf` | Yes | **No** | NOT GENERATED |
| `fig1a_treatment_map.pdf` | Yes | Yes | Visual inspection required |
| `fig_distribution_language.pdf` | Yes | Yes | Visual inspection required |
| `fig_border_pairs_forest.pdf` | Yes | Yes | Visual inspection required |
| `fig3_distribution.pdf` | Yes | **No** | NOT GENERATED |
| `fig5_language_comparison.pdf` | Yes | Yes | Visual inspection required |

---

## 5. Classification

### Final Classification: PARTIAL WITH ERRORS

**Justification:**
5 of 13 scripts failed. Results may be incomplete.

---

## 6. Next Steps

1. Fix failing scripts
2. Re-run replication
3. Visually compare outputs

---

## Appendix: File Locations

- **Execution Log:** `logs/execution.log`
- **Generated Figures:** `figures/`
- **Generated Tables:** `tables/`
- **Original Paper:** `/Users/dyanag/auto-policy-evals/papers/apep_0132/paper.pdf`
