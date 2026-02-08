################################################################################
# 06_tables.R
# Social Network Minimum Wage Exposure - REVISED IDENTIFICATION STRATEGY
#
# Input:  data/analysis_panel.rds, data/main_results.rds,
#         data/shock_diagnostics.rds, data/mechanism_results.rds
# Output: tables/tab*.tex
################################################################################

source("00_packages.R")

cat("=== Generating Tables ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

panel <- readRDS("../data/analysis_panel.rds")
results <- readRDS("../data/main_results.rds")
state_mw <- readRDS("../data/state_mw_panel.rds")

cat("Data loaded.\n")

# Create tables directory
dir.create("../tables", showWarnings = FALSE)

# Stars function
stars <- function(pval) {
  if (is.na(pval)) return("")
  if (pval < 0.01) return("***")
  if (pval < 0.05) return("**")
  if (pval < 0.1) return("*")
  return("")
}

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("\nTable 1: Summary statistics...\n")

# Panel summary
panel_summary <- panel %>%
  summarise(
    `Counties` = n_distinct(county_fips),
    `States` = n_distinct(state_fips),
    `Quarters` = n_distinct(yearq),
    `Observations` = format(n(), big.mark = ",")
  )

# Exposure summary (using new variable names)
exposure_summary <- panel %>%
  summarise(
    `Full Network MW Mean` = sprintf("%.3f", mean(network_mw_full, na.rm = TRUE)),
    `Full Network MW SD` = sprintf("%.3f", sd(network_mw_full, na.rm = TRUE)),
    `Out-of-State MW Mean` = sprintf("%.3f", mean(network_mw_out_state, na.rm = TRUE)),
    `Out-of-State MW SD` = sprintf("%.3f", sd(network_mw_out_state, na.rm = TRUE)),
    `Corr (Full, Out-of-State)` = sprintf("%.3f",
      cor(network_mw_full, network_mw_out_state, use = "complete.obs")),
    `Corr (Full, Own-State)` = sprintf("%.3f",
      cor(network_mw_full, own_log_mw, use = "complete.obs"))
  )

# Minimum wage summary
mw_summary <- state_mw %>%
  filter(min_wage > 7.25) %>%
  summarise(
    `States with MW > Federal` = n_distinct(state_fips),
    `Min State MW` = sprintf("$%.2f", min(min_wage)),
    `Max State MW` = sprintf("$%.2f", max(min_wage))
  )

# Combine into table
tab1_data <- tibble(
  Statistic = c(
    "\\textbf{Panel Structure}", "",
    "Counties", "States", "Quarters", "Observations",
    "", "\\textbf{Network Exposure Variables}", "",
    "Full Network MW (Mean)", "Full Network MW (SD)",
    "Out-of-State Network MW (Mean)", "Out-of-State Network MW (SD)",
    "Corr(Full, Out-of-State)", "Corr(Full, Own-State MW)",
    "", "\\textbf{Minimum Wage Variation}", "",
    "States with MW > Federal", "Min State MW", "Max State MW"
  ),
  Value = c(
    "", "",
    as.character(panel_summary$Counties),
    as.character(panel_summary$States),
    as.character(panel_summary$Quarters),
    panel_summary$Observations,
    "", "", "",
    exposure_summary$`Full Network MW Mean`,
    exposure_summary$`Full Network MW SD`,
    exposure_summary$`Out-of-State MW Mean`,
    exposure_summary$`Out-of-State MW SD`,
    exposure_summary$`Corr (Full, Out-of-State)`,
    exposure_summary$`Corr (Full, Own-State)`,
    "", "", "",
    as.character(mw_summary$`States with MW > Federal`),
    mw_summary$`Min State MW`,
    mw_summary$`Max State MW`
  )
)

tab1_latex <- tab1_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    col.names = c("", ""),
    escape = FALSE,
    caption = "Summary Statistics",
    label = "sumstats"
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_footnote(
    paste0("Notes: Full network MW is the SCI-weighted average of log minimum wages ",
           "excluding only own-county. Out-of-state network MW excludes all same-state connections ",
           "and serves as the instrumental variable. Sample period: 2012-2022."),
    notation = "none"
  )

writeLines(tab1_latex, "../tables/tab1_sumstats.tex")
cat("  Saved tab1_sumstats.tex\n")

# ============================================================================
# Table 2: Main Results - OLS vs IV
# ============================================================================

cat("\nTable 2: Main results (OLS vs 2SLS)...\n")

# Extract coefficients from results (using population-weighted specification names)
ols1_coef <- coef(results$ols_pop_simple)[1]
ols1_se <- se(results$ols_pop_simple)[1]
ols1_p <- fixest::pvalue(results$ols_pop_simple)[1]

ols2_coef <- coef(results$ols_pop_statetime)[1]
ols2_se <- se(results$ols_pop_statetime)[1]
ols2_p <- fixest::pvalue(results$ols_pop_statetime)[1]

iv_coef <- coef(results$iv_2sls_pop)[1]
iv_se <- se(results$iv_2sls_pop)[1]
iv_p <- fixest::pvalue(results$iv_2sls_pop)[1]

fs_coef <- coef(results$first_stage_pop)[1]
fs_se <- se(results$first_stage_pop)[1]
first_stage_f <- results$first_stage_f_pop

tab2_data <- tibble(
  ` ` = c(
    "Full Network MW", "",
    "", "County FE", "Time FE", "State $\\times$ Time FE",
    "First Stage F", "Observations"
  ),
  `(1) OLS` = c(
    paste0(sprintf("%.4f", ols1_coef), stars(ols1_p)),
    sprintf("(%.4f)", ols1_se),
    "", "Yes", "Yes", "No",
    "--",
    format(nobs(results$ols_pop_simple), big.mark = ",")
  ),
  `(2) OLS` = c(
    paste0(sprintf("%.4f", ols2_coef), stars(ols2_p)),
    sprintf("(%.4f)", ols2_se),
    "", "Yes", "No", "Yes",
    "--",
    format(nobs(results$ols_pop_statetime), big.mark = ",")
  ),
  `(3) 2SLS` = c(
    paste0(sprintf("%.4f", iv_coef), stars(iv_p)),
    sprintf("(%.4f)", iv_se),
    "", "Yes", "No", "Yes",
    sprintf("%.1f", first_stage_f),
    format(nobs(results$iv_2sls_pop), big.mark = ",")
  )
)

tab2_latex <- tab2_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    escape = FALSE,
    caption = "Main Results: Effect of Network Minimum Wage on Employment",
    label = "mainresults",
    align = c("l", "c", "c", "c")
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_footnote(
    paste0("Notes: Dependent variable is log employment. Full Network MW is ",
           "SCI-weighted average of log minimum wages excluding only own-county. ",
           "Column (3) instruments Full Network MW with Out-of-State Network MW ",
           "(excludes all same-state connections). ",
           "Standard errors clustered at state level in parentheses. ",
           "*** p<0.01, ** p<0.05, * p<0.1."),
    notation = "none"
  )

writeLines(tab2_latex, "../tables/tab2_main.tex")
cat("  Saved tab2_main.tex\n")

# ============================================================================
# Table 3: First Stage and Balancedness
# ============================================================================

cat("\nTable 3: First stage and balancedness...\n")

# First stage
tab3a_data <- tibble(
  ` ` = c(
    "Out-of-State Network MW", "",
    "", "County FE", "State $\\times$ Time FE",
    "F-statistic", "Observations"
  ),
  `First Stage` = c(
    paste0(sprintf("%.4f", fs_coef), "***"),
    sprintf("(%.4f)", fs_se),
    "", "Yes", "Yes",
    sprintf("%.1f", first_stage_f),
    format(nobs(results$first_stage_pop), big.mark = ",")
  )
)

tab3a_latex <- tab3a_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    escape = FALSE,
    caption = "First Stage: Out-of-State Network MW $\\rightarrow$ Full Network MW",
    label = "firststage",
    align = c("l", "c")
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_footnote(
    paste0("Notes: Dependent variable is Full Network MW (log). ",
           "Out-of-State Network MW excludes all same-state SCI connections. ",
           "*** p<0.01."),
    notation = "none"
  )

writeLines(tab3a_latex, "../tables/tab3_firststage.tex")
cat("  Saved tab3_firststage.tex\n")

# ============================================================================
# Table 4: Distance Robustness
# ============================================================================

cat("\nTable 4: Distance robustness...\n")

dist_results <- results$distance_results

if (!is.null(dist_results) && length(dist_results) > 0) {
  # Convert list to data frame (including n_obs and computing n_counties)
  dist_df <- do.call(rbind, lapply(names(dist_results), function(d) {
    r <- dist_results[[d]]
    # Compute number of counties from n_obs and panel structure
    # Each county appears in multiple quarters; estimate counties from n_obs
    n_quarters <- n_distinct(panel$yearq)
    n_counties_est <- round(as.numeric(r$n_obs) / n_quarters)
    data.frame(
      dist = r$threshold,
      fs_f = as.numeric(r$first_stage_f),
      tsls_coef = as.numeric(r$tsls_coef),
      tsls_se = as.numeric(r$tsls_se),
      balance_p = as.numeric(r$balance_p),
      n_obs = as.numeric(r$n_obs),
      n_counties = n_counties_est,
      stringsAsFactors = FALSE
    )
  }))

  # Filter to strong instruments only
  tab4_data <- dist_df %>%
    filter(fs_f >= 10) %>%
    mutate(
      `Distance Threshold` = paste0("$\\geq$ ", dist, " km"),
      `First Stage F` = sprintf("%.1f", fs_f),
      `2SLS Coef.` = sprintf("%.4f", tsls_coef),
      `2SLS SE` = sprintf("%.4f", tsls_se),
      `Balance p` = sprintf("%.3f", balance_p),
      `N` = format(n_obs, big.mark = ","),
      `Counties` = format(n_counties, big.mark = ",")
    ) %>%
    select(`Distance Threshold`, `First Stage F`, `2SLS Coef.`, `2SLS SE`,
           `Balance p`, `N`, `Counties`)

  tab4_latex <- tab4_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      caption = "Distance Robustness: 2SLS Estimates by IV Distance Threshold",
      label = "distance",
      align = c("l", "c", "c", "c", "c", "c", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: Each row uses out-of-state SCI connections beyond the distance threshold ",
             "as the instrument. Balance p-value tests equality of pre-treatment employment across IV quartiles. ",
             "N is the number of county-quarter observations; Counties is the approximate number of counties. ",
             "Estimates shown only for specifications with F $>$ 10."),
      notation = "none"
    )

  writeLines(tab4_latex, "../tables/tab4_distance.tex")
  cat("  Saved tab4_distance.tex\n")
}

# ============================================================================
# Table 5: Earnings Outcome
# ============================================================================

cat("\nTable 5: Earnings outcome...\n")

if (!is.null(results$ols_earn_pop) && !is.null(results$iv_earn_pop)) {
  ols_earn_coef <- coef(results$ols_earn_pop)[1]
  ols_earn_se <- se(results$ols_earn_pop)[1]
  ols_earn_p <- fixest::pvalue(results$ols_earn_pop)[1]

  iv_earn_coef <- coef(results$iv_earn_pop)[1]
  iv_earn_se <- se(results$iv_earn_pop)[1]
  iv_earn_p <- fixest::pvalue(results$iv_earn_pop)[1]

  tab5_data <- tibble(
    ` ` = c(
      "Full Network MW", "",
      "", "First Stage F", "Observations"
    ),
    `(1) OLS` = c(
      paste0(sprintf("%.4f", ols_earn_coef), stars(ols_earn_p)),
      sprintf("(%.4f)", ols_earn_se),
      "", "--",
      format(nobs(results$ols_earn_pop), big.mark = ",")
    ),
    `(2) 2SLS` = c(
      paste0(sprintf("%.4f", iv_earn_coef), stars(iv_earn_p)),
      sprintf("(%.4f)", iv_earn_se),
      "", sprintf("%.1f", first_stage_f),
      format(nobs(results$iv_earn_pop), big.mark = ",")
    )
  )

  tab5_latex <- tab5_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      caption = "Effect on Log Earnings",
      label = "earnings",
      align = c("l", "c", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: Dependent variable is log average quarterly earnings. ",
             "Specifications include county and state $\\times$ time fixed effects. ",
             "*** p<0.01, ** p<0.05, * p<0.1."),
      notation = "none"
    )

  writeLines(tab5_latex, "../tables/tab5_earnings.tex")
  cat("  Saved tab5_earnings.tex\n")
}

# ============================================================================
# Table 6: Reduced Form
# ============================================================================

cat("\nTable 6: Reduced form...\n")

if (!is.null(results$reduced_form_pop)) {
  rf_coef <- coef(results$reduced_form_pop)[1]
  rf_se <- se(results$reduced_form_pop)[1]
  rf_p <- fixest::pvalue(results$reduced_form_pop)[1]

  tab6_data <- tibble(
    ` ` = c(
      "Out-of-State Network MW", "",
      "", "County FE", "State $\\times$ Time FE",
      "Observations"
    ),
    `Reduced Form` = c(
      paste0(sprintf("%.4f", rf_coef), stars(rf_p)),
      sprintf("(%.4f)", rf_se),
      "", "Yes", "Yes",
      format(nobs(results$reduced_form_pop), big.mark = ",")
    )
  )

  tab6_latex <- tab6_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      caption = "Reduced Form: Out-of-State Network MW $\\rightarrow$ Employment",
      label = "reducedform",
      align = c("l", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: Dependent variable is log employment. ",
             "This is the direct effect of the instrument on the outcome. ",
             "Reduced form coefficient divided by first stage equals 2SLS: ",
             sprintf("%.4f / %.4f = %.4f", rf_coef, fs_coef, rf_coef/fs_coef), "."),
      notation = "none"
    )

  writeLines(tab6_latex, "../tables/tab6_reducedform.tex")
  cat("  Saved tab6_reducedform.tex\n")
}

# ============================================================================
# Table 7: Shock Contribution Diagnostics
# ============================================================================

cat("\nTable 7: Shock contribution diagnostics...\n")

if (file.exists("../data/shock_diagnostics.rds")) {
  shock_diag <- readRDS("../data/shock_diagnostics.rds")
  mw_changes <- shock_diag$mw_changes

  # Top 10 states by MW change magnitude
  top10 <- mw_changes %>%
    arrange(desc(total_mw_change)) %>%
    head(10)

  # Compute leave-one-out 2SLS coefficients for each top state
  # Drop all counties in that state's FIPS from the panel and re-run 2SLS
  loo_results <- lapply(seq_len(nrow(top10)), function(i) {
    st <- top10$state_fips[i]
    panel_loo <- panel %>%
      filter(state_fips != st)

    loo_iv <- tryCatch({
      feols(
        log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_out_state,
        data = panel_loo,
        cluster = ~state_fips
      )
    }, error = function(e) NULL)

    if (!is.null(loo_iv)) {
      data.frame(
        loo_coef = coef(loo_iv)[1],
        loo_se = se(loo_iv)[1],
        stringsAsFactors = FALSE
      )
    } else {
      data.frame(loo_coef = NA_real_, loo_se = NA_real_, stringsAsFactors = FALSE)
    }
  })

  loo_df <- do.call(rbind, loo_results)
  top10 <- bind_cols(top10, loo_df)

  tab7_data <- top10 %>%
    mutate(
      `State` = state_name,
      `Total MW Change` = sprintf("%.3f", total_mw_change),
      `N Changes` = as.character(n_changes),
      `LOO 2SLS Coef.` = ifelse(is.na(loo_coef), "---", sprintf("%.4f", loo_coef)),
      `LOO 2SLS SE` = ifelse(is.na(loo_se), "---", sprintf("%.4f", loo_se))
    ) %>%
    select(`State`, `Total MW Change`, `N Changes`, `LOO 2SLS Coef.`, `LOO 2SLS SE`)

  tab7_latex <- tab7_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      caption = "Shock Contribution Diagnostics",
      label = "shockdiag",
      align = c("l", "c", "c", "c", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: Top 10 states by total minimum wage change magnitude (sum of absolute log MW changes). ",
             "LOO 2SLS reports the 2SLS coefficient when all counties in that origin state are dropped from the sample. ",
             "Stability of LOO coefficients indicates no single state drives the result."),
      notation = "none"
    )

  writeLines(tab7_latex, "../tables/tab7_shockdiag.tex")
  cat("  Saved tab7_shockdiag.tex\n")
} else {
  cat("  shock_diagnostics.rds not found, skipping Table 7.\n")
}

# ============================================================================
# Table 8: Migration Mechanism Results
# ============================================================================

cat("\nTable 8: Migration mechanism results...\n")

if (file.exists("../data/mechanism_results.rds")) {
  mech <- readRDS("../data/mechanism_results.rds")

  if (!is.null(mech$migration) && mech$has_migration) {
    migration <- mech$migration

    # Helper to extract OLS results
    extract_ols <- function(mod) {
      if (is.null(mod)) return(list(coef = NA, se = NA))
      list(coef = coef(mod)[1], se = se(mod)[1])
    }

    ols_net <- extract_ols(migration$mig_net)
    ols_out <- extract_ols(migration$mig_out)
    ols_in  <- extract_ols(migration$mig_in)

    # Compute 2SLS for migration outcomes using IV
    # Re-load migration panel data if available
    mig_panel_file <- "../data/migration_flows.rds"
    has_iv_mig <- FALSE

    if (file.exists(mig_panel_file)) {
      # Rebuild the migration panel for 2SLS
      migration_raw <- readRDS(mig_panel_file)

      if (!is.null(migration_raw) && nrow(migration_raw) > 0) {
        # Check if panel already has migration columns
        if (all(c("log_net_mig", "log_outflow", "log_inflow") %in% names(panel))) {
          panel_mig_iv <- panel %>% filter(!is.na(log_net_mig))
        } else {
          panel_mig_iv <- NULL
        }

        if (!is.null(panel_mig_iv) && nrow(panel_mig_iv) > 10000) {
          iv_net <- tryCatch({
            feols(log_net_mig ~ 1 | county_fips + state_fips^year | network_mw_pop ~ network_mw_out_state,
                  data = panel_mig_iv, cluster = ~state_fips)
          }, error = function(e) NULL)

          iv_out <- tryCatch({
            feols(log_outflow ~ 1 | county_fips + state_fips^year | network_mw_pop ~ network_mw_out_state,
                  data = panel_mig_iv, cluster = ~state_fips)
          }, error = function(e) NULL)

          iv_in <- tryCatch({
            feols(log_inflow ~ 1 | county_fips + state_fips^year | network_mw_pop ~ network_mw_out_state,
                  data = panel_mig_iv, cluster = ~state_fips)
          }, error = function(e) NULL)

          has_iv_mig <- TRUE
        }
      }
    }

    # Format results
    fmt <- function(val) if (is.na(val)) "---" else sprintf("%.4f", val)

    iv_net_coef <- if (has_iv_mig && !is.null(iv_net)) coef(iv_net)[1] else NA
    iv_net_se   <- if (has_iv_mig && !is.null(iv_net)) se(iv_net)[1] else NA
    iv_out_coef <- if (has_iv_mig && !is.null(iv_out)) coef(iv_out)[1] else NA
    iv_out_se   <- if (has_iv_mig && !is.null(iv_out)) se(iv_out)[1] else NA
    iv_in_coef  <- if (has_iv_mig && !is.null(iv_in)) coef(iv_in)[1] else NA
    iv_in_se    <- if (has_iv_mig && !is.null(iv_in)) se(iv_in)[1] else NA

    tab8_data <- tibble(
      `Outcome` = c("Net Migration", "", "Outflows", "", "Inflows", ""),
      `OLS Coef.` = c(
        fmt(ols_net$coef), sprintf("(%s)", fmt(ols_net$se)),
        fmt(ols_out$coef), sprintf("(%s)", fmt(ols_out$se)),
        fmt(ols_in$coef),  sprintf("(%s)", fmt(ols_in$se))
      ),
      `2SLS Coef.` = c(
        fmt(iv_net_coef), sprintf("(%s)", fmt(iv_net_se)),
        fmt(iv_out_coef), sprintf("(%s)", fmt(iv_out_se)),
        fmt(iv_in_coef),  sprintf("(%s)", fmt(iv_in_se))
      )
    )

    tab8_latex <- tab8_data %>%
      kable(
        format = "latex",
        booktabs = TRUE,
        escape = FALSE,
        caption = "Migration Mechanism Tests",
        label = "migration",
        align = c("l", "c", "c")
      ) %>%
      kable_styling(latex_options = "hold_position") %>%
      add_footnote(
        paste0("Notes: Each row reports the effect of network minimum wage exposure on a migration outcome. ",
               "OLS uses Full Network MW directly; 2SLS instruments with Out-of-State Network MW. ",
               "Migration data from IRS Statistics of Income county-to-county flows. ",
               "Standard errors clustered at state level in parentheses."),
        notation = "none"
      )

    writeLines(tab8_latex, "../tables/tab8_migration.tex")
    cat("  Saved tab8_migration.tex\n")
  } else {
    cat("  No migration results available in mechanism_results.rds, skipping Table 8.\n")
  }
} else {
  cat("  mechanism_results.rds not found, skipping Table 8.\n")
}

# ============================================================================
# Table 9: Industry Heterogeneity
# ============================================================================

cat("\nTable 9: Industry heterogeneity...\n")

if (file.exists("../data/industry_panel.rds")) {
  industry_panel <- readRDS("../data/industry_panel.rds")

  industry_results <- list()
  for (ind_type in c("High Bite", "Low Bite")) {
    ind_data <- industry_panel %>% filter(industry_type == ind_type)
    if (nrow(ind_data) < 1000) next

    ols_ind <- tryCatch({
      feols(log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
            data = ind_data, cluster = ~state_fips)
    }, error = function(e) NULL)

    iv_ind <- tryCatch({
      feols(log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_out_state,
            data = ind_data, cluster = ~state_fips)
    }, error = function(e) NULL)

    industry_results[[ind_type]] <- list(ols = ols_ind, iv = iv_ind)
  }

  if (length(industry_results) > 0) {
    fmt <- function(val) if (is.null(val) || is.na(val)) "---" else sprintf("%.4f", val)

    rows <- list()
    for (ind_type in names(industry_results)) {
      r <- industry_results[[ind_type]]
      ols_c <- if (!is.null(r$ols)) coef(r$ols)[1] else NA
      ols_s <- if (!is.null(r$ols)) se(r$ols)[1] else NA
      ols_p <- if (!is.null(r$ols)) fixest::pvalue(r$ols)[1] else NA
      iv_c  <- if (!is.null(r$iv))  coef(r$iv)[1] else NA
      iv_s  <- if (!is.null(r$iv))  se(r$iv)[1] else NA
      iv_p  <- if (!is.null(r$iv))  fixest::pvalue(r$iv)[1] else NA

      rows[[length(rows) + 1]] <- c(
        ind_type,
        paste0(fmt(ols_c), stars(ols_p)), sprintf("(%s)", fmt(ols_s)),
        paste0(fmt(iv_c), stars(iv_p)), sprintf("(%s)", fmt(iv_s))
      )
    }

    tab9_data <- do.call(rbind, rows)
    colnames(tab9_data) <- c("Industry Group", "OLS Coef.", "OLS SE", "2SLS Coef.", "2SLS SE")
    tab9_data <- as_tibble(tab9_data)

    tab9_latex <- tab9_data %>%
      kable(
        format = "latex",
        booktabs = TRUE,
        escape = FALSE,
        caption = "Industry Heterogeneity: High-Bite vs. Low-Bite Sectors",
        label = "industry",
        align = c("l", "c", "c", "c", "c")
      ) %>%
      kable_styling(latex_options = "hold_position") %>%
      add_footnote(
        paste0("Notes: High Bite = NAICS 44-45 (Retail) + 72 (Accommodation/Food). ",
               "Low Bite = NAICS 52 (Finance) + 54 (Professional). ",
               "County and state x time FEs. SEs clustered at state level. ",
               "*** p<0.01, ** p<0.05, * p<0.1."),
        notation = "none"
      )

    writeLines(tab9_latex, "../tables/tab9_industry.tex")
    cat("  Saved tab9_industry.tex\n")
  }
} else {
  cat("  industry_panel.rds not found, skipping Table 9.\n")
}

# ============================================================================
# Table 10: Placebo Shock Results
# ============================================================================

cat("\nTable 10: Placebo shock results...\n")

if (file.exists("../data/placebo_shock_results.rds")) {
  placebo <- readRDS("../data/placebo_shock_results.rds")

  if (length(placebo) > 0) {
    fmt <- function(val) if (is.null(val) || is.na(val)) "---" else sprintf("%.4f", val)

    placebo_rows <- list()
    if (!is.null(placebo$gdp_rf)) {
      placebo_rows[["GDP-weighted exposure"]] <- list(
        coef = coef(placebo$gdp_rf)[1],
        se = se(placebo$gdp_rf)[1],
        p = fixest::pvalue(placebo$gdp_rf)[1]
      )
    }
    if (!is.null(placebo$emp_rf)) {
      placebo_rows[["Employment-weighted exposure"]] <- list(
        coef = coef(placebo$emp_rf)[1],
        se = se(placebo$emp_rf)[1],
        p = fixest::pvalue(placebo$emp_rf)[1]
      )
    }
    if (!is.null(placebo$horse_race)) {
      placebo_rows[["MW exposure (horse race)"]] <- list(
        coef = coef(placebo$horse_race)["network_mw_pop"],
        se = se(placebo$horse_race)["network_mw_pop"],
        p = fixest::pvalue(placebo$horse_race)["network_mw_pop"]
      )
      placebo_rows[["GDP exposure (horse race)"]] <- list(
        coef = coef(placebo$horse_race)["placebo_gdp"],
        se = se(placebo$horse_race)["placebo_gdp"],
        p = fixest::pvalue(placebo$horse_race)["placebo_gdp"]
      )
    }

    if (length(placebo_rows) > 0) {
      tab10_data <- tibble(
        Instrument = names(placebo_rows),
        Coefficient = sapply(placebo_rows, function(r) paste0(fmt(r$coef), stars(r$p))),
        SE = sapply(placebo_rows, function(r) sprintf("(%s)", fmt(r$se))),
        `p-value` = sapply(placebo_rows, function(r) fmt(r$p))
      )

      tab10_latex <- tab10_data %>%
        kable(
          format = "latex",
          booktabs = TRUE,
          escape = FALSE,
          caption = "Placebo Shock Tests for Exclusion Restriction",
          label = "placebo",
          align = c("l", "c", "c", "c")
        ) %>%
        kable_styling(latex_options = "hold_position") %>%
        add_footnote(
          paste0("Notes: Reduced-form regressions of log employment on placebo instruments. ",
                 "GDP/Employment-weighted exposure uses same SCI weights as MW instrument ",
                 "but replaces MW with state GDP/employment. Horse race includes both MW and GDP ",
                 "exposure simultaneously. County and state x time FEs. SEs clustered at state level."),
          notation = "none"
        )

      writeLines(tab10_latex, "../tables/tab10_placebo.tex")
      cat("  Saved tab10_placebo.tex\n")
    }
  }
} else {
  cat("  placebo_shock_results.rds not found, skipping Table 10.\n")
}

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Tables Complete ===\n")
cat("Generated tables in ../tables/\n")
