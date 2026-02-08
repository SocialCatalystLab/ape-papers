# ============================================================
# 06_tables.R - Regression tables and summary statistics
# Paper 148: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v5)
# Revision of apep_0161 (family apep_0150)
# ============================================================
# PROVENANCE:
#   Inputs:
#     data/analysis_panel.rds        (from 02_clean_data.R, PRIMARY working-age)
#     data/analysis_panel_allages.rds (from 02_clean_data.R, SECONDARY all-ages)
#     data/policy_database.csv       (from 01_fetch_data.R)
#     data/main_results.rds          (from 03_main_analysis.R, PRIMARY)
#     data/main_results_allages.rds  (from 03_main_analysis.R, SECONDARY)
#     data/robustness_results.rds    (from 04_robustness.R)
#     data/mde_table.rds             (from 04_robustness.R)
#     data/dilution_table.rds        (from 04_robustness.R)
#     data/vermont_sensitivity.rds   (from 04_robustness.R)
#   Outputs:
#     tables/table1_summary_stats.tex
#     tables/table2_policy_dates.tex
#     tables/table3_main_results.tex   (PRIMARY working-age)
#     tables/table3_cs_sa_results.tex
#     tables/table4_robustness.tex
#     tables/table5_heterogeneity.tex
#     tables/tableA1_pretreatment_balance.tex
#     tables/tableA2_mde.tex
#     tables/tableA3_inference.tex
#     tables/tableA4_dilution.tex
#     tables/tableA5_vermont.tex
#     tables/tableA6_allages.tex
# ============================================================

source("code/00_packages.R")

dir.create("tables", showWarnings = FALSE)

# Verify inputs
stopifnot(file.exists("data/analysis_panel.rds"))
stopifnot(file.exists("data/policy_database.csv"))

# Load data and results
panel        <- readRDS("data/analysis_panel.rds")
policy_db    <- read_csv("data/policy_database.csv", show_col_types = FALSE)
main_results <- tryCatch(readRDS("data/main_results.rds"), error = function(e) NULL)
robustness   <- tryCatch(readRDS("data/robustness_results.rds"), error = function(e) NULL)

cat("Panel loaded:", nrow(panel), "observations (working-age 25-64)\n")

# ============================================================
# Table 1: Summary Statistics (Working-Age PRIMARY)
# ============================================================

cat("\n=== Table 1: Summary Statistics ===\n")

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

summ_all <- compute_summ(panel, "Full Sample")
summ_treated_pre <- compute_summ(
  panel %>% filter(first_treat > 0, year < first_treat), "Treated (Pre)")
summ_control_pre <- compute_summ(
  panel %>% filter(first_treat == 0), "Never-Treated")
summ_treated_post <- compute_summ(
  panel %>% filter(first_treat > 0, year >= first_treat), "Treated (Post)")

table1 <- bind_rows(summ_all, summ_treated_pre, summ_treated_post, summ_control_pre)

print(as.data.frame(table1), digits = 3, row.names = FALSE)
write_csv(table1, "tables/table1_summary_stats.csv")

sink("tables/table1_summary_stats.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Working-Age (25--64) Diabetes Mortality Rates}\n")
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
cat("ages 25--64, ICD-10 codes E10--E14.\n")
cat("\\item Source: CDC WONDER Underlying Cause of Death (D76/D176), 1999--2023. ")
cat(sprintf("Panel: %d states $\\times$ %d years (%d state-year observations).\n",
            n_distinct(panel$state_fips), n_distinct(panel$year), nrow(panel)))
cat(sprintf("\\item Treated states: %d. Never-treated states: %d. Vermont excluded.\n",
            n_distinct(panel$state_fips[panel$first_treat > 0]),
            n_distinct(panel$state_fips[panel$first_treat == 0])))
cat("\\item Treated (Pre) N may be less than the full balanced count due to CDC suppression\n")
cat("of state-year cells with $<$10 diabetes deaths (ages 25--64). Suppressed cells are\n")
cat("excluded rather than imputed.\n")
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
  state_label <- table2$State[i]
  treat_yr <- table2$`Treatment Year`[i]
  if (state_label == "Vermont") {
    state_label <- "Vermont$^{\\dagger}$"
  } else if (treat_yr >= 2024) {
    state_label <- paste0(state_label, "$^{\\ddagger}$")
  }
  cat(sprintf("%s & %s & %s & %d & \\$%d \\\\\n",
              state_label, table2$Abbr[i],
              as.character(table2$`Effective Date`[i]),
              treat_yr, table2$`Cap Amount ($)`[i]))
}

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Treatment year = first calendar year of full exposure.\n")
cat("\\item $^{\\ddagger}$Reclassified as not-yet-treated (treatment postdates 2023 data endpoint).\n")
cat("\\item $^{\\dagger}$Vermont excluded from primary analysis; post-treatment working-age mortality suppressed by CDC.\n")
cat("\\item Sources: NCSL Insulin Copay Cap Tracker, state session laws, ADA legislative tracker.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tables/table2_policy_dates.tex\n")

# ============================================================
# Table 3: Main Results (Working-Age PRIMARY)
# ============================================================

cat("\n=== Table 3: Main Results (Working-Age 25-64) ===\n")

if (!is.null(main_results)) {
  twfe_models <- list(
    "(1) TWFE" = main_results$twfe_basic,
    "(2) + COVID" = main_results$twfe_covid,
    "(3) Log Rate" = main_results$twfe_log,
    "(4) + Trends" = main_results$twfe_trends
  )

  # Add Medicaid expansion spec if available
  if (!is.null(main_results$twfe_medicaid)) {
    twfe_models[["(5) + Medicaid Exp."]] <- main_results$twfe_medicaid
  }

  tryCatch({
    msummary(
      twfe_models,
      stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
      coef_map = c(
        "treated" = "Post Copay Cap",
        "covid_year" = "COVID Year",
        "covid_death_rate" = "COVID Death Rate",
        "medicaid_expanded" = "Medicaid Expanded"
      ),
      gof_map = c("nobs", "r.squared", "adj.r.squared",
                   "FE: state_id", "FE: year"),
      output = "tables/table3_main_results.tex",
      title = "Effect of Insulin Copay Caps on Working-Age (25--64) Diabetes Mortality",
      notes = c(
        "Standard errors clustered at state level in parentheses.",
        "All specifications include state and year fixed effects.",
        "Outcome: working-age (25--64) diabetes mortality rate per 100,000 (ICD-10 E10--E14).",
        "Column 3 uses log(mortality rate + 0.1) as outcome.",
        "Column 4 adds state-specific linear time trends.",
        "Column 5 controls for Medicaid expansion status.",
        "Vermont excluded from all specifications."
      )
    )
    main_tex <- readLines("tables/table3_main_results.tex")
    main_tex <- sub(
      "(caption=\\{[^}]+\\}),",
      "\\1,\nlabel={tab:main_results},",
      main_tex
    )
    writeLines(main_tex, "tables/table3_main_results.tex")
    cat("  Saved tables/table3_main_results.tex\n")
  }, error = function(e) {
    cat("  modelsummary error:", e$message, "\n")
  })

  tryCatch({
    msummary(
      twfe_models,
      stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
      coef_map = c("treated" = "Post Copay Cap"),
      gof_map = c("nobs", "r.squared"),
      output = "tables/table3_main_results.csv"
    )
  }, error = function(e) NULL)

  # CS-DiD and Sun-Abraham
  sink("tables/table3_cs_sa_results.tex", append = FALSE)
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Heterogeneity-Robust Estimators (Working-Age 25--64)}\n")
  cat("\\label{tab:cs_sa}\n")
  cat("\\begin{tabular}{lcc}\n")
  cat("\\hline\\hline\n")
  cat("Estimator & ATT & SE \\\\\n")
  cat("\\hline\n")

  if (!is.null(main_results$cs_agg_simple)) {
    cs_att <- main_results$cs_agg_simple$overall.att
    cs_se  <- main_results$cs_agg_simple$overall.se
    cs_sig <- sig_stars(cs_att, cs_se)
    cat(sprintf("Callaway-Sant'Anna (2021) & %.3f%s & (%.3f) \\\\\n",
                cs_att, cs_sig, cs_se))
  }

  if (!is.null(main_results$sa_result)) {
    sa_agg <- tryCatch(summary(main_results$sa_result, agg = "ATT"), error = function(e) NULL)
    if (!is.null(sa_agg)) {
      sa_att <- sa_agg$coeftable[1, 1]
      sa_se  <- sa_agg$coeftable[1, 2]
      sa_sig <- sig_stars(sa_att, sa_se)
      cat(sprintf("Sun-Abraham (2021) & %.3f%s & (%.3f) \\\\\n",
                  sa_att, sa_sig, sa_se))
    }
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$.\n")
  cs_method <- if (!is.null(main_results$cs_est_method_used)) main_results$cs_est_method_used else "dr"
  cs_method_label <- ifelse(cs_method == "dr", "doubly robust", "outcome regression")
  cat(sprintf("\\item CS-DiD uses %s estimation with never-treated control group.\n", cs_method_label))
  cat("\\item Sun-Abraham uses interaction-weighted estimator via \\texttt{fixest::sunab()}.\n")
  cat(sprintf("\\item N = %d state-year observations. Clusters = %d states.\n",
              nrow(panel), n_distinct(panel$state_fips)))
  cat("\\item Outcome: working-age (25--64) diabetes mortality per 100,000.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/table3_cs_sa_results.tex\n")
}

# ============================================================
# Table 4: Robustness Results
# ============================================================

cat("\n=== Table 4: Robustness Results ===\n")

if (!is.null(robustness)) {
  robustness_table <- data.frame(
    Specification = character(), ATT = numeric(), SE = numeric(),
    CI_lower = numeric(), CI_upper = numeric(), N = integer(),
    stringsAsFactors = FALSE
  )

  # Helper to add rows
  add_row <- function(tbl, spec, att, se, n = NA) {
    rbind(tbl, data.frame(
      Specification = spec, ATT = att, SE = se,
      CI_lower = att - 1.96 * se, CI_upper = att + 1.96 * se, N = n
    ))
  }

  # Baseline CS-DiD
  if (!is.null(main_results) && !is.null(main_results$cs_agg_simple)) {
    cs_agg <- main_results$cs_agg_simple
    robustness_table <- add_row(robustness_table, "CS-DiD (baseline, 25-64)",
                                cs_agg$overall.att, cs_agg$overall.se)
  }

  # Exclude COVID
  if (!is.null(robustness$twfe_no_covid)) {
    robustness_table <- add_row(robustness_table, "TWFE excl. 2020-2021",
                                coef(robustness$twfe_no_covid)["treated"],
                                summary(robustness$twfe_no_covid)$se["treated"],
                                nobs(robustness$twfe_no_covid))
  }

  # COVID controls
  if (!is.null(robustness$twfe_covid_control)) {
    robustness_table <- add_row(robustness_table, "TWFE + COVID death rate",
                                coef(robustness$twfe_covid_control)["treated"],
                                summary(robustness$twfe_covid_control)$se["treated"],
                                nobs(robustness$twfe_covid_control))
  }

  # COVID dummies (MEDIUM flag fix: report this specification)
  if (!is.null(robustness$twfe_covid_dummies)) {
    robustness_table <- add_row(robustness_table, "TWFE + COVID year dummies",
                                coef(robustness$twfe_covid_dummies)["treated"],
                                summary(robustness$twfe_covid_dummies)$se["treated"],
                                nobs(robustness$twfe_covid_dummies))
  }

  # CS-DiD no COVID
  if (!is.null(robustness$cs_no_covid_att)) {
    robustness_table <- add_row(robustness_table, "CS-DiD excl. 2020-2021",
                                robustness$cs_no_covid_att$overall.att,
                                robustness$cs_no_covid_att$overall.se)
  }

  # Log spec
  if (!is.null(robustness$cs_log)) {
    robustness_table <- add_row(robustness_table, "CS-DiD (log mortality)",
                                robustness$cs_log$overall.att,
                                robustness$cs_log$overall.se)
  }

  # Wild bootstrap
  if (!is.null(robustness$wild_bootstrap)) {
    robustness_table <- rbind(robustness_table, data.frame(
      Specification = "Wild cluster bootstrap",
      ATT = robustness$wild_bootstrap$point_estimate,
      SE = NA, CI_lower = robustness$wild_bootstrap$conf_int[1],
      CI_upper = robustness$wild_bootstrap$conf_int[2], N = NA
    ))
  }

  # Medicaid expansion control
  if (!is.null(robustness$twfe_medicaid)) {
    robustness_table <- add_row(robustness_table, "TWFE + Medicaid expansion",
                                coef(robustness$twfe_medicaid)["treated"],
                                summary(robustness$twfe_medicaid)$se["treated"],
                                nobs(robustness$twfe_medicaid))
  }

  # All-ages robustness
  if (!is.null(robustness$allages_robustness)) {
    aa <- robustness$allages_robustness
    if (!is.na(aa$twfe_att)) {
      robustness_table <- add_row(robustness_table, "TWFE (all ages)",
                                  aa$twfe_att, aa$twfe_se)
    }
    if (!is.na(aa$cs_att)) {
      robustness_table <- add_row(robustness_table, "CS-DiD (all ages)",
                                  aa$cs_att, aa$cs_se)
    }
  }

  # Placebos
  if (!is.null(robustness$placebo_heart_twfe)) {
    robustness_table <- add_row(robustness_table, "Placebo: Heart Disease (TWFE)",
                                coef(robustness$placebo_heart_twfe)["treated"],
                                summary(robustness$placebo_heart_twfe)$se["treated"],
                                nobs(robustness$placebo_heart_twfe))
  }

  if (!is.null(robustness$placebo_cancer_twfe)) {
    robustness_table <- add_row(robustness_table, "Placebo: Cancer (TWFE)",
                                coef(robustness$placebo_cancer_twfe)["treated"],
                                summary(robustness$placebo_cancer_twfe)$se["treated"],
                                nobs(robustness$placebo_cancer_twfe))
  }

  if (!is.null(robustness$cs_placebo_heart_full) && !is.null(robustness$cs_placebo_heart_full$agg)) {
    agg <- robustness$cs_placebo_heart_full$agg
    robustness_table <- add_row(robustness_table, "Placebo: Heart (CS-DiD, Full)",
                                agg$overall.att, agg$overall.se)
  }

  if (!is.null(robustness$cs_placebo_cancer_full) && !is.null(robustness$cs_placebo_cancer_full$agg)) {
    agg <- robustness$cs_placebo_cancer_full$agg
    robustness_table <- add_row(robustness_table, "Placebo: Cancer (CS-DiD, Full)",
                                agg$overall.att, agg$overall.se)
  }

  print(robustness_table, digits = 4, row.names = FALSE)
  write_csv(robustness_table, "tables/table4_robustness.csv")

  # LaTeX
  sink("tables/table4_robustness.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Robustness Checks and Placebo Tests (Working-Age 25--64)}\n")
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
    # Use sig_stars helper (Flag 8 fix)
    stars <- if (!is.na(robustness_table$SE[i])) {
      sig_stars(robustness_table$ATT[i], robustness_table$SE[i])
    } else { "" }
    cat(sprintf("%s & %.3f%s & %s & %s \\\\\n",
                robustness_table$Specification[i],
                robustness_table$ATT[i], stars,
                se_str, ci_str))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$. ")
  cat("Standard errors clustered at state level.\n")
  cat("\\item Primary outcome: working-age (25--64) diabetes mortality per 100,000.\n")
  cat("\\item Wild bootstrap uses Webb (6-point) weights with 9,999 replications.\n")
  cat("\\item All-ages specifications shown for comparison (outcome dilution expected).\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/table4_robustness.tex\n")
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
        title = "Heterogeneous Effects by Copay Cap Amount (Working-Age 25--64)",
        notes = c(
          "Standard errors clustered at state level in parentheses.",
          "Each column restricts treated states to caps in the specified range.",
          "Control group: never-treated states (same across columns).",
          "Outcome: working-age (25--64) diabetes mortality per 100,000."
        )
      )
      het_tex <- readLines("tables/table5_heterogeneity.tex")
      het_tex <- sub(
        "caption=\\{Heterogeneous Effects by Copay Cap Amount",
        "caption={Heterogeneous Effects by Copay Cap Amount",
        het_tex
      )
      writeLines(het_tex, "tables/table5_heterogeneity.tex")
      cat("  Saved tables/table5_heterogeneity.tex\n")
    }, error = function(e) {
      cat("  Heterogeneity table error:", e$message, "\n")
    })
  }
}

# ============================================================
# Appendix Table A1: Pre-Treatment Balance
# ============================================================

cat("\n=== Appendix: Pre-Treatment Balance ===\n")

pre_balance <- panel %>%
  filter(
    (first_treat > 0 & year < first_treat) |
    (first_treat == 0)
  ) %>%
  filter(year <= 2017) %>%
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

sink("tables/tableA1_pretreatment_balance.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Pre-Treatment Balance: Treated vs.\\ Control States (1999--2017, Ages 25--64)}\n")
cat("\\label{tab:balance}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\hline\\hline\n")
cat(" & Ever-Treated & Never-Treated \\\\\n")
cat("\\hline\n")

et <- pre_balance %>% filter(group == "Ever-Treated")
nt <- pre_balance %>% filter(group == "Never-Treated")

if (nrow(et) > 0 && nrow(nt) > 0) {
  cat(sprintf("Diabetes Mortality (25--64) & %.2f & %.2f \\\\\n",
              et$`Mean Diabetes Mort. Rate`, nt$`Mean Diabetes Mort. Rate`))
  cat(sprintf(" \\quad (SD) & (%.2f) & (%.2f) \\\\\n",
              et$`SD Diabetes Mort. Rate`, nt$`SD Diabetes Mort. Rate`))
  cat(sprintf("Heart Disease Mortality & %.2f & %.2f \\\\\n",
              et$`Mean Heart Mort. Rate`, nt$`Mean Heart Mort. Rate`))
  cat(sprintf("Cancer Mortality & %.2f & %.2f \\\\\n",
              et$`Mean Cancer Mort. Rate`, nt$`Mean Cancer Mort. Rate`))
  cat(sprintf("N States & %d & %d \\\\\n", et$`N States`, nt$`N States`))
  cat(sprintf("N State-Years & %d & %d \\\\\n", et$`N State-Years`, nt$`N State-Years`))
}

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Pre-treatment period: 1999--2017 (before first state adopted caps).\n")
cat("\\item All rates per 100,000 (ages 25--64). Source: CDC WONDER.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tables/tableA1_pretreatment_balance.tex\n")

# ============================================================
# Table A2: MDE (Working-Age)
# ============================================================

cat("\n=== Appendix: MDE Table ===\n")

if (file.exists("data/mde_table.rds")) {
  mde_table <- readRDS("data/mde_table.rds")
  print(mde_table, digits = 3, row.names = FALSE)

  sink("tables/tableA2_mde.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Minimum Detectable Effects (Working-Age 25--64)}\n")
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
  cat("\\item Two-sided test at 5\\% significance. SE from actual estimator variance.\n")
  cat("\\item Working-age (25--64) panel. Vermont excluded.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/tableA2_mde.tex\n")
}

# ============================================================
# Table A3: Inference Comparison (3 SE types)
#   Flag 8 fix: use format_pval() helper
# ============================================================

cat("\n=== Appendix: Inference Comparison ===\n")

if (!is.null(main_results) && !is.null(robustness)) {
  tryCatch({
    twfe_basic <- main_results$twfe_basic
    coef_val <- coef(twfe_basic)["treated"]

    se_cr <- summary(twfe_basic, cluster = ~state_id)
    se1 <- se_cr$coeftable["treated", "Std. Error"]
    p1 <- se_cr$coeftable["treated", "Pr(>|t|)"]

    se_cr2 <- summary(twfe_basic, cluster = ~state_id,
                       ssc = ssc(adj = TRUE, fixef.K = "full", cluster.adj = TRUE))
    se2 <- se_cr2$coeftable["treated", "Std. Error"]
    p2 <- se_cr2$coeftable["treated", "Pr(>|t|)"]

    wb_p <- if (!is.null(robustness$wild_bootstrap)) robustness$wild_bootstrap$p_val else NA

    sink("tables/tableA3_inference.tex")
    cat("\\begin{table}[htbp]\n")
    cat("\\centering\n")
    cat("\\caption{Inference Robustness: Three SE Types for TWFE Treatment Effect (Working-Age)}\n")
    cat("\\label{tab:inference}\n")
    cat("\\begin{tabular}{lccc}\n")
    cat("\\hline\\hline\n")
    cat(" & SE & $p$-value & 95\\% CI \\\\\n")
    cat("\\hline\n")
    # Flag 8 fix: use format_pval()
    cat(sprintf("Cluster-robust & %.3f & %s & [%.3f, %.3f] \\\\\n",
                se1, format_pval(p1), coef_val - 1.96*se1, coef_val + 1.96*se1))
    cat(sprintf("CR2 (small-sample adj.) & %.3f & %s & [%.3f, %.3f] \\\\\n",
                se2, format_pval(p2), coef_val - 1.96*se2, coef_val + 1.96*se2))
    if (!is.na(wb_p)) {
      wb_ci <- robustness$wild_bootstrap$conf_int
      cat(sprintf("Wild cluster bootstrap & -- & %s & [%.3f, %.3f] \\\\\n",
                  format_pval(wb_p), wb_ci[1], wb_ci[2]))
    }
    cat("\\hline\n")
    cat(sprintf("\\multicolumn{4}{l}{Point estimate: %.3f} \\\\\n", coef_val))
    cat("\\hline\\hline\n")
    cat("\\end{tabular}\n")
    cat("\\begin{tablenotes}\n")
    cat("\\small\n")
    cat(sprintf("\\item \\textit{Notes:} N = %d. Clusters = %d states.\n",
                nrow(panel), n_distinct(panel$state_fips)))
    cat("\\item Wild bootstrap: Webb (6-point) weights, 9,999 replications.\n")
    cat("\\item Working-age (25--64) panel. Vermont excluded.\n")
    cat("\\end{tablenotes}\n")
    cat("\\end{table}\n")
    sink()

    cat("  Saved tables/tableA3_inference.tex\n")
  }, error = function(e) {
    cat("  Inference table error:", e$message, "\n")
  })
}

# ============================================================
# Table A4: MDE Dilution Mapping (Working-Age)
# ============================================================

cat("\n=== Appendix: MDE Dilution Mapping ===\n")

if (file.exists("data/dilution_table.rds")) {
  dilution_table <- readRDS("data/dilution_table.rds")
  print(dilution_table, digits = 3, row.names = FALSE)

  sink("tables/tableA4_dilution.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{MDE Dilution Mapping: Working-Age (25--64) Panel}\n")
  cat("\\label{tab:dilution}\n")
  cat("\\begin{tabular}{ccccc}\n")
  cat("\\hline\\hline\n")
  cat("Treated Share & $s$ (\\%) & Pop-Level MDE & Treated-Group MDE & MDE (\\% Baseline) \\\\\n")
  cat("\\hline\n")

  for (i in 1:nrow(dilution_table)) {
    cat(sprintf("%.2f & %.0f\\%% & %.2f & %.2f & %.1f\\%% \\\\\n",
                dilution_table$treated_share[i],
                dilution_table$treated_share_pct[i],
                dilution_table$mde_pop_level[i],
                dilution_table$mde_treated_group[i],
                dilution_table$mde_treated_pct_baseline[i]))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} Dilution algebra: $\\text{ATT}_{\\text{pop}} = s \\times \\Delta_T$.\n")
  cat("\\item Working-age restriction raises $s$ from $\\approx$3\\% (all ages) to $\\approx$15--20\\% (ages 25--64).\n")
  cat("\\item Population-level MDE at 80\\% power, 5\\% significance using TWFE SE.\n")
  cat(sprintf("\\item Mean baseline working-age diabetes mortality: %.2f per 100,000.\n",
              dilution_table$mean_mortality[1]))
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/tableA4_dilution.tex\n")
}

# ============================================================
# Table A5: Vermont Sensitivity (Flag 6)
# ============================================================

cat("\n=== Appendix: Vermont Sensitivity ===\n")

if (file.exists("data/vermont_sensitivity.rds")) {
  vt_sens <- readRDS("data/vermont_sensitivity.rds")

  sink("tables/tableA5_vermont.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Vermont Sensitivity Analysis}\n")
  cat("\\label{tab:vermont}\n")
  cat("\\begin{tabular}{lcc}\n")
  cat("\\hline\\hline\n")
  cat("Specification & ATT & SE \\\\\n")
  cat("\\hline\n")

  for (nm in names(vt_sens)) {
    s <- vt_sens[[nm]]
    stars <- sig_stars(s$att, s$se)
    cat(sprintf("%s & %.3f%s & (%.3f) \\\\\n", s$spec, s$att, stars, s$se))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$.\n")
  cat("\\item TWFE specifications with state and year FE, clustered at state level.\n")
  cat("\\item Vermont (2022 copay cap) has suppressed working-age diabetes mortality data.\n")
  cat("\\item Primary specification excludes Vermont entirely.\n")
  cat("\\item ``Vermont as treated'' includes VT in treated group (limited post-treatment data).\n")
  cat("\\item ``Vermont as control'' reclassifies VT as never-treated.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/tableA5_vermont.tex\n")
} else {
  cat("  Vermont sensitivity not found\n")
}

# ============================================================
# Table A6: All-Ages Comparison
# ============================================================

cat("\n=== Appendix: All-Ages Results ===\n")

if (file.exists("data/main_results_allages.rds")) {
  aa_results <- readRDS("data/main_results_allages.rds")

  sink("tables/tableA6_allages.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Comparison: Working-Age (25--64) vs.\\ All-Ages Results}\n")
  cat("\\label{tab:allages}\n")
  cat("\\begin{tabular}{lccc}\n")
  cat("\\hline\\hline\n")
  cat("Estimator & Working-Age ATT & All-Ages ATT & All-Ages SE \\\\\n")
  cat("\\hline\n")

  # TWFE
  wa_coef <- coef(main_results$twfe_basic)["treated"]
  wa_se <- summary(main_results$twfe_basic)$se["treated"]
  aa_coef <- coef(aa_results$twfe_basic)["treated"]
  aa_se <- summary(aa_results$twfe_basic)$se["treated"]
  cat(sprintf("TWFE & %.3f%s & %.3f%s & (%.3f) \\\\\n",
              wa_coef, sig_stars(wa_coef, wa_se),
              aa_coef, sig_stars(aa_coef, aa_se), aa_se))
  cat(sprintf(" & (%.3f) & & \\\\\n", wa_se))

  # CS-DiD
  if (!is.null(main_results$cs_agg_simple) && !is.null(aa_results$cs_agg_simple)) {
    wa_cs <- main_results$cs_agg_simple
    aa_cs <- aa_results$cs_agg_simple
    cat(sprintf("Callaway-Sant'Anna & %.3f%s & %.3f%s & (%.3f) \\\\\n",
                wa_cs$overall.att, sig_stars(wa_cs$overall.att, wa_cs$overall.se),
                aa_cs$overall.att, sig_stars(aa_cs$overall.att, aa_cs$overall.se),
                aa_cs$overall.se))
    cat(sprintf(" & (%.3f) & & \\\\\n", wa_cs$overall.se))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$.\n")
  cat("\\item Working-age (25--64) is the primary specification. All-ages shown for comparison.\n")
  cat("\\item Outcome dilution: copay caps affect $\\approx$3\\% of all-ages population vs.\\ $\\approx$15--20\\% of working-age.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/tableA6_allages.tex\n")
}

# ============================================================
# Table 6: Insulin Utilization Results (Intermediate Outcome)
# ============================================================

cat("\n=== Table 6: Insulin Utilization Results ===\n")

if (file.exists("data/insulin_results.rds")) {
  insulin_res <- readRDS("data/insulin_results.rds")

  sink("tables/table6_insulin.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Intermediate Outcome: Effect on Medicaid Insulin Prescriptions}\n")
  cat("\\label{tab:insulin}\n")
  cat("\\begin{tabular}{lcc}\n")
  cat("\\hline\\hline\n")
  cat("Estimator & ATT & SE \\\\\n")
  cat("\\hline\n")

  if (!is.null(insulin_res$twfe_log)) {
    coef_val <- coef(insulin_res$twfe_log)["treated"]
    se_val <- summary(insulin_res$twfe_log)$se["treated"]
    stars <- sig_stars(coef_val, se_val)
    cat(sprintf("TWFE (log Rx) & %.4f%s & (%.4f) \\\\\n", coef_val, stars, se_val))
    pct_change <- (exp(coef_val) - 1) * 100
    cat(sprintf("\\quad Implied \\%% change & \\multicolumn{2}{c}{%.2f\\%%} \\\\\n", pct_change))
  }

  if (!is.null(insulin_res$twfe_level)) {
    coef_val <- coef(insulin_res$twfe_level)["treated"]
    se_val <- summary(insulin_res$twfe_level)$se["treated"]
    stars <- sig_stars(coef_val, se_val)
    cat(sprintf("TWFE (levels) & %.1f%s & (%.1f) \\\\\n", coef_val, stars, se_val))
  }

  if (!is.null(insulin_res$cs_agg)) {
    cs_att <- insulin_res$cs_agg$overall.att
    cs_se <- insulin_res$cs_agg$overall.se
    stars <- sig_stars(cs_att, cs_se)
    cat(sprintf("CS-DiD (log Rx) & %.4f%s & (%.4f) \\\\\n", cs_att, stars, cs_se))
    pct_cs <- (exp(cs_att) - 1) * 100
    cat(sprintf("\\quad Implied \\%% change & \\multicolumn{2}{c}{%.2f\\%%} \\\\\n", pct_cs))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$.\n")
  cat("\\item Outcome: Medicaid insulin prescriptions from CMS State Drug Utilization Data (SDUD).\n")
  cat("\\item Log specification uses $\\log$(total prescriptions). Levels in raw counts.\n")
  cat("\\item \\textbf{Important:} Medicaid SDUD covers Medicaid beneficiaries, not commercial insurance.\n")
  cat("State copay caps primarily target commercial plans. A null effect confirms commercial-only targeting;\n")
  cat("a positive effect suggests broader state-level policy attention to insulin access.\n")
  cat(sprintf("\\item N = %d state-year observations (2015--2024). Clusters = %d states.\n",
              insulin_res$n_obs, insulin_res$n_states))
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/table6_insulin.tex\n")
} else {
  cat("  Insulin results not found — skipping Table 6\n")
}

# ============================================================
# Table A7: Cohort-Specific ATTs (Reviewer Request)
# ============================================================

cat("\n=== Appendix: Cohort-Specific ATTs ===\n")

if (file.exists("data/cohort_att_table.rds")) {
  cohort_att <- readRDS("data/cohort_att_table.rds")

  sink("tables/tableA7_cohort_att.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Cohort-Specific Treatment Effects (Callaway-Sant'Anna)}\n")
  cat("\\label{tab:cohort_att}\n")
  cat("\\begin{tabular}{ccccc}\n")
  cat("\\hline\\hline\n")
  cat("Treatment Cohort & ATT & SE & 95\\% CI & $p$-value \\\\\n")
  cat("\\hline\n")

  for (i in 1:nrow(cohort_att)) {
    stars <- sig_stars(cohort_att$att[i], cohort_att$se[i])
    cat(sprintf("%d & %.3f%s & (%.3f) & [%.3f, %.3f] & %s \\\\\n",
                cohort_att$cohort[i],
                cohort_att$att[i], stars,
                cohort_att$se[i],
                cohort_att$ci_lower[i], cohort_att$ci_upper[i],
                format_pval(cohort_att$p_value[i])))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$.\n")
  cat("\\item Group-specific ATTs from Callaway-Sant'Anna (2021) group aggregation.\n")
  cat("\\item Each row shows the average treatment effect for states that adopted copay caps\n")
  cat("in the specified year. Heterogeneity across cohorts is expected if policy design\n")
  cat("or implementation timing relative to pandemic varies.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/tableA7_cohort_att.tex\n")
} else {
  cat("  Cohort ATT table not found — skipping\n")
}

# ============================================================
# Table A8: Suppression Documentation
# ============================================================

cat("\n=== Appendix: Suppression Documentation ===\n")

if (!is.null(robustness) && !is.null(robustness$suppression_info)) {
  supp <- robustness$suppression_info

  sink("tables/tableA8_suppression.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{CDC Suppression in Working-Age (25--64) Diabetes Mortality Data}\n")
  cat("\\label{tab:suppression}\n")
  cat("\\begin{tabular}{lc}\n")
  cat("\\hline\\hline\n")
  cat("Statistic & Value \\\\\n")
  cat("\\hline\n")
  cat(sprintf("Total state-year observations & %d \\\\\n", supp$n_total))
  cat(sprintf("Suppressed observations (deaths $<$ 10) & %d \\\\\n", supp$n_suppressed))
  cat(sprintf("Suppression rate & %.1f\\%% \\\\\n", supp$n_suppressed / supp$n_total * 100))
  cat(sprintf("States with any suppression & %d \\\\\n", supp$n_states_suppressed))
  cat("\\hline\n")
  cat("\\multicolumn{2}{l}{\\textit{Suppression Bounds (TWFE ATT)}} \\\\\n")
  if (!is.na(supp$twfe_lower)) {
    cat(sprintf("Lower bound (impute deaths $= 0$) & %.3f \\\\\n", supp$twfe_lower))
  }
  cat(sprintf("Primary (drop suppressed) & %.3f \\\\\n", supp$twfe_primary))
  if (!is.na(supp$twfe_upper)) {
    cat(sprintf("Upper bound (impute deaths $= 9$) & %.3f \\\\\n", supp$twfe_upper))
  }
  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} CDC WONDER suppresses state-year cells with fewer than 10 deaths.\n")
  cat("\\item Primary specification drops suppressed cells. Bounds impute at extreme values.\n")
  cat("\\item Suppression is concentrated in small-population states and is uncorrelated with\n")
  cat("treatment status (suppressed cells occur in both treated and control states).\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("  Saved tables/tableA8_suppression.tex\n")
} else {
  cat("  Suppression info not found — skipping\n")
}

cat("\n=== All Tables Created ===\n")
cat("Tables saved to tables/ directory\n")
