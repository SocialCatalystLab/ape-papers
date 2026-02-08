# ============================================================
# 06_tables.R - Regression tables and summary statistics
# Paper 135: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality
# ============================================================

source("code/00_packages.R")

# Create output directory
dir.create("tables", showWarnings = FALSE)

# Load data and results
panel        <- readRDS("data/analysis_panel.rds")
policy_db    <- read_csv("data/policy_database.csv", show_col_types = FALSE)
main_results <- tryCatch(readRDS("data/main_results.rds"), error = function(e) NULL)
robustness   <- tryCatch(readRDS("data/robustness_results.rds"), error = function(e) NULL)

cat("Panel loaded:", nrow(panel), "observations\n")

# ============================================================
# Table 1: Summary Statistics
# ============================================================

cat("\n=== Table 1: Summary Statistics ===\n")

# Split by treatment group and period
compute_summ <- function(df, label) {
  df %>%
    summarise(
      Group = label,
      `Mean Mortality Rate`   = mean(mortality_rate, na.rm = TRUE),
      `SD Mortality Rate`     = sd(mortality_rate, na.rm = TRUE),
      `Median Mortality Rate` = median(mortality_rate, na.rm = TRUE),
      `Min Rate`              = min(mortality_rate, na.rm = TRUE),
      `Max Rate`              = max(mortality_rate, na.rm = TRUE),
      `N States`              = n_distinct(state_fips),
      `N State-Years`         = n()
    )
}

# Overall
summ_all <- compute_summ(panel, "Full Sample")

# By treatment status, pre-period only
summ_treated_pre <- compute_summ(
  panel %>% filter(first_treat > 0, year < first_treat),
  "Treated (Pre)"
)
summ_control_pre <- compute_summ(
  panel %>% filter(first_treat == 0),
  "Never-Treated"
)

# By treatment status, post-period
summ_treated_post <- compute_summ(
  panel %>% filter(first_treat > 0, year >= first_treat),
  "Treated (Post)"
)

table1 <- bind_rows(summ_all, summ_treated_pre, summ_treated_post, summ_control_pre)

# Print
cat("\n")
print(as.data.frame(table1), digits = 3, row.names = FALSE)

# Save CSV
write_csv(table1, "tables/table1_summary_stats.csv")

# Generate LaTeX
sink("tables/table1_summary_stats.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Diabetes Mortality Rates (All Ages, Age-Adjusted)}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\hline\\hline\n")
cat(" & Mean & SD & Median & Min & Max & N \\\\\n")
cat("\\hline\n")

for (i in 1:nrow(table1)) {
  cat(sprintf("%s & %.2f & %.2f & %.2f & %.2f & %.2f & %d \\\\\n",
              table1$Group[i],
              table1$`Mean Mortality Rate`[i],
              table1$`SD Mortality Rate`[i],
              table1$`Median Mortality Rate`[i],
              table1$`Min Rate`[i],
              table1$`Max Rate`[i],
              table1$`N State-Years`[i]))
}

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Diabetes mortality rate per 100,000 population, ")
cat("all ages, age-adjusted, ICD-10 codes E10--E14.\n")
cat("\\item Source: CDC WONDER Underlying Cause of Death, 1999--2023. ")
cat(sprintf("Panel: %d states $\\times$ %d years (%d state-year observations).\n",
            n_distinct(panel$state_fips), n_distinct(panel$year), nrow(panel)))
cat(sprintf("\\item Treated states: %d. Never-treated states: %d. State-level clusters: %d.\n",
            n_distinct(panel$state_fips[panel$first_treat > 0]),
            n_distinct(panel$state_fips[panel$first_treat == 0]),
            n_distinct(panel$state_fips)))
cat("\\item ``Treated (Pre)'' = treated states before copay cap effective. ")
cat("``Treated (Post)'' = after effective date.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tables/table1_summary_stats.tex\n")

# ============================================================
# Table 2: Policy Adoption Dates
# ============================================================

cat("\n=== Table 2: Policy Adoption Dates ===\n")

table2 <- policy_db %>%
  arrange(effective_date) %>%
  select(
    State = state_name,
    Abbr = state_abbr,
    `Effective Date` = effective_date,
    `Treatment Year` = first_treat,
    `Cap Amount ($)` = cap_amount
  )

print(as.data.frame(table2), row.names = FALSE)

write_csv(table2, "tables/table2_policy_dates.csv")

# LaTeX
sink("tables/table2_policy_dates.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{State Insulin Copay Cap Laws: Adoption Dates and Cap Amounts}\n")
cat("\\label{tab:policy}\n")
cat("\\begin{tabular}{llccc}\n")
cat("\\hline\\hline\n")
cat("State & Abbr & Effective Date & Treatment Year & Cap (\\$) \\\\\n")
cat("\\hline\n")

for (i in 1:nrow(table2)) {
  cat(sprintf("%s & %s & %s & %d & \\$%d \\\\\n",
              table2$State[i],
              table2$Abbr[i],
              as.character(table2$`Effective Date`[i]),
              table2$`Treatment Year`[i],
              table2$`Cap Amount ($)`[i]))
}

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Treatment year is the first calendar year of full ")
cat("exposure (first January 1 under the law).\n")
cat("\\item Cap amounts reflect the per-month (or per-30-day-supply) limit on ")
cat("insulin copayments for state-regulated health plans.\n")
cat("\\item Sources: NCSL, state session laws, legislative trackers.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tables/table2_policy_dates.tex\n")

# ============================================================
# Table 3: Main Results (TWFE, CS-DiD, Sun-Abraham)
# ============================================================

cat("\n=== Table 3: Main Results ===\n")

if (!is.null(main_results)) {
  # Use modelsummary for TWFE specifications
  twfe_models <- list(
    "(1) TWFE" = main_results$twfe_basic,
    "(2) + COVID Controls" = main_results$twfe_covid,
    "(3) Log Rate" = main_results$twfe_log,
    "(4) + State Trends" = main_results$twfe_trends
  )

  # Create table with modelsummary
  tryCatch({
    msummary(
      twfe_models,
      stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
      coef_map = c(
        "treated" = "Post Copay Cap",
        "covid_year" = "COVID Year",
        "covid_death_rate" = "COVID Death Rate"
      ),
      gof_map = c("nobs", "r.squared", "adj.r.squared",
                   "FE: state_id", "FE: year"),
      output = "tables/table3_main_results.tex",
      title = "Effect of Insulin Copay Caps on Diabetes Mortality (All Ages, Age-Adjusted)",
      notes = c(
        "Standard errors clustered at state level in parentheses.",
        "All specifications include state and year fixed effects.",
        "Outcome: diabetes mortality rate per 100,000 (all ages, age-adjusted, ICD-10 E10--E14).",
        "Column 3 uses log(mortality rate + 0.1) as outcome.",
        "Column 4 adds state-specific linear time trends."
      )
    )
    cat("  Saved tables/table3_main_results.tex\n")
  }, error = function(e) {
    cat("  modelsummary error:", e$message, "\n")
  })

  # Also save CSV version
  tryCatch({
    msummary(
      twfe_models,
      stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
      coef_map = c(
        "treated" = "Post Copay Cap",
        "covid_year" = "COVID Year",
        "covid_death_rate" = "COVID Death Rate"
      ),
      gof_map = c("nobs", "r.squared"),
      output = "tables/table3_main_results.csv"
    )
  }, error = function(e) NULL)

  # Add CS-DiD and Sun-Abraham results manually below the TWFE table
  sink("tables/table3_cs_sa_results.tex", append = FALSE)
  cat("\n% Callaway-Sant'Anna and Sun-Abraham Results\n")
  cat("% (Append below main TWFE table or present separately)\n")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Heterogeneity-Robust Estimators}\n")
  cat("\\label{tab:cs_sa}\n")
  cat("\\begin{tabular}{lcc}\n")
  cat("\\hline\\hline\n")
  cat("Estimator & ATT & SE \\\\\n")
  cat("\\hline\n")

  # CS-DiD
  if (!is.null(main_results$cs_agg_simple)) {
    cs_att <- main_results$cs_agg_simple$overall.att
    cs_se  <- main_results$cs_agg_simple$overall.se
    cs_sig <- ifelse(abs(cs_att / cs_se) > 2.576, "***",
              ifelse(abs(cs_att / cs_se) > 1.96, "**",
              ifelse(abs(cs_att / cs_se) > 1.645, "*", "")))
    cat(sprintf("Callaway-Sant'Anna (2021) & %.3f%s & (%.3f) \\\\\n",
                cs_att, cs_sig, cs_se))
  }

  # Sun-Abraham
  if (!is.null(main_results$sa_result)) {
    sa_agg <- tryCatch({
      summary(main_results$sa_result, agg = "ATT")
    }, error = function(e) NULL)

    if (!is.null(sa_agg)) {
      sa_att <- sa_agg$coeftable[1, 1]
      sa_se  <- sa_agg$coeftable[1, 2]
      sa_sig <- ifelse(abs(sa_att / sa_se) > 2.576, "***",
                ifelse(abs(sa_att / sa_se) > 1.96, "**",
                ifelse(abs(sa_att / sa_se) > 1.645, "*", "")))
      cat(sprintf("Sun-Abraham (2021) & %.3f%s & (%.3f) \\\\\n",
                  sa_att, sa_sig, sa_se))
    }
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$.\n")
  # Report which CS estimation method was actually used
  cs_method <- if (!is.null(main_results$cs_est_method_used)) main_results$cs_est_method_used else "dr"
  cs_method_label <- ifelse(cs_method == "dr", "doubly robust", "outcome regression")
  cat(sprintf("\\item CS-DiD uses %s estimation with never-treated control group.\n", cs_method_label))
  cat("\\item Sun-Abraham uses interaction-weighted estimator via \\texttt{fixest::sunab()}.\n")
  cat(sprintf("\\item N = %d state-year observations. Clusters = %d states. Treated = %d states.\n",
              nrow(panel), n_distinct(panel$state_fips),
              n_distinct(panel$state_fips[panel$first_treat > 0])))
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/table3_cs_sa_results.tex\n")

} else {
  cat("  Main results not found — run 03_main_analysis.R first\n")
}

# ============================================================
# Table 4: Robustness Results
# ============================================================

cat("\n=== Table 4: Robustness Results ===\n")

if (!is.null(robustness)) {
  robustness_table <- data.frame(
    Specification = character(),
    ATT = numeric(),
    SE = numeric(),
    CI_lower = numeric(),
    CI_upper = numeric(),
    N = integer(),
    stringsAsFactors = FALSE
  )

  # 1. Exclude COVID years
  if (!is.null(robustness$twfe_no_covid)) {
    coef_val <- coef(robustness$twfe_no_covid)["treated"]
    se_val   <- summary(robustness$twfe_no_covid)$se["treated"]
    robustness_table <- rbind(robustness_table, data.frame(
      Specification = "TWFE excl. 2020-2021",
      ATT = coef_val,
      SE = se_val,
      CI_lower = coef_val - 1.96 * se_val,
      CI_upper = coef_val + 1.96 * se_val,
      N = nobs(robustness$twfe_no_covid)
    ))
  }

  # 2. COVID death rate control
  if (!is.null(robustness$twfe_covid_control)) {
    coef_val <- coef(robustness$twfe_covid_control)["treated"]
    se_val   <- summary(robustness$twfe_covid_control)$se["treated"]
    robustness_table <- rbind(robustness_table, data.frame(
      Specification = "TWFE + COVID death rate",
      ATT = coef_val,
      SE = se_val,
      CI_lower = coef_val - 1.96 * se_val,
      CI_upper = coef_val + 1.96 * se_val,
      N = nobs(robustness$twfe_covid_control)
    ))
  }

  # 3. CS-DiD without COVID
  if (!is.null(robustness$cs_no_covid_att)) {
    robustness_table <- rbind(robustness_table, data.frame(
      Specification = "CS-DiD excl. 2020-2021",
      ATT = robustness$cs_no_covid_att$overall.att,
      SE = robustness$cs_no_covid_att$overall.se,
      CI_lower = robustness$cs_no_covid_att$overall.att - 1.96 * robustness$cs_no_covid_att$overall.se,
      CI_upper = robustness$cs_no_covid_att$overall.att + 1.96 * robustness$cs_no_covid_att$overall.se,
      N = NA
    ))
  }

  # 4. Log specification
  if (!is.null(robustness$cs_log)) {
    robustness_table <- rbind(robustness_table, data.frame(
      Specification = "CS-DiD (log mortality)",
      ATT = robustness$cs_log$overall.att,
      SE = robustness$cs_log$overall.se,
      CI_lower = robustness$cs_log$overall.att - 1.96 * robustness$cs_log$overall.se,
      CI_upper = robustness$cs_log$overall.att + 1.96 * robustness$cs_log$overall.se,
      N = NA
    ))
  }

  # 5. Wild bootstrap
  if (!is.null(robustness$wild_bootstrap)) {
    robustness_table <- rbind(robustness_table, data.frame(
      Specification = "Wild cluster bootstrap",
      ATT = robustness$wild_bootstrap$point_estimate,
      SE = NA,
      CI_lower = robustness$wild_bootstrap$conf_int[1],
      CI_upper = robustness$wild_bootstrap$conf_int[2],
      N = NA
    ))
  }

  # Placebo tests
  if (!is.null(robustness$placebo_heart_twfe)) {
    coef_val <- coef(robustness$placebo_heart_twfe)["treated"]
    se_val   <- summary(robustness$placebo_heart_twfe)$se["treated"]
    robustness_table <- rbind(robustness_table, data.frame(
      Specification = "Placebo: Heart Disease (TWFE)",
      ATT = coef_val,
      SE = se_val,
      CI_lower = coef_val - 1.96 * se_val,
      CI_upper = coef_val + 1.96 * se_val,
      N = nobs(robustness$placebo_heart_twfe)
    ))
  }

  if (!is.null(robustness$placebo_cancer_twfe)) {
    coef_val <- coef(robustness$placebo_cancer_twfe)["treated"]
    se_val   <- summary(robustness$placebo_cancer_twfe)$se["treated"]
    robustness_table <- rbind(robustness_table, data.frame(
      Specification = "Placebo: Cancer All Ages (TWFE)",
      ATT = coef_val,
      SE = se_val,
      CI_lower = coef_val - 1.96 * se_val,
      CI_upper = coef_val + 1.96 * se_val,
      N = nobs(robustness$placebo_cancer_twfe)
    ))
  }

  cat("\n")
  print(robustness_table, digits = 4, row.names = FALSE)

  write_csv(robustness_table, "tables/table4_robustness.csv")

  # LaTeX version
  sink("tables/table4_robustness.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Robustness Checks and Placebo Tests}\n")
  cat("\\label{tab:robustness}\n")
  cat("\\begin{tabular}{lccc}\n")
  cat("\\hline\\hline\n")
  cat("Specification & ATT & SE & 95\\% CI \\\\\n")
  cat("\\hline\n")
  cat("\\multicolumn{4}{l}{\\textit{Panel A: Alternative Specifications}} \\\\\n")

  for (i in 1:nrow(robustness_table)) {
    if (robustness_table$Specification[i] == "Placebo: Heart Disease (TWFE)") {
      cat("\\hline\n")
      cat("\\multicolumn{4}{l}{\\textit{Panel B: Placebo Tests}} \\\\\n")
    }
    se_str <- ifelse(is.na(robustness_table$SE[i]), "--",
                     sprintf("%.3f", robustness_table$SE[i]))
    ci_str <- sprintf("[%.3f, %.3f]",
                      robustness_table$CI_lower[i],
                      robustness_table$CI_upper[i])
    cat(sprintf("%s & %.3f & %s & %s \\\\\n",
                robustness_table$Specification[i],
                robustness_table$ATT[i],
                se_str, ci_str))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} Standard errors clustered at state level. ")
  cat("Wild bootstrap uses Webb (6-point) weights with 9,999 replications.\n")
  cat("\\item Placebo tests use outcomes that should not be affected by ")
  cat("insulin copay caps: heart disease mortality (unrelated cause) ")
  cat("and cancer mortality for all ages, age-adjusted (unrelated cause). Placebo data covers 1999--2017.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/table4_robustness.tex\n")

} else {
  cat("  Robustness results not found — run 04_robustness.R first\n")
}

# ============================================================
# Table 5: Heterogeneity by Cap Amount
# ============================================================

cat("\n=== Table 5: Heterogeneity by Cap Amount ===\n")

if (!is.null(robustness)) {
  het_models <- list()

  if (!is.null(robustness$het_low))  het_models[["(1) Low ($25-30)"]]  <- robustness$het_low
  if (!is.null(robustness$het_med))  het_models[["(2) Medium ($35-50)"]] <- robustness$het_med
  if (!is.null(robustness$het_high)) het_models[["(3) High ($100)"]]   <- robustness$het_high

  if (length(het_models) > 0) {
    tryCatch({
      msummary(
        het_models,
        stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
        coef_map = c("treated" = "Post Copay Cap"),
        gof_map = c("nobs", "r.squared"),
        output = "tables/table5_heterogeneity.tex",
        title = "Heterogeneous Effects by Copay Cap Amount",
        notes = c(
          "Standard errors clustered at state level in parentheses.",
          "Each column restricts treated states to those with caps in the specified range.",
          "Control group: never-treated states (same across columns).",
          "Outcome: diabetes mortality rate per 100,000 (all ages, age-adjusted)."
        )
      )
      cat("  Saved tables/table5_heterogeneity.tex\n")

      msummary(
        het_models,
        stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
        coef_map = c("treated" = "Post Copay Cap"),
        gof_map = c("nobs", "r.squared"),
        output = "tables/table5_heterogeneity.csv"
      )
    }, error = function(e) {
      cat("  Heterogeneity table error:", e$message, "\n")
    })

    # Print summary
    cat("\nHeterogeneity by Cap Amount:\n")
    for (name in names(het_models)) {
      coef_val <- coef(het_models[[name]])["treated"]
      se_val <- summary(het_models[[name]])$se["treated"]
      cat(sprintf("  %s: ATT = %.3f (SE = %.3f)\n", name, coef_val, se_val))
    }
  }

} else {
  cat("  Robustness results not found — run 04_robustness.R first\n")
}

# ============================================================
# Appendix Table: Pre-Treatment Balance
# ============================================================

cat("\n=== Appendix: Pre-Treatment Balance ===\n")

# Pre-treatment balance: use treatment-status-aware filtering
# For ever-treated states, pre-treatment = years before their specific first_treat
# For never-treated states, all years are pre-treatment
pre_balance <- panel %>%
  filter(
    (first_treat > 0 & year < first_treat) |  # Treated states: before their treatment
    (first_treat == 0)                         # Never-treated: all observations
  ) %>%
  filter(year <= 2017) %>%  # Restrict to historical period (1999-2017) for comparability
  mutate(group = ifelse(first_treat > 0, "Ever-Treated", "Never-Treated")) %>%
  group_by(group) %>%
  summarise(
    `Mean Diabetes Mort. Rate` = mean(mortality_rate, na.rm = TRUE),
    `SD Diabetes Mort. Rate`   = sd(mortality_rate, na.rm = TRUE),
    `Mean Heart Mort. Rate`    = mean(mortality_rate_heart, na.rm = TRUE),
    `Mean Cancer Mort. Rate`   = mean(mortality_rate_cancer, na.rm = TRUE),
    `N States`                 = n_distinct(state_fips),
    `N State-Years`            = n(),
    .groups = "drop"
  )

print(as.data.frame(pre_balance), digits = 3, row.names = FALSE)

write_csv(pre_balance, "tables/tableA1_pretreatment_balance.csv")

# LaTeX
sink("tables/tableA1_pretreatment_balance.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Pre-Treatment Balance: Treated vs.\\ Control States (1999--2019)}\n")
cat("\\label{tab:balance}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\hline\\hline\n")
cat(" & Ever-Treated & Never-Treated \\\\\n")
cat("\\hline\n")

et <- pre_balance %>% filter(group == "Ever-Treated")
nt <- pre_balance %>% filter(group == "Never-Treated")

cat(sprintf("Diabetes Mortality (All Ages) & %.2f & %.2f \\\\\n",
            et$`Mean Diabetes Mort. Rate`, nt$`Mean Diabetes Mort. Rate`))
cat(sprintf(" \\quad (SD) & (%.2f) & (%.2f) \\\\\n",
            et$`SD Diabetes Mort. Rate`, nt$`SD Diabetes Mort. Rate`))
cat(sprintf("Heart Disease Mortality & %.2f & %.2f \\\\\n",
            et$`Mean Heart Mort. Rate`, nt$`Mean Heart Mort. Rate`))
cat(sprintf("Cancer Mortality (All Ages) & %.2f & %.2f \\\\\n",
            et$`Mean Cancer Mort. Rate`, nt$`Mean Cancer Mort. Rate`))
cat(sprintf("N States & %d & %d \\\\\n",
            et$`N States`, nt$`N States`))
cat(sprintf("N State-Years & %d & %d \\\\\n",
            et$`N State-Years`, nt$`N State-Years`))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Pre-treatment period: 1999--2019 (before any state adopted caps).\n")
cat("\\item All rates per 100,000 population. Source: CDC WONDER.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tables/tableA1_pretreatment_balance.tex\n")

# ============================================================
# MDE Table (Appendix)
# ============================================================

cat("\n=== Appendix: Minimum Detectable Effect Table ===\n")

if (file.exists("data/mde_table.rds")) {
  mde_table <- readRDS("data/mde_table.rds")
  print(mde_table, digits = 3, row.names = FALSE)

  sink("tables/tableA2_mde.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Minimum Detectable Effects}\n")
  cat("\\label{tab:mde}\n")
  cat("\\begin{tabular}{llccc}\n")
  cat("\\hline\\hline\n")
  cat("Estimator & Power & SE & MDE & MDE (\\% of Mean) \\\\\n")
  cat("\\hline\n")

  for (i in 1:nrow(mde_table)) {
    if (!is.na(mde_table$MDE[i])) {
      power_escaped <- gsub("%", "\\\\%", mde_table$Power[i])
      cat(sprintf("%s & %s & %.3f & %.2f & %.1f\\%% \\\\\n",
                  mde_table$Estimator[i], power_escaped,
                  mde_table$SE[i], mde_table$MDE[i], mde_table$MDE_pct[i]))
    }
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} MDE = $(z_{\\alpha/2} + z_{\\beta}) \\times \\text{SE}$.\n")
  cat("\\item Two-sided test at 5\\% significance level. SE from actual estimator variance.\n")
  cat(sprintf("\\item N = %d state-year observations. Clusters = %d states.\n",
              nrow(panel), n_distinct(panel$state_fips)))
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/tableA2_mde.tex\n")
} else {
  cat("  MDE table not found — run 04_robustness.R first\n")
}

# ============================================================
# Inference Comparison Table (3 SE types)
# ============================================================

cat("\n=== Appendix: Inference Comparison (3 SE Types) ===\n")

if (!is.null(main_results) && !is.null(robustness)) {
  tryCatch({
    twfe_basic <- main_results$twfe_basic
    coef_val <- coef(twfe_basic)["treated"]

    # 1. Standard cluster-robust
    se_cr <- summary(twfe_basic, cluster = ~state_id)
    se1 <- se_cr$coeftable["treated", "Std. Error"]
    p1 <- se_cr$coeftable["treated", "Pr(>|t|)"]

    # 2. CR2 (small-sample corrected)
    se_cr2 <- summary(twfe_basic, cluster = ~state_id,
                       ssc = ssc(adj = TRUE, fixef.K = "full", cluster.adj = TRUE))
    se2 <- se_cr2$coeftable["treated", "Std. Error"]
    p2 <- se_cr2$coeftable["treated", "Pr(>|t|)"]

    # 3. Wild bootstrap
    wb_p <- if (!is.null(robustness$wild_bootstrap)) robustness$wild_bootstrap$p_val else NA

    sink("tables/tableA3_inference.tex")
    cat("\\begin{table}[htbp]\n")
    cat("\\centering\n")
    cat("\\caption{Inference Robustness: Three SE Types for TWFE Treatment Effect}\n")
    cat("\\label{tab:inference}\n")
    cat("\\begin{tabular}{lccc}\n")
    cat("\\hline\\hline\n")
    cat(" & SE & $p$-value & 95\\% CI \\\\\n")
    cat("\\hline\n")
    cat(sprintf("Cluster-robust & %.3f & %.3f & [%.3f, %.3f] \\\\\n",
                se1, p1, coef_val - 1.96*se1, coef_val + 1.96*se1))
    cat(sprintf("CR2 (small-sample adj.) & %.3f & %.3f & [%.3f, %.3f] \\\\\n",
                se2, p2, coef_val - 1.96*se2, coef_val + 1.96*se2))
    if (!is.na(wb_p)) {
      wb_ci <- robustness$wild_bootstrap$conf_int
      cat(sprintf("Wild cluster bootstrap & -- & %.3f & [%.3f, %.3f] \\\\\n",
                  wb_p, wb_ci[1], wb_ci[2]))
    }
    cat("\\hline\n")
    cat(sprintf("\\multicolumn{4}{l}{Point estimate: %.3f} \\\\\n", coef_val))
    cat("\\hline\\hline\n")
    cat("\\end{tabular}\n")
    cat("\\begin{tablenotes}\n")
    cat("\\small\n")
    cat(sprintf("\\item \\textit{Notes:} N = %d. Clusters = %d states.\n",
                nrow(panel), n_distinct(panel$state_fips)))
    cat("\\item Wild bootstrap uses Webb (6-point) weights with 9,999 replications.\n")
    cat("\\end{tablenotes}\n")
    cat("\\end{table}\n")
    sink()

    cat("  Saved tables/tableA3_inference.tex\n")
  }, error = function(e) {
    cat("  Inference table error:", e$message, "\n")
  })
}

cat("\n=== All Tables Created ===\n")
cat("Tables saved to tables/ directory\n")
