###############################################################################
# 06_tables.R — Generate all LaTeX tables
# APEP-0372: Minimum Wage Spillovers to College Graduate Earnings
###############################################################################

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"
dir.create(tables_dir, showWarnings = FALSE)

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
results <- readRDS(file.path(data_dir, "regression_results.rds"))
rob_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

# Load revision results if available (for CIs and bootstrap p-values)
revision_file <- file.path(data_dir, "revision_results.rds")
has_revision <- file.exists(revision_file)
if (has_revision) {
  rev_results <- readRDS(revision_file)
  cat("Revision results loaded (CIs and bootstrap p-values available).\n")
} else {
  cat("No revision results found; tables will omit CIs and bootstrap p-values.\n")
}

###############################################################################
# Helper: format CI row
###############################################################################

format_ci <- function(b, s, level = 0.95) {
  z <- qnorm(1 - (1 - level) / 2)
  lo <- b - z * s
  hi <- b + z * s
  sprintf("[%.4f, %.4f]", lo, hi)
}

format_coef <- function(m) sprintf("%.4f", coef(m)["ln_mw"])
format_se <- function(m) sprintf("(%.4f)", se(m)["ln_mw"])
format_stars <- function(m) {
  p <- fixest::pvalue(m)["ln_mw"]
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}
format_ci_from_model <- function(m) {
  format_ci(coef(m)["ln_mw"], se(m)["ln_mw"])
}

###############################################################################
# Table 2: Main TWFE Results (Bachelor's) — with 95% CIs
###############################################################################

cat("=== Generating Table 2: Main Results (with CIs) ===\n")

main <- results$main_ba

sink(file.path(tables_dir, "table2_main.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Minimum Wage on Bachelor's Degree Graduate Earnings}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\hline\\hline\n")
cat(" & \\multicolumn{2}{c}{P25} & \\multicolumn{2}{c}{P50} & \\multicolumn{2}{c}{P75} \\\\\n")
cat(" & (1) & (2) & (3) & (4) & (5) & (6) \\\\\n")
cat("\\hline\n")

# Coefficient row
cat(sprintf("$\\ln(MW)$ & %s%s & %s%s & %s%s & %s%s & %s%s & %s%s \\\\\n",
            format_coef(main$m1_p25), format_stars(main$m1_p25),
            format_coef(main$m2_p25), format_stars(main$m2_p25),
            format_coef(main$m1_p50), format_stars(main$m1_p50),
            format_coef(main$m2_p50), format_stars(main$m2_p50),
            format_coef(main$m1_p75), format_stars(main$m1_p75),
            format_coef(main$m2_p75), format_stars(main$m2_p75)))

# SE row
cat(sprintf(" & %s & %s & %s & %s & %s & %s \\\\\n",
            format_se(main$m1_p25), format_se(main$m2_p25),
            format_se(main$m1_p50), format_se(main$m2_p50),
            format_se(main$m1_p75), format_se(main$m2_p75)))

# 95% CI row
cat(sprintf(" & %s & %s & %s & %s & %s & %s \\\\\n",
            format_ci_from_model(main$m1_p25), format_ci_from_model(main$m2_p25),
            format_ci_from_model(main$m1_p50), format_ci_from_model(main$m2_p50),
            format_ci_from_model(main$m1_p75), format_ci_from_model(main$m2_p75)))

# Wild cluster bootstrap p-value row (for P25 columns only)
if (has_revision) {
  boot_ba <- rev_results$bootstrap$ba_p25
  cat(sprintf("WCB $p$-value & & %.4f & & & & \\\\\n", boot_ba$p_value))
  cat(sprintf("WCB 95\\%% CI & & %s & & & & \\\\\n",
              sprintf("[%.4f, %.4f]", boot_ba$ci_lower, boot_ba$ci_upper)))
}

cat("\\hline\n")
cat("State controls & No & Yes & No & Yes & No & Yes \\\\\n")
cat("Institution FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n")
cat("Cohort FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n")

df_ba <- df %>% filter(degree_group == "Bachelor's", !is.na(ln_y1_p25))

cat(sprintf("Observations & %s & %s & %s & %s & %s & %s \\\\\n",
            formatC(main$m1_p25$nobs, big.mark = ","),
            formatC(main$m2_p25$nobs, big.mark = ","),
            formatC(main$m1_p50$nobs, big.mark = ","),
            formatC(main$m2_p50$nobs, big.mark = ","),
            formatC(main$m1_p75$nobs, big.mark = ","),
            formatC(main$m2_p75$nobs, big.mark = ",")))

cat(sprintf("Clusters (states) & %d & %d & %d & %d & %d & %d \\\\\n",
            n_distinct(df_ba$state_fips), n_distinct(df_ba$state_fips),
            n_distinct(df_ba$state_fips), n_distinct(df_ba$state_fips),
            n_distinct(df_ba$state_fips), n_distinct(df_ba$state_fips)))

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Dependent variables are log earnings at the 25th, 50th, and 75th percentiles, ")
cat("measured one year after graduation. $\\ln(MW)$ is the log of the average effective state ")
cat("minimum wage during the 3-year graduation cohort window. State controls include the ")
cat("unemployment rate and log per capita income averaged over the cohort window. ")
cat("Standard errors clustered at the state level in parentheses; 95\\% confidence intervals in brackets. ")
if (has_revision) {
  cat("WCB denotes wild cluster bootstrap (Webb 6-point, 9,999 replications) $p$-values and CIs ")
  cat("for the preferred specification (column 2). ")
}
cat("$^{***}$, $^{**}$, $^{*}$ denote significance at the 1\\%, 5\\%, and 10\\% levels.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

###############################################################################
# Table 3: By Degree Level (P25, P50, P75) — with 95% CIs
###############################################################################

cat("=== Generating Table 3: Degree Level Results (with CIs) ===\n")

sink(file.path(tables_dir, "table3_degree.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{MW Elasticity by Degree Level}\n")
cat("\\label{tab:degree}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & P25 & P50 & P75 \\\\\n")
cat("\\hline\n")

for (dg in c("Certificate", "Associate", "Bachelor's")) {
  if (dg %in% names(results$degree_results)) {
    r <- results$degree_results[[dg]]

    format_entry <- function(b, s) {
      if (is.na(b)) return("--")
      p <- 2 * pnorm(-abs(b / s))
      stars <- ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))
      sprintf("%.4f%s", b, stars)
    }

    format_ci_entry <- function(b, s) {
      if (is.na(b) || is.na(s) || s == 0) return("--")
      format_ci(b, s)
    }

    # Coefficient row
    cat(sprintf("\\textit{%s} & %s & %s & %s \\\\\n",
                dg,
                format_entry(r$p25_beta, r$p25_se),
                format_entry(r$p50_beta, r$p50_se),
                format_entry(r$p75_beta, r$p75_se)))
    # SE row
    cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n",
                r$p25_se,
                ifelse(is.na(r$p50_se), 0, r$p50_se),
                ifelse(is.na(r$p75_se), 0, r$p75_se)))
    # 95% CI row
    cat(sprintf(" & %s & %s & %s \\\\\n",
                format_ci_entry(r$p25_beta, r$p25_se),
                format_ci_entry(r$p50_beta, r$p50_se),
                format_ci_entry(r$p75_beta, r$p75_se)))

    # Bootstrap p-value row for Associate and Bachelor's P25
    if (has_revision && dg == "Associate") {
      boot_as <- rev_results$bootstrap$as_p25
      cat(sprintf(" & \\footnotesize WCB $p$=%.4f & & \\\\\n", boot_as$p_value))
    }
    if (has_revision && dg == "Bachelor's") {
      boot_ba <- rev_results$bootstrap$ba_p25
      cat(sprintf(" & \\footnotesize WCB $p$=%.4f & & \\\\\n", boot_ba$p_value))
    }

    cat(sprintf(" & [N=%s] & & \\\\\n",
                formatC(r$n, big.mark = ",")))
    cat("[0.5em]\n")
  }
}

cat("\\hline\n")
cat("State controls & Yes & Yes & Yes \\\\\n")
cat("Institution FE & Yes & Yes & Yes \\\\\n")
cat("Cohort FE & Yes & Yes & Yes \\\\\n")
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Each cell reports the coefficient on $\\ln(MW)$ from a ")
cat("separate regression of log earnings at the indicated percentile on log ")
cat("minimum wage, with institution and cohort fixed effects and state-level controls ")
cat("(unemployment rate, log per capita income). Standard errors clustered at the state level ")
cat("in parentheses; 95\\% confidence intervals in brackets. ")
if (has_revision) {
  cat("WCB $p$-values are wild cluster bootstrap $p$-values (Webb 6-point, 9,999 replications) ")
  cat("for the P25 specification. ")
}
cat("$^{***}$, $^{**}$, $^{*}$ denote significance at the 1\\%, 5\\%, and 10\\% levels.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

###############################################################################
# Table 5: Time Horizon (Y1, Y5, Y10) — with 95% CIs
###############################################################################

cat("=== Generating Table 5: Time Horizon (with CIs) ===\n")

sink(file.path(tables_dir, "table5_horizon.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Persistence of MW Effects: Bachelor's Degree Graduates}\n")
cat("\\label{tab:horizon}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & 1 Year & 5 Years & 10 Years \\\\\n")
cat("\\hline\n")

for (p in c("p25", "p50", "p75")) {
  p_label <- toupper(p)
  vals <- sapply(c("y1", "y5", "y10"), function(h) {
    key <- paste(h, p, sep = "_")
    if (key %in% names(results$horizon_results)) {
      r <- results$horizon_results[[key]]
      pval <- 2 * pnorm(-abs(r$beta / r$se))
      stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
      sprintf("%.4f%s", r$beta, stars)
    } else {
      "--"
    }
  })
  ses <- sapply(c("y1", "y5", "y10"), function(h) {
    key <- paste(h, p, sep = "_")
    if (key %in% names(results$horizon_results)) {
      r <- results$horizon_results[[key]]
      sprintf("(%.4f)", r$se)
    } else {
      ""
    }
  })
  cis <- sapply(c("y1", "y5", "y10"), function(h) {
    key <- paste(h, p, sep = "_")
    if (key %in% names(results$horizon_results)) {
      r <- results$horizon_results[[key]]
      format_ci(r$beta, r$se)
    } else {
      ""
    }
  })
  ns <- sapply(c("y1", "y5", "y10"), function(h) {
    key <- paste(h, p, sep = "_")
    if (key %in% names(results$horizon_results)) {
      r <- results$horizon_results[[key]]
      formatC(r$n, big.mark = ",")
    } else {
      "--"
    }
  })

  cat(sprintf("\\textit{%s} & %s & %s & %s \\\\\n", p_label, vals[1], vals[2], vals[3]))
  cat(sprintf(" & %s & %s & %s \\\\\n", ses[1], ses[2], ses[3]))
  cat(sprintf(" & %s & %s & %s \\\\\n", cis[1], cis[2], cis[3]))
  cat(sprintf(" & [N=%s] & [N=%s] & [N=%s] \\\\\n", ns[1], ns[2], ns[3]))
  cat("[0.5em]\n")
}

cat("\\hline\n")
cat("State controls & Yes & Yes & Yes \\\\\n")
cat("Institution FE & Yes & Yes & Yes \\\\\n")
cat("Cohort FE & Yes & Yes & Yes \\\\\n")
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Each cell reports the coefficient on $\\ln(MW)$ from a separate regression. ")
cat("The dependent variable is log earnings at the indicated percentile, measured 1, 5, or 10 years after graduation. ")
cat("All specifications include institution and cohort fixed effects and state-level controls. ")
cat("Standard errors clustered at the state level in parentheses; 95\\% confidence intervals in brackets.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

###############################################################################
# Table 6: CIP Heterogeneity — with 95% CIs
###############################################################################

cat("=== Generating Table 6: CIP Heterogeneity (with CIs) ===\n")

sink(file.path(tables_dir, "table6_cip.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{MW Elasticity by Field of Study (Bachelor's, P25)}\n")
cat("\\label{tab:cip}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\hline\\hline\n")
cat(" & $\\ln(MW)$ & SE & 95\\% CI & N & Inst$\\times$CIP \\\\\n")
cat("\\hline\n")

for (wg in c("Low-wage", "Mid-wage", "High-wage")) {
  if (wg %in% names(results$cip_results)) {
    r <- results$cip_results[[wg]]
    pval <- 2 * pnorm(-abs(r$beta / r$se))
    stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
    cat(sprintf("%s & %.4f%s & (%.4f) & %s & %s & %s \\\\\n",
                wg, r$beta, stars, r$se,
                format_ci(r$beta, r$se),
                formatC(r$n, big.mark = ","),
                formatC(r$n_units, big.mark = ",")))
  }
}

cat("\\hline\n")
cat("\\multicolumn{6}{l}{\\footnotesize Low-wage: Education (13), Humanities (23, 24, 50), Arts (38, 54)} \\\\\n")
cat("\\multicolumn{6}{l}{\\footnotesize Mid-wage: Biology (26), Math (27), Social Science (42, 45)} \\\\\n")
cat("\\multicolumn{6}{l}{\\footnotesize High-wage: CS (11), Engineering (14), Business (52), Health (51)} \\\\\n")
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Dependent variable is log P25 first-year earnings. Each row is a separate regression ")
cat("for bachelor's degree graduates in the indicated field group. Fixed effects are at the institution$\\times$CIP ")
cat("and cohort level. Standard errors clustered at the state level in parentheses; 95\\% confidence intervals in brackets.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\nAll tables generated.\n")
