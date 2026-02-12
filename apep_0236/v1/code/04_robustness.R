## =============================================================================
## 04_robustness.R — Robustness checks for IMLC paper
## APEP Working Paper apep_0232
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
results <- readRDS(file.path(data_dir, "main_results.rds"))
panel <- results$panel

cat("=== Robustness Checks ===\n\n")

## ---------------------------------------------------------------------------
## 1. Placebo test: Retail Trade (NAICS 44-45)
##    IMLC should NOT affect retail employment
## ---------------------------------------------------------------------------

cat("--- Placebo: Placebo: Accomm. Employment ---\n")

cs_retail <- att_gt(
  yname  = "log_plc_emp",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_plc_emp)),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_retail <- aggte(cs_retail, type = "simple")
cat(sprintf("Placebo ATT (Placebo: Accomm. Employment): %.4f (SE: %.4f, p: %.4f)\n",
            agg_retail$overall.att, agg_retail$overall.se,
            2 * pnorm(-abs(agg_retail$overall.att / agg_retail$overall.se))))

es_retail <- aggte(cs_retail, type = "dynamic", min_e = -5, max_e = 6)

## ---------------------------------------------------------------------------
## 2. Placebo: Hospital Employment (NAICS 622)
##    Hospitals require physical presence; IMLC should mainly affect
##    ambulatory/telehealth-intensive settings
## ---------------------------------------------------------------------------

cat("\n--- Sub-industry: Hospital Employment ---\n")

cs_hosp <- att_gt(
  yname  = "log_hosp_emp",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_hosp_emp)),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_hosp <- aggte(cs_hosp, type = "simple")
cat(sprintf("ATT (Hospital Employment): %.4f (SE: %.4f, p: %.4f)\n",
            agg_hosp$overall.att, agg_hosp$overall.se,
            2 * pnorm(-abs(agg_hosp$overall.att / agg_hosp$overall.se))))

es_hosp <- aggte(cs_hosp, type = "dynamic", min_e = -5, max_e = 6)

## ---------------------------------------------------------------------------
## 3. Bacon decomposition (diagnostic for TWFE)
## ---------------------------------------------------------------------------

cat("\n--- Bacon Decomposition ---\n")

# Need binary treatment variable and balanced panel
bacon_data <- panel %>%
  filter(!is.na(log_hc_emp)) %>%
  # Bacon decomposition requires complete panel
  group_by(state_id) %>%
  filter(n() == max(panel %>% count(year) %>% pull(n))) %>%
  ungroup()

bacon_result <- tryCatch({
  bacon(log_hc_emp ~ treated,
        data = bacon_data,
        id_var = "state_id",
        time_var = "year")
}, error = function(e) {
  cat(sprintf("Bacon decomposition error: %s\n", e$message))
  NULL
})

if (!is.null(bacon_result)) {
  cat("\nBacon decomposition weights:\n")
  bacon_summary <- bacon_result %>%
    group_by(type) %>%
    summarise(
      weight = sum(weight),
      avg_estimate = weighted.mean(estimate, weight),
      .groups = "drop"
    )
  print(bacon_summary)
}

## ---------------------------------------------------------------------------
## 4. Cohort-specific ATTs
## ---------------------------------------------------------------------------

cat("\n--- Cohort-specific ATTs ---\n")

agg_cohort <- aggte(results$cs_hc_emp, type = "group")
cohort_atts <- data.frame(
  cohort = agg_cohort$egt,
  att = agg_cohort$att.egt,
  se = agg_cohort$se.egt
)
cat("Cohort-specific ATTs (Healthcare Employment):\n")
print(cohort_atts)

## ---------------------------------------------------------------------------
## 5. Not-yet-treated as control (alternative to never-treated)
## ---------------------------------------------------------------------------

cat("\n--- Alternative control: Not-yet-treated ---\n")

cs_nyt <- att_gt(
  yname  = "log_hc_emp",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_hc_emp)),
  control_group = "notyettreated",
  base_period = "universal"
)

agg_nyt <- aggte(cs_nyt, type = "simple")
cat(sprintf("ATT with not-yet-treated control: %.4f (SE: %.4f, p: %.4f)\n",
            agg_nyt$overall.att, agg_nyt$overall.se,
            2 * pnorm(-abs(agg_nyt$overall.att / agg_nyt$overall.se))))

es_nyt <- aggte(cs_nyt, type = "dynamic", min_e = -5, max_e = 6)

## ---------------------------------------------------------------------------
## 6. Excluding COVID years (2020-2021) sensitivity
## ---------------------------------------------------------------------------

cat("\n--- Excluding COVID years (2020-2021) ---\n")

cs_nocovid <- att_gt(
  yname  = "log_hc_emp",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_hc_emp), !year %in% c(2020, 2021)),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_nocovid <- aggte(cs_nocovid, type = "simple")
cat(sprintf("ATT excluding COVID: %.4f (SE: %.4f, p: %.4f)\n",
            agg_nocovid$overall.att, agg_nocovid$overall.se,
            2 * pnorm(-abs(agg_nocovid$overall.att / agg_nocovid$overall.se))))

## ---------------------------------------------------------------------------
## 7. Pre-2020 cohorts only (cleanest identification)
## ---------------------------------------------------------------------------

cat("\n--- Pre-2020 cohorts only ---\n")

cs_pre2020 <- att_gt(
  yname  = "log_hc_emp",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>%
    filter(!is.na(log_hc_emp)) %>%
    filter(first_treat == 0 | first_treat <= 2019),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_pre2020 <- aggte(cs_pre2020, type = "simple")
cat(sprintf("ATT pre-2020 cohorts: %.4f (SE: %.4f, p: %.4f)\n",
            agg_pre2020$overall.att, agg_pre2020$overall.se,
            2 * pnorm(-abs(agg_pre2020$overall.att / agg_pre2020$overall.se))))

## ---------------------------------------------------------------------------
## 8. Retail establishments placebo
## ---------------------------------------------------------------------------

cat("\n--- Placebo: Placebo: Accomm. Establishments ---\n")

cs_ret_estabs <- att_gt(
  yname  = "log_plc_estabs",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_plc_estabs)),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_ret_estabs <- aggte(cs_ret_estabs, type = "simple")
cat(sprintf("Placebo ATT (Placebo: Accomm. Estabs): %.4f (SE: %.4f, p: %.4f)\n",
            agg_ret_estabs$overall.att, agg_ret_estabs$overall.se,
            2 * pnorm(-abs(agg_ret_estabs$overall.att / agg_ret_estabs$overall.se))))

## ---------------------------------------------------------------------------
## 9. Save robustness results
## ---------------------------------------------------------------------------

robust_results <- list(
  # Placebo
  cs_retail       = cs_retail,
  agg_retail      = agg_retail,
  es_retail       = es_retail,
  cs_ret_estabs   = cs_ret_estabs,
  agg_ret_estabs  = agg_ret_estabs,

  # Sub-industry
  cs_hosp      = cs_hosp,
  agg_hosp     = agg_hosp,
  es_hosp      = es_hosp,

  # Bacon
  bacon_result = bacon_result,

  # Cohort ATTs
  agg_cohort   = agg_cohort,
  cohort_atts  = cohort_atts,

  # Alternative control
  cs_nyt       = cs_nyt,
  agg_nyt      = agg_nyt,
  es_nyt       = es_nyt,

  # COVID exclusion
  agg_nocovid  = agg_nocovid,

  # Pre-2020 cohorts
  agg_pre2020  = agg_pre2020
)

saveRDS(robust_results, file.path(data_dir, "robust_results.rds"))

# Summary table
robust_table <- tibble(
  Specification = c(
    "Main (CS, never-treated)",
    "Not-yet-treated control",
    "Excluding COVID (2020-21)",
    "Pre-2020 cohorts only",
    "Placebo: Accommodation Employment",
    "Placebo: Accommodation Establishments",
    "Sub-industry: Hospitals"
  ),
  ATT = c(
    results$agg_hc_emp$overall.att,
    agg_nyt$overall.att,
    agg_nocovid$overall.att,
    agg_pre2020$overall.att,
    agg_retail$overall.att,
    agg_ret_estabs$overall.att,
    agg_hosp$overall.att
  ),
  SE = c(
    results$agg_hc_emp$overall.se,
    agg_nyt$overall.se,
    agg_nocovid$overall.se,
    agg_pre2020$overall.se,
    agg_retail$overall.se,
    agg_ret_estabs$overall.se,
    agg_hosp$overall.se
  )
) %>%
  mutate(
    pval = 2 * pnorm(-abs(ATT / SE)),
    stars = case_when(
      pval < 0.01 ~ "***",
      pval < 0.05 ~ "**",
      pval < 0.10 ~ "*",
      TRUE ~ ""
    )
  )

write_csv(robust_table, file.path(data_dir, "robustness_table.csv"))

cat("\nRobustness summary:\n")
print(robust_table)

cat("\n=== Robustness checks complete ===\n")
