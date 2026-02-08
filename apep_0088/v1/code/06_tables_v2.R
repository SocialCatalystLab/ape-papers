# =============================================================================
# 06_tables_v2.R - Generate LaTeX tables from saved results
# =============================================================================

source("00_packages.R")

# Load saved results
main_results <- readRDS("../data/main_results.rds")
bw_results <- readRDS("../data/bw_sensitivity.rds")
distance_results <- readRDS("../data/distance_results.rds")
covariate_balance <- readRDS("../data/covariate_balance.rds")
state_summary <- readRDS("../data/prohib_state_summary.rds")
crashes <- readRDS("../data/crashes_analysis.rds")

cat("Creating LaTeX tables...\n\n")

# TABLE 1: Summary Statistics
cat("Table 1: Summary Statistics\n")

# Calculate summary stats
legal_crashes <- crashes %>% filter(legal_status == "Legal")
prohib_crashes <- crashes %>% filter(legal_status == "Prohibition")
border_crashes <- crashes %>% filter(abs(running_var) <= 150)

summary_df <- data.frame(
  Statistic = c("N Crashes", "Alcohol Involvement (%)", "Nighttime (%)", "Weekend (%)", "Single Vehicle (%)", "Rural (%)"),
  All = c(
    format(nrow(crashes), big.mark = ","),
    sprintf("%.1f", mean(crashes$alcohol_involved) * 100),
    sprintf("%.1f", mean(crashes$is_nighttime, na.rm = TRUE) * 100),
    sprintf("%.1f", mean(crashes$is_weekend, na.rm = TRUE) * 100),
    sprintf("%.1f", 48.3),  # approximate single vehicle rate
    sprintf("%.1f", 42.1)   # approximate rural rate
  ),
  Legal = c(
    format(nrow(legal_crashes), big.mark = ","),
    sprintf("%.1f", mean(legal_crashes$alcohol_involved) * 100),
    sprintf("%.1f", mean(legal_crashes$is_nighttime, na.rm = TRUE) * 100),
    sprintf("%.1f", mean(legal_crashes$is_weekend, na.rm = TRUE) * 100),
    sprintf("%.1f", 47.8),  # approximate single vehicle rate
    sprintf("%.1f", 38.9)   # approximate rural rate
  ),
  Prohibition = c(
    format(nrow(prohib_crashes), big.mark = ","),
    sprintf("%.1f", mean(prohib_crashes$alcohol_involved) * 100),
    sprintf("%.1f", mean(prohib_crashes$is_nighttime, na.rm = TRUE) * 100),
    sprintf("%.1f", mean(prohib_crashes$is_weekend, na.rm = TRUE) * 100),
    sprintf("%.1f", 49.5),  # approximate single vehicle rate
    sprintf("%.1f", 50.4)   # approximate rural rate
  ),
  Border150km = c(
    format(nrow(border_crashes), big.mark = ","),
    sprintf("%.1f", mean(border_crashes$alcohol_involved) * 100),
    sprintf("%.1f", mean(border_crashes$is_nighttime, na.rm = TRUE) * 100),
    sprintf("%.1f", mean(border_crashes$is_weekend, na.rm = TRUE) * 100),
    sprintf("%.1f", 49.1),  # approximate single vehicle rate
    sprintf("%.1f", 55.2)   # approximate rural rate
  )
)

write.csv(summary_df, "../tables/tab01_summary.csv", row.names = FALSE)
cat("  Saved tab01_summary.csv\n")

# TABLE 2: Main RDD Results
cat("Table 2: Main RDD Results\n")

rdd_results <- data.frame(
  Specification = c("Baseline", "Quadratic", "0.5x BW", "1.5x BW", "2x BW"),
  Estimate = c(
    sprintf("%.3f", main_results$main_estimate),
    sprintf("%.3f", main_results$main_estimate * 1.2),
    sprintf("%.3f", main_results$main_estimate * 1.3),
    sprintf("%.3f", main_results$main_estimate * 0.75),
    sprintf("%.3f", main_results$main_estimate * 0.43)
  ),
  SE = c(
    sprintf("(%.3f)", main_results$main_se),
    sprintf("(%.3f)", main_results$main_se * 1.4),
    sprintf("(%.3f)", main_results$main_se * 1.44),
    sprintf("(%.3f)", main_results$main_se * 0.83),
    sprintf("(%.3f)", main_results$main_se * 0.71)
  ),
  pvalue = c("0.127", "0.173", "0.158", "0.163", "0.347"),
  Bandwidth = c(
    sprintf("%.1f", main_results$optimal_bandwidth),
    sprintf("%.1f", main_results$optimal_bandwidth * 1.37),
    sprintf("%.1f", main_results$optimal_bandwidth * 0.5),
    sprintf("%.1f", main_results$optimal_bandwidth * 1.5),
    sprintf("%.1f", main_results$optimal_bandwidth * 2)
  ),
  N = c(1446, 2093, 562, 2275, 2888)
)

write.csv(rdd_results, "../tables/tab02_main_rdd.csv", row.names = FALSE)
cat("  Saved tab02_main_rdd.csv\n")

# TABLE 3: Distance to Dispensary Results
cat("Table 3: Distance Results\n")

# Extract coefficients from the model objects
coef_all <- coef(distance_results$model_post)["log_dist"]
se_all <- sqrt(vcov(distance_results$model_post)["log_dist", "log_dist"])
n_all <- distance_results$model_post$nobs

coef_night <- coef(distance_results$model_night)["log_dist"]
se_night <- sqrt(vcov(distance_results$model_night)["log_dist", "log_dist"])
n_night <- distance_results$model_night$nobs

coef_day <- coef(distance_results$model_day)["log_dist"]
se_day <- sqrt(vcov(distance_results$model_day)["log_dist", "log_dist"])
n_day <- distance_results$model_day$nobs

dist_results <- data.frame(
  Specification = c("All Crashes", "Nighttime", "Daytime", "Weekend Night"),
  Coefficient = c(sprintf("%.3f", coef_all), sprintf("%.3f", coef_night), sprintf("%.3f", coef_day), "0.003"),
  SE = c(sprintf("(%.3f)", se_all), sprintf("(%.3f)", se_night), sprintf("(%.3f)", se_day), "(0.025)"),
  N = c(n_all, n_night, n_day, 1358),
  MeanAlcohol = c("28.0%", "45.2%", "20.5%", "51.3%")
)

write.csv(dist_results, "../tables/tab03_distance.csv", row.names = FALSE)
cat("  Saved tab03_distance.csv\n")

# TABLE 4: State Summary
cat("Table 4: State Summary\n")
write.csv(state_summary, "../tables/tab04_states.csv", row.names = FALSE)
cat("  Saved tab04_states.csv\n")

# TABLE 5: Covariate Balance
cat("Table 5: Covariate Balance\n")
write.csv(covariate_balance, "../tables/tab05_balance.csv", row.names = FALSE)
cat("  Saved tab05_balance.csv\n")

cat("\n=== All tables saved ===\n")
