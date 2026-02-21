# ============================================================================
# 06_tables.R — Generate all tables (LaTeX format)
# Multi-Level Political Alignment and Local Development in India
# ============================================================================

source("00_packages.R")
library(kableExtra)
data_dir <- "../data"
tab_dir  <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)
load(file.path(data_dir, "analysis_data.RData"))
load(file.path(data_dir, "main_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

rdd_data_state <- results$rdd_data_state
rdd_data_center <- results$rdd_data_center

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================
cat("Generating Table 1: Summary Statistics...\n")

# Prepare statistics
sumstats <- data.table(
  Variable = c("Vote margin", "State-aligned", "Center-aligned",
               "Double-aligned", "Log nightlights (post)",
               "Log nightlights (pre)", "Population (Census 2011)",
               "Literacy rate", "SC share", "ST share",
               "Work participation rate", "Agriculture share"),
  N = c(nrow(rdd_data_state),
        nrow(rdd_data_state),
        nrow(rdd_data_state),
        nrow(rdd_data_state),
        sum(!is.na(rdd_data_state$post_log_nl)),
        sum(!is.na(rdd_data_state$pre_log_nl)),
        sum(!is.na(rdd_data_state$pop)),
        sum(!is.na(rdd_data_state$lit_rate)),
        sum(!is.na(rdd_data_state$sc_share)),
        sum(!is.na(rdd_data_state$st_share)),
        sum(!is.na(rdd_data_state$work_rate)),
        sum(!is.na(rdd_data_state$ag_share))),
  Mean = c(mean(abs(rdd_data_state$rdd_margin_state), na.rm = TRUE),
           mean(rdd_data_state$state_aligned, na.rm = TRUE),
           mean(rdd_data_state$center_aligned, na.rm = TRUE),
           mean(rdd_data_state$double_aligned, na.rm = TRUE),
           mean(rdd_data_state$post_log_nl, na.rm = TRUE),
           mean(rdd_data_state$pre_log_nl, na.rm = TRUE),
           mean(rdd_data_state$pop, na.rm = TRUE),
           mean(rdd_data_state$lit_rate, na.rm = TRUE),
           mean(rdd_data_state$sc_share, na.rm = TRUE),
           mean(rdd_data_state$st_share, na.rm = TRUE),
           mean(rdd_data_state$work_rate, na.rm = TRUE),
           mean(rdd_data_state$ag_share, na.rm = TRUE)),
  SD = c(sd(abs(rdd_data_state$rdd_margin_state), na.rm = TRUE),
         sd(rdd_data_state$state_aligned, na.rm = TRUE),
         sd(rdd_data_state$center_aligned, na.rm = TRUE),
         sd(rdd_data_state$double_aligned, na.rm = TRUE),
         sd(rdd_data_state$post_log_nl, na.rm = TRUE),
         sd(rdd_data_state$pre_log_nl, na.rm = TRUE),
         sd(rdd_data_state$pop, na.rm = TRUE),
         sd(rdd_data_state$lit_rate, na.rm = TRUE),
         sd(rdd_data_state$sc_share, na.rm = TRUE),
         sd(rdd_data_state$st_share, na.rm = TRUE),
         sd(rdd_data_state$work_rate, na.rm = TRUE),
         sd(rdd_data_state$ag_share, na.rm = TRUE))
)

sumstats[, Mean := round(Mean, 3)]
sumstats[, SD := round(SD, 3)]
sumstats[, N := format(N, big.mark = ",")]

tab1 <- kable(sumstats, format = "latex", booktabs = TRUE,
              caption = "Summary Statistics: State-Alignment RDD Sample",
              label = "tab:sumstats") |>
  kable_styling(latex_options = c("hold_position"))

writeLines(tab1, file.path(tab_dir, "table1_sumstats.tex"))

# ============================================================================
# Table 2: Main RDD Results
# ============================================================================
cat("Generating Table 2: Main RDD Results...\n")

# Build results table manually
main_results <- data.table(
  ` ` = c("RDD Estimate (τ)", "Std. Error", "p-value",
          "Bandwidth (h)", "Eff. N (left)", "Eff. N (right)",
          "Polynomial", "Kernel"),
  `State Alignment` = c(
    sprintf("%.4f", results$rdd_state$coef[1]),
    sprintf("(%.4f)", results$rdd_state$se[1]),
    sprintf("%.3f", results$rdd_state$pv[1]),
    sprintf("%.4f", results$rdd_state$bws[1, 1]),
    as.character(results$rdd_state$N_h[1]),
    as.character(results$rdd_state$N_h[2]),
    "Local linear", "Triangular"
  ),
  `Center Alignment` = c(
    sprintf("%.4f", results$rdd_center$coef[1]),
    sprintf("(%.4f)", results$rdd_center$se[1]),
    sprintf("%.3f", results$rdd_center$pv[1]),
    sprintf("%.4f", results$rdd_center$bws[1, 1]),
    as.character(results$rdd_center$N_h[1]),
    as.character(results$rdd_center$N_h[2]),
    "Local linear", "Triangular"
  )
)

tab2 <- kable(main_results, format = "latex", booktabs = TRUE,
              caption = "Main RDD Results: Effect of Political Alignment on Nighttime Lights",
              label = "tab:main_rdd", align = c("l", "c", "c")) |>
  kable_styling(latex_options = c("hold_position")) |>
  add_header_above(c(" " = 1, "Log Nightlights" = 2))

writeLines(tab2, file.path(tab_dir, "table2_main_rdd.tex"))

# ============================================================================
# Table 3: Robustness — Bandwidth Sensitivity
# ============================================================================
cat("Generating Table 3: Bandwidth Sensitivity...\n")

bw_tab <- robustness$bw_results_state[h %in% c(0.05, 0.08, 0.10, 0.12, 0.14, 0.16, 0.20)]
bw_tab[, est_str := sprintf("%.4f", est)]
bw_tab[, se_str := sprintf("(%.4f)", se)]
bw_tab[, pval_str := sprintf("%.3f", pval)]
bw_tab[, h_str := sprintf("%.0f%%", h * 100)]

tab3_data <- bw_tab[, .(Bandwidth = h_str, N = format(n, big.mark = ","),
                          Estimate = est_str, `Std. Error` = se_str,
                          `p-value` = pval_str)]

tab3 <- kable(tab3_data, format = "latex", booktabs = TRUE,
              caption = "Bandwidth Sensitivity: State Alignment RDD",
              label = "tab:bw_sensitivity", align = c("c", "r", "c", "c", "c")) |>
  kable_styling(latex_options = c("hold_position"))

writeLines(tab3, file.path(tab_dir, "table3_bw_sensitivity.tex"))

# ============================================================================
# Table 4: Robustness — Alternative Specifications
# ============================================================================
cat("Generating Table 4: Alternative Specifications...\n")

# Build Table 4 programmatically from saved robustness results
poly <- robustness$poly_results
kern <- robustness$kernel_results
donut <- robustness$donut_results
gen <- robustness$gen_result
era <- robustness$era_results

alt_rows <- list()
# Baseline (p=1, triangular) from poly_results
if (nrow(poly) > 0 && any(poly$p_ord == 1)) {
  b <- poly[p_ord == 1]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Baseline (local linear, triangular)",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
# Quadratic
if (nrow(poly) > 0 && any(poly$p_ord == 2)) {
  b <- poly[p_ord == 2]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Quadratic polynomial",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
# Cubic
if (nrow(poly) > 0 && any(poly$p_ord == 3)) {
  b <- poly[p_ord == 3]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Cubic polynomial",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
# Kernels (skip triangular as it's the baseline)
if (nrow(kern) > 0 && any(kern$kernel == "uniform")) {
  b <- kern[kernel == "uniform"]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Uniform kernel",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
if (nrow(kern) > 0 && any(kern$kernel == "epanechnikov")) {
  b <- kern[kernel == "epanechnikov"]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Epanechnikov kernel",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
# Donut specifications
if (nrow(donut) > 0 && any(donut$donut == 0.01)) {
  b <- donut[donut == 0.01]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Donut (drop < 1\\%)",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
if (nrow(donut) > 0 && any(donut$donut == 0.02)) {
  b <- donut[donut == 0.02]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Donut (drop < 2\\%)",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
# General constituencies
if (!is.null(gen)) {
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "General constituencies only",
    Estimate = sprintf("%.4f", gen$est), `Std. Error` = sprintf("(%.4f)", gen$se),
    `p-value` = sprintf("%.3f", gen$pval))
}
# Era split
if (nrow(era) > 0 && any(era$era == "pre2014")) {
  b <- era[era == "pre2014"]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Pre-2014 elections",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
if (nrow(era) > 0 && any(era$era == "post2014")) {
  b <- era[era == "post2014"]
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Post-2014 elections",
    Estimate = sprintf("%.4f", b$est), `Std. Error` = sprintf("(%.4f)", b$se),
    `p-value` = sprintf("%.3f", b$pval))
}
# Covariate-adjusted
cov_adj <- robustness$cov_adj_result
if (!is.null(cov_adj)) {
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Covariate-adjusted (pop, SC share)",
    Estimate = sprintf("%.4f", cov_adj$est), `Std. Error` = sprintf("(%.4f)", cov_adj$se),
    `p-value` = sprintf("%.3f", cov_adj$pval))
}
# Complete window
cw <- robustness$cw_result
if (!is.null(cw)) {
  alt_rows[[length(alt_rows) + 1]] <- data.table(
    Specification = "Complete VIIRS window (2012+ elections)",
    Estimate = sprintf("%.4f", cw$est), `Std. Error` = sprintf("(%.4f)", cw$se),
    `p-value` = sprintf("%.3f", cw$pval))
}
alt_specs <- rbindlist(alt_rows)

tab4 <- kable(alt_specs, format = "latex", booktabs = TRUE,
              caption = "Robustness: Alternative Specifications for State Alignment",
              label = "tab:robustness", align = c("l", "c", "c", "c")) |>
  kable_styling(latex_options = c("hold_position", "scale_down"))

writeLines(tab4, file.path(tab_dir, "table4_robustness.tex"))

# ============================================================================
# Table 5: Covariate Balance
# ============================================================================
cat("Generating Table 5: Covariate Balance...\n")

covariates <- c("log_baseline", "pop", "lit_rate", "sc_share",
                "st_share", "work_rate", "ag_share")
cov_labels <- c("Log Baseline NL", "Population", "Literacy Rate",
                "SC Share", "ST Share", "Work Participation",
                "Agriculture Share")

bal_tab <- data.table()
for (i in seq_along(covariates)) {
  cv <- covariates[i]
  y <- rdd_data_state[[cv]]
  x <- rdd_data_state$rdd_margin_state
  valid <- !is.na(y) & !is.na(x) & is.finite(y)
  if (sum(valid) >= 100) {
    bal <- tryCatch({
      rdrobust(y = y[valid], x = x[valid], c = 0, p = 1, kernel = "triangular")
    }, error = function(e) NULL)
    if (!is.null(bal)) {
      bal_tab <- rbind(bal_tab, data.table(
        Covariate = cov_labels[i],
        Estimate = sprintf("%.4f", bal$coef[1]),
        `Std. Error` = sprintf("(%.4f)", bal$se[1]),
        `p-value` = sprintf("%.3f", bal$pv[1])
      ))
    }
  }
}

tab5 <- kable(bal_tab, format = "latex", booktabs = TRUE,
              caption = "Covariate Balance at the State-Alignment Cutoff",
              label = "tab:balance", align = c("l", "c", "c", "c")) |>
  kable_styling(latex_options = c("hold_position"))

writeLines(tab5, file.path(tab_dir, "table5_balance.tex"))

# ============================================================================
# Table 6: Dynamic Effects
# ============================================================================
cat("Generating Table 6: Dynamic Effects...\n")

dyn_s <- robustness$dynamic_state
dyn_c <- robustness$dynamic_center

dyn_tab <- merge(
  dyn_s[, .(rel_year,
             `State Est.` = sprintf("%.4f", est),
             `State SE` = sprintf("(%.4f)", se),
             `State p` = sprintf("%.3f", pval))],
  dyn_c[, .(rel_year,
             `Center Est.` = sprintf("%.4f", est),
             `Center SE` = sprintf("(%.4f)", se),
             `Center p` = sprintf("%.3f", pval))],
  by = "rel_year", all = TRUE
)
setnames(dyn_tab, "rel_year", "Year")

tab6 <- kable(dyn_tab, format = "latex", booktabs = TRUE,
              caption = "Dynamic Alignment Effects by Years Since Election",
              label = "tab:dynamic", align = c("c", rep("c", 6))) |>
  kable_styling(latex_options = c("hold_position")) |>
  add_header_above(c(" " = 1, "State Alignment" = 3, "Center Alignment" = 3))

writeLines(tab6, file.path(tab_dir, "table6_dynamic.tex"))

cat("\nAll tables saved to", tab_dir, "\n")
