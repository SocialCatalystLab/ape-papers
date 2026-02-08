################################################################################
# 03_main_analysis.R — Primary DiD Regressions and Event Studies
# Paper: Digital Exodus or Digital Magnet?
################################################################################

source(file.path(dirname(sys.frame(1)$ofile %||% "00_packages.R"), "00_packages.R"))

cat("=== Main Analysis ===\n")

###############################################################################
# 1. Load analysis-ready data
###############################################################################

qcew_panel <- read_csv(file.path(DATA_DIR, "qcew_panel.csv"),
                       show_col_types = FALSE)
bfs_panel  <- read_csv(file.path(DATA_DIR, "bfs_panel.csv"),
                       show_col_types = FALSE)

if (file.exists(file.path(DATA_DIR, "irs_migration_panel.csv"))) {
  irs_migration <- read_csv(file.path(DATA_DIR, "irs_migration_panel.csv"),
                            show_col_types = FALSE)
} else {
  irs_migration <- tibble()
}

privacy_laws <- read_csv(file.path(DATA_DIR, "privacy_law_dates.csv"),
                         show_col_types = FALSE)

cat("Data loaded. QCEW:", nrow(qcew_panel), "rows\n")

###############################################################################
# 2. TWFE baseline — Log employment by industry
###############################################################################

cat("\n--- TWFE Regressions ---\n")

# Ensure factor variables
qcew_panel <- qcew_panel %>%
  mutate(
    state_f = factor(state_abbr),
    time_f  = factor(yearqtr)
  )

industries <- c("Information", "Software Publishers",
                "Computer Systems Design", "Finance & Insurance",
                "Construction")

twfe_results <- list()

for (ind in industries) {
  df <- qcew_panel %>% filter(industry == ind)
  if (nrow(df) < 100) next

  # TWFE with state + time FE
  fit <- feols(log_emp ~ treat | state_f + time_f,
               data = df, cluster = ~state_f)
  twfe_results[[ind]] <- fit

  cat(sprintf("  %-25s β = %7.4f (SE = %.4f) p = %.4f  N = %d\n",
              ind,
              coef(fit)["treat"],
              se(fit)["treat"],
              fixest::pvalue(fit)["treat"],
              nobs(fit)))
}

# Save TWFE results
saveRDS(twfe_results, file.path(DATA_DIR, "twfe_results.rds"))

###############################################################################
# 3. Callaway-Sant'Anna Group-Time ATTs
###############################################################################

cat("\n--- Callaway-Sant'Anna DiD ---\n")

# Prepare data for CS-DiD
# Need: group variable (first treatment period), time variable, id variable

# For CS-DiD, group = first treatment period (in quarters since start)
# Convert yearqtr to integer period
all_yearqtrs <- sort(unique(qcew_panel$yearqtr))
period_map <- tibble(
  yearqtr = all_yearqtrs,
  period = seq_along(all_yearqtrs)
)

cs_data <- qcew_panel %>%
  left_join(period_map, by = "yearqtr") %>%
  mutate(
    # CS-DiD group: period of first treatment (0 for never-treated)
    G = ifelse(treated_state == 1,
               period_map$period[match(treat_yearqtr, period_map$yearqtr)],
               0)
  ) %>%
  # Handle cases where treat_yearqtr is beyond our data
  mutate(G = ifelse(is.na(G) & treated_state == 1, 0, G))

cs_results <- list()

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- cs_data %>% filter(industry == ind, !is.na(period), !is.na(state_id))

  # Drop states with all NA or constant outcomes
  state_var <- df %>%
    group_by(state_id) %>%
    summarize(sd_y = sd(log_emp, na.rm = TRUE), .groups = "drop") %>%
    filter(!is.na(sd_y), sd_y > 0)

  df <- df %>% filter(state_id %in% state_var$state_id)

  if (length(unique(df$G[df$G > 0])) < 2) {
    cat("  Skipping", ind, "— insufficient treatment groups\n")
    next
  }

  tryCatch({
    cs_out <- att_gt(
      yname = "log_emp",
      tname = "period",
      idname = "state_id",
      gname = "G",
      data = as.data.frame(df),
      control_group = "nevertreated",
      est_method = "dr",  # Doubly robust
      base_period = "universal",
      clustervars = "state_id",
      print_details = FALSE
    )

    cs_results[[ind]] <- cs_out

    # Aggregate to overall ATT
    agg_simple <- aggte(cs_out, type = "simple")
    cat(sprintf("  %-25s ATT = %7.4f (SE = %.4f) [%.4f, %.4f]\n",
                ind,
                agg_simple$overall.att,
                agg_simple$overall.se,
                agg_simple$overall.att - 1.96 * agg_simple$overall.se,
                agg_simple$overall.att + 1.96 * agg_simple$overall.se))

  }, error = function(e) {
    cat("  CS-DiD failed for", ind, ":", e$message, "\n")
  })
}

saveRDS(cs_results, file.path(DATA_DIR, "cs_results.rds"))

###############################################################################
# 4. Event Study — Dynamic Treatment Effects
###############################################################################

cat("\n--- Event Study (TWFE) ---\n")

# Create relative time indicators for event study
# Use TWFE event study with Sun-Abraham correction later in robustness

es_results <- list()

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>%
    filter(industry == ind, treated_state == 1) %>%
    mutate(
      # Bin relative time: cap at [-8, +8] quarters
      rel_time_binned = pmin(pmax(rel_time, -8), 8)
    ) %>%
    bind_rows(
      qcew_panel %>%
        filter(industry == ind, treated_state == 0) %>%
        mutate(rel_time_binned = 0)  # Never-treated are always "at treatment"
    )

  # TWFE event study using fixest's i() function
  tryCatch({
    fit_es <- feols(
      log_emp ~ i(rel_time_binned, treated_state, ref = -1) | state_f + time_f,
      data = df %>% filter(!is.na(rel_time_binned) | treated_state == 0),
      cluster = ~state_f
    )

    es_results[[ind]] <- fit_es
    cat("  Event study for", ind, "estimated.\n")

  }, error = function(e) {
    cat("  Event study failed for", ind, ":", e$message, "\n")
  })
}

saveRDS(es_results, file.path(DATA_DIR, "es_results.rds"))

###############################################################################
# 5. CS-DiD Event Study (Dynamic Aggregation)
###############################################################################

cat("\n--- CS-DiD Dynamic Effects ---\n")

cs_dynamic <- list()

for (ind in names(cs_results)) {
  tryCatch({
    agg_dyn <- aggte(cs_results[[ind]], type = "dynamic",
                     min_e = -8, max_e = 8)
    cs_dynamic[[ind]] <- agg_dyn
    cat("  Dynamic ATT for", ind, ": periods",
        min(agg_dyn$egt), "to", max(agg_dyn$egt), "\n")
  }, error = function(e) {
    cat("  Dynamic aggregation failed for", ind, ":", e$message, "\n")
  })
}

saveRDS(cs_dynamic, file.path(DATA_DIR, "cs_dynamic.rds"))

###############################################################################
# 6. BFS Business Applications Analysis
###############################################################################

cat("\n--- BFS Business Applications ---\n")

bfs_panel <- bfs_panel %>%
  mutate(
    state_f = factor(state_abbr),
    time_f  = factor(yearqtr)
  )

bfs_sectors <- c("TOTAL", "NAICS51", "NAICS54")
bfs_sector_names <- c("Total", "Information", "Professional/Technical")

bfs_results <- list()

for (i in seq_along(bfs_sectors)) {
  sec <- bfs_sectors[i]
  sec_name <- bfs_sector_names[i]

  df <- bfs_panel %>% filter(naics_sector == sec)
  if (nrow(df) < 100) next

  fit <- feols(log_apps ~ treat | state_f + time_f,
               data = df, cluster = ~state_f)
  bfs_results[[sec_name]] <- fit

  cat(sprintf("  %-25s β = %7.4f (SE = %.4f) p = %.4f  N = %d\n",
              sec_name,
              coef(fit)["treat"],
              se(fit)["treat"],
              fixest::pvalue(fit)["treat"],
              nobs(fit)))
}

saveRDS(bfs_results, file.path(DATA_DIR, "bfs_results.rds"))

###############################################################################
# 7. IRS Migration Analysis
###############################################################################

if (nrow(irs_migration) > 0) {
  cat("\n--- IRS Migration Analysis ---\n")

  irs_migration <- irs_migration %>%
    mutate(state_f = factor(state_abbr))

  # Net migration
  fit_mig <- feols(net_migration_rate ~ treat | state_f + year,
                   data = irs_migration, cluster = ~state_f)

  cat(sprintf("  Net migration rate: β = %7.4f (SE = %.4f) p = %.4f\n",
              coef(fit_mig)["treat"],
              se(fit_mig)["treat"],
              fixest::pvalue(fit_mig)["treat"]))

  # AGI-weighted migration
  fit_agi <- feols(log_net_agi ~ treat | state_f + year,
                   data = irs_migration, cluster = ~state_f)

  cat(sprintf("  Log net AGI:        β = %7.4f (SE = %.4f) p = %.4f\n",
              coef(fit_agi)["treat"],
              se(fit_agi)["treat"],
              fixest::pvalue(fit_agi)["treat"]))

  saveRDS(list(migration = fit_mig, agi = fit_agi),
          file.path(DATA_DIR, "irs_results.rds"))
}

###############################################################################
# 8. Wage Analysis (Test for compositional changes)
###############################################################################

cat("\n--- Wage Regressions ---\n")

wage_results <- list()

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>% filter(industry == ind)
  if (nrow(df) < 100) next

  fit <- feols(log_wage ~ treat | state_f + time_f,
               data = df, cluster = ~state_f)
  wage_results[[ind]] <- fit

  cat(sprintf("  %-25s β = %7.4f (SE = %.4f) p = %.4f\n",
              ind,
              coef(fit)["treat"],
              se(fit)["treat"],
              fixest::pvalue(fit)["treat"]))
}

saveRDS(wage_results, file.path(DATA_DIR, "wage_results.rds"))

###############################################################################
# 9. Establishment counts (extensive margin)
###############################################################################

cat("\n--- Establishment Regressions ---\n")

estab_results <- list()

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>% filter(industry == ind)
  if (nrow(df) < 100) next

  fit <- feols(log_estabs ~ treat | state_f + time_f,
               data = df, cluster = ~state_f)
  estab_results[[ind]] <- fit

  cat(sprintf("  %-25s β = %7.4f (SE = %.4f) p = %.4f\n",
              ind,
              coef(fit)["treat"],
              se(fit)["treat"],
              fixest::pvalue(fit)["treat"]))
}

saveRDS(estab_results, file.path(DATA_DIR, "estab_results.rds"))

###############################################################################
# 10. Goodman-Bacon Decomposition
###############################################################################

cat("\n--- Goodman-Bacon Decomposition ---\n")

# For the Information sector
info_df <- qcew_panel %>%
  filter(industry == "Information") %>%
  group_by(state_abbr, yearqtr) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(
    state_num = as.numeric(factor(state_abbr)),
    time_num = as.numeric(factor(yearqtr))
  )

tryCatch({
  bacon_out <- bacon(
    log_emp ~ treat,
    data = as.data.frame(info_df),
    id_var = "state_num",
    time_var = "time_num"
  )

  cat("Bacon decomposition complete.\n")
  cat("Components:\n")
  bacon_summary <- bacon_out %>%
    group_by(type) %>%
    summarize(
      n_pairs = n(),
      avg_estimate = weighted.mean(estimate, weight),
      total_weight = sum(weight),
      .groups = "drop"
    )
  print(bacon_summary)

  saveRDS(bacon_out, file.path(DATA_DIR, "bacon_decomp.rds"))

}, error = function(e) {
  cat("Bacon decomposition failed:", e$message, "\n")
})

cat("\n=== Main analysis complete ===\n")
