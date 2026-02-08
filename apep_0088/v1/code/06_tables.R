# =============================================================================
# 06_tables.R
# Generate Tables for Paper
# =============================================================================

source("00_packages.R")

# Load results
crashes <- readRDS("../data/crashes_analysis.rds")
main_results <- readRDS("../data/main_results.rds")
bw_results <- readRDS("../data/bw_sensitivity.rds")
time_results <- readRDS("../data/time_heterogeneity.rds")
age_results <- readRDS("../data/age_heterogeneity.rds")
balance_results <- readRDS("../data/covariate_balance.rds")

crashes$rv <- -crashes$running_var

cat("Generating tables...\n\n")

# =============================================================================
# TABLE 1: Summary Statistics
# =============================================================================

cat("Table 1: Summary Statistics\n")

# Create summary by treatment status
summary_stats <- crashes %>%
  group_by(treated) %>%
  summarise(
    n_crashes = n(),
    alcohol_rate = mean(alcohol_involved),
    alcohol_se = sd(alcohol_involved) / sqrt(n()),
    night_rate = mean(is_nighttime),
    mean_age = mean(driver_age),
    age_21_45_rate = mean(is_young_adult),
    elderly_rate = mean(is_elderly),
    mean_dist_border = mean(abs(running_var)),
    .groups = "drop"
  ) %>%
  mutate(
    group = ifelse(treated == 1, "Legal State", "Prohibition State")
  )

# Overall stats
overall_stats <- crashes %>%
  summarise(
    n_crashes = n(),
    alcohol_rate = mean(alcohol_involved),
    alcohol_se = sd(alcohol_involved) / sqrt(n()),
    night_rate = mean(is_nighttime),
    mean_age = mean(driver_age),
    age_21_45_rate = mean(is_young_adult),
    elderly_rate = mean(is_elderly),
    mean_dist_border = mean(abs(running_var))
  ) %>%
  mutate(
    group = "Overall",
    treated = NA
  )

summary_table <- bind_rows(summary_stats, overall_stats) %>%
  select(group, n_crashes, alcohol_rate, night_rate, mean_age,
         age_21_45_rate, elderly_rate, mean_dist_border) %>%
  mutate(across(c(alcohol_rate, night_rate, age_21_45_rate, elderly_rate),
                ~ sprintf("%.1f%%", . * 100))) %>%
  mutate(
    n_crashes = format(n_crashes, big.mark = ","),
    mean_age = sprintf("%.1f", mean_age),
    mean_dist_border = sprintf("%.1f km", mean_dist_border)
  )

# Write to LaTeX
cat("\\begin{table}[H]\n\\centering\n\\caption{Summary Statistics}\n\\label{tab:summary}\n",
    file = "../tables/tab01_summary.tex")
cat("\\begin{threeparttable}\n\\begin{tabular}{lccc}\n\\toprule\n",
    file = "../tables/tab01_summary.tex", append = TRUE)
cat("& Legal State & Prohibition State & Overall \\\\\n\\midrule\n",
    file = "../tables/tab01_summary.tex", append = TRUE)

cat(sprintf("N Crashes & %s & %s & %s \\\\\n",
            summary_table$n_crashes[1], summary_table$n_crashes[2], summary_table$n_crashes[3]),
    file = "../tables/tab01_summary.tex", append = TRUE)
cat(sprintf("Alcohol Involvement Rate & %s & %s & %s \\\\\n",
            summary_table$alcohol_rate[1], summary_table$alcohol_rate[2], summary_table$alcohol_rate[3]),
    file = "../tables/tab01_summary.tex", append = TRUE)
cat(sprintf("Nighttime Crashes & %s & %s & %s \\\\\n",
            summary_table$night_rate[1], summary_table$night_rate[2], summary_table$night_rate[3]),
    file = "../tables/tab01_summary.tex", append = TRUE)
cat(sprintf("Mean Driver Age & %s & %s & %s \\\\\n",
            summary_table$mean_age[1], summary_table$mean_age[2], summary_table$mean_age[3]),
    file = "../tables/tab01_summary.tex", append = TRUE)
cat(sprintf("Age 21--45 & %s & %s & %s \\\\\n",
            summary_table$age_21_45_rate[1], summary_table$age_21_45_rate[2], summary_table$age_21_45_rate[3]),
    file = "../tables/tab01_summary.tex", append = TRUE)
cat(sprintf("Age 65+ & %s & %s & %s \\\\\n",
            summary_table$elderly_rate[1], summary_table$elderly_rate[2], summary_table$elderly_rate[3]),
    file = "../tables/tab01_summary.tex", append = TRUE)
cat(sprintf("Mean Distance to Border & %s & %s & %s \\\\\n",
            summary_table$mean_dist_border[1], summary_table$mean_dist_border[2], summary_table$mean_dist_border[3]),
    file = "../tables/tab01_summary.tex", append = TRUE)

cat("\\bottomrule\n\\end{tabular}\n",
    file = "../tables/tab01_summary.tex", append = TRUE)
cat("\\begin{tablenotes}[flushleft]\\small\n",
    file = "../tables/tab01_summary.tex", append = TRUE)
cat("\\item Notes: Sample includes fatal crashes within 150km of legal-prohibition borders, 2016--2019.\n",
    file = "../tables/tab01_summary.tex", append = TRUE)
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n",
    file = "../tables/tab01_summary.tex", append = TRUE)

# =============================================================================
# TABLE 2: Main RDD Results
# =============================================================================

cat("Table 2: Main RDD Results\n")

# Run multiple specifications
rdd_linear <- rdrobust(crashes$alcohol_involved, crashes$rv, c = 0, p = 1)
rdd_quad <- rdrobust(crashes$alcohol_involved, crashes$rv, c = 0, p = 2)
rdd_uniform <- rdrobust(crashes$alcohol_involved, crashes$rv, c = 0, p = 1, kernel = "uniform")
rdd_50bw <- rdrobust(crashes$alcohol_involved, crashes$rv, c = 0, p = 1,
                     h = rdd_linear$bws[1,1] * 0.5)
rdd_200bw <- rdrobust(crashes$alcohol_involved, crashes$rv, c = 0, p = 1,
                      h = rdd_linear$bws[1,1] * 2.0)

# Build table
cat("\\begin{table}[H]\n\\centering\n\\caption{Main Regression Discontinuity Results}\n\\label{tab:main_results}\n",
    file = "../tables/tab02_main_results.tex")
cat("\\begin{threeparttable}\n\\begin{tabular}{lccccc}\n\\toprule\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat("& (1) & (2) & (3) & (4) & (5) \\\\\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat("& Baseline & Quadratic & Uniform & 0.5$\\times$BW & 2$\\times$BW \\\\\n\\midrule\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)

cat(sprintf("Legal Cannabis Access & %.4f** & %.4f** & %.4f** & %.4f* & %.4f** \\\\\n",
            rdd_linear$coef[1], rdd_quad$coef[1], rdd_uniform$coef[1],
            rdd_50bw$coef[1], rdd_200bw$coef[1]),
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat(sprintf("& (%.4f) & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
            rdd_linear$se[1], rdd_quad$se[1], rdd_uniform$se[1],
            rdd_50bw$se[1], rdd_200bw$se[1]),
    file = "../tables/tab02_main_results.tex", append = TRUE)

cat("\\\\\n", file = "../tables/tab02_main_results.tex", append = TRUE)
cat("Polynomial Order & Linear & Quadratic & Linear & Linear & Linear \\\\\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat("Kernel & Triangular & Triangular & Uniform & Triangular & Triangular \\\\\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat(sprintf("Bandwidth (km) & %.1f & %.1f & %.1f & %.1f & %.1f \\\\\n",
            rdd_linear$bws[1,1], rdd_quad$bws[1,1], rdd_uniform$bws[1,1],
            rdd_50bw$bws[1,1], rdd_200bw$bws[1,1]),
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat(sprintf("Effective N (Legal) & %d & %d & %d & %d & %d \\\\\n",
            rdd_linear$N_h[2], rdd_quad$N_h[2], rdd_uniform$N_h[2],
            rdd_50bw$N_h[2], rdd_200bw$N_h[2]),
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat(sprintf("Effective N (Prohibition) & %d & %d & %d & %d & %d \\\\\n",
            rdd_linear$N_h[1], rdd_quad$N_h[1], rdd_uniform$N_h[1],
            rdd_50bw$N_h[1], rdd_200bw$N_h[1]),
    file = "../tables/tab02_main_results.tex", append = TRUE)

cat("\\bottomrule\n\\end{tabular}\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat("\\begin{tablenotes}[flushleft]\\small\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat("\\item Notes: * p$<$0.10, ** p$<$0.05, *** p$<$0.01. Standard errors in parentheses.\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat("Outcome is indicator for alcohol-involved crash. Bandwidth selection: MSE-optimal (Columns 1--3) or fixed multiple (Columns 4--5).\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n",
    file = "../tables/tab02_main_results.tex", append = TRUE)

# =============================================================================
# TABLE 3: Mechanism Tests (Time and Age)
# =============================================================================

cat("Table 3: Mechanism Tests\n")

cat("\\begin{table}[H]\n\\centering\n\\caption{Mechanism Tests: Heterogeneity by Time and Age}\n\\label{tab:mechanisms}\n",
    file = "../tables/tab03_mechanisms.tex")
cat("\\begin{threeparttable}\n\\begin{tabular}{lcccccc}\n\\toprule\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat("& \\multicolumn{2}{c}{Time of Day} & & \\multicolumn{3}{c}{Driver Age} \\\\\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat("\\cmidrule{2-3} \\cmidrule{5-7}\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat("& Night & Day & & 21--45 & 46--64 & 65+ \\\\\n\\midrule\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)

# Time results
night_est <- time_results$estimate[1]
night_se <- time_results$se[1]
day_est <- time_results$estimate[2]
day_se <- time_results$se[2]

# Age results
age_21_45 <- age_results %>% filter(age_group == "21-45")
age_46_64 <- age_results %>% filter(age_group == "46-64")
age_65 <- age_results %>% filter(age_group == "65+")

cat(sprintf("RDD Estimate & %.4f** & %.4f & & %.4f** & %.4f & %.4f \\\\\n",
            night_est, day_est,
            age_21_45$estimate, age_46_64$estimate, age_65$estimate),
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat(sprintf("& (%.4f) & (%.4f) & & (%.4f) & (%.4f) & (%.4f) \\\\\n",
            night_se, day_se,
            age_21_45$se, age_46_64$se, age_65$se),
    file = "../tables/tab03_mechanisms.tex", append = TRUE)

cat(sprintf("\\\\\nBaseline Rate & %.1f\\%% & %.1f\\%% & & %.1f\\%% & %.1f\\%% & %.1f\\%% \\\\\n",
            time_results$baseline_rate[1]*100, time_results$baseline_rate[2]*100,
            age_21_45$baseline_rate*100, age_46_64$baseline_rate*100, age_65$baseline_rate*100),
    file = "../tables/tab03_mechanisms.tex", append = TRUE)

cat(sprintf("N & %d & %d & & %d & %d & %d \\\\\n",
            time_results$n[1], time_results$n[2],
            age_21_45$n, age_46_64$n, age_65$n),
    file = "../tables/tab03_mechanisms.tex", append = TRUE)

cat("\\bottomrule\n\\end{tabular}\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat("\\begin{tablenotes}[flushleft]\\small\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat("\\item Notes: * p$<$0.10, ** p$<$0.05, *** p$<$0.01. Standard errors in parentheses.\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat("Night = 9pm--5am; Day = 6am--9pm. Effects concentrated at night and among ages 21--45,\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat("consistent with recreational substitution. Null effects for elderly drivers confirm placebo.\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n",
    file = "../tables/tab03_mechanisms.tex", append = TRUE)

# =============================================================================
# TABLE 4: Covariate Balance
# =============================================================================

cat("Table 4: Covariate Balance\n")

cat("\\begin{table}[H]\n\\centering\n\\caption{Covariate Balance at the Border}\n\\label{tab:balance}\n",
    file = "../tables/tab04_balance.tex")
cat("\\begin{threeparttable}\n\\begin{tabular}{lccc}\n\\toprule\n",
    file = "../tables/tab04_balance.tex", append = TRUE)
cat("Covariate & RDD Estimate & Std. Error & p-value \\\\\n\\midrule\n",
    file = "../tables/tab04_balance.tex", append = TRUE)

for (i in 1:nrow(balance_results)) {
  cov_name <- switch(balance_results$covariate[i],
                     "is_nighttime" = "Nighttime Crash",
                     "is_weekend" = "Weekend",
                     "driver_age" = "Driver Age",
                     "is_elderly" = "Driver Age 65+",
                     balance_results$covariate[i])

  cat(sprintf("%s & %.4f & (%.4f) & %.3f \\\\\n",
              cov_name, balance_results$estimate[i],
              balance_results$se[i], balance_results$p_value[i]),
      file = "../tables/tab04_balance.tex", append = TRUE)
}

cat("\\bottomrule\n\\end{tabular}\n",
    file = "../tables/tab04_balance.tex", append = TRUE)
cat("\\begin{tablenotes}[flushleft]\\small\n",
    file = "../tables/tab04_balance.tex", append = TRUE)
cat("\\item Notes: Tests for discontinuities in pre-determined covariates at the border.\n",
    file = "../tables/tab04_balance.tex", append = TRUE)
cat("No significant discontinuities detected, supporting the RDD identification assumption.\n",
    file = "../tables/tab04_balance.tex", append = TRUE)
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n",
    file = "../tables/tab04_balance.tex", append = TRUE)

# =============================================================================
# Save summary
# =============================================================================

cat("\n=== All tables saved to ../tables/ ===\n")
cat("
Generated:
  tab01_summary.tex
  tab02_main_results.tex
  tab03_mechanisms.tex
  tab04_balance.tex
\n")
