# ==============================================================================
# Paper 91: Credit, Social Networks, and Political Polarization
# 02_descriptives.R - Summary statistics and correlations
# ==============================================================================

source("00_packages.R")

# Load data
df <- readRDS("../data/analysis_data.rds")

# ==============================================================================
# 1. SUMMARY STATISTICS
# ==============================================================================

cat("Generating summary statistics...\n")

# Panel A: Credit Access Variables
credit_vars <- df %>%
  select(
    `Credit Score` = credit_score,
    `Student Loan Balance ($)` = student_loan,
    `Mortgage Balance ($)` = mortgage,
    `Credit Card Balance ($)` = credit_card,
    `Auto Loan Balance ($)` = auto_loan,
    `Delinquency Rate` = delinquency
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "value") %>%
  group_by(Variable) %>%
  summarize(
    N = sum(!is.na(value)),
    Mean = mean(value, na.rm = TRUE),
    SD = sd(value, na.rm = TRUE),
    Min = min(value, na.rm = TRUE),
    p25 = quantile(value, 0.25, na.rm = TRUE),
    Median = median(value, na.rm = TRUE),
    p75 = quantile(value, 0.75, na.rm = TRUE),
    Max = max(value, na.rm = TRUE),
    .groups = "drop"
  )

# Panel B: Social Capital Variables
social_vars <- df %>%
  select(
    `Economic Connectedness` = ec,
    `Child Economic Connectedness` = child_ec,
    `Friending Bias` = friending_bias,
    `Clustering` = clustering,
    `Volunteering Rate` = volunteering,
    `Civic Organizations (per capita)` = civic_orgs
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "value") %>%
  group_by(Variable) %>%
  summarize(
    N = sum(!is.na(value)),
    Mean = mean(value, na.rm = TRUE),
    SD = sd(value, na.rm = TRUE),
    Min = min(value, na.rm = TRUE),
    p25 = quantile(value, 0.25, na.rm = TRUE),
    Median = median(value, na.rm = TRUE),
    p75 = quantile(value, 0.75, na.rm = TRUE),
    Max = max(value, na.rm = TRUE),
    .groups = "drop"
  )

# Panel C: Political Variables
political_vars <- df %>%
  select(
    `GOP Vote Share 2020` = pct_gop_2020,
    `GOP Vote Share 2016` = pct_gop_2016,
    `GOP Vote Share 2024` = pct_gop_2024,
    `GOP Change 2016-2020` = gop_change_16_20,
    `GOP Change 2020-2024` = gop_change_20_24,
    `GOP Change 2016-2024` = gop_change_16_24
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "value") %>%
  group_by(Variable) %>%
  summarize(
    N = sum(!is.na(value)),
    Mean = mean(value, na.rm = TRUE),
    SD = sd(value, na.rm = TRUE),
    Min = min(value, na.rm = TRUE),
    p25 = quantile(value, 0.25, na.rm = TRUE),
    Median = median(value, na.rm = TRUE),
    p75 = quantile(value, 0.75, na.rm = TRUE),
    Max = max(value, na.rm = TRUE),
    .groups = "drop"
  )

# Panel D: County Covariates
covariate_vars <- df %>%
  select(
    `Median HH Income 2010` = hhinc_median_2010,
    `College Share 2010` = frac_coll_2010,
    `Employment Rate 2010` = emp_2010,
    `Poverty Share 2010` = poor_share_2010,
    `Gini Coefficient 2010` = gini_2010,
    `Share White 2010` = share_white_2010,
    `Share Black 2010` = share_black_2010,
    `Population Density 2010` = popdensity
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "value") %>%
  group_by(Variable) %>%
  summarize(
    N = sum(!is.na(value)),
    Mean = mean(value, na.rm = TRUE),
    SD = sd(value, na.rm = TRUE),
    Min = min(value, na.rm = TRUE),
    p25 = quantile(value, 0.25, na.rm = TRUE),
    Median = median(value, na.rm = TRUE),
    p75 = quantile(value, 0.75, na.rm = TRUE),
    Max = max(value, na.rm = TRUE),
    .groups = "drop"
  )

# Combine all panels
summary_stats <- bind_rows(
  credit_vars %>% mutate(Panel = "A: Credit Access"),
  social_vars %>% mutate(Panel = "B: Social Capital"),
  political_vars %>% mutate(Panel = "C: Political"),
  covariate_vars %>% mutate(Panel = "D: County Covariates")
) %>%
  relocate(Panel)

# Print
print(summary_stats, n = 30)

# ==============================================================================
# 2. CORRELATION MATRIX
# ==============================================================================

cat("\nComputing correlation matrix...\n")

# Select key variables for correlation
cor_data <- df %>%
  select(
    credit_score, student_loan, delinquency,
    ec, friending_bias, clustering,
    pct_gop_2020, gop_change_16_24,
    hhinc_median_2010, frac_coll_2010, popdensity
  ) %>%
  drop_na()

cor_matrix <- cor(cor_data, use = "pairwise.complete.obs")

# Print
cat("\nCorrelation Matrix:\n")
print(round(cor_matrix, 3))

# ==============================================================================
# 3. KEY STATISTICS FOR PAPER
# ==============================================================================

cat("\n\n=== KEY STATISTICS FOR PAPER ===\n\n")

# Credit score range
cat(sprintf("Credit score range: %.0f - %.0f\n",
            min(df$credit_score, na.rm = TRUE),
            max(df$credit_score, na.rm = TRUE)))

# Economic connectedness range
cat(sprintf("Economic connectedness range: %.2f - %.2f\n",
            min(df$ec, na.rm = TRUE),
            max(df$ec, na.rm = TRUE)))

# Key correlations
cat(sprintf("\nCredit score - EC correlation: %.3f\n",
            cor(df$credit_score, df$ec, use = "complete.obs")))
cat(sprintf("Credit score - GOP 2020 correlation: %.3f\n",
            cor(df$credit_score, df$pct_gop_2020, use = "complete.obs")))
cat(sprintf("EC - GOP 2020 correlation: %.3f\n",
            cor(df$ec, df$pct_gop_2020, use = "complete.obs")))

# Share Trump counties
cat(sprintf("\nShare Trump counties 2020: %.1f%%\n",
            100 * mean(df$trump_county_2020, na.rm = TRUE)))

# Mean shift
cat(sprintf("Mean GOP shift 2016-2024: %.3f pp\n",
            100 * mean(df$gop_change_16_24, na.rm = TRUE)))

# ==============================================================================
# 4. SAVE SUMMARY TABLES
# ==============================================================================

write_csv(summary_stats, "../tables/summary_statistics.csv")
write_csv(as.data.frame(cor_matrix) %>% rownames_to_column("Variable"),
          "../tables/correlation_matrix.csv")

cat("\nTables saved to ../tables/\n")
