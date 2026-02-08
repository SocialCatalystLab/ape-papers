##############################################################################
# 04_robustness.R - Robustness checks
# Paper 137: Medicaid Postpartum Coverage Extensions
##############################################################################

source("00_packages.R")

# Set seed for reproducibility of all bootstrap procedures
set.seed(20240137)

cat("=== Robustness Checks ===\n")

# Load data
state_year_pp <- fread(file.path(data_dir, "state_year_postpartum.csv"))
df_postpartum <- fread(file.path(data_dir, "acs_postpartum.csv"))
df_pp_highinc <- fread(file.path(data_dir, "acs_postpartum_highinc.csv"))
df_nonpostpartum <- fread(file.path(data_dir, "acs_nonpostpartum_lowinc.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

# Prepare state_year_pp for CS-DiD
state_year_pp <- state_year_pp %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(medicaid_rate))

# =========================================================
# 1. Placebo Test: High-Income Postpartum Women
# =========================================================

cat("\n--- Placebo: High-Income Postpartum Women ---\n")

# These women are not affected by Medicaid policy
state_year_highinc <- df_pp_highinc %>%
  group_by(state_fips, year, first_treat) %>%
  summarise(
    medicaid_rate = weighted.mean(medicaid, weight, na.rm = TRUE),
    uninsured_rate = weighted.mean(uninsured, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(medicaid_rate))

if (n_distinct(state_year_highinc$state_id[state_year_highinc$first_treat == 0]) > 0) {
  cs_placebo_highinc <- tryCatch({
    att_gt(
      yname = "medicaid_rate",
      tname = "year",
      idname = "state_id",
      gname = "first_treat",
      data = as.data.frame(state_year_highinc),
      control_group = "nevertreated",
      weightsname = "total_weight",
      bstrap = TRUE,
      biters = 1000
    )
  }, error = function(e) {
    cat("  CS-DiD failed for high-income placebo:", e$message, "\n")
    NULL
  })

  if (!is.null(cs_placebo_highinc)) {
    cs_agg_placebo_highinc <- aggte(cs_placebo_highinc, type = "simple")
    cat(sprintf("Placebo ATT (Medicaid, High-Income PP): %.4f (SE: %.4f)\n",
                cs_agg_placebo_highinc$overall.att, cs_agg_placebo_highinc$overall.se))
  }
}

# =========================================================
# 2. Placebo Test: Non-Postpartum Low-Income Women
# =========================================================

cat("\n--- Placebo: Non-Postpartum Low-Income Women ---\n")

state_year_nonpp <- df_nonpostpartum %>%
  group_by(state_fips, year, first_treat) %>%
  summarise(
    medicaid_rate = weighted.mean(medicaid, weight, na.rm = TRUE),
    uninsured_rate = weighted.mean(uninsured, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(medicaid_rate))

cs_placebo_nonpp <- tryCatch({
  att_gt(
    yname = "medicaid_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_nonpp),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  CS-DiD failed for non-postpartum placebo:", e$message, "\n")
  NULL
})

if (!is.null(cs_placebo_nonpp)) {
  cs_agg_placebo_nonpp <- aggte(cs_placebo_nonpp, type = "simple")
  cat(sprintf("Placebo ATT (Medicaid, Non-PP Low-Income): %.4f (SE: %.4f)\n",
              cs_agg_placebo_nonpp$overall.att, cs_agg_placebo_nonpp$overall.se))
}

# =========================================================
# 3. Excluding PHE Period
# =========================================================

cat("\n--- Excluding PHE Period (2020-2022) ---\n")

state_year_no_phe <- state_year_pp %>%
  filter(year < 2020 | year > 2022)

cs_no_phe <- tryCatch({
  att_gt(
    yname = "medicaid_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_no_phe),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  CS-DiD failed for no-PHE sample:", e$message, "\n")
  NULL
})

if (!is.null(cs_no_phe)) {
  cs_agg_no_phe <- aggte(cs_no_phe, type = "simple")
  cat(sprintf("ATT (Medicaid, excl. PHE): %.4f (SE: %.4f)\n",
              cs_agg_no_phe$overall.att, cs_agg_no_phe$overall.se))
}

# =========================================================
# 4. TWFE with controls (individual level)
# =========================================================

cat("\n--- TWFE with Individual Controls ---\n")

twfe_controls <- feols(
  medicaid ~ treated + age + I(age^2) + married + factor(educ) + factor(race_eth)
  | state_fips + year,
  data = df_postpartum,
  weights = ~weight,
  cluster = ~state_fips
)

cat("TWFE with controls:\n")
summary(twfe_controls)

# =========================================================
# 5. Goodman-Bacon Decomposition
# =========================================================

cat("\n--- Goodman-Bacon Decomposition ---\n")

# Need balanced panel for bacon decomposition
# Use state-year panel with complete years
balanced_panel <- state_year_pp %>%
  group_by(state_id) %>%
  filter(n() == max(state_year_pp %>% count(state_id) %>% pull(n))) %>%
  ungroup()

if (requireNamespace("bacondecomp", quietly = TRUE)) {
  library(bacondecomp)
  bacon_result <- tryCatch({
    bacon(medicaid_rate ~ treated,
          data = as.data.frame(balanced_panel),
          id_var = "state_id",
          time_var = "year")
  }, error = function(e) {
    cat("  Bacon decomposition failed:", e$message, "\n")
    NULL
  })

  if (!is.null(bacon_result)) {
    cat("\nBacon Decomposition:\n")
    print(bacon_result %>%
            group_by(type) %>%
            summarise(
              n_comparisons = n(),
              mean_estimate = weighted.mean(estimate, weight),
              total_weight = sum(weight)
            ))
  }
}

# =========================================================
# 6. Medicaid Expansion Heterogeneity
# =========================================================

cat("\n--- Medicaid Expansion Heterogeneity ---\n")

# States that expanded Medicaid under ACA (as of 2019)
expansion_states <- c(2, 4, 6, 8, 9, 10, 11, 15, 17, 18, 19, 20, 21, 22, 23,
                      24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 38, 39,
                      40, 41, 42, 44, 46, 49, 50, 51, 53, 54)

state_year_pp <- state_year_pp %>%
  mutate(expansion = as.integer(state_fips %in% expansion_states))

# TWFE with expansion interaction
twfe_expansion <- feols(
  medicaid_rate ~ treated * expansion | state_fips + year,
  data = state_year_pp,
  weights = ~total_weight,
  cluster = ~state_fips
)

cat("TWFE with Medicaid Expansion Interaction:\n")
summary(twfe_expansion)

# =========================================================
# 7. Wild Cluster Bootstrap
# =========================================================

cat("\n--- Wild Cluster Bootstrap ---\n")

if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)

  twfe_base <- feols(
    medicaid_rate ~ treated | state_fips + year,
    data = state_year_pp,
    weights = ~total_weight,
    cluster = ~state_fips
  )

  boot_result <- tryCatch({
    boottest(twfe_base,
             param = "treated",
             clustid = "state_fips",
             B = 9999,
             type = "rademacher")
  }, error = function(e) {
    cat("  WCB failed:", e$message, "\n")
    NULL
  })

  if (!is.null(boot_result)) {
    cat("Wild Cluster Bootstrap p-value:\n")
    print(summary(boot_result))
  }
} else {
  cat("  fwildclusterboot not installed, skipping WCB\n")
}

# =========================================================
# 8. Save robustness results
# =========================================================

robustness_results <- list(
  placebo_highinc = if (exists("cs_agg_placebo_highinc")) cs_agg_placebo_highinc else NULL,
  placebo_nonpp = if (exists("cs_agg_placebo_nonpp")) cs_agg_placebo_nonpp else NULL,
  no_phe = if (exists("cs_agg_no_phe")) cs_agg_no_phe else NULL,
  twfe_controls = twfe_controls,
  twfe_expansion = twfe_expansion,
  bacon = if (exists("bacon_result")) bacon_result else NULL,
  boot = if (exists("boot_result")) boot_result else NULL
)

saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
