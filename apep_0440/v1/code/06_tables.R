###############################################################################
# 06_tables.R — Generate all tables
# Paper: Social Insurance Thresholds and Late-Career Underemployment
# APEP-0440
###############################################################################

source("00_packages.R")

cat("=== Loading Data ===\n")
dt <- as.data.table(read_parquet("../data/analysis_employed.parquet"))
results <- readRDS("../data/main_results.rds")

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================
cat("\n=== Table 1: Summary Statistics ===\n")

# Compute weighted stats for key variables
make_stats <- function(data, label) {
  data.table(
    Sample = label,
    N = format(nrow(data), big.mark = ","),
    `Mean Age` = sprintf("%.1f", weighted.mean(data$AGEP, data$PWGTP)),
    `Female (\\%)` = sprintf("%.1f", 100 * weighted.mean(data$female, data$PWGTP)),
    `Bachelor's+ (\\%)` = sprintf("%.1f", 100 * weighted.mean(data$has_bachelors, data$PWGTP)),
    `Part-Time (\\%)` = sprintf("%.1f", 100 * weighted.mean(data$part_time, data$PWGTP, na.rm = TRUE)),
    `Overqualified (\\%)` = sprintf("%.1f", 100 * weighted.mean(data$overqualified, data$PWGTP, na.rm = TRUE)),
    `Earnings Mismatch (\\%)` = sprintf("%.1f", 100 * weighted.mean(data$earnings_mismatch, data$PWGTP, na.rm = TRUE)),
    `Employer Ins. (\\%)` = sprintf("%.1f", 100 * weighted.mean(data$has_employer_ins, data$PWGTP)),
    `Medicare (\\%)` = sprintf("%.1f", 100 * weighted.mean(data$has_medicare, data$PWGTP)),
    `Mean Income` = sprintf("\\$%s", format(round(weighted.mean(data$PINCP, data$PWGTP, na.rm = TRUE)), big.mark = ","))
  )
}

tab1_data <- rbind(
  make_stats(dt, "Full Sample (52-75)"),
  make_stats(dt[AGEP < 62], "Below 62"),
  make_stats(dt[AGEP >= 62 & AGEP < 65], "62-64"),
  make_stats(dt[AGEP >= 65], "65+"),
  make_stats(dt[has_bachelors == 1L], "Bachelor's+"),
  make_stats(dt[has_employer_ins == 1L], "Employer Insured")
)

# LaTeX output
tab1_tex <- kable(tab1_data, format = "latex", booktabs = TRUE,
                  escape = FALSE, align = c("l", rep("r", 10)),
                  caption = "Summary Statistics: Employed Workers Aged 52--75, ACS PUMS 2018--2019 and 2022",
                  label = "summary") %>%
  kable_styling(latex_options = c("scale_down", "hold_position")) %>%
  add_header_above(c(" " = 1, " " = 1, "Demographics" = 3,
                      "Underemployment" = 3, "Insurance" = 2, " " = 1))

writeLines(tab1_tex, "../tables/tab1_summary.tex")
cat("  Saved: tables/tab1_summary.tex\n")

# ============================================================================
# Table 2: Main RDD Results
# ============================================================================
cat("\n=== Table 2: Main RDD Results ===\n")

format_result <- function(r) {
  if (is.null(r)) return(list(est = "--", se = "--", pv = "--", ci = "--"))
  stars <- ""
  if (r$pvalue < 0.01) stars <- "***"
  else if (r$pvalue < 0.05) stars <- "**"
  else if (r$pvalue < 0.10) stars <- "*"
  # Report in percentage points (multiply by 100)
  ci_lo <- (r$estimate - 1.96 * r$se) * 100
  ci_hi <- (r$estimate + 1.96 * r$se) * 100
  list(
    est = sprintf("%.2f%s", r$estimate * 100, stars),
    se = sprintf("(%.2f)", r$se * 100),
    ci = sprintf("[%.2f, %.2f]", ci_lo, ci_hi),
    pv = sprintf("[%.3f]", r$pvalue),
    bw = sprintf("%.1f", r$bandwidth),
    n = format(r$n_left + r$n_right, big.mark = ",")
  )
}

outcomes <- c("part_time", "overqualified", "earnings_mismatch",
              "involuntary_pt", "composite_underemploy")
labels <- c("Part-Time", "Overqualified", "Earnings Mismatch",
            "Involuntary PT", "Composite Index")

# Build table rows
tab2_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{RDD Estimates at Social Insurance Eligibility Thresholds}",
  "\\label{tab:main}",
  "\\begin{tabular}{lcc}",
  "\\toprule",
  " & Age 62 (Social Security) & Age 65 (Medicare) \\\\",
  "\\midrule"
)

for (i in seq_along(outcomes)) {
  r62 <- results$rdd_62[[outcomes[i]]]
  r65 <- results$rdd_65[[outcomes[i]]]

  f62 <- format_result(r62)
  f65 <- format_result(r65)

  tab2_lines <- c(tab2_lines,
    sprintf("\\textit{%s} & %s & %s \\\\", labels[i], f62$est, f65$est),
    sprintf(" & %s & %s \\\\", f62$se, f65$se),
    sprintf(" & %s & %s \\\\", f62$ci, f65$ci)
  )

  if (i < length(outcomes)) {
    tab2_lines <- c(tab2_lines, "[0.3em]")
  }
}

# Add bandwidth and N rows
r62_any <- results$rdd_62[[outcomes[1]]]
r65_any <- results$rdd_65[[outcomes[1]]]
bw62 <- if (!is.null(r62_any)) sprintf("%.1f", r62_any$bandwidth) else "--"
bw65 <- if (!is.null(r65_any)) sprintf("%.1f", r65_any$bandwidth) else "--"
n62 <- if (!is.null(r62_any)) format(r62_any$n_left + r62_any$n_right, big.mark = ",") else "--"
n65 <- if (!is.null(r65_any)) format(r65_any$n_left + r65_any$n_right, big.mark = ",") else "--"

tab2_lines <- c(tab2_lines,
  "\\midrule",
  sprintf("Bandwidth & %s & %s \\\\", bw62, bw65),
  sprintf("Observations & %s & %s \\\\", n62, n65),
  "Kernel & Uniform & Uniform \\\\",
  "\\bottomrule",
  "\\multicolumn{3}{p{0.85\\textwidth}}{\\footnotesize \\textit{Notes:} ",
  "Each cell reports the RDD estimate (in percentage points) from a local linear regression using the ",
  "\\texttt{fixest} package with a bandwidth of 5 age-years. ",
  "Standard errors (in parentheses) clustered at the age level (11 clusters per threshold). ",
  "95\\% confidence intervals in brackets. ",
  "* $p < 0.10$, ** $p < 0.05$, *** $p < 0.01$.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tab2_lines, "../tables/tab2_main.tex")
cat("  Saved: tables/tab2_main.tex\n")

# ============================================================================
# Table 3: Heterogeneity by Insurance Type
# ============================================================================
cat("\n=== Table 3: Heterogeneity ===\n")

# Run heterogeneity by subgroup using feols (consistent with main analysis)
# Note: No Bachelor's excluded because overqualification requires BA+ by construction
het_groups <- list(
  list(var = "has_employer_ins", val = 1L, label = "Employer Insured"),
  list(var = "has_employer_ins", val = 0L, label = "Not Employer Insured"),
  list(var = "has_bachelors", val = 1L, label = "Bachelor's+"),
  list(var = "female", val = 1L, label = "Female"),
  list(var = "female", val = 0L, label = "Male")
)

tab3_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Heterogeneity in Overqualification RDD at Age 65}",
  "\\label{tab:heterogeneity}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  "Subgroup & Estimate & SE & $p$-value & $N$ \\\\",
  "\\midrule"
)

for (g in het_groups) {
  sub <- dt[abs(age_c65) <= 5 & get(g$var) == g$val & !is.na(overqualified)]

  tryCatch({
    mod <- feols(overqualified ~ above_65 * age_c65,
                 data = sub, weights = ~PWGTP, cluster = ~AGEP)
    est <- coef(mod)["above_65"]
    se_val <- fixest::se(mod)["above_65"]
    pv <- fixest::pvalue(mod)["above_65"]

    stars <- ""
    if (pv < 0.01) stars <- "***"
    else if (pv < 0.05) stars <- "**"
    else if (pv < 0.10) stars <- "*"

    tab3_lines <- c(tab3_lines,
      sprintf("%s & %.2f%s & %.2f & %.3f & %s \\\\",
              g$label, est * 100, stars, se_val * 100, pv,
              format(nrow(sub), big.mark = ","))
    )
  }, error = function(e) {
    cat("  Warning: feols failed for", g$label, ":", e$message, "\n")
    tab3_lines <<- c(tab3_lines,
      sprintf("%s & -- & -- & -- & %s \\\\",
              g$label, format(nrow(sub), big.mark = ",")))
  })
}

tab3_lines <- c(tab3_lines,
  "\\bottomrule",
  "\\multicolumn{5}{p{0.85\\textwidth}}{\\footnotesize \\textit{Notes:} ",
  "Each row reports the RDD estimate (in percentage points) for overqualification at age 65 within the indicated subgroup. ",
  "Local linear regression, bandwidth of 5 age-years, standard errors clustered at the age level. ",
  "No Bachelor's subgroup is excluded because overqualification requires a bachelor's degree by construction. ",
  "* $p < 0.10$, ** $p < 0.05$, *** $p < 0.01$.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tab3_lines, "../tables/tab3_heterogeneity.tex")
cat("  Saved: tables/tab3_heterogeneity.tex\n")

# ============================================================================
# Table 4: Robustness Summary
# ============================================================================
cat("\n=== Table 4: Robustness ===\n")

tab4_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness of Overqualification RDD Estimate at Age 65}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "Specification & Estimate & SE & $p$-value \\\\",
  "\\midrule",
  "\\textit{Panel A: Bandwidth} \\\\"
)

# Bandwidth robustness
if (file.exists("../data/robustness_bandwidth.csv")) {
  bw_data <- fread("../data/robustness_bandwidth.csv")
  for (r in 1:nrow(bw_data[cutoff == 65])) {
    row <- bw_data[cutoff == 65][r]
    tab4_lines <- c(tab4_lines,
      sprintf("\\quad BW = %d & %.2f & %.2f & %.3f \\\\",
              row$bandwidth, row$estimate * 100, row$se * 100, row$pvalue))
  }
}

tab4_lines <- c(tab4_lines, "[0.5em]", "\\textit{Panel B: Polynomial Order} \\\\")

if (file.exists("../data/robustness_polynomial.csv")) {
  poly_data <- fread("../data/robustness_polynomial.csv")
  for (r in 1:nrow(poly_data[cutoff == 65])) {
    row <- poly_data[cutoff == 65][r]
    tab4_lines <- c(tab4_lines,
      sprintf("\\quad Order %d & %.2f & %.2f & %.3f \\\\",
              row$poly_order, row$estimate * 100, row$se * 100, row$pvalue))
  }
}

tab4_lines <- c(tab4_lines, "[0.5em]", "\\textit{Panel C: Kernel} \\\\")

if (file.exists("../data/robustness_kernel.csv")) {
  kern_data <- fread("../data/robustness_kernel.csv")
  for (r in 1:nrow(kern_data[cutoff == 65])) {
    row <- kern_data[cutoff == 65][r]
    tab4_lines <- c(tab4_lines,
      sprintf("\\quad %s & %.2f & %.2f & %.3f \\\\",
              tools::toTitleCase(row$kernel), row$estimate * 100, row$se * 100, row$pvalue))
  }
}

tab4_lines <- c(tab4_lines, "[0.5em]", "\\textit{Panel D: Donut RDD} \\\\")

if (file.exists("../data/robustness_donut.csv")) {
  donut_data <- fread("../data/robustness_donut.csv")
  for (r in 1:nrow(donut_data[cutoff == 65])) {
    row <- donut_data[cutoff == 65][r]
    tab4_lines <- c(tab4_lines,
      sprintf("\\quad Exclude age 65 & %.2f & %.2f & %.3f \\\\",
              row$estimate * 100, row$se * 100, row$pvalue))
  }
}

tab4_lines <- c(tab4_lines,
  "\\bottomrule",
  "\\multicolumn{4}{p{0.8\\textwidth}}{\\footnotesize \\textit{Notes:} ",
  "All estimates (in percentage points) are for overqualification at the age 65 threshold using local linear regression ",
  "with the \\texttt{fixest} package. Standard errors clustered at the age level. ",
  "The baseline specification uses a bandwidth of 5 age-years, local linear polynomial, ",
  "and uniform kernel (survey weights only).} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tab4_lines, "../tables/tab4_robustness.tex")
cat("  Saved: tables/tab4_robustness.tex\n")

# ============================================================================
# Table 5: Covariate Balance
# ============================================================================
cat("\n=== Table 5: Covariate Balance ===\n")

if (file.exists("../data/robustness_balance.csv")) {
  bal_data <- fread("../data/robustness_balance.csv")

  tab5_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Covariate Balance at Age 65 and Age 62 Thresholds}",
    "\\label{tab:balance}",
    "\\begin{tabular}{lcccccc}",
    "\\toprule",
    " & \\multicolumn{3}{c}{Age 62} & \\multicolumn{3}{c}{Age 65} \\\\",
    "\\cmidrule(lr){2-4} \\cmidrule(lr){5-7}",
    "Covariate & Estimate & SE & $p$ & Estimate & SE & $p$ \\\\",
    "\\midrule"
  )

  covs <- unique(bal_data$covariate)
  for (cov in covs) {
    r62 <- bal_data[cutoff == 62 & covariate == cov]
    r65 <- bal_data[cutoff == 65 & covariate == cov]

    if (nrow(r62) > 0 & nrow(r65) > 0) {
      tab5_lines <- c(tab5_lines,
        sprintf("%s & %.2f & %.2f & %.3f & %.2f & %.2f & %.3f \\\\",
                cov, r62$estimate * 100, r62$se * 100, r62$pvalue,
                r65$estimate * 100, r65$se * 100, r65$pvalue))
    }
  }

  tab5_lines <- c(tab5_lines,
    "\\bottomrule",
    "\\multicolumn{7}{p{0.9\\textwidth}}{\\footnotesize \\textit{Notes:} ",
    "Each cell tests whether the indicated covariate is smooth through the age threshold. ",
    "A significant estimate would suggest compositional changes that threaten the RDD validity.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )

  writeLines(tab5_lines, "../tables/tab5_balance.tex")
  cat("  Saved: tables/tab5_balance.tex\n")
}

cat("\n=== All Tables Generated ===\n")
