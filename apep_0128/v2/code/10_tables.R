## ============================================================================
## 10_tables.R — LaTeX Tables for Paper
## Paper 184: Dutch Nitrogen Crisis & Housing (Sub-national DiD)
## ============================================================================

source("00_packages.R")

cat("=== 10_tables.R: Generating LaTeX tables ===\n")

dir.create("../tables", recursive = TRUE, showWarnings = FALSE)

# Force modelsummary to use kableExtra backend for LaTeX (not tinytable)
options(modelsummary_factory_latex = "kableExtra")
options(modelsummary_format_numeric_latex = "plain")

## --- Load all results ---
panel_prices   <- readRDS("../data/processed/panel_prices.rds")
panel_permits  <- readRDS("../data/processed/panel_permits.rds")

# Load treatment_vars -- try gpkg first (has geometry for st_drop_geometry), else use RDS
treatment_vars <- tryCatch({
  library(sf)
  tv <- st_read("../data/processed/treatment_vars_geo.gpkg", quiet = TRUE)
  tv <- tv %>% rename(muni_code = gemeentecode)
  tv
}, error = function(e) {
  readRDS("../data/processed/treatment_vars.rds")
})

fs_results   <- tryCatch(readRDS("../data/processed/first_stage_results.rds"), error = function(e) NULL)
main_results <- tryCatch(readRDS("../data/processed/main_results.rds"), error = function(e) NULL)
rob_results  <- tryCatch(readRDS("../data/processed/robustness_results.rds"), error = function(e) NULL)
scm_results  <- tryCatch(readRDS("../data/processed/nnls_scm_results.rds"), error = function(e) NULL)

## =========================================================================
## TABLE 1: Summary Statistics by N2000 Tertile
## =========================================================================
cat("Table 1: Summary statistics...\n")

tryCatch({
  sum_stats <- panel_prices %>%
    filter(year <= 2018) %>%  # Pre-treatment only
    mutate(group = case_when(
      n2000_tertile == 1 ~ "Low N2000",
      n2000_tertile == 2 ~ "Medium N2000",
      n2000_tertile == 3 ~ "High N2000"
    )) %>%
    group_by(group) %>%
    summarize(
      `N Municipalities` = n_distinct(muni_code),
      `Mean Price (EUR)` = sprintf("%.0f", mean(price, na.rm = TRUE)),
      `SD Price` = sprintf("%.0f", sd(price, na.rm = TRUE)),
      `Mean N2000 Share` = sprintf("%.3f", mean(n2000_share, na.rm = TRUE)),
      `Mean Dist N2000 (km)` = sprintf("%.1f", mean(dist_n2000_km, na.rm = TRUE)),
      `Mean Population` = sprintf("%.0f", mean(aantalInwoners, na.rm = TRUE)),
      .groups = "drop"
    )

  # LaTeX output
  latex_tab1 <- kable(sum_stats, format = "latex", booktabs = TRUE,
                      caption = "Summary Statistics by Natura 2000 Exposure Tertile (Pre-Treatment, 2012--2018)",
                      label = "tab:summary") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(general = "Municipalities grouped into tertiles by share of area designated as Natura 2000. Statistics computed over pre-treatment years (2012--2018). Price is average transaction price for existing dwellings (CBS 83625ENG).",
             threeparttable = TRUE)

  writeLines(latex_tab1, "../tables/tab1_summary.tex")
  cat("  Saved: tab1_summary.tex\n")
}, error = function(e) cat("  Table 1 error:", conditionMessage(e), "\n"))

## =========================================================================
## TABLE 2: First Stage — Building Permits DiD
## =========================================================================
cat("Table 2: First stage (permits)...\n")

if (!is.null(fs_results)) {
  tryCatch({
    models_fs <- list(
      "(1) Basic" = fs_results$m1,
      "(2) Prov x Qtr FE" = fs_results$m2,
      "(3) Permits/1000" = fs_results$m3,
      "(4) Pre-COVID" = fs_results$m4
    )

    latex_tab2 <- modelsummary(
      models_fs,
      output = "latex",
      stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
      coef_rename = c("n2000_share:post" = "N2000 Share $\\times$ Post"),
      gof_map = c("nobs", "r.squared", "FE: muni_code", "FE: yq"),
      title = "First Stage: Effect of Nitrogen Ruling on Building Permits",
      notes = "Clustered standard errors at municipality level in parentheses. Post = 2019Q2 onwards. N2000 Share is the fraction of municipality area designated as Natura 2000. Column (4) restricts to pre-COVID period (through 2019Q4).",
      escape = FALSE
    )

    writeLines(latex_tab2, "../tables/tab2_first_stage.tex")
    cat("  Saved: tab2_first_stage.tex\n")
  }, error = function(e) cat("  Table 2 error:", conditionMessage(e), "\n"))
}

## =========================================================================
## TABLE 3: Main Results — Housing Price DiD
## =========================================================================
cat("Table 3: Main results (prices)...\n")

if (!is.null(main_results)) {
  tryCatch({
    models_main <- list(
      "(1) Basic" = main_results$p1,
      "(2) Controls" = main_results$p2,
      "(3) Prov x Year FE" = main_results$p3,
      "(4) Pre-COVID" = main_results$p4,
      "(5) Full Sample" = main_results$p5,
      "(6) Prov Cluster" = main_results$p6
    )

    latex_tab3 <- modelsummary(
      models_main,
      output = "latex",
      stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
      coef_rename = c("n2000_share:post" = "N2000 Share $\\times$ Post"),
      gof_map = c("nobs", "r.squared", "FE: muni_code", "FE: year", "FE: province^year"),
      title = "Main Results: Effect of Nitrogen Ruling on Housing Prices",
      notes = "Dependent variable: log average purchase price. Clustered standard errors at municipality level (columns 1--5) or province level (column 6) in parentheses. N2000 Share is fraction of municipality area in Natura 2000. Post = year $\\geq$ 2019.",
      escape = FALSE
    )

    writeLines(latex_tab3, "../tables/tab3_main_results.tex")
    cat("  Saved: tab3_main_results.tex\n")
  }, error = function(e) cat("  Table 3 error:", conditionMessage(e), "\n"))
}

## =========================================================================
## TABLE 4: Alternative Treatment Definitions
## =========================================================================
cat("Table 4: Alternative treatments...\n")

if (!is.null(rob_results)) {
  tryCatch({
    models_alt <- list(
      "(1) N2000 Share" = rob_results$rob_full,
      "(2) Within 5km" = rob_results$rob_5km,
      "(3) Within 10km" = rob_results$rob_10km,
      "(4) Within 15km" = rob_results$rob_15km
    )

    latex_tab4 <- modelsummary(
      models_alt,
      output = "latex",
      stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
      gof_map = c("nobs", "r.squared"),
      title = "Robustness: Alternative Treatment Definitions",
      notes = "Dependent variable: log average purchase price. Municipality and year FE. Clustered SEs at municipality level. Column (1): continuous N2000 area share. Columns (2)--(4): binary indicator for municipality centroid within specified distance of nearest Natura 2000 site.",
      escape = FALSE
    )

    writeLines(latex_tab4, "../tables/tab4_alt_treatment.tex")
    cat("  Saved: tab4_alt_treatment.tex\n")
  }, error = function(e) cat("  Table 4 error:", conditionMessage(e), "\n"))
}

## =========================================================================
## TABLE 5: Heterogeneity — Randstad vs Rest
## =========================================================================
cat("Table 5: Heterogeneity...\n")

if (!is.null(rob_results)) {
  tryCatch({
    models_het <- list(
      "(1) Full Sample" = rob_results$rob_full,
      "(2) Randstad" = rob_results$rob_randstad_only,
      "(3) Non-Randstad" = rob_results$rob_no_randstad
    )

    latex_tab5 <- modelsummary(
      models_het,
      output = "latex",
      stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
      gof_map = c("nobs", "r.squared"),
      title = "Heterogeneity: Randstad vs. Non-Randstad Municipalities",
      notes = "Dependent variable: log average purchase price. Municipality and year FE. Clustered SEs at municipality level. Randstad: Noord-Holland, Zuid-Holland, Utrecht, Flevoland.",
      escape = FALSE
    )

    writeLines(latex_tab5, "../tables/tab5_heterogeneity.tex")
    cat("  Saved: tab5_heterogeneity.tex\n")
  }, error = function(e) cat("  Table 5 error:", conditionMessage(e), "\n"))
}

## =========================================================================
## TABLE 6: Placebo Treatment Dates
## =========================================================================
cat("Table 6: Placebo tests...\n")

if (!is.null(rob_results) && !is.null(rob_results$placebo_results)) {
  tryCatch({
    placebo_df <- do.call(rbind, lapply(names(rob_results$placebo_results), function(yr) {
      ct <- rob_results$placebo_results[[yr]]
      data.frame(
        `Placebo Year` = yr,
        Estimate = sprintf("%.4f", ct$coef),
        SE = sprintf("%.4f", ct$se),
        `p-value` = sprintf("%.3f", ct$pval),
        check.names = FALSE
      )
    }))

    latex_tab6 <- kable(placebo_df, format = "latex", booktabs = TRUE,
                        caption = "Placebo Tests: Falsified Treatment Dates",
                        label = "tab:placebo") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(general = "Each row re-estimates the DiD using a placebo treatment date, restricting to pre-2019 data. Under the null of parallel trends, all coefficients should be insignificant.",
               threeparttable = TRUE)

    writeLines(latex_tab6, "../tables/tab6_placebo.tex")
    cat("  Saved: tab6_placebo.tex\n")
  }, error = function(e) cat("  Table 6 error:", conditionMessage(e), "\n"))
}

## =========================================================================
## TABLE 7: Augmented SCM + SDID (National Complement)
## =========================================================================
cat("Table 7: National SCM complement...\n")

if (!is.null(scm_results)) {
  tryCatch({
    scm_df <- data.frame(
      Method = c("NNLS SCM (Original)", "Augmented SCM", "Synthetic DiD"),
      ATT = c(sprintf("%.2f", scm_results$att), "---", "---"),
      SE = c(sprintf("%.2f", scm_results$att_se), "---", "---"),
      `Pre-RMSE` = c(sprintf("%.2f", scm_results$pre_rmse), "---", "---"),
      `Pre-R2` = c(sprintf("%.3f", scm_results$pre_r2), "---", "---"),
      check.names = FALSE
    )

    # Update with augsynth results if available
    asc_results <- tryCatch(readRDS("../data/processed/augsynth_results.rds"), error = function(e) NULL)
    if (!is.null(asc_results)) {
      summ <- asc_results$asc_summ
      if (!is.null(summ$average_att)) {
        scm_df$ATT[2] <- sprintf("%.2f", summ$average_att$Estimate)
        scm_df$SE[2] <- sprintf("%.2f", summ$average_att$Std.Error)
      }
    }

    latex_tab7 <- kable(scm_df, format = "latex", booktabs = TRUE,
                        caption = "National-Level Complement: Synthetic Control Estimates",
                        label = "tab:scm") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(general = "ATT is average treatment effect on the treated (index points). SE for NNLS is time-series SD/$\\sqrt{n}$ (not valid for inference). Augmented SCM uses Ridge augmentation with conformal inference. SDID combines synthetic control with difference-in-differences weighting. All methods use 15 European donor countries and treatment date 2019Q2.",
               threeparttable = TRUE, escape = FALSE)

    writeLines(latex_tab7, "../tables/tab7_scm_complement.tex")
    cat("  Saved: tab7_scm_complement.tex\n")
  }, error = function(e) cat("  Table 7 error:", conditionMessage(e), "\n"))
}

## =========================================================================
## TABLE 8: Treatment Variable Summary
## =========================================================================
cat("Table 8: Treatment variable distribution...\n")

tryCatch({
  tv <- treatment_vars
  if (inherits(tv, "sf")) tv <- st_drop_geometry(tv)
  tv <- tv %>%
    summarize(
      N = n(),
      `Pct with N2000` = sprintf("%.1f%%", mean(n2000_share > 0) * 100),
      `Mean Share (all)` = sprintf("%.3f", mean(n2000_share)),
      `Mean Share (>0)` = sprintf("%.3f", mean(n2000_share[n2000_share > 0])),
      `Median Share (>0)` = sprintf("%.3f", median(n2000_share[n2000_share > 0])),
      `Max Share` = sprintf("%.3f", max(n2000_share)),
      `Mean Dist (km)` = sprintf("%.1f", mean(dist_n2000_km)),
      `Min Dist (km)` = sprintf("%.1f", min(dist_n2000_km))
    ) %>% t()

  colnames(tv) <- "Value"
  tv <- as.data.frame(tv)
  tv$Statistic <- rownames(tv)
  tv <- tv[, c("Statistic", "Value")]

  latex_tab8 <- kable(tv, format = "latex", booktabs = TRUE, row.names = FALSE,
                      caption = "Distribution of Natura 2000 Treatment Variables",
                      label = "tab:treatment_dist") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(general = "N2000 Share: fraction of municipality area designated as Natura 2000. Distance: km from municipality centroid to nearest Natura 2000 boundary. Computed from EEA Natura 2000 end-2023 spatial data intersected with CBS 2019 municipality boundaries.",
             threeparttable = TRUE)

  writeLines(latex_tab8, "../tables/tab8_treatment_dist.tex")
  cat("  Saved: tab8_treatment_dist.tex\n")
}, error = function(e) cat("  Table 8 error:", conditionMessage(e), "\n"))

cat("\n=== All tables generated ===\n")
cat("Files in tables/:\n")
print(list.files("../tables"))
