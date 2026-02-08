# ============================================================================
# Paper 64: The Pence Effect
# 04_tables.R - Create All Tables
# ============================================================================

source("code/00_packages.R")

library(fixest)
library(tidyverse)

cat("Creating publication-ready tables...\n")

# ============================================================================
# Load Data
# ============================================================================

emp_data <- readRDS("data/employment_data.rds")
industry_harassment <- readRDS("data/industry_harassment.rds")
summary_stats <- readRDS("data/summary_stats.rds")
models <- readRDS("data/ddd_models.rds")

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("Creating Table 1: Summary statistics...\n")

# Reshape summary stats
table1 <- summary_stats %>%
  select(Group, Period, N, mean_emp, sd_emp, mean_hires) %>%
  pivot_wider(
    names_from = Period,
    values_from = c(N, mean_emp, sd_emp, mean_hires)
  )

# Create LaTeX table
table1_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics by Group and Period}\n",
  "\\label{tab:summary_stats}\n",
  "\\begin{tabular}{lcccccc}\n",
  "\\toprule\n",
  " & \\multicolumn{3}{c}{Pre-MeToo (2014-2017)} & \\multicolumn{3}{c}{Post-MeToo (2018-2023)} \\\\\n",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-7}\n",
  "Group & N & Mean Emp & Mean Hires & N & Mean Emp & Mean Hires \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(table1)) {
  table1_tex <- paste0(table1_tex,
    table1$Group[i], " & ",
    format(table1$`N_Pre-MeToo (2014-2017)`[i], big.mark = ","), " & ",
    sprintf("%.1f", table1$`mean_emp_Pre-MeToo (2014-2017)`[i]), " & ",
    sprintf("%.1f", table1$`mean_hires_Pre-MeToo (2014-2017)`[i]), " & ",
    format(table1$`N_Post-MeToo (2018-2023)`[i], big.mark = ","), " & ",
    sprintf("%.1f", table1$`mean_emp_Post-MeToo (2018-2023)`[i]), " & ",
    sprintf("%.1f", table1$`mean_hires_Post-MeToo (2018-2023)`[i]), " \\\\\n"
  )
}

table1_tex <- paste0(table1_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\caption*{\\footnotesize Note: Employment and hires measured in thousands. ",
  "High-harassment industries include accommodation, retail, healthcare, arts, and administrative services.}\n",
  "\\end{table}\n"
)

cat(table1_tex, file = "figures/table1_summary_stats.tex")

# ============================================================================
# Table 3: Industry Harassment Classification
# ============================================================================

cat("Creating Table 3: Industry classification...\n")

table3_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Industry Classification by Sexual Harassment Exposure}\n",
  "\\label{tab:industry_classification}\n",
  "\\begin{tabular}{llcc}\n",
  "\\toprule\n",
  "NAICS & Industry & Harassment Rate & Classification \\\\\n",
  "\\midrule\n"
)

ih <- industry_harassment %>% arrange(desc(harassment_rate))

for (i in 1:nrow(ih)) {
  table3_tex <- paste0(table3_tex,
    ih$naics[i], " & ",
    ih$industry_name[i], " & ",
    sprintf("%.1f", ih$harassment_rate[i]), " & ",
    ifelse(ih$high_harassment[i], "High", "Low"), " \\\\\n"
  )
}

table3_tex <- paste0(table3_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\caption*{\\footnotesize Note: Harassment rate measured as EEOC sexual harassment charges per 10,000 employees (2010-2016 average). ",
  "Classification threshold is the median rate across industries.}\n",
  "\\end{table}\n"
)

cat(table3_tex, file = "figures/table3_industry_classification.tex")

# ============================================================================
# Table 4: Robustness Checks
# ============================================================================

cat("Creating Table 4: Robustness checks...\n")

# Re-run some robustness specifications
emp_quarterly <- emp_data %>%
  mutate(quarter = ceiling(month / 3)) %>%
  group_by(state_fips, naics, year, quarter, female, high_harassment) %>%
  summarise(
    employment = mean(employment, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    yearqtr = year + (quarter - 1) / 4,
    post_metoo = as.integer(yearqtr >= 2017.75),
    DDD_term = female * high_harassment * post_metoo,
    state_industry = paste(state_fips, naics, sep = "_"),
    log_employment = log(employment + 1)
  )

# Main specification
r1 <- feols(
  log_employment ~ DDD_term |
    state_fips^yearqtr + naics^female + female^yearqtr + naics^yearqtr,
  data = emp_quarterly,
  cluster = ~state_industry
)

# Exclude accommodation & food (largest high-harassment)
r2 <- feols(
  log_employment ~ DDD_term |
    state_fips^yearqtr + naics^female + female^yearqtr + naics^yearqtr,
  data = emp_quarterly %>% filter(naics != "72"),
  cluster = ~state_industry
)

# Exclude healthcare (may have unique COVID dynamics)
r3 <- feols(
  log_employment ~ DDD_term |
    state_fips^yearqtr + naics^female + female^yearqtr + naics^yearqtr,
  data = emp_quarterly %>% filter(naics != "62"),
  cluster = ~state_industry
)

# Pre-2020 only (avoid COVID)
r4 <- feols(
  log_employment ~ DDD_term |
    state_fips^yearqtr + naics^female + female^yearqtr + naics^yearqtr,
  data = emp_quarterly %>% filter(year < 2020),
  cluster = ~state_industry
)

# State-clustered SE
r5 <- feols(
  log_employment ~ DDD_term |
    state_fips^yearqtr + naics^female + female^yearqtr + naics^yearqtr,
  data = emp_quarterly,
  cluster = ~state_fips
)

etable(r1, r2, r3, r4, r5,
       dict = c(DDD_term = "Female $\\times$ High Harass. $\\times$ Post"),
       headers = c("Main", "Excl. Accom.", "Excl. Healthcare", "Pre-COVID", "State Cluster"),
       fitstat = ~ r2 + n,
       se.below = TRUE,
       title = "Robustness Checks",
       label = "tab:robustness",
       file = "figures/table4_robustness.tex")

# ============================================================================
# Table 5: Placebo Tests
# ============================================================================

cat("Creating Table 5: Placebo tests...\n")

# Placebo: 2015
emp_placebo15 <- emp_quarterly %>%
  mutate(
    post_placebo = as.integer(yearqtr >= 2015.75),
    DDD_placebo = female * high_harassment * post_placebo
  ) %>%
  filter(yearqtr < 2017.75)  # Only use pre-MeToo data

p15 <- feols(
  log_employment ~ DDD_placebo |
    state_fips^yearqtr + naics^female + female^yearqtr + naics^yearqtr,
  data = emp_placebo15,
  cluster = ~state_industry
)

# Placebo: 2016
emp_placebo16 <- emp_quarterly %>%
  mutate(
    post_placebo = as.integer(yearqtr >= 2016.75),
    DDD_placebo = female * high_harassment * post_placebo
  ) %>%
  filter(yearqtr < 2017.75)

p16 <- feols(
  log_employment ~ DDD_placebo |
    state_fips^yearqtr + naics^female + female^yearqtr + naics^yearqtr,
  data = emp_placebo16,
  cluster = ~state_industry
)

# Actual MeToo
p17 <- r1

etable(p15, p16, p17,
       dict = c(DDD_placebo = "DDD Coefficient", DDD_term = "DDD Coefficient"),
       headers = c("Placebo (Q4 2015)", "Placebo (Q4 2016)", "Actual (Q4 2017)"),
       fitstat = ~ r2 + n,
       se.below = TRUE,
       title = "Placebo Tests: Alternative Treatment Dates",
       label = "tab:placebo",
       file = "figures/table5_placebo.tex")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Tables Created ===\n")
cat("1. table1_summary_stats.tex - Summary statistics by group and period\n")
cat("2. table2_ddd_results.tex - Main DDD regression results (from main analysis)\n")
cat("3. table3_industry_classification.tex - Industry harassment classification\n")
cat("4. table4_robustness.tex - Robustness checks\n")
cat("5. table5_placebo.tex - Placebo tests\n")

cat("\nAll tables saved to figures/\n")
