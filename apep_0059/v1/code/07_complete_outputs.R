# =============================================================================
# 07_complete_outputs.R
# Generate all figures, tables, and save data for replication
# =============================================================================

library(tidyverse)
library(sandwich)
library(lmtest)
library(sensemakr)
library(ggplot2)

set.seed(20260125)

# Set paths
output_dir <- "/Users/dyanag/auto-policy-evals/output/paper_1"
fig_dir <- file.path(output_dir, "figures")
tbl_dir <- file.path(output_dir, "tables")
data_dir <- file.path(output_dir, "data")

dir.create(fig_dir, showWarnings = FALSE)
dir.create(tbl_dir, showWarnings = FALSE)

# APEP ggplot theme
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

# =============================================================================
# FETCH DATA FROM CENSUS API
# =============================================================================

cat("Fetching PUMS data from Census API...\n")

fetch_pums <- function(year, state = "*") {
  base_url <- paste0("https://api.census.gov/data/", year, "/acs/acs1/pums")
  vars <- "AGEP,SEX,RAC1P,HISP,SCHL,MAR,COW,WKHP,HICOV,HINS1,HINS2,HINS3,HINS4,NPF,PINCP,ST,PWGTP"

  url <- paste0(base_url, "?get=", vars, "&for=state:", state)

  tryCatch({
    response <- httr::GET(url)
    if (httr::status_code(response) == 200) {
      data <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))
      df <- as.data.frame(data[-1, ], stringsAsFactors = FALSE)
      colnames(df) <- data[1, ]
      df$year <- year
      return(df)
    }
  }, error = function(e) {
    cat("Error fetching", year, ":", e$message, "\n")
    return(NULL)
  })
}

# Fetch 2022 data only for speed
df_raw <- fetch_pums(2022)

if (!is.null(df_raw)) {
  cat("Fetched", nrow(df_raw), "observations from 2022\n")
} else {
  stop("Failed to fetch data")
}

# =============================================================================
# CLEAN DATA
# =============================================================================

# Medicaid expansion states (by 2022)
expansion_states <- c("02", "04", "05", "06", "08", "09", "10", "11", "12", "15",
                      "17", "18", "19", "20", "21", "22", "23", "24", "25", "26",
                      "27", "28", "29", "30", "31", "32", "33", "34", "35", "36",
                      "37", "38", "39", "40", "41", "42", "44", "45", "46", "47",
                      "49", "50", "51", "53", "54", "55", "56")

df <- df_raw %>%
  mutate(
    age = as.numeric(AGEP),
    female = as.numeric(SEX == "2"),
    hours_worked = as.numeric(WKHP),
    income = as.numeric(PINCP),
    weight = as.numeric(PWGTP),
    state = ST
  ) %>%
  # Age 25-64, employed
  filter(age >= 25 & age <= 64) %>%
  filter(!is.na(COW) & COW %in% c("1", "2", "3", "4", "5", "6", "7")) %>%
  filter(hours_worked >= 10) %>%
  mutate(
    # Self-employment
    self_employed = as.numeric(COW %in% c("6", "7")),

    # Insurance variables
    any_insurance = as.numeric(HICOV == "1"),
    employer_insurance = as.numeric(HINS1 == "1"),
    direct_purchase = as.numeric(HINS2 == "1"),
    medicaid = as.numeric(HINS4 == "1"),

    # Demographics
    race = case_when(
      HISP != "01" ~ "Hispanic",
      RAC1P == "1" ~ "White",
      RAC1P == "2" ~ "Black",
      RAC1P %in% c("6", "7") ~ "Asian",
      TRUE ~ "Other"
    ),

    educ = case_when(
      as.numeric(SCHL) < 16 ~ "Less than HS",
      as.numeric(SCHL) %in% 16:17 ~ "High School",
      as.numeric(SCHL) %in% 18:20 ~ "Some College",
      as.numeric(SCHL) == 21 ~ "Bachelors",
      as.numeric(SCHL) >= 22 ~ "Graduate",
      TRUE ~ "Unknown"
    ),

    married = as.numeric(MAR == "1"),
    household_size = pmin(as.numeric(NPF), 10),

    # Income quintiles
    income_quintile = case_when(
      income < 25000 ~ "Q1",
      income < 45000 ~ "Q2",
      income < 70000 ~ "Q3",
      income < 110000 ~ "Q4",
      TRUE ~ "Q5"
    ),

    medicaid_expanded = as.numeric(state %in% expansion_states)
  ) %>%
  select(age, female, race, educ, married, hours_worked, household_size,
         income_quintile, self_employed, any_insurance, employer_insurance,
         direct_purchase, medicaid, medicaid_expanded, state, weight, income)

cat("Cleaned data:", nrow(df), "observations\n")

# Save data sample
write_csv(df %>% slice_sample(n = min(100000, nrow(df))),
          file.path(data_dir, "pums_sample.csv"))
cat("Saved data sample to", file.path(data_dir, "pums_sample.csv"), "\n")

# =============================================================================
# DESCRIPTIVE STATISTICS
# =============================================================================

stats <- df %>%
  group_by(self_employed) %>%
  summarise(
    n = n(),
    age_mean = mean(age),
    female_pct = 100 * mean(female),
    college_pct = 100 * mean(educ %in% c("Bachelors", "Graduate")),
    married_pct = 100 * mean(married),
    hours_mean = mean(hours_worked),
    any_insurance = 100 * mean(any_insurance),
    employer_ins = 100 * mean(employer_insurance),
    direct_purchase = 100 * mean(direct_purchase),
    medicaid = 100 * mean(medicaid),
    .groups = "drop"
  )

# Save descriptive stats
saveRDS(stats, file.path(data_dir, "descriptive_stats.rds"))

# Create Table 1: Summary Statistics
table1 <- tibble(
  Variable = c("Age", "Female (%)", "College+ (%)", "Married (%)",
               "Hours worked/week", "Any insurance (%)",
               "Employer insurance (%)", "Direct purchase (%)", "Medicaid (%)"),
  `Wage Workers` = c(
    sprintf("%.1f", stats$age_mean[1]),
    sprintf("%.1f", stats$female_pct[1]),
    sprintf("%.1f", stats$college_pct[1]),
    sprintf("%.1f", stats$married_pct[1]),
    sprintf("%.1f", stats$hours_mean[1]),
    sprintf("%.1f", stats$any_insurance[1]),
    sprintf("%.1f", stats$employer_ins[1]),
    sprintf("%.1f", stats$direct_purchase[1]),
    sprintf("%.1f", stats$medicaid[1])
  ),
  `Self-Employed` = c(
    sprintf("%.1f", stats$age_mean[2]),
    sprintf("%.1f", stats$female_pct[2]),
    sprintf("%.1f", stats$college_pct[2]),
    sprintf("%.1f", stats$married_pct[2]),
    sprintf("%.1f", stats$hours_mean[2]),
    sprintf("%.1f", stats$any_insurance[2]),
    sprintf("%.1f", stats$employer_ins[2]),
    sprintf("%.1f", stats$direct_purchase[2]),
    sprintf("%.1f", stats$medicaid[2])
  )
)

write_csv(table1, file.path(tbl_dir, "table1_summary.csv"))

# =============================================================================
# MAIN REGRESSION ANALYSIS
# =============================================================================

outcomes <- c("any_insurance", "employer_insurance", "direct_purchase", "medicaid")
outcome_labels <- c("Any Insurance", "Employer Insurance", "Direct Purchase", "Medicaid")

results <- list()

for (i in seq_along(outcomes)) {
  outcome <- outcomes[i]

  formula <- as.formula(paste(
    outcome,
    "~ self_employed + age + I(age^2) + female + race + educ +",
    "married + hours_worked + I(hours_worked^2) + household_size +",
    "income_quintile + medicaid_expanded + factor(state)"
  ))

  fit <- lm(formula, data = df)
  robust_se <- sqrt(diag(vcovHC(fit, type = "HC2")))

  coef_est <- coef(fit)["self_employed"]
  coef_se <- robust_se["self_employed"]

  results[[outcome]] <- tibble(
    outcome = outcome_labels[i],
    coef = coef_est,
    se = coef_se,
    ci_lower = coef_est - 1.96 * coef_se,
    ci_upper = coef_est + 1.96 * coef_se,
    p_value = 2 * pnorm(-abs(coef_est / coef_se)),
    n = nobs(fit),
    r_squared = summary(fit)$r.squared
  )
}

results_df <- bind_rows(results)
saveRDS(results_df, file.path(data_dir, "ols_results.rds"))

# Create Table 2: Main Results
table2 <- results_df %>%
  mutate(
    Coefficient = sprintf("%.4f", coef),
    SE = sprintf("(%.4f)", se),
    `95% CI` = sprintf("[%.4f, %.4f]", ci_lower, ci_upper),
    `p-value` = sprintf("%.4f", p_value)
  ) %>%
  select(Outcome = outcome, Coefficient, SE, `95% CI`, `p-value`, N = n)

write_csv(table2, file.path(tbl_dir, "table2_main_results.csv"))

# =============================================================================
# FIGURE 1: Insurance Coverage by Employment Type
# =============================================================================

fig1_data <- df %>%
  group_by(self_employed) %>%
  summarise(
    any_insurance = mean(any_insurance),
    employer_ins = mean(employer_insurance),
    direct_purchase = mean(direct_purchase),
    medicaid = mean(medicaid),
    .groups = "drop"
  ) %>%
  pivot_longer(-self_employed, names_to = "coverage_type", values_to = "rate") %>%
  mutate(
    employment = ifelse(self_employed == 1, "Self-Employed", "Wage Workers"),
    coverage_type = case_when(
      coverage_type == "any_insurance" ~ "Any Insurance",
      coverage_type == "employer_ins" ~ "Employer",
      coverage_type == "direct_purchase" ~ "Direct Purchase",
      coverage_type == "medicaid" ~ "Medicaid"
    ),
    coverage_type = factor(coverage_type,
                           levels = c("Any Insurance", "Employer", "Direct Purchase", "Medicaid"))
  )

fig1 <- ggplot(fig1_data, aes(x = coverage_type, y = rate * 100, fill = employment)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  scale_fill_manual(values = c("Self-Employed" = "#E69F00", "Wage Workers" = "#0072B2")) +
  labs(
    title = "Health Insurance Coverage by Employment Type",
    subtitle = "American Community Survey 2022, Adults 25-64",
    x = "",
    y = "Coverage Rate (%)",
    fill = ""
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig1_coverage_by_employment.png"), fig1,
       width = 8, height = 6, dpi = 300)

# =============================================================================
# FIGURE 2: Coefficient Plot
# =============================================================================

fig2_data <- results_df %>%
  mutate(outcome = factor(outcome, levels = rev(outcome_labels)))

fig2 <- ggplot(fig2_data, aes(x = coef, y = outcome)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, linewidth = 0.8) +
  geom_point(size = 3, color = "#0072B2") +
  labs(
    title = "Effect of Self-Employment on Insurance Coverage",
    subtitle = "OLS estimates with 95% confidence intervals (HC2 robust SEs)",
    x = "Coefficient (percentage points)",
    y = ""
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_coefficient_plot.png"), fig2,
       width = 8, height = 5, dpi = 300)

# =============================================================================
# FIGURE 3: Heterogeneity by Medicaid Expansion
# =============================================================================

het_results <- list()

for (expanded in c(0, 1)) {
  subset_df <- df %>% filter(medicaid_expanded == expanded)

  fit <- lm(any_insurance ~ self_employed + age + I(age^2) + female +
              race + educ + married + hours_worked + factor(state),
            data = subset_df)

  robust_se <- sqrt(diag(vcovHC(fit, type = "HC2")))["self_employed"]
  coef_est <- coef(fit)["self_employed"]

  het_results[[as.character(expanded)]] <- tibble(
    group = ifelse(expanded == 1, "Expansion States", "Non-Expansion States"),
    coef = coef_est,
    se = robust_se,
    ci_lower = coef_est - 1.96 * robust_se,
    ci_upper = coef_est + 1.96 * robust_se
  )
}

het_df <- bind_rows(het_results)

fig3 <- ggplot(het_df, aes(x = coef, y = group)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.15, linewidth = 0.8) +
  geom_point(size = 4, color = "#D55E00") +
  labs(
    title = "Self-Employment Effect by Medicaid Expansion Status",
    subtitle = "Effect on any insurance coverage",
    x = "Coefficient (percentage points)",
    y = ""
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_heterogeneity_expansion.png"), fig3,
       width = 8, height = 4, dpi = 300)

# =============================================================================
# FIGURE 4: Heterogeneity by Income
# =============================================================================

income_results <- list()

for (q in c("Q1", "Q2", "Q3", "Q4", "Q5")) {
  subset_df <- df %>% filter(income_quintile == q)

  fit <- lm(any_insurance ~ self_employed + age + I(age^2) + female +
              race + educ + married + hours_worked + medicaid_expanded + factor(state),
            data = subset_df)

  robust_se <- sqrt(diag(vcovHC(fit, type = "HC2")))["self_employed"]
  coef_est <- coef(fit)["self_employed"]

  income_results[[q]] <- tibble(
    quintile = q,
    coef = coef_est,
    se = robust_se,
    ci_lower = coef_est - 1.96 * robust_se,
    ci_upper = coef_est + 1.96 * robust_se
  )
}

income_df <- bind_rows(income_results)

fig4 <- ggplot(income_df, aes(x = quintile, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.15, linewidth = 0.8) +
  geom_point(size = 4, color = "#009E73") +
  labs(
    title = "Self-Employment Effect by Income Quintile",
    subtitle = "Effect on any insurance coverage",
    x = "Income Quintile",
    y = "Coefficient (percentage points)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_heterogeneity_income.png"), fig4,
       width = 8, height = 5, dpi = 300)

# =============================================================================
# SENSITIVITY ANALYSIS
# =============================================================================

# Simple OLS for sensemakr
fit_sens <- lm(
  any_insurance ~ self_employed + age + I(age^2) + female +
    race + educ + married + hours_worked + medicaid_expanded,
  data = df
)

sens <- sensemakr(
  model = fit_sens,
  treatment = "self_employed",
  benchmark_covariates = c("female", "married"),
  kd = 1:3
)

# Save sensitivity results
saveRDS(sens, file.path(data_dir, "sensitivity_analysis.rds"))

# Create Table 3: Sensitivity bounds
sens_summary <- summary(sens)
sens_table <- tibble(
  Confounder = c("1x Female", "2x Female", "3x Female",
                 "1x Married", "2x Married", "3x Married"),
  `Adjusted Effect` = c(
    sens$bounds$female$adjusted_estimate[1:3],
    sens$bounds$married$adjusted_estimate[1:3]
  ),
  `Bias` = c(
    sens$bounds$female$bias[1:3],
    sens$bounds$married$bias[1:3]
  )
)
write_csv(sens_table, file.path(tbl_dir, "table3_sensitivity.csv"))

cat("\n========================================\n")
cat("ALL OUTPUTS GENERATED SUCCESSFULLY\n")
cat("========================================\n\n")
cat("Figures saved to:", fig_dir, "\n")
cat("Tables saved to:", tbl_dir, "\n")
cat("Data saved to:", data_dir, "\n")
